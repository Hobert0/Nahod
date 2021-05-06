<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!--	šablona zrcadlení obchodních dokladů - z dokladů vydaných vytvoří doklady přijaté -->

	<!--	vybrat pouze vydané doklady -->
	<xsl:template match="/">
		<xsl:apply-templates select="MoneyData"/>
	</xsl:template>
	<xsl:template match="MoneyData">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="SeznamFaktVyd[FaktVyd]"/>
			<xsl:apply-templates select="SeznamFaktVyd_DPP[FaktVyd_DPP]"/>
			<xsl:apply-templates select="SeznamObjVyd[ObjVyd]"/>
			<xsl:apply-templates select="SeznamNabVyd[NabVyd]"/>
			<xsl:apply-templates select="SeznamPoptVyd[PoptVyd]"/>
			<xsl:call-template name="VydejkaProdejka"/>
			<xsl:apply-templates select="SeznamDLVyd[DLVyd]"/>
		</xsl:element>
	</xsl:template>

	<!--	FV -> FP -->
	<xsl:template match="SeznamFaktVyd">
		<xsl:element name="SeznamFaktPrij">
			<xsl:apply-templates select="FaktVyd"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="FaktVyd">
		<xsl:element name="FaktPrij">
			<xsl:call-template name="Faktura"/>
		</xsl:element>
	</xsl:template>

	<!--	FV_DPP -> FP_DPP (daňový doklad k přijaté platbě) -->
	<xsl:template match="SeznamFaktVyd_DPP">
		<xsl:element name="SeznamFaktPrij_DPP">
			<xsl:apply-templates select="FaktVyd_DPP"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="FaktVyd_DPP">
		<xsl:element name="FaktPrij_DPP">
			<xsl:call-template name="Faktura"/>		<!--	daňový doklad k přijaté platbě má stejný obsah jako faktura -->
		</xsl:element>
	</xsl:template>

	<!--	OV -> OP -->
	<xsl:template match="SeznamObjVyd">
		<xsl:element name="SeznamObjPrij">
			<xsl:apply-templates select="ObjVyd"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="ObjVyd">
		<xsl:element name="ObjPrij">
			<xsl:call-template name="Objedn"/>
		</xsl:element>
	</xsl:template>

	<!--	NV -> NP -->
	<xsl:template match="SeznamNabVyd">
		<xsl:element name="SeznamNabPrij">
			<xsl:apply-templates select="NabVyd"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="NabVyd">
		<xsl:element name="NabPrij">
			<xsl:call-template name="Objedn"/>
		</xsl:element>
	</xsl:template>

	<!--	PV -> PP -->
	<xsl:template match="SeznamPoptVyd">
		<xsl:element name="SeznamPoptPrij">
			<xsl:apply-templates select="PoptVyd"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="PoptVyd">
		<xsl:element name="PoptPrij">
			<xsl:call-template name="Objedn"/>
		</xsl:element>
	</xsl:template>

	<!--	vydejka nebo prodejka -> prijemka -->
	<xsl:template name="VydejkaProdejka">
		<xsl:if test="SeznamVydejka/Vydejka|SeznamProdejka/Prodejka">
			<xsl:element name="SeznamPrijemka">
				<xsl:apply-templates select="SeznamVydejka/Vydejka"/>
				<xsl:apply-templates select="SeznamProdejka/Prodejka"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Vydejka|Prodejka">
		<xsl:element name="Prijemka">
			<xsl:call-template name="SklDokl"/>
		</xsl:element>
	</xsl:template>

	<!--	DLVyd -> DLPrij -->
	<xsl:template match="SeznamDLVyd">
		<xsl:element name="SeznamDLPrij">
			<xsl:apply-templates select="DLVyd"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="DLVyd">
		<xsl:element name="DLPrij">
			<xsl:call-template name="SklDokl"/>
		</xsl:element>
	</xsl:template>

	<!-- záhlaví faktury -->
	<xsl:template name="Faktura">
		<xsl:apply-templates select="Popis"/>
		<xsl:apply-templates select="Vystaveno"/>
		<xsl:apply-templates select="PlnenoDPH"/>
		<xsl:apply-templates select="Splatno"/>
		<xsl:apply-templates select="KonstSym"/>
		<xsl:apply-templates select="VarSymbol"/>
		<xsl:apply-templates select="SpecSymbol"/>
		<xsl:element name="PrijatDokl">
			<xsl:value-of select="Doklad"/>
		</xsl:element>
		<xsl:apply-templates select="Druh"/>
		<xsl:apply-templates select="Dobropis"/>
		<xsl:apply-templates select="ZpDopravy"/>
		<xsl:apply-templates select="Uhrada"/>
		<xsl:apply-templates select="SazbaDPH1"/>
		<xsl:apply-templates select="SazbaDPH2"/>
		<xsl:apply-templates select="Sleva"/>
		<xsl:apply-templates select="SouhrnDPH"/>
		<xsl:apply-templates select="Celkem"/>
		<xsl:apply-templates select="Valuty"/>
		<xsl:apply-templates select="SumZaloha"/>
		<xsl:apply-templates select="SumZalohaC"/>
		<xsl:apply-templates select="MojeFirma"/>
		<xsl:apply-templates select="SeznamPolozek"/>
		<xsl:apply-templates select="SeznamZalPolozek"/>

		<xsl:if test="(SeznamVazeb/Vazba/Typ = 'DD') and (SeznamVazeb/Vazba/Doklad/Druh = 'FV')">
			<xsl:element name="SeznamVazeb">
				<xsl:for-each select="SeznamVazeb/Vazba">
					<xsl:if test="(Typ = 'DD') and (Doklad/Druh = 'FV')">
						<xsl:element name="Vazba">
							<xsl:apply-templates select="Typ"/>
							<xsl:apply-templates select="PodTyp"/>
								<xsl:element name="Doklad">
									<xsl:element name="Druh">FP</xsl:element>
									<xsl:element name="PrijatDokl"><xsl:value-of select="Doklad/Cislo"/></xsl:element>
								</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>

	</xsl:template>
	<!-- položky normální faktury a daňového dokladu k přijaté platbě -->
	<xsl:template match="FaktVyd/SeznamPolozek/Polozka|FaktVyd_DPP/SeznamPolozek/Polozka">	
		<xsl:element name="{name()}">
			<xsl:for-each select="SklPolozka">
				<xsl:element name="{name()}">
					<xsl:apply-templates select="KmKarta"/>
					<xsl:apply-templates select="SeznamVC"/>
					<xsl:apply-templates select="Slozeni"/>
				</xsl:element>
			</xsl:for-each>
			<xsl:apply-templates select="NesklPolozka"/>
			<xsl:apply-templates select="Popis"/>
			<xsl:apply-templates select="Poznamka"/>
			<xsl:apply-templates select="PocetMJ"/>
			<xsl:apply-templates select="SazbaDPH"/>
			<xsl:apply-templates select="Cena"/>
			<xsl:apply-templates select="CenaTyp"/>
			<xsl:apply-templates select="Sleva"/>
			<xsl:apply-templates select="CenaPoSleve"/>
			<xsl:apply-templates select="Poradi"/>
			<xsl:apply-templates select="Valuty"/>

			<!-- Seznam vazeb - související zálohová faktura k odpočtové položce -->
			<xsl:if test="(SeznamVazeb/Vazba/Typ = 'ZL') and (SeznamVazeb/Vazba/Doklad/Druh = 'FV')">
				<xsl:element name="SeznamVazeb">
					<xsl:for-each select="SeznamVazeb/Vazba">
							<xsl:if test="(Typ = 'ZL') and (Doklad/Druh = 'FV') ">
								<xsl:element name="Vazba">
										<xsl:apply-templates select="Typ"/>
										<xsl:apply-templates select="PodTyp"/>
										<xsl:element name="Doklad">
											<xsl:element name="Druh">FP</xsl:element>
											<xsl:element name="PrijatDokl"><xsl:value-of select="Doklad/Cislo"/></xsl:element>
										</xsl:element>
								</xsl:element>
							</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>

		</xsl:element>
	</xsl:template>
	<xsl:template match="FaktVyd/SeznamZalPolozek/Polozka">	<!-- položky zálohové faktury -->
		<xsl:element name="{name()}">
			<xsl:apply-templates select="KmKarta"/>
			<xsl:apply-templates select="NesklPolozka"/>
			<xsl:apply-templates select="Popis"/>
			<xsl:apply-templates select="Poznamka"/>
			<xsl:apply-templates select="PocetMJ"/>
			<xsl:apply-templates select="Cena"/>
			<xsl:apply-templates select="SazbaDPH"/>
			<xsl:apply-templates select="TypCeny"/>
			<xsl:apply-templates select="Sleva"/>
			<xsl:apply-templates select="CenaPoSleve"/>
			<xsl:apply-templates select="VyriditNej"/>
			<xsl:apply-templates select="Vyridit_do"/>
			<xsl:apply-templates select="Hmotnost"/>
			<xsl:apply-templates select="Poradi"/>
			<xsl:apply-templates select="Valuty"/>
			<xsl:apply-templates select="SeznamVC"/>
			<xsl:apply-templates select="Slozeni"/>
		</xsl:element>
	</xsl:template>

	<!-- záhlaví objednávky, poptávky, nabídky -->
	<xsl:template name="Objedn">
		<xsl:apply-templates select="Popis"/>
		<xsl:apply-templates select="Poznamka"/>
		<xsl:apply-templates select="TextPredPo"/>
		<xsl:apply-templates select="TextZaPol"/>
		<xsl:apply-templates select="Vystaveno"/>
		<xsl:apply-templates select="VyriditDo"/>
		<xsl:apply-templates select="MojeFirma"/>
		<xsl:apply-templates select="SouhrnDPH"/>
		<xsl:apply-templates select="Celkem"/>
		<xsl:apply-templates select="Sleva"/>
		<xsl:apply-templates select="Vystavil"/>
		<xsl:apply-templates select="PlatPodm"/>
		<xsl:apply-templates select="Doprava"/>
		<xsl:apply-templates select="VyriditNej"/>
		<xsl:element name="PrimDoklad">
			<xsl:value-of select="Doklad"/>
		</xsl:element>
		<xsl:apply-templates select="Valuty"/>
		<xsl:apply-templates select="SazbaDPH1"/>
		<xsl:apply-templates select="SazbaDPH2"/>
		<xsl:apply-templates select="Polozka"/>
	</xsl:template>
	<!-- položka obj. vydané a všechny podpoložky - komponenty složených karet -->
	<xsl:template match="ObjVyd//Polozka|NabVyd//Polozka|PoptVyd//Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="KmKarta"/>
			<xsl:apply-templates select="NesklPolozka"/>
			<xsl:apply-templates select="Popis"/>
			<xsl:apply-templates select="Poznamka"/>
			<xsl:apply-templates select="PocetMJ"/>
			<xsl:apply-templates select="Cena"/>
			<xsl:apply-templates select="SazbaDPH"/>
			<xsl:apply-templates select="TypCeny"/>
			<xsl:apply-templates select="Sleva"/>
			<xsl:apply-templates select="CenaPoSleve"/>
			<xsl:apply-templates select="VyriditNej"/>
			<xsl:apply-templates select="Vyridit_do"/>
			<xsl:apply-templates select="Hmotnost"/>
			<xsl:apply-templates select="Poradi"/>
			<xsl:apply-templates select="Valuty"/>
			<xsl:apply-templates select="SeznamVC"/>
			<xsl:apply-templates select="Slozeni"/>
		</xsl:element>
	</xsl:template>

	<!-- záhlaví skladového dokladu -->
	<xsl:template name="SklDokl">
		<xsl:apply-templates select="Datum"/>
		<xsl:apply-templates select="SouhrnDPH"/>
		<xsl:apply-templates select="Celkem"/>
		<xsl:apply-templates select="Sleva"/>
		<xsl:apply-templates select="PopisX"/>
		<xsl:apply-templates select="Vystavil"/>
		<xsl:apply-templates select="VyrizFaktu"/>
		<xsl:apply-templates select="TextPredPo"/>
		<xsl:apply-templates select="TextZaPol"/>
		<xsl:apply-templates select="SazbaDPH1"/>
		<xsl:apply-templates select="SazbaDPH2"/>
		<xsl:element name="PrimDoklad">
			<xsl:value-of select="CisloDokla"/>
		</xsl:element>
		<xsl:apply-templates select="MojeFirma"/>
		<xsl:apply-templates select="Polozka"/>
	</xsl:template>
	<!-- položka skl. dokladu a všechny podpoložky - komponenty složených karet -->
	<xsl:template match="Vydejka//Polozka|Prodejka//Polozka|DLVyd//Polozka|FaktVyd/SeznamPolozek/Polozka//Polozka">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="KmKarta"/>
			<xsl:apply-templates select="Nazev"/>
			<xsl:apply-templates select="PocetMJ"/>
			<xsl:apply-templates select="Cena"/>
			<xsl:apply-templates select="DPH"/>
			<xsl:apply-templates select="CenaTyp"/>
			<xsl:apply-templates select="CenovaHlad"/>
			<xsl:apply-templates select="Poznamka"/>
			<xsl:apply-templates select="Vratka"/>
			<xsl:apply-templates select="SeznamVC"/>
			<xsl:apply-templates select="Slozeni"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="KmKarta">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="Popis"/>
			<xsl:apply-templates select="Zkrat"/>
			<xsl:apply-templates select="Pozn"/>
			<xsl:apply-templates select="MJ"/>
			<xsl:apply-templates select="UzivCode"/>
			<xsl:apply-templates select="Katalog"/>
			<xsl:apply-templates select="BarCode"/>
			<xsl:apply-templates select="BCTyp"/>
			<xsl:apply-templates select="TypZarDoby"/>
			<xsl:apply-templates select="ZarDoba"/>
			<xsl:apply-templates select="TypKarty"/>
			<xsl:apply-templates select="EvDruhy"/>
			<xsl:apply-templates select="EvVyrCis"/>
			<xsl:apply-templates select="DesMist"/>
			<xsl:apply-templates select="Obrazek"/>
			<xsl:apply-templates select="Obrazek2"/>
			<xsl:apply-templates select="Popis1"/>
			<xsl:apply-templates select="Pozn1"/>
			<xsl:apply-templates select="Popis2"/>
			<xsl:apply-templates select="Pozn2"/>
			<xsl:apply-templates select="Popis3"/>
			<xsl:apply-templates select="Pozn3"/>
			<xsl:apply-templates select="Objem"/>
			<xsl:apply-templates select="Hmotnost"/>
			<xsl:apply-templates select="Slozeni"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="KmKarta/Slozeni/Komponenta">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="PocMJ"/>
			<xsl:apply-templates select="KmKarta"/>
		</xsl:element>
	</xsl:template>


	<!-- moje firma -> odběratel/dodavatel -->
	<xsl:template match="MojeFirma">
		<xsl:element name="DodOdb">
			<xsl:apply-templates select="*|@*|text()"/>
		</xsl:element>
	</xsl:template>


	<!-- implicitní přepis elementů, atributů a obsahu -->
	<xsl:template match="node()">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="*|@*|text()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>

</xsl:stylesheet>
