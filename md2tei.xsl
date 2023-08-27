<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fct="factoton"
    xmlns:file="http://expath.org/ns/file" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" expand-text="yes"
    version="3.0">
    <!-- this xslt use an initial-template, saxon parameter -it with value '{http://www.w3.org/1999/XSL/Transform}initial-template' -->

    <xsl:param name="input-encoding" select="'UTF-8'" as="xs:string" />
    <xsl:param name="input-uri"
        select="'/Users/emmanuelchateau/publicarchi/hnu6052/plan-de-cours.md'" />
    <xsl:param name="dir" select="file:parent($input-uri)" />
    <xsl:param name="fileName" select="file:name($input-uri)" />
    <xsl:param name="content" select="unparsed-text($input-uri, $input-encoding)" />
    
    <xsl:variable name="result">
        <xsl:sequence select="fct:parse($content)"></xsl:sequence>
    </xsl:variable> 
   

    <xsl:output indent="yes" method="xml" encoding="UTF-8" omit-xml-declaration="yes" />
    <xsl:strip-space elements="*" />

    <xsl:mode on-no-match="shallow-copy" />

    <xsl:template name="xsl:initial-template">
        <xsl:result-document href="{$dir}/{$fileName}.xml" method="xml">
            <TEI xmlns="http://www.tei-c.org/ns/1.0" rend="jTEI">
                <teiHeader>
                    <fileDesc>
                        <titleStmt>
                            <title type="main" />
                            <author>
                                <name>
                                    <forename>Emmanuel</forename>
                                    <surname>Château-Dutier</surname>
                                </name>
                                <affiliation />
                                <email />
                            </author>
                        </titleStmt>
                        <publicationStmt>
                            <publisher>Publicarchitectura</publisher>
                            <date />
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
                                <term />
                            </keywords>
                        </textClass>
                    </profileDesc>
                    <revisionDesc>
                        <change />
                    </revisionDesc>
                </teiHeader>
                <text>
                    <body>
                        <div>
                            <xsl:copy-of select="$result"></xsl:copy-of>
                        </div>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>

    </xsl:template>

    <!--<xsl:template name="getYaml">
    <xsl:for-each select="tokenize(., '\n')">
    <!-\- @todo -\->
    </xsl:for-each>
  </xsl:template>-->
    
        
    <xsl:template match="ITEM">
        <itemB><xsl:apply-templates></xsl:apply-templates></itemB>
    </xsl:template>

    <xsl:template match="h1 | h2 | h3 | h4 | h5 | h6 | h7">
        <xsl:variable name="this" select="name()" />
        <xsl:variable name="next" select="translate($this, '12345678', '23456789')" />
        <div>
            <head>
                <xsl:value-of select="." />
            </head>
            <xsl:for-each-group select="current-group() except ."
                group-starting-with="*[name() = $next]">
                <xsl:apply-templates select="." mode="group" />
            </xsl:for-each-group>
        </div>
    </xsl:template>

    <xsl:function name="fct:parse" as="element()*">
        <xsl:param name="content" as="xs:string*" />
        <xsl:sequence select="unparsed-text-lines($input-uri) ! fct:parseLine(.)" />
    </xsl:function>

    <xsl:function name="fct:parseLine" as="element()*">
        <xsl:param name="vLine" as="xs:string*" />

        <xsl:variable name="nLine" select="normalize-space($vLine)" />
        <xsl:choose>
            <xsl:when test="string-length($nLine) = 0" />
            <xsl:when test="starts-with($vLine, '    ')">
                <xsl:analyze-string select="$vLine" regex="^(    )+(.*)$">
                    <xsl:matching-substring>
                        <BCODE level="{string-length(regex-group(1))}">
                            <xsl:sequence select="fct:parseString(regex-group(2))" />
                        </BCODE>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="starts-with($nLine, '---')">
                <META />
            </xsl:when>
            <xsl:when test="starts-with($nLine, '```')">
                <!-- fenced code block (in some flavors delimited with ~~~ instead) -->
                <FCODE />
            </xsl:when>
            <xsl:when test="starts-with($nLine, '#')">
                <xsl:analyze-string select="$nLine" regex="^(#+) ?(.*)(#*)$">
                    <xsl:matching-substring>
                        <HEAD level="{string-length(regex-group(1))}">
                            <xsl:sequence select="fct:parseString(regex-group(2))" />
                        </HEAD>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:sequence select="fct:parseString(.)" />
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="starts-with($nLine, '- ') or starts-with($nLine, '* ')">
                <ITEM n="item">
                    <xsl:sequence select="fct:parseString(substring($nLine, 3))" />
                </ITEM>
            </xsl:when>
            <xsl:when test="matches($nLine, '^[0-9]\. ')">
                <NITEM n="item">
                    <xsl:sequence
                        select="fct:parseString(normalize-space(substring-after($nLine, '. ')))" />
                </NITEM>
            </xsl:when>
            <xsl:when test="matches($nLine, '^>')">
                <BQUOTE n="item">
                    <xsl:sequence select="fct:parseString(substring($nLine, 2))" />
                </BQUOTE>
            </xsl:when>
            <xsl:otherwise>
                <p> <xsl:sequence select="fct:parseString($nLine)" /> </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fct:parseString" as="node()*">
        <xsl:param name="pS" as="xs:string" />

        <!-- match
    bold/italic __bold__ _italic_
  | bold/italic **bold** *italic*
  | links with text description [description](link)
  | inline code `code`
  | deleted ~~del~~
  | inline links (not very happy about the regex) 
  -->
        <xsl:analyze-string select="$pS" flags="x" regex="(__?(.*?)__?)
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
            ">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(1)">
                        <xsl:choose>
                            <xsl:when test="substring(regex-group(1), 1, 2) = '__'">
                                <strong>
                                    <xsl:sequence select="fct:parseString(regex-group(2))" />
                                </strong>
                            </xsl:when>
                            <xsl:otherwise>
                                <em>
                                    <xsl:sequence select="fct:parseString(regex-group(2))" />
                                </em>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="regex-group(3)">
                        <xsl:choose>
                            <xsl:when test="substring(regex-group(3), 1, 2) = '**'">
                                <strong>
                                    <xsl:sequence select="fct:parseString(regex-group(4))" />
                                </strong>
                            </xsl:when>
                            <xsl:otherwise>
                                <em>
                                    <xsl:sequence select="fct:parseString(regex-group(4))" />
                                </em>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="regex-group(5)">
                        <a href="{regex-group(7)}">
                            <xsl:sequence select="regex-group(6)" />
                        </a>
                    </xsl:when>
                    <xsl:when test="regex-group(8)">
                        <code>
                            <xsl:sequence select="regex-group(9)" />
                        </code>
                    </xsl:when>
                    <xsl:when test="regex-group(10)">
                        <del>
                            <xsl:sequence select="regex-group(11)" />
                        </del>
                    </xsl:when>
                    <xsl:when test="regex-group(12)">
                        <a href="{regex-group(12)}">
                            <xsl:sequence select="regex-group(12)" />
                        </a>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="." />
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

</xsl:stylesheet>
