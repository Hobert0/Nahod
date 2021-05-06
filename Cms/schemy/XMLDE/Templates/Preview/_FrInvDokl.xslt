<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Transformační šablona náhledu pro inventurní doklady ve tvaru HTML. Doklad se zobrazuje jako náhled dokladu před tiskem.
Autor: Marek Vykydal
 -->

	<xsl:import href="_Doklady.xslt"/>
	<xsl:output method="xml" encoding="UTF-8" />  

	<xsl:template match="/">
		<html>
			<head>
				<title>Inventúrny doklad</title>
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
	<xsl:template match="SeznamInvDokl">
		<xsl:apply-templates select="InvDoklad">
			<xsl:with-param name="Pocet" select="count(InvDoklad)"/>
		</xsl:apply-templates>
	</xsl:template>
	

<!-- Datumový formát výstupu - nevyužito -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum" />
		<xsl:variable name="den" select="substring($_datum, 9,2)"></xsl:variable>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"></xsl:variable>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"></xsl:variable>
		<xsl:variable name="datum" select="concat($den,'.',$mesic,'.',$rok)"></xsl:variable>
		<xsl:value-of select="$datum"></xsl:value-of>
	</xsl:template>
	


<!-- Položky dokladu - podřízené -->
	<xsl:template match="Slozeni/SubPolozka/Polozka">
		<xsl:param name="Druh"/>
		<xsl:param name="Mena"/>
		<xsl:param name="TypKartyNadr"/>

		<xsl:variable name="TypKarty">
			<xsl:value-of select="SklPolozka/KmKarta/TypKarty" />
			<xsl:value-of select="KmKarta/TypKarty" />
		</xsl:variable>

		<xsl:choose>

			<xsl:when test="$Druh = 'InvDoklad' ">	<!-- Položky inventurních dokladů - mají jinou strukturu -->
				<tr>
					<td height="23"  width="2%">-</td>
	
					<td class="velikost5 " align="left" colspan="2">
						<xsl:choose>
							<xsl:when test="string-length(Popis)>0">
								<xsl:value-of select="Popis"/>&#160;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="KmKarta/Popis"/>&#160;
							</xsl:otherwise>
						</xsl:choose>
					</td>
		
					<td class="velikost5 " align="left">
						<xsl:choose>
							<xsl:when test="string-length(Zkrat)>0">
								<xsl:value-of select="Zkrat"/>&#160;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="KmKarta/Zkrat"/>&#160;
							</xsl:otherwise>
						</xsl:choose>
					</td>
			
					<td class="velikost5 " align="left">
						<xsl:choose>
							<xsl:when test="string-length(Sklad/Nazev)>0">
								<xsl:value-of select="Sklad/Nazev"/>&#160;
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="Sklad/KodSkladu"/>&#160;
							</xsl:otherwise>
						</xsl:choose>
					</td>
	
					<td class="velikost5 " align="left"><xsl:value-of select="Slupina"/>&#160;</td>	<!-- překlep v elementu - 'l' vs. 'k' -->
	
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="string-length(MnInv)>0">
							<xsl:value-of select="format-number(MnInv, '#,##0.00')" />
						</xsl:if>
					</td>							
	
					<td class="velikost5 " align="left">
						<xsl:choose>
							<xsl:when test="string-length(MJ)>0">&#160;&#160;&#160;
								<xsl:value-of select="MJ"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="KmKarta/MJ"/>
							</xsl:otherwise>
						</xsl:choose>
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
			</xsl:when>


			<!-- Položky ostatních dokladů 
			Tento přepis pro položky ostatních dokladů je zde proto, že šablona pro inventurní doklad _FrInvDokl.xslt se v Reportu importuje jako poslední a nahrazuje tak ostatní volání
			podřízených elementů Slozeni/SubPolozka/Polozka. Šablona _FrInvDokl.xslt proto musí být v Reportu umístěna až jako poslední v seznamu šablon dokladů.
			-->
			<xsl:otherwise>			
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
						<xsl:if test="((($Druh = 'FaktVyd') or ($Druh = 'ObjPrij') or ($Druh = 'NabVyd') or ($Druh = 'PoptPrij')
									or ($Druh = 'DLVyd') or ($Druh = 'Prodejka')) and ($TypKarty != 'sada') and ($TypKartyNadr != 'komplet'))
									or ((($Druh = 'FaktPrij') or ($Druh = 'ObjVyd') or ($Druh = 'NabPrij') or ($Druh = 'PoptVyd') or ($Druh = 'DLPrij')
									or ($Druh = 'Prijemka') or ($Druh = 'Vydejka') or ($Druh = 'Prevodka')) and ($TypKarty != 'sada') and ($TypKarty != 'komplet'))">
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
						<xsl:if test="((($Druh = 'FaktVyd') or ($Druh = 'ObjPrij') or ($Druh = 'NabVyd') or ($Druh = 'PoptPrij')
									or ($Druh = 'DLVyd') or ($Druh = 'Prodejka')) and ($TypKarty != 'sada') and ($TypKartyNadr != 'komplet'))
									or ((($Druh = 'FaktPrij') or ($Druh = 'ObjVyd') or ($Druh = 'NabPrij') or ($Druh = 'PoptVyd') or ($Druh = 'DLPrij')
									or ($Druh = 'Prijemka') or ($Druh = 'Vydejka') or ($Druh = 'Prevodka')) and ($TypKarty != 'sada') and ($TypKarty != 'komplet'))">
							<xsl:value-of select="DPH" /><xsl:value-of select="SazbaDPH" />&#160;%
						</xsl:if>					
					</td>
					
					<td class="velikost5 " align="right">&#160;
						<xsl:if test="((($Druh = 'FaktVyd') or ($Druh = 'ObjPrij') or ($Druh = 'NabVyd') or ($Druh = 'PoptPrij')
									or ($Druh = 'DLVyd') or ($Druh = 'Prodejka')) and ($TypKarty != 'sada') and ($TypKartyNadr != 'komplet'))
									or ((($Druh = 'FaktPrij') or ($Druh = 'ObjVyd') or ($Druh = 'NabPrij') or ($Druh = 'PoptVyd') or ($Druh = 'DLPrij')
									or ($Druh = 'Prijemka') or ($Druh = 'Vydejka') or ($Druh = 'Prevodka')) and ($TypKarty != 'sada') and ($TypKarty != 'komplet'))">
							<xsl:if test="CenaTyp='0' or TypCeny='0' ">bez DPH</xsl:if>
							<xsl:if test="CenaTyp='1'  or TypCeny='1' ">s DPH</xsl:if>
							<xsl:if test="CenaTyp='2'  or TypCeny='2' ">iba DPH</xsl:if>
							<xsl:if test="CenaTyp='3'  or TypCeny='3' ">iba základ</xsl:if>
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
			</xsl:otherwise>

		</xsl:choose>


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



<!-- Inventurní doklad -->
	<xsl:template match="InvDoklad">
		<xsl:param name="Druh" select="name()"/>
		<xsl:param name="Pocet"/>

		<table bordercolor="blue" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>

			<tr>
				<!-- inventurní doklad -->
				<td class="velikost1 tucne podtrzeni_N3" width="48.5%" height="32">Inventúrny doklad</td>

				<!-- mezera mezi sloupci -->
				<td class="podtrzeni_N3" width="3%">&#160;</td>

				<!-- číslo dokladu-->
				<td>
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="podtrzeni_N3">&#160;</td>
								<td class="velikost1 tucne podtrzeni_N3 podtrzeni_D podtrzeni_L podtrzeni_P"  height="32" align="center" width="40%">
									<xsl:value-of select="CisloD"/>&#160;
								</td>
							</tr>
						</tbody>
					</table>
				</td>
			</tr>


			<!-- mezera -->
			<tr><td height="10" colspan="3"/></tr>

			<tr>
			<!-- inventura, popis, zpracoval, odpovídá -->
				<td colspan="3">
					<table class="podtrzeni_N podtrzeni_D podtrzeni_L podtrzeni_P" bordercolor="black" width="100%" cellspacing="0" cellpadding="5" border="0">
						<tbody>
							<tr>
								<td class="velikost5" width="10%">
									Inventúra:<br/>
									Popis:<br/>
									Spracoval:<br/>
									Zodpovedá:<br/>
								</td>
				
								<td class="velikost5">
									<xsl:value-of select="InvID"/><br/>
									<xsl:value-of select="Popis"/><br/>
									<xsl:value-of select="Prac"/><br/>
									<xsl:value-of select="Kontr"/><br/>
								</td>
							</tr>

						</tbody>
					</table>

				</td>
			</tr>


			<tr>
			<!-- oddělovací čárka  -->
				<td colspan="3">
					<table bordercolor="black" width="100%" cellspacing="0" cellpadding="0" border="0">
						<tbody>
							<tr>
								<td class="velikost8 podtrzeni_D" width="2%">&#160;</td>
								<td width="98%"/>
							</tr>

							<tr><td height="20" colspan="2"/></tr>

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
							<tr>
								<td class="velikost5 tucne podtrzeni_D" height="21" align="left" colspan="3" width="35%">Popis</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">Skratka</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">Sklad</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">Skupina</td>
								<td class="velikost5 tucne podtrzeni_D" align="right">Inv. množstvo</td>
								<td class="velikost5 tucne podtrzeni_D" align="left">&#160;&#160;&#160;&#160;m. j.</td>
							</tr>
							</xsl:if>

							<!-- položky dokladu -->
								<xsl:for-each select="Polozka">
									<tr>
										<td class="velikost5 podtrzeni_NT" align="left" height="23" colspan="3">
											<xsl:choose>
												<xsl:when test="string-length(Popis)>0">
													<xsl:value-of select="Popis"/>&#160;
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="KmKarta/Popis"/>&#160;
												</xsl:otherwise>
											</xsl:choose>
										</td>
							
										<td class="velikost5 podtrzeni_NT" align="left">
											<xsl:choose>
												<xsl:when test="string-length(Zkrat)>0">
													<xsl:value-of select="Zkrat"/>&#160;
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="KmKarta/Zkrat"/>&#160;
												</xsl:otherwise>
											</xsl:choose>
										</td>
								
										<td class="velikost5 podtrzeni_NT" align="left">
											<xsl:choose>
												<xsl:when test="string-length(Sklad/Nazev)>0">
													<xsl:value-of select="Sklad/Nazev"/>&#160;
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="Sklad/KodSkladu"/>&#160;
												</xsl:otherwise>
											</xsl:choose>
										</td>

										<td class="velikost5 podtrzeni_NT" align="left"><xsl:value-of select="Slupina"/>&#160;</td>	<!-- překlep v elementu - 'l' vs. 'k' -->

										<td class="velikost5 podtrzeni_NT" align="right">&#160;
											<xsl:if test="string-length(MnInv)>0">
												<xsl:value-of select="format-number(MnInv, '#,##0.00')" />
											</xsl:if>
										</td>							

										<td class="velikost5 podtrzeni_NT" align="left">&#160;&#160;&#160;
											<xsl:choose>
												<xsl:when test="string-length(MJ)>0">
													<xsl:value-of select="MJ"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="KmKarta/MJ"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>

									</tr>

									<xsl:if test="string-length(Poznamka)>0">
										<tr>
											<td class="velikost7 kurziva zarovnani_N" height="15" colspan="8"><xsl:value-of select="Poznamka" /></td>
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
										<xsl:with-param name="Druh" select="$Druh"/>
									</xsl:apply-templates>

							</xsl:for-each>

							<xsl:if test="count(Polozka)>0">
								<tr>
									<!-- oddělovací čára položek -->
									<td class="podtrzeni_NT" height="23" colspan="8"><xsl:if test="Polozka">&#160;</xsl:if></td>
								</tr>
							</xsl:if>

						</tbody>
					</table>
				</td>
			</tr>	


			<tr>
			<!-- poznámka-->
				<td class="velikost6 zarovnani_D kurziva" height="20" colspan="3">
					<xsl:if test="string-length(Poznamka)>0 ">
						<xsl:value-of select="Poznamka"/>
					</xsl:if>
				</td>
			</tr>

			<tr><td height="150" colspan="3"/></tr>											<!-- mezera -->
			
			<!--<xsl:if test="position() != $Pocet ">	-->										<!-- jestliže se nejedná o poslední entitu -->
				<tr><td colspan="3">&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->
			<!--</xsl:if> -->
			
	
		</tbody>
		</table>

	</xsl:template>
</xsl:stylesheet>
