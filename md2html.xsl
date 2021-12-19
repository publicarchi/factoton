<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="3.1">
<!--
  md2html
  @author emchateau
  @since 2018-07-28
  @chance 2020-04-10 passed to xslt3
  
  factoton
  
  @use template param -i {http://www.w3.org/1999/XSL/Transform}initial-template
  
  Supported Markdown specifications
  | Flavor | Version |
  | [The original markdown.pl](https://daringfireball.net/projects/markdown/) | ? |
  | [CommonMark](https://commonmark.org/) | ? |
  | [GitHub Flavored Markdown](https://github.github.com/gfm/) | ? |
  Pour une liste des syntaxes voir aussi https://github.com/commonmark/commonmark-spec/wiki/Markdown-Flavors
  
  @see TEIStyleseets 
            https://github.com/TEIC/Stylesheets
  @see HTML to Markdown in (E)XSLT 
            https://gist.github.com/ap/281631  
  @see Regex - Converting simple markdown(string) to html with xslt, 
            https://stackoverflow.com/questions/3549827/converting-simple-markdownstring-to-html-with-xslt
  @see Šmíd Martin, Markdown to DocBook Converter, s.l., 2020 [2014].
            https://github.com/msmid/markdown2docbook
  @see Vieiro Antonio, Xmark, s.l., 2021 [2016]. 
            https://github.com/vieiro/xmark
  @see The path from Markdown to DITA - DITAMark framework, s.l., oXygen XML Editor, 2018 [2016].
            https://github.com/oxygenxml/ditaMark
  @see Fenner Martin, From Markdown to JATS XML in one Step (12 décembre 2013)
            https://blog.front-matter.io/posts/from-markdown-to-jats-xml-in-one-step
  @see science rOpenSci-open tools for open, Tinkr: editing Markdown documents using XML tools | R-bloggers (1 octobre 2018) 
            https://www.r-bloggers.com/tinkr-editing-markdown-documents-using-xml-tools/
  @see Markdown and XML (3 décembre 2006)
            https://fletcherpenney.net/2006/03/markdown_and_xml
  @see JATS conversion 
            https://github.com/PeerJ/jats-conversion
  @see rOpensci 
            https://docs.ropensci.org/xslt/
  @see Markdown2docbook
            https://github.com/msmid/markdown2docbook/blob/master/src/htmlparse.xsl
  @see Zeux, Parsing-xml.markdown
            https://gist.github.com/zeux/5346409
  @see https://github.com/eXist-db/exist-markdown/blob/master/content/markdown.xql
  
  @see https://github.com/xqdoc/exist-xqdoc/blob/main/src/main/xquery/xqdoc2openapi-lib.xqm
  @see https://github.com/kermitt2/pdfalto
-->
  <xsl:output indent="yes" method="html" encoding="UTF-8" />
  <xsl:strip-space elements="*" />
  
  <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string"/>
  <xsl:param name="sourceFormat" select="'markdown'" as="xs:string"/>
  <xsl:param name="input-uri" select="'/Users/emmanuelchateau/publicarchi/website/md/cbc.md'"/> 
  
  <xsl:template name="xsl:initial-template">
    <html lang="fr" dir="ltr">
      <head>
        <title>te</title>
      </head>
      <body>
        <xsl:choose>
          <xsl:when test="count($input-uri) = 1">
            <xsl:call-template name="gatherText">
              <xsl:with-param name="content" select="unparsed-text($input-uri, $input-encoding)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- <xsl:for-each select="for $i in $input-uri return $i"> -->
            <xsl:for-each select="$input-uri">
              <section>
                <xsl:call-template name="gatherText">
                  <xsl:with-param name="content" select="unparsed-text(., $input-encoding)"/>
                </xsl:call-template>
              </section>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>
  
  
  <xsl:template name="gatherText">
    <xsl:param name="content" />
    <xsl:for-each select="tokenize($content, '\n')">
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
    <xsl:param name="parseString" as="xs:string"/>
    <!-- match
    bold/italic __bold__ _italic_
  | bold/italic **bold** *italic*
  | links with text description [description](link)
  | inline code `code`
  | deleted ~~del~~
  | inline links (not very happy about the regex) 
  -->
    <xsl:analyze-string select="$parseString" flags="x" regex=
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