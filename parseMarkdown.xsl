<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fct="factotum"
  xmlns:mk="markdown"
  exclude-result-prefixes="xs"
  expand-text="yes"
  version="3.1">
<!--
  parseMarkdown
  @author emchateau
  @since 2020-04-13
 
  factoton
  
  @use template param -i {http://www.w3.org/1999/XSL/Transform}initial-template
  
  @target : Instead of converting Markdown directly to any format, factoton parses Markdown to an AST (abstract syntax tree) before rendering it. This common AST can then be transformed to HTML, XML-TEI or any format, allowing manipulation before rendering. Ultimately, we would like to achieve a full implementation of Commonmark with testing. We target the following formats : HTML5, jTEI-article, TEI-SimplePrint., DITA, DocBook, JATS, odt and docx. The software will take advantage of the new packaging feature of XSLT3.
  
  Why a new implementation? While one of the application areas of XSLT is structured document processing, there is no standard implementation of CommonMark in this language. Particularly interested in the production of XML documents, factoton supports, among other things, the hierarchical structuring of documents.
  
  Supported Markdown specifications
  | Flavor | Version |
  | [The original markdown.pl](https://daringfireball.net/projects/markdown/) | ? |
  | [CommonMark](https://commonmark.org/) | ? |
  | [GitHub Flavored Markdown](https://github.github.com/gfm/) | ? |
  Pour une liste des syntaxes voir aussi https://github.com/commonmark/commonmark-spec/wiki/Markdown-Flavors
  
  @see https://github.com/TEIC/Stylesheets
  @todo create all defined variable in Commonmark
  @todo deal with Leaf blocks 
-->
  <xsl:output indent="yes" method="html" encoding="UTF-8" />
  <xsl:strip-space elements="*" />
  
  <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string"/>
  <xsl:param name="sourceFormat" select="'markdown'" as="xs:string"/>
  <xsl:param name="input-uri" select="'./README.md'"/> 
  <xsl:variable name="content" select="unparsed-text($input-uri, $input-encoding)"/>
  <xsl:variable name="parsedContent" select="fct:parseMarkdown($content)"/>
  <!-- 
  <xsl:choose>
          <xsl:when test="count($input-uri) = 1">
            <xsl:variable name="content" select="unparsed-text($input-uri, $input-encoding)"/>
            <xsl:sequence select="fct:parseMarkdown($content)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="for $i in $input-uri return $i">
              <xsl:variable name="content" select="unparsed-text(., $input-encoding)"/>
              <section>
                <xsl:sequence select="fct:parseMarkdown($content)"/>
              </section>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
  -->
  
  <xsl:template name="xsl:initial-template">
    <html lang="fr" dir="ltr">
      <head>
        <title>{$parsedContent[mk:atxHeading]}</title>
      </head>
      <body>
        <xsl:apply-templates select="$parsedContent"/>
      </body>
    </html>
  </xsl:template>
  
  <!-- blocks container -->
  <xsl:template match="mk:atxHeading">
    <head><xsl:apply-templates/></head>
  </xsl:template>
  <xsl:template match="mk:blockQuote">
    <blockquote><xsl:apply-templates/></blockquote>
  </xsl:template>
  <xsl:template match="mk:paragraph">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  <xsl:template match="mk:listItem">
    <li><xsl:apply-templates/></li>
  </xsl:template>
  <!-- inlines -->
  <xsl:template match="codeSpan">
    <code><xsl:apply-templates/></code>
  </xsl:template>
  <xsl:template match="emphasis">
    <em><xsl:apply-templates/></em>
  </xsl:template>
  <xsl:template match="strong">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>
  <xsl:template match="link">
    <a><xsl:apply-templates/></a>
  </xsl:template>
  <xsl:template match="delete">
    <del><xsl:apply-templates/></del>
  </xsl:template>


  <xsl:function name="fct:parseMarkdown" as="element()*">
    <xsl:param name="content" as="xs:string*"/>
    <mk:document>
      <xsl:for-each select="tokenize($content, '\n')">
        <xsl:sequence select="fct:parseLine(.)"/>
      </xsl:for-each>
    </mk:document>
  </xsl:function>
  
  <xsl:function name="fct:parseLine" as="element()*">
    <xsl:param name="line" as="xs:string*"/>
    <xsl:variable name="normalizedLine" select="normalize-space($line)"/>
    <xsl:variable name="blockOpenners" select="(
      '.',
      '^&lt;(?:script|pre|style)(?:\s|&gt;|$)',
      '^&lt;!--',
      '^&lt;[?]',
      '^&lt;![A-Z]',
      '^&lt;!\[CDATA\[',
      '^&lt;[/]?(?:address|article|aside|base|basefont|blockquote|body|caption|center|col|colgroup|dd|details|dialog|dir|div|dl|dt|fieldset|figcaption|figure|footer|form|frame|frameset|h[123456]|head|header|hr|html|iframe|legend|li|link|main|menu|menuitem|nav|noframes|ol|optgroup|option|p|param|section|source|summary|table|tbody|td|tfoot|th|thead|title|tr|track|ul)(?:\s|[/]?[&gt;]|$)'
      )"/>
    <!--  new RegExp("^(?:" + OPENTAG + "|" + CLOSETAG + ")\\s*$", "i") -->
    <!-- 2 et 7, option i -->
    <xsl:variable name="blockClosers" select="(
      '.',
      '&lt;\/(?:script|pre|style)>',
      '--&gt;',
      '\?&gt;',
      '&gt;',
      '\]\]&gt;'
      )"/>
    
    <xsl:choose>
      <xsl:when test="string-length($normalizedLine)=0"/>
      <xsl:when test="starts-with($line, '    ')">
        <xsl:analyze-string select="$line" regex="^(    )+(.*)$">
          <xsl:matching-substring>
            <mk:blockQuote level="{string-length(regex-group(1))}">
              <xsl:sequence select="fct:parseString(regex-group(2))"/>
            </mk:blockQuote>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="starts-with($normalizedLine, '```')">
        <!-- fenced code block (in some flavors delimited with ~~~ instead) -->
        <mk:FCODE/>
      </xsl:when>
      <xsl:when test="starts-with($normalizedLine, '#')">
        <xsl:analyze-string select="$normalizedLine" regex="^(#+) ?(.*)(#*)$">
          <xsl:matching-substring>
            <mk:atxHeading level="{string-length(regex-group(1))}">
              <xsl:sequence select="fct:parseString(regex-group(2))"/>
            </mk:atxHeading>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:sequence select="fct:parseString(.)"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="starts-with($normalizedLine, '- ') or starts-with($normalizedLine, '* ')">
        <mk:listItem type="unordered" n="item">
          <xsl:sequence select="fct:parseString(substring($normalizedLine, 3))"/>
        </mk:listItem>
      </xsl:when>
      <xsl:when test="matches($normalizedLine,'^[0-9]\. ')">
        <mk:listItem type="ordered" n="item">
          <xsl:sequence select="fct:parseString(normalize-space(substring-after($normalizedLine, '. ')))"/>
        </mk:listItem>
      </xsl:when>
      <xsl:when test="matches($normalizedLine,'^>')">
        <mk:blockQuote n="item">
          <xsl:sequence select="fct:parseString(substring($normalizedLine, 2))"/>
        </mk:blockQuote>
      </xsl:when>
      <xsl:otherwise>
        <mk:paragraph>
          <xsl:sequence select="fct:parseString($normalizedLine)"/>
        </mk:paragraph>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="fct:parseString" as="node()*">
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
                <mk:strong>
                  <xsl:sequence select="fct:parseString(regex-group(2))"/>
                </mk:strong>
              </xsl:when>
              <xsl:otherwise>
                <mk:emphasis>
                  <xsl:sequence select="fct:parseString(regex-group(2))"/>
                </mk:emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="regex-group(3)">
            <xsl:choose>
              <xsl:when test="substring(regex-group(3), 1, 2)='**'">
                <mk:strong>
                  <xsl:sequence select="fct:parseString(regex-group(4))"/>
                </mk:strong>
              </xsl:when>
              <xsl:otherwise>
                <mk:emphasis>
                  <xsl:sequence select="fct:parseString(regex-group(4))"/>
                </mk:emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="regex-group(5)">
            <mk:link href="{regex-group(7)}">
              <xsl:sequence select="regex-group(6)"/>
            </mk:link>
          </xsl:when>
          <xsl:when test="regex-group(8)">
            <mk:codeSpan>
              <xsl:sequence select="regex-group(9)"/>
            </mk:codeSpan>
          </xsl:when>
          <xsl:when test="regex-group(10)">
            <mk:delete>
              <xsl:sequence select="regex-group(11)"/>
            </mk:delete>
          </xsl:when>
          <xsl:when test="regex-group(12)">
            <mk:link href="{regex-group(12)}">
              <xsl:sequence select="regex-group(12)"/>
            </mk:link>
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