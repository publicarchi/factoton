<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="2.0">
  <!--
    md2html
    @author emchateau
    @since 2018-11-28
    
    @see https://github.com/TEIC/Stylesheets
    @see https://gist.github.com/ap/281631
    @see https://stackoverflow.com/questions/3549827/converting-simple-markdownstring-to-html-with-xslt
  -->
  <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string"/>
  <xsl:param name="input-uri" select="/Users/emmanuelchateau/publicarchitectura/hnu6052/plan-de-cours.md"/>
  
  <xsl:output indent="no" method="text" encoding="UTF-8" />
  <xsl:strip-space elements="*" />
  
  <xsl:template match="/">
    <xsl:call-template name="main"/>
  </xsl:template>
  
  <xsl:template name="main">
    <xsl:call-template name="gatherText"/>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" rend="jTEI">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title type="main"/>
            <author>
              <name>
                <forename>Emmanuel</forename> 
                <surname>Château-Dutier</surname>
              </name>
              <affiliation/>
              <email/>
            </author>
          </titleStmt>
          <publicationStmt>
            <publisher>Publicarchitectura</publisher>
            <date/>
            <availability>
              <licence target="https://creativecommons.org/licenses/by/4.0/">
                <p>For this publication a Creative Commons Attribution 4.0 International license has been granted by the author(s) who retain full copyright.</p>
              </licence> 
            </availability>
          </publicationStmt>
          <sourceDesc>
            <p>This file was converted from a Markdown document.</p>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <projectDesc>
            <p>Publicarchitectura</p>
          </projectDesc>
        </encodingDesc>
        <profileDesc>
          <langUsage>
            <language ident="fr">fr</language>
          </langUsage>
          <textClass>
            <keywords xml:lang="fr">
              <term/>
            </keywords>
          </textClass>
        </profileDesc>
        <revisionDesc>
          <change/>
        </revisionDesc>
      </teiHeader>
      <text>
        <front>
          <div type="abstract" xml:id="abstract"/>
        </front>
        <body>
        <xsl:choose>
          <xsl:when test="$input-uri = 1">
            <xsl:call-template name="gatherText"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="unparsed-text($input-uri, $input-encoding)">
              <section>
                <xsl:call-template name="gatherText"/>
              </section>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </body>
      </text>
    </TEI>
  </xsl:template>
  
  <!--<xsl:template name="getYaml">
    <xsl:for-each select="tokenize(., '\n')">
    <!-\- @todo -\->
    </xsl:for-each>
  </xsl:template>-->
  <xsl:template name="gatherText">
    <xsl:for-each select="tokenize(., '\n')">
      <xsl:sequence select="html:parseLine(.)"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="html:parseLine" as="element()*">
    <xsl:param name="vLine" as="xs:string*"/>
    
    <xsl:variable name="nLine" select="normalize-space($vLine)"/>
    <xsl:choose>
      <xsl:when test="string-length($nLine)=0"/>
      <xsl:when test="starts-with($vLine, '    ')">
        <xsl:analyze-string select="$vLine" regex="^(    )+(.*)$">
          <xsl:matching-substring>
            <BCODE level="{string-length(regex-group(1))}">
              <xsl:sequence select="html:parseString(regex-group(2))"/>
            </BCODE>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="starts-with($nLine, '```')">
        <!-- fenced code block (in some flavors delimited with ~~~ instead) -->
        <FCODE/>
      </xsl:when>
      <xsl:when test="starts-with($nLine, '#')">
        <xsl:analyze-string select="$nLine" regex="^(#+) ?(.*)(#*)$">
          <xsl:matching-substring>
            <HEAD level="{string-length(regex-group(1))}">
              <xsl:sequence select="html:parseString(regex-group(2))"/>
            </HEAD>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:sequence select="html:parseString(.)"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="starts-with($nLine, '- ') or starts-with($nLine, '* ')">
        <ITEM n="item">
          <xsl:sequence select="html:parseString(substring($nLine, 3))"/>
        </ITEM>
      </xsl:when>
      <xsl:when test="matches($nLine,'^[0-9]\. ')">
        <NITEM n="item">
          <xsl:sequence select="html:parseString(normalize-space(substring-after($nLine, '. ')))"/>
        </NITEM>
      </xsl:when>
      <xsl:when test="matches($nLine,'^>')">
        <BQUOTE n="item">
          <xsl:sequence select="html:parseString(substring($nLine, 2))"/>
        </BQUOTE>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:sequence select="html:parseString($nLine)"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="html:parseString" as="node()*">
    <xsl:param name="pS" as="xs:string"/>
    
    <!-- match
    bold/italic __bold__ _italic_
  | bold/italic **bold** *italic*
  | links with text description [description](link)
  | inline code `code`
  | deleted ~~del~~
  | inline links (not very happy about the regex) 
  -->
    <xsl:analyze-string select="$pS" flags="x" regex=
      '(__?(.*?)__?)
      |
      (\*\*?(.*?)\*\*?)
      |
      (\[(.*?)\]\((.*?)\))
      |
      (`(.*?)`)
      |
      (~~(.*?)~~)
      |
      (https?://(\w(\w|\d)*\.)*(aero|arpa|biz|com|coop|edu|info|int|gov|mil|museum|name|net|org|pro|localhost)/?((\w|\d|\.)+/?)*\??((\w|\d)*=(\w|\d)*)?(&amp;(\w|\d)*=(\w|\d)*)*)
      '>
      <xsl:matching-substring>
        <xsl:choose>
          <xsl:when test="regex-group(1)">
            <xsl:choose>
              <xsl:when test="substring(regex-group(1), 1, 2)='__'">
                <strong>
                  <xsl:sequence select="html:parseString(regex-group(2))"/>
                </strong>
              </xsl:when>
              <xsl:otherwise>
                <em>
                  <xsl:sequence select="html:parseString(regex-group(2))"/>
                </em>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="regex-group(3)">
            <xsl:choose>
              <xsl:when test="substring(regex-group(3), 1, 2)='**'">
                <strong>
                  <xsl:sequence select="html:parseString(regex-group(4))"/>
                </strong>
              </xsl:when>
              <xsl:otherwise>
                <em>
                  <xsl:sequence select="html:parseString(regex-group(4))"/>
                </em>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="regex-group(5)">
            <a href="{regex-group(7)}">
              <xsl:sequence select="regex-group(6)"/>
            </a>
          </xsl:when>
          <xsl:when test="regex-group(8)">
            <code>
              <xsl:sequence select="regex-group(9)"/>
            </code>
          </xsl:when>
          <xsl:when test="regex-group(10)">
            <del>
              <xsl:sequence select="regex-group(11)"/>
            </del>
          </xsl:when>
          <xsl:when test="regex-group(12)">
            <a href="{regex-group(12)}">
              <xsl:sequence select="regex-group(12)"/>
            </a>
          </xsl:when>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>
  
  
  <xsl:template match="node()|@*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>