<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- Odstraní z inventurních dokladů čísla dokladů a čísla inventur. Inventura musí být specifikovaná v konfiguraci dat. -->

	<xsl:template match="InvDoklad">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*[not(self::CisloD | self::InvID)] | @* | text()"/>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
