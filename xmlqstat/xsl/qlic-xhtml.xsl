<xsl:stylesheet version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
<!--
   | process XML generated by the qlicserver
   | to produce an overview of resource usage
   | The menuMode only affects the top menu
-->

<!-- ============================= Imports ================================ -->
<!-- Import our masthead and templates -->
<xsl:import href="xmlqstat-masthead.xsl"/>
<xsl:import href="xmlqstat-templates.xsl"/>


<!-- ======================== Passed Parameters =========================== -->
<xsl:param name="timestamp"/>
<xsl:param name="menuMode"/>


<!-- ======================= Internal Parameters ========================== -->
<!-- NONE -->


<!-- ======================= Output Declaration =========================== -->
<xsl:output method="xhtml" indent="yes" version="1.0" encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
/>


<!-- ============================ Matching ================================ -->
<xsl:template match="/" >
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta http-equiv="Refresh" content="30" />

  <link rel="icon" type="image/png" href="images/icons/silk/database_key.png"/>
  <title> resources
    <xsl:if test="//query/cluster/@name">
    - <xsl:value-of select="//query/cluster/@name"/>
    </xsl:if>
  </title>
  <!-- import CSS from a file -->
  <link href="css/xmlqstat.css" media="screen" rel="Stylesheet" type="text/css" />
</head>
<xsl:text>
</xsl:text>

<!-- CALCULATIONS -->

<!-- done CALCULATIONS -->

<!-- begin body -->
<body>
<xsl:text>
</xsl:text>
<xsl:comment> Main body content </xsl:comment>
<xsl:text>
</xsl:text>

<div id="main">
<!-- Topomost Logo Div and Top Menu Bar -->
<xsl:call-template name="topLogo"/>
<xsl:choose>
<xsl:when test="$menuMode='xmlqstat'">
  <xsl:call-template name="xmlqstatMenu"/>
</xsl:when>
<xsl:otherwise>
  <xsl:call-template name="topMenu"/>
</xsl:otherwise>
</xsl:choose>

<xsl:text>
</xsl:text>
<xsl:comment> Top dotted line bar (holds the qmaster host and update time) </xsl:comment>
<div class="dividerBarBelow">
<xsl:choose>
<xsl:when test="//query/cluster and //query/host">
  <!-- query host, cluster/cell name -->
  <xsl:value-of
      select="//query/host"
      />@<xsl:value-of
      select="//query/cluster/@name"
      />/<xsl:value-of
      select="//query/cluster/@cell"/>
  <xsl:text> </xsl:text>
  <!-- replace 'T' in dateTime for easier reading -->
  [<xsl:value-of select="translate(//query/time, 'T', '_')"/>]
</xsl:when>
<xsl:otherwise>
  <!-- unnamed cluster: -->
  unnamed cluster
</xsl:otherwise>
</xsl:choose>
</div>

<xsl:text>
</xsl:text>
<xsl:comment> Resources </xsl:comment>
<xsl:text>
</xsl:text>

<!-- resources: -->
<blockquote>
<table class="listing">
  <tr valign="middle">
    <td>
      <div class="tableCaption">Resources</div>
    </td>
  </tr>
</table>
<xsl:apply-templates select="//qlicserver/resources" />
</blockquote>

<!-- bottom status bar with rendered time -->
<xsl:call-template name="bottomStatusBar">
  <xsl:with-param name="timestamp" select="$timestamp" />
</xsl:call-template>

<xsl:text>
</xsl:text>
</div>
</body></html>
<!-- end body/html -->
</xsl:template>


<!--
  resources: header
-->
<xsl:template match="qlicserver/resources">
<div id="resourcesTable">
  <table class="listing">
  <tr>
    <th/>
    <th>used</th>
    <th>total</th>
    <th>limit</th>
    <th>extern</th>
    <th>intern</th>
    <th>wait</th>
    <th>free</th>
  </tr>
  <xsl:apply-templates select="resource"/>
  </table>
</div>
</xsl:template>


<!--
  resources: content
-->
<xsl:template match="resources/resource">
  <tr align="right">
  <!-- annotate with 'served', 'from' and 'note' attributes -->
  <xsl:variable name="annotation">
    <xsl:if test="@served">served = <xsl:value-of select="@served"/>
      <xsl:if test="@from"> [<xsl:value-of select="@from"/>]</xsl:if>
    </xsl:if>
    <xsl:if test="@note"> (<xsl:value-of select="@note"/>)</xsl:if>
  </xsl:variable>

  <td align="left">
    <xsl:choose>
    <xsl:when test="@served">
      <xsl:element name="acronym">
        <xsl:attribute name="title"><xsl:value-of select="$annotation"/></xsl:attribute>
        <xsl:value-of select="@name" />
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@name" />
    </xsl:otherwise>
    </xsl:choose>
  </td>

  <xsl:variable name="valueUsed">
    <xsl:choose>
    <xsl:when test="@extern and @intern">
      <xsl:value-of select="@extern + @intern"/>
    </xsl:when>
    <xsl:when test="@extern">
      <xsl:value-of select="@extern"/>
    </xsl:when>
    <xsl:when test="@intern">
      <xsl:value-of select="@intern"/>
    </xsl:when>
    <xsl:otherwise>
      0
    </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="valueTotal" select="@total"/>

  <!-- used -->
  <td width="100px" align="left">
    <xsl:choose>
    <xsl:when test="$valueUsed &gt; 0 and ($valueUsed &gt;= $valueTotal)">
      <xsl:call-template name="progressBar">
        <xsl:with-param name="label"   select="concat($valueUsed, '/', $valueTotal)" />
        <xsl:with-param name="percent" select="100"/>
        <xsl:with-param name="class"   select="'warnBar'"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$valueUsed &gt; 0">
      <xsl:call-template name="progressBar">
        <xsl:with-param name="label"   select="concat($valueUsed, '/', $valueTotal)" />
        <xsl:with-param name="percent" select="($valueUsed div $valueTotal)*100"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
    </xsl:choose>
  </td>

  <!-- total: display as alarm if none found -->
  <xsl:choose>
  <xsl:when test="@total &gt; 0">
    <td><xsl:value-of select="@total"/></td>
  </xsl:when>
  <xsl:otherwise>
    <!-- alarm color -->
    <td class="alarmState">0</td>
  </xsl:otherwise>
  </xsl:choose>

  <!-- limit -->
  <td>
    <xsl:value-of select="@limit" />
  </td>

  <!-- extern: display users -->
  <xsl:choose>
  <xsl:when test="@extern">
    <td>
      <xsl:element name="acronym">
        <xsl:attribute name="title">
          <xsl:for-each select="user[@type = 'extern']">
            <xsl:value-of select="@name"/>@<xsl:value-of select="@host"/>=<xsl:value-of select="."/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:attribute>
        <xsl:value-of select="@extern" />
      </xsl:element>
    </td>
  </xsl:when>
  <xsl:when test="@type = 'intern'">
    <!-- empty color -->
    <td bgcolor="#dee7ec"/>
  </xsl:when>
  <xsl:otherwise>
    <td/>
  </xsl:otherwise>
  </xsl:choose>
  <!-- intern: display users -->
  <xsl:choose>
  <xsl:when test="@intern">
    <td>
      <xsl:element name="acronym">
        <xsl:attribute name="title">
          <xsl:for-each select="user[@type = 'intern']">
            <xsl:value-of select="@name"/>@<xsl:value-of select="@host"/>=<xsl:value-of select="."/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:attribute>
        <xsl:value-of select="@intern" />
      </xsl:element>
    </td>
  </xsl:when>
  <xsl:when test="@type = 'track'">
    <!-- empty color -->
    <td bgcolor="#dee7ec"/>
  </xsl:when>
  <xsl:otherwise>
    <td/>
  </xsl:otherwise>
  </xsl:choose>
  <!-- waiting: display users -->
  <td>
    <xsl:element name="acronym">
      <xsl:attribute name="title">
        <xsl:for-each select="user[@type = 'waiting']">
          <xsl:value-of select="@name"/>=<xsl:value-of select="."/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:value-of select="@waiting" />
    </xsl:element>
  </td>
  <xsl:choose>
  <!-- free: display warn/alarm when exhausted -->
  <xsl:when test="@free">
    <td>
    <xsl:value-of select="@free"/>
    </td>
  </xsl:when>
  <xsl:when test="@type = 'track'">
    <!-- pale warn color -->
    <td class="warnState">0</td>
  </xsl:when>
  <xsl:when test="@waiting">
    <!-- alarm color -->
    <td class="alarmState">0</td>
  </xsl:when>
  <xsl:otherwise>
    <!-- warn color -->
    <td class="warnState">0</td>
  </xsl:otherwise>
  </xsl:choose>

  </tr>
<xsl:text>
</xsl:text>
</xsl:template>


</xsl:stylesheet>
