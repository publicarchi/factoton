<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string"/>
  <xsl:param name="input-uri" select="/Users/emmanuelchateau/publicarchitectura/transx/README.md"/>
  <xsl:param name="sys" select="'sys'"/>
  <xsl:param name="enableLinks" select="true()"/>
  <xsl:param name="yamlCompatible" select="false()"/>
  <xsl:param name="usePadding" select="true()"/>
  <xsl:param name="extendObjects" select="false()"/>
  <xsl:param name="maxLevel" select="100"/>
  
  <xsl:output indent="no" method="text" encoding="UTF-8" />
  <xsl:strip-space elements="*" />
  
 
</xsl:stylesheet>