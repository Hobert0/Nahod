<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dt="urn:schemas-microsoft-com:datatypes" xmlns:d2="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882">

<!-- Sablona pro zobrazeni obecneho XML souboru a jeho struktury -->

<xsl:template match="/">
  <HTML>
    <HEAD>
      <STYLE>
        BODY {font:x-small 'Verdana'; margin-right:1.5em}
        .c {}
        .b {color:red; font-family:'Courier New'; font-weight:bold; text-decoration:none}
        .e {margin-left:1em; text-indent:-1em; margin-right:1em}
        .k {margin-left:1em; text-indent:-1em; margin-right:1em}
        .t {color:#990000}
        .xt {color:#990099}
        .ns {color:red}
        .dt {color:green}
        .m {color:blue}
        .tx {font-weight:bold}
        .db {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; border-left:1px solid #CCCCCC; font:small Courier}
        .di {font:small Courier}
        .d {color:blue}
        .pi {color:blue}
        .cb {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; font:small Courier; color:#888888}
        .ci {font:small Courier; color:#888888}
        PRE {margin:0px; display:inline}
      </STYLE>
    </HEAD>
    <BODY class="st"><xsl:apply-templates/></BODY>
  </HTML>
</xsl:template>

<xsl:template match="@*" xml:space="preserve">
  <SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()" /></SPAN><SPAN class="m">="</SPAN><B><xsl:value-of select="."/></B><SPAN class="m">"</SPAN>
</xsl:template>

<xsl:template match="text()">
  <DIV class="e">
    <SPAN class="b">&#160;</SPAN><SPAN class="tx"><xsl:value-of select="."/></SPAN>
  </DIV>
</xsl:template>

<xsl:template match="*">
  <DIV class="e"><DIV STYLE="margin-left:1em;text-indent:-2em">
    <SPAN class="b">&#160;</SPAN><SPAN class="m">&lt;</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN> <xsl:apply-templates select="@*"/><SPAN class="m">/&gt;</SPAN>
  </DIV></DIV>
</xsl:template>

<xsl:template match="*[comment() | processing-instruction()]">
  <DIV class="e">
    <DIV class="c"><A href="#" class="b">-</A>
      <SPAN class="m">&lt;</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><xsl:apply-templates select="@*"/><SPAN class="m">&gt;</SPAN>
    </DIV>
    <DIV><xsl:apply-templates/>
      <DIV>
        <SPAN class="b">&#160;</SPAN> <SPAN class="m">&lt;/</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><SPAN class="m">&gt;</SPAN>
      </DIV>
    </DIV>
  </DIV>
</xsl:template>

<xsl:template match="*[text() and not(comment() | processing-instruction())]">
  <DIV class="e"><DIV STYLE="margin-left:1em;text-indent:-2em">
    <SPAN class="b">&#160;</SPAN><SPAN class="m">&lt;</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><xsl:apply-templates select="@*"/><SPAN class="m">&gt;</SPAN><SPAN class="tx"><xsl:value-of select="."/></SPAN><SPAN class="m">&lt;/</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><SPAN class="m">&gt;</SPAN>
  </DIV></DIV>
</xsl:template>

<xsl:template match="*[*]">
  <DIV class="e">
    <DIV class="c" STYLE="margin-left:1em;text-indent:-2em"><!--A href="#" class="b">-</A-->
    <SPAN class="m">&lt;</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><xsl:apply-templates select="@*"/><SPAN class="m">&gt;</SPAN>
  </DIV>
  <DIV>
    <xsl:apply-templates/>
    <DIV>
      <SPAN class="b">&#160;</SPAN><SPAN class="m">&lt;/</SPAN><SPAN><xsl:attribute name="class"><xsl:if test="starts-with(name(),'xsl:')">x</xsl:if>t</xsl:attribute><xsl:value-of select="name()"/></SPAN><SPAN class="m">&gt;</SPAN>
    </DIV>
  </DIV></DIV>
</xsl:template>

</xsl:stylesheet>