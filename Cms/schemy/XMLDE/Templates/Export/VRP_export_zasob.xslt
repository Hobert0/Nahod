<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2008 sp1 (http://www.altova.com) by Dusan Pesko (CIGLER SOFTWARE, a.s.) -->
<!--Export tovarovych poloziek do Virtualnej registracnej pokladnice-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:template match="MoneyData">
		<sluzby>
			<xsl:apply-templates select="SeznamZasoba"/>
		</sluzby>
	</xsl:template>
	<xsl:template match="SeznamZasoba">
		<xsl:for-each select="Zasoba">
			<xsl:element name="sluzba">
				<xsl:element name="oznacenie">
					<xsl:value-of select="./KmKarta/Popis"/>
				</xsl:element>
				<xsl:element name="eanKod">
					<xsl:value-of select="./KmKarta/BarCode"/>
				</xsl:element>
				<xsl:element name="kodTovaru">
					<xsl:value-of select="./KmKarta/UzivCode"/>
				</xsl:element>
				<xsl:element name="jednotkovaCenaDPH">
					<xsl:value-of select="./PC[1]/Cena1/Cena"/>
				</xsl:element>
				<xsl:element name="sadzbaDPH">
					<xsl:value-of select="./konfigurace/SDPH_Prod"/>
				</xsl:element>
				<xsl:element name="poznamka">
					<xsl:value-of select="./Pozn"/>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
