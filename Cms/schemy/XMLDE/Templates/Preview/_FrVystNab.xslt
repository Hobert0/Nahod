<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Transformační šablona náhledu pro nabídky vydané ve tvaru HTML. Doklad se zobrazuje jako náhled dokladu před tiskem.
Autor: Marek Vykydal
 -->

	<xsl:import href="_Doklady.xslt"/>
	<xsl:output method="xml" encoding="UTF-8" />  

	<xsl:template match="/">
		<html>
			<head>
				<title>Ponuka vystavená</title>
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
	<xsl:template match="SeznamNabVyd">
		<xsl:apply-templates select="NabVyd">
			<xsl:with-param name="Pocet" select="count(NabVyd)"/>
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
	

<!-- Položky - podřízené -->
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



<!-- Nabídka vydaná -->
	<xsl:template match="NabVyd">
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
										<xsl:when test="string-length(Nadpis)>0">
											<xsl:value-of select="Nadpis"/>
										</xsl:when>
										<xsl:otherwise>
									Ponuka vystavená
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td class="podtrzeni_N3" width="3%">&#160;</td>

				<!-- odběratel -->
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
								<td class="velikost4 tucne">&#160;</td>
								<td class="velikost3 tucne" align="center" colspan="2">&#160;</td>
							</tr>
							
							<tr>	<td height="5" colspan="3"></td></tr>
							<tr>	<td class="velikost4 tucne podtrzeni_D" colspan="3">Odběratel</td></tr>

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
				<!-- platba, doprava + popisek "Datum" -->
				<td class="zarovnani_D">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4 tucne">Platba:</td>
								<td/>
								<td class="velikost4" colspan="2"><xsl:value-of select="PlatPodm"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">Doprava:</td>
								<td/>
								<td class="velikost4" colspan="2"><xsl:value-of select="Doprava"/>&#160;</td>
							</tr>

							<tr>
								<td height="10" colspan="4"></td>
							</tr>

							<tr>
								<td class="velikost4 tucne podtrzeni_D" width="20%">Dátum</td>
								<td class="podtrzeni_D" width="2%">&#160;</td>
								<td  class="podtrzeni_D" width="18%">&#160;</td>
								<td width="60%"/>
							</tr>


						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- datumové pole, vystavil  -->
				<td class="zarovnani_N" rowspan="2">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4" height="17" align="right" width="20%">vystavenia:</td>
								<td width="2%"/>
								<td class="velikost4" align="center" width="18%">
									<xsl:if test="string-length(Vystaveno)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum"><xsl:value-of select="Vystaveno"/></xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td width="60%"/>
							</tr>

							<xsl:if test="string-length(VyriditNej)>0">
								<tr>
									<td class="velikost4" height="17" align="right">vybaviť najsk.:</td>
									<td/>
									<td class="velikost4" align="center">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum">
												<xsl:value-of select="VyriditNej" />
											</xsl:with-param>
										</xsl:call-template>
									</td>
									<td/>
								</tr>
							</xsl:if>
 
							<tr>
								<td class="velikost4 tucne" height="17" align="right">platnosť do:</td>
								<td/>
								<td class="velikost4 tucne pozadi1" align="center">
									<xsl:call-template name="_datum_">
										<xsl:with-param name="_datum">
											<xsl:value-of select="Vyridit_do" />
										</xsl:with-param>
									</xsl:call-template>
								</td>
								<td/>
							</tr>

							<xsl:if test="string-length(Vystavil)>0">
								<tr>	<td height="10" colspan="4"/>	</tr>
								<tr>	<td class="velikost4" height="17" colspan="4"><b>Vystavil(a):</b>&#160;<xsl:value-of select="Vystavil" /></td></tr>
							</xsl:if>

						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td rowspan="2"/>

				<!-- popisek "Konečný příjemce" + odběratel - IČ, DIČ -->
				<td class="zarovnani_N">
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
				</td>
			</tr>

			<tr>
				<!-- konečný příjemce - adresa -->
				<td class="zarovnani_D">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>	<td height="10"/></tr>
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
											<xsl:value-of select="DodOdb/ObchAdresa/PSC"/>&#160;&#160;<xsl:value-of select="DodOdb/ObchAdresa/Misto" />											<br/>
											<xsl:value-of select="DodOdb/ObchAdresa/Stat"/>&#160;
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>

						</tbody>
					</table>

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

							<xsl:if test="string-length(TextPredPo)>0 ">
								<tr>	<td class="velikost6 zarovnani_D kurziva" height="20" colspan="2"><xsl:value-of select="TextPredPo"/></td></tr>
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

							<xsl:if test="count(Polozka)>0">
							<tr><td height="14" colspan="9"/></tr>
							<tr>
								<td class="velikost5 tucne podtrzeni_D" height="21" align="left" colspan="3" width="35%">Označenie dodávky</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">Katalóg</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Počet</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">&#160; m. j.</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Cena za m. j.</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Sadzba</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Typ ceny</td>
							</tr>
							</xsl:if>

							<!-- položky dokladu -->
								<xsl:for-each select="Polozka">

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
									<xsl:when test="//Polozka">
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
							<td class="velikost2 tucne" height="25" align="right" width="43%">Spolu s DPH:&#160;&#160;</td>
							<td class="velikost2 tucne pozadi2 barvapisma" align="right" width="43%">
								<xsl:choose>
									<xsl:when test="string-length(Valuty/Mena/Kod)>0">
										<xsl:value-of select="format-number(Valuty/Celkem, '#,##0.00')" />&#160;&#160;
									</xsl:when>
									<xsl:otherwise><xsl:value-of select="format-number(Celkem, '#,##0.00')" />&#160;&#160;</xsl:otherwise>				
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

						</tbody>
					</table>
				</td>

			</tr>	


			<tr><td height="20" colspan="2"/></tr>

			<tr>
			<!-- text za cenami  -->
				<td class="velikost6 zarovnani_D kurziva" height="20" colspan="3">
					<xsl:if test="string-length(TextZaPol)>0 ">
						<xsl:value-of select="TextZaPol"/>
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
