<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Transformační šablona náhledu pro bankovní doklady ve tvaru HTML. Doklad se zobrazuje jako náhled dokladu před tiskem.- sk lokalizácia
Autor: Marek Vykydal
 -->

	<xsl:import href="_Doklady.xslt"/>
	<xsl:output method="xml" encoding="UTF-8" />  

	<xsl:template match="/">
		<html>
			<head>
				<title>Bankový doklad</title>
				<style><![CDATA[
					body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%;	color: black;}
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
						.velikost10 {font-size: 90%;}

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
	<xsl:template match="SeznamBankDokl">
		<xsl:apply-templates select="BankDokl">
			<xsl:with-param name="Pocet" select="count(BankDokl)"/>
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
	

<!-- Bankovní doklad  -->
	<xsl:template match="BankDokl">
		<xsl:param name="Pocet"/>
		<xsl:param name="Mena" select="Valuty/Mena/Kod"/>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

<!-- naše firma -->

	<xsl:if test="name(MojeFirma)">			<!-- není prozatím podporován export elementu MojeFirma, proto je zde podmínka pro pozdější budoucí použití -->
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
	</xsl:if>


			<tr>
				<!-- nadpis dokladu -->
				<td class="zarovnani_N" width="48.5%">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost1 tucne podtrzeni_N3" align="left" height="32">
									<xsl:choose>		<!-- test, zda se jedná o příjmový nebo výdajový bankovní doklad  -->
										<xsl:when test="Vydej=0">Príjmový bankový doklad</xsl:when>
										<xsl:when test="Vydej=1">Výdajový bankový doklad</xsl:when>
										<xsl:otherwise>Bankový doklad</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td class="podtrzeni_N3" width="3%">&#160;</td>

				<!-- Přijato (od), Vyplaceno (komu) -->
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
								<td colspan="3">&#160;</td>
							</tr>
							
							<tr>	<td height="5" colspan="3"></td></tr>
							<tr>	<td class="velikost4 tucne podtrzeni_D" colspan="3">
										<xsl:choose>		<!-- test, zda se jedná o příjmový nebo výdajový bankovní doklad  -->
											<xsl:when test="Vydej=0">Prijaté (od):</xsl:when>
											<xsl:when test="Vydej=1">Vyplatené (komu):</xsl:when>
											<xsl:otherwise>&#160;</xsl:otherwise>
										</xsl:choose>
									</td>
							</tr>

							<tr>	<td height="20" colspan="3"></td></tr>

							<tr>
								<td class="velikost2 tucne" colspan="3">
									<xsl:value-of select="Adresa/ObchNazev" />&#160;
								</td>
							</tr>

							<tr>	<td height="20" colspan="3"></td></tr>

							<tr>
								<td class="velikost3 tucne" colspan="3">
									<xsl:if test="Adresa/Nazev != Adresa/ObchNazev"><xsl:value-of select="Adresa/Nazev" /></xsl:if>&#160;<br/>
									<xsl:value-of select="Adresa/ObchAdresa/Ulice" />&#160;<br/>
									<xsl:value-of select="Adresa/ObchAdresa/PSC" />&#160;&#160;
									<xsl:value-of select="Adresa/ObchAdresa/Misto" /><br/>
									<xsl:value-of select="Adresa/ObchAdresa/Stat"/>&#160;
								</td>
							</tr>

							<tr>	<td class="podtrzeni_D" height="20" colspan="3">&#160;</td></tr>	

						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- platba + popisek "Datum" -->
				<td class="zarovnani_D">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4 tucne">Účel platby:</td>
								<td/>
								<td class="velikost4" colspan="2"><xsl:value-of select="Popis"/>&#160;</td>
							</tr>
							<tr>
								<td class="velikost4 tucne">&#160;</td>
								<td/>
								<td class="velikost4" colspan="2"><xsl:value-of select="Doprava"/>&#160;</td>
							</tr>

							<tr>
								<td height="10" colspan="4"></td>
							</tr>

							<tr>
								<td class="velikost4 tucne podtrzeni_D" width="20%">Dátum</td>
								<td class="podtrzeni_D" width="2%">&#160;</td>
								<td class="podtrzeni_D" width="18%">&#160;</td>
								<td width="60%"/>
							</tr>

						</tbody>
					</table>
				</td>
			</tr>


			<tr>
				<!-- datumové pole -->
				<td class="zarovnani_N">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost4" height="17" align="right" width="20%">úč. prípadu:</td>
								<td width="2%"/>
								<td class="velikost4" align="center" width="18%">
									<xsl:if test="string-length(DatUcPr)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum"><xsl:value-of select="DatUcPr"/></xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td width="60%"/>
							</tr>

							<tr>
								<td class="velikost4" height="17" align="right">vystavenia:</td>
								<td/>
								<td class="velikost4" align="center">
									<xsl:if test="string-length(DatVyst)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum">
												<xsl:value-of select="DatVyst" />
											</xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td/>
							</tr>

							<tr>
								<td class="velikost4" height="17" align="right">zd. plnenia:</td>
								<td/>
								<td class="velikost4" align="center">
									<xsl:if test="string-length(DatPln)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum">
												<xsl:value-of select="DatPln" />
											</xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td/>
							</tr>

							<tr>
								<td class="velikost4" height="17" align="right">platby:</td>
								<td/>
								<td class="velikost4" align="center">
									<xsl:if test="string-length(DatPlat)>0">
										<xsl:call-template name="_datum_">
											<xsl:with-param name="_datum">
												<xsl:value-of select="DatPlat" />
											</xsl:with-param>
										</xsl:call-template>
									</xsl:if>
								</td>
								<td/>
							</tr>

						</tbody>
					</table>
				</td>

				<!-- mezera mezi sloupci -->
				<td/>

				<!-- partner - IČ, DIČ -->
				<td class="zarovnani_N">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>

							<tr>
								<td rowspan="3">&#160;</td>
								<td class="velikost4 zarovnani_D" align="right" height="17" width="10%">IČO:</td>
								<td class="velikost4 zarovnani_D" width="30%">&#160;&#160;<xsl:value-of select="Adresa/ICO" /></td>
							</tr>

							<tr>
								<td class="velikost4 zarovnani_D" align="right">IČ DPH:</td>
								<td class="velikost4 zarovnani_D">&#160;&#160;<xsl:value-of select="Adresa/DIC" /></td>
							</tr>
              <tr>
                <td class="velikost4 zarovnani_D" align="right">DIČ:</td>
                <td class="velikost4 zarovnani_D">&#160;&#160;<xsl:value-of select="Adresa/DICSK" /></td>
              </tr>
						</tbody>
					</table>
				</td>
			</tr>


			<!-- mezera -->
			<tr><td height="10" colspan="3"/></tr>


			<tr>
			<!-- zaúčtoval, schválil, podpisy -->
				<td colspan="3">
					<table class="podtrzeni_N podtrzeni_D podtrzeni_L podtrzeni_P" bordercolor="black" width="100%" cellspacing="0" cellpadding="5" border="0">
						<tbody>
							<tr>
								<td class="velikost4 podtrzeni_P" width="25%">
									Zaúčtoval(a): <xsl:value-of select="Vyst" /><br/>
									Dňa:
									<xsl:choose>
										<xsl:when test="string-length(DatUcPr)>0">
											<xsl:call-template name="_datum_"><xsl:with-param name="_datum"><xsl:value-of select="DatUcPr" /></xsl:with-param></xsl:call-template>
										</xsl:when>
										<xsl:when test="string-length(DatVyst)>0">
											<xsl:call-template name="_datum_"><xsl:with-param name="_datum"><xsl:value-of select="DatVyst" /></xsl:with-param></xsl:call-template>
										</xsl:when>
									</xsl:choose>
									<br/>&#160;
								</td>
								<td class="velikost4 zarovnani_N podtrzeni_P" width="25%">Schválil(a):</td>
								<td class="velikost4 zarovnani_N podtrzeni_P" width="25%">&#160;</td>
								<td class="velikost4 zarovnani_N">&#160;</td>
							</tr>

						</tbody>
					</table>

				</td>
			</tr>

			<tr>
			<!-- oddělovací čárka -->
				<td colspan="3">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost8 podtrzeni_D" width="2%">&#160;</td>
								<td width="98%"/>
							</tr>

							<tr><td height="6" colspan="2"/></tr>

						</tbody>
					</table>
				</td>
			</tr>


			<!-- položky  -->
			<tr>	
				<td colspan="3">
					<xsl:choose>
					<xsl:when test="count(SeznamNormPolozek/NormPolozka)>0">		<!-- normální položky  -->
						<table bordercolor="green" cellspacing="0" cellpadding="0" width="100%" border="0" >
							<tbody>
								<tr><td height="14" colspan="6"/></tr>
								<tr>
									<td class="velikost5 tucne podtrzeni_D " height="21" align="left" width="35%">Popis</td>
									<td class="velikost5 tucne podtrzeni_D " align="right">Počet</td>
									<td class="velikost5 tucne podtrzeni_D " align="left">&#160; m. j.</td>
									<td class="velikost5 tucne podtrzeni_D " align="right">Cena za m. j.</td>
									<td class="velikost5 tucne podtrzeni_D " align="right">Sadzba</td>
									<td class="velikost5 tucne podtrzeni_D " align="right">Typ ceny</td>
								</tr>

								<xsl:for-each select="SeznamNormPolozek/NormPolozka">
									<tr>
										<td class="velikost5 podtrzeni_NT" height="23" align="left"><xsl:value-of select="Popis"/></td>
										<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="format-number(PocetMJ, '#,##0.00')" /></td>
										<td class="velikost5 podtrzeni_NT">&#160; <xsl:value-of select="TextMJ" /></td>
										<td class="velikost5 podtrzeni_NT" align="right">
											<xsl:choose>
												<xsl:when test="string-length($Mena)>0 ">
													<xsl:value-of select="format-number(Valuty, '#,##0.00')" />
												</xsl:when>
												<xsl:otherwise>																			
													<xsl:value-of select="format-number(Cena, '#,##0.00')" />
												</xsl:otherwise>																			
											</xsl:choose>
										</td>
										<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="SazbaDPH" />&#160;%</td>
										<td class="velikost5 podtrzeni_NT" align="right">
											<xsl:if test="CenaTyp='0' ">bez DPH</xsl:if>
											<xsl:if test="CenaTyp='4' ">s DPH</xsl:if>
											<xsl:if test="CenaTyp='2' ">len DPH</xsl:if>
											<xsl:if test="CenaTyp='3' ">len základ</xsl:if>
										</td>
									</tr>
			
									<xsl:if test="string-length(Poznamka)>0">
										<tr>
											<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6"><xsl:value-of select="Poznamka" /></td>
										</tr>
									</xsl:if>

								</xsl:for-each>

							</tbody>
						</table>
					</xsl:when>

					<xsl:when test="count(SeznamRozuctPolozek/RozuctPolozka)>0">		<!-- rozúčtovací položky  - vždy pouze v domácí měně  -->
						<table bordercolor="green" cellspacing="0" cellpadding="0" width="100%" border="0" >
							<tbody>
									<xsl:choose>
										<xsl:when test="string-length(SeznamRozuctPolozek/RozuctPolozka/Pohyb)>0">	<!-- daňová evidence  -->
											<tr><td height="14" colspan="5"/></tr>
											<tr>
												<td class="velikost5 tucne podtrzeni_D " height="21" align="left" width="35%">Popis - rozúčtovanie</td>
												<td class="velikost5 tucne podtrzeni_D " align="left">Pohyb</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Suma</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Sadzba</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Typ ceny</td>
											</tr>

											<xsl:for-each select="SeznamRozuctPolozek/RozuctPolozka">
												<tr>
													<td class="velikost5 podtrzeni_NT" height="23" align="left"><xsl:value-of select="Popis"/></td>
													<td class="velikost5 podtrzeni_NT" ><xsl:value-of select="Pohyb"/></td>
													<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="format-number(Castka, '#,##0.00')" /></td>
													<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="SazbaDPH" />&#160;%</td>
													<td class="velikost5 podtrzeni_NT" align="right">
														<xsl:if test="TypCena='0' ">DPH</xsl:if>
														<xsl:if test="TypCena='1' ">základ</xsl:if>
													</td>
												</tr>

												<xsl:if test="string-length(Pozn)>0">
													<tr>
														<td class="velikost7 kurziva zarovnani_N" height="15" colspan="5"><xsl:value-of select="Pozn" /></td>
													</tr>
												</xsl:if>
			
											</xsl:for-each>

											<tr>
												<td class="podtrzeni_N " height="23" colspan="5">&#160;</td>
											</tr>
										</xsl:when>

										<xsl:otherwise>												<!-- podvojné účetnictví  -->
											<tr><td height="14" colspan="6"/></tr>
											<tr>
												<td class="velikost5 tucne podtrzeni_D" height="21" align="left" width="35%">Popis - rozúčtovanie</td>
												<td class="velikost5 tucne podtrzeni_D " align="left">Účet MD</td>
												<td class="velikost5 tucne podtrzeni_D " align="left">Účet D</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Suma</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Sadzba</td>
												<td class="velikost5 tucne podtrzeni_D " align="right">Typ ceny</td>
											</tr>

											<xsl:for-each select="SeznamRozuctPolozek/RozuctPolozka">
												<tr>
													<td class="velikost5 podtrzeni_NT" height="23" align="left"><xsl:value-of select="Popis"/></td>
													<td class="velikost5 podtrzeni_NT"><xsl:value-of select="UcMD"/></td>
													<td class="velikost5 podtrzeni_NT"><xsl:value-of select="UcD"/></td>
													<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="format-number(Castka, '#,##0.00')" /></td>
													<td class="velikost5 podtrzeni_NT" align="right"><xsl:value-of select="SazbaDPH" />&#160;%</td>
													<td class="velikost5 podtrzeni_NT" align="right">
														<xsl:if test="TypCena='0' ">základ</xsl:if>
														<xsl:if test="TypCena='1' ">DPH</xsl:if>
													</td>
												</tr>

												<xsl:if test="string-length(Pozn)>0">
													<tr>
														<td class="velikost7 kurziva zarovnani_N" height="15" colspan="6"><xsl:value-of select="Pozn" /></td>
													</tr>
												</xsl:if>
			
											</xsl:for-each>

										</xsl:otherwise>
									</xsl:choose>

							</tbody>
						</table>					
					</xsl:when>
					</xsl:choose>		
				</td>
			</tr>


			<!-- mezera -->
			<tr>
				<xsl:choose>
					<xsl:when test="count(SeznamNormPolozek/NormPolozka)>0 or count(SeznamRozuctPolozek/RozuctPolozka)>0">
						<td class="podtrzeni_NT " height="23" colspan="3">&#160;</td>
					</xsl:when>
					<xsl:otherwise>
						<td height="14" colspan="3"/>
					</xsl:otherwise>
				</xsl:choose>
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


			<tr><td height="20" colspan="3"/></tr>


			<tr>
			<!-- poznámka  -->
				<td class="velikost6 zarovnani_D kurziva" height="20" colspan="3">
					<xsl:if test="string-length(Pozn)>0 ">
						<xsl:value-of select="Pozn"/>
					</xsl:if>
				</td>
			</tr>


			<tr><td height="150" colspan="3"/></tr>											<!-- mezera -->

			<!--<xsl:if test="position() != $Pocet ">	-->									<!-- jestliže se nejedná o poslední entitu -->
				<tr>	<td colspan="3">&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->
			<!--</xsl:if>-->

		</tbody>
		</table>
	</xsl:template>

</xsl:stylesheet>
