<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- Transformační šablona pro import dat z docházkového systému
Autor: Solitea Slovensko, a.s.
-->

	<!-- Seznam mezd -->
	<xsl:template match="/">
		<xsl:param name="Mesic"/>
		<xsl:param name="Rok"/>

		<xsl:element name="MoneyData">
			<xsl:if test="count(MoneyData/SeznamZamestnancu/Zamestnanec)>0 ">
				<xsl:element name="SeznamMezd">
					<xsl:apply-templates select="MoneyData/SeznamZamestnancu/Zamestnanec">
						<xsl:with-param name="Mesic" select="MoneyData/Obdobi/Mesic"/>
						<xsl:with-param name="Rok" select="MoneyData/Obdobi/Rok"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>


	<!-- Mzda -->
	<xsl:template match="Zamestnanec">
		<xsl:param name="Mesic"/>
		<xsl:param name="Rok"/>

		<xsl:element name="Mzda">
			<xsl:element name="Zamestnanec">
				<xsl:if test="string-length(OsobniCislo)>0 ">
					<xsl:element name="OsCislo">
						<xsl:value-of select="OsobniCislo"/>
					</xsl:element>
				</xsl:if>

				<xsl:if test="string-length(Prijmeni)>0">
					<xsl:element name="Jmeno">
						<xsl:choose>
							<xsl:when test="string-length(Jmeno)>0 and string-length(Titul)>0">
								<xsl:value-of select="normalize-space(concat(Prijmeni,' ',Jmeno,', ',Titul))" />
							</xsl:when>
							<xsl:when test="string-length(Titul)>0">
								<xsl:value-of select="normalize-space(concat(Prijmeni,', ',Titul))" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(concat(Prijmeni,' ',Jmeno))" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:if>
			</xsl:element>

			<xsl:if test="string-length($Mesic)>0 ">
				<xsl:element name="Mesic">
					<xsl:call-template name="_mesic_">
						<xsl:with-param name="_mesic">
							<xsl:value-of select="$Mesic"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length($Rok)>0 ">
				<xsl:element name="Rok">
					<xsl:value-of select="$Rok"/>
				</xsl:element>
			</xsl:if>

			<xsl:if test="string-length(PracovniFond/FondDnu)>0 ">
				<xsl:element name="PracDnu">
					<xsl:choose>
						<xsl:when test="contains(PracovniFond/FondDnu,'.')">
							<xsl:value-of select="substring-before(PracovniFond/FondDnu,'.')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="PracovniFond/FondDnu"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(PracovniFond/FondHodin)>0 ">
				<xsl:element name="PracHod">
					<xsl:value-of select="PracovniFond/FondHodin"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Odpracovano/OdpracDnu)>0 ">
				<xsl:element name="OdprDnu">
					<xsl:value-of select="Odpracovano/OdpracDnu"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Odpracovano/OdpracHodin)>0 ">
				<xsl:element name="OdprHod">
					<xsl:value-of select="Odpracovano/OdpracHodin"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Svatky/OdpracDnu)>0 ">
				<xsl:element name="OdprSvDnu">
					<xsl:value-of select="Svatky/OdpracDnu"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Svatky/OdpracHodin)>0 ">
				<xsl:element name="OdprSvHod">
					<xsl:value-of select="Svatky/OdpracHodin"/>
				</xsl:element>
			</xsl:if>

			<xsl:if test="count(SeznamNepritomnosti/Nepritomnost)>0 ">
				<xsl:element name="SeznamNepritomnosti">
					<xsl:apply-templates select="SeznamNepritomnosti"/>
				</xsl:element>
			</xsl:if>

			<!-- Mzdové příplatky - seznam -->
			<!-- test, zda je celkový počet hodin všech příplatků větší než nula -->
			<xsl:if test="sum(SeznamMzPriplatku/MzPriplatek/PripHodin)>0">
				<xsl:element name="SeznamMzPriplatku">
					<xsl:apply-templates select="SeznamMzPriplatku"/>
				</xsl:element>
			</xsl:if>
			<!-- Mzdové příplatky - bez seznamu -->
			<xsl:if test="MzdovePriplatky/PrescasHodin>0 or MzdovePriplatky/SvatkyHodin>0 or MzdovePriplatky/SobotaNedeleHodin>0
			or MzdovePriplatky/ProstrediHodin>0 or MzdovePriplatky/NocHodin>0 or MzdovePriplatky/PohotovostHodin>0 or MzdovePriplatky/SvatkyDohHodin or MzdovePriplatky/SobotaHodin or MzdovePriplatky/NedeleHodin">
				<xsl:call-template name="MzdovePriplatky_bez_seznamu"/>
			</xsl:if>

		</xsl:element>
	</xsl:template>

	<!-- Mzdové příplatky - seznam -->
	<xsl:template match="SeznamMzPriplatku">
		<xsl:apply-templates select="MzPriplatek"/>
	</xsl:template>

	<!-- Mzdový příplatek -->
	<xsl:template match="MzPriplatek">
		<xsl:if test="PripHodin>0">
			<xsl:element name="MzPriplatek">
				<xsl:element name="TypPriplatku">
					<xsl:if test="string-length(Zkratka)>0 ">
						<xsl:element name="Zkratka">
							<xsl:value-of select="Zkratka"/>
						</xsl:element>
					</xsl:if>
					<xsl:if test="string-length(Druh)>0 ">
						<xsl:element name="Druh">
							<xsl:value-of select="Druh"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
				<xsl:if test="string-length(PripHodin)>0 ">
					<xsl:element name="PripHodin">
						<xsl:value-of select="PripHodin"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>


	<!-- Mzdové příplatky - bez seznamu -->
	<xsl:template name="MzdovePriplatky_bez_seznamu">
<!-- 
V SK verzii v (MzPripl.DAt) je nasledovné:

1   Nadčasy  
2   Práca vo sviatky
3   Pracovné prostredie
4   Práca v noci  
2   Práca vo sviatky - dohody (rovnaký druh ako Práca vo sviatok, preto cez skratku)
6   Práca v sobotu
7   Práca v nedeľu  
-->
		<xsl:element name="SeznamMzPriplatku">

			<xsl:if test="MzdovePriplatky/PrescasHodin>0">
				<xsl:element name="MzPriplatek">
					<xsl:element name="TypPriplatku">
						<xsl:element name="Druh">1</xsl:element>
					</xsl:element>
					<xsl:element name="PripHodin">
						<xsl:value-of select="MzdovePriplatky/PrescasHodin"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>

			<xsl:if test="MzdovePriplatky/SvatkyHodin>0">
				<xsl:element name="MzPriplatek">
					<xsl:element name="TypPriplatku">
						<xsl:element name="Druh">2</xsl:element>
					</xsl:element>
					<xsl:element name="PripHodin">
						<xsl:value-of select="MzdovePriplatky/SvatkyHodin"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
      
			<xsl:if test="MzdovePriplatky/ProstrediHodin>0">
				<xsl:element name="MzPriplatek">
					<xsl:element name="TypPriplatku">
						<xsl:element name="Druh">3</xsl:element>
					</xsl:element>
					<xsl:element name="PripHodin">
						<xsl:value-of select="MzdovePriplatky/ProstrediHodin"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
      
			<xsl:if test="MzdovePriplatky/NocHodin>0">
				<xsl:element name="MzPriplatek">
					<xsl:element name="TypPriplatku">
						<xsl:element name="Druh">4</xsl:element>
					</xsl:element>
					<xsl:element name="PripHodin">
						<xsl:value-of select="MzdovePriplatky/NocHodin"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
      
			<!--má rovnaký Druh=2 ako Práca vo Sviatky, preto cez skratku-->
      <xsl:if test="MzdovePriplatky/SvatkyDohHodin>0">
				<xsl:element name="MzPriplatek">
          <xsl:element name="TypPriplatku">
            <xsl:element name="Zkratka">CSW_SV_DOH</xsl:element>
          </xsl:element>
					<xsl:element name="PripHodin">
						<xsl:value-of select="MzdovePriplatky/SvatkyDohHodin"/>
					</xsl:element>
				</xsl:element>
      </xsl:if>

      <xsl:if test="MzdovePriplatky/SobotaHodin>0">
        <xsl:element name="MzPriplatek">
          <xsl:element name="TypPriplatku">
            <xsl:element name="Druh">6</xsl:element>
          </xsl:element>
          <xsl:element name="PripHodin">
            <xsl:value-of select="MzdovePriplatky/SobotaHodin"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:if test="MzdovePriplatky/NedeleHodin>0">
        <xsl:element name="MzPriplatek">
          <xsl:element name="TypPriplatku">
            <xsl:element name="Druh">7</xsl:element>
          </xsl:element>
          <xsl:element name="PripHodin">
            <xsl:value-of select="MzdovePriplatky/NedeleHodin"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>

		</xsl:element>
	</xsl:template>


	<!-- Seznam nepřítomností -->
	<xsl:template match="SeznamNepritomnosti">
		<xsl:apply-templates select="Nepritomnost"/>
	</xsl:template>


	<!-- Nepřítomnost -->
	<xsl:template match="Nepritomnost">
		<xsl:element name="Nepritomnost">
			<xsl:if test="string-length(Typ)>0 ">
				<xsl:element name="Typ">
					<xsl:call-template name="_typ_">
						<xsl:with-param name="_typ">
							<xsl:value-of select="Typ"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>

			<xsl:if test="string-length(Zacatek/Datum)>0 ">
				<xsl:element name="Zacatek">
					<xsl:value-of select="Zacatek/Datum"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Konec/Datum)>0 ">
				<xsl:element name="Konec">
					<xsl:value-of select="Konec/Datum"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Zacatek/OdpracHodin)>0 ">
				<xsl:element name="OdpHodZ">
					<xsl:value-of select="Zacatek/OdpracHodin"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(Konec/OdpracHodin)>0 ">
				<xsl:element name="OdpHodK">
					<xsl:value-of select="Konec/OdpracHodin"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(KalDnu)>0 ">
				<xsl:element name="KalDnu">
					<xsl:value-of select="KalDnu"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(PracDnu)>0 ">
				<xsl:element name="PracDnu">
					<xsl:value-of select="PracDnu"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(PracHodin)>0 ">
				<xsl:element name="Hodin">
					<xsl:value-of select="PracHodin"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(SvatkyDnu)>0 ">
				<xsl:element name="SvatDnu">
					<xsl:value-of select="SvatkyDnu"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(SvatkyHodin)>0 ">
				<xsl:element name="SvatHod">
					<xsl:value-of select="SvatkyHodin"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>


	<!-- Nepřítomnost - formát výstupu -->
	<xsl:template name="_typ_">
		<xsl:param name="_typ"/>
		<!--
    
Docházka:
0 = Dovolenka
1 = Paragraf (všetky druhy paragrafov)
2 = Neplatené voľno
3 = Neospravedlnená absencia
4 = Choroba
5 = Karanténa
6 = OČR (ošetrovanie člena rodiny)
7 = Materská dovolenka
8 = Úraz
9 = Dlhodobo uvoľnený z pracovného pomeru
10 = Rodičovská dovolenka do 6. rokov
11 = Rodičovská dovolenka do 7. rokov
12 = Prekážy na strane zamestnávateľa

Money S3 - sk verzia:
P = Plánovaná dovolenka
D = Dovolenka
G = Paragraf
V = Neplatené voľno
A = Neospravedlnená absencia
N = Choroba 
K = karanténa
O = OČR (ošetrovanie člena rodiny)
C = Materská dovolenka
U = Úraz
S = Dlhodobo uvoľnený z prac. pomeru
X = Rodičovská dovolenka do 6. rokov
Z = Rodičovská dovolenka do 7. rokov
I = Prekážky na strane zamestnávateľa-->
    
		<xsl:choose>
			<xsl:when test="$_typ='0'">D</xsl:when>
			<xsl:when test="$_typ='1'">G</xsl:when>
			<xsl:when test="$_typ='2'">V</xsl:when>
			<xsl:when test="$_typ='3'">A</xsl:when>
			<xsl:when test="$_typ='4'">N</xsl:when>
      <xsl:when test="$_typ='5'">K</xsl:when>
			<xsl:when test="$_typ='6'">O</xsl:when>
			<xsl:when test="$_typ='7'">C</xsl:when>      
      <xsl:when test="$_typ='8'">U</xsl:when>
      <xsl:when test="$_typ='9'">S</xsl:when>
      <xsl:when test="$_typ='10'">X</xsl:when>
      <xsl:when test="$_typ='11'">Z</xsl:when>
      <xsl:when test="$_typ='12'">I</xsl:when>
            
		</xsl:choose>
	</xsl:template>


	<!-- Měsíc - formát výstupu -->
	<xsl:template name="_mesic_">
		<xsl:param name="_mesic"/>
		<xsl:choose>
			<xsl:when test="substring($_mesic,1,1)=0">
				<xsl:value-of select="substring($_mesic,2,1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$_mesic"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
