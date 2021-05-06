<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>

<!-- Transformační šablona náhledu pro zakázky ve tvaru HTML.
Autor: Marek Vykydal
 -->

	<xsl:template match="/">
		<html>
			<head>
				<title>Zákazka</title>
				<style><![CDATA[
					body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%;	color: black; }
					td {vertical-align: middle;}
	
						.pismo1 {font-family: "Wingdings";}
						.tucne {font-weight: bold;}

						.velikost1 {font-size: 120%;}
						.velikost2 {font-size: 100%;}
						.velikost3 {font-size: 80%;}
						.velikost4 {font-size: 75%}
						.velikost9 {font-size: 95%;}

						.zarovnani_N {vertical-align: top;}
						.zarovnani_D {vertical-align: bottom;}

						.podtrzeni_P {border-right: 1px solid black;}
						.podtrzeni_L {border-left: 1px solid black;}
						.podtrzeni_N {border-top: 1px solid black;}
						.podtrzeni_D {border-bottom: 1px solid black;}

						.podtrzeni_D3 {border-bottom: 3px solid black;}
						.podtrzeni_NT {border-top: 1px dotted black;}

						.odsad_P {padding-right: 5px;}
						.odsad_L {padding-left: 5px;}
						.odsad_N {padding-top: 5px;}
						.odsad_D {padding-bottom: 5px;}

						.radius {border-radius: 10px;}
					]]>
				</style>
			</head>
			<body>aaa
				<xsl:apply-templates></xsl:apply-templates>
			</body>
		</html>

	</xsl:template>


	<!-- hlavni element -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>


	<!-- seznam zakázek -->
	<xsl:template match="SeznamZakazka">
		<xsl:apply-templates>
			<xsl:with-param name="Pocet" select="count(Zakazka)"/>
		</xsl:apply-templates>
	</xsl:template>


	<!-- datumový formát výstupu -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum" />
		<xsl:variable name="den" select="substring($_datum, 9,2)"></xsl:variable>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"></xsl:variable>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"></xsl:variable>
		<xsl:variable name="datum" select="concat($den,'.',$mesic,'.',$rok)"></xsl:variable>
		<xsl:value-of select="$datum"></xsl:value-of>
	</xsl:template>


	<!-- zakázka -->
	<xsl:template match="Zakazka">
		<xsl:param name="Pocet"/>


      <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
 	     <tr><td class="velikost1 tucne podtrzeni_D3" height="27">Karta zákazky</td></tr>
      <table class="karta" width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">


      <!-- popis, zkratka -->
      <tr><td height="15"></td></tr>	

      <tr>
	      <td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
			<table width="100%">
			          <tr>
			          	<td class="velikost4 " width="50%">Popis:</td>
			          	<td class="velikost4 ">Skratka:</td>
			          </tr>
				   <tr><td height="5"/></tr>
			          <tr>
					<td class="velikost2 tucne"><xsl:value-of select="Nazev"/>&#160;</td>
					<td class="velikost2 tucne"><xsl:value-of select="Zkrat"/>&#160;</td>
			          </tr>
			</table>
	      </td>
      </tr>


      <!-- podrobné informace o zakázce -->
      <tr><td height="15"></td></tr>	

      <tr>
		<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%"  border="0" bordercolor="green">

	          		<xsl:if test="string-length(TypZak)>0">
			          <tr>
			          	<td class="velikost4 tucne" width="20%">Typ zákazky:</td>
			          	<td class="velikost4" width="30%">
						<xsl:choose>
							<xsl:when test="TypZak = 'O' ">Obchodná zákazka</xsl:when>
							<xsl:when test="TypZak = 'V' ">Výrobná zákazka</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>			          	
					</td>
				    </tr>
				</xsl:if>

		          <tr>
		          	<td class="velikost4 tucne" width="20%">Objednávka číslo:</td>
		          	<td class="velikost4" width="30%"><xsl:value-of select="CObjednavk"/></td>
	          		<xsl:if test="ObchPrip=1">
			          	<td class="velikost4 tucne" >Obchodný prípad pre firmu:</td>
			          	<td class="velikost4" colspan="3"><xsl:value-of select="DodOdb/Nazev"/></td>
				</xsl:if>
			    </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Druh zákazky:</td>
		          	<td class="velikost4"><xsl:value-of select="DruhZak"/></td>
		          	<td class="velikost4 tucne" width="20%">Stav zákazky:</td>
		          	<td class="velikost4" width="30%" >
					<xsl:choose>
						<xsl:when test="StavZak = 'B' ">Predbežná</xsl:when>
						<xsl:when test="StavZak = 'P' ">Plánovaná</xsl:when>
						<xsl:when test="StavZak = 'U' ">Uvolnená</xsl:when>
						<xsl:when test="StavZak = 'S' ">Zahájená</xsl:when>
						<xsl:when test="StavZak = 'K' ">Odovzdaná</xsl:when>
						<xsl:when test="StavZak = 'Z' ">Uzatvorená</xsl:when>
					</xsl:choose>		          	
		          	</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Zodpovedá:</td>
		          	<td class="velikost4 "><xsl:value-of select="OdpOs"/></td>
		          	<td class="velikost4 tucne" >Hodnotenie:</td>
		          	<td class="velikost4 " ><xsl:value-of select="Hodnoceni"/></td>
		          </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Plánované zahájenie:</td>
		          	<td class="velikost4">
		          		<xsl:if test="string-length(DatPlZah)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatPlZah"/></xsl:with-param>
							</xsl:call-template>
					</xsl:if>
		          	</td>
		          	<td class="velikost4 tucne">Plánované odovzdanie:</td>
		          	<td class="velikost4 ">
		          		<xsl:if test="string-length(DatPlPred)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatPlPred"/></xsl:with-param>
							</xsl:call-template>
					</xsl:if>
		          	</td>
		          </tr>
		
		          <tr>
		          	<td class="velikost4 tucne">Zahájené:</td>
		          	<td class="velikost4 ">
		          		<xsl:if test="string-length(DatZah)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatZah"/></xsl:with-param>
							</xsl:call-template>
					</xsl:if>
				</td>
		          	<td class="velikost4 tucne">Odovzdané:</td>
		          	<td class="velikost4 ">
		          		<xsl:if test="string-length(DatPred)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatPred"/></xsl:with-param>
							</xsl:call-template>
					</xsl:if>
				</td>
		          </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
			       <td class="velikost4 tucne" width="20%">Záruka do:</td>
		          	<td class="velikost4" width="30%">
		          		<xsl:if test="string-length(ZarukaDo)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="ZarukaDo"/></xsl:with-param>
							</xsl:call-template>
					</xsl:if>
				</td>
		          </tr>

		        </table>
	      </td>
	</tr>


      <!-- poznámka -->
	<xsl:if test="string-length(Pozn)>0">

	      <tr><td height="15"></td></tr>	
	      <tr><td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%">
		          
			          <tr>
			          	<td class="velikost4 tucne zarovnani_N" width="20%">Poznámka:</td>
			          	<td class="velikost4 zarovnani_N" width="80%" rowspan="3" ><xsl:value-of select="Pozn"/>&#160;</td>
			          </tr>
	
			          <tr><td>&#160;</td></tr>
			          <tr><td>&#160;</td></tr>
		        </table>
	      </td></tr>

	</xsl:if>


		<!-- mezera na konci karty -->
	      <tr><td height="75"></td></tr>	
	

		<!--<xsl:if test="position() != $Pocet ">	-->									<!-- jestliže se nejedná o poslední entitu -->
			<tr>	<td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->
		<!--</xsl:if>-->


      </table><!-- konec tabulky karty -->
    </table><!-- konec cele karty (vcetne nadpisu) -->

  </xsl:template>

</xsl:stylesheet>
