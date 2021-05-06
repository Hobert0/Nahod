<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>

<!-- Transformační šablona náhledu pro seznam skladů a ceníků ve tvaru HTML. -->

	<xsl:template match="/">
		<html>
			<head>
				<title>Zoznam skladov a cenníkov</title>
				<style><![CDATA[
					body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%; color: black; }
					td {vertical-align: middle;}

						.tucne {font-weight: bold;}
						.kurziva {font-style: italic;}

						.velikost1 {font-size: 120%;}
						.velikost5 {font-size: 72%;}
						.velikost7 {font-size: 60%;}

						.zarovnani_N {vertical-align: top;}
						.zarovnani_D {vertical-align: bottom;}

						.podtrzeni_N {border-top: 1px solid black;}
						.podtrzeni_D {border-bottom: 1px solid black;}
						.podtrzeni_NT {border-top: 1px dotted black;}
						.podtrzeni_DT {border-bottom: 1px dotted black;}

					   ]]>
				</style>
			</head>
			<body>
				<xsl:apply-templates></xsl:apply-templates>
			</body>
		</html>
	</xsl:template>


<!-- Kořenový element -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	

<!-- Datumový formát výstupu -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum" />
		<xsl:variable name="den" select="substring($_datum, 9,2)"></xsl:variable>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"></xsl:variable>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"></xsl:variable>
		<xsl:variable name="datum" select="concat($den,'.',$mesic,'.',$rok)"></xsl:variable>
		<xsl:value-of select="$datum"></xsl:value-of>
	</xsl:template>


<!-- Seznam skladů a ceníků -->
	<xsl:template match="SeznamSkladu">
		<xsl:param name="Pocet" select="count(Sklad)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

			<xsl:if test="$Pocet>0">
				<tr>
					<td class="velikost1 tucne zarovnani_N" colspan="8" height="35">Zoznam skladov a cenníkov</td>
				</tr>
				<tr>
					<td class="velikost5 tucne podtrzeni_D" height="20" width="30%">Názov skladu</td>
					<td class="velikost5 tucne podtrzeni_D" width="15%">Kód skladu (EAN)</td>
					<td class="velikost5 tucne podtrzeni_D" width="15%">Stredisko</td>
					<td class="velikost5 tucne podtrzeni_D" width="10%">Preferovaný sklad</td>
					<td class="velikost5 tucne podtrzeni_D" width="10%">Predajný cenník</td>
					<td class="velikost5 tucne podtrzeni_D" width="10%">Platnosť cenníka od</td>
					<td class="velikost5 tucne podtrzeni_D" width="10%">Platnosť cenníka do</td>
				</tr>
			</xsl:if>

			<xsl:apply-templates select="Sklad">
				<xsl:with-param name="Report" select="$Report"/>
			</xsl:apply-templates>

			<xsl:if test="$Pocet>0">
				<tr><td class="podtrzeni_N" colspan="8">&#160;</td></tr>
				<tr><td height="75"/></tr>										<!-- mezera -->
			</xsl:if>	

			<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Sklad -->
	<xsl:template match="Sklad">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Nazev"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="KodSkladu"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Stredisko"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						<xsl:choose>
							<xsl:when test="PrefSklad = 1">Áno</xsl:when>
							<xsl:when test="PrefSklad = 0">Nie</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</td>
					<td class="velikost5 podtrzeni_NT">
						<xsl:choose>
							<xsl:when test="CenikSklad = 1">Áno</xsl:when>
							<xsl:when test="CenikSklad = 0">Nie</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</td>
					<td class="velikost5 podtrzeni_NT">
						<xsl:if test="string-length(PlatnoOd) &gt; 0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="PlatnoOd"/></xsl:with-param>
							</xsl:call-template>
						</xsl:if>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						<xsl:if test="string-length(PlatnoDo) &gt; 0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="PlatnoDo"/></xsl:with-param>
							</xsl:call-template>
						</xsl:if>&#160;</td>
				</tr>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="7" height="35">Sklad</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="30%">Názov skladu</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Kód skladu (EAN)</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Stredisko</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%">Preferovaný sklad</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%">Predajný cenník</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%">Platnosť cenníka od</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%">Platnosť cenníka do</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Nazev"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="KodSkladu"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Stredisko"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							<xsl:choose>
								<xsl:when test="PrefSklad = 1">Áno</xsl:when>
								<xsl:when test="PrefSklad = 0">Nie</xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
							</xsl:choose>
						</td>
						<td class="velikost5 podtrzeni_NT">
							<xsl:choose>
								<xsl:when test="CenikSklad = 1">Áno</xsl:when>
								<xsl:when test="CenikSklad = 0">Nie</xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
							</xsl:choose>
						</td>
						<td class="velikost5 podtrzeni_NT">
							<xsl:if test="string-length(PlatnoOd) &gt; 0">
								<xsl:call-template name="_datum_">
									<xsl:with-param name="_datum"><xsl:value-of select="PlatnoOd"/></xsl:with-param>
								</xsl:call-template>
							</xsl:if>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							<xsl:if test="string-length(PlatnoDo) &gt; 0">
								<xsl:call-template name="_datum_">
									<xsl:with-param name="_datum"><xsl:value-of select="PlatnoDo"/></xsl:with-param>
								</xsl:call-template>
							</xsl:if>&#160;</td>
					</tr>
					<tr><td class="podtrzeni_N" colspan="7">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>

</xsl:stylesheet>
