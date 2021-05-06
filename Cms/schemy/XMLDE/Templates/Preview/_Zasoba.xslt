<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>

<!-- Transformační šablona náhledu pro zásoby ve tvaru HTML.
Autor: Marek Vykydal
 -->

	<xsl:template match="/">
		<html>
			<head>
				<title>Zásoby</title>
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
			<body>
				<xsl:apply-templates></xsl:apply-templates>
			</body>
		</html>

	</xsl:template>


	<!-- hlavni element -->
	<xsl:template match="MoneyData">
		<xsl:apply-templates></xsl:apply-templates>
	</xsl:template>


	<!-- seznam zásob -->
	<xsl:template match="SeznamZasoba">
		<xsl:apply-templates>
			<xsl:with-param name="Pocet" select="count(Zasoba)"/>
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


	<!-- karta zásoby -->
	<xsl:template match="Zasoba">
		<xsl:param name="Pocet"/>


      <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
 	     <tr><td class="velikost1 tucne podtrzeni_D3" height="27">Karta zásoby</td></tr>
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
					<td class="velikost2 tucne"><xsl:value-of select="KmKarta/Popis"/>&#160;</td>
					<td class="velikost2 tucne"><xsl:value-of select="KmKarta/Zkrat"/>&#160;</td>
			          </tr>
			</table>
	      </td>
      </tr>


      <!-- podrobné informace o zásobě -->
      <tr><td height="15"></td></tr>	

      <tr>
		<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%"  border="0" bordercolor="green">
		          <tr>
		          	<td class="velikost4 tucne" width="20%">Stav zásoby:</td>
		          	<td class="velikost4" width="30%">
					<xsl:choose>
						<xsl:when test="string-length(StavZasoby/Zasoba)>0 "><xsl:value-of select="format-number(StavZasoby/Zasoba, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>	
		          	</td>
			       <td class="velikost4" colspan="3">
				       <xsl:if test="string-length(KmKarta/GUID)>0">
						<b>GUID km. karty:&#160;</b><xsl:value-of select="KmKarta/GUID"/>       
				       </xsl:if>
			       </td>
			    </tr>

				<xsl:if test="string-length(KmKarta/MJ)>0">
			          <tr>
			          	<td class="velikost4 tucne">MJ:</td>
			          	<td class="velikost4 " colspan="4"><xsl:value-of select="KmKarta/MJ"/>&#160;</td>
			          </tr>
				</xsl:if>

			   <tr>
		          	<td>&#160;</td>
		          </tr>


		          <tr>
		          	<td class="velikost4 tucne">Rezervácie:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="string-length(StavZasoby/Rezervace)>0 "><xsl:value-of select="format-number(StavZasoby/Rezervace, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>
				</td>
		          	<td class="velikost4 tucne" width="20%">Minimálny limit:</td>
		          	<td class="velikost4 " width="15%" >
					<xsl:choose>
						<xsl:when test="konfigurace/Ev_Min = '1' "><xsl:value-of select="format-number(konfigurace/Minimum, '#,##0.0000')"/>&#160;</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>	
		          	</td>
				<td width="15%"/>
		          </tr>
		
		          <tr>
		          	<td class="velikost4 tucne">Objednané:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="string-length(StavZasoby/Objednano)>0 "><xsl:value-of select="format-number(StavZasoby/Objednano, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
		          	<td class="velikost4 tucne">Maximálny limit:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="konfigurace/Ev_Max = '1' "><xsl:value-of select="format-number(konfigurace/Maximum, '#,##0.0000')"/>&#160;</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>	
		          	</td>
		          	<td/>
		          </tr>


			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Katalóg:</td>
		          	<td class="velikost4 "><xsl:value-of select="KmKarta/Katalog"/>&#160;</td>
		          	<td class="velikost4 tucne" >Záručná doba:</td>
		          	<td class="velikost4 " >
					<xsl:choose>
						<xsl:when test="KmKarta/TypZarDoby = 'N' ">nie je žiadna záruka</xsl:when>
						<xsl:when test="(KmKarta/TypZarDoby = 'D') and (string-length(KmKarta/ZarDoba)>0) "><xsl:value-of select="KmKarta/ZarDoba"/> dní</xsl:when>
						<xsl:when test="(KmKarta/TypZarDoby = 'M') and (string-length(KmKarta/ZarDoba)>0) "><xsl:value-of select="KmKarta/ZarDoba"/> mesiacov</xsl:when>
						<xsl:when test="(KmKarta/TypZarDoby = 'R') and (string-length(KmKarta/ZarDoba)>0) "><xsl:value-of select="KmKarta/ZarDoba"/> rokov</xsl:when>
						<xsl:when test="KmKarta/TypZarDoby = 'S' ">stála (doživotná)</xsl:when>
					</xsl:choose>		          	
		          	</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Čiarovy kód:</td>
		          	<td class="velikost4 "><xsl:value-of select="KmKarta/BarCode"/>&#160;</td>
		          	<td class="velikost4 tucne" >Kód štátu pôvodu:</td>
		          	<td class="velikost4 " ><xsl:value-of select="KmKarta/KodStatu"/>&#160;</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">PLU:</td>
		          	<td class="velikost4 "><xsl:value-of select="KmKarta/UzivCode"/>&#160;</td>
		          	<td class="velikost4 tucne" >Kód komb. nomenklatury:</td>
		          	<td class="velikost4 " ><xsl:value-of select="KmKarta/KodKN"/>&#160;</td>
				<td/>
		          </tr>


			   <tr>
		          	<td>&#160;</td>
		          </tr>


		          <tr>
		          	<td class="velikost4 tucne">Typ skladovej karty:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="KmKarta/TypKarty = 'jednoducha' ">Jednoduchá karta</xsl:when>
						<xsl:when test="KmKarta/TypKarty = 'sluzba' ">Služba</xsl:when>
						<xsl:when test="KmKarta/TypKarty = 'sada' ">Sada</xsl:when>
						<xsl:when test="KmKarta/TypKarty = 'komplet' ">Komplet</xsl:when>
						<xsl:when test="KmKarta/TypKarty = 'vyrobek' ">Výrobok</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
		          	<td class="velikost4 tucne" >Hmotnosť:</td>
		          	<td class="velikost4 " >
					<xsl:choose>
						<xsl:when test="KmKarta/Hmotnost != 0 "><xsl:value-of select="format-number(KmKarta/Hmotnost, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Druh zásoby:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="konfigurace/Druh_zas = 'M' ">Materiál</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'Z' ">Tovar</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'V' ">Vlastná výroba</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'O' ">Ostatné</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
		          	</td>
		          	<td class="velikost4 tucne" >Objem:</td>
		          	<td class="velikost4 " >
					<xsl:choose>
						<xsl:when test="KmKarta/Objem != 0 "><xsl:value-of select="format-number(KmKarta/Objem, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td/>
		          </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>
		          
		          
		          <tr>
		          	<td class="velikost4 tucne">
					<xsl:choose>
						<xsl:when test="Sklad/CenikSklad=1">Cenníkový sklad:</xsl:when>
						<xsl:otherwise>Sklad:</xsl:otherwise>
					</xsl:choose>
		          	</td>
		          	<td class="velikost4 tucne">
					<xsl:choose>
						<xsl:when test="string-length(Sklad/Nazev)>0">
							<xsl:value-of select="translate(Sklad/Nazev,'áabcčdďeéěfghiíjklmnňoópqrřsštťuúůvwxyýzž','ÁABCČDĎEÉĚFGHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate(Sklad/KodSkladu,'áabcčdďeéěfghiíjklmnňoópqrřsštťuúůvwxyýzž','ÁABCČDĎEÉĚFGHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽ')"/>&#160;
						</xsl:otherwise>
					</xsl:choose>
				</td>
		          	<td class="velikost4" colspan="3">
				       <xsl:if test="string-length(Sklad/GUID)>0">
						<b>GUID skladu:&#160;</b><xsl:value-of select="Sklad/GUID"/>       
				       </xsl:if>
				</td>
		          </tr>

				<xsl:if test="(string-length(Skupina/Nazev)>0) or (string-length(Skupina/Zkratka)>0)">
					          <tr>
					          	<td class="velikost4 tucne">Skupina:</td>
					          	<td class="velikost4">
								<xsl:choose>
									<xsl:when test="string-length(Skupina/Nazev)>0"><xsl:value-of select="Skupina/Nazev"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="Skupina/Zkratka"/>&#160;</xsl:otherwise>
								</xsl:choose>
							</td>
							<td/>
					          </tr>
				</xsl:if>

			   <tr>
		          	<td>&#160;</td>
		          </tr>


		          <tr>
		          	<td class="velikost4 tucne">Posledný nákup:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="string-length(Posl_Nak)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="Posl_Nak"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>
		          	</td>
		          	<td class="velikost4 tucne" >Obstarávacia cena (skladová):</td>
		          	<td class="velikost4 " align="right">
					<xsl:choose>
						<xsl:when test="string-length(Nak_Cena)>0 "><xsl:value-of select="format-number(Nak_Cena, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td width="15%"/>
		          </tr>
		
		          <tr>
		          	<td class="velikost4 tucne">Posledný predaj:</td>
		          	<td class="velikost4 ">
		          		<xsl:choose>
						<xsl:when test="string-length(Posl_Prod)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="Posl_Prod"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>
				</td>
		          	<td class="velikost4 tucne">Posledná nákupná cena bez DPH:</td>
		          	<td class="velikost4 " align="right">
					<xsl:choose>
						<xsl:when test="string-length(Posl_N_Cen)>0 "><xsl:value-of select="format-number(Posl_N_Cen, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">&#160;</td>
		          	<td class="velikost4 ">&#160;</td>
		          	<td class="velikost4 tucne">Základná predajná cena:</td>
		          	<td class="velikost4 " align="right">
					<xsl:choose>
						<xsl:when test="string-length(PC[1]/Cena1/Cena)>0 "><xsl:value-of select="format-number(PC[1]/Cena1/Cena, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
		          	</td>
		          	<td class="velikost4 ">&#160;
					<xsl:if test="PC[1]/Cena1/Cena != 0">
						<xsl:choose>
							<xsl:when test="PC[1]/SDPH=1">s DPH</xsl:when>
							<xsl:when test="PC[1]/SDPH=0">bez DPH</xsl:when>
						</xsl:choose>
					</xsl:if>
		          	</td>
		          </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Posledná inventúra:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="string-length(DatInv)>0">
							<xsl:call-template name="_datum_">
								<xsl:with-param name="_datum"><xsl:value-of select="DatInv"/></xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>
				</td>
		          	<td class="velikost4 tucne" ><xsl:if test="string-length(konfigurace/SDPH_Nakup)>0">DPH pre nákup:</xsl:if></td>
		          	<td class="velikost4 " >
		          		<xsl:if test="string-length(konfigurace/SDPH_Nakup)>0">
		          			<xsl:value-of select="format-number(konfigurace/SDPH_Nakup, '#0')"/> %
		          		</xsl:if>
		          	</td>
				<td width="15%"/>
		          </tr>
		
		          <tr>
		          	<td class="velikost4 tucne">Inventurne množstvo:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="(string-length(DatInv)>0) and (string-length(MnInv)>0)">
			          			<xsl:value-of select="format-number(MnInv, '#,##0.0000')"/>
						</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>
		          	</td>
		          	<td class="velikost4 tucne"><xsl:if test="string-length(konfigurace/SDPH_Prod)>0">DPH pre predaj:</xsl:if></td>
		          	<td class="velikost4 ">
		          		<xsl:if test="string-length(konfigurace/SDPH_Prod)>0">
		          			<xsl:value-of select="format-number(konfigurace/SDPH_Prod, '#0')"/> %
		          		</xsl:if>
		          	</td>
				<td/>
		          </tr>

			<xsl:if test="string-length(konfigurace/Cinnosti)>0">
				   <tr>
			          	<td>&#160;</td>
			          </tr>
	
			          <tr>
			          	<td class="velikost4 tucne">Činnosti:</td>
			          	<td class="velikost4 " colspan="4"><xsl:value-of select="konfigurace/Cinnosti"/></td>
			          </tr>
			</xsl:if>


		        </table>
	      </td>
	</tr>


     <!-- elektronický obchod -->
	<xsl:if test="(eshop/eSkup/Name) or (eshop/eSkup/Descript)">

	      <tr><td height="15"></td></tr>	
	      <tr><td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%">
		          
			          <tr>
			          	<td class="velikost4 tucne zarovnani_N" width="20%">Kategórie el. obchodu:</td>
			          	<td class="velikost4 zarovnani_N" width="80%" colspan="2"><xsl:apply-templates select="eshop/eSkup"/></td>
			          </tr>

					<xsl:if test="string-length(Vyrobce)>0">
				          <tr>
				          	<td class="velikost4 tucne">Výrobca:</td>
						<td class="velikost4" colspan="2"><xsl:value-of select="Vyrobce"/></td>
				          </tr>
					</xsl:if>

			          <tr>
			          	<td class="velikost4 tucne">Zľava:</td>
					<td class="velikost4" colspan="2">
						<xsl:choose>
							<xsl:when test="Sleva != '0' "><xsl:value-of select="Sleva"/> %</xsl:when>
							<xsl:otherwise>-</xsl:otherwise>
						</xsl:choose>	
					</td>
			          </tr>

					<xsl:choose>
						<xsl:when test="Novinka = '1' ">
					          <tr>
							<td/>
							<td class="velikost9 pismo1" width="1%">ţ</td>
							<td class="velikost4 tucne"> Novinka</td>
					          </tr>
						</xsl:when>
					</xsl:choose>	

					<xsl:choose>
						<xsl:when test="Pripravuje = '1' ">
					          <tr>
							<td/>
							<td class="velikost9 pismo1" width="1%">ţ</td>
							<td class="velikost4 tucne"> Pripravuje sa</td>
					          </tr>
						</xsl:when>
					</xsl:choose>	

					<xsl:choose>
						<xsl:when test="Vyprodej = '1' ">
					          <tr>
							<td/>
							<td class="velikost9 pismo1" width="1%">ţ</td>
							<td class="velikost4 tucne"> Výpredaj</td>
					          </tr>
						</xsl:when>
					</xsl:choose>	

					<xsl:choose>
						<xsl:when test="ZakazProde = '1' ">
					          <tr>
							<td/>
							<td class="velikost9 pismo1" width="1%">ţ</td>
							<td class="velikost4 tucne"> Nepredávať</td>
					          </tr>
						</xsl:when>
					</xsl:choose>	

				<xsl:if test="(Novinka = '0' ) and (Pripravuje = '0' ) and (Vyprodej = '0' ) and (ZakazProde = '0' )">
			          <tr><td>&#160;</td></tr>
				</xsl:if>      


		        </table>
	      </td></tr>

	</xsl:if>      


      <!-- rozšířený popis -->
	<xsl:if test="(string-length(KmKarta/Popis1)>0) or (string-length(KmKarta/Pozn1)>0) or (string-length(KmKarta/Popis2)>0) or (string-length(KmKarta/Pozn2)>0) or (string-length(KmKarta/Popis3)>0) or (string-length(KmKarta/Pozn3)>0)">

	      <tr><td height="15"></td></tr>	
	      <tr><td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%">
		          
			          <tr>
			          	<td class="velikost4 tucne zarovnani_N" width="20%">Rozšírený popis:</td>

			          	<td class="velikost4 zarovnani_N" width="80%" rowspan="3" >
						<xsl:if test="string-length(KmKarta/Popis1)>0"><xsl:value-of select="KmKarta/Popis1"/>
							<xsl:choose>
								<xsl:when test="string-length(KmKarta/Pozn1)>0"><br/></xsl:when>
								<xsl:otherwise><br/><br/></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(KmKarta/Pozn1)>0"><i><xsl:value-of select="KmKarta/Pozn1"/></i><br/><br/></xsl:if>

						<xsl:if test="string-length(KmKarta/Popis2)>0"><xsl:value-of select="KmKarta/Popis2"/>
							<xsl:choose>
								<xsl:when test="string-length(KmKarta/Pozn2)>0"><br/></xsl:when>
								<xsl:otherwise><br/><br/></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(KmKarta/Pozn2)>0"><i><xsl:value-of select="KmKarta/Pozn2"/></i><br/><br/></xsl:if>

						<xsl:if test="string-length(KmKarta/Popis3)>0"><xsl:value-of select="KmKarta/Popis3"/>
							<xsl:choose>
								<xsl:when test="string-length(KmKarta/Pozn3)>0"><br/></xsl:when>
								<xsl:otherwise></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(KmKarta/Pozn3)>0"><i><xsl:value-of select="KmKarta/Pozn3"/></i></xsl:if>
			          	</td>
			          </tr>
	
			          <tr><td>&#160;</td></tr>
			          <tr><td>&#160;</td></tr>
		        </table>
	      </td></tr>

	</xsl:if>


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


      <!-- mezera -->
      <tr><td height="25"></td></tr>


  <!-- složení kmenové karty -->      
	<xsl:if test="count(KmKarta/Slozeni/Komponenta)>0">	

	      <tr>
	      	  <td>
		        <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			          <tr>
			          	<td class="velikost2 tucne" colspan="5">Definícia zostavy</td>
			          </tr>

				   <tr><td height="5"/></tr>

			          <tr>
			          	<td class="velikost4 tucne odsad_L podtrzeni_D" width="10%" height="23">Poradie</td>
			          	<td class="velikost4 tucne podtrzeni_D"  width="35%">Komponent</td>
			          	<td class="velikost4 tucne podtrzeni_D">Sklad</td>
			          	<td class="velikost4 tucne podtrzeni_D" align="right">Počet MJ</td>
			          	<td class="podtrzeni_D" width="10%">&#160;</td>
			          </tr>
	
					<xsl:apply-templates select="KmKarta/Slozeni/Komponenta"/>

				   <tr>
					<td class="podtrzeni_N" colspan="5" height="25">&#160;</td>
				   </tr>

		        </table>
	        </td>
	      </tr>

	</xsl:if>



  <!-- seznam prodejních cen -->      
	<xsl:if test="count(PC)>0">
	
	      <tr>
	      	  <td>
		        <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			          <tr>
			          	<td class="velikost2 tucne" colspan="5">Zoznam predajných cien</td>
			          </tr>

				   <tr><td height="5"/></tr>
			          
			          <tr>
			          	<td class="velikost4 tucne odsad_L podtrzeni_D" width="30%" height="23">Cenová hladina</td>
			          	<td class="velikost4 tucne podtrzeni_D" width="10%" align="right">Cena</td>
			          	<td class="podtrzeni_D" width="5%">&#160;</td>
			          	<td class="velikost4 tucne podtrzeni_D" width="10%">Typ ceny</td>
			          	<td class="podtrzeni_D" >&#160;</td>
			          </tr>
	
					<xsl:apply-templates select="PC"/>

				   <tr>
					<td class="podtrzeni_N" colspan="5" height="25">&#160;</td>
				   </tr>
	
		        </table>
	        </td>
	      </tr>
	</xsl:if>


  <!-- seznam parametrů -->      
	<xsl:if test="count(KmKarta/SeznamParametruKarty/ParametrKarty)>0">
	
	      <tr>
	      	  <td>
		        <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			          <tr>
			          	<td class="velikost2 tucne" colspan="3">Zoznam parametrov</td>
			          </tr>

				   <tr><td height="5"/></tr>

			          <tr>
			          	<td class="velikost4 tucne odsad_L podtrzeni_D" width="10%" height="23">Poradie</td>
			          	<td class="velikost4 tucne podtrzeni_D" width="35%">Názov</td>
			          	<td class="velikost4 tucne podtrzeni_D">Hodnota</td>
			          </tr>
	
						<xsl:apply-templates select="KmKarta/SeznamParametruKarty/ParametrKarty"/>

				   <tr>
					<td class="podtrzeni_N" colspan="3" height="25">&#160;</td>
				   </tr>

		        </table>
	        </td>
	      </tr>

	</xsl:if>


  <!-- seznam alternativ -->      
	<xsl:if test="count(SeznamAlternativ/Alternativa)>0">
	
	      <tr>
	      	  <td>
		        <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			          <tr>
			          	<td class="velikost2 tucne" colspan="5">Zoznam alternatív</td>
			          </tr>

				   <tr><td height="5"/></tr>

			          <tr>
			          	<td class="velikost4 tucne odsad_L podtrzeni_D" width="10%" height="23">Poradie</td>
			          	<td class="velikost4 tucne podtrzeni_D"  width="35%">Komponent</td>
			          	<td class="velikost4 tucne podtrzeni_D">Sklad</td>
			          	<td class="velikost4 tucne podtrzeni_D" >Druh komponentu</td>
			          	<td class="velikost4 tucne podtrzeni_D" align="center">Obojstranná väzba</td>
			          </tr>
	
					<xsl:apply-templates select="SeznamAlternativ/Alternativa"/>

				   <tr>
					<td class="podtrzeni_N" colspan="5" height="25">&#160;</td>
				   </tr>

		        </table>
	        </td>
	      </tr>

	</xsl:if>


  <!-- seznam příslušenství -->      
	<xsl:if test="count(SeznamPrislusenstvi/Prislusenstvi)>0">	
	
	      <tr>
	      	  <td>
		        <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
			          <tr>
			          	<td class="velikost2 tucne" colspan="5">Zoznam príslušenstva</td>
			          </tr>

				   <tr><td height="5"/></tr>

			          <tr>
			          	<td class="velikost4 tucne odsad_L podtrzeni_D" width="10%" height="23">Poradie</td>
			          	<td class="velikost4 tucne podtrzeni_D"  width="35%">Komponent</td>
			          	<td class="velikost4 tucne podtrzeni_D">Sklad</td>
			          	<td class="velikost4 tucne podtrzeni_D" align="right">Počet MJ</td>
			          	<td class="podtrzeni_D" width="10%">&#160;</td>
			          </tr>

					<xsl:apply-templates select="SeznamPrislusenstvi/Prislusenstvi"/>
	
				   <tr>
					<td class="podtrzeni_N" colspan="5" height="25">&#160;</td>
				   </tr>

		        </table>
	        </td>
	      </tr>

	</xsl:if>


		<!-- mezera na konci karty -->
	      <tr><td height="50"></td></tr>	
	

		<!--<xsl:if test="position() != $Pocet ">	-->									<!-- jestliže se nejedná o poslední entitu -->
			<tr>	<td>&#160;<div style="page-break-after: always"/></td></tr>		<!-- přechod na novou stranu -->
		<!--</xsl:if>-->


      </table><!-- konec tabulky karty -->
    </table><!-- konec cele karty (vcetne nadpisu) -->

  </xsl:template>



  <!-- komponenty -->
	<xsl:template match="Komponenta">
		<xsl:param name="Poradi"/>

	  <tr>
		<td class="velikost4 odsad_L podtrzeni_NT"  height="23">
			<xsl:value-of select="$Poradi"/><xsl:if test="string-length($Poradi)>0">.</xsl:if><xsl:value-of select="@Poradi"/>&#160;
		</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(KmKarta/Popis)>0"><xsl:value-of select="KmKarta/Popis"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="KmKarta/Zkrat"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(Sklad/Nazev)>0"><xsl:value-of select="Sklad/Nazev"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="Sklad/KodSkladu"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" align="right"><xsl:value-of select="format-number(PocMJ, '#,##0.0000')"/>&#160;</td>
		<td class="podtrzeni_NT">&#160;</td>

	    </tr>

		<xsl:apply-templates select="KmKarta/Slozeni/Komponenta">
			<xsl:with-param name="Poradi">
				<xsl:value-of select="$Poradi"/><xsl:if test="string-length($Poradi)>0">.</xsl:if><xsl:value-of select="@Poradi"/>
			</xsl:with-param>
		</xsl:apply-templates>

	</xsl:template>


  <!-- prodejní ceny -->
	<xsl:template match="PC">
	  <tr>

		<td class="velikost4 odsad_L podtrzeni_NT"  height="23">
			<xsl:choose>
				<xsl:when test="Hladina/Zkrat"><xsl:value-of select="Hladina/Zkrat"/></xsl:when>
				<xsl:otherwise>Základná cena</xsl:otherwise>
			</xsl:choose>	
	      	</td>

		<td class="velikost4 podtrzeni_NT" align="right"><xsl:value-of select="format-number(Cena1/Cena, '#,##0.00')"/>&#160;</td>
		<td class="velikost4 podtrzeni_NT">&#160;<xsl:value-of select="Mena/Kod" /></td>

		<td class="velikost4 podtrzeni_NT">
			<xsl:choose>
				<xsl:when test="SDPH=1">s DPH</xsl:when>
				<xsl:when test="SDPH=0">bez DPH</xsl:when>
			</xsl:choose>	      
		</td>
		<td class="podtrzeni_NT">&#160;</td>

	    </tr>
	</xsl:template>


  <!-- parametry karty -->
	<xsl:template match="ParametrKarty">
	<tr>
		<td class="velikost4 odsad_L podtrzeni_NT"  height="23"><xsl:value-of select="Poradi"/>&#160;</td>
		<td class="velikost4 podtrzeni_NT"><xsl:value-of select="Parametr/Nazev"/>&#160;</td>
		<td class="velikost4 podtrzeni_NT">
			<xsl:choose>
				<xsl:when test="Parametr/Druh='N' ">
				<xsl:value-of select="format-number(Value, '#,##0.00')"/>&#160;<xsl:value-of select="Parametr/MJ"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="Value"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>
	</tr>
	</xsl:template>


  <!-- alternativy -->
	<xsl:template match="Alternativa">
	  <tr>

		<td class="velikost4 odsad_L podtrzeni_NT"  height="23"><xsl:value-of select="Poradi"/>&#160;</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(KmKarta/Popis)>0"><xsl:value-of select="KmKarta/Popis"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="KmKarta/Zkrat"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(Sklad/Nazev)>0"><xsl:value-of select="Sklad/Nazev"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="Sklad/KodSkladu"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="DruhKomp = 'A' ">alternatíva</xsl:when>
				<xsl:when test="DruhKomp = 'N' ">náhrada</xsl:when>
			</xsl:choose>
		</td>

		<td class="velikost9 pismo1 podtrzeni_NT" align="center">
			<xsl:choose>
				<xsl:when test="Symetric = '1' ">ţ</xsl:when>
				<xsl:otherwise>o</xsl:otherwise>
			</xsl:choose>
		</td>

	    </tr>
	</xsl:template>


  <!-- příslušenství -->
	<xsl:template match="Prislusenstvi">
	  <tr>

		<td class="velikost4 odsad_L podtrzeni_NT"  height="23"><xsl:value-of select="Poradi"/>&#160;</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(KmKarta/Popis)>0"><xsl:value-of select="KmKarta/Popis"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="KmKarta/Zkrat"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" >
			<xsl:choose>
				<xsl:when test="string-length(Sklad/Nazev)>0"><xsl:value-of select="Sklad/Nazev"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="Sklad/KodSkladu"/>&#160;</xsl:otherwise>
			</xsl:choose>
		</td>

		<td class="velikost4 podtrzeni_NT" align="right"><xsl:value-of select="format-number(PocMJ, '#,##0.00')"/>&#160;</td>
		<td class="podtrzeni_NT">&#160;</td>

	    </tr>
	</xsl:template>


  <!-- kategorie elektronického obchodu -->
	<xsl:template match="eSkup">
		<xsl:apply-templates select="Parent"/>

		<xsl:choose>
			<xsl:when test="string-length(Name)>0"><xsl:value-of select="Name"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="Descript"/></xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="Parent">
		<xsl:apply-templates select="Parent"/>

		<xsl:if test="Parent">
			<xsl:choose>
				<xsl:when test="string-length(Name)>0"><xsl:value-of select="Name"/> / </xsl:when>
				<xsl:otherwise><xsl:value-of select="Descript"/> / </xsl:otherwise>
			</xsl:choose>		
		</xsl:if>

	</xsl:template>


</xsl:stylesheet>
