<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


<!-- Transformační šablona na export dat do docházkového systému
Autor: Marek Vykydal
-->


	<xsl:template match="/">
			<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="MoneyData/*">										<!--	Pro všechny elementy pod elementem MoneyData proveď -->
		<xsl:choose>
			<xsl:when test="name()='SeznamZamestnancu' ">
					<!-- Seznam zaměstnanců -->
					<xsl:if test="count(Zamestnanec)>0 ">
						<xsl:element name="SeznamZamestnancu">
							<xsl:apply-templates select="Zamestnanec"/>
						</xsl:element>
					</xsl:if>
			</xsl:when>
			<xsl:when test="name()='SeznamTypuPriplatku' ">
					<!-- Seznam typů mzdových příplatků -->
					<!-- Test, zda jsou v seznamu nějaké nenulové (tzn. definované) druhy příplatků. Nedefinované druhy příplatků se nepřenáší do docházkového systému. -->
					<xsl:if test="sum(TypPriplatku/Druh)>0 ">
						<xsl:element name="SeznamTypuPriplatku">
							<xsl:apply-templates select="TypPriplatku"/>
						</xsl:element>
					</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>	<!--	kopírování ostatních elementů -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Zaměstnanec -->
	<xsl:template match="Zamestnanec">
	<xsl:param name="Pocet" select="count(SeznamMzdovychObdobi/MzdoveObdobi)"/>

		<xsl:element name="Zamestnanec">
			<xsl:if test="string-length(OsCislo)>0 ">
				<xsl:element name="OsobniCislo"><xsl:value-of select="OsCislo"/></xsl:element>
			</xsl:if>

			<xsl:if test="string-length(Jmeno/@Prijmeni)>0 ">
				<xsl:element name="Prijmeni"><xsl:value-of select="Jmeno/@Prijmeni"/></xsl:element>
			</xsl:if>

			<xsl:if test="string-length(Jmeno/@JmenoKr)>0 ">
				<xsl:element name="Jmeno"><xsl:value-of select="Jmeno/@JmenoKr"/></xsl:element>
			</xsl:if>

			<xsl:if test="string-length(Jmeno/@Titul)>0 ">
				<xsl:element name="Titul"><xsl:value-of select="Jmeno/@Titul"/></xsl:element>
			</xsl:if>

			<xsl:for-each select="SeznamMzdovychObdobi/MzdoveObdobi">
			       <xsl:sort select="Rok" data-type="number"/>		<!-- seřazení mzdových období podle roku a měsíce -->
			       <xsl:sort select="Mesic" data-type="number"/>
					<xsl:if test="position()=$Pocet">				<!-- aktuální mzdové období, poslední v seřazeném seznamu -->
						<xsl:if test="string-length(Funkce)>0 ">
							<xsl:element name="Funkce"><xsl:value-of select="Funkce"/></xsl:element>
						</xsl:if>
						<xsl:if test="string-length(PracPomer/Zkrat)>0 ">
							<xsl:element name="PracPomer">
								<xsl:element name="Zkratka"><xsl:value-of select="PracPomer/Zkrat"></xsl:value-of></xsl:element>
								<xsl:if test="string-length(PracPomer/Popis)>0 ">
									<xsl:element name="Popis"><xsl:value-of select="PracPomer/Popis"/></xsl:element>
								</xsl:if>
								<xsl:if test="string-length(PracPomer/ELDPKod)>0 ">
									<xsl:element name="KodCinnosti"><xsl:value-of select="PracPomer/ELDPKod"/></xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:if>
					</xsl:if>
		  	</xsl:for-each>

			<xsl:if test="string-length(Stredisko)>0 ">
				<xsl:element name="Stredisko">
					<xsl:element name="Zkratka"><xsl:value-of select="Stredisko"/></xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="string-length(DatNastup)>0 ">
				<xsl:element name="DatumNastup"><xsl:value-of select="DatNastup"/></xsl:element>
			</xsl:if>
			<xsl:if test="string-length(DatOdchod)>0 ">
				<xsl:element name="DatumOdchod"><xsl:value-of select="DatOdchod"/></xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>


	<!-- Mzdový příplatek -->
	<xsl:template match="TypPriplatku">
		<xsl:if test="Druh>0 ">
			<xsl:element name="TypPriplatku">
				<xsl:if test="string-length(Zkratka)>0 ">
					<xsl:element name="Zkratka"><xsl:value-of select="Zkratka"/></xsl:element>
				</xsl:if>
				<xsl:if test="string-length(Popis)>0 ">
					<xsl:element name="Popis"><xsl:value-of select="Popis"/></xsl:element>
				</xsl:if>
				<xsl:if test="string-length(Druh)>0 ">
					<xsl:element name="Druh"><xsl:value-of select="Druh"/></xsl:element>
				</xsl:if>
				<xsl:if test="string-length(Sazba)>0 ">
					<xsl:element name="Sazba"><xsl:value-of select="Sazba"/></xsl:element>
				</xsl:if>
				<xsl:if test="string-length(Typ)>0 ">
					<xsl:element name="Typ"><xsl:value-of select="Typ"/></xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>


	<!--	Kopírování dokumentu -->
	<xsl:template match="*|@*|comment()|text()" name="Kopiruj">
		<xsl:copy>
			<xsl:apply-templates select="*|@*|comment()|text()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
