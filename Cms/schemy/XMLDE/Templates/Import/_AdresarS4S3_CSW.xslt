<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--
	transformacni sablona pro prenos adres MoneyS4 -> MoneyS3
	autor: Pavel Lelovsky a Jaromir Leso, CIGLER SOFTWARE, a. s.
	26.8.2003
	-->
	<xsl:template match="/">
		<xsl:element name="MoneyData">
			<xsl:apply-templates select="PartnerSeznam"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="PartnerSeznam">
		<xsl:element name="SeznamFirem">
			<xsl:apply-templates select="Partner"/>
		</xsl:element>
	</xsl:template>
	<!-- lokalita -->
	<xsl:template match="Partner">
		<xsl:element name="Firma">
<!--
			<xsl:element name="GUID">
				<xsl:value-of select="ID"/>
			</xsl:element>
-->
			<!-- test jestli ma firma lokalitu, ktera neni sidlo ani fakt. adresa -->
			<xsl:choose>
				<!-- pokud ano, tak se prvni z nich vezme jako adresa provozovny -->
				<xsl:when test="Lokality/Lokalita[ID!=../../Sidlo/ID/.][ID!=../../FaktAdresa/ID/.]">
					<xsl:for-each select="Lokality/Lokalita[ID!=../../Sidlo/ID/.][ID!=../../FaktAdresa/ID/.]">
						<xsl:if test="position()=1">
							<xsl:apply-templates select="Nazev"/>
							<xsl:element name="Adresa">
								<xsl:apply-templates select="Adresa"/>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<!-- pokud ne, tak se adresa provozovny prevezme z fakturacni adresy -->
				<xsl:otherwise>
					<xsl:for-each select="Lokality/Lokalita[ID=../../FaktAdresa/ID/.]">
						<xsl:if test="position()=1">
							<xsl:apply-templates select="Nazev"/>
							<xsl:element name="Adresa">
								<xsl:apply-templates select="Adresa"/>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="Lokality/Lokalita[ID=../../Sidlo/ID/.]">
				<xsl:if test="position()=1">
					<xsl:element name="ObchNazev">
						<xsl:value-of select="Nazev"/>
					</xsl:element>
					<xsl:element name="ObchAdresa">
						<xsl:apply-templates select="Adresa"/>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="Lokality/Lokalita[ID=../../FaktAdresa/ID/.]">
				<xsl:if test="position()=1">
					<xsl:element name="FaktNazev">
						<xsl:value-of select="Nazev"/>
					</xsl:element>
					<xsl:element name="FaktAdresa">
						<xsl:apply-templates select="Adresa"/>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
			<xsl:element name="Tel">
				<xsl:apply-templates select="Kontakt1"/>
			</xsl:element>
			<xsl:element name="Fax">
				<xsl:apply-templates select="Kontakt2"/>
			</xsl:element>
			<xsl:element name="Mobil">
				<xsl:apply-templates select="Kontakt3"/>
			</xsl:element>
			<xsl:element name="EMail">
				<xsl:apply-templates select="KontaktMail"/>
			</xsl:element>
			<xsl:element name="WWW">
				<xsl:apply-templates select="KontaktWeb"/>
			</xsl:element>
			<xsl:element name="ICO">
				<xsl:value-of select="IC"/>
			</xsl:element>
			<xsl:element name="DIC">
				<xsl:value-of select="DIC"/>
			</xsl:element>
			<xsl:apply-templates select="PlatceDPH"/>
			<xsl:apply-templates select="FyzOsoba"/>
			<xsl:apply-templates select="BankSpoj"/>
			<xsl:element name="Cinnosti">
				<xsl:for-each select="Cinnosti/PartnerCinnost">
					<xsl:if test="position()!=1">;</xsl:if>
					<xsl:value-of select="Cinnost/Kod"/>
				</xsl:for-each>
			</xsl:element>
			<xsl:element name="AdrKlice">
				<xsl:for-each select="SeznamKategorii/PartnerKategorie">
					<xsl:if test="position()!=1">;</xsl:if>
					<xsl:value-of select="Kategorie/Kod"/>
				</xsl:for-each>
			</xsl:element>
			<xsl:apply-templates select="Zprava"/>
			<xsl:apply-templates select="Poznamka"/>
			<xsl:element name="KodPartn">
				<xsl:value-of select="Kod"/>
			</xsl:element>
			<xsl:apply-templates select="Osoby/Osoba"/>
			<xsl:apply-templates select="Skupina"/>
		</xsl:element>
	</xsl:template>
	<!-- osoba -->
	<xsl:template match="Osoba">
		<xsl:element name="Osoba">
			<xsl:apply-templates select="TitulPred"/>
			<xsl:apply-templates select="TitulZa"/>
			<xsl:apply-templates select="Jmeno"/>
			<xsl:apply-templates select="Prijmeni"/>
<!--
			<xsl:element name="Pohlavi">
				<xsl:value-of select="1-Pohlavi"/>
			</xsl:element>
-->
			<xsl:apply-templates select="Pohlavi"/>
			<xsl:apply-templates select="Funkce"/>
			<xsl:element name="Adresa">
				<xsl:apply-templates select="Adresa"/>
			</xsl:element>
			<xsl:element name="Tel">
				<xsl:apply-templates select="Kontakt1"/>
			</xsl:element>
			<xsl:element name="Fax">
				<xsl:apply-templates select="Kontakt2"/>
			</xsl:element>
			<xsl:element name="Mobil">
				<xsl:apply-templates select="Kontakt3"/>
			</xsl:element>
			<xsl:element name="EMail">
				<xsl:apply-templates select="KontaktMail"/>
			</xsl:element>
			<xsl:element name="Pozn">
				<xsl:value-of select="Poznamka"/>
			</xsl:element>
			<xsl:element name="KodPartn">
				<xsl:value-of select="Kod"/>
			</xsl:element>
			<xsl:element name="Jednatel">
				<xsl:value-of select="number((../../TiskJednatel!=0) and (ID=../../Jednatel/ID/.))"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!-- adresa -->
	<xsl:template match="Adresa">
		<xsl:apply-templates select="Ulice"/>
		<xsl:element name="Misto">
			<xsl:value-of select="PSC/Nazev"/>
		</xsl:element>
		<xsl:element name="PSC">
			<xsl:value-of select="PSC/Kod"/>
		</xsl:element>
		<xsl:element name="Stat">
			<xsl:value-of select="Zeme/Nazev"/>
		</xsl:element>
	</xsl:template>
	<!-- kontakt -->
	<xsl:template match="Kontakt1|Kontakt2|Kontakt3">
		<xsl:element name="Cislo">
			<xsl:value-of select="substring(Spojeni,1,20)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="KontaktMail|KontaktWeb">
		<xsl:value-of select="Spojeni"/>
	</xsl:template>
	<!-- bankovni spojeni -->
	<xsl:template match="BankSpoj">
		<xsl:element name="Banka">
			<xsl:value-of select="Banka/NazevBanky"/>
		</xsl:element>
		<xsl:element name="Ucet">
			<xsl:value-of select="CisloUctu"/>
		</xsl:element>
		<xsl:element name="KodBanky">
			<xsl:value-of select="Banka/BANIS"/>
		</xsl:element>
		<xsl:element name="Specsym">
			<xsl:value-of select="SpecSymbol"/>
		</xsl:element>
	</xsl:template>
	<!-- skupina -->
	<xsl:template match="Skupina">
		<xsl:element name="Skupina">
			<xsl:element name="Zkratka">
				<xsl:value-of select="Kod"/>
			</xsl:element>
			<xsl:apply-templates select="Nazev"/>
			<xsl:apply-templates select="Poznamka"/>
		</xsl:element>
	</xsl:template>
	<!-- implicitní přepis elementů a obsahu -->
	<xsl:template match="node()">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*|text()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:stylesheet>
