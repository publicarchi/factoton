<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xmlns="http://www.w3.org/1999/xhtml" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <!--
    teiArticle2html5
    @author emchateau
    @since 2018-11-28
  -->
  <xsl:output method="html" indent="yes" encoding="UTF-8" html-version="5.0" omit-xml-declaration="yes"  exclude-result-prefixes="#default"/>
  <xsl:strip-space elements="*" />
  
  <xsl:template match="processing-instruction(xml-model)"/>
  <xsl:template match="/TEI">
    <html>
      <xsl:apply-templates select="teiHeader" />
      <xsl:apply-templates select="text" />
    </html>
  </xsl:template>
  <xsl:template match="teiHeader">
    <head>
      <meta charset="utf-8" />
      <meta http-equiv="content-type" content="text/html" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />
      <title>
        <xsl:for-each select="fileDesc/titleStmt/title">
          <xsl:apply-templates />
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </title>
      <link href="css/normalize.css" rel="stylesheet" />
      <link href="css/main.css" rel="stylesheet" />
    </head>
  </xsl:template>
  <xsl:template match="text">
      <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="front"/>
  <xsl:template match="body">
    <body>
      <xsl:apply-templates />
    </body>
  </xsl:template>
  <xsl:template match="back"/>
  <xsl:template match="div">
    <div>
      <xsl:apply-templates />
    </div>
  </xsl:template>
  <xsl:template match="p">
    <p>
      <xsl:apply-templates />
    </p>
  </xsl:template>
  <xsl:template match="list">
    <xsl:choose>
      <xsl:when test="@type='ordered'">
        <ol>
          <xsl:apply-templates/>
        </ol>
      </xsl:when>
      <xsl:when test="@type='definition'">
        <dl>
          <xsl:apply-templates mode="definition" />
        </dl>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:apply-templates />
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="item">
    <li>
      <xsl:apply-templates />
    </li>
  </xsl:template>
  <xsl:template match="item" mode="definition">
    <dt>
      <xsl:apply-templates/>
    </dt>
  </xsl:template>
  <xsl:template match="head">
    <xsl:variable name="level" select="count(ancestor::div)" />
    <xsl:variable name="name" select="concat('h', $level)" />
    <xsl:element name="{$name}">
      <xsl:apply-templates select="@*|node()" />
    </xsl:element>
  </xsl:template>
  <!-- cit et ref -->
  <xsl:template match="quote">
    <xsl:text>« </xsl:text>
    <xsl:apply-templates />
    <xsl:text> »</xsl:text>
  </xsl:template>
  <xsl:template match="note">
    <sup>
      <a title="{.}" href="#">
        <xsl:number count="note" level="any"/>
      </a>
    </sup>
  </xsl:template>
  
  <xsl:template match="lb">
    <br />
  </xsl:template>
  <!-- inline -->
  <xsl:template match="hi[@rend = 'italic']">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>
  <xsl:template match="hi[@rend = 'bold']">
    <strong>
      <xsl:apply-templates />
    </strong>
  </xsl:template>
  <xsl:template match="hi[@rend='superscript']">
    <sup>
      <xsl:apply-templates />
    </sup>
  </xsl:template>
  <xsl:template match="del">
    <del>
      <xsl:apply-templates />
    </del>
  </xsl:template>
  <xsl:template match="ref[@target]">
    <a href="{@target}">
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="node()" />
    </a>
  </xsl:template>
  <xsl:template match="soCalled">
    <em class="soCalled">
      <xsl:apply-templates />
    </em>
  </xsl:template>
  <!-- attributs -->
  <xsl:template match="*"> 
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="@xml:id">
    <xsl:attribute name="id">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy />
  </xsl:template>
  <!-- copie à l’identique -->
  <xsl:template match="node() | @*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current" />
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
