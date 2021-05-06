<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2008 sp1 (http://www.altova.com) by Dusan Pesko (CIGLER SOFTWARE, a.s.) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- Transformační šablona náhledu určená pro doklady ve tvaru HTML - cenový panel - SK lokalizácia.
Autor: Marek Vykydal
 -->
	<xsl:variable name="Razeni">1</xsl:variable>
	<!-- ZPŮSOB ŘAZENÍ na cenovém panelu: 1 = vzestupně, 2 = sestupně -->
	<!-- CENOVÝ PANEL -->
	<xsl:template name="CenovyPanel">
		<xsl:param name="Rezim"/>
		<!-- Režim výpočtu:
																		 1 - cenový panel určený pro doklad v domácí měně
																		 2 - cenový panel určený pro doklad v cizí měně
																		 jinak cenový panel určený pro seznam dokladů (vždy v domácí měně) -->
		<!-- Počet výskytů všech sazeb DPH -->
		<xsl:variable name="VyskytSazba0">
			<xsl:choose>
				<xsl:when test="($Rezim = 1) and (SouhrnDPH/Zaklad0)">1</xsl:when>
				<xsl:when test="($Rezim = 2) and (Valuty/SouhrnDPH/Zaklad0)">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*[SouhrnDPH/Zaklad0])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="VyskytSSazby">
			<xsl:choose>
				<xsl:when test="($Rezim = 1) and ((SSazba) or (SazbaDPH1) or (SouhrnDPH/Zaklad5) or (SouhrnDPH/DPH5))">1</xsl:when>
				<xsl:when test="($Rezim = 2) and ((SSazba) or (SazbaDPH1) or (Valuty/SouhrnDPH/Zaklad5) or (Valuty/SouhrnDPH/DPH5))">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*[(SSazba) or (SazbaDPH1) or (SouhrnDPH/Zaklad5) or (SouhrnDPH/DPH5)])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="VyskytZSazby">
			<xsl:choose>
				<xsl:when test="($Rezim = 1) and ((ZSazba) or (SazbaDPH2) or (SouhrnDPH/Zaklad22) or (SouhrnDPH/DPH22))">1</xsl:when>
				<xsl:when test="($Rezim = 2) and ((ZSazba) or (SazbaDPH2) or (Valuty/SouhrnDPH/Zaklad22) or (Valuty/SouhrnDPH/DPH22))">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*[(ZSazba) or (SazbaDPH2) or (SouhrnDPH/Zaklad22) or (SouhrnDPH/DPH22)])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="VyskytDalsiSazby">
			<xsl:choose>
				<xsl:when test="($Rezim = 1)">
					<xsl:value-of select="count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
				</xsl:when>
				<xsl:when test="($Rezim = 2)">
					<xsl:value-of select="count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="CelkemVyskyt">
			<xsl:value-of select="$VyskytSazba0+$VyskytSSazby+$VyskytZSazby+$VyskytDalsiSazby"/>
		</xsl:variable>
		<xsl:call-template name="CenovyPanel_Hlavicka">
			<xsl:with-param name="Rezim" select="$Rezim"/>
			<xsl:with-param name="CelkemVyskyt" select="$CelkemVyskyt"/>
		</xsl:call-template>
		<xsl:call-template name="CenovyPanel_Radky">
			<xsl:with-param name="Rezim" select="$Rezim"/>
		</xsl:call-template>
		<xsl:call-template name="CenovyPanel_Zaver">
			<xsl:with-param name="Rezim" select="$Rezim"/>
			<xsl:with-param name="CelkemVyskyt" select="$CelkemVyskyt"/>
		</xsl:call-template>
	</xsl:template>
	<!-- CENOVÝ PANEL - HLAVIČKA -->
	<xsl:template name="CenovyPanel_Hlavicka">
		<xsl:param name="Rezim"/>
		<xsl:param name="CelkemVyskyt"/>
		<xsl:choose>
			<xsl:when test="($CelkemVyskyt &gt; 0)">
				<tr>
					<xsl:choose>
						<xsl:when test="$Rezim = 2">
							<!-- Doklad v cizí měně - kurz  -->
							<td class="velikost5 tucne podtrzeni_D" height="23" width="22%" align="right">
								<xsl:value-of select="Valuty/Mena/Mnozstvi"/> EUR =&#160;
								<xsl:value-of select="(-1)*(format-number(Valuty/Mena/Kurs,'#,##0.0000'))"/>&#160;
								<xsl:value-of select="Valuty/Mena/Kod"/>
							</td>
						</xsl:when>
						<xsl:otherwise>
							<td class="velikost5 tucne podtrzeni_D" height="23" width="15%" align="right">Sadzba</td>
						</xsl:otherwise>
					</xsl:choose>
					<td class="velikost5 tucne podtrzeni_D" align="right">Základ</td>
					<td class="velikost5 tucne podtrzeni_D" align="right" width="28%">DPH</td>
					<td class="velikost5 tucne podtrzeni_D" align="right" width="28%">Spolu&#160;</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$Rezim = 2">&#160;
						<!-- Doklad v cizí měně - kurz  -->
					<td class="velikost5 tucne" height="23">
						<xsl:value-of select="Valuty/Mena/Mnozstvi"/> EUR =&#160;
								<xsl:value-of select="(-1)*(format-number(Valuty/Mena/Kurs, '#,##0.0000'))"/>&#160;
								<xsl:value-of select="Valuty/Mena/Kod"/>
					</td>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- CENOVÝ PANEL - ZÁVĚR -->
	<xsl:template name="CenovyPanel_Zaver">
		<xsl:param name="Rezim"/>
		<xsl:param name="CelkemVyskyt"/>
		<xsl:if test="($CelkemVyskyt &gt; 0)">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<tr>
						<xsl:variable name="DPH" select="sum(SouhrnDPH/DPH5) + sum(SouhrnDPH/DPH22) + sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>
						<xsl:variable name="Zaklad" select="sum(SouhrnDPH/Zaklad0) + sum(SouhrnDPH/Zaklad5) + sum(SouhrnDPH/Zaklad22)
															+ sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad)"/>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_L" height="23" align="right">SPOLU</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_P" align="right">
							<xsl:value-of select="format-number($Zaklad + $DPH,'#,##0.00')"/>&#160;	</td>
					</tr>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<tr>
						<xsl:variable name="DPH" select="sum(Valuty/SouhrnDPH/DPH5) + sum(Valuty/SouhrnDPH/DPH22)
															+ sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>
						<xsl:variable name="Zaklad" select="sum(Valuty/SouhrnDPH/Zaklad0) + sum(Valuty/SouhrnDPH/Zaklad5) + sum(Valuty/SouhrnDPH/Zaklad22)
															+ sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad)"/>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_L" height="23" align="right">SPOLU v  <xsl:value-of select="Valuty/Mena/Kod"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_P" align="right">
							<xsl:value-of select="format-number($Zaklad + $DPH,'#,##0.00')"/>&#160;	</td>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<xsl:variable name="Zaklad" select="sum(*/SouhrnDPH/Zaklad0) + sum(*/SouhrnDPH/Zaklad5) + sum(*/SouhrnDPH/Zaklad22)
															+ sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad)"/>
						<xsl:variable name="DPH" select="sum(*/SouhrnDPH/DPH5) + sum(*/SouhrnDPH/DPH22) + sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_L" height="23" align="right">SPOLU</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D" align="right">
							<xsl:value-of select="format-number($DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 tucne podtrzeni_NT podtrzeni_D podtrzeni_P" align="right">
							<xsl:value-of select="format-number($Zaklad + $DPH, '#,##0.00')"/>&#160;
						</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="($Rezim = 1) or ($Rezim = 2)">
				<tr>
					<!-- poznámka k cenovému přehledu  -->
					<td class="velikost7 kurziva" height="17" align="right" colspan="4">Pozn.: Sumy obsahujú zaokrúhlenie.</td>
				</tr>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- CENOVÝ PANEL - ŘÁDKY SAZEB -->
	<xsl:template name="CenovyPanel_Radky">
		<xsl:param name="Rezim"/>
		<xsl:choose>
			<!-- Pokud se nebude vypisovat seznam dokladů a současně nebude uveden žádný element pro nulovou, sníženou standardní
				a základní standardní sazbu, tak se použije pouze seznam dalších sazeb vzestupně resp. sestupně seřazený.
				Součástí tohoto seznamu musí být i nulová, snížená standardní a snížená základní sazba.  -->
			<xsl:when test="(($Rezim = 1) and not(SazbaDPH1) and not(SazbaDPH2) and not(SSazba) and not(ZSazba)
							and not(SouhrnDPH/Zaklad0) and not(SouhrnDPH/Zaklad5) and not(SouhrnDPH/DPH5) and not(SouhrnDPH/Zaklad22) and not(SouhrnDPH/DPH22))
							or 
							(($Rezim = 2) and not(SazbaDPH1) and not(SazbaDPH2) and not(SSazba) and not(ZSazba)
							and not(Valuty/SouhrnDPH/Zaklad0) and not(Valuty/SouhrnDPH/Zaklad5) and not(Valuty/SouhrnDPH/DPH5) and not(Valuty/SouhrnDPH/Zaklad22)
							and not(Valuty/SouhrnDPH/DPH22))">
				<xsl:call-template name="CenovyPanel_DalsiSazby">
					<xsl:with-param name="Rezim" select="$Rezim"/>
					<xsl:with-param name="Razeni" select="$Razeni"/>
					<xsl:with-param name="VsechnySazby" select="1"/>
					<!-- Vypíše všechny sazby -->
				</xsl:call-template>
			</xsl:when>
			<!-- Ostatní případy -->
			<xsl:otherwise>
				<xsl:variable name="Minimum" select="0"/>
				<!-- Minimální výše sazby DPH -->
				<xsl:variable name="Maximum">
					<!-- Maximální výše sazby DPH v celém seznamu -->
					<xsl:call-template name="MaximumSazbaDPH">
						<xsl:with-param name="Rezim" select="$Rezim"/>
						<xsl:with-param name="Procento" select="0"/>
						<xsl:with-param name="Pocitadlo" select="1"/>
						<xsl:with-param name="Celkem">
							<xsl:choose>
								<xsl:when test="($Rezim = 1) or ($Rezim = 2)">1</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="count(*)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="Pocitadlo">
					<xsl:choose>
						<xsl:when test="$Razeni = 1">
							<xsl:value-of select="$Minimum"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$Maximum"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="Celkem">
					<xsl:choose>
						<xsl:when test="$Razeni = 1">
							<xsl:value-of select="$Maximum"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$Minimum"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<!-- Vzestupné řazení -->
					<xsl:when test="$Razeni = 1">
						<!-- Řádky sazeb s definovaným procentem -->
						<xsl:call-template name="CenovyPanel_Radek">
							<xsl:with-param name="Rezim" select="$Rezim"/>
							<xsl:with-param name="Razeni" select="$Razeni"/>
							<xsl:with-param name="Celkem" select="$Celkem"/>
							<xsl:with-param name="Pocitadlo" select="$Pocitadlo"/>
						</xsl:call-template>
						<!-- Řádky sazeb s jiným než celým nebo polovičním procentem (nebudou seřazeny) -->
						<xsl:call-template name="CenovyPanel_OstSazby">
							<xsl:with-param name="Rezim" select="$Rezim"/>
							<xsl:with-param name="Razeni" select="$Razeni"/>
						</xsl:call-template>
						<!-- Řádky sazeb s nedefinovaným procentem -->
						<xsl:if test="($Rezim = 1) or ($Rezim=2)">
							<xsl:call-template name="CenovyPanel_Nedef">
								<xsl:with-param name="Rezim" select="$Rezim"/>
								<xsl:with-param name="Razeni" select="$Razeni"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:when>
					<!-- Sestupné řazení -->
					<xsl:otherwise>
						<!-- Řádky sazeb s nedefinovaným procentem -->
						<xsl:call-template name="CenovyPanel_Nedef">
							<xsl:with-param name="Rezim" select="$Rezim"/>
							<xsl:with-param name="Razeni" select="$Razeni"/>
						</xsl:call-template>
						<!-- Řádky sazeb s definovaným procentem -->
						<xsl:call-template name="CenovyPanel_Radek">
							<xsl:with-param name="Rezim" select="$Rezim"/>
							<xsl:with-param name="Razeni" select="$Razeni"/>
							<xsl:with-param name="Celkem" select="$Celkem"/>
							<xsl:with-param name="Pocitadlo" select="$Pocitadlo"/>
						</xsl:call-template>
						<!-- Řádky sazeb s jiným než celým nebo polovičním procentem (nebudou seřazeny) -->
						<xsl:if test="($Rezim = 1) or ($Rezim=2)">
							<xsl:call-template name="CenovyPanel_Nedef">
								<xsl:with-param name="Rezim" select="$Rezim"/>
								<xsl:with-param name="Razeni" select="$Razeni"/>
							</xsl:call-template>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Řádky sazeb s definovaným procentem -->
	<xsl:template name="CenovyPanel_Radek">
		<xsl:param name="Rezim"/>
		<xsl:param name="Razeni"/>
		<xsl:param name="Celkem"/>
		<xsl:param name="Pocitadlo"/>
		<xsl:if test="(($Razeni = 1) and ($Pocitadlo &lt;= $Celkem)) or (($Razeni = 2) and ($Pocitadlo &gt;= $Celkem))">
			<xsl:variable name="Zaklad">
				<xsl:choose>
					<xsl:when test="$Rezim = 1">
						<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[../Sazba=$Pocitadlo])
													+ sum(SouhrnDPH/Zaklad0[$Pocitadlo=0])
													+ sum(SouhrnDPH/Zaklad5[../../SSazba=$Pocitadlo])
													+ sum(SouhrnDPH/Zaklad5[../../SazbaDPH1=$Pocitadlo])
													+ sum(SouhrnDPH/Zaklad22[../../ZSazba=$Pocitadlo])
													+ sum(SouhrnDPH/Zaklad22[../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:when>
					<xsl:when test="$Rezim = 2">
						<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[../Sazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/Zaklad0[$Pocitadlo=0])
													+ sum(Valuty/SouhrnDPH/Zaklad5[../../../SSazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/Zaklad5[../../../SazbaDPH1=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/Zaklad22[../../../ZSazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/Zaklad22[../../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[../Sazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/Zaklad0[$Pocitadlo=0])
													+ sum(*/SouhrnDPH/Zaklad5[../../SSazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/Zaklad5[../../SazbaDPH1=$Pocitadlo])
													+ sum(*/SouhrnDPH/Zaklad22[../../ZSazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/Zaklad22[../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="DPH">
				<xsl:choose>
					<xsl:when test="$Rezim = 1">
						<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[../Sazba=$Pocitadlo])
													+ sum(SouhrnDPH/DPH5[../../SSazba=$Pocitadlo])
													+ sum(SouhrnDPH/DPH5[../../SazbaDPH1=$Pocitadlo])
													+ sum(SouhrnDPH/DPH22[../../ZSazba=$Pocitadlo])
													+ sum(SouhrnDPH/DPH22[../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:when>
					<xsl:when test="$Rezim = 2">
						<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[../Sazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/DPH5[../../../SSazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/DPH5[../../../SazbaDPH1=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/DPH22[../../../ZSazba=$Pocitadlo])
													+ sum(Valuty/SouhrnDPH/DPH22[../../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[../Sazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/DPH5[../../SSazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/DPH5[../../SazbaDPH1=$Pocitadlo])
													+ sum(*/SouhrnDPH/DPH22[../../ZSazba=$Pocitadlo])
													+ sum(*/SouhrnDPH/DPH22[../../SazbaDPH2=$Pocitadlo])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- počet výskytů sazby -->
			<xsl:variable name="VyskytSazba0">
				<xsl:choose>
					<xsl:when test="($Rezim = 1) and (SouhrnDPH/Zaklad0) and ($Pocitadlo=0)">1</xsl:when>
					<xsl:when test="($Rezim = 2) and (Valuty/SouhrnDPH/Zaklad0) and ($Pocitadlo=0)">1</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(*[(SouhrnDPH/Zaklad0) and ($Pocitadlo=0)])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="VyskytSSazby">
				<xsl:choose>
					<xsl:when test="(($Rezim = 1) or ($Rezim = 2)) and ((SSazba = $Pocitadlo) or (SazbaDPH1 = $Pocitadlo))">1</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(*[SSazba=$Pocitadlo])+count(*[SazbaDPH1=$Pocitadlo])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="VyskytZSazby">
				<xsl:choose>
					<xsl:when test="(($Rezim = 1) or ($Rezim = 2)) and ((ZSazba = $Pocitadlo) or (SazbaDPH2 = $Pocitadlo))">1</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(*[ZSazba=$Pocitadlo])+count(*[SazbaDPH2=$Pocitadlo])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="VyskytDalsiSazby">
				<xsl:choose>
					<xsl:when test="($Rezim = 1)">
						<xsl:value-of select="count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Pocitadlo])"/>
					</xsl:when>
					<xsl:when test="($Rezim = 2)">
						<xsl:value-of select="count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Pocitadlo])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Pocitadlo])"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="CelkemVyskyt">
				<xsl:value-of select="$VyskytSazba0+$VyskytSSazby+$VyskytZSazby+$VyskytDalsiSazby"/>
			</xsl:variable>
			<!-- popis a hladina další sazby (použije se první výskyt sazby v seznamu dalších sazeb) -->
			<xsl:variable name="PopisDalsiSazby">
				<xsl:choose>
					<xsl:when test="($Rezim = 1)">
						<xsl:value-of select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Popis[../Sazba=$Pocitadlo]"/>
					</xsl:when>
					<xsl:when test="($Rezim = 2)">
						<xsl:value-of select="Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Popis[../Sazba=$Pocitadlo]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Popis[../Sazba=$Pocitadlo]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="HladinaDalsiSazby">
				<xsl:choose>
					<xsl:when test="($Rezim = 1)">
						<xsl:value-of select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba/HladinaDPH[../Sazba=$Pocitadlo]"/>
					</xsl:when>
					<xsl:when test="($Rezim = 2)">
						<xsl:value-of select="Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/HladinaDPH[../Sazba=$Pocitadlo]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/HladinaDPH[../Sazba=$Pocitadlo]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="($CelkemVyskyt &gt; 0)">
				<tr>
					<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
						<xsl:value-of select="format-number($Pocitadlo, '#,##0.##')"/>&#160;&#160;%</td>
					<td class="velikost5 " align="right">
						<xsl:value-of select="format-number($Zaklad, '#,##0.00')"/>
					</td>
					<td class="velikost5 " align="right">
						<xsl:value-of select="format-number($DPH, '#,##0.00')"/>
					</td>
					<td class="velikost5 podtrzeni_P" align="right">
						<xsl:value-of select="format-number(($Zaklad + $DPH), '#,##0.00')"/>&#160;</td>
				</tr>
			</xsl:if>
			<xsl:call-template name="CenovyPanel_Radek">
				<xsl:with-param name="Rezim" select="$Rezim"/>
				<xsl:with-param name="Razeni" select="$Razeni"/>
				<xsl:with-param name="Celkem" select="$Celkem"/>
				<xsl:with-param name="Pocitadlo">
					<xsl:choose>
						<!-- Vzestupné řazení -->
						<xsl:when test="$Razeni = 1">
							<xsl:value-of select="$Pocitadlo+0.5"/>
						</xsl:when>
						<!-- Sestupné řazení -->
						<xsl:otherwise>
							<xsl:value-of select="$Pocitadlo - 0.5"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- Řádky sazeb s jiným než celým nebo polovičním procentem (nebudou seřazeny) - neřeší seznam dokladů (poptávky, nabídky, objednávky) -->
	<xsl:template name="CenovyPanel_OstSazby">
		<xsl:param name="Rezim"/>
		<xsl:param name="Razeni"/>
		<xsl:variable name="SazbaDPH2_zbytek">
			<xsl:value-of select="(SazbaDPH2)mod(0.5)"/>
		</xsl:variable>
		<xsl:variable name="ZSazba_zbytek">
			<xsl:value-of select="(ZSazba)mod(0.5)"/>
		</xsl:variable>
		<xsl:variable name="SazbaDPH2">
			<xsl:choose>
				<xsl:when test="SazbaDPH2 != 0">
					<xsl:value-of select="SazbaDPH2"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ZSazba"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="SazbaDPH1_zbytek">
			<xsl:value-of select="(SazbaDPH1)mod(0.5)"/>
		</xsl:variable>
		<xsl:variable name="SSazba_zbytek">
			<xsl:value-of select="(SSazba)mod(0.5)"/>
		</xsl:variable>
		<xsl:variable name="SazbaDPH1">
			<xsl:choose>
				<xsl:when test="SazbaDPH1 != 0">
					<xsl:value-of select="SazbaDPH1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="SSazba"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Z_Zaklad">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="SouhrnDPH/Zaklad22"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="Valuty/SouhrnDPH/Zaklad22"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Z_DPH">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="SouhrnDPH/DPH22"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="Valuty/SouhrnDPH/DPH22"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="S_Zaklad">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="SouhrnDPH/Zaklad5"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="Valuty/SouhrnDPH/Zaklad5"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="S_DPH">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="SouhrnDPH/DPH5"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="Valuty/SouhrnDPH/DPH5"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- Snížená sazba -->
		<xsl:if test="($SazbaDPH1_zbytek &gt; 0) or ($SSazba_zbytek &gt; 0)">
			<tr>
				<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
					<xsl:value-of select="format-number($SazbaDPH1, '#,##0.##')"/>&#160;&#160;%</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($S_Zaklad, '#,##0.00')"/>
				</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($S_DPH, '#,##0.00')"/>
				</td>
				<td class="velikost5 podtrzeni_P" align="right">
					<xsl:value-of select="format-number(($S_Zaklad + $S_DPH), '#,##0.00')"/>&#160;</td>
			</tr>
		</xsl:if>
		<!-- Základní sazba -->
		<xsl:if test="($SazbaDPH2_zbytek &gt; 0) or ($ZSazba_zbytek &gt; 0)">
			<tr>
				<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
					<xsl:value-of select="format-number($SazbaDPH2, '#,##0.##')"/>&#160;&#160;%</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($Z_Zaklad, '#,##0.00')"/>
				</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($Z_DPH, '#,##0.00')"/>
				</td>
				<td class="velikost5 podtrzeni_P" align="right">
					<xsl:value-of select="format-number(($Z_Zaklad + $Z_DPH), '#,##0.00')"/>&#160;</td>
			</tr>
		</xsl:if>
		<!-- Další sazby -->
		<xsl:call-template name="CenovyPanel_DalsiSazby">
			<xsl:with-param name="Rezim" select="$Rezim"/>
			<xsl:with-param name="Razeni" select="$Razeni"/>
			<xsl:with-param name="VsechnySazby" select="0"/>
		</xsl:call-template>
	</xsl:template>
	<!-- Řádky sazeb - seznam dalších sazeb (neřeší standardní sníženou a standardní základní sazbu, která je mimo seznam dalších sazeb) -->
	<xsl:template name="CenovyPanel_DalsiSazby">
		<xsl:param name="Rezim"/>
		<xsl:param name="Razeni"/>
		<xsl:param name="VsechnySazby"/>
		<!-- 0 = vypíše pouze sazby s jiným než celým nebo polovičním procentem, 1 = vypíše všechny sazby -->
		<xsl:choose>
			<xsl:when test="$Rezim = 1">
				<xsl:choose>
					<!-- Vzestupné řazení -->
					<xsl:when test="$Razeni = 1">
						<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
							<xsl:sort select="Sazba" order="ascending" data-type="number"/>
							<xsl:variable name="Sazba_zbytek">
								<xsl:value-of select="(Sazba)mod(0.5)"/>
							</xsl:variable>
							<xsl:if test="($VsechnySazby = 1) or (($VsechnySazby = 0) and ($Sazba_zbytek &gt; 0))">
								<tr>
									<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
										<xsl:value-of select="format-number(Sazba, '#,##0.##')"/>&#160;&#160;%</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(Zaklad, '#,##0.00')"/>
									</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(DPH, '#,##0.00')"/>
									</td>
									<td class="velikost5 podtrzeni_P" align="right">
										<xsl:value-of select="format-number((Zaklad + DPH), '#,##0.00')"/>&#160;</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<!-- Sestupné řazení -->
					<xsl:otherwise>
						<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
							<xsl:sort select="Sazba" order="descending" data-type="number"/>
							<xsl:variable name="Sazba_zbytek">
								<xsl:value-of select="(Sazba)mod(0.5)"/>
							</xsl:variable>
							<xsl:if test="($VsechnySazby = 1) or (($VsechnySazby = 0) and ($Sazba_zbytek &gt; 0))">
								<tr>
									<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
										<xsl:value-of select="format-number(Sazba, '#,##0.##')"/>&#160;&#160;%</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(Zaklad, '#,##0.00')"/>
									</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(DPH, '#,##0.00')"/>
									</td>
									<td class="velikost5 podtrzeni_P" align="right">
										<xsl:value-of select="format-number((Zaklad + DPH), '#,##0.00')"/>&#160;</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Rezim = 2">
				<xsl:choose>
					<!-- Vzestupné řazení -->
					<xsl:when test="$Razeni = 1">
						<xsl:for-each select="Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
							<xsl:sort select="Sazba" order="ascending" data-type="number"/>
							<xsl:variable name="Sazba_zbytek">
								<xsl:value-of select="(Sazba)mod(0.5)"/>
							</xsl:variable>
							<xsl:if test="($VsechnySazby = 1) or (($VsechnySazby = 0) and ($Sazba_zbytek &gt; 0))">
								<tr>
									<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
										<xsl:value-of select="format-number(Sazba, '#,##0.##')"/>&#160;&#160;%</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(Zaklad, '#,##0.00')"/>
									</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(DPH, '#,##0.00')"/>
									</td>
									<td class="velikost5 podtrzeni_P" align="right">
										<xsl:value-of select="format-number((Zaklad + DPH), '#,##0.00')"/>&#160;</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<!-- Sestupné řazení -->
					<xsl:otherwise>
						<xsl:for-each select="Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
							<xsl:sort select="Sazba" order="descending" data-type="number"/>
							<xsl:variable name="Sazba_zbytek">
								<xsl:value-of select="(Sazba)mod(0.5)"/>
							</xsl:variable>
							<xsl:if test="($VsechnySazby = 1) or (($VsechnySazby = 0) and ($Sazba_zbytek &gt; 0))">
								<tr>
									<td class="velikost5 tucne podtrzeni_L" align="right" height="23">
										<xsl:value-of select="format-number(Sazba, '#,##0.##')"/>&#160;&#160;%</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(Zaklad, '#,##0.00')"/>
									</td>
									<td class="velikost5 " align="right">
										<xsl:value-of select="format-number(DPH, '#,##0.00')"/>
									</td>
									<td class="velikost5 podtrzeni_P" align="right">
										<xsl:value-of select="format-number((Zaklad + DPH), '#,##0.00')"/>&#160;</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- Řádky sazeb s nedefinovaným procentem -->
	<xsl:template name="CenovyPanel_Nedef">
		<xsl:param name="Rezim"/>
		<xsl:param name="Razeni"/>
		<xsl:variable name="S_Zaklad">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(SouhrnDPH/Zaklad5[(../../SSazba|../../SazbaDPH1='') or (not(../../SSazba|../../SazbaDPH1))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(Valuty/SouhrnDPH/Zaklad5[(../../../SSazba|../../../SazbaDPH1='') or (not(../../../SSazba|../../../SazbaDPH1))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(*/SouhrnDPH/Zaklad5[(../../SSazba|../../SazbaDPH1='') or (not(../../SSazba|../../SazbaDPH1))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="S_DPH">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(SouhrnDPH/DPH5[(../../SSazba|../../SazbaDPH1='') or (not(../../SSazba|../../SazbaDPH1))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(Valuty/SouhrnDPH/DPH5[(../../../SSazba|../../../SazbaDPH1='') or (not(../../../SSazba|../../../SazbaDPH1))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=1)])
												+ sum(*/SouhrnDPH/DPH5[(../../SSazba|../../SazbaDPH1='') or (not(../../SSazba|../../SazbaDPH1))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Z_Zaklad">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(SouhrnDPH/Zaklad22[(../../ZSazba|../../SazbaDPH2='') or (not(../../ZSazba|../../SazbaDPH2))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(Valuty/SouhrnDPH/Zaklad22[(../../../ZSazba|../../../SazbaDPH2='') or (not(../../../ZSazba|../../../SazbaDPH2))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(*/SouhrnDPH/Zaklad22[(../../ZSazba|../../SazbaDPH2='') or (not(../../ZSazba|../../SazbaDPH2))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Z_DPH">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(SouhrnDPH/DPH22[(../../ZSazba|../../SazbaDPH2='') or (not(../../ZSazba|../../SazbaDPH2))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(Valuty/SouhrnDPH/DPH22[(../../../ZSazba|../../../SazbaDPH2='') or (not(../../../ZSazba|../../../SazbaDPH2))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and (../HladinaDPH=2)])
												+ sum(*/SouhrnDPH/DPH22[(../../ZSazba|../../SazbaDPH2='') or (not(../../ZSazba|../../SazbaDPH2))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Ost_Zaklad">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and
													((../HladinaDPH='') or (not(../HladinaDPH)))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and
													((../HladinaDPH='') or (not(../HladinaDPH)))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad[((../Sazba='') or (not(../Sazba))) and
													((../HladinaDPH='') or (not(../HladinaDPH)))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Ost_DPH">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and ((../HladinaDPH='')
													or (not(../HladinaDPH)))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and ((../HladinaDPH='')
													or (not(../HladinaDPH)))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH[((../Sazba='') or (not(../Sazba))) and ((../HladinaDPH='')
													or (not(../HladinaDPH)))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- počet výskytů sazby (sazba se uvede jen v případě, že existuje alespoň jeden element související s danou sazbou) -->
		<xsl:variable name="VyskytSSazby">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<!-- element Sazba DPH je prázdný nebo neexistuje a současně existuje element Zaklad nebo DPH
								dále se přičte počet dalších sazeb, kde element sazba je prázdný nebo neexistuje a současně se jedná o sníženou hladinu -->
					<xsl:value-of select="(((SSazba|SazbaDPH1='') or (not(SSazba|SazbaDPH1))) and ((SouhrnDPH/Zaklad5) or (SouhrnDPH/DPH5)))
										+ count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or not(Sazba)) and (HladinaDPH=1)]) "/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="(((SSazba|SazbaDPH1='') or (not(SSazba|SazbaDPH1))) and ((Valuty/SouhrnDPH/Zaklad5) or (Valuty/SouhrnDPH/DPH5)))
												+ count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or not(Sazba)) and (HladinaDPH=1)]) "/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*[(((SSazba|SazbaDPH1='') or (not(SSazba|SazbaDPH1))) and ((SouhrnDPH/Zaklad5) or (SouhrnDPH/DPH5)))])
										 + count(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or (not(Sazba))) and (HladinaDPH=1)])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="VyskytZSazby">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="(((ZSazba|SazbaDPH2='') or (not(ZSazba|SazbaDPH2))) and ((SouhrnDPH/Zaklad22) or (SouhrnDPH/DPH22)))
										+ count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or not(Sazba)) and (HladinaDPH=2)]) "/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="(((ZSazba|SazbaDPH2='') or (not(ZSazba|SazbaDPH2))) and ((Valuty/SouhrnDPH/Zaklad22) or (Valuty/SouhrnDPH/DPH22)))
												+ count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or not(Sazba)) and (HladinaDPH=2)]) "/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*[(((ZSazba|SazbaDPH2='') or (not(ZSazba|SazbaDPH2))) and ((SouhrnDPH/Zaklad22) or (SouhrnDPH/DPH22)))])
										 + count(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or (not(Sazba))) and (HladinaDPH=2)])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="VyskytOstSazby">
			<xsl:choose>
				<xsl:when test="$Rezim = 1">
					<xsl:value-of select="count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or (not(Sazba))) and ((HladinaDPH='') or (not(HladinaDPH)))])"/>
				</xsl:when>
				<xsl:when test="$Rezim = 2">
					<xsl:value-of select="count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or (not(Sazba))) and ((HladinaDPH='') or (not(HladinaDPH)))])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(*/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[((Sazba='') or (not(Sazba))) and ((HladinaDPH='') or (not(HladinaDPH)))])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<!-- Vzestupné řazení -->
			<xsl:when test="$Razeni = 1">
				<xsl:if test="($VyskytSSazby &gt; 0)">
					<tr>
						<td class="velikost5 tucne podtrzeni_L" align="right" height="23">&#160;NaN&#160;&#160;%</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($S_Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($S_DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 podtrzeni_P" align="right">
							<xsl:value-of select="format-number(($S_Zaklad + $S_DPH), '#,##0.00')"/>&#160;</td>
					</tr>
				</xsl:if>
				<xsl:if test="($VyskytZSazby &gt; 0)">
					<tr>
						<td class="velikost5 tucne podtrzeni_L" align="right" height="23">&#160;NaN&#160;&#160;%</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($Z_Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($Z_DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 podtrzeni_P" align="right">
							<xsl:value-of select="format-number(($Z_Zaklad + $Z_DPH), '#,##0.00')"/>&#160;</td>
					</tr>
				</xsl:if>
			</xsl:when>
			<!-- Sestupné řazení -->
			<xsl:otherwise>
				<xsl:if test="($VyskytZSazby &gt; 0)">
					<tr>
						<td class="velikost5 tucne podtrzeni_L" align="right" height="23">&#160;NaN&#160;&#160;%</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($Z_Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($Z_DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 podtrzeni_P" align="right">
							<xsl:value-of select="format-number(($Z_Zaklad + $Z_DPH), '#,##0.00')"/>&#160;</td>
					</tr>
				</xsl:if>
				<xsl:if test="($VyskytSSazby &gt; 0)">
					<tr>
						<td class="velikost5 tucne podtrzeni_L" align="right" height="23">&#160;NaN&#160;&#160;%</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($S_Zaklad, '#,##0.00')"/>
						</td>
						<td class="velikost5 " align="right">
							<xsl:value-of select="format-number($S_DPH, '#,##0.00')"/>
						</td>
						<td class="velikost5 podtrzeni_P" align="right">
							<xsl:value-of select="format-number(($S_Zaklad + $S_DPH), '#,##0.00')"/>&#160;</td>
					</tr>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="($VyskytOstSazby &gt; 0)">
			<tr>
				<td class="velikost5 tucne podtrzeni_L" align="right" height="23">&#160;NaN&#160;&#160;%</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($Ost_Zaklad, '#,##0.00')"/>
				</td>
				<td class="velikost5 " align="right">
					<xsl:value-of select="format-number($Ost_DPH, '#,##0.00')"/>
				</td>
				<td class="velikost5 podtrzeni_P" align="right">
					<xsl:value-of select="format-number(($Ost_Zaklad + $Ost_DPH), '#,##0.00')"/>&#160;</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!-- Maximální výše sazby DPH v celém seznamu -->
	<xsl:template name="MaximumSazbaDPH">
		<xsl:param name="Rezim"/>
		<xsl:param name="Procento"/>
		<xsl:param name="Pocitadlo"/>
		<xsl:param name="Celkem"/>
		<xsl:choose>
			<xsl:when test="($Pocitadlo &lt;= $Celkem)">
				<xsl:variable name="SSazba">
					<xsl:choose>
						<xsl:when test="($Rezim = 1) or ($Rezim = 2)">
							<xsl:value-of select="SSazba|SazbaDPH1"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="*[position()=$Pocitadlo]/SSazba"/>
							<xsl:value-of select="*[position()=$Pocitadlo]/SazbaDPH1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="ZSazba">
					<xsl:choose>
						<xsl:when test="($Rezim = 1) or ($Rezim = 2)">
							<xsl:value-of select="ZSazba|SazbaDPH2"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="*[position()=$Pocitadlo]/ZSazba"/>
							<xsl:value-of select="*[position()=$Pocitadlo]/SazbaDPH2"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="StandSazba">
					<!-- Maximální výše standardní sazby aktuálního dokladu -->
					<xsl:choose>
						<xsl:when test="($ZSazba = '') and ($SSazba = '' )">0</xsl:when>
						<xsl:when test="(($ZSazba &gt;= $SSazba) or ($SSazba = '' )) and ($ZSazba !='' )">
							<xsl:value-of select="$ZSazba"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$SSazba"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="DalsiSazba">
					<!-- Maximální výše sazby DPH v seznamu dalších sazeb aktuálního dokladu -->
					<xsl:call-template name="MaximumDalsiSazby">
						<xsl:with-param name="Rezim" select="$Rezim"/>
						<xsl:with-param name="Procento" select="0"/>
						<xsl:with-param name="AktPocitadlo" select="$Pocitadlo"/>
						<xsl:with-param name="Pocitadlo" select="1"/>
						<xsl:with-param name="Celkem">
							<xsl:choose>
								<xsl:when test="$Rezim = 1">
									<xsl:value-of select="count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
								</xsl:when>
								<xsl:when test="$Rezim = 2">
									<xsl:value-of select="count(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="count(*[position()=$Pocitadlo]/SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="MaximumSazbaDPH">
					<xsl:with-param name="Procento">
						<xsl:choose>
							<xsl:when test="($StandSazba &gt;= $DalsiSazba) and ($StandSazba &gt; $Procento)">
								<xsl:value-of select="$StandSazba"/>
							</xsl:when>
							<xsl:when test="($DalsiSazba &gt; $StandSazba) and ($DalsiSazba &gt; $Procento)">
								<xsl:value-of select="$DalsiSazba"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$Procento"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="Pocitadlo" select="$Pocitadlo+1"/>
					<xsl:with-param name="Celkem" select="$Celkem"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Procento"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Maximální výše sazby DPH v seznamu dalších sazeb aktuálního dokladu -->
	<xsl:template name="MaximumDalsiSazby">
		<xsl:param name="Rezim"/>
		<xsl:param name="Procento"/>
		<xsl:param name="AktPocitadlo"/>
		<xsl:param name="Pocitadlo"/>
		<xsl:param name="Celkem"/>
		<xsl:choose>
			<xsl:when test="($Pocitadlo &lt;= $Celkem)">
				<xsl:variable name="SazbaDPH">
					<xsl:choose>
						<xsl:when test="$Rezim = 1">
							<xsl:value-of select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba[position()=$Pocitadlo]/Sazba"/>
						</xsl:when>
						<xsl:when test="$Rezim = 2">
							<xsl:value-of select="Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[position()=$Pocitadlo]/Sazba"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="*[position()=$AktPocitadlo]/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[position()=$Pocitadlo]/Sazba"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="MaximumDalsiSazby">
					<xsl:with-param name="Rezim" select="$Rezim"/>
					<xsl:with-param name="Procento">
						<xsl:choose>
							<xsl:when test="($SazbaDPH &gt; $Procento)">
								<xsl:value-of select="$SazbaDPH"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$Procento"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="AktPocitadlo" select="$AktPocitadlo"/>
					<xsl:with-param name="Pocitadlo" select="$Pocitadlo+1"/>
					<xsl:with-param name="Celkem" select="$Celkem"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Procento"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- KONEC CENOVÉHO PANELU - ŘÁDKY SAZEB -->
</xsl:stylesheet>
