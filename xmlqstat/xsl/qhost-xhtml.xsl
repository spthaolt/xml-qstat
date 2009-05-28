<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dt="http://xsltsl.org/date-time"
    xmlns:str="http://xsltsl.org/string"
    exclude-result-prefixes="dt str"
>
<!--
   | process XML generated by
   |     "qhost -xml -j -q"
   | to produce
   |   1) a detailed list of the queue instances (the default)
   |   2) a queue summary (renderMode = summary)
   |   3) a list of queues that have warnings (renderMode = warn)
-->

<!-- output declarations -->
<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
/>

<!-- Import the XSLTL library method -->
<xsl:include href="xsltl/stdlib.xsl"/>

<!-- Import our uniform masthead -->
<xsl:include href="xmlqstat-masthead.xsl"/>

<!-- Import our templates -->
<xsl:include href="xmlqstat-templates.xsl"/>

<!-- XSL Parameters -->
<xsl:param name="timestamp"/>
<xsl:param name="renderMode"/>

<!-- define sorting keys -->
<xsl:key
    name="queue-summary"
    match="//host/queue"
    use="@name"
/>
<xsl:key
    name="job-summary"
    match="//host/job"
    use="@name"
/>


<xsl:template match="/" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Refresh" content="30" />

<xsl:choose>
<xsl:when test="$renderMode='summary'">
  <link rel="icon" type="image/png" href="images/icons/silk/chart_bar.png"/>
  <title> queue summary
    <xsl:if test="//config/cluster/@name">
    - <xsl:value-of select="//config/cluster/@name"/>
    </xsl:if>
  </title>
</xsl:when>
<xsl:when test="$renderMode='warn'">
  <link rel="icon" type="image/png" href="images/icons/silk/chart_bar_error.png"/>
  <title> queue warnings
    <xsl:if test="//config/cluster/@name">
    - <xsl:value-of select="//config/cluster/@name"/>
    </xsl:if>
  </title>
</xsl:when>
<xsl:otherwise>
  <link rel="icon" type="image/png" href="images/icons/silk/chart_bar_add.png"/>
  <title> queue instances
    <xsl:if test="//config/cluster/@name">
    - <xsl:value-of select="//config/cluster/@name"/>
    </xsl:if>
  </title>
</xsl:otherwise>
</xsl:choose>

<xsl:text>
</xsl:text>
<xsl:comment> Load CSS from a file </xsl:comment>
<xsl:text>
</xsl:text>
<link href="css/xmlqstat.css" media="screen" rel="Stylesheet" type="text/css" />
<xsl:text>
</xsl:text>
</head>
<xsl:text>
</xsl:text>

<!-- CALCULATE TOTALS -->

<!-- count active jobs -->
<xsl:variable name="AJ_total">
  <xsl:call-template name="count-jobs">
    <xsl:with-param name="nodeList" select="//qhost/host/job"/>
  </xsl:call-template>
</xsl:variable>

<!-- done CALCULATE -->

<body>
<xsl:text>
</xsl:text>
<xsl:comment> Main body content </xsl:comment>
<xsl:text>
</xsl:text>

<div id="main">
<!-- Topomost Logo Div -->
<xsl:call-template name="topLogo"/>
<xsl:text>
</xsl:text>
<!-- Top Menu Bar -->
<xsl:choose>
<xsl:when test="$renderMode='summary'">
  <!-- show 'more' toggle for queue instances -->
  <xsl:call-template name="topMenu">
    <xsl:with-param name="queueinfo" select="'more'"/>
  </xsl:call-template>
</xsl:when>
<xsl:when test="$renderMode='warn'">
  <!-- show 'more' toggle for hosts -->
  <xsl:call-template name="topMenu">
    <xsl:with-param name="hostinfo" select="'more'"/>
  </xsl:call-template>
</xsl:when>
<xsl:otherwise>
  <xsl:call-template name="topMenu">
  </xsl:call-template>
</xsl:otherwise>
</xsl:choose>
<xsl:text>
</xsl:text>

<xsl:comment> Top dotted line bar (holds the cluster/qmaster names and update time) </xsl:comment>
<div class="dividerBarBelow">
<xsl:choose>
<xsl:when test="//config/cluster">
  <!-- query host, cluster/cell name -->
  <xsl:value-of select="//config/cluster/@name"/>
  <xsl:if test="//config/cluster/@cell != 'default'">/<xsl:value-of
      select="//config/cluster/@cell"/>
  </xsl:if>
  <xsl:if test="//query/host">@<xsl:value-of select="//query/host"/>
  <xsl:text> </xsl:text>
  <!-- replace 'T' in dateTime for easier reading -->
  [<xsl:value-of select="translate(//query/time, 'T', '_')"/>]
  </xsl:if>
</xsl:when>
<xsl:otherwise>
  <!-- unnamed cluster: -->
  unnamed cluster
</xsl:otherwise>
</xsl:choose>
<br/>
<xsl:choose>
<xsl:when test="$AJ_total &gt; 0">
  <!-- active jobs: -->
  <xsl:value-of select="$AJ_total"/> active jobs
  (<xsl:value-of select="sum(//queuevalue[@name='slots_used'])"/> slots)
</xsl:when>
<xsl:otherwise>
  <!-- no active jobs -->
  no active jobs
</xsl:otherwise>
</xsl:choose>
</div>

<xsl:text>
</xsl:text>
<xsl:comment> Host or Queue Instance Information </xsl:comment>
<xsl:text>
</xsl:text>

<xsl:choose>
<xsl:when test="$renderMode='summary'">
  <!-- summary: -->
  <blockquote>
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Summary</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost" mode="summary"/>
  </blockquote>
</xsl:when>
<xsl:when test="$renderMode='warn'">
  <!-- warnings: -->
  <blockquote>
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Warnings</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost"/>
  </blockquote>
</xsl:when>
<xsl:otherwise>
  <!-- queue/host information: -->
  <blockquote>
  <table class="listing">
    <tr valign="middle">
      <td>
        <div class="tableCaption">Queue Information</div>
      </td>
    </tr>
  </table>
  <xsl:apply-templates select="//qhost"/>
  </blockquote>
</xsl:otherwise>
</xsl:choose>

<!-- bottom status bar with rendered time -->
<xsl:call-template name="bottomStatusBar">
  <xsl:with-param name="timestamp" select="$timestamp" />
</xsl:call-template>

<xsl:text>
</xsl:text>
</div>
</body></html>
</xsl:template>


<!--
  cluster summary: header and content
-->
<xsl:template match="//qhost" mode="summary">
<!-- summary: header -->
<table class="listing">
  <tr>
  <th/>
  <th>total</th>
  <th>used</th>
  <th>
    <span style="cursor:help;">
      <xsl:element name="acronym">
        <xsl:attribute name="title">a(larm) C(alendar) S(ubordinate)</xsl:attribute>
        <xsl:value-of select="'warnings'" />
      </xsl:element>
    </span>
  </th>
  <th>
    <span style="cursor:help;">
      <xsl:element name="acronym">
        <xsl:attribute name="title">d(isabled) s(uspended) u(nknown) E(rror)</xsl:attribute>
        <xsl:value-of select="'errors'" />
      </xsl:element>
    </span>
  </th>
  <th>free</th>
  </tr>

  <!-- summary: content -->
  <xsl:for-each select="host/queue">
    <xsl:sort select="@name"/>

    <xsl:variable name="qname" select="@name"/>
    <xsl:variable name="thisNode" select="generate-id(.)"/>
    <xsl:variable name="allNodes" select="key('queue-summary', $qname)"/>
    <xsl:variable name="firstNode" select="generate-id($allNodes[1])"/>

    <xsl:if test="$thisNode = $firstNode">
      <xsl:variable
          name="slotsUsed"
          select="sum($allNodes/queuevalue[@name='slots_used'])"
      />

      <xsl:variable
          name="slotsTotal"
          select="sum($allNodes/queuevalue[@name='slots'])"
      />

      <xsl:variable
          name="slotsDisabled"
          select="sum($allNodes/queuevalue[@name='slots_used'])"
      />

      <!-- select all queue instances with an unusual state -->
      <xsl:variable
          name="stateNodes"
          select="$allNodes/queuevalue[@name='state_string'][. != '']"
      />

  <!-- possible queue states:
       u(nknown), a(larm), A(larm), C(alendar suspended), s(uspended),
       S(ubordinate), d(isabled), D(isabled), E(rror)
  -->

      <!-- select unknown separately -->
      <xsl:variable
          name="nodeSet_unknown"
          select="$stateNodes[contains(., 'u')]"
      />

      <xsl:variable
          name="nodeSet_known"
          select="$stateNodes[not(contains(., 'u'))]"
      />

      <!-- discount these queue instances -->
      <xsl:variable
          name="slotsProblem"
          select="sum($stateNodes/../queuevalue[@name='slots']) -
                  sum($stateNodes/../queuevalue[@name='slots_used'])"
      />

      <!-- group cdsuE -->
      <xsl:variable name="group_cdsuE">
        <xsl:variable
            name="subset"
            select="$stateNodes[
                contains(., 'c')
             or contains(., 'd')
             or contains(., 's')
             or contains(., 'u')
             or contains(., 'E')
             ]"
        />
        <xsl:value-of
          select="sum($subset/../queuevalue[@name='slots']) -
                  sum($subset/../queuevalue[@name='slots_used'])"
        />
      </xsl:variable>

      <!-- determine group aoACDS implicitly -->
      <xsl:variable
          name="group_aoACDS"
          select="$slotsProblem - $group_cdsuE"
      />

      <xsl:variable
          name="slotsAvailable"
          select="$slotsTotal - $slotsUsed - $slotsProblem"
      />

      <tr align="right">
        <!-- queue name -->
        <td align="left"><xsl:value-of select="@name"/></td>

        <!-- total: display as alarm if none found -->
        <xsl:choose>
        <xsl:when test="$slotsTotal">
          <td>
            <xsl:value-of select="$slotsTotal" />
          </td>
        </xsl:when>
        <xsl:otherwise>
          <!-- alarm color -->
          <td class="alarmState">0</td>
        </xsl:otherwise>
        </xsl:choose>

        <!-- used slots -->
        <xsl:variable name="valueUsed"    select="$slotsUsed"/>
        <xsl:variable name="valueTotal"   select="$slotsAvailable + $slotsUsed"/>
        <xsl:variable name="valuePercent">
          <xsl:choose>
          <xsl:when test="$valueTotal &gt; 0">
            <xsl:value-of select="($valueUsed div $valueTotal)*100"/>
          </xsl:when>
          <xsl:otherwise>
            0
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <td width="100px" align="left">
          <xsl:call-template name="progressBar">
            <xsl:with-param name="title"   select="total = $valueTotal" />
            <xsl:with-param name="label"   select="concat($valueUsed, '/', $valueTotal)" />
            <xsl:with-param name="percent" select="$valuePercent" />
          </xsl:call-template>
        </td>

        <!-- aoACDS errors (warnings) -->
        <xsl:variable name="valueUsed"    select="$group_aoACDS"/>
        <xsl:variable name="valueTotal"   select="$slotsTotal"/>
        <xsl:variable name="valuePercent">
          <xsl:choose>
          <xsl:when test="$valueTotal &gt; 0">
            <xsl:value-of select="($valueUsed div $valueTotal)*100"/>
          </xsl:when>
          <xsl:otherwise>
            0
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <td width="100px" align="left">
          <xsl:call-template name="progressBar">
            <xsl:with-param name="title"   select="''" />
            <xsl:with-param name="label"   select="$valueUsed" />
            <xsl:with-param name="percent" select="$valuePercent" />
            <xsl:with-param name="background" select="'#ffff7f'" />
          </xsl:call-template>
        </td>

        <!-- cdsuE errors -->
        <xsl:variable name="valueUsed"    select="$group_cdsuE"/>
        <xsl:variable name="valueTotal"   select="$slotsTotal"/>
        <xsl:variable name="valuePercent">
          <xsl:choose>
          <xsl:when test="$valueTotal &gt; 0">
            <xsl:value-of select="($valueUsed div $valueTotal)*100"/>
          </xsl:when>
          <xsl:otherwise>
            0
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <td width="100px" align="left">
          <xsl:call-template name="progressBar">
            <xsl:with-param name="title"   select="''" />
            <xsl:with-param name="label"   select="$valueUsed" />
            <xsl:with-param name="percent" select="$valuePercent" />
            <xsl:with-param name="background" select="'#ff7f7f'" />
          </xsl:call-template>
        </td>

        <!-- free: display warn/alarm when exhausted -->
        <xsl:choose>
        <xsl:when test="$slotsAvailable &gt; 0">
          <td><xsl:value-of select="$slotsAvailable"/></td>
        </xsl:when>
        <xsl:otherwise>
          <!-- warn color -->
          <td class="warnState">0</td>
        </xsl:otherwise>
        </xsl:choose>

      </tr>
<xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:for-each>

</table>
</xsl:template>


<!--
  queue/host information: header
-->
<xsl:template match="//qhost">
<div id="hostInfoTable">
  <table class="listing">
  <thead>
  <tr>
    <th/>
    <th>load</th>
    <th>queue information</th>
    <th>cpu</th>
    <th>jobs</th>
    <th>mem</th>
    <th>swap</th>
  </tr>
  </thead>
  <xsl:apply-templates select="host[@name != 'global']"/>
  </table>
</div>
</xsl:template>

<!--
  queue/host information: content
-->
<xsl:template match="qhost/host">
<xsl:if test="$renderMode!='warn'
    or queue/queuevalue[@name='state_string'][contains(., 'a')
    or contains(., 'd') or contains(., 'E')]
 "
>

  <tr align="right">
  <!-- overall background color based on queue(s) status -->
  <!--
  <xsl:apply-templates select="queue/queuevalue[@name='state_string']" />
  -->

  <!-- no queues configured -->
  <xsl:if test="count(queue) = 0" >
    <xsl:attribute name="style">
      font-style: italic;
    </xsl:attribute>
  </xsl:if>

  <!-- host -->
  <td align="left">
    <xsl:value-of select="substring-before(@name,'.')"/>
  </td>

  <!-- load (w/o dash for missing values) -->
  <td>
    <xsl:value-of select="translate(hostvalue[@name='load_avg'], '-', ' ')"/>
  </td>

  <!-- queue instance information -->
  <xsl:choose>
  <xsl:when test="count(queue)">
    <td>
      <table class="embedded">
      <xsl:for-each select="queue">
        <xsl:apply-templates select="." />
      </xsl:for-each>
      </table>
    </td>
  </xsl:when>
  <xsl:otherwise>
    <td/>
  </xsl:otherwise>
  </xsl:choose>

  <!-- ncpu (w/o dash for missing values) with arch -->
  <td>
    <span style="cursor:help;">
      <xsl:element name="acronym">
        <xsl:attribute name="title">
          arch = <xsl:value-of select="hostvalue[@name='arch_string']"/>
        </xsl:attribute>
        <xsl:value-of select="translate(hostvalue[@name='num_proc'], '-', ' ')"/>
      </xsl:element>
    </span>
  </td>

  <!-- jobs -->
  <td>
    <xsl:for-each select="job">
      <xsl:choose>
      <xsl:when test="jobvalue[@name='pe_master'] = 'SLAVE'">
        slave
      </xsl:when>
      <xsl:otherwise>
        master
      </xsl:otherwise>
      </xsl:choose>
      <xsl:element name="a">
        <xsl:attribute name="title">details for job <xsl:value-of select="@name"/></xsl:attribute>
        <xsl:attribute name="href">jobinfo?<xsl:value-of select="@name"/></xsl:attribute>
        <xsl:value-of select="@name"/>
      </xsl:element>
      <br/>
    </xsl:for-each>
  </td>

  <!-- mem -->
  <td width="100px" align="left">
    <xsl:call-template name="memoryCalculate">
      <xsl:with-param name="memUsed"  select="hostvalue[@name='mem_used']" />
      <xsl:with-param name="memTotal" select="hostvalue[@name='mem_total']" />
    </xsl:call-template>
  </td>

  <!-- swap -->
  <td width="100px" align="left">
    <xsl:call-template name="memoryCalculate">
      <xsl:with-param name="memUsed"  select="hostvalue[@name='swap_used']"/>
      <xsl:with-param name="memTotal" select="hostvalue[@name='swap_total']"/>
    </xsl:call-template>
  </td>

  </tr>
<xsl:text>
</xsl:text>
</xsl:if>
</xsl:template>


<!--
  process host queue information
-->
<xsl:template match="host/queue">
  <xsl:variable name="valueUsed"    select="queuevalue[@name='slots_used']"/>
  <xsl:variable name="valueTotal"   select="queuevalue[@name='slots']"/>
  <xsl:variable name="state"        select="queuevalue[@name='state_string']"/>

  <tr>
    <!-- 'S' suspend state : alter font-style -->
    <xsl:if test="contains($state, 'S')">
      <xsl:attribute name="style">
        font-style: italic;
      </xsl:attribute>
    </xsl:if>

    <!-- font style, background color based on queue(s) status -->
    <xsl:call-template name="queue-state-style">
      <xsl:with-param name="state" select="$state"/>
    </xsl:call-template>

    <!-- state icon and queue name -->
    <td align="left">
      <xsl:call-template name="queue-state-icon">
        <xsl:with-param name="state" select="$state"/>
      </xsl:call-template>

      <xsl:choose>
      <xsl:when test="string-length($state)">
        <span style="cursor:help;">
          <xsl:element name="acronym">
            <xsl:attribute name="title"><xsl:value-of select="$state"/></xsl:attribute>
            <xsl:value-of select="@name"/>
          </xsl:element>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@name"/>
      </xsl:otherwise>
      </xsl:choose>
    </td>

    <!-- queue type B(atch), I(nteractive), P(arallel) -->
    <td align="right">
      <span style="cursor:help;">
        <xsl:element name="acronym">
          <xsl:attribute name="title">B(atch), I(nteractive), P(arallel)</xsl:attribute>
          <xsl:value-of select="queuevalue[@name='qtype_string']"/>
        </xsl:element>
      </span>
    </td>

    <!-- slider showing slot usage -->
    <td width="100px" align="left">
      <xsl:if test="$valueUsed &gt; -1">
        <xsl:call-template name="progressBar">
          <xsl:with-param name="label" select="concat($valueUsed, '/', $valueTotal)" />
          <xsl:with-param name="percent" select="($valueUsed div $valueTotal)*100"/>
        </xsl:call-template>
      </xsl:if>
    </td>
  </tr>
</xsl:template>


<!--
   | count the number of jobs
   | use string-length as a cheap hack to summarize the values
   -->
<xsl:template name="count-jobs">
  <xsl:param name="nodeList"/>
  <xsl:variable name="count">
    <xsl:for-each select="$nodeList">
      <xsl:variable name="jobId" select="@name"/>
      <xsl:variable name="thisNode" select="generate-id(.)"/>
      <xsl:variable name="allNodes" select="key('job-summary', $jobId)"/>
      <xsl:variable name="firstNode" select="generate-id($allNodes[1])"/>
      <xsl:choose>
      <xsl:when test="$thisNode = $firstNode">1</xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="string-length($count)"/>
</xsl:template>

</xsl:stylesheet>
