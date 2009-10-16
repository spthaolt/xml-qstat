<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
<!ENTITY  newline "<xsl:text>&#x0a;</xsl:text>">
<!ENTITY  space   "<xsl:text> </xsl:text>">
<!ENTITY  nbsp    "&#xa0;">
]>
<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<!--
   | process XML generated by
   |     "qstat -u * -xml -r -s prs"
   | to produce a list of active and pending jobs
   |
   | expected input:
   |   - qstat.xml
   |
   | uses external files:
   |  - config/config.xml
   -->

<!-- ======================= Imports / Includes =========================== -->
<!-- Include our masthead and templates -->
<xsl:include href="xmlqstat-masthead.xsl"/>
<xsl:include href="xmlqstat-templates.xsl"/>
<!-- Include processor-instruction parsing -->
<xsl:include href="pi-param.xsl"/>

<!-- ======================== Passed Parameters =========================== -->
<xsl:param name="clusterName">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'clusterName'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="timestamp">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'timestamp'"/>
  </xsl:call-template>
</xsl:param>
<xsl:param name="filterByUser">
  <xsl:call-template name="pi-param">
    <xsl:with-param  name="name"    select="'filterByUser'"/>
  </xsl:call-template>
</xsl:param>


<!-- ======================= Internal Parameters ========================== -->
<!-- configuration parameters -->
<xsl:variable
    name="configFile"
    select="document('../config/config.xml')/config" />
<xsl:variable
    name="viewlog"
    select="$configFile/programs/viewlog" />
<xsl:variable
    name="clusterNode"
    select="$configFile/clusters/cluster[@name=$clusterName]" />

<xsl:variable name="cgiParams">
  <xsl:call-template name="cgiParams">
    <xsl:with-param name="clusterNode" select="$clusterNode" />
  </xsl:call-template>
</xsl:variable>

<!-- the date according to the processing-instruction -->
<xsl:variable name="piDate">
  <xsl:call-template name="pi-named-param">
    <xsl:with-param  name="pis"  select="processing-instruction('qstat')" />
    <xsl:with-param  name="name" select="'date'"/>
  </xsl:call-template>
</xsl:variable>


<!-- ======================= Output Declaration =========================== -->
<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
/>


<!-- ============================ Matching ================================ -->
<xsl:template match="/" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Refresh" content="30" />
<link rel="icon" type="image/png" href="css/screen/icons/lorry_flatbed.png"/>
&newline;

<title> jobs
<xsl:if test="$clusterName"> @<xsl:value-of select="$clusterName"/></xsl:if>
</title>

&newline;
<xsl:comment> load javascript </xsl:comment>
&newline;
<!-- NB: <script> .. </script> needs some (any) content -->
<script src="javascript/cookie.js" type="text/javascript">
  // Dortch cookies
</script>
<script src="javascript/xmlqstat.js" type="text/javascript">
  // display altering code
</script>

&newline;
<!-- load css -->
<link href="css/xmlqstat.css" media="screen" rel="Stylesheet" type="text/css" />
<style type="text/css">
  /* initially hide elements that rely on javascript */
  #activeJobTableToggle  { visibility: hidden; }
  #pendingJobTableToggle { visibility: hidden; }
</style>
&newline;
</head>

<!-- nothing to pre-calculate -->


<!-- begin body -->
<body>
&newline;
<xsl:comment> Main body content </xsl:comment>
&newline;

<div id="main">
<!-- Topomost Logo Div -->
<xsl:call-template name="topLogo"/>
<!-- Top Menu Bar -->
<xsl:call-template name="topMenu"/>

&newline;
<xsl:comment> Top dotted line bar (holds the qmaster host and update time) </xsl:comment>
&newline;
<div class="dividerBarBelow">
<xsl:choose>
<xsl:when test="$clusterNode">
  <!-- cluster/cell name -->
  <xsl:value-of select="$clusterNode/@name"/>
  <xsl:if test="$clusterNode/@cell != 'default'">/<xsl:value-of
      select="$clusterNode/@cell"/>
  </xsl:if>
</xsl:when>
<xsl:otherwise>
  <!-- unnamed cluster: -->
  unnamed cluster
</xsl:otherwise>
</xsl:choose>
<!-- replace 'T' in dateTime for easier reading -->
&space; <xsl:value-of select="translate($piDate, 'T', ' ')"/>
</div>
&newline;

<xsl:comment> Active Jobs </xsl:comment>
&newline;
<xsl:if test="count(//job_info)">

<!--
   | count active jobs/slots for user or everyone
   | here we can count the slots directly, since each job/task is listed separately
   -->
<xsl:variable name="AJ_total">
  <xsl:choose>
  <xsl:when test="string-length($filterByUser)">
    <xsl:value-of select="count(//job_info/queue_info/job_list[JB_owner=$filterByUser])"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="count(//job_info/queue_info/job_list)"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="AJ_slots">
  <xsl:choose>
  <xsl:when test="string-length($filterByUser)">
    <xsl:call-template name="count-slots">
      <xsl:with-param name="nodeList" select="//job_info/queue_info/job_list[JB_owner=$filterByUser]"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="count-slots">
      <xsl:with-param name="nodeList" select="//job_info/queue_info/job_list"/>
    </xsl:call-template>
  </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<blockquote>
<xsl:choose>
<xsl:when test="$AJ_total &gt; 0">
  <!-- active jobs: -->
  <table class="listing">
    <tr valign="middle">
    <td>
      <div class="tableCaption">
        <xsl:value-of select="$AJ_total"/> active jobs
        <xsl:if test="string-length($filterByUser)">
          for <em><xsl:value-of select="$filterByUser"/></em>
        </xsl:if>
        (<xsl:value-of select="$AJ_slots"/> slots)
      </div>
      <!-- show/hide activeJobTable via javascript -->
      <xsl:call-template name="toggleElementVisibility">
        <xsl:with-param name="name"  select="'activeJobTable'"/>
      </xsl:call-template>
    </td>
    </tr>
  </table>
  &newline;
  <xsl:apply-templates select="//job_info/queue_info" />
</xsl:when>
<xsl:otherwise>
  <!-- no active jobs -->
  <div class="skipTableFormat">
    <img alt="*" src="css/screen/list_bullet.png" />
      no active jobs
      <xsl:if test="string-length($filterByUser)">
        for <em><xsl:value-of select="$filterByUser"/></em>
    </xsl:if>
  </div>
</xsl:otherwise>
</xsl:choose>
</blockquote>

&newline;
<xsl:comment> Pending Jobs </xsl:comment>
&newline;

<!--
   | count pending jobs/slots for user or everyone
   | we must count the slots ourselves, since pending job tasks are grouped together
   -->
<xsl:variable name="PJ_total">
  <xsl:choose>
  <xsl:when test="string-length($filterByUser)">
    <xsl:value-of select="count(//job_info/job_info/job_list[JB_owner=$filterByUser])"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="count(//job_info/job_info/job_list)"/>
  </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="PJ_slots">
  <xsl:choose>
  <xsl:when test="string-length($filterByUser)">
    <xsl:call-template name="count-slots">
      <xsl:with-param name="nodeList" select="//job_info/job_info/job_list[JB_owner=$filterByUser]"/>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:call-template name="count-slots">
      <xsl:with-param name="nodeList" select="//job_info/job_info/job_list"/>
    </xsl:call-template>
  </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<blockquote>
<xsl:choose>
<xsl:when test="$PJ_total &gt; 0">
  <!-- pending jobs: -->
  <table class="listing">
    <tr valign="middle">
    <td>
      <div class="tableCaption">
        <xsl:value-of select="$PJ_total"/> pending jobs
        <xsl:if test="string-length($filterByUser)">
          for <em><xsl:value-of select="$filterByUser"/></em>
        </xsl:if>
        (<xsl:value-of select="$PJ_slots"/> slots)
      </div>
      <!-- show/hide pendingJobTable via javascript -->
      <xsl:call-template name="toggleElementVisibility">
        <xsl:with-param name="name" select="'pendingJobTable'"/>
      </xsl:call-template>
    </td>
    </tr>
  </table>
  &newline;
  <xsl:apply-templates select="//job_info/job_info" />
</xsl:when>
<xsl:otherwise>
  <!-- no pending jobs -->
  <div class="skipTableFormat">
    <img alt="*" src="css/screen/list_bullet.png" />
    no pending jobs
    <xsl:if test="string-length($filterByUser)">
      for user <em><xsl:value-of select="$filterByUser"/></em>
    </xsl:if>
  </div>
</xsl:otherwise>
</xsl:choose>
</blockquote>
</xsl:if>

<!-- bottom status bar with rendered time -->
<xsl:call-template name="bottomStatusBar">
  <xsl:with-param name="timestamp" select="$timestamp" />
</xsl:call-template>

&newline;
</div>
</body>
&newline;
<xsl:comment> javascript tricks after loading body </xsl:comment>
&newline;
<script type="text/javascript">
   // hide elements based on the cookie values
   hideDivFromCookie("activeJobTable");
   hideDivFromCookie("pendingJobTable");

   // expose toggle elements that rely on javascript
   document.getElementById("activeJobTableToggle").style.visibility = "visible";
   document.getElementById("pendingJobTableToggle").style.visibility = "visible";
</script>

</html>
<!-- end body/html -->
</xsl:template>


<!--
  active jobs: header
 -->
<xsl:template match="job_info/queue_info">

  &newline;
  <div id="activeJobTable">
    <table class="listing">
    <tr>
      <th>jobId</th>
      <th>owner</th>
      <th>name</th>
      <th>slots</th>
      <th>tasks</th>
      <th>queue</th>
      <th><acronym title="priority">startTime</acronym></th>
      <th>state</th>
    </tr>
    &newline;
    <xsl:for-each select="job_list[@state='running']">
      <!-- sorted by job number and task -->
      <xsl:sort select="JB_job_number"/>
      <xsl:sort select="tasks"/>
      &newline;
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    </table>
  </div>
  &newline;
</xsl:template>

<!--
  active jobs: contents
 -->
<xsl:template match="job_list[@state='running']">
<!-- per user sort -->
<xsl:if test="not(string-length($filterByUser)) or JB_owner=$filterByUser">

  <tr>
  <!-- jobId with resource requests -->
  <!-- link jobId to details: "jobinfo?{jobId}" -->
  <td>
    <xsl:element name="a">
      <xsl:attribute name="title">
        <xsl:for-each select="hard_request">
          <xsl:value-of select="@name"/>=<xsl:value-of select="."/>
          &space;
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="href">jobinfo?<xsl:value-of select="JB_job_number"/></xsl:attribute>
      <xsl:value-of select="JB_job_number" />
    </xsl:element>
  </td>
  <!-- owner -->
  <td>
    <!-- link owner names to "jobs?user={owner}" -->
    <xsl:element name="a">
      <xsl:attribute name="title">view jobs owned by <xsl:value-of select="JB_owner"/></xsl:attribute>
      <xsl:attribute name="href">jobs?user=<xsl:value-of select="JB_owner"/></xsl:attribute>
      <xsl:value-of select="JB_owner" />
    </xsl:element>
  </td>
  <!-- name and full name -->
  <td>
    <xsl:call-template name="shortName">
      <xsl:with-param name="name" select="full_job_name"/>
    </xsl:call-template>
  </td>
  <!-- slots -->
  <td>
    <xsl:value-of select="slots" />
  </td>
  <!-- task -->
  <td>
    <xsl:value-of select="tasks" />
  </td>
  <!-- queue -->
  <td>
    <xsl:call-template name="unqualifiedQueue">
      <xsl:with-param name="queue" select="queue_name"/>
    </xsl:call-template>
  </td>
  <!-- startTime with priority-->
  <td>
    <xsl:element name="acronym">
      <xsl:attribute name="title"><xsl:value-of select="JAT_prio"/></xsl:attribute>
      <xsl:value-of select="JAT_start_time" />
    </xsl:element>
  </td>
  <!-- state : with link to residuals -->
  <td>
    <xsl:value-of select="state" />
    <xsl:if test="string-length($viewlog)">
      <xsl:apply-templates select="." mode="viewlog"/>
    </xsl:if>
  </td>
  </tr>
&newline;
</xsl:if>
</xsl:template>


<!--
  pending jobs: header
 -->
<xsl:template match="//job_info/job_info">
  &newline;
  <div id="pendingJobTable">
    <table class="listing">
    <tr>
      <th>jobId</th>
      <th>owner</th>
      <th>name</th>
      <th>slots</th>
      <th>tasks</th>
      <th>queue</th>
      <th><acronym title="submissionTime">priority</acronym></th>
      <th>state</th>
    </tr>
    <xsl:for-each select="job_list[@state='pending']">
      <!-- sorted by priority and job number -->
      <xsl:sort select="JAT_prio" order="descending"/>
      <xsl:sort select="JB_job_number"/>
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    </table>
  </div>
  &newline;
</xsl:template>

<!--
  pending jobs: content
 -->
<xsl:template match="job_list[@state='pending']">
<!-- per user sort -->
<xsl:if test="not(string-length($filterByUser)) or JB_owner=$filterByUser">

  <tr>
  <!-- jobId with resource requests -->
  <!-- link jobId to details: "jobinfo?{jobId}" -->
  <td>
    <xsl:element name="a">
      <xsl:attribute name="title">
        <xsl:for-each select="hard_request">
          <xsl:value-of select="@name"/>=<xsl:value-of select="."/>
          &space;
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="href">jobinfo?<xsl:value-of select="JB_job_number"/></xsl:attribute>
      <xsl:value-of select="JB_job_number" />
    </xsl:element>
  </td>
  <!-- owner -->
  <td>
    <!-- link owner names to "jobs?user={owner}" -->
    <xsl:element name="a">
      <xsl:attribute name="title">view jobs owned by <xsl:value-of select="JB_owner"/></xsl:attribute>
      <xsl:attribute name="href">jobs?user=<xsl:value-of select="JB_owner"/></xsl:attribute>
      <xsl:value-of select="JB_owner" />
    </xsl:element>
  </td>
  <!-- name and full name -->
  <td>
    <xsl:call-template name="shortName">
      <xsl:with-param name="name" select="full_job_name"/>
    </xsl:call-template>
  </td>
  <!-- slots -->
  <td>
    <xsl:value-of select="slots" />
  </td>
  <!-- task -->
  <td>
    <xsl:value-of select="tasks" />
  </td>
  <!-- queue -->
  <td>
    <xsl:for-each select="hard_req_queue">
      <xsl:call-template name="unqualifiedQueue">
        <xsl:with-param name="queue" select="."/>
      </xsl:call-template>
      &space;
    </xsl:for-each>
  </td>
  <!-- priority with submissionTime-->
  <td>
    <xsl:element name="acronym">
      <xsl:attribute name="title">
        <xsl:value-of select="JB_submission_time"/>
      </xsl:attribute>
    <xsl:value-of select="JAT_prio" />
    </xsl:element>
  </td>
  <!-- state -->
  <td>
    <xsl:value-of select="state" />
  </td>
  </tr>
&newline;
</xsl:if>
</xsl:template>


<!--
  create links for viewlog with plots
-->
<xsl:template match="job_list" mode="viewlog">
<xsl:if test="count(hard_request)">
  &newline;
  <xsl:variable name="resources">
    <xsl:for-each
        select="hard_request"><xsl:value-of
        select="@name"/>,</xsl:for-each>
  </xsl:variable>
  <xsl:variable name="request">jobid=<xsl:value-of
        select="JB_job_number"/><xsl:if
        test="tasks">.<xsl:value-of
        select="tasks"/></xsl:if><xsl:text>&amp;</xsl:text>resources=<xsl:value-of
        select="$resources"/>
  </xsl:variable>

  <!-- url viewlog?jobid=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">viewlog</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlog"/>?<xsl:value-of
        select="$request"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img src="css/screen/icons/page_find.png" alt="[v]" border="0" />
  </xsl:element>

  <!-- url viewlog?action=plot&jobid=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">plotlog</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlog"/>?action=plot<xsl:text>&amp;</xsl:text><xsl:value-of
        select="$request"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img src="css/screen/icons/chart_curve.png" alt="[p]" border="0" />
  </xsl:element>

  <!-- url viewlog?action=plot&owner=...&resources={resources} -->
  <xsl:element name="a">
    <xsl:attribute name="title">plotlogs</xsl:attribute>
    <xsl:attribute name="href"><xsl:value-of
        select="$viewlog"/>?action=plot<xsl:text>&amp;</xsl:text>owner=<xsl:value-of
        select="JB_owner"/><xsl:text>&amp;</xsl:text>resources=<xsl:value-of
        select="$resources"/><xsl:value-of select="$cgiParams"/></xsl:attribute>
    <img src="css/screen/icons/chart_curve_add.png" alt="[P]" border="0" />
  </xsl:element>
</xsl:if>
</xsl:template>


</xsl:stylesheet>

<!-- =========================== End of File ============================== -->
