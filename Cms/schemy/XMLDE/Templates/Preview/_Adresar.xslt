<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2008 sp1 (http://www.altova.com) by Dusan Pesko (CIGLER SOFTWARE, a.s.) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- hlavni cast stranky -->
	<xsl:template match="/">
		<html>
			<head>
				<title>Adresár</title>
				<style><![CDATA[
					body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%;	color: black; }
					td {vertical-align: middle;}
	
						.pismo1 {font-family: "Wingdings";}
						.tucne {font-weight: bold;}

						.velikost1 {font-size: 120%;}
						.velikost2 {font-size: 100%;}
						.velikost3 {font-size: 80%;}
						.velikost4 {font-size: 75%}
						.velikost5 {font-size: 72%;}
						.velikost6 {font-size: 70%;}
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
						.odsad_L2 {padding-left: 10px;}
						.odsad_N {padding-top: 5px;}
						.odsad_D {padding-bottom: 5px;}

						.radius {border-radius: 10px;}
					]]></style>
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	<!-- hlavni element -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- seznam firem -->
	<xsl:template match="SeznamFirem">
		<xsl:apply-templates>
			<xsl:with-param name="Pocet" select="count(Firma)"/>
		</xsl:apply-templates>
	</xsl:template>
	<!-- karta firmy -->
	<xsl:template match="Firma">
		<xsl:param name="Pocet"/>
		<table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			<tr>
				<td class="velikost1 tucne podtrzeni_D3" height="27">Karta adresára</td>
			</tr>
			<table class="karta" width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
				<!-- obchodni jmeno -->
				<tr>
					<td height="15"/>
				</tr>
				<tr>
					<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
						<table width="100%">
							<tr>
								<td class="velikost4 tucne">Obchodné meno:</td>
							</tr>
							<tr>
								<td height="5"/>
							</tr>
							<tr>
								<td class="velikost2 tucne">
									<xsl:value-of select="ObchNazev"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost3 tucne">
									<xsl:value-of select="ObchAdresa/Ulice"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost3 tucne">
									<xsl:value-of select="ObchAdresa/PSC"/>&#160;&#160;<xsl:value-of select="ObchAdresa/Misto"/>
								</td>
							</tr>
							<tr>
								<td class="velikost3 tucne">
									<xsl:value-of select="ObchAdresa/Stat"/>&#160;</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- kontakty -->
				<tr>
					<td height="15"/>
				</tr>
				<tr>
					<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
						<table width="100%" border="0" bordercolor="green">
							<tr>
								<td class="velikost4 tucne" width="15%">Kód partnera:</td>
								<td class="velikost4" width="35%">
									<xsl:value-of select="KodPartn"/>&#160;</td>
								<td class="velikost4" width="50%">
									<xsl:if test="string-length(GUID)>0">
										<b>GUID:&#160;</b>
										<xsl:value-of select="GUID"/>
									</xsl:if>
								</td>
							</tr>
							<tr>
								<td colspan="3">&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">IČO:</td>
								<td class="velikost4 tucne">
									<xsl:value-of select="ICO"/>&#160;</td>
								<td class="velikost4 tucne">Prevádzkáreň:</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">IČ DPH:</td>
								<td class="velikost4 tucne">
									<xsl:value-of select="DIC"/>&#160;</td>
								<td class="velikost4">
									<xsl:value-of select="Nazev"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">DIČ:</td>
								<td class="velikost4 tucne">
									<xsl:value-of select="DICSK"/>&#160;</td>
								<td class="velikost4">
									<xsl:value-of select="Adresa/Ulice"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Tel:</td>
								<td class="velikost4">
									<xsl:value-of select="Tel/Pred"/>
									<xsl:if test="string-length(Tel/Cislo)>0">-</xsl:if>
									<xsl:value-of select="Tel/Cislo"/>&#160;
		          	</td>
								<td class="velikost4">
									<xsl:value-of select="Adresa/PSC"/>&#160;&#160;<xsl:value-of select="Adresa/Misto"/>
								</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Fax:</td>
								<td class="velikost4">
									<xsl:value-of select="Fax/Pred"/>
									<xsl:if test="string-length(Fax/Cislo)>0">-</xsl:if>
									<xsl:value-of select="Fax/Cislo"/>&#160;
				</td>
								<td class="velikost4">
									<xsl:value-of select="Adresa/Stat"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Mobil:</td>
								<td class="velikost4">
									<xsl:value-of select="Mobil/Pred"/>
									<xsl:if test="string-length(Mobil/Cislo)>0">-</xsl:if>
									<xsl:value-of select="Mobil/Cislo"/>&#160;
				</td>
								<td/>
							</tr>
							<tr>
								<td class="velikost4 tucne">e-mail:</td>
								<td class="velikost4">
									<xsl:value-of select="EMail"/>&#160;</td>
								<td/>
							</tr>
							<tr>
								<td class="velikost4 tucne">www:</td>
								<td class="velikost4">
									<xsl:value-of select="WWW"/>&#160;</td>
								<td class="velikost4 tucne">Fakturačná adresa:</td>
							</tr>
							<tr>
								<td colspan="2"/>
								<td class="velikost4">
									<xsl:value-of select="FaktNazev"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Účet:</td>
								<td class="velikost4">
									<xsl:value-of select="Ucet"/>
									<xsl:if test="string-length(KodBanky)>0">/</xsl:if>
									<xsl:value-of select="KodBanky"/>&#160;</td>
								<td class="velikost4">
									<xsl:value-of select="FaktAdresa/Ulice"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Banka:</td>
								<td class="velikost4">
									<xsl:value-of select="Banka"/>&#160;</td>
								<td class="velikost4">
									<xsl:value-of select="FaktAdresa/PSC"/>&#160;&#160;<xsl:value-of select="FaktAdresa/Misto"/>
								</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Var. symbol:</td>
								<td class="velikost4">
									<xsl:value-of select="VSymb"/>&#160;</td>
								<td class="velikost4">
									<xsl:value-of select="FaktAdresa/Stat"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Spec. symbol:</td>
								<td class="velikost4">
									<xsl:value-of select="SpecSym"/>&#160;</td>
								<td/>
							</tr>
						</table>
					</td>
				</tr>
				<!-- dph, posta... -->
				<tr>
					<td height="15"/>
				</tr>
				<tr>
					<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
						<table width="100%">
							<tr>
								<td width="20%" class="velikost4 tucne">Platiteľ DPH:</td>
								<td class="velikost4" colspan="2">
									<xsl:if test="string-length(PlatceDPH)>0">
										<xsl:if test="not(PlatceDPH=1)">nie je platiteľ DPH</xsl:if>
										<xsl:if test="PlatceDPH=1">je platiteľ DPH</xsl:if>&#160;
						</xsl:if>
								</td>
								<td width="20%" class="velikost4 tucne">Pošta:</td>
								<td class="velikost4" colspan="2">
									<xsl:if test="string-length(Mail)>0">
										<xsl:if test="not(Mail=1)">neposielať poštu</xsl:if>
										<xsl:if test="Mail=1">posielať poštu</xsl:if>&#160;
						</xsl:if>
								</td>
							</tr>
							<tr>
								<td colspan="6">&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Zľava pre doklady:</td>
								<td class="velikost9 pismo1" width="5%">
									<xsl:if test="string-length(FlagSleva)>0">
										<xsl:if test="not(FlagSleva=1)">&#168;</xsl:if>
										<xsl:if test="FlagSleva=1">&#254;</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4">
									<xsl:if test="string-length(FlagSleva)>0">
										<xsl:if test="not(FlagSleva=1)">0.00&#160;&#37;</xsl:if>
										<xsl:if test="FlagSleva=1">
											<xsl:value-of select="format-number(Sleva,'#,##0.00')"/>&#160;&#37;</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4 tucne">Splatnosť pohľadávok:</td>
								<td class="velikost9 pismo1" width="5%">
									<xsl:if test="string-length(SplatPoh)>0">
										<xsl:if test="not(SplatPoh=1)">&#168;</xsl:if>
										<xsl:if test="SplatPoh=1">&#254;</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4">
									<xsl:if test="string-length(SplatPoh)>0">
										<xsl:if test="not(SplatPoh=1)">0&#160;dní</xsl:if>
										<xsl:if test="SplatPoh=1">
											<xsl:value-of select="SplPohDni"/>&#160;dní</xsl:if>
									</xsl:if>
								</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Sledovať kredit:</td>
								<td class="velikost9 pismo1">
									<xsl:if test="string-length(Kredit)>0">
										<xsl:if test="not(Kredit=1)">&#168;</xsl:if>
										<xsl:if test="Kredit=1">&#254;</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4">
									<xsl:if test="string-length(Kredit)>0">
										<xsl:if test="not(Kredit=1)">0.00</xsl:if>
										<xsl:if test="Kredit=1">
											<xsl:value-of select="format-number (KreditVal,'#,##0.00')"/>
										</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4 tucne">Splatnosť záväzkov:</td>
								<td class="velikost9 pismo1">
									<xsl:if test="string-length(SplatZav)>0">
										<xsl:if test="not(SplatZav=1)">&#168;</xsl:if>
										<xsl:if test="SplatZav=1">&#254;</xsl:if>
									</xsl:if>
								</td>
								<td class="velikost4">
									<xsl:if test="string-length(SplatZav)>0">
										<xsl:if test="not(SplatZav=1)">0&#160;dní</xsl:if>
										<xsl:if test="SplatZav=1">
											<xsl:value-of select="SplZavDni"/>&#160;dní</xsl:if>
									</xsl:if>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- adr. klice, ceny, ceniky... -->
				<tr>
					<td height="15"/>
				</tr>
				<tr>
					<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
						<table width="100%">
							<tr>
								<td class="velikost4 tucne" width="20%">Adresné kľúče:</td>
								<td class="velikost4" width="80%">
									<xsl:value-of select="AdrKlice"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Ceny:</td>
								<td class="velikost4">
									<xsl:value-of select="Ceny"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Cenníky:</td>
								<td class="velikost4">
									<xsl:value-of select="Ceniky"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Činnosti:</td>
								<td class="velikost4">
									<xsl:value-of select="Cinnosti"/>&#160;</td>
							</tr>
						</table>
					</td>
				</tr>
				<!-- zprava, poznamka -->
				<tr>
					<td height="15"/>
				</tr>
				<tr>
					<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
						<table width="100%">
							<tr>
								<td class="velikost4 tucne" width="20%">Správa:</td>
								<td class="velikost4" width="80%">
									<xsl:value-of select="Zprava"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne zarovnani_N">Poznámka:</td>
								<td class="velikost4 zarovnani_N" rowspan="3">
									<xsl:value-of select="Poznamka"/>&#160;</td>
							</tr>
							<tr>
								<td>&#160;</td>
							</tr>
							<tr>
								<td>&#160;</td>
							</tr>
						</table>
					</td>
				</tr>

				<!-- seznam kontaktních osob -->
				<xsl:if test="count(Osoba)>0">
					<tr>
						<td height="25"/>
					</tr>
					<tr>
						<td>
							<table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
								<tr>
									<td class="velikost2 tucne" colspan="3">Zoznam kontaktných osôb</td>
								</tr>
								<tr>
									<td height="5"/>
								</tr>
								<tr>
									<td class="velikost4 tucne odsad_L podtrzeni_D" width="50%" height="23">Kontaktná osoba</td>
									<td class="velikost4 tucne podtrzeni_D" width="25%">Kód partnera (EAN)</td>
									<td class="velikost4 tucne podtrzeni_D" width="25%" align="center">Konateľ / zamestnanec</td>
								</tr>
								<xsl:for-each select="Osoba">
									<xsl:call-template name="Osoba"/>
								</xsl:for-each>

								<tr>
									<td class="podtrzeni_N" colspan="3">&#160;</td>
								</tr>
							</table>
						</td>
					</tr>
				</xsl:if>

				<!-- seznam dalších provozoven -->      
					<xsl:if test="count(SeznamProvozoven/Provozovna)>0">	

							<xsl:choose>
								 <xsl:when test="count(Osoba)=0">
									  <tr><td height="25"></td></tr>
								 </xsl:when>
								 <xsl:otherwise>
									  <tr><td height="12"></td></tr>
								 </xsl:otherwise>
							</xsl:choose>

						  <tr>
							  <td>
								<table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
									  <tr>
										<td class="velikost2 tucne" colspan="3">Seznam dalších provozoven</td>
									  </tr>
				
								   <tr><td height="5"/></tr>
									  
									  <tr>
										<td class="velikost4 tucne odsad_L podtrzeni_D" width="50%" height="23">Název</td>
										<td class="velikost4 tucne podtrzeni_D" width="50%">Adresa</td>
									  </tr>
					
									  <xsl:for-each select="SeznamProvozoven/Provozovna"><xsl:call-template name="Provozovna"/></xsl:for-each>
					
								   <tr>
									<td class="podtrzeni_N" colspan="3">&#160;</td>
								   </tr>
					
								</table>
							</td>
						  </tr>
					</xsl:if>

				<!-- mezera na konci karty -->
				<tr>
					<td height="50"/>
				</tr>
				<!--<xsl:if test="position() != $Pocet ">	-->
				<!-- jestliže se nejedná o poslední entitu -->
				<tr>
					<td>&#160;<div style="page-break-after: always"/>
					</td>
				</tr>
				<!-- přechod na novou stranu -->
				<!--</xsl:if>-->
			</table>
			<!-- konec tabulky karty -->
		</table>
		<!-- konec cele karty (vcetne nadpisu) -->
	</xsl:template>


	<!-- kontaktni osoby -->
	<xsl:template name="Osoba">
		<tr>
			<td class="velikost4 odsad_L podtrzeni_NT" height="23">
				<xsl:value-of select="Prijmeni"/>&#160;
	      		<xsl:value-of select="Jmeno"/>
				<xsl:if test="TitulPred">,&#160;<xsl:value-of select="TitulPred"/>
				</xsl:if>
				<xsl:if test="TitulZa">,&#160;<xsl:value-of select="TitulZa"/>
				</xsl:if>
			</td>
			<td class="velikost4 podtrzeni_NT">
				<xsl:value-of select="KodPartn"/>&#160;</td>
			<td class="velikost9 pismo1 podtrzeni_NT" align="center">
				<xsl:if test="not(Jednatel=1)">&#168;</xsl:if>
				<xsl:if test="Jednatel=1">&#254;</xsl:if>
			</td>
		</tr>
	</xsl:template>


	<!-- Další provozovna -->
	<xsl:template name="Provozovna">

		<tr>
			<td class="velikost4 odsad_L podtrzeni_NT" height="23">
				<xsl:value-of select="Adresa/Nazev"/>&#160;
			</td>
	
			<td class="velikost4 podtrzeni_NT">
				<xsl:value-of select="Adresa/Ulice"/>
				<xsl:if test="(string-length(Adresa/Ulice)>0) and ((string-length(Adresa/Misto)>0) or (string-length(Adresa/PSC)>0))">, </xsl:if>
				<xsl:value-of select="Adresa/PSC"/>&#160;&#160;<xsl:value-of select="Adresa/Misto"/>
			</td>
		</tr>

			<!-- kontaktní osoby k další provozovně -->
			<xsl:if test="count(SeznamOsob/Osoba)>0">	
			
				<tr>
					<td colspan="2">
						<table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
							<xsl:for-each select="SeznamOsob/Osoba">
								<tr>
									<td class="velikost6 odsad_L2 kurziva" height="18">
										<xsl:value-of select="Prijmeni"/>&#160;<xsl:value-of select="Jmeno"/><xsl:if test="Jednatel=1"> (jednatel)</xsl:if>
									</td>
								</tr>
							</xsl:for-each>
						</table>
					</td>
				</tr>
			</xsl:if>

	</xsl:template>


</xsl:stylesheet>
