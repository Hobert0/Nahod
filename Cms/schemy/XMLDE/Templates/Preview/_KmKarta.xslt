<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>

<!-- Transformační šablona náhledu pro kmenové karty ve tvaru HTML.
Autor: Marek Vykydal
 -->

	<xsl:template match="/">
		<html>
			<head>
				<title>Kmeňová karta</title>
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


	<!-- seznam kmenových karet -->
	<xsl:template match="SeznamKmKarta">
		<xsl:apply-templates>
			<xsl:with-param name="Pocet" select="count(KmKarta)"/>
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


	<!-- kmenová karta -->
	<xsl:template match="KmKarta">
		<xsl:param name="Pocet"/>


      <table width="100%" cellspacing="0" cellpadding="0" border="0" bordercolor="green">
 	     <tr><td class="velikost1 tucne podtrzeni_D3" height="27">Kmeňová karta</td></tr>
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
					<td class="velikost2 tucne"><xsl:value-of select="Popis"/>&#160;</td>
					<td class="velikost2 tucne"><xsl:value-of select="Zkrat"/>&#160;</td>
			          </tr>
			</table>
	      </td>
      </tr>


      <!-- podrobné informace o kmenové kartě  -->
      <tr><td height="15"></td></tr>	

      <tr>
		<td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%"  border="0" bordercolor="green">
		          <tr>
		          	<td class="velikost4 tucne" width="20%">Typ karty:</td>
		          	<td class="velikost4 " width="30%">
					<xsl:choose>
						<xsl:when test="TypKarty = 'jednoducha' ">Jednoduchá karta</xsl:when>
						<xsl:when test="TypKarty = 'sluzba' ">Služba</xsl:when>
						<xsl:when test="TypKarty = 'sada' ">Sada</xsl:when>
						<xsl:when test="TypKarty = 'komplet' ">Komplet</xsl:when>
						<xsl:when test="TypKarty = 'vyrobek' ">Výrobok</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
				</td>
			       <td class="velikost4" colspan="2">
				       <xsl:if test="string-length(GUID)>0">
						<b>GUID:&#160;</b><xsl:value-of select="GUID"/>       
				       </xsl:if>
			       </td>
			    </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Katalóg:</td>
		          	<td class="velikost4 " ><xsl:value-of select="Katalog"/>&#160;</td>
		          	<td class="velikost4 tucne"  width="20%">Záručná doba:</td>
		          	<td class="velikost4 " width="30%" >
					<xsl:choose>
						<xsl:when test="TypZarDoby = 'N' ">nie je žiadna záruka</xsl:when>
						<xsl:when test="(TypZarDoby = 'D') and (string-length(ZarDoba)>0) "><xsl:value-of select="ZarDoba"/> dní</xsl:when>
						<xsl:when test="(TypZarDoby = 'M') and (string-length(ZarDoba)>0) "><xsl:value-of select="ZarDoba"/> mesiacov</xsl:when>
						<xsl:when test="(TypZarDoby = 'R') and (string-length(ZarDoba)>0) "><xsl:value-of select="ZarDoba"/> rokov</xsl:when>
						<xsl:when test="TypZarDoby = 'S' ">stálá (doživotná)</xsl:when>
					</xsl:choose>		          	
		          	</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4"><b>Čiarový kód </b>
					<xsl:choose>
						<xsl:when test="BCTyp = 'E1' ">(EAN-13)</xsl:when>
						<xsl:when test="BCTyp = 'E8' ">(EAN-8)</xsl:when>
						<xsl:when test="BCTyp = 'UP' ">(UPC)</xsl:when>
						<xsl:when test="BCTyp = '39' ">(Code 39)</xsl:when>
						<xsl:when test="BCTyp = '2S' ">(2/5 Standard)</xsl:when>
						<xsl:when test="BCTyp = '2I' ">(2/5 Interleaved)</xsl:when>
						<xsl:when test="BCTyp = '2M' ">(Matrix 2/5)</xsl:when>
						<xsl:when test="BCTyp = '93' ">(Code 93)</xsl:when>
						<xsl:when test="BCTyp = '12' ">(Code 128)</xsl:when>
						<xsl:when test="BCTyp = 'CB' ">(Codabar)</xsl:when>
						<xsl:when test="BCTyp = 'O' ">(Ostatné)</xsl:when>
					</xsl:choose>:
		          	</td>
		          	<td class="velikost4 "><xsl:value-of select="BarCode"/>&#160;</td>
		          	<td class="velikost4 tucne" >Kód štátu pôvodu:</td>
		          	<td class="velikost4 " ><xsl:value-of select="KodStatu"/>&#160;</td>
				<td/>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">PLU:</td>
		          	<td class="velikost4 "><xsl:value-of select="UzivCode"/>&#160;</td>
		          	<td class="velikost4 tucne" >Kód komb. nomenklatúry:</td>
		          	<td class="velikost4 " ><xsl:value-of select="KodKN"/>&#160;</td>
				<td/>
		          </tr>


			   <tr>
		          	<td>&#160;</td>
		          </tr>


		          <tr>
		          	<td class="velikost4 tucne">MJ:</td>
		          	<td class="velikost4 " ><xsl:value-of select="MJ"/>&#160;</td>
		          	<td class="velikost4 tucne" >Hmotnosť:</td>
		          	<td class="velikost4 " >
					<xsl:choose>
						<xsl:when test="Hmotnost != 0 "><xsl:value-of select="format-number(Hmotnost, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td/>
		          </tr>

		          <tr>
		          	<td colspan="2"/>
		          	<td class="velikost4 tucne" >Objem:</td>
		          	<td class="velikost4 " >
					<xsl:choose>
						<xsl:when test="Objem != 0 "><xsl:value-of select="format-number(Objem, '#,##0.0000')"/></xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>		          	
				</td>
				<td/>
		          </tr>

		        </table>
	      </td>
	</tr>



      <!-- informace o zásobě -->
      <tr><td height="15"></td></tr>	

      <tr>
	      <td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
			<table width="100%">

		          <tr>
		          	<td class="velikost4 tucne" width="20%">Druh zásoby:</td>
		          	<td class="velikost4 " width="30%">
					<xsl:choose>
						<xsl:when test="konfigurace/Druh_zas = 'M' ">Materiál</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'Z' ">Tovar</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'V' ">Vlastná výroba</xsl:when>
						<xsl:when test="konfigurace/Druh_zas = 'O' ">Ostatné</xsl:when>
						<xsl:otherwise>&#160;</xsl:otherwise>
					</xsl:choose>
		          	</td>
		          	<td colspan="2"/>
		          </tr>

			   <tr>
		          	<td>&#160;</td>
		          </tr>

		          <tr>
		          	<td class="velikost4 tucne">Minimálny limit:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="konfigurace/Ev_Min = '1' "><xsl:value-of select="format-number(konfigurace/Minimum, '#,##0.0000')"/>&#160;</xsl:when>
						<xsl:otherwise>-</xsl:otherwise>
					</xsl:choose>	
		          	</td>
		          	<td class="velikost4 tucne" width="20%"><xsl:if test="string-length(konfigurace/SDPH_Nakup)>0">DPH pro nákup:</xsl:if></td>
		          	<td class="velikost4 " width="30%">
		          		<xsl:if test="string-length(konfigurace/SDPH_Nakup)>0">
		          			<xsl:value-of select="format-number(konfigurace/SDPH_Nakup, '#0')"/> %
		          		</xsl:if>
		          	</td>
				<td/>
		          </tr>
		
		          <tr>
		          	<td class="velikost4 tucne">Maximálny limit:</td>
		          	<td class="velikost4 ">
					<xsl:choose>
						<xsl:when test="konfigurace/Ev_Max = '1' "><xsl:value-of select="format-number(konfigurace/Maximum, '#,##0.0000')"/>&#160;</xsl:when>
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
			          	<td class="velikost4 " colspan="3"><xsl:value-of select="konfigurace/Cinnosti"/></td>
			          </tr>
			</xsl:if>

			</table>
	      </td>
      </tr>



      <!-- rozšířený popis -->
	<xsl:if test="(string-length(Popis1)>0) or (string-length(Pozn1)>0) or (string-length(Popis2)>0) or (string-length(Pozn2)>0) or (string-length(Popis3)>0) or (string-length(Pozn3)>0)">

	      <tr><td height="15"></td></tr>	
	      <tr><td class="podtrzeni_P podtrzeni_L podtrzeni_N podtrzeni_D odsad_P odsad_L odsad_N odsad_D radius">
		        <table width="100%">
		          
			          <tr>
			          	<td class="velikost4 tucne zarovnani_N" width="20%">Rozšírený popis:</td>

			          	<td class="velikost4 zarovnani_N" width="80%" rowspan="3" >
						<xsl:if test="string-length(Popis1)>0"><xsl:value-of select="Popis1"/>
							<xsl:choose>
								<xsl:when test="string-length(Pozn1)>0"><br/></xsl:when>
								<xsl:otherwise><br/><br/></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(Pozn1)>0"><i><xsl:value-of select="Pozn1"/></i><br/><br/></xsl:if>

						<xsl:if test="string-length(Popis2)>0"><xsl:value-of select="Popis2"/>
							<xsl:choose>
								<xsl:when test="string-length(Pozn2)>0"><br/></xsl:when>
								<xsl:otherwise><br/><br/></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(Pozn2)>0"><i><xsl:value-of select="Pozn2"/></i><br/><br/></xsl:if>

						<xsl:if test="string-length(Popis3)>0"><xsl:value-of select="Popis3"/>
							<xsl:choose>
								<xsl:when test="string-length(Pozn3)>0"><br/></xsl:when>
								<xsl:otherwise></xsl:otherwise>
							</xsl:choose>						
						</xsl:if>
						<xsl:if test="string-length(Pozn3)>0"><i><xsl:value-of select="Pozn3"/></i></xsl:if>
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
	<xsl:if test="count(Slozeni/Komponenta)>0">	

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
	
					<xsl:apply-templates select="Slozeni/Komponenta"/>

				   <tr>
					<td class="podtrzeni_N" colspan="5" height="25">&#160;</td>
				   </tr>

		        </table>
	        </td>
	      </tr>

	</xsl:if>


  <!-- seznam parametrů -->      
	<xsl:if test="count(SeznamParametruKarty/ParametrKarty)>0">
	
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
	
						<xsl:apply-templates select="SeznamParametruKarty/ParametrKarty"/>

				   <tr>
					<td class="podtrzeni_N" colspan="3" height="25">&#160;</td>
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

</xsl:stylesheet>
