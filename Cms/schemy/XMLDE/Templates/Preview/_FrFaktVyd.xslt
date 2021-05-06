<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Transformační šablona náhledu pro faktury vydané ve tvaru HTML. Doklad se zobrazuje jako náhled dokladu před tiskem.- SK lokalizácia
Autor: Marek Vykydal
 -->

	<xsl:import href="_Doklady.xslt"/>
	<xsl:output method="xml" encoding="UTF-8" />  

	<xsl:template match="/">
		<html>
			<head>
				<title>Faktúra vystavená</title>
				<style><![CDATA[
					body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%;	color: black; }
					td {vertical-align: middle;}

						.pozadi1 {background-color: #D3D3D3;}
						.pozadi2 {background-color: #000;}
						.pismo1 {font-family: "Wingdings";}
						.barvapisma {color: #FFFFFF;}
						.tucne {font-weight: bold;}
						.kurziva {font-style: italic;}

						.velikost1 {font-size: 120%;}
						.velikost2 {font-size: 100%;}
						.velikost3 {font-size: 80%;}
						.velikost4 {font-size: 75%}
						.velikost5 {font-size: 72%;}
						.velikost6 {font-size: 70%;}
						.velikost7 {font-size: 60%;}
						.velikost8 {font-size: 20%;}
						.velikost9 {font-size: 95%;}

						.zarovnani_N {vertical-align: top;}
						.zarovnani_D {vertical-align: bottom;}

						.podtrzeni_P {border-right: 1px solid black;}
						.podtrzeni_L {border-left: 1px solid black;}
						.podtrzeni_N {border-top: 1px solid black;}
						.podtrzeni_D {border-bottom: 1px solid black;}

						.podtrzeni_P3 {border-right: 3px solid black;}
						.podtrzeni_L3 {border-left: 3px solid black;}
						.podtrzeni_N3 {border-top: 3px solid black;}
						.podtrzeni_D3 {border-bottom: 3px solid black;}

						.podtrzeni_NT {border-top: 1px dotted black;}
					   ]]>
				</style>
			</head>
			<body>
				<xsl:apply-templates></xsl:apply-templates>
			</body>
		</html>
	</xsl:template>
	

	<!-- -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	

	<!-- -->
	<xsl:template match="SeznamFaktVyd | SeznamFaktVyd_DPP">
		<xsl:apply-templates select="FaktVyd | FaktVyd_DPP">
			<xsl:with-param name="Pocet" select="count(FaktVyd | FaktVyd_DPP)"/>
		</xsl:apply-templates>
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
	



<!-- Položky normální faktury - přechod na element SklPolozka pro potřeby rekurzivního volání podřízených položek -->
	<xsl:template match="SklPolozka">
		<xsl:param name="Druh"/>
		<xsl:param name="Mena"/>
		<xsl:param name="TypKartyNadr"/>
		<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
			<xsl:with-param name="Mena" select="$Mena"/>
			<xsl:with-param name="Druh" select="$Druh"/>
			<xsl:with-param name="TypKartyNadr" select="$TypKartyNadr"/>
		</xsl:apply-templates>
	</xsl:template>



<!-- Položky faktury - podřízené -->
	<xsl:template match="Slozeni/SubPolozka/Polozka">
		<xsl:param name="Druh"/>
		<xsl:param name="Mena"/>
		<xsl:param name="TypKartyNadr"/>
	
		<xsl:variable name="TypKarty">
			<xsl:value-of select="SklPolozka/KmKarta/TypKarty" />
			<xsl:value-of select="KmKarta/TypKarty" />
		</xsl:variable>

				<tr>
					<td height="23"  width="2%">-</td>
					<td class="velikost5 " align="left" colspan="2">
						<xsl:value-of select="Nazev"/><xsl:value-of select="Popis"/>&#160;
					</td>
		
					<td class="velikost5 " align="left">
						<xsl:value-of select="SklPolozka/KmKarta/Katalog" />
						<xsl:value-of select="KmKarta/Katalog" />
						<xsl:value-of select="NesklPolozka/Katalog" />
						&#160;
					</td>
			
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="string-length(PocetMJ)>0">
							<xsl:value-of select="format-number(PocetMJ, '#,##0.00')" />
						</xsl:if>
					</td>							
		
					<td class="velikost5 " align="left">&#160;
						<xsl:value-of select="SklPolozka/KmKarta/MJ" />
						<xsl:value-of select="KmKarta/MJ" />
						<xsl:value-of select="NesklPolozka/MJ" />
					</td>
					
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="($TypKarty != 'sada') and ($TypKartyNadr != 'komplet')">
							<xsl:choose>
								<xsl:when test="string-length($Mena)>0 and string-length(Valuty)>0">
									<xsl:value-of select="format-number(Valuty, '#,##0.00')" />
								</xsl:when>
								<xsl:when test="string-length($Mena)=0 and string-length(Cena)>0">
									<xsl:value-of select="format-number(Cena, '#,##0.00')" />
								</xsl:when>
							</xsl:choose>
						</xsl:if>
					</td>
		
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="($TypKarty != 'sada') and ($TypKartyNadr != 'komplet')">
							<xsl:value-of select="DPH" /><xsl:value-of select="SazbaDPH" />&#160;%
						</xsl:if>					
					</td>
					
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="($TypKarty != 'sada') and ($TypKartyNadr != 'komplet')">
							<xsl:if test="CenaTyp='0' or TypCeny='0' ">bez DPH</xsl:if>
							<xsl:if test="CenaTyp='1'  or TypCeny='1' ">s DPH</xsl:if>
							<xsl:if test="CenaTyp='2'  or TypCeny='2' ">len DPH</xsl:if>
							<xsl:if test="CenaTyp='3'  or TypCeny='3' ">len základ</xsl:if>
						</xsl:if>
					</td>
				</tr>
		
				<xsl:if test="string-length(Poznamka)>0">
					<tr>
						<td height="15"/>
						<td class="velikost7 kurziva zarovnani_N" colspan="8">
							<xsl:value-of select="Poznamka" />
						</td>
					</tr>
				</xsl:if>
		
				<xsl:if test="count(SeznamVC/VyrobniCislo)>0">
					<xsl:for-each select="SeznamVC/VyrobniCislo">
						<tr>
							<td height="15"/>
							<td class="velikost5" width="2%">-</td>
							<td class="velikost6 kurziva" colspan="7"><xsl:value-of select="VyrobniCis"/></td>
						</tr>
					</xsl:for-each>
				</xsl:if>

				<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
					<xsl:with-param name="Druh" select="$Druh"/>
					<xsl:with-param name="TypKartyNadr">
							<xsl:choose>
								<xsl:when test="$TypKartyNadr = 'komplet' ">
									<xsl:value-of select="$TypKartyNadr" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$TypKarty" />
								</xsl:otherwise>
							</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>

	</xsl:template>




<!-- Faktura  vydaná  -->
	<xsl:template match="FaktVyd | FaktVyd_DPP">
		<xsl:param name="Druh" select="name()"/>
		<xsl:param name="Pocet"/>
		<xsl:param name="Mena" select="Valuty/Mena/Kod"/>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

			<!-- naše firma -->
			<tr>
				<td colspan="3">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td height="20" class="velikost2 tucne"  colspan="8"><xsl:value-of select="MojeFirma/Nazev"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost3 tucne zarovnani_N" width="28%" >
										<xsl:value-of select="MojeFirma/ObchAdresa/Ulice" />&#160;<br/>
										<xsl:value-of select="MojeFirma/ObchAdresa/PSC" />&#160;&#160;
										<xsl:value-of select="MojeFirma/ObchAdresa/Misto" /><br/>
										<xsl:value-of select="MojeFirma/ObchAdresa/Stat"/>&#160;
								</td>
								<td class="velikost3 tucne zarovnani_N" align="right" width="5%">IČO:<br/>IČ DPH:<br/>DIČ:
              </td>
								<td class="velikost3 tucne zarovnani_N" width="13%">
										&#160;&#160;<xsl:value-of select="MojeFirma/ICO" /><br/>
										&#160;&#160;<xsl:value-of select="MojeFirma/DIC" /><br/>
                    &#160;&#160;<xsl:value-of select="MojeFirma/DanIC" />
								</td>
		
								<td class="velikost7 zarovnani_N" align="right" width="6%">mobil:<br/>www:<br/>e-mail:</td>
								<td class="velikost7 zarovnani_N" width="14%">
										&#160;&#160;<xsl:value-of select="MojeFirma/Mobil/Pred"/><xsl:if test="string-length(MojeFirma/Mobil/Pred)>0 ">-</xsl:if>
										<xsl:value-of select="MojeFirma/Mobil/Cislo"/><br/>
										&#160;&#160;<xsl:value-of select="MojeFirma/WWW"/><br/>
										&#160;&#160;<xsl:value-of select="MojeFirma/EMail" />
								</td>
								<td class="velikost7 zarovnani_N" align="right" width="6%">tel:<br/>fax:</td>
								<td class="velikost7 zarovnani_N" width="30%">
										&#160;&#160;<xsl:value-of select="MojeFirma/Tel/Pred"/><xsl:if test="string-length(MojeFirma/Tel/Pred)>0 ">-</xsl:if>
										<xsl:value-of select="MojeFirma/Tel/Cislo"/>
										<xsl:if test="string-length(MojeFirma/Tel/Klap)>0 ">/</xsl:if>
										<xsl:value-of select="MojeFirma/Tel/Klap"/><br/>

										&#160;&#160;<xsl:value-of select="MojeFirma/Fax/Pred"/><xsl:if test="string-length(MojeFirma/Fax/Pred)>0 ">-</xsl:if>
										<xsl:value-of select="MojeFirma/Fax/Cislo"/>
										<xsl:if test="string-length(MojeFirma/Fax/Klap)>0 ">/</xsl:if>
										<xsl:value-of select="MojeFirma/Fax/Klap"/>
								</td>
								<td class="velikost7 zarovnani_N">&#160;</td>
							</tr>
							<tr>
								<td height="5" colspan="8"></td>
							</tr>
						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- nadpis dokladu -->
				<td class="zarovnani_N" width="48.5%">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost1 tucne podtrzeni_N3" align="left" height="32">
									<xsl:choose>
										<xsl:when test="Druh='D'">Faktúra k prijatej platbe</xsl:when>
										<xsl:when test="Druh='L' or Druh='Z' ">Zálohová faktúra vystavená</xsl:when>
										<xsl:when test="Druh='F' or Druh='P' ">Proforma faktúra vystavená</xsl:when>
										<xsl:when test="Druh='N' and Dobropis='1' ">Faktúra vystavená - dobropis</xsl:when>
										<xsl:otherwise>Faktúra vystavená</xsl:otherwise>								
									</xsl:choose>
								</td>
							</tr>
						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td class="podtrzeni_N3" width="3%">&#160;</td>

				<!-- objednávka, odběratel -->
				<td class="zarovnani_N" rowspan="2">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>

							<tr>
								<td class="podtrzeni_N3">&#160;</td>
								<td class="velikost1 tucne podtrzeni_N3 podtrzeni_D podtrzeni_L podtrzeni_P"  height="32" align="center" colspan="2" width="40%">
									<xsl:value-of select="Doklad"/>&#160;
								</td>
							</tr>

							<tr>
								<td class="velikost4 tucne">Objednávka:</td>
								<td class="velikost3 tucne pozadi1" align="center" colspan="2"><xsl:value-of select="CObjednavk"/></td>
							</tr>
							
							<tr>	<td height="5" colspan="3"></td></tr>
							<tr>	<td class="velikost4 tucne podtrzeni_D" colspan="3">Odberateľ</td></tr>

							<tr>	<td height="20" colspan="3"></td></tr>

							<tr>
								<td class="velikost2 tucne" colspan="3">
									<xsl:value-of select="DodOdb/ObchNazev" />&#160;
								</td>
							</tr>

							<tr>	<td height="20" colspan="3"></td></tr>

							<tr>
								<td class="velikost3 tucne" colspan="3">
									<xsl:if test="DodOdb/Nazev != DodOdb/ObchNazev"><xsl:value-of select="DodOdb/Nazev" /></xsl:if>&#160;<br/>
									<xsl:value-of select="DodOdb/ObchAdresa/Ulice" />&#160;<br/>
									<xsl:value-of select="DodOdb/ObchAdresa/PSC" />&#160;&#160;
									<xsl:value-of select="DodOdb/ObchAdresa/Misto" /><br/>
									<xsl:value-of select="DodOdb/ObchAdresa/Stat"/>&#160;
								</td>
							</tr>
								
							<tr>	<td class="podtrzeni_D" height="20" colspan="3">&#160;</td></tr>	

						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- platba, doprava + popoisek "Datum" a "Symbol" -->
				<td class="zarovnani_D">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4 tucne">
									<xsl:if test="Druh!='D' ">Platba:</xsl:if>
								</td>
								<td/>
								<td class="velikost4" colspan="2">
									<xsl:if test="Druh!='D' "><xsl:value-of select="Uhrada"/>&#160;</xsl:if>
								</td>
								<td class="velikost9 pismo1 tucne" align="center"><!-- <xsl:if test="Dobropis=1 ">ţ</xsl:if> --></td>
								<td class="velikost4 tucne" colspan="4"><!-- xsl:if test="Dobropis=1 ">Opravný daňový doklad</xsl:if> --></td>
							</tr>
							<tr>
								<td class="velikost4 tucne">
									<xsl:if test="Druh!='D' ">Doprava:</xsl:if>
								</td>
								<td/>
								<td class="velikost4" colspan="7">
									<xsl:if test="Druh!='D' "><xsl:value-of select="ZpDopravy"/>&#160;</xsl:if>
								</td>
							</tr>

							<tr>
								<td height="10" colspan="9"></td>
							</tr>

							<tr>
								<td class="velikost4 tucne podtrzeni_D" width="16%">Dátum</td>
								<td class="podtrzeni_D" width="2%">&#160;</td>
								<td  class="podtrzeni_D" width="16%">&#160;</td>
								<td width="10%"/>
								<td class="velikost4 tucne podtrzeni_D" width="17%" colspan="2">Symbol</td>
								<td class="podtrzeni_D" width="2%">&#160;</td>
								<td  class="podtrzeni_D" width="16%">&#160;</td>
								<td width="20%"/>
							</tr>


						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- datumové pole, symboly, bankovní účet -->
				<td class="zarovnani_N" rowspan="2">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4" height="17" align="right" width="16%">vystavenia:</td>
								<td width="2%"/>
								<td class="velikost4" align="center" width="16%">
									<xsl:if test="string-length(Vystaveno)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum"><xsl:value-of select="Vystaveno"/></xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td width="10%"/>
								<td class="velikost4" align="right" width="17%">konštantný:</td>
								<td width="2%"/>
								<td class="velikost4" width="16%">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">&#160;&#160;<xsl:value-of select="KonstSym" /></xsl:when>
										<xsl:otherwise>-</xsl:otherwise>
									</xsl:choose>
								</td>
								<td width="20%"/>
							</tr>
							<tr>
								<td height="17" class="velikost4 tucne" align="right">splatnosti:</td>
								<td/>
								<td class="velikost4 tucne pozadi1" align="center">
									<xsl:choose>
										<xsl:when test="string-length(Splatno)>0 ">
											<xsl:call-template name="_datum_">
												<xsl:with-param name="_datum"><xsl:value-of select="Splatno"/></xsl:with-param>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>-</xsl:otherwise>
									</xsl:choose>
								</td>
								<td/>
								<td class="velikost4 tucne" align="right">variabilný:</td>
								<td/>
								<td class="velikost4 tucne pozadi1" colspan="2">&#160;&#160;<xsl:value-of select="VarSymbol" /></td>
							</tr>
							<tr>
								<td class="velikost4 " height="17" align="right">
									<xsl:choose>
										<xsl:when test="Druh='N' or Druh='Z' or Druh='P' ">dodania:</xsl:when>
										<xsl:when test="(Druh='L' or Druh='F') and (Vyrizeno!='') ">vybavenia:</xsl:when>
										<xsl:when test="string-length(PlnenoDPH)>0">dodania:</xsl:when>							
									</xsl:choose>
								</td>
								<td/>
								<td class="velikost4" align="center">
									<xsl:choose>
										<xsl:when test="Druh='N' or Druh='Z' or Druh='P' ">
											<xsl:call-template name="_datum_">
												<xsl:with-param name="_datum">
													<xsl:value-of select="PlnenoDPH" />
												</xsl:with-param>
											</xsl:call-template>
										</xsl:when>

										<xsl:when test="(Druh='L' or Druh='F') and (Vyrizeno!='') ">																				<xsl:call-template name="_datum_">
												<xsl:with-param name="_datum">
													<xsl:value-of select="Vyrizeno" />
												</xsl:with-param>
											</xsl:call-template>
										</xsl:when>

										<xsl:when test="string-length(PlnenoDPH)>0">
											<xsl:call-template name="_datum_">
												<xsl:with-param name="_datum">
													<xsl:value-of select="PlnenoDPH"/>
												</xsl:with-param>
											</xsl:call-template>
										</xsl:when>
									</xsl:choose>
								</td>

								<td/>
								<td class="velikost4" align="right">špecifický:</td>
								<td/>
								<td class="velikost4" colspan="2">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">&#160;&#160;<xsl:value-of select="SpecSymbol" /></xsl:when>
										<xsl:otherwise>-</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>

							<tr>
								<td height="10" colspan="8"></td>
							</tr>

							<!-- bankovní účet -->
							<tr>
								<xsl:choose>
									<xsl:when test="Druh!='D' ">
										<td class="velikost3 tucne pozadi1" colspan="3">Bankový účet</td>
										<td/>
										<td class="velikost3 tucne" align="right" colspan="4"><xsl:value-of select="MojeFirma/Banka"/></td>
									</xsl:when>
									<xsl:otherwise><td/><td/><td/></xsl:otherwise>
								</xsl:choose>
							</tr>

							<tr>
								<xsl:choose>
									<xsl:when test="Druh!='D' ">
										<td class="velikost2 tucne podtrzeni_N3 podtrzeni_D3 podtrzeni_P3 podtrzeni_L3" align="center" colspan="5">
											<xsl:value-of select="MojeFirma/Ucet"/>
											<xsl:if test="string-length(MojeFirma/Ucet)=0">&#160;</xsl:if>
										</td>
										<td/>
										<td class="velikost2 tucne podtrzeni_N3 podtrzeni_D3 podtrzeni_P3 podtrzeni_L3" align="center" colspan="2">
											<xsl:value-of select="MojeFirma/KodBanky"/>
											<xsl:if test="string-length(MojeFirma/KodBanky)=0">&#160;</xsl:if>
										</td>
									</xsl:when>
									<xsl:otherwise><td/><td/><td/></xsl:otherwise>
								</xsl:choose>
							</tr>
						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td rowspan="3"/>

				<!-- popisek "Konečný příjemce" + odběratel - IČ, DIČ -->
				<td class="zarovnani_N">
					<xsl:if test="Druh!='D' ">				<!-- nejedná se o daňový doklad -->
						<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
							<tbody>
	
								<tr>
									<td class="velikost4 tucne" rowspan="3">Konečný príjemca</td>
									<td class="velikost4 zarovnani_D" align="right" height="17" width="10%">IČO:</td>
									<td class="velikost4 zarovnani_D" width="30%">&#160;&#160;<xsl:value-of select="DodOdb/ICO" /></td>
								</tr>
	
								<tr>
									<td class="velikost4 zarovnani_D" align="right">IČ DPH:</td>
									<td class="velikost4 zarovnani_D">&#160;&#160;<xsl:value-of select="DodOdb/DIC" /></td>
								</tr>
                <tr>
                  <td class="velikost4 zarovnani_D" align="right">DIČ:</td>
                  <td class="velikost4 zarovnani_D">
                    &#160;&#160;<xsl:value-of select="DodOdb/DICSK" />
                  </td>
                </tr>
							</tbody>
						</table>
					</xsl:if>
				</td>
			</tr>

			<tr>
				<!-- konečný příjemce - adresa -->
				<td class="zarovnani_D">
					<xsl:if test="Druh!='D' ">				<!-- nejedná se o daňový doklad -->
						<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
							<tbody>
								<tr>
									<td class="velikost4">
										<xsl:choose>
											<xsl:when test="string-length(KonecPrij/Nazev)>0">
												<xsl:value-of select="KonecPrij/Nazev" />&#160;<br/>
												<xsl:value-of select="KonecPrij/Adresa/Ulice"/>&#160;<br/>
												<xsl:value-of select="KonecPrij/Adresa/PSC"/>&#160;&#160;<xsl:value-of select="KonecPrij/Adresa/Misto" /><br/>
												<xsl:value-of select="KonecPrij/Adresa/Stat"/>&#160;							
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="DodOdb/ObchNazev" />&#160;<br/>
												<xsl:value-of select="DodOdb/ObchAdresa/Ulice"/>&#160;<br/>
												<xsl:value-of select="DodOdb/ObchAdresa/PSC"/>&#160;&#160;<xsl:value-of select="DodOdb/ObchAdresa/Misto" />												<br/>
												<xsl:value-of select="DodOdb/ObchAdresa/Stat"/>&#160;
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</tr>
	
							</tbody>
						</table>
					</xsl:if>
				</td>
			</tr>


			<tr>
			<!-- text před cenami  -->
				<td colspan="3">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost8 podtrzeni_D" width="2%">&#160;</td>
								<td width="98%"/>
							</tr>

							<xsl:if test="string-length(TextPredFa)>0 ">
								<tr><td class="velikost6 zarovnani_D kurziva" height="20" colspan="2"><xsl:value-of select="TextPredFa"/></td></tr>
							</xsl:if>

							<tr><td height="6" colspan="2"/></tr>

						</tbody>
					</table>
				</td>
			</tr>


			<tr>
			<!-- položky dokladu -->
				<td colspan="3">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>

							<xsl:if test="SeznamPolozek/Polozka | SeznamZalPolozek/Polozka">
							<tr><td height="14" colspan="9"/></tr>
							<tr>
								<td class="velikost5 tucne podtrzeni_D" height="21" align="left" colspan="3" width="35%">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">Označenie dodávky</xsl:when>
										<xsl:otherwise>Popis položky</xsl:otherwise>
									</xsl:choose>
								</td>								
								<td class="velikost5 tucne podtrzeni_D" align="left">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">Katalóg</xsl:when>
										<xsl:otherwise>&#160;</xsl:otherwise>
									</xsl:choose>
								</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">Počet</xsl:when>
										<xsl:otherwise>&#160;</xsl:otherwise>
									</xsl:choose>
								</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">&#160; m. j.</xsl:when>
										<xsl:otherwise>&#160;</xsl:otherwise>
									</xsl:choose>
								</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">
									<xsl:choose>
										<xsl:when test="Druh!='D' ">Cena za m. j.</xsl:when>
										<xsl:otherwise>Cena spolu</xsl:otherwise>
									</xsl:choose>
								</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Sadzba</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Typ ceny</td>
							</tr>
							</xsl:if>

							<!-- položky normální faktury -->
								<xsl:for-each select="SeznamPolozek/Polozka">
									<xsl:variable name="TypKarty">
										<xsl:value-of select="SklPolozka/KmKarta/TypKarty" />
										<xsl:value-of select="KmKarta/TypKarty" />
									</xsl:variable>

									<tr>
										<td class="velikost5 podtrzeni_NT" align="left" height="23" colspan="3"><xsl:value-of select="Popis"/>&#160;</td>
							
										<td class="velikost5 podtrzeni_NT" align="left">
											<xsl:choose>
												<xsl:when test="../../Druh!='D' ">
													<xsl:value-of select="SklPolozka/KmKarta/Katalog" />
													<xsl:value-of select="KmKarta/Katalog" />
													<xsl:value-of select="NesklPolozka/Katalog" />
													&#160;
												</xsl:when>
												<xsl:otherwise>&#160;</xsl:otherwise>
											</xsl:choose>
										</td>
							
										<td class="velikost5 podtrzeni_NT" align="right">&#160;
											<xsl:if test="(string-length(PocetMJ)>0) and (../../Druh!='D') ">
												<xsl:value-of select="format-number(PocetMJ, '#,##0.00')" />
											</xsl:if>
										</td>
							
										<td class="velikost5 podtrzeni_NT" align="left">&#160;
											<xsl:choose>
												<xsl:when test="../../Druh!='D' ">
													<xsl:value-of select="SklPolozka/KmKarta/MJ" />
													<xsl:value-of select="KmKarta/MJ" />
													<xsl:value-of select="NesklPolozka/MJ" />
												</xsl:when>
												<xsl:otherwise>&#160;</xsl:otherwise>
											</xsl:choose>
										</td>
										
										<td class="velikost5 podtrzeni_NT" align="right">&#160;
											<xsl:if test="$TypKarty != 'sada' ">
												<xsl:choose>
													<xsl:when test="string-length($Mena)>0 and string-length(Valuty)>0">
														<xsl:choose>
															<xsl:when test="../../Druh!='D' ">
																<xsl:value-of select="format-number(Valuty, '#,##0.00')" />
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="format-number(PocetMJ*Valuty, '#,##0.00')" />
															</xsl:otherwise>
														</xsl:choose>
													</xsl:when>
													<xsl:when test="string-length($Mena)=0 and string-length(Cena)>0">
														<xsl:choose>
															<xsl:when test="../../Druh!='D' ">
																<xsl:value-of select="format-number(Cena, '#,##0.00')" />
															</xsl:when>
															<xsl:otherwise>
																<xsl:value-of select="format-number(PocetMJ*Cena, '#,##0.00')" />
															</xsl:otherwise>
														</xsl:choose>
													</xsl:when>
												</xsl:choose>
											</xsl:if>
										</td>
							
										<td class="velikost5 podtrzeni_NT" align="right">&#160;
											<xsl:if test="$TypKarty != 'sada' ">
												<xsl:value-of select="SazbaDPH" />&#160;%
											</xsl:if>
										</td>

										<td class="velikost5 podtrzeni_NT" align="right">&#160;
											<xsl:if test="$TypKarty != 'sada' ">
												<xsl:if test="CenaTyp='0' or TypCeny='0' ">bez DPH</xsl:if>
												<xsl:if test="CenaTyp='1'  or TypCeny='1' ">s DPH</xsl:if>
												<xsl:if test="CenaTyp='2'  or TypCeny='2' ">len DPH</xsl:if>
												<xsl:if test="CenaTyp='3'  or TypCeny='3' ">len základ</xsl:if>
											</xsl:if>
										</td>
									</tr>

									<xsl:if test="string-length(Poznamka)>0">
										<tr>
											<td class="velikost7 kurziva zarovnani_N" height="15" colspan="9"><xsl:value-of select="Poznamka" /></td>
										</tr>
									</xsl:if>

									<xsl:if test="count(SklPolozka/SeznamVC/VyrobniCislo)>0">
										<xsl:for-each select="SklPolozka/SeznamVC/VyrobniCislo">
											<tr>
												<td class="velikost5" height="15" width="2%">-</td>
												<td class="velikost6 kurziva" colspan="8"><xsl:value-of select="VyrobniCis"/></td>
											</tr>
										</xsl:for-each>
									</xsl:if>

									<!-- subpoložky dokladu -->
									<xsl:apply-templates select="SklPolozka">
										<xsl:with-param name="Mena" select="$Mena"/>
										<xsl:with-param name="Druh" select="$Druh"/>
										<xsl:with-param name="TypKartyNadr" select="$TypKarty"/>
									</xsl:apply-templates>
	
							</xsl:for-each>


							<!-- položky zálohové faktury -->
							<xsl:for-each select="SeznamZalPolozek/Polozka">
									<xsl:variable name="TypKarty">
										<xsl:value-of select="SklPolozka/KmKarta/TypKarty" />
										<xsl:value-of select="KmKarta/TypKarty" />
									</xsl:variable>

								<tr>
									<td class="velikost5 podtrzeni_NT" align="left" height="23" colspan="3"><xsl:value-of select="Popis"/>&#160;</td>
						
									<td class="velikost5 podtrzeni_NT" align="left">
										<xsl:value-of select="SklPolozka/KmKarta/Katalog" />
										<xsl:value-of select="KmKarta/Katalog" />
										<xsl:value-of select="NesklPolozka/Katalog" />
										&#160;
									</td>
						
									<td class="velikost5 podtrzeni_NT" align="right">&#160;
										<xsl:if test="string-length(PocetMJ)>0">
											<xsl:value-of select="format-number(PocetMJ, '#,##0.00')" />
										</xsl:if>
									</td>
						
									<td class="velikost5 podtrzeni_NT" align="left">&#160;
										<xsl:value-of select="SklPolozka/KmKarta/MJ" />
										<xsl:value-of select="KmKarta/MJ" />
										<xsl:value-of select="NesklPolozka/MJ" />
									</td>
									
									<td class="velikost5 podtrzeni_NT" align="right">&#160;
										<xsl:if test="$TypKarty != 'sada' ">
											<xsl:choose>
												<xsl:when test="string-length($Mena)>0 and string-length(Valuty)>0">
													<xsl:value-of select="format-number(Valuty, '#,##0.00')" />
												</xsl:when>
												<xsl:when test="string-length($Mena)=0 and string-length(Cena)>0">
													<xsl:value-of select="format-number(Cena, '#,##0.00')" />
												</xsl:when>
											</xsl:choose>
										</xsl:if>
									</td>
						
									<td class="velikost5 podtrzeni_NT" align="right">&#160;
										<xsl:if test="$TypKarty != 'sada' ">									
											<xsl:value-of select="SazbaDPH" />&#160;%
										</xsl:if>
									</td>
									
									<td class="velikost5 podtrzeni_NT" align="right">&#160;
										<xsl:if test="$TypKarty != 'sada' ">
											<xsl:if test="CenaTyp='0' or TypCeny='0' ">bez DPH</xsl:if>
											<xsl:if test="CenaTyp='1'  or TypCeny='1' ">s DPH</xsl:if>
											<xsl:if test="CenaTyp='2'  or TypCeny='2' ">len DPH</xsl:if>
											<xsl:if test="CenaTyp='3'  or TypCeny='3' ">len základ</xsl:if>
										</xsl:if>
									</td>
								</tr>

									<xsl:if test="string-length(Poznamka)>0">
										<tr>
											<td class="velikost7 kurziva zarovnani_N" height="15" colspan="9"><xsl:value-of select="Poznamka" /></td>
										</tr>
									</xsl:if>

									<xsl:if test="count(SeznamVC/VyrobniCislo)>0">
										<xsl:for-each select="SeznamVC/VyrobniCislo">
											<tr>
												<td class="velikost5" height="15" width="2%">-</td>
												<td class="velikost6 kurziva" colspan="7"><xsl:value-of select="VyrobniCis"/></td>
											</tr>
										</xsl:for-each>
									</xsl:if>

									<!-- subpoložky dokladu -->
									<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
										<xsl:with-param name="Mena" select="$Mena"/>
										<xsl:with-param name="Druh" select="$Druh"/>
										<xsl:with-param name="TypKartyNadr" select="$TypKarty"/>
									</xsl:apply-templates>

							</xsl:for-each>

							<tr>
								<xsl:choose>
									<xsl:when test="SeznamPolozek/Polozka | SeznamZalPolozek/Polozka">
										<td class="podtrzeni_NT" height="23" colspan="9">&#160;</td>
									</xsl:when>
									<xsl:otherwise>
										<td height="23" colspan="9"/>
									</xsl:otherwise>
								</xsl:choose>
							</tr>

						</tbody>
					</table>
				</td>
			</tr>	


			<tr>
			<!-- cenový přehled dokladu -->
				<td>
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>

							<xsl:choose>
									<xsl:when test="string-length(Valuty/Mena/Kod)>0 ">	<!-- Doklad v cizí měně -->
										<xsl:call-template name="CenovyPanel">			<!-- sazby na cenovém panelu -->
											<xsl:with-param name="Rezim" select="2"/>
										</xsl:call-template>
									</xsl:when>

								<xsl:otherwise>								<!-- Doklad v domácí měně -->				
									<xsl:call-template name="CenovyPanel">			<!-- sazby na cenovém panelu -->
										<xsl:with-param name="Rezim" select="1"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td/>

				<!-- závěr cen -->
				<td>
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>

						<!-- Tento element se při importu ignoruje. Sleva se vždy počítá z položek.
							<tr>
								<td class="velikost2 tucne" height="25" align="right" width="43%">Sleva v %:&#160;&#160;</td>
								<td class="velikost2 tucne" align="right" width="43%" ><xsl:value-of select="format-number(Sleva,'#,##0.00')" />&#160;&#160;</td>
								<td/>
							</tr>
						-->

						<tr>
							<td class="velikost2 tucne" height="25" align="right" width="43%">
								<xsl:choose>
									<xsl:when test="Druh!='D' ">Spolu na úhradu:&#160;&#160;</xsl:when>
									<xsl:otherwise>Celkem:&#160;&#160;</xsl:otherwise>
								</xsl:choose>
							</td>
							<td class="velikost2 tucne pozadi2 barvapisma" align="right" width="43%">
								<xsl:choose>
									<xsl:when test="string-length(Valuty/Mena/Kod)>0">
										<xsl:choose>
											<xsl:when test="Druh='N'">
												<!-- na vyúčtovací faktuře se navýší o sumu odpočtů - viz totéž co v tisku -->
												<xsl:value-of select="format-number((Valuty/Celkem)-(SumZalohaC), '#,##0.00')" />&#160;&#160;
											</xsl:when>
											<xsl:otherwise><xsl:value-of select="format-number(Valuty/Celkem, '#,##0.00')" />&#160;&#160;</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="Druh='N'">
												<xsl:value-of select="format-number((Celkem)-(SumZaloha), '#,##0.00')" />&#160;&#160;
											</xsl:when>
											<xsl:otherwise><xsl:value-of select="format-number(Celkem, '#,##0.00')" />&#160;&#160;</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td class="velikost2 tucne pozadi1" align="center">
								<xsl:choose>
									<xsl:when test="string-length(Valuty/Mena/Kod)>0 ">
										<xsl:value-of select="Valuty/Mena/Kod"/>
									</xsl:when>
									<xsl:otherwise>Eur</xsl:otherwise>		
								</xsl:choose>
							</td>
						</tr>


						<xsl:if test="Druh='N' or Druh='Z' or Druh='P'">
							<tr>
								<td class="velikost2 tucne" height="25" align="right">Uhradené zálohou:&#160;&#160;</td>
								<td class="velikost2 tucne" align="right" >
									<xsl:choose>
										<xsl:when test="string-length(Valuty/Mena/Kod)>0">
											<!-- u sumy odpočtů se obrací znaménko - viz totéž co v tisku -->
											<xsl:value-of select="format-number((SumZalohaC)*(-1), '#,##0.00')" />&#160;&#160;
										</xsl:when>
										<xsl:otherwise><xsl:value-of select="format-number((SumZaloha)*(-1), '#,##0.00')" />&#160;&#160;</xsl:otherwise>			
									</xsl:choose>
								</td>
								<td/>
							</tr>
						</xsl:if>

						<xsl:if test="Druh!='D' ">
						<tr>
							<td class="velikost2 tucne" height="25" align="right">Zostáva uhradiť:&#160;&#160;</td>
							<td class="velikost2 tucne" align="right" >
								<xsl:choose>
									<xsl:when test="string-length(Valuty/Mena/Kod)>0">
										<xsl:choose>	<!-- u dobropisů se obrací znaménko - viz totéž co v tisku -->
											<xsl:when test="Dobropis = 1"><xsl:value-of select="format-number((ValutyProp)*(-1), '#,##0.00')" />&#160;&#160;</xsl:when>
											<xsl:otherwise><xsl:value-of select="format-number(ValutyProp, '#,##0.00')" />&#160;&#160;</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>	<!-- u dobropisů se obrací znaménko - viz totéž co v tisku -->
											<xsl:when test="Dobropis = 1"><xsl:value-of select="format-number((Proplatit)*(-1), '#,##0.00')" />&#160;&#160;</xsl:when>
											<xsl:otherwise><xsl:value-of select="format-number(Proplatit, '#,##0.00')" />&#160;&#160;</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td/>
						</tr>
						</xsl:if>

						<xsl:if test="string-length(Uhrazeno)>0 and string-length(UDoklad)>0 ">
							<tr><td height="5" colspan="3"/></tr>
							<tr>
								<td class="velikost2 tucne" height="25" align="center" colspan="3">
								Uhradené 
									<xsl:call-template name="_datum_">
										<xsl:with-param name="_datum"><xsl:value-of select="Uhrazeno" />
										</xsl:with-param>
									</xsl:call-template>, dokladom <xsl:value-of select="UDoklad" />
								</td>
							</tr>
						</xsl:if>

						</tbody>
					</table>
				</td>

			</tr>	


			<tr><td height="20" colspan="2"/></tr>

			<tr>
			<!-- text za cenami  -->
				<td class="velikost6 zarovnani_D kurziva" height="20" colspan="3">
					<xsl:if test="string-length(TextZaFa)>0 ">
						<xsl:value-of select="TextZaFa"/>
					</xsl:if>
				</td>
			</tr>


			<tr><td height="150" colspan="3"/></tr>											<!-- mezera -->
			
			<!--<xsl:if test="position() != $Pocet ">	-->										<!-- jestliže se nejedná o poslední entitu -->
				<tr><td colspan="10">&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->
			<!--</xsl:if> -->
			
	
		</tbody>
		</table>

	</xsl:template>

</xsl:stylesheet>
