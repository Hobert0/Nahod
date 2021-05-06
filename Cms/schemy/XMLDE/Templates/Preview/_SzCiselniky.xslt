<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8" />

<!-- Transformační šablona náhledu určená pro zobrazení kontrolingových seznamů ve tvaru HTML.
střediska, činnosti, členění DPH, účtová osnova (podvojné účetnictví), účetní pohyby (daňová evidence), předkontace (podvojné účetnictví, daňová evidence), zaúčtování DPH (podvojné účetnictví, daňová evidence), bankovní účty a pokladny

Autor: Marek Vykydal
 -->

	<xsl:template match="/">
		<html>
			<head>
				<title>Seznamy</title>
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


<!-- Seznam činností, středisek  -->
	<xsl:template match="SeznamCinnosti | SeznamStredisek">
		<xsl:param name="Pocet" select="count(Cinnost | Stredisko)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="2" height="35">
					    <xsl:choose>
							<xsl:when test="name()='SeznamCinnosti' ">Zoznam činností</xsl:when>
							<xsl:when test="name()='SeznamStredisek' ">Zoznam stredísk</xsl:when>
					    </xsl:choose>
				</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="20%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D">Popis</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="Cinnost | Stredisko">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="2">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Činnost, středisko  -->
	<xsl:template match="Cinnost | Stredisko">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Nazev"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="2">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="2" height="35">
						    <xsl:choose>
								<xsl:when test="name()='Cinnost' ">Činnosť</xsl:when>
								<xsl:when test="name()='Stredisko' ">Stredisko</xsl:when>
						    </xsl:choose>
						</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="20%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D">Popis</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Nazev"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="2">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="2">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam členění DPH -->
	<xsl:template match="SeznamClenDPH">
		<xsl:param name="Pocet" select="count(ClenDPH)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="4" height="35">Zoznam členení DPH</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Platnosť od</td>
				<td class="velikost5 tucne podtrzeni_D">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="20%">Typ zdaniteľného plnenia</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="ClenDPH">
		      <xsl:sort select="DatumOd"/>				<!-- řazení podle data od a zkratky -->
			<xsl:sort select="Zkrat"/>
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="4">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Členění DPH -->
	<xsl:template match="ClenDPH">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" height="20">
						<xsl:call-template name="_datum_">
							<xsl:with-param name="_datum"><xsl:value-of select="DatumOd"/></xsl:with-param>
						</xsl:call-template>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='U' ">uskutočnené plnenia</xsl:when>
								<xsl:when test="Typ='P' ">prijaté plnenia</xsl:when>
						    </xsl:choose>&#160;
					</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="4">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="4" height="35">Členenie DPH</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Platnosť od</td>
						<td class="velikost5 tucne podtrzeni_D">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="20%">Typ zdaniteľného plnenia</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" height="20">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatumOd"/></xsl:with-param>
							</xsl:call-template>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='U' ">uskutočnené plnenia</xsl:when>
								<xsl:when test="Typ='P' ">prijaté plnenia</xsl:when>
						    </xsl:choose>&#160;
						</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="4">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="4">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Účtová osnova  -->
	<xsl:template match="SeznamUcOsnov">
		<xsl:param name="Pocet" select="count(UcOsnova)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="6" height="35">Účtová osnova</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Účet</td>
				<td class="velikost5 tucne podtrzeni_D"  width="40%">Názov účtu</td>
				<td class="velikost5 tucne podtrzeni_D"  width="10%">Druh účtu</td>
				<td class="velikost5 tucne podtrzeni_D"  width="10%">Typ účtu</td>
				<td class="velikost5 tucne podtrzeni_D"  width="20%">Podtyp</td>
				<td class="velikost5 tucne podtrzeni_D"  width="10%">Účet prevodu</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="UcOsnova">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="6">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Účet -->
	<xsl:template match="UcOsnova">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Ucet"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Nazev"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="DruhUctu=1">súvahový</xsl:when>
								<xsl:when test="DruhUctu=2">výsledkový</xsl:when>
								<xsl:when test="DruhUctu=3">závierkový</xsl:when>
								<xsl:when test="DruhUctu=4">podsúvahový</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="UcetTyp=1">aktívny</xsl:when>
								<xsl:when test="UcetTyp=2">pasívny</xsl:when>
								<xsl:when test="UcetTyp=3">nákladový</xsl:when>
								<xsl:when test="UcetTyp=4">výnosový</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT">
							<xsl:choose>
								<xsl:when test="UcetPodTyp=1">sledovať saldo</xsl:when>
								<xsl:when test="UcetPodTyp=2">nesledovať saldo</xsl:when>
								<xsl:when test="UcetPodTyp=3">ovplyvňujúci daň z príjmov</xsl:when>
								<xsl:when test="UcetPodTyp=4">neovplyvňujúci daň z príjmov</xsl:when>
								<xsl:when test="UcetPodTyp=5">sledovať zostatok na MD</xsl:when>
								<xsl:when test="UcetPodTyp=6">sledovať zostatok na DAL</xsl:when>
							</xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="UcPrev"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="6" height="35">Účtová osnova</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Účet</td>
						<td class="velikost5 tucne podtrzeni_D"  width="40%">Názov účtu</td>
						<td class="velikost5 tucne podtrzeni_D"  width="10%">Druh účtu</td>
						<td class="velikost5 tucne podtrzeni_D"  width="10%">Typ účtu</td>
						<td class="velikost5 tucne podtrzeni_D"  width="20%">Podtyp</td>
						<td class="velikost5 tucne podtrzeni_D"  width="10%">Účet prevodu</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Ucet"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Nazev"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
              <xsl:choose>
                <xsl:when test="DruhUctu=1">súvahový</xsl:when>
                <xsl:when test="DruhUctu=2">výsledkový</xsl:when>
                <xsl:when test="DruhUctu=3">závierkový</xsl:when>
                <xsl:when test="DruhUctu=4">podsúvahový</xsl:when>
              </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT">
              <xsl:choose>
                <xsl:when test="UcetTyp=1">aktívny</xsl:when>
                <xsl:when test="UcetTyp=2">pasívny</xsl:when>
                <xsl:when test="UcetTyp=3">nákladový</xsl:when>
                <xsl:when test="UcetTyp=4">výnosový</xsl:when>
              </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT">
							   	<xsl:choose>
                    <xsl:when test="UcetPodTyp=1">sledovať saldo</xsl:when>
                    <xsl:when test="UcetPodTyp=2">nesledovať saldo</xsl:when>
                    <xsl:when test="UcetPodTyp=3">ovplyvňujúci daň z príjmov</xsl:when>
                    <xsl:when test="UcetPodTyp=4">neovplyvňujúci daň z príjmov</xsl:when>
                    <xsl:when test="UcetPodTyp=5">sledovať zostatok na MD</xsl:when>
                    <xsl:when test="UcetPodTyp=6">sledovať zostatok na DAL</xsl:when>
								</xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="UcPrev"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="6">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam účetních pohybů -->
	<xsl:template match="SeznamUcPohybu">
		<xsl:param name="Pocet" select="count(UcPohyb)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="4" height="35">Zoznam účtovných pohybov</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="40%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%">Typ</td>
				<td class="velikost5 tucne podtrzeni_D" width="40%">Stĺpec v peňažnom denníku</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="UcPohyb">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="6">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Účetní pohyb -->
	<xsl:template match="UcPohyb">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='P' ">príjmy</xsl:when>
								<xsl:when test="Typ='V' ">výdaje</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<!-- Společné pro CZ i SK verzi: -->
								<xsl:when test="Sloupec='PZbo' ">príjmy za tovar</xsl:when>
								<xsl:when test="Sloupec='PSlu' ">príjmy za služby</xsl:when>
								<xsl:when test="Sloupec='POst' ">ostatné príjmy podliehajúce dani</xsl:when>
								<xsl:when test="Sloupec='PSra' ">príjmy - zrážky</xsl:when>
								<xsl:when test="Sloupec='PDPH' ">príjmy – DPH</xsl:when>
								<xsl:when test="Sloupec='PDot' ">príjmy – dotácie</xsl:when>
								<xsl:when test="Sloupec='PVkl' ">príjmy – vklad</xsl:when>
								<xsl:when test="Sloupec='POsN' ">ostatné príjmy nepodliehajúce dani</xsl:when>
								<xsl:when test="Sloupec='PPrP' ">prevod z priebežných položiek</xsl:when>
								<xsl:when test="Sloupec='VMat' ">výdaje za materiál </xsl:when>
								<xsl:when test="Sloupec='VZbo' ">výdaje za tovar</xsl:when>
								<xsl:when test="Sloupec='VDrM' ">výdaje za drobný majetok</xsl:when>
								<xsl:when test="Sloupec='VMzd' ">výdaje za mzdy</xsl:when>
								<xsl:when test="Sloupec='VDMz' ">výdaje za daň z miezd</xsl:when>
								<xsl:when test="Sloupec='VRez' ">výdaje - prevádzková réžia</xsl:when>
								<xsl:when test="Sloupec='VHIM' ">výdaje – dlhodobý majetok</xsl:when>
								<xsl:when test="Sloupec='VDPH' ">výdaje – DPH</xsl:when>
								<xsl:when test="Sloupec='VRzr' ">výdaje – rezerva</xsl:when>
								<xsl:when test="Sloupec='VDzP' ">výdaje – daň z príjmov</xsl:when>
								<xsl:when test="Sloupec='VOso' ">výdaje – osobné</xsl:when>
								<xsl:when test="Sloupec='VOsN' ">ostatné výdaje nepodliehajúce dani</xsl:when>
								<xsl:when test="Sloupec='VPrP' ">prevod na priebežné položky</xsl:when>

								<!-- Pouze CZ verze: -->
								<xsl:when test="Sloupec='VDar' ">výdaje – dary</xsl:when>
								<xsl:when test="Sloupec='VSoP' ">výdaje za sociální pojištění</xsl:when>
								<xsl:when test="Sloupec='VZdP' ">výdaje za zdravotní pojištění</xsl:when>
								<xsl:when test="Sloupec='VOzc' "></xsl:when>

								<!-- Pouze SK verze: -->
								<xsl:when test="Sloupec='PSFT' "></xsl:when>
								<xsl:when test="Sloupec='VPoj' "></xsl:when>
								<xsl:when test="Sloupec='VTSF' "></xsl:when>
								<xsl:when test="Sloupec='VUvP' "></xsl:when>
								<xsl:when test="Sloupec='VSFC' "></xsl:when>
							</xsl:choose>&#160;
					</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="4">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="4" height="35">Účtovný pohyb</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D" width="40%">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%">Typ</td>
						<td class="velikost5 tucne podtrzeni_D" width="40%">Stĺpec v peňažnom denníku</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							    <xsl:choose>
									<xsl:when test="Typ='P' ">příjmy</xsl:when>
									<xsl:when test="Typ='V' ">výdaje</xsl:when>
							    </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<!-- Společné pro CZ i SK verzi: -->
                  <xsl:when test="Sloupec='PZbo' ">príjmy za tovar</xsl:when>
                  <xsl:when test="Sloupec='PSlu' ">príjmy za služby</xsl:when>
                  <xsl:when test="Sloupec='POst' ">ostatné príjmy podliehajúce dani</xsl:when>
                  <xsl:when test="Sloupec='PSra' ">príjmy - zrážky</xsl:when>
                  <xsl:when test="Sloupec='PDPH' ">príjmy – DPH</xsl:when>
                  <xsl:when test="Sloupec='PDot' ">príjmy – dotácie</xsl:when>
                  <xsl:when test="Sloupec='PVkl' ">príjmy – vklad</xsl:when>
                  <xsl:when test="Sloupec='POsN' ">ostatné príjmy nepodliehajúce dani</xsl:when>
                  <xsl:when test="Sloupec='PPrP' ">prevod z priebežných položiek</xsl:when>
                  <xsl:when test="Sloupec='VMat' ">výdaje za materiál </xsl:when>
                  <xsl:when test="Sloupec='VZbo' ">výdaje za tovar</xsl:when>
                  <xsl:when test="Sloupec='VDrM' ">výdaje za drobný majetok</xsl:when>
                  <xsl:when test="Sloupec='VMzd' ">výdaje za mzdy</xsl:when>
                  <xsl:when test="Sloupec='VDMz' ">výdaje za daň z miezd</xsl:when>
                  <xsl:when test="Sloupec='VRez' ">výdaje - prevádzková réžia</xsl:when>
                  <xsl:when test="Sloupec='VHIM' ">výdaje – dlhodobý majetok</xsl:when>
                  <xsl:when test="Sloupec='VDPH' ">výdaje – DPH</xsl:when>
                  <xsl:when test="Sloupec='VRzr' ">výdaje – rezerva</xsl:when>
                  <xsl:when test="Sloupec='VDzP' ">výdaje – daň z príjmov</xsl:when>
                  <xsl:when test="Sloupec='VOso' ">výdaje – osobné</xsl:when>
                  <xsl:when test="Sloupec='VOsN' ">ostatné výdaje nepodliehajúce dani</xsl:when>
                  <xsl:when test="Sloupec='VPrP' ">prevod na priebežné položky</xsl:when>


                  <!-- Pouze CZ verze: -->
								<xsl:when test="Sloupec='VDar' ">výdaje – dary</xsl:when>
								<xsl:when test="Sloupec='VSoP' ">výdaje za sociální pojištění</xsl:when>
								<xsl:when test="Sloupec='VZdP' ">výdaje za zdravotní pojištění</xsl:when>
								<xsl:when test="Sloupec='VOzc' "></xsl:when>

								<!-- Pouze SK verze: -->
								<xsl:when test="Sloupec='PSFT' "></xsl:when>
								<xsl:when test="Sloupec='VPoj' "></xsl:when>
								<xsl:when test="Sloupec='VTSF' "></xsl:when>
								<xsl:when test="Sloupec='VUvP' "></xsl:when>
								<xsl:when test="Sloupec='VSFC' "></xsl:when>
							</xsl:choose>&#160;
						</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="4">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="4">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam předkontací (podvojné účetnictví) -->
	<xsl:template match="SeznamPredkontaci">
		<xsl:param name="Pocet" select="count(Predkontace)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="8" height="35">Zoznam predkontácií</td>
			</tr>
			<tr>
				<td/>
				<td/>
				<td/>
				<td class="velikost5 tucne" height="20" colspan="2" align="center">Základ dane</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="12%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="28%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="14%">Použitie</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
				<td class="velikost5 tucne podtrzeni_D" width="4%">&#160;</td>
				<td class="velikost5 tucne podtrzeni_D" width="11%">Zaúčtovanie DPH</td>
				<td class="velikost5 tucne podtrzeni_D" width="11%">Členenie DPH</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="Predkontace">
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


<!-- Předkontace (podvojné účetnictví)  -->
	<xsl:template match="Predkontace">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='NN' ">ľubovoľná predkontácia</xsl:when>
								<xsl:when test="Typ='VF' ">faktúry vystavené</xsl:when>
								<xsl:when test="Typ='PF' ">faktúry prijaté</xsl:when>
								<xsl:when test="Typ='PP' ">príjem do pokladnice</xsl:when>
								<xsl:when test="Typ='VP' ">výdaj z pokladnice</xsl:when>
								<xsl:when test="Typ='PU' ">príjem na účet</xsl:when>
								<xsl:when test="Typ='VU' ">výdaj z účtu</xsl:when>
								<xsl:when test="Typ='ZA' ">záväzky</xsl:when>
								<xsl:when test="Typ='PO' ">pohľadávky</xsl:when>
								<xsl:when test="Typ='ID' ">interné doklady</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="UcMD"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="UcD"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="ZauctDPH"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Cleneni"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="8">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="8" height="35">Predkontácia</td>
					</tr>
					<tr>
						<td/>
						<td/>
						<td/>
						<td class="velikost5 tucne" height="20" colspan="2" align="center">Základ dane</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="12%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D" width="28%">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="14%">Použití</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
						<td class="velikost5 tucne podtrzeni_D" width="4%">&#160;</td>
						<td class="velikost5 tucne podtrzeni_D" width="11%">Zaúčtovanie DPH</td>
						<td class="velikost5 tucne podtrzeni_D" width="11%">Členenie DPH</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							    <xsl:choose>
                    <xsl:when test="Typ='NN' ">ľubovoľná predkontácia</xsl:when>
                    <xsl:when test="Typ='VF' ">faktúry vystavené</xsl:when>
                    <xsl:when test="Typ='PF' ">faktúry prijaté</xsl:when>
                    <xsl:when test="Typ='PP' ">príjem do pokladnice</xsl:when>
                    <xsl:when test="Typ='VP' ">výdaj z pokladnice</xsl:when>
                    <xsl:when test="Typ='PU' ">príjem na účet</xsl:when>
                    <xsl:when test="Typ='VU' ">výdaj z účtu</xsl:when>
                    <xsl:when test="Typ='ZA' ">záväzky</xsl:when>
                    <xsl:when test="Typ='PO' ">pohľadávky</xsl:when>
                    <xsl:when test="Typ='ID' ">interné doklady</xsl:when>
							    </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="UcMD"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="UcD"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="ZauctDPH"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Cleneni"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="8">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="8">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam předkontací (dańová evidence) -->
	<xsl:template match="SeznamPredkontaciDE">
		<xsl:param name="Pocet" select="count(PredkontaceDE)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="6" height="35">Zoznam predkontácií</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="15%">Použitie</td>
				<td class="velikost5 tucne podtrzeni_D" width="15%">Základ dane</td>
				<td class="velikost5 tucne podtrzeni_D" width="15%">Zaúčtovanie DPH</td>
				<td class="velikost5 tucne podtrzeni_D" width="15%">Členenie DPH</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="PredkontaceDE">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="6">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Předkontace (daňová evidence)  -->
	<xsl:template match="PredkontaceDE">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='P' ">príjmy</xsl:when>
								<xsl:when test="Typ='V' ">výdaje</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohZak"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="ZauctDPH"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Cleneni"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="9" height="35">Predkontácie</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Typ</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Základ dane</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Zaúčtovanie DPH</td>
						<td class="velikost5 tucne podtrzeni_D" width="15%">Členenie DPH</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							    <xsl:choose>
									<xsl:when test="Typ='P' ">príjmy</xsl:when>
									<xsl:when test="Typ='V' ">výdaje</xsl:when>
							    </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohZak"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="ZauctDPH"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Cleneni"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="6">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>
	</xsl:template>



<!-- Seznam zaúčtování DPH (podvojné účetnictví) -->
	<xsl:template match="SeznamZauctovaniDPH">
		<xsl:param name="Pocet" select="count(ZauctovaniDPH)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="7" height="35">Seznam zaúčtování DPH</td>
			</tr>
			<tr>
				<td/>
				<td/>
				<td/>
				<td class="velikost5 tucne" height="20" colspan="2" align="center">DPH v zníženej hladine</td>
				<td class="velikost5 tucne" colspan="2" align="center">DPH v základnej hladine</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="12%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="18%">Použitie</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
				<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="ZauctovaniDPH">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="7">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Zaúčtování DPH (podvojné účetnictví)  -->
	<xsl:template match="ZauctovaniDPH">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='P' ">příjmy</xsl:when>
								<xsl:when test="Typ='V' ">výdaje</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="SDUcMD"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="SDUcD"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="ZDUcMD"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="ZDUcD"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="7">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
							<td class="velikost1 tucne zarovnani_N" colspan="7" height="35">Zaúčtovanie DPH</td>
						</tr>
						<tr>
							<td/>
							<td/>
							<td/>
							<td class="velikost5 tucne" height="20" colspan="2" align="center">DPH v zníženej hladine</td>
							<td class="velikost5 tucne" colspan="2" align="center">DPH v základnej hladine</td>
						</tr>
						<tr>
							<td class="velikost5 tucne podtrzeni_D" height="20" width="12%">Skratka</td>
							<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
							<td class="velikost5 tucne podtrzeni_D" width="18%">Použitie</td>
							<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
							<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
							<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">MÁ DAŤ</td>
							<td class="velikost5 tucne podtrzeni_D" width="10%" align="center">DAL</td>
						</tr>

					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							    <xsl:choose>
									<xsl:when test="Typ='P' ">príjmy</xsl:when>
									<xsl:when test="Typ='V' ">výdaje</xsl:when>
							    </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="SDUcMD"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="SDUcD"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="ZDUcMD"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" align="center"><xsl:value-of select="ZDUcD"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="7">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="7">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam zaúčtování DPH (daňová evidence) -->
	<xsl:template match="SeznamZauctovaniDPH_DE">
		<xsl:param name="Pocet" select="count(ZauctovaniDPH_DE)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="5" height="35">Zoznam zaúčtovania DPH</td>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="16%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="18%">Použitie</td>
				<td class="velikost5 tucne podtrzeni_D" width="18%">DPH v zníženej hladine</td>
				<td class="velikost5 tucne podtrzeni_D" width="18%">DPH v základnej hladine</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="ZauctovaniDPH_DE">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="5">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Zaúčtování DPH (daňová evidence)  -->
	<xsl:template match="ZauctovaniDPH_DE">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT">
						    <xsl:choose>
								<xsl:when test="Typ='P' ">príjmy</xsl:when>
								<xsl:when test="Typ='V' ">výdaje</xsl:when>
						    </xsl:choose>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohDSS"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohDZS"/>&#160;</td>
				</tr>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="5">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<td class="velikost1 tucne zarovnani_N" colspan="5" height="35">Zaúčtování DPH</td>
					</tr>
					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="16%">Skratka</td>
						<td class="velikost5 tucne podtrzeni_D" width="30%">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="18%">Použitie</td>
						<td class="velikost5 tucne podtrzeni_D" width="18%">DPH v zníženej hladine</td>
						<td class="velikost5 tucne podtrzeni_D" width="18%">DPH v základnej hladine</td>
					</tr>

					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT">
							    <xsl:choose>
									<xsl:when test="Typ='P' ">príjmy</xsl:when>
									<xsl:when test="Typ='V' ">výdaje</xsl:when>
							    </xsl:choose>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohDSS"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PohDZS"/>&#160;</td>
					</tr>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="5">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="5">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>

	</xsl:template>



<!-- Seznam bankovních účtů a pokladen -->
	<xsl:template match="SeznamBankUctuPokladen">
		<xsl:param name="Pocet" select="count(BankUcetPokladna)"/>
		<xsl:param name="Report">Ne</xsl:param>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

		<xsl:if test="$Pocet>0">
			<tr>
				<td class="velikost1 tucne zarovnani_N" colspan="7" height="35">Zoznam bankových účtov a pokladníc</td>
			</tr>

			<tr>
				<td/>
				<td/>
				<td class="velikost5 tucne" height="20">Účet - číslo účtu, peňažný ústav</td>
				<td/>
				<td/>
				<td/>
				<td/>
			</tr>
			<tr>
				<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Skratka</td>
				<td class="velikost5 tucne podtrzeni_D" width="23%">Popis</td>
				<td class="velikost5 tucne podtrzeni_D" width="25%">Pokladnica - pokladník</td>
				<td class="velikost5 tucne podtrzeni_D" width="19%">Homebanking</td>
				<td class="velikost5 tucne podtrzeni_D" width="9%">Primárny účet</td>
				<td class="velikost5 tucne podtrzeni_D" width="9%" align="right">Počiatočný stav</td>
				<td class="velikost5 tucne podtrzeni_D" width="5%">&#160;&#160;Mena</td>
			</tr>
		</xsl:if>

		<xsl:apply-templates select="BankUcetPokladna">
			<xsl:with-param name="Report" select="$Report"/>
		</xsl:apply-templates>

		<xsl:if test="$Pocet>0">
			<tr><td class="podtrzeni_N" colspan="7">&#160;</td></tr>
			<tr><td height="75"/></tr>										<!-- mezera -->
		</xsl:if>	

		<tr><td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->

		</tbody>
		</table>
	</xsl:template>


<!-- Bankovní účet nebo pokladna  -->
	<xsl:template match="BankUcetPokladna">
		<xsl:param name="Report"/>

	    <xsl:choose>
			<xsl:when test="$Report='Ne' ">
				<tr>
					<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" colspan="2">
						    <xsl:choose>
								<xsl:when test="string-length(Ucet)>0 and string-length(BKod)>0">
									<xsl:value-of select="Ucet"/> / <xsl:value-of select="BKod"/>
								</xsl:when>
								<xsl:when test="string-length(Ucet)>0">
									<xsl:value-of select="Ucet"/>
								</xsl:when>
								<xsl:otherwise><xsl:value-of select="BKod"/></xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="Pokladni"/>&#160;
					</td>
					<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PrimUcet"/>&#160;</td>
					<td class="velikost5 podtrzeni_NT" align="right">
						    <xsl:choose>
								<xsl:when test="string-length(PocStav)>0 "><xsl:value-of select="format-number(PocStav,'#,##0.00')" /></xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
						    </xsl:choose>
					</td>
					<td class="velikost5 podtrzeni_NT">&#160;&#160;<xsl:value-of select="Mena"/></td>
				</tr>
				<xsl:if test="string-length(BNazev)>0 or string-length(HBNazev)>0">
					<tr>
						<td colspan="2"/>
						<td class="velikost5"><xsl:value-of select="BNazev"/>&#160;</td>
						<td class="velikost5" colspan="4"><xsl:value-of select="HBNazev"/>&#160;</td>
					</tr>
				</xsl:if>
				<xsl:if test="string-length(Pozn)>0">
					<tr>
						<td class="velikost7 kurziva zarovnani_N" height="15" colspan="7">&#160;&#160;<xsl:value-of select="Pozn" /></td>
					</tr>
				</xsl:if>
			</xsl:when>
		      <xsl:otherwise>											<!-- Data z Reportu -->
				<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>

						<td class="velikost1 tucne zarovnani_N" colspan="7" height="35">
						    <xsl:choose>
								<xsl:when test="UcPokl='U' ">Bankový účet</xsl:when>
								<xsl:when test="UcPokl='P' ">Pokladnica</xsl:when>
								<xsl:otherwise>&#160;</xsl:otherwise>
						    </xsl:choose>
						</td>
					</tr>

					<tr>
						<td class="velikost5 tucne podtrzeni_D" height="20" width="10%">Zkratka</td>
						<td class="velikost5 tucne podtrzeni_D" width="23%">Popis</td>
						<td class="velikost5 tucne podtrzeni_D" width="25%">
							    <xsl:choose>
									<xsl:when test="UcPokl='U' ">Účet - číslo účtu, peňažný ústav</xsl:when>
									<xsl:when test="UcPokl='P' ">Pokladnica - pokladník</xsl:when>
									<xsl:otherwise>&#160;</xsl:otherwise>
							    </xsl:choose>
						</td>
						<td class="velikost5 tucne podtrzeni_D" width="19%">
							    <xsl:choose>
									<xsl:when test="UcPokl='U' ">Homebanking</xsl:when>
									<xsl:when test="UcPokl='P' ">&#160;</xsl:when>
									<xsl:otherwise>&#160;</xsl:otherwise>
							    </xsl:choose>
						</td>
						<td class="velikost5 tucne podtrzeni_D" width="9%">Primárny účet</td>
						<td class="velikost5 tucne podtrzeni_D" width="9%" align="right">Počiatočný stav</td>
						<td class="velikost5 tucne podtrzeni_D" width="5%">&#160;&#160;Mena</td>
					</tr>
					<tr>
						<td class="velikost5 podtrzeni_NT" height="20"><xsl:value-of select="Zkrat"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="Popis"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" colspan="2">
							    <xsl:choose>
									<xsl:when test="string-length(Ucet)>0 and string-length(BKod)>0">
										<xsl:value-of select="Ucet"/> / <xsl:value-of select="BKod"/>
									</xsl:when>
									<xsl:when test="string-length(Ucet)>0">
										<xsl:value-of select="Ucet"/>
									</xsl:when>
									<xsl:otherwise><xsl:value-of select="BKod"/></xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="Pokladni"/>&#160;
						</td>
						<td class="velikost5 podtrzeni_NT"><xsl:value-of select="PrimUcet"/>&#160;</td>
						<td class="velikost5 podtrzeni_NT" align="right">
							    <xsl:choose>
									<xsl:when test="string-length(PocStav)>0 "><xsl:value-of select="format-number(PocStav,'#,##0.00')" /></xsl:when>
									<xsl:otherwise>&#160;</xsl:otherwise>
							    </xsl:choose>
						</td>
						<td class="velikost5 podtrzeni_NT">&#160;&#160;<xsl:value-of select="Mena"/></td>
					</tr>
					<xsl:if test="string-length(BNazev)>0 or string-length(HBNazev)>0">
						<tr>
							<td colspan="2"/>
							<td class="velikost5"><xsl:value-of select="BNazev"/>&#160;</td>
							<td class="velikost5" colspan="4"><xsl:value-of select="HBNazev"/>&#160;</td>
						</tr>
					</xsl:if>
					<xsl:if test="string-length(Pozn)>0">
						<tr>
							<td class="velikost7 kurziva zarovnani_N" height="15" colspan="7">&#160;&#160;<xsl:value-of select="Pozn" /></td>
						</tr>
					</xsl:if>
					<tr><td class="podtrzeni_N" colspan="7">&#160;</td></tr>
				</tbody>
				</table>
		      </xsl:otherwise>
	    </xsl:choose>
	</xsl:template>

</xsl:stylesheet>
