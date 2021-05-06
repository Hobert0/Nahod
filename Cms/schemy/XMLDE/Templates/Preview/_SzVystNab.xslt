<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="_Doklady.xslt"/>
	<xsl:output method="xml" encoding="UTF-8" />  

	<!-- -->
	<xsl:template match="/">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	<!-- -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>
	<!-- -->
	<xsl:template match="SeznamNabVyd">
		<html>
			<head>
				<title>Zoznam vystavených ponúk</title>
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
				<script language="JScript">
					function Init() {
						document.all.Datum.innerHTML = Datum();
					}
					
					function Datum() {
						var m_datum = new Date();
						var s_datum = "";	
							s_datum += m_datum.getDate() + ".";				
							s_datum += m_datum.getMonth() + 1 + ".";
							s_datum += m_datum.getYear();
							
						return (s_datum);
					}
				</script>
			</head>

			<body onload="Init();">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td class="velikost1 tucne podtrzeni_D3" align="left" height="35" colspan="11">Zoznam vystavených ponúk</td>
					</tr>
					<tr>
						<td height="20"/>
					</tr>

					<tr>
						<td class="velikost5 tucne podtrzeni_D" align="left" height="25" width="8%">Doklad</td>
						<td class="velikost5 tucne podtrzeni_D"  width="8%" align="left" >Dátum vystavenia</td>
						<td class="velikost5 tucne podtrzeni_D"  width="8%" align="left" >Platná do</td>
						<td class="velikost5 tucne podtrzeni_D"  width="8%" align="left" >Dátum vybavenia</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%" align="right">Základ</td>
						<td class="velikost5 tucne podtrzeni_D" width="10%" align="right">Celkom</td>
						<td class="podtrzeni_D" width="3%" >&#160;</td>
						<td class="velikost5 tucne podtrzeni_D" width="8%" align="left">Zákazka</td>
						<td class="velikost5 tucne podtrzeni_D" width="8%" align="left">Stredisko</td>
						<td class="velikost5 tucne podtrzeni_D" width="8%" align="left">Činnosť</td>
						<td class="velikost5 tucne podtrzeni_D" width="21%" align="left">Popis</td>
					</tr>

					<xsl:apply-templates select="NabVyd"></xsl:apply-templates>

					<!-- Pomocné proměnné -->
					<xsl:variable name="Zaklad" select="sum(*/SouhrnDPH/Zaklad0) + sum(*/SouhrnDPH/Zaklad5) + sum(*/SouhrnDPH/Zaklad22)
														+ sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad)"/>
					<xsl:variable name="DPH" select="sum(*/SouhrnDPH/DPH5) + sum(*/SouhrnDPH/DPH22) + sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>

					<xsl:variable name="_vzaklad22" select="sum(*/SouhrnDPH/Zaklad22[../../Vyrizeno !=''])" />
					<xsl:variable name="_vzaklad5" select="sum(*/SouhrnDPH/Zaklad5[../../Vyrizeno !=''])" />
					<xsl:variable name="_vzaklad0" select="sum(*/SouhrnDPH/Zaklad0[../../Vyrizeno !=''])" />
					<xsl:variable name="_vzakladOstSazby" select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[../../../../Vyrizeno !=''])"/>
					
					<xsl:variable name="_nzaklad22" select="sum(*/SouhrnDPH/Zaklad22[(../../Vyrizeno='') or (not(../..//Vyrizeno))])" />
					<xsl:variable name="_nzaklad5" select="sum(*/SouhrnDPH/Zaklad5[(../../Vyrizeno='') or (not(../..//Vyrizeno))])" />
					<xsl:variable name="_nzaklad0" select="sum(*/SouhrnDPH/Zaklad0[(../../Vyrizeno='') or (not(../..//Vyrizeno))])" />
					<xsl:variable name="_nzakladOstSazby" select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[(../../../../Vyrizeno='') or (not(../../../..//Vyrizeno))])"/>

					<tr>
						<td class="velikost5 podtrzeni_N" height="25" align="left">Celkom:</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="velikost5 podtrzeni_N" align="right"><xsl:value-of select="format-number($Zaklad, '#,##0.00')" /></td>
						<td class="velikost5 podtrzeni_N" align="right"><xsl:value-of select="format-number($Zaklad + $DPH, '#,##0.00')" /></td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="podtrzeni_N">&#160;</td>
						<td class="velikost5 podtrzeni_N" align="right">počet záznamov:&#32;<xsl:value-of select="count(*)"/></td>
			
					</tr>
			
					<tr><td height="30"></td></tr>
			
					<!-- Cenový panel - rozpis sazeb DPH  -->
					<tr>
						<td colspan="11" align="right">
			
							<table cellspacing="1" cellpadding="0" width="100%" border="0">
								<tbody>
									<tr>
										<td width="50%"/>
			
										<td>
											<table bordercolor="black" cellspacing="0" cellpadding="2" width="100%" border="0">
												<tbody>
				
													<!-- Cenový panel - řádky sazeb -->
													<xsl:call-template name="CenovyPanel"/>

												</tbody>
											</table>
										</td>
									</tr>
			
								</tbody>
							</table>
						</td>
					</tr>

					<tr><td height="30"></td></tr>

					<!-- Vyřízené vs. nevyřízené doklady -->
					<tr>
						<td colspan="11" align="right">

							<table cellspacing="1" cellpadding="0" width="100%" border="0">
							<tbody>
								<tr>
									<td width="50%"/>
									<td>
										<table bordercolor="black" cellspacing="0" cellpadding="2" width="100%" border="0">
											<tbody>
											<tr>
												<td class="velikost5 tucne podtrzeni_D" height="23" width="15%">&#160;</td>
												<td class="velikost5 tucne podtrzeni_D" align="right" >Počet</td>
												<td class="velikost5 tucne podtrzeni_D" align="right" width="28%">Základ</td>
												<td class="velikost5 tucne podtrzeni_D" align="right" width="28%">Celkom&#160;</td>
											</tr>
							
											<tr>
												<td class="velikost5 podtrzeni_L tucne" height="23" align="right">Vybavené</td>
												<td class="velikost5 " align="right" ><xsl:value-of select="count(*[Vyrizeno !=''])" /></td>
												<td class="velikost5 " align="right">
													<xsl:value-of select="format-number($_vzaklad22+$_vzaklad5+$_vzaklad0+$_vzakladOstSazby, '#,##0.00')" />
												</td>
												<td class="velikost5 podtrzeni_P" align="right">
													<xsl:value-of select="format-number(sum(*/Celkem[../Vyrizeno !='']), '#,##0.00')" />&#160;
												</td>
											</tr>
							
											<tr>
												<td class="velikost5 podtrzeni_L tucne" height="23" align="right">Nevybavené</td>
												<td class="velikost5 " align="right" ><xsl:value-of select="count(*[(Vyrizeno='') or (not(Vyrizeno))])" /></td>
												<td class="velikost5 " align="right">
													<xsl:value-of select="format-number($_nzaklad22+$_nzaklad5+$_nzaklad0+$_nzakladOstSazby, '#,##0.00')" />
												</td>
												<td class="velikost5 podtrzeni_P" align="right">
													<xsl:value-of select="format-number(sum(*/Celkem[(../Vyrizeno='') or (not(..//Vyrizeno))]), '#,##0.00')" />&#160;
												</td>
											</tr>
											
											<tr>
												<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_L" align="right" height="23">CELKOM</td>
												<td class="velikost5 podtrzeni_NT podtrzeni_D" align="right"><xsl:value-of select="count(*)" /></td>
												<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right"><xsl:value-of select="format-number($Zaklad, '#,##0.00')" /></td>
												<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_P" align="right"><xsl:value-of select="format-number($Zaklad + $DPH, '#,##0.00')" />&#160;</td>
											</tr>
											</tbody>
										</table>
										<br />
										<br />
										<br />
									</td>
								</tr>

							</tbody>
						</table>
					</td>
				</tr>
	
					<tr>
						<td class="velikost5 podtrzeni_N" height="25" colspan="11">Vytiskl(a): &#32;<span id="Datum"></span></td>
					</tr>

				</table>
			</body>

		</html>
	</xsl:template>


	<!-- -->
	<xsl:template match="NabVyd">

		<tr>
			<td class="velikost5 podtrzeni_NT" height="23"><xsl:value-of select="Doklad" />&#160;</td>
			<td  class="velikost5 podtrzeni_NT" align="left">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="Vystaveno" />
					</xsl:with-param>
				</xsl:call-template>&#160;
			</td>
			<td  class="velikost5 podtrzeni_NT" align="left">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="Vyridit_do" />
					</xsl:with-param>
				</xsl:call-template>&#160;
			</td>
			<td  class="velikost5 podtrzeni_NT" align="left">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="Vyrizeno" />
					</xsl:with-param>
				</xsl:call-template>&#160;
			</td>
			<td class="velikost5 podtrzeni_NT" align="right">&#160;<xsl:apply-templates select="SouhrnDPH"></xsl:apply-templates></td>
			<td class="velikost5 podtrzeni_NT" align="right">&#160;<xsl:value-of select="format-number(Celkem, '###,##0.00')" />	</td>
			<td class="podtrzeni_NT">&#160;</td>
			<td class="velikost5 podtrzeni_NT" align="left"><xsl:value-of select="Zakazka" />&#160;</td>
			<td class="velikost5 podtrzeni_NT" align="left"><xsl:value-of select="Stredisko" />&#160;</td>
			<td class="velikost5 podtrzeni_NT" align="left"><xsl:value-of select="Cinnost" />&#160;</td>
			<td class="velikost5 podtrzeni_NT" align="left"><xsl:value-of select="Popis" />&#160;</td>
		</tr>

	</xsl:template>

	<!-- -->
	<xsl:template match="SouhrnDPH">
		<xsl:variable name="Zaklad" select="Zaklad0 + Zaklad5 + Zaklad22 + sum(SeznamDalsiSazby/DalsiSazba/Zaklad)"/>
		<xsl:value-of select="format-number($Zaklad, '###,##0.00')"/>
	</xsl:template>

	<!-- -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum" />
		<xsl:variable name="den" select="substring($_datum, 9,2)"></xsl:variable>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"></xsl:variable>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"></xsl:variable>
		<xsl:variable name="datum" select="concat($den,'.',$mesic,'.',$rok)"></xsl:variable>
		<xsl:value-of select="$datum"/>
	</xsl:template>
	<!-- -->

</xsl:stylesheet>
