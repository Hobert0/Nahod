<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates select="*|@*|text()"/>
	</xsl:template>


	<!-- Odstraní z dokladů čísla dokladů. Doklad se zařadí podle číselné řady.	 -->
	<xsl:include href="__BezCD.xslt"/>


	<!-- Odstraní z dokladů čísla dokladů a číselnou řadu. Doklad se zařadí podle typu dokladu, který je buď součástí importu,
	      nebo je specifikovaný v konfiguraci dat.
	<xsl:include href="__BezCDaCR.xslt"/>
	 -->


	<!-- Odstraní z dokladů čísla dokladů, číselnou řadu a typ dokladu. Doklad se zařadí podle typu dokladu, který musí být
             specifikovaný v konfiguraci dat.
	<xsl:include href="__BezCDaCRaTD.xslt"/>
      	-->


	<!-- Odstraní z položek dokladů sklad. Sklad musí být specifikovaný v konfiguraci dat.
	<xsl:include href="__BezSkl.xslt"/>
	 -->


	<!-- implicitní přepis elementů, atributů a obsahu -->
	<xsl:template match="node()">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*|@*|text()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>

</xsl:stylesheet>
