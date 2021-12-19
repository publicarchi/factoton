<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fct="factotum"
  xmlns:yaml="yaml"
  exclude-result-prefixes="xs"
  expand-text="yes"
  version="3.1">
<!--
  This transformation is part of Factoton
  Factoton is a multiformat document transformation library
  
  parseYaml
  @author emchateau
  @since 2020-06-12
  @licence GNU GPL
  
  @use template param -i {http://www.w3.org/1999/XSL/Transform}initial-template
  @see https://yaml.org/xml
  @see https://nodeca.github.io/js-yaml/
  @see https://github.com/eemeli/yaml
-->
  <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string"/>
  <xsl:param name="sourceFormat" select="'markdown'" as="xs:string"/>
  <xsl:param name="input-uri" select="'./README.md'"/> 
  <xsl:variable name="content" select="unparsed-text($input-uri, $input-encoding)"/>
  <xsl:variable name="parsedContent" select="fct:parseYaml($content)"/>
  
  <xsl:output indent="yes" method="xml" encoding="UTF-8" />
  <xsl:strip-space elements="*" />
  
  <xsl:template name="xsl:initial-template">
    {$parsedContent}
  </xsl:template>
  
  <xsl:function name="fct:parseYaml" as="item()*">
    <xsl:param name="sourceFormat" as="xs:string"/>
    <xsl:sequence/>
  </xsl:function>
  
</xsl:stylesheet>