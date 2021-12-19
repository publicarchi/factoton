<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:csl="http://purl.org/net/xbiblio/csl"
  xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="xs"
  version="2.0">
  <!--  This stylesheet transforms TEI BiblStruct to a Chicago bibliography 17th french ref -->
  
  <xsl:output method="xhtml" html-version="5.0" include-content-type="no" omit-xml-declaration="yes" exclude-result-prefixes="#all" encoding="UTF-8" indent="yes" />
  <xsl:strip-space elements="*" />
  <xdoc:doc type="stylesheet">
    <xdoc:short>Main CiteProc stylesheet.</xdoc:short>
    <xdoc:author>Bruce D’Arcus</xdoc:author>
    <xdoc:copyright>2006, Bruce D’Arcus</xdoc:copyright>
  </xdoc:doc>
  <xdoc:doc>Sort order for bibliography.<xdoc:param type="string"/>
  </xdoc:doc>
  <xsl:variable name="csl" select="'chicago-author-dateFr.csl'" />
  <xsl:variable name="lang" select="'fr'" />
  
  <xsl:variable name="terms" select="doc($csl)/csl:style/csl:locale[@xml:lang=$lang]/csl:terms/csl:term"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="TEI/text/body//biblStruct"/>
  </xsl:template>
  
  <xsl:template match="biblStruct">
    <xsl:choose>
      <xsl:when test="analytic and monogr/title[@level='j']">
        <xsl:call-template name="journalArticle"/>
      </xsl:when>
      <xsl:when test="analytic and monogr/title[@level='m'] and monogr/meeting">
        <xsl:call-template name="conferenceArticle"/>
      </xsl:when>
      <xsl:when test="analytic and monogr/title[@level='m']">
        <xsl:call-template name="bookChapter"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="book"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="journalArticle">@todo article</xsl:template>
  <xsl:template name="conferenceArticle">@todo conference</xsl:template>
  <xsl:template name="bookChapter">@todo chapter</xsl:template>
  <xsl:template name="book">
    
  </xsl:template>
  
</xsl:stylesheet>