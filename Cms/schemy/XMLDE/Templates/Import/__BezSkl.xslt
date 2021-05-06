<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- Odstraní z položek dokladů sklad. Sklad musí být specifikovaný v konfiguraci dat. -->

	<xsl:template match="FaktVyd//SklPolozka | FaktPrij//SklPolozka | FaktVyd//Polozka | FaktPrij//Polozka | Slozeni/SubPolozka/Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Sklad | self::SkladID)] | @* | text()"/>
		</xsl:element>
	</xsl:template>
	<!-- Faktury vydané a přijaté - normální, faktury vydané a přijaté - zálohové, podřízené položky - pro všechny doklady -->

	<xsl:template match="ObjPrij//Polozka | ObjVyd//Polozka | NabPrij//Polozka | NabVyd//Polozka | PoptPrij//Polozka | PoptVyd//Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Sklad | self::SkladID)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Prijemka//Polozka | Vydejka//Polozka | Prodejka//Polozka | DLPrij//Polozka | DLVyd//Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Sklad | self::SkladID)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="InvDoklad//Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Sklad | self::SkladID)] | @* | text()"/>
		</xsl:element>
	</xsl:template>


</xsl:stylesheet>
