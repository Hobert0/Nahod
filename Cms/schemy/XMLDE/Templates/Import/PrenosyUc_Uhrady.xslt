<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


<!-- Transformační šablona doplní u faktur element Payment a odebere element ZpusobUctovani.
Autor: Marek Vykydal
-->


	<xsl:template match="/">						<!--	Pro všechny elementy na vrcholu vstupního dokumentu proveď  -->
			<xsl:apply-templates/>				<!--	Volá všechny funkce pro ty elementy, které se nachází na vrcholu vstupního dokumentu, tzn. MoneyData -->
	</xsl:template>

	<xsl:template match="MoneyData/*">										<!--	Pro všechny elementy pod elementem MoneyData proveď -->
		<xsl:choose>
			<xsl:when test="name()='SeznamFaktVyd'">
				<xsl:element name="SeznamFaktVyd">
					<xsl:apply-templates select="FaktVyd"/>					<!--	Volá funkce pro element FaktVyd -->
				</xsl:element>
			</xsl:when>
			<xsl:when test="name()='SeznamFaktPrij'">
				<xsl:element name="SeznamFaktPrij">
					<xsl:apply-templates select="FaktPrij"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Kopiruj"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


<!--	Založení faktury vydané -->
	<xsl:template match="FaktVyd">

		<xsl:element name="FaktVyd">
					<!--	Přidání elementu Payment kvůli importu úhrad -->
				<xsl:element name="Payment">1</xsl:element>
					<!-- Zkopírování elementů, které se nachází pod elementem FaktVyd kromě elementu ZpusobUctovani -->
				<xsl:apply-templates select="*[not(self::ZpusobUctovani)]|@*|comment()|text()"/>
		</xsl:element>

	</xsl:template>


<!--	Založení faktury přijaté -->
	<xsl:template match="FaktPrij">
	
		<xsl:element name="FaktPrij">
				<xsl:element name="Payment">1</xsl:element>
				<xsl:apply-templates select="*[not(self::ZpusobUctovani)]|@*|comment()|text()"/>
		</xsl:element>

	</xsl:template>


<!--	Kopírování struktury dokumentu kromě elementu ZpusobUctovani -->
	<xsl:template match="node()" name="Kopiruj">
	
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::ZpusobUctovani)]|@*|text()" >
				<xsl:with-param name="Rezim" select="1"/>
			</xsl:apply-templates>
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
