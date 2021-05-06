<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- Odstraní z dokladů čísla dokladů, číselnou řadu a typ dokladu. Doklad se zařadí podle typu dokladu, který musí být
             specifikovaný v konfiguraci dat. -->

	<xsl:template match="FaktPrij | FaktPrij_DPP | FaktVyd | FaktVyd_DPP">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Doklad | self::Rada | self::CisRada | self::Typ)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ObjPrij | ObjVyd | NabPrij | NabVyd | PoptPrij | PoptVyd">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Doklad | self::DRada | self::DCislo | self::ZkratkaTypu)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Prijemka | Vydejka | Prodejka | DLPrij | DLVyd">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::CisloDokla | self::DRada | self::DCislo | self::ZkratTypuD)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="IntDokl | PokDokl | BanDokl | Pohledavka | Zavazek">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::Doklad | self::DRada | self::DCislo | self::TypDokl)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
