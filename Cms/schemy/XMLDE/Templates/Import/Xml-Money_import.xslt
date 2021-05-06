<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"

xmlns:isdocX="http://isdoc.cz/namespace/invoice"
xmlns:isdoc="http://isdoc.cz/namespace/2013"
xmlns:money="http://www.money.cz"

>

<!--	Transformační šablona na zrcadlení obchodních dokladů - z dokladů vydaných vytvoří doklady přijaté. Šablona je použita při importu faktur, daňových dokladů k přijaté platbě a objednávek, které dodavatel posílá svému odběrateli. Do transformace jsou zahrnuty pouze údaje, které mají pro příjemce dokladu význam. Šablona podporuje import dokladů z formátu ISDOC. Při importu z formátu xml-money jsou složené karty typu "komplet" a "výrobek" převedeny na jednoduché karty.

Poznámka: struktura Money obsažená ve struktuře ISDOC povinně obsahuje jmenný prostor. Proto se při čtení používá varianta se jmenným prostorem (viz money:)  i bez jmenného prostoru (soubor má příponu xml-money).

	Autor: Marek Vykydal
 -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:choose>
			<!-- na vstupu je struktura Money S3 -> transformuje podle struktury Money S3 -->
			<xsl:when test="money:MoneyData | MoneyData ">
				<xsl:apply-templates select="money:MoneyData | MoneyData "/>
			</xsl:when>

			<!-- na vstupu je struktura ISDOC obsahující strukturu Money S3 -> transformuje podle struktury Money S3 -->
			<xsl:when test="((contains(isdoc:Invoice/isdoc:IssuingSystem,'Money S3')) and (isdoc:Invoice/isdoc:Extensions/money:MoneyData))
							or ((contains(isdocX:Invoice/isdocX:IssuingSystem,'Money S3')) and (isdocX:Invoice/isdocX:Extensions/money:MoneyData)) ">
				<xsl:apply-templates select="isdoc:Invoice/isdoc:Extensions/money:MoneyData | isdocX:Invoice/isdocX:Extensions/money:MoneyData "/>
			</xsl:when>

			<!-- na vstupu je struktura ISDOC bez struktury Money S3 (doklad z jiného systému) -> transformuje podle struktury ISDOC -->
			<xsl:when test="isdoc:Invoice | isdocX:Invoice ">
				<xsl:apply-templates select="isdoc:Invoice | isdocX:Invoice "/>
			</xsl:when>

			<!--	na vstupu je jiná struktura, provede pouze její zkopírování -->
			<xsl:otherwise>
				<xsl:apply-templates select="*|@*|text()"/>
			</xsl:otherwise>

		</xsl:choose>
	</xsl:template>

	<!-- IMPORT PODLE STRUKTURY MONEY -->
	<xsl:template match="money:MoneyData | MoneyData">
		<xsl:element name="{local-name()}">

			<!--	Informace o tom, že se transformuje podle struktury MoneyData -->
			<xsl:attribute name="Transformace">1</xsl:attribute>

			<xsl:apply-templates select="money:SeznamFaktVyd | SeznamFaktVyd "/>
			<xsl:apply-templates select="money:SeznamFaktVyd_DPP | SeznamFaktVyd_DPP "/>
			<xsl:apply-templates select="money:SeznamObjVyd | SeznamObjVyd "/>
		</xsl:element>
	</xsl:template>

	<!--	FV -> FP -->
	<xsl:template match="money:SeznamFaktVyd | SeznamFaktVyd ">
		<xsl:element name="SeznamFaktPrij">
			<xsl:apply-templates select="money:FaktVyd | FaktVyd "/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="money:FaktVyd | FaktVyd ">
		<xsl:element name="FaktPrij">
			<xsl:call-template name="Faktura"/>
		</xsl:element>
	</xsl:template>

	<!--	FV_DPP -> FP_DPP (daňový doklad k přijaté platbě) -->
	<xsl:template match="money:SeznamFaktVyd_DPP | SeznamFaktVyd_DPP ">
		<xsl:element name="SeznamFaktPrij_DPP">
			<xsl:apply-templates select="money:FaktVyd_DPP | FaktVyd_DPP "/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="money:FaktVyd_DPP | FaktVyd_DPP ">
		<xsl:element name="FaktPrij_DPP">
			<xsl:call-template name="Faktura"/>		<!--	daňový doklad k přijaté platbě má stejný obsah jako faktura -->
		</xsl:element>
	</xsl:template>

	<!--	OV -> OP -->
	<xsl:template match="money:SeznamObjVyd | SeznamObjVyd ">
		<xsl:element name="SeznamObjPrij">
			<xsl:apply-templates select="money:ObjVyd | ObjVyd "/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="money:ObjVyd | ObjVyd ">
		<xsl:element name="ObjPrij">
			<xsl:call-template name="Objedn"/>
		</xsl:element>
	</xsl:template>

<!-- FAKTURA, DAŇOVÝ DOKLAD K PŘIJATÉ PLATBĚ -->
	<xsl:template name="Faktura">
		<!-- Při přenosu faktury z jednoho Money do jiného Money budeme GUID v importovaném souboru odstraňovat.
			Při ponechání GUIDU by totiž mohla u odběratele nastat situace, kdy při přenosu faktury (ve formátu Xml-Money nebo ISDOC)
			v nové verzi programu (16.000) z důvodu její aktualizace se faktura díky existenci GUIDU naimportuje u odběratele jako nová,
			protože původní faktura vystavená ve starší verzi programu GUID neobsahovala. V tomto případě tedy bude v konfiguračním souboru importu zapnutý přepínač „Automaticky“.
			Toto řešení je dostačující, protože v Money stejně nelze u již existujícího dokladu změnit číslo dokladu. Proto přenos GUIDU není potřebný.
		<xsl:if test="string-length(money:GUID | GUID) &gt; 0 ">
			<xsl:apply-templates select="money:GUID | GUID"/>
		</xsl:if>
		-->

		<xsl:apply-templates select="money:Popis | Popis"/>

		<xsl:choose>
			<xsl:when test="string-length(money:VyriditNej | VyriditNej) &gt; 0 ">
				<xsl:apply-templates select="money:Vystaveno | Vystaveno"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="Vystaveno">
					<xsl:value-of select="../../../../@MoneyDate"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:apply-templates select="money:PlnenoDPH | PlnenoDPH "/>

		<!-- datum uplatnění DPH se uvede pouze v případě, pokud se nebude jednat o dobropis ani zálohovou fakturu -->
		<xsl:if test="(not(money:Druh = 'L') and not(money:Dobropis = 1))
					and (not(Druh = 'L') and not(Dobropis = 1)) ">
			<xsl:element name="Doruceno">
				<xsl:value-of select="../../../../@MoneyDate"/>
			</xsl:element>
		</xsl:if>

		<xsl:apply-templates select="money:KonstSym | KonstSym"/>
		<xsl:apply-templates select="money:SpecSymbol | SpecSymbol"/>
		<xsl:element name="PrijatDokl">
			<xsl:value-of select="money:Doklad | Doklad"/>
		</xsl:element>

		<xsl:if test="(money:Druh | Druh) !='D' ">
			<xsl:apply-templates select="money:Splatno | Splatno"/>
			<xsl:element name="VarSymbol">
				<xsl:value-of select="money:Doklad | Doklad"/>
			</xsl:element>
			<xsl:element name="Poznamka">
				<xsl:value-of select="money:ZpDopravy | ZpDopravy "/>
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates select="money:Druh | Druh "/>
		<xsl:apply-templates select="money:Dobropis | Dobropis"/>
		<xsl:apply-templates select="money:Uhrada | Uhrada"/>

		<xsl:if test="string-length(money:SazbaDPH1 | SazbaDPH1) &gt; 0 ">
			<xsl:apply-templates select="money:SazbaDPH1 | SazbaDPH1"/>
		</xsl:if>
		<xsl:if test="string-length(money:SazbaDPH2 | SazbaDPH2) &gt; 0 ">
			<xsl:apply-templates select="money:SazbaDPH2 | SazbaDPH2"/>
		</xsl:if>

		<xsl:apply-templates select="money:Sleva | Sleva"/>
		<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
		<xsl:apply-templates select="money:Celkem | Celkem"/>
		<xsl:apply-templates select="money:Proplatit | Proplatit"/>
		<xsl:apply-templates select="money:Valuty | Valuty"/>
		<xsl:apply-templates select="money:ValutyProp | ValutyProp"/>
		<xsl:apply-templates select="money:SumZaloha | SumZaloha"/>
		<xsl:apply-templates select="money:SumZalohaC | SumZalohaC"/>
		<xsl:apply-templates select="money:VyriditNej | VyriditNej"/>
		<xsl:apply-templates select="money:Vyridit_do | Vyridit_do"/>
		<xsl:apply-templates select="money:MojeFirma | MojeFirma"/>
		<xsl:apply-templates select="money:DodOdb | DodOdb"/>
		<xsl:apply-templates select="money:SeznamPolozek | SeznamPolozek"/>
		<xsl:apply-templates select="money:SeznamZalPolozek | SeznamZalPolozek"/>

		<!-- Seznam vazeb - v případě daňového dokladu související zálohová faktura (číslo přijatého dokladu), v případě normálních faktur související vyřizované objednávky (číslo objednávky vydané převzaté z pole "Doklad došlý") -->
		<xsl:if test="((money:SeznamVazeb/money:Vazba/money:Typ = 'DD') and (money:SeznamVazeb/money:Vazba/money:Doklad/money:Druh = 'FV'))
					or ((SeznamVazeb/Vazba/Typ = 'DD') and (SeznamVazeb/Vazba/Doklad/Druh = 'FV'))
					or ((money:SeznamVazeb/money:Vazba/money:Typ = 'PR') and (money:SeznamVazeb/money:Vazba/money:Doklad/money:Druh = 'OP') and (string-length(money:SeznamVazeb/money:Vazba/money:Doklad/money:PrijatDokl) &gt; 0))
					or ((SeznamVazeb/Vazba/Typ = 'PR') and (SeznamVazeb/Vazba/Doklad/Druh = 'OP') and (string-length(SeznamVazeb/Vazba/Doklad/PrijatDokl) &gt; 0))">
			<xsl:element name="SeznamVazeb">
				<xsl:for-each select="money:SeznamVazeb/money:Vazba | SeznamVazeb/Vazba">
					<xsl:choose>
						<xsl:when test="((money:Typ = 'DD') and (money:Doklad/money:Druh = 'FV')) or ((Typ = 'DD') and (Doklad/Druh = 'FV')) ">
							<xsl:element name="Vazba">
									<xsl:apply-templates select="money:Typ | Typ"/>
									<xsl:apply-templates select="money:PodTyp | PodTyp"/>
									<xsl:element name="Doklad">
										<xsl:element name="Druh">FP</xsl:element>
										<xsl:element name="PrijatDokl"><xsl:value-of select="money:Doklad/money:Cislo | Doklad/Cislo"/></xsl:element>
									</xsl:element>
							</xsl:element>
						</xsl:when>
						<xsl:when test="((money:Typ = 'PR') and (money:Doklad/money:Druh = 'OP') and (string-length(money:Doklad/money:PrijatDokl) &gt; 0))
										or ((Typ = 'PR') and (Doklad/Druh = 'OP') and (string-length(Doklad/PrijatDokl) &gt; 0))">
							<xsl:element name="Vazba">
									<xsl:apply-templates select="money:Typ | Typ"/>
									<xsl:element name="Doklad">
										<xsl:element name="Druh">OV</xsl:element>
										<xsl:element name="Cislo"><xsl:value-of select="money:Doklad/money:PrijatDokl | Doklad/PrijatDokl"/></xsl:element>
									</xsl:element>
							</xsl:element>
						</xsl:when>
					</xsl:choose>

				</xsl:for-each>
			</xsl:element>
		</xsl:if>

		<!-- přílohy (připojené dokumenty) -->
		<xsl:call-template name="Dokumenty"/>

	</xsl:template>

	<!-- položky normální faktury a daňového dokladu k přijaté platbě -->
	<xsl:template match="money:FaktVyd/money:SeznamPolozek/money:Polozka | money:FaktVyd_DPP/money:SeznamPolozek/money:Polozka |
							FaktVyd/SeznamPolozek/Polozka | FaktVyd_DPP/SeznamPolozek/Polozka ">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Popis | Popis"/>
			<xsl:apply-templates select="money:Poznamka | Poznamka"/>
			<xsl:apply-templates select="money:PocetMJ | PocetMJ"/>
			<xsl:apply-templates select="money:SazbaDPH | SazbaDPH"/>
			<xsl:apply-templates select="money:Cena | Cena"/>
			<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
			<xsl:apply-templates select="money:CenaTyp | CenaTyp"/>
			<xsl:apply-templates select="money:Sleva | Sleva"/>
			<xsl:apply-templates select="money:CenaPoSleve | CenaPoSleve"/>
			<xsl:apply-templates select="money:Valuty | Valuty"/>
			<xsl:apply-templates select="money:NesklPolozka | NesklPolozka"/>
			<xsl:for-each select="money:SklPolozka | SklPolozka">
				<xsl:element name="{local-name()}">
					<xsl:apply-templates select="money:Vratka | Vratka"/>
					<xsl:apply-templates select="money:Hmotnost | Hmotnost"/>
					<xsl:apply-templates select="money:KodStatuPuv | KonStatuPuv "/>
					<xsl:apply-templates select="money:KmKarta | KmKarta">
						<xsl:with-param name="DPH" select="../money:SazbaDPH | ../SazbaDPH"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="money:SeznamVC | SeznamVC"/>
					<xsl:if test="((money:KmKarta/money:TypKarty!='komplet') and (money:KmKarta/money:TypKarty!='vyrobek')) 
								or ((KmKarta/TypKarty!='komplet') and (KmKarta/TypKarty!='vyrobek')) ">
						<xsl:apply-templates select="money:Slozeni | Slozeni"/>
					</xsl:if>
				</xsl:element>
			</xsl:for-each>

		<!-- Seznam vazeb - související zálohová faktura k odpočtové položce -->
		<xsl:if test="((money:SeznamVazeb/money:Vazba/money:Typ = 'ZL') and (money:SeznamVazeb/money:Vazba/money:Doklad/money:Druh = 'FV'))
					or ((SeznamVazeb/Vazba/Typ = 'ZL') and (SeznamVazeb/Vazba/Doklad/Druh = 'FV'))">
			<xsl:element name="SeznamVazeb">
				<xsl:for-each select="money:SeznamVazeb/money:Vazba | SeznamVazeb/Vazba">
						<xsl:if test="((money:Typ = 'ZL') and (money:Doklad/money:Druh = 'FV')) or ((Typ = 'ZL') and (Doklad/Druh = 'FV')) ">
							<xsl:element name="Vazba">
									<xsl:apply-templates select="money:Typ | Typ"/>
									<xsl:apply-templates select="money:PodTyp | PodTyp"/>
									<xsl:element name="Doklad">
										<xsl:element name="Druh">FP</xsl:element>
										<xsl:element name="PrijatDokl"><xsl:value-of select="money:Doklad/money:Cislo | Doklad/Cislo"/></xsl:element>
									</xsl:element>
							</xsl:element>
						</xsl:if>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>

		</xsl:element>
	</xsl:template>

	<!-- podpoložky normální faktury -->
	<xsl:template match="money:SeznamPolozek/money:Polozka/money:SklPolozka/money:Slozeni/money:SubPolozka/money:Polozka |
							SeznamPolozek/	Polozka/SklPolozka/Slozeni/SubPolozka/Polozka ">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Nazev | Nazev"/>
			<xsl:apply-templates select="money:Poznamka | Poznamka"/>
			<xsl:apply-templates select="money:PocetMJ | PocetMJ"/>
			<xsl:apply-templates select="money:Cena | Cena"/>
			<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
			<xsl:apply-templates select="money:Valuty | Valuty"/>
			<xsl:apply-templates select="money:DPH | DPH"/>
			<xsl:apply-templates select="money:CenaTyp | CenaTyp"/>
			<xsl:apply-templates select="money:Sleva | Sleva"/>
			<xsl:apply-templates select="money:CenaPoSleve | CenaPoSleve "/>
			<xsl:apply-templates select="money:Vratka | Vratka"/>
			<xsl:apply-templates select="money:KodStatuPuv | KonStatuPuv"/>
			<xsl:apply-templates select="money:Hmotnost | Hmotnost"/>
			<xsl:apply-templates select="money:KmKarta | KmKarta">
				<xsl:with-param name="DPH" select="money:DPH | DPH"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="money:SeznamVC | SeznamVC"/>
			<xsl:if test="((money:KmKarta/money:TypKarty!='komplet') and (money:KmKarta/money:TypKarty!='vyrobek'))
						or ((KmKarta/TypKarty!='komplet') and (KmKarta/TypKarty!='vyrobek')) ">
				<xsl:apply-templates select="money:Slozeni | Slozeni"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- položky zálohové faktury vydané včetně podpoložek -->
	<xsl:template match="money:FaktVyd/money:SeznamZalPolozek//money:Polozka |
							FaktVyd/SeznamZalPolozek//Polozka ">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Popis | Popis"/>
			<xsl:apply-templates select="money:Poznamka | Poznamka"/>
			<xsl:apply-templates select="money:PocetMJ | PocetMJ"/>
			<xsl:apply-templates select="money:Cena | Cena"/>
			<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
			<xsl:apply-templates select="money:SazbaDPH | SazbaDPH"/>
			<xsl:apply-templates select="money:TypCeny | TypCeny"/>
			<xsl:apply-templates select="money:Sleva | Sleva"/>
			<xsl:apply-templates select="money:CenaPoSleve | CenaPoSleve"/>
			<xsl:apply-templates select="money:VyriditNej | VyriditNej"/>
			<xsl:apply-templates select="money:Vyridit_do | Vyridit_do"/>
			<xsl:apply-templates select="money:Hmotnost | Hmotnost"/>
			<xsl:apply-templates select="money:KodStatuPuv | KonStatuPuv"/>
			<xsl:apply-templates select="money:Valuty | Valuty"/>
			<xsl:apply-templates select="money:NesklPolozka | NesklPolozka"/>
			<xsl:apply-templates select="money:KmKarta | KmKarta">
				<xsl:with-param name="DPH" select="money:SazbaDPH | SazbaDPH"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="money:SeznamVC | SeznamVC"/>
			<xsl:if test="((money:KmKarta/money:TypKarty!='komplet') and (money:KmKarta/money:TypKarty!='vyrobek'))
						or ((KmKarta/TypKarty!='komplet') and (KmKarta/TypKarty!='vyrobek')) ">
				<xsl:apply-templates select="money:Slozeni | Slozeni"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>


<!-- OBJEDNÁVKA -->
	<xsl:template name="Objedn">
		<!-- 
		<xsl:if test="string-length(money:GUID | GUID) &gt; 0 ">
			<xsl:apply-templates select="money:GUID | GUID"/>
		</xsl:if>
		-->
		<xsl:apply-templates select="money:Popis | Popis"/>
		<xsl:element name="PrimDoklad">
			<xsl:value-of select="money:Doklad | Doklad"/>
		</xsl:element>
		<xsl:apply-templates select="money:Poznamka | Poznamka"/>
		<xsl:apply-templates select="money:TextPredPo | TextPredPo"/>
		<xsl:apply-templates select="money:TextZaPol | TextZaPol"/>
		<xsl:if test="string-length(money:VyriditNej | VyriditNej) &gt; 0">
			<xsl:apply-templates select="money:Vystaveno | Vystaveno"/>
		</xsl:if>
		<xsl:apply-templates select="money:VyriditNej | VyriditNej"/>
		<xsl:apply-templates select="money:Vyridit_do | Vyridit_do"/>
		<xsl:apply-templates select="money:Celkem | Celkem"/>

		<xsl:if test="string-length(money:SazbaDPH1 | SazbaDPH1) &gt; 0 ">
			<xsl:apply-templates select="money:SazbaDPH1 | SazbaDPH1"/>
		</xsl:if>
		<xsl:if test="string-length(money:SazbaDPH2 | SazbaDPH2) &gt; 0 ">
			<xsl:apply-templates select="money:SazbaDPH2 | SazbaDPH2"/>
		</xsl:if>

		<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
		<xsl:apply-templates select="money:Sleva | Sleva"/>
		<xsl:apply-templates select="money:Valuty | Valuty"/>
		<xsl:apply-templates select="money:PlatPodm | PlatPodm"/>
		<xsl:apply-templates select="money:Doprava | Doprava"/>
		<xsl:apply-templates select="money:MojeFirma | MojeFirma"/>
		<xsl:apply-templates select="money:DodOdb | DodOdb"/>
		<xsl:apply-templates select="money:KonecPrij | KonecPrij"/>
		<xsl:apply-templates select="money:Polozka | Polozka"/>
	</xsl:template>

	<!-- položky objednávky včetně podpoložek -->
	<xsl:template match="money:ObjVyd//money:Polozka | ObjVyd//Polozka ">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Popis | Popis"/>
			<xsl:apply-templates select="money:Poznamka | Poznamka"/>
			<xsl:apply-templates select="money:PocetMJ | PocetMJ"/>
			<xsl:apply-templates select="money:Cena | Cena"/>
			<xsl:apply-templates select="money:SouhrnDPH | SouhrnDPH"/>
			<xsl:apply-templates select="money:SazbaDPH | SazbaDPH"/>
			<xsl:apply-templates select="money:TypCeny | TypCeny"/>
			<xsl:apply-templates select="money:Sleva | Sleva"/>
			<xsl:apply-templates select="money:CenaPoSleve | CenaPoSleve "/>
			<xsl:apply-templates select="money:VyriditNej | VyriditNej"/>
			<xsl:apply-templates select="money:Vyridit_do | Vyridit_do"/>
			<xsl:apply-templates select="money:Hmotnost | Hmotnost"/>
			<xsl:apply-templates select="money:KodStatuPuv | KodStatuPuv"/>
			<xsl:apply-templates select="money:Valuty | Valuty"/>
			<xsl:apply-templates select="money:NesklPolozka | NesklPolozka"/>
			<xsl:apply-templates select="money:KmKarta | KmKarta">
				<xsl:with-param name="DPH" select="money:SazbaDPH | SazbaDPH"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="money:SeznamVC | SeznamVC"/>
			<xsl:if test="((money:KmKarta/money:TypKarty!='komplet') and (money:KmKarta/money:TypKarty!='vyrobek'))
						or ((KmKarta/TypKarty!='komplet') and (KmKarta/TypKarty!='vyrobek')) ">	
				<xsl:apply-templates select="money:Slozeni | Slozeni"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>

<!-- KMENOVÁ KARTA -->
	<xsl:template match="money:KmKarta | KmKarta">
		<xsl:param name="DPH"/>

		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Popis | Popis"/>
			<xsl:element name="TypKarty">			<!-- komplet a výrobek se převádí na jednoduchou kartu -->
				<xsl:choose>
					<xsl:when test="(money:TypKarty='komplet') or (money:TypKarty='vyrobek') 
									or (TypKarty='komplet') or (TypKarty='vyrobek') ">jednoducha</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="money:TypKarty | TypKarty"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:if test="string-length(money:Zkrat | Zkrat) &gt; 0">
				<xsl:apply-templates select="money:Zkrat | Zkrat"/>
			</xsl:if>
			<xsl:if test="string-length(money:Katalog | Katalog) &gt; 0">
				<xsl:apply-templates select="money:Katalog | Katalog"/>
			</xsl:if>
			<xsl:if test="string-length(money:BarCode | BarCode) &gt; 0">
				<xsl:apply-templates select="money:BarCode | BarCode"/>
			</xsl:if>
			<xsl:if test="string-length(money:BCTyp | BCTyp) &gt; 0">
				<xsl:apply-templates select="money:BCTyp | BCTyp"/>
			</xsl:if>
			<xsl:if test="string-length(money:UzivCode | UzivCode) &gt; 0">
				<xsl:apply-templates select="money:UzivCode | UzivCode"/>
			</xsl:if>
			<xsl:apply-templates select="money:MJ | MJ "/>
			<xsl:apply-templates select="money:DesMist | DesMist"/>
			<xsl:apply-templates select="money:TypZarDoby | TypZarDoby "/>
			<xsl:apply-templates select="money:ZarDoba | ZarDoba"/>
			<xsl:apply-templates select="money:Hmotnost | Hmotnost "/>
			<xsl:apply-templates select="money:Objem | Objem"/>
			<xsl:apply-templates select="money:KodKN | KodKN"/>
			<xsl:apply-templates select="money:PredmPln | PredmPln"/>
			<xsl:apply-templates select="money:KodStatu | KodStatu"/>
			<xsl:apply-templates select="money:EvVyrCis | EvVyrCis"/>
			<xsl:if test="((money:TypKarty!='komplet') and (money:TypKarty!='vyrobek'))
						 or ((TypKarty!='komplet') and (TypKarty!='vyrobek')) ">
				<xsl:apply-templates select="money:Slozeni | Slozeni"/>
			</xsl:if>

			<xsl:if test="string-length($DPH) &gt; 0">
				<xsl:element name="konfigurace">
					<xsl:element name="SDPH_Nakup"><xsl:value-of select="$DPH"/></xsl:element>
					<xsl:element name="SDPH_Prod"><xsl:value-of select="$DPH"/></xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:element>
	</xsl:template>

	<xsl:template match="money:KmKarta/money:Slozeni/money:Komponenta | KmKarta/Slozeni/Komponenta">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:PocMJ | PocMJ"/>
			<xsl:apply-templates select="money:KmKarta | KmKarta"/>
		</xsl:element>
	</xsl:template>


<!-- MOJE FIRMA (FV, OV) -> DODAVATEL (FP, OP) -->
	<xsl:template match="money:MojeFirma | MojeFirma">
		<xsl:element name="DodOdb">
			<xsl:call-template name="Firma"/>
		</xsl:element>
	</xsl:template>

<!-- ODBĚRATEL (FV, OV) -> MOJE FIRMA (FP, OP) -->
	<xsl:template match="money:DodOdb | DodOdb">
		<xsl:element name="MojeFirma">
			<xsl:call-template name="Firma"/>
		</xsl:element>
	</xsl:template>

<!-- KONEČNÝ PŘÍJEMCE (OV -> OP) - pouze přepis  -->
	<xsl:template match="money:KonecPrij | KonecPrij">
		<xsl:element name="KonecPrij">
			<xsl:call-template name="Firma"/>
		</xsl:element>
	</xsl:template>

	<!-- firma -->
	<xsl:template name="Firma">
		<xsl:apply-templates select="money:Nazev | Nazev"/>
		<xsl:apply-templates select="money:Adresa | Adresa"/>
		<xsl:apply-templates select="money:ObchNazev | ObchNazev"/>
		<xsl:apply-templates select="money:ObchAdresa | ObchAdresa"/>
		<xsl:apply-templates select="money:FaktNazev | FaktNazev"/>
		<xsl:apply-templates select="money:FaktAdresa | FaktAdresa"/>
		<xsl:apply-templates select="money:Tel | Tel"/>
		<xsl:apply-templates select="money:Fax | Fax"/>
		<xsl:apply-templates select="money:Mobil | Mobil"/>
		<xsl:apply-templates select="money:EMail | EMail"/>
		<xsl:apply-templates select="money:WWW | WWW"/>
		<xsl:if test="string-length(money:ICO | ICO) &gt; 0">
			<xsl:apply-templates select="money:ICO | ICO"/>
		</xsl:if>
		<xsl:if test="string-length(money:DIC | DIC) &gt; 0">
			<xsl:apply-templates select="money:DIC | DIC"/>
		</xsl:if>
		<xsl:if test="string-length(money:DICSK | DICSK) &gt; 0">
			<xsl:apply-templates select="money:DICSK | DICSK"/>
		</xsl:if>
		<xsl:if test="string-length(money:DanIC | DanIC) &gt; 0">		<!-- element DanIC se vyskytuje pod elementem MojeFirma v SK verzi namísto elementu DICSK -->
			<xsl:element name="DICSK">
				<xsl:value-of select="money:DanIC | DanIC"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(money:DIC | DIC) &gt; 0">			<!-- element PlatceDPH se nevyskytuje pod elementem MojeFirma, proto je zde podmínka na DIČ -->
			<PlatceDPH>1</PlatceDPH>
		</xsl:if>
		<xsl:apply-templates select="money:FyzOsoba | FyzOsoba "/>
		<xsl:if test="string-length(money:Banka | Banka) &gt; 0">
			<xsl:apply-templates select="money:Banka | Banka"/>
		</xsl:if>
		<xsl:if test="string-length(money:Ucet | Ucet ) &gt; 0">
			<xsl:apply-templates select="money:Ucet | Ucet"/>
		</xsl:if>
		<xsl:if test="string-length(money:KodBanky | KodBanky) &gt; 0">
			<xsl:apply-templates select="money:KodBanky | KodBanky"/>
		</xsl:if>
		<xsl:if test="string-length(money:KodPartn | KodPartn) &gt; 0">
			<xsl:apply-templates select="money:KodPartn | KodPartn"/>
		</xsl:if>
		<xsl:apply-templates select="money:SpisovaZnacka | SpisovaZnacka"/>
		<xsl:apply-templates select="money:Osoba | Osoba"/>
		<xsl:apply-templates select="money:SeznamBankSpojeni | SeznamBankSpojeni"/>
	</xsl:template>

	<!-- kontaktní osoba -->
	<xsl:template match="money:Osoba | Osoba">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:Osloveni | Osloveni"/>
			<xsl:apply-templates select="money:TitulPred | TitulPred"/>
			<xsl:apply-templates select="money:TitulZa | TitulZa"/>
			<xsl:apply-templates select="money:Jmeno | Jmeno"/>
			<xsl:apply-templates select="money:Prijmeni | Prijmeni"/>
			<xsl:apply-templates select="money:Pohlavi | Pohlavi"/>
			<xsl:apply-templates select="money:Funkce | Funkce"/>
			<xsl:apply-templates select="money:Adresa | Adresa"/>
			<xsl:apply-templates select="money:Tel | Tel"/>
			<xsl:apply-templates select="money:Fax | Fax"/>
			<xsl:apply-templates select="money:Mobil | Mobil"/>
			<xsl:apply-templates select="money:EMail | EMail"/>
			<xsl:apply-templates select="money:WWW | WWW"/>
			<xsl:if test="string-length(money:KodPartn | KodPartn) &gt; 0">
				<xsl:apply-templates select="money:KodPartn | KodPartn "/>
			</xsl:if>
			<xsl:apply-templates select="money:Jednatel | Jednatel"/>
		</xsl:element>
	</xsl:template>

	<!-- seznam bankovních spojení -->
	<xsl:template match="money:SeznamBankSpojeni | SeznamBankSpojeni">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="money:BankSpojeni | BankSpojeni"/>
		</xsl:element>
	</xsl:template>

	<!-- bankovní spojení -->
	<xsl:template match="money:BankSpojeni | BankSpojeni ">
		<xsl:element name="{local-name()}">
			<xsl:if test="string-length(money:Banka | Banka) &gt; 0">
				<xsl:apply-templates select="money:Banka | Banka"/>
			</xsl:if>
			<xsl:if test="string-length(money:Ucet | Ucet) &gt; 0">
				<xsl:apply-templates select="money:Ucet | Ucet "/>
			</xsl:if>
			<xsl:if test="string-length(money:KodBanky | KodBanky ) &gt; 0">
				<xsl:apply-templates select="money:KodBanky | KodBanky "/>
			</xsl:if>
		</xsl:element>
	</xsl:template>


<!-- IMPLICITNÍ PŘEPIS ELEMENTŮ, ATRIBUTŮ A OBSAHU -->
	<xsl:template match="node()">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="*|@*|text()"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>


<!-- FORMÁT ISDOC  -->

<xsl:template match="isdoc:Invoice | isdocX:Invoice">

	<!--	Informace o tom, že alespoň jedna položka obsahuje některý z identifikačních kódů zboží -->
	<xsl:param name="KodZbozi">
		<xsl:for-each select="isdoc:InvoiceLines/isdoc:InvoiceLine/isdoc:Item | isdocX:InvoiceLines/isdocX:InvoiceLine/isdocX:Item">
			<xsl:if test="
					((string-length(isdoc:CatalogueItemIdentification/isdoc:ID) &gt; 0) and (isdoc:CatalogueItemIdentification/isdoc:ID != 0))
					or ((string-length(isdocX:CatalogueItemIdentification/isdocX:ID) &gt; 0) and (isdocX:CatalogueItemIdentification/isdocX:ID != 0))
	
					or ((string-length(isdoc:SellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:SellersItemIdentification/isdoc:ID != 0))
					or ((string-length(isdocX:SellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:SellersItemIdentification/isdocX:ID != 0))
	
					or ((string-length(isdoc:SecondarySellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:SecondarySellersItemIdentification/isdoc:ID != 0))
					or ((string-length(isdocX:SecondarySellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:SecondarySellersItemIdentification/isdocX:ID != 0))

					or ((string-length(isdoc:TertiarySellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:TertiarySellersItemIdentification/isdoc:ID != 0))
					or ((string-length(isdocX:TertiarySellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:TertiarySellersItemIdentification/isdocX:ID != 0))
	
					or ((string-length(isdoc:BuyersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:BuyersItemIdentification/isdoc:ID != 0))
					or ((string-length(isdocX:BuyersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:BuyersItemIdentification/isdocX:ID != 0))">1</xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:element name="MoneyData">
		<!--	Informace o tom, že žádná z položek neobsahuje některý z identifikačních kódů zboží -->
		<xsl:if test="string-length($KodZbozi) = 0">
			<xsl:attribute name="Transformace">2</xsl:attribute>
		</xsl:if>

		<xsl:element name="SeznamFaktPrij">
			<xsl:element name="FaktPrij">
				<xsl:call-template name="Faktura_ISDOC"/>
			</xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:template>

<!-- FAKTURA -->
<xsl:template name="Faktura_ISDOC">

	<xsl:param name="DocumentType" select="isdoc:DocumentType | isdocX:DocumentType"/>
	<xsl:param name="Druh">			<!-- Druh dokladu -->
		<xsl:choose>
			<xsl:when test="$DocumentType = 4">L</xsl:when>
			<xsl:when test="($DocumentType = 5) or ($DocumentType = 6)">D</xsl:when>
			<xsl:otherwise>N</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:param name="Znamenko">		<!--	Znaménko. V případě dobropisu jsou částky v ISDOCU kladné, v Money se uvádí záporné. Bude tedy docházet k obracení znaménka. -->
		<xsl:choose>
			<xsl:when test="($DocumentType = 2) or ($DocumentType = 6)">-1</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<!--	Informace o tom, z jakého elementu (identifikátoru zboží) se budou plnit elementy Katalog a PLU, které se mohou použít jako spojovací klíče kmenové karty -->
	<xsl:param name="KatalogN" select="@Katalog"/>
	<xsl:param name="UzivCodeN" select="@UzivCode"/>
	<xsl:param name="BarCodeN">10</xsl:param>		<!-- Atribut @BarCode prozatím nevyužit. Čárový kód se používá automaticky jako primární spojovací klíč zásoby. -->

	<xsl:param name="PrvniPrevod">	<!-- Pořadí první platby převodem v seznamu plateb, kde je uveden účet -->
		<xsl:call-template name="PrvniPlatba">
			<xsl:with-param name="Pocitadlo" select="1"/>
			<xsl:with-param name="Pocet" select="count(isdoc:PaymentMeans/isdoc:Payment/isdoc:Details)+count(isdocX:PaymentMeans/isdocX:Payment/isdocX:Details)"/>
		</xsl:call-template>
	</xsl:param>

	<!-- Variabilní, konstantní a specifický symbol se nastaví podle první platby -->
	<xsl:param name="KonstSym">
		<xsl:value-of select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:Details/isdoc:ConstantSymbol"/>
		<xsl:value-of select="isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:Details/isdocX:ConstantSymbol"/>
	</xsl:param>

	<xsl:param name="SpecSymbol">
		<xsl:value-of select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:Details/isdoc:SpecificSymbol"/>
		<xsl:value-of select="isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:Details/isdocX:SpecificSymbol"/>
	</xsl:param>

	<xsl:param name="VarSymbol">	
		<xsl:value-of select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:Details/isdoc:VariableSymbol"/>
		<xsl:value-of select="isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:Details/isdocX:VariableSymbol"/>
	</xsl:param>	

	<xsl:param name="Splatno">		<!-- Datum splatnosti se nastaví podle první platby -->
			<xsl:value-of select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:Details/isdoc:IssueDate"/>
			<xsl:value-of select="isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:Details/isdocX:IssueDate"/>
			<xsl:value-of select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:Details/isdoc:PaymentDueDate"/>
			<xsl:value-of select="isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:Details/isdocX:PaymentDueDate"/>
	</xsl:param>

	<xsl:param name="Uhrada">		<!-- Způsob úhrady se nastaví podle první platby -->
		<xsl:variable name="ZpusobPlatby" select="isdoc:PaymentMeans/isdoc:Payment[1]/isdoc:PaymentMeansCode | isdocX:PaymentMeans/isdocX:Payment[1]/isdocX:PaymentMeansCode"/>
			<xsl:choose>
				<xsl:when test="$ZpusobPlatby = 10">hotově</xsl:when>
				<xsl:when test="$ZpusobPlatby = 20">platba šekem</xsl:when>
				<xsl:when test="$ZpusobPlatby = 31">credit transfer</xsl:when>
				<xsl:when test="$ZpusobPlatby = 48">plat. kart.</xsl:when>
				<xsl:when test="$ZpusobPlatby = 49">direct debit</xsl:when>
				<xsl:when test="$ZpusobPlatby = 50">dobírkou</xsl:when>
				<xsl:when test="$ZpusobPlatby = 97">zápočtem</xsl:when>
				<xsl:otherwise>převodem</xsl:otherwise>
			</xsl:choose>
	</xsl:param>

	<!-- definice elementů -->
	<xsl:param name="Popis" select="(isdoc:InvoiceLines/isdoc:InvoiceLine[1]/isdoc:Item/isdoc:Description) | 
									(isdocX:InvoiceLines/isdocX:InvoiceLine[1]/isdocX:Item/isdocX:Description)"/>
	<!-- transformovaný popis na malá písmena -->
	<xsl:param name="mpismena">abcdefghijklmnopqrstuvwxyzáčďéěíľňóřšťúůýž</xsl:param>
	<xsl:param name="vpismena">ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍĽŇÓŘŠŤÚŮÝŽ</xsl:param>
	<xsl:param name="PopisT">
		<xsl:value-of select="translate($Popis, $vpismena, $mpismena)"/>
	</xsl:param>

	<xsl:param name="OznacDok" select="(isdoc:ElectronicPossibilityAgreementReference) | (isdocX:ElectronicPossibilityAgreementReference)"/>
		
	<xsl:param name="CiziMena" select="(isdoc:ForeignCurrencyCode) | (isdocX:ForeignCurrencyCode)"/>
	<xsl:param name="DodObchAdresa" select="(isdoc:AccountingSupplierParty/isdoc:Party) | (isdocX:AccountingSupplierParty/isdocX:Party)"/>
	<xsl:param name="DodFaktAdresa" select="(isdoc:SellerSupplierParty/isdoc:Party) | (isdocX:SellerSupplierParty/isdocX:Party)"/>
	<xsl:param name="OdbObchAdresa" select="(isdoc:AccountingCustomerParty/isdoc:Party) | (isdocX:AccountingCustomerParty/isdocX:Party)"/>
	<xsl:param name="OdbDodAdresa" select="(isdoc:Delivery/isdoc:Party) | (isdocX:Delivery/isdocX:Party)"/>
	<xsl:param name="OdbFaktAdresa" select="(isdoc:BuyerCustomerParty/isdoc:Party) | (isdocX:BuyerCustomerParty/isdocX:Party)"/>
	<xsl:param name="PuvDoklady" select="(isdoc:OriginalDocumentReferences/isdoc:OriginalDocumentReference) | (isdocX:OriginalDocumentReferences/isdocX:OriginalDocumentReference)"/>
	<xsl:param name="Objednavky" select="(isdoc:OrderReferences/isdoc:OrderReference) | (isdocX:OrderReferences/isdocX:OrderReference)"/>
	<xsl:param name="Polozky" select="(isdoc:InvoiceLines/isdoc:InvoiceLine) | (isdocX:InvoiceLines/isdocX:InvoiceLine)"/>
	<xsl:param name="Odpocty" select="(isdoc:TaxedDeposits/isdoc:TaxedDeposit) | (isdocX:TaxedDeposits/isdocX:TaxedDeposit)"/>
	<xsl:param name="OdpoctyN" select="(isdoc:NonTaxedDeposits/isdoc:NonTaxedDeposit) | (isdocX:NonTaxedDeposits/isdocX:NonTaxedDeposit)"/>
	<xsl:param name="OdpoctyD" select="(isdoc:TaxedDeposits/isdoc:TaxedDeposit) | (isdocX:TaxedDeposits/isdocX:TaxedDeposit)"/>
	<xsl:param name="SouhrnDPH" select="(isdoc:TaxTotal/isdoc:TaxSubTotal) | (isdocX:TaxTotal/isdocX:TaxSubTotal)"/>
	<xsl:param name="SeznamDalsiSazby">	<!-- příznak, zda je v souhrnu sazeb DPH alespoň jedna nenulová sazba -->
		<xsl:for-each select="$SouhrnDPH">
			<xsl:variable name="Sazba" select="(isdoc:TaxCategory/isdoc:Percent) | (isdocX:TaxCategory/isdocX:Percent)"/>
			<xsl:if test="$Sazba != 0">1</xsl:if>
		</xsl:for-each>
	</xsl:param>
	<xsl:param name="Celkem" select="(isdoc:LegalMonetaryTotal) | (isdocX:LegalMonetaryTotal)"/>

	<!-- celkem v nulové sazbě DPH -->
	<xsl:param name="Zaklad0_DM" select="sum($SouhrnDPH/isdoc:DifferenceTaxableAmount[../isdoc:TaxCategory/isdoc:Percent = 0])
													+ sum($SouhrnDPH/isdocX:DifferenceTaxableAmount[../isdocX:TaxCategory/isdocX:Percent = 0]) "/>
	<xsl:param name="Zaklad0_CM" select="sum($SouhrnDPH/isdoc:DifferenceTaxableAmountCurr[../isdoc:TaxCategory/isdoc:Percent = 0])
													+ sum($SouhrnDPH/isdocX:DifferenceTaxableAmountCurr[../isdocX:TaxCategory/isdocX:Percent = 0]) "/>
	<!-- celkem nedaňové odpočty (na nedaňové záloze zaplaceno) - na normální faktuře se odečte od nulové sazby DPH -->
	<xsl:param name="OdpoctyN_DM" select="sum($OdpoctyN/isdoc:DepositAmount) + sum($OdpoctyN/isdocX:DepositAmount) "/>
	<xsl:param name="OdpoctyN_CM" select="sum($OdpoctyN/isdoc:DepositAmountCurr) + sum($OdpoctyN/isdocX:DepositAmountCurr) "/>
	<!-- celkem daňové odpočty včetně DPH -->
	<xsl:param name="OdpoctyD_DM" select="sum($OdpoctyD/isdoc:TaxInclusiveDepositAmount) + sum($OdpoctyD/isdocX:TaxInclusiveDepositAmount) "/>
	<xsl:param name="OdpoctyD_CM" select="sum($OdpoctyD/isdoc:TaxInclusiveDepositAmountCurr) + sum($OdpoctyD/isdocX:TaxInclusiveDepositAmountCurr) "/>
	<!-- celkem zaokrouhlení - přičte se k nulové sazbě DPH -->
	<xsl:param name="ZaokrouhleniDM" select="($Celkem/isdoc:PayableRoundingAmount) | ($Celkem/isdocX:PayableRoundingAmount) "/>
	<xsl:param name="ZaokrouhleniCM" select="($Celkem/isdoc:PayableRoundingAmountCurr) | ($Celkem/isdocX:PayableRoundingAmountCurr) "/>
	<!-- výsledné plnění včetně DPH (bez nedaňových odpočtů a bez zaokrouhlení) -->
	<xsl:param name="VyslednePlneniDM" select="($Celkem/isdoc:DifferenceTaxInclusiveAmount) | ($Celkem/isdocX:DifferenceTaxInclusiveAmount)"/>
	<xsl:param name="VyslednePlneniCM" select="($Celkem/isdoc:DifferenceTaxInclusiveAmountCurr) | ($Celkem/isdocX:DifferenceTaxInclusiveAmountCurr)"/>
	<!-- zbývá uhradit -->
	<xsl:param name="Proplatit" select="($Celkem/isdoc:PayableAmount) | ($Celkem/isdocX:PayableAmount) "/>
	<xsl:param name="ValutyProp" select="($Celkem/isdoc:PayableAmountCurr) | ($Celkem/isdocX:PayableAmountCurr) "/>
	<!-- suma záloh -->
	<xsl:param name="SumZaloha" select="($OdpoctyD_DM+$OdpoctyN_DM) "/>
	<xsl:param name="SumZalohaC" select="($OdpoctyD_CM+$OdpoctyN_CM) "/>

	<xsl:element name="Druh">
		<xsl:value-of select="$Druh"/>
	</xsl:element>

	<xsl:if test="$DocumentType = 2">
		<xsl:element name="Dobropis">1</xsl:element>
	</xsl:if>

	<xsl:element name="GUID">{<xsl:value-of select="isdoc:UUID | isdocX:UUID"/>}</xsl:element>
	<xsl:element name="PrijatDokl">
		<xsl:value-of select="isdoc:ID | isdocX:ID"/>
	</xsl:element>

	<!-- pokud první položka není zaokrouhlovací položkou, tak se popis z první položky vloží do popisu dokladu -->
	<xsl:if test="not(contains($PopisT, 'zaokrouhl' ))">
		<xsl:element name="Popis">
			<xsl:value-of select="$Popis"/>
		</xsl:element>
	</xsl:if>

	<xsl:element name="Vystaveno">
		<xsl:value-of select="@MoneyDate"/>
	</xsl:element>

	<xsl:if test="$Druh != 'L' ">
		<xsl:element name="PlnenoDPH">
			<xsl:value-of select="isdoc:TaxPointDate | isdocX:TaxPointDate"/>
		</xsl:element>
	</xsl:if>

	<!-- datum uplatnění DPH se uvede pouze v případě, pokud se nebude jednat o dobropis ani zálohovou fakturu -->
	<xsl:if test="($DocumentType != 2) and ($DocumentType != 4)">
		<xsl:element name="Doruceno">
			<xsl:value-of select="@MoneyDate"/>
		</xsl:element>
	</xsl:if>

	<xsl:if test="$Druh != 'D' ">
		<xsl:if test="(string-length($KonstSym) &gt; 0)">
			<xsl:element name="KonstSym">
				<xsl:value-of select="$KonstSym"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($SpecSymbol) &gt; 0)">
			<xsl:element name="SpecSymbol">
				<xsl:value-of select="$SpecSymbol"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($VarSymbol) &gt; 0)">
			<xsl:element name="VarSymbol">
				<xsl:value-of select="$VarSymbol"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($Splatno) &gt; 0)">
			<xsl:element name="Splatno">
				<xsl:value-of select="$Splatno"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($Uhrada) &gt; 0)">
			<xsl:element name="Uhrada">
				<xsl:value-of select="$Uhrada"/>
			</xsl:element>
		</xsl:if>
	</xsl:if>

	<xsl:if test="$PuvDoklady">
		<xsl:element name="PuvDoklad">
			<xsl:for-each select="$PuvDoklady">
				<xsl:if test="(string-length(isdoc:ID) &gt; 0) or (string-length(isdocX:ID) &gt; 0) ">
					<xsl:if test="position() != 1">;</xsl:if><xsl:value-of select="isdoc:ID | isdocX:ID"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:if>

	<xsl:if test="(string-length(isdoc:Note) &gt; 0) or (string-length(isdocX:Note) &gt; 0) ">
		<xsl:element name="Poznamka">
			<xsl:value-of select="isdoc:Note | isdocX:Note"/>
		</xsl:element>
	</xsl:if>


	<xsl:element name="SouhrnDPH">
		<xsl:element name="SeznamDalsiSazby">

			<!-- nulová sazba se uvede pouze v případě, že byla v ISDOCU použita -->
			<xsl:if test="($SouhrnDPH/isdoc:TaxCategory/isdoc:Percent = 0) or ($SouhrnDPH/isdocX:TaxCategory/isdocX:Percent = 0)
						or ($Zaklad0_DM !=0) or ($ZaokrouhleniDM !=0 ) or (($OdpoctyN_DM !=0 ) and ($Druh = 'N' ))">
				<xsl:element name="DalsiSazba">
					<xsl:element name="HladinaDPH">0</xsl:element>
					<xsl:element name="Sazba">0</xsl:element>
					<xsl:element name="Zaklad">
						<xsl:choose>
							<!-- celkem nedaňové odpočty nejsou v ISDOCU součástí výsledného plnění (viz elementy LegalMonetaryTotal/Difference*).
								Proto u normální faktury je budeme odečítat od výsledného plnění nulové sazby -->
							<xsl:when test="$Druh = 'N' ">
								<xsl:value-of select="format-number((($Zaklad0_DM)+($ZaokrouhleniDM)-($OdpoctyN_DM))*($Znamenko),'0.##' )"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(($Zaklad0_DM+$ZaokrouhleniDM)*($Znamenko),'0.##' )"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="DPH">0</xsl:element>
				</xsl:element>
			</xsl:if>

			<xsl:if test="(string-length($SeznamDalsiSazby) &gt; 0)">		<!-- v souhrnu sazeb DPH je alespoň jedna nenulová sazba -->
				<xsl:for-each select="$SouhrnDPH">
					<!-- vzestupné řazení sazeb -->
					<xsl:sort select="(isdoc:TaxCategory/isdoc:Percent) | (isdocX:TaxCategory/isdocX:Percent)" order="ascending" data-type="number"/>
						<xsl:variable name="Sazba" select="(isdoc:TaxCategory/isdoc:Percent) | (isdocX:TaxCategory/isdocX:Percent)"/>
						<xsl:variable name="Zaklad" select="(isdoc:DifferenceTaxableAmount) | (isdocX:DifferenceTaxableAmount)"/>
						<xsl:variable name="DPH" select="(isdoc:DifferenceTaxAmount) | (isdocX:DifferenceTaxAmount)"/>
							<xsl:if test="$Sazba != 0">
								<xsl:element name="DalsiSazba">
									<xsl:element name="HladinaDPH">
										<xsl:choose>
											<xsl:when test="($Sazba &lt;= 15)">1</xsl:when>	<!-- do 15ti % včetně se jedná o sníženou hladinu -->
											<xsl:otherwise>2</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<xsl:element name="Sazba"><xsl:value-of select="$Sazba"/></xsl:element>
									<xsl:element name="Zaklad"><xsl:value-of select="($Zaklad)*($Znamenko)"/></xsl:element>
									<xsl:element name="DPH"><xsl:value-of select="($DPH)*($Znamenko)"/></xsl:element>
								</xsl:element>
							</xsl:if>
				</xsl:for-each>
			</xsl:if>

		</xsl:element>
	</xsl:element>


	<xsl:element name="Celkem">
		<xsl:choose>
			<xsl:when test="$Druh = 'N' ">	<!-- v případě normální faktury se odečte suma nedaňových odpočtů, která není v ISDOCU součástí výsledného plnění  -->
				<xsl:value-of select="format-number((($VyslednePlneniDM)+($ZaokrouhleniDM)-($OdpoctyN_DM))*($Znamenko),'0.##' )"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="format-number(($VyslednePlneniDM+$ZaokrouhleniDM)*($Znamenko),'0.##' )"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>

	<xsl:element name="Proplatit">
		<xsl:value-of select="$Proplatit"/>
	</xsl:element>

	<xsl:if test="$Druh = 'N' ">
		<xsl:element name="SumZaloha">
				<!-- u sumy odpočtů je znaménko opačné (normální faktury - záporně, dobropisy - kladně) -->
			<xsl:value-of select="format-number(($SumZaloha)*($Znamenko)*(-1),'0.##' )"/>
		</xsl:element>
	</xsl:if>

	<xsl:if test="$CiziMena">
		<xsl:element name="Valuty">
			<xsl:element name="Mena">
				<xsl:element name="Kod">
					<xsl:value-of select="$CiziMena"/>
				</xsl:element>
				<xsl:element name="Mnozstvi">
					<xsl:value-of select="isdoc:RefCurrRate | isdocX:RefCurrRate"/>
				</xsl:element>
				<xsl:element name="Kurs">
					<xsl:value-of select="isdoc:CurrRate | isdocX:CurrRate"/>
				</xsl:element>
			</xsl:element>

			<xsl:element name="SouhrnDPH">
				<xsl:element name="SeznamDalsiSazby">
					<xsl:if test="($SouhrnDPH/isdoc:TaxCategory/isdoc:Percent = 0) or ($SouhrnDPH/isdocX:TaxCategory/isdocX:Percent = 0)
								or ($Zaklad0_CM !=0) or ($ZaokrouhleniCM !=0 ) or (($OdpoctyN_CM !=0 ) and ($Druh = 'N' ))">
						<xsl:element name="DalsiSazba">
							<xsl:element name="HladinaDPH">0</xsl:element>
							<xsl:element name="Sazba">0</xsl:element>
							<xsl:element name="Zaklad">
								<xsl:choose>
									<xsl:when test="$Druh = 'N' ">
										<xsl:value-of select="format-number((($Zaklad0_CM)+($ZaokrouhleniCM)-($OdpoctyN_CM))*($Znamenko),'0.##' )"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="format-number(($Zaklad0_CM+$ZaokrouhleniCM)*($Znamenko),'0.##' )"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<xsl:element name="DPH">0</xsl:element>
						</xsl:element>
					</xsl:if>
	
					<xsl:if test="(string-length($SeznamDalsiSazby) &gt; 0)">
						<xsl:for-each select="$SouhrnDPH">
								<xsl:sort select="(isdoc:TaxCategory/isdoc:Percent) | (isdocX:TaxCategory/isdocX:Percent)" order="ascending" data-type="number"/>
								<xsl:variable name="Sazba" select="(isdoc:TaxCategory/isdoc:Percent) | (isdocX:TaxCategory/isdocX:Percent)"/>
								<xsl:variable name="Zaklad" select="(isdoc:DifferenceTaxableAmountCurr) | (isdocX:DifferenceTaxableAmountCurr)"/>
								<xsl:variable name="DPH" select="(isdoc:DifferenceTaxAmountCurr) | (isdocX:DifferenceTaxAmountCurr)"/>
									<xsl:if test="$Sazba != 0">
										<xsl:element name="DalsiSazba">
											<xsl:element name="HladinaDPH">
												<xsl:choose>
													<xsl:when test="($Sazba &lt;= 15)">1</xsl:when>
													<xsl:otherwise>2</xsl:otherwise>
												</xsl:choose>
											</xsl:element>
											<xsl:element name="Sazba"><xsl:value-of select="$Sazba"/></xsl:element>
											<xsl:element name="Zaklad"><xsl:value-of select="($Zaklad)*($Znamenko)"/></xsl:element>
											<xsl:element name="DPH"><xsl:value-of select="($DPH)*($Znamenko)"/></xsl:element>
										</xsl:element>
									</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:element>
			</xsl:element>


			<xsl:element name="Celkem">
				<xsl:choose>
					<xsl:when test="$Druh = 'N' ">
						<xsl:value-of select="format-number((($VyslednePlneniCM)+($ZaokrouhleniCM)-($OdpoctyN_CM))*($Znamenko),'0.##' )"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(($VyslednePlneniCM+$ZaokrouhleniCM)*($Znamenko),'0.##' )"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:element>

		<xsl:element name="ValutyProp">
			<xsl:value-of select="$ValutyProp"/>
		</xsl:element>

		<xsl:if test="$Druh = 'N' ">
			<xsl:element name="SumZalohaC">
				<xsl:value-of select="format-number(($SumZalohaC)*($Znamenko)*(-1),'0.##' )"/>
			</xsl:element>
		</xsl:if>

	</xsl:if>

	<!-- dodavatel - obchodní adresa, fakturační adresa -->
	<xsl:if test="$DodObchAdresa | $DodFaktAdresa">
		<xsl:element name="DodOdb">
			<xsl:call-template name="Dodavatel">
				<xsl:with-param name="PrvniUcet" select="$PrvniPrevod"/>
				<xsl:with-param name="ObchAdresa" select="$DodObchAdresa"/>
				<xsl:with-param name="FaktAdresa" select="$DodFaktAdresa"/>
				<xsl:with-param name="OznacDok" select="$OznacDok"/>
				<xsl:with-param name="Katalog" select="$KatalogN"/>
				<xsl:with-param name="UzivCode" select="$UzivCodeN"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:if>

	<!-- položky dokladu -->
	<xsl:if test="$Polozky">
		<xsl:choose>
			<xsl:when test="$Druh = 'L' ">	<!-- zálohová faktura -->
				<xsl:element name="SeznamZalPolozek">
					<xsl:apply-templates select="$Polozky">
						<xsl:with-param name="Druh" select="$Druh"/>
						<xsl:with-param name="CiziMena" select="$CiziMena"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
						<xsl:with-param name="KatalogN" select="$KatalogN"/>
						<xsl:with-param name="UzivCodeN" select="$UzivCodeN"/>
						<xsl:with-param name="BarCodeN" select="$BarCodeN"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>					<!-- ostatní faktury -->
				<xsl:element name="SeznamPolozek">
					<xsl:apply-templates select="$Polozky">
						<xsl:with-param name="Druh" select="$Druh"/>
						<xsl:with-param name="CiziMena" select="$CiziMena"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
						<xsl:with-param name="KatalogN" select="$KatalogN"/>
						<xsl:with-param name="UzivCodeN" select="$UzivCodeN"/>
						<xsl:with-param name="BarCodeN" select="$BarCodeN"/>
					</xsl:apply-templates>
					<xsl:if test="$Druh = 'N' ">							<!-- odpočty jen u normální faktury -->
						<xsl:apply-templates select="$Odpocty">
							<xsl:with-param name="Druh" select="$Druh"/>
							<xsl:with-param name="CiziMena" select="$CiziMena"/>
							<xsl:with-param name="Znamenko">			<!-- u odpočtů je znaménko opačné -->
								<xsl:choose>
									<xsl:when test="($Znamenko = 1)">-1</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
						<xsl:apply-templates select="$OdpoctyN">		<!-- nedaňové odpočty, budou vždy v nulové sazbě -->
							<xsl:with-param name="Druh" select="$Druh"/>
							<xsl:with-param name="CiziMena" select="$CiziMena"/>
							<xsl:with-param name="Znamenko">	
								<xsl:choose>
									<xsl:when test="($Znamenko = 1)">-1</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>

	<!-- odběratel (moje firma) - obchodní adresa, fakturační adresa, dodací adresa -->
	<xsl:if test="$OdbObchAdresa | $OdbDodAdresa | $OdbFaktAdresa">
		<xsl:element name="MojeFirma">
			<xsl:call-template name="Odberatel">
				<xsl:with-param name="ObchAdresa" select="$OdbObchAdresa"/>
				<xsl:with-param name="DodAdresa" select="$OdbDodAdresa"/>
				<xsl:with-param name="FaktAdresa" select="$OdbFaktAdresa"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:if>

	<!-- vazba daňového dokladu na zálohovou fakturu, vazby na vyřizované objednávky -->
	<xsl:if test="(($Druh = 'D') and ($OdpoctyN))
				or (($Druh = 'N') and (string-length($Objednavky/isdoc:ExternalOrderID | $Objednavky/isdocX:ExternalOrderID) &gt; 0))">

		<xsl:element name="SeznamVazeb">
			<xsl:for-each select="$OdpoctyN">
				<xsl:element name="Vazba">
					<xsl:element name="Typ">DD</xsl:element>
					<xsl:element name="PodTyp">ZF</xsl:element>
						<xsl:element name="Doklad">
							<xsl:element name="Druh">FP</xsl:element>
							<xsl:element name="VarSymbol"><xsl:value-of select="isdoc:VariableSymbol | isdocX:VariableSymbol"/></xsl:element>
							<xsl:element name="PrijatDokl"><xsl:value-of select="isdoc:ID | isdocX:ID "/></xsl:element>
						</xsl:element>
				</xsl:element>
			</xsl:for-each>

			<xsl:for-each select="$Objednavky">
				<xsl:variable name="Doklad" select="isdoc:ExternalOrderID | isdocX:ExternalOrderID"/>
				<xsl:if test="string-length($Doklad) &gt; 0">
					<xsl:element name="Vazba">
						<xsl:element name="Typ">PR</xsl:element>
							<xsl:element name="Doklad">
								<xsl:element name="Druh">OV</xsl:element>
								<xsl:element name="Cislo"><xsl:value-of select="$Doklad"/></xsl:element>
							</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:if>

	<!-- přílohy (připojené dokumenty) -->
	<xsl:call-template name="Dokumenty"/>

</xsl:template>

<!-- Pořadí první platby převodem v seznamu plateb, kde je uveden účet -->
<xsl:template name="PrvniPlatba">
<xsl:param name="Pocitadlo"/>
<xsl:param name="Pocet"/>

	<xsl:if test="$Pocitadlo &lt;= $Pocet">
		<xsl:choose>
			<xsl:when test="(string-length(isdoc:PaymentMeans/isdoc:Payment[$Pocitadlo]/isdoc:Details/isdoc:ID) &gt; 0)
							or (string-length(isdocX:PaymentMeans/isdocX:Payment[$Pocitadlo]/isdocX:Details/isdocX:ID) &gt; 0)
							or (string-length(isdoc:PaymentMeans/isdoc:Payment[$Pocitadlo]/isdoc:Details/isdoc:IBAN) &gt; 0)
							or (string-length(isdocX:PaymentMeans/isdocX:Payment[$Pocitadlo]/isdocX:Details/isdocX:IBAN) &gt; 0) ">
				<xsl:value-of select="$Pocitadlo"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PrvniPlatba">
					<xsl:with-param name="Pocitadlo" select="$Pocitadlo+1"/>
					<xsl:with-param name="Pocet" select="$Pocet"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- FAKTURA - KONEC -->


<!-- DODAVATEL -->
<xsl:template name="Dodavatel">
	<xsl:param name="PrvniUcet"/>
	<xsl:param name="ObchAdresa"/>
	<xsl:param name="FaktAdresa"/>
	<xsl:param name="ObchAdresaKontakt" select="($ObchAdresa/isdoc:Contact) | ($ObchAdresa/isdocX:Contact)"/>
	<xsl:param name="FaktAdresaKontakt" select="($FaktAdresa/isdoc:Contact) | ($FaktAdresa/isdocX:Contact)"/>
	<xsl:param name="OznacDok"/>
	<xsl:param name="Katalog"/>
	<xsl:param name="UzivCode"/>

	<xsl:choose>
		<xsl:when test="($ObchAdresa) and ($FaktAdresa)">
			<xsl:apply-templates select="$ObchAdresa">	<!-- obchodní adresa -->
				<xsl:with-param name="TypAdr" select="1"/>
				<xsl:with-param name="OznacDok" select="$OznacDok"/>
				<xsl:with-param name="Katalog" select="$Katalog"/>
				<xsl:with-param name="UzivCode" select="$UzivCode"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">	<!-- dodací adresa -->
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">		<!-- fakturační adresa -->
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:when test="($ObchAdresa) and not($FaktAdresa)">
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
				<xsl:with-param name="OznacDok" select="$OznacDok"/>
				<xsl:with-param name="Katalog" select="$Katalog"/>
				<xsl:with-param name="UzivCode" select="$UzivCode"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
				<xsl:with-param name="OznacDok" select="$OznacDok"/>
				<xsl:with-param name="Katalog" select="$Katalog"/>
				<xsl:with-param name="UzivCode" select="$UzivCode"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>

	<!-- Telefon -->
	<!-- pozice prvního kontaktu obsahující neprázdný telefon v obchodní adrese dodavatele -->
	<xsl:variable name="PoziceTel_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="1"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- pozice prvního kontaktu obsahující neprázdný telefon ve fakturační adrese dodavatele -->
	<xsl:variable name="PoziceTel_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="1"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:if test="($PoziceTel_1 &gt; 0) or ($PoziceTel_2 &gt; 0) ">
		<xsl:call-template name="Telefon">
			<xsl:with-param name="Telefon">
				<xsl:choose>
					<xsl:when test="($PoziceTel_1 &gt; 0)">
						<xsl:value-of select="translate($ObchAdresaKontakt[$PoziceTel_1]/isdoc:Telephone,' ','')"/>
						<xsl:value-of select="translate($ObchAdresaKontakt[$PoziceTel_1]/isdocX:Telephone,' ','')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="translate($FaktAdresaKontakt[$PoziceTel_2]/isdoc:Telephone,' ','')"/>
						<xsl:value-of select="translate($FaktAdresaKontakt[$PoziceTel_2]/isdocX:Telephone,' ','')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>

	<!-- Email -->
	<xsl:variable name="PoziceEmail_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="2"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceEmail_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="2"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:if test="($PoziceEmail_1 &gt; 0) or ($PoziceEmail_2 &gt; 0) ">
		<xsl:element name="EMail">
			<xsl:choose>
				<xsl:when test="($PoziceEmail_1 &gt; 0)">
					<xsl:value-of select="$ObchAdresaKontakt[$PoziceEmail_1]/isdoc:ElectronicMail"/>
					<xsl:value-of select="$ObchAdresaKontakt[$PoziceEmail_1]/isdocX:ElectronicMail"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$FaktAdresaKontakt[$PoziceEmail_2]/isdoc:ElectronicMail"/>
					<xsl:value-of select="$FaktAdresaKontakt[$PoziceEmail_2]/isdocX:ElectronicMail"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:if>

	<!-- Kontaktní osoby -->
	<!-- pozice prvního kontaktu obsahující neprázdné jméno -> bude se jednat o jednatele -->
	<xsl:variable name="PoziceOsoba_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="3"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceOsoba_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="3"/>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:for-each select="$ObchAdresaKontakt">
		<xsl:variable name="Jmeno" select="isdoc:Name | isdocX:Name"/>
		<xsl:variable name="Telefon" select="isdoc:Telephone | isdocX:Telephone"/>
		<xsl:variable name="Email" select="isdoc:ElectronicMail | isdocX:ElectronicMail"/>
		<xsl:if test="string-length($Jmeno) &gt; 0">
			<xsl:call-template name="KontaktOsoba">
				<xsl:with-param name="Jmeno" select="$Jmeno"/>
				<xsl:with-param name="Telefon" select="$Telefon"/>
				<xsl:with-param name="Email" select="$Email"/>
				<xsl:with-param name="JednatelPozice" select="$PoziceOsoba_1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<!-- u fakturační adresy se vypisují pouze kontaktní osoby, jejichž jméno se nevyskytuje v seznamu kontaktních osob obchodní adresy -->
	<xsl:for-each select="$FaktAdresaKontakt">
		<xsl:variable name="Jmeno" select="isdoc:Name | isdocX:Name"/>
		<xsl:variable name="Telefon" select="isdoc:Telephone | isdocX:Telephone"/>
		<xsl:variable name="Email" select="isdoc:ElectronicMail | isdocX:ElectronicMail"/>
		<xsl:variable name="Shoda">
			<xsl:for-each select="$ObchAdresaKontakt">
				<xsl:variable name="JmenoObch" select="isdoc:Name | isdocX.Name"/>
				<xsl:if test="(string-length($JmenoObch) &gt; 0) and ($JmenoObch=$Jmeno)">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- řetězec je neprázdný a není shodný s některou kontaktní osobou u obchodní adresy -->
		<xsl:if test="(string-length($Jmeno) &gt; 0) and not(string-length($Shoda) &gt; 0)">
			<xsl:call-template name="KontaktOsoba">
				<xsl:with-param name="Jmeno" select="$Jmeno"/>
				<xsl:with-param name="Telefon" select="$Telefon"/>
				<xsl:with-param name="Email" select="$Email"/>
				<xsl:with-param name="JednatelPozice">
					<xsl:if test="not(string-length($PoziceOsoba_1) &gt; 0)">
						<xsl:value-of select="$PoziceOsoba_2"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<xsl:variable name="BankSpojeniSz" select="isdoc:PaymentMeans/isdoc:AlternateBankAccounts | isdocX:PaymentMeans/isdocX:AlternateBankAccounts"/>
	<xsl:variable name="BankSpojeniUcet" select="isdoc:PaymentMeans/isdoc:AlternateBankAccounts/isdoc:AlternateBankAccount | isdocX:PaymentMeans/isdocX:AlternateBankAccounts/isdocX:AlternateBankAccount"/>
	<xsl:variable name="Platby" select="isdoc:PaymentMeans/isdoc:Payment | isdocX:PaymentMeans/isdocX:Payment"/>

	<!-- Bankovní spojení -->
	<xsl:if test="(string-length($PrvniUcet) &gt; 0) or ($BankSpojeniSz)">
		<xsl:choose>
			<!-- použije se první účet vyskytující se v seznamu plateb -->
			<xsl:when test="(string-length($PrvniUcet) &gt; 0)">
				<xsl:if test="(string-length($Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:Name) &gt; 0)
							or (string-length($Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:Name) &gt; 0)">
					<xsl:element name="Banka">
						<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:Name"/><xsl:value-of select="$Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:Name"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="Ucet">
					<xsl:choose>
						<xsl:when test="(string-length($Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:IBAN) &gt; 0)
										or (string-length($Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:IBAN) &gt; 0)">
						<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:IBAN"/><xsl:value-of select="$Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:IBAN"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:ID"/>
							<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="KodBanky">
					<xsl:choose>
						<xsl:when test="(string-length($Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:BIC) &gt; 0)
										or (string-length($Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:BIC) &gt; 0)">
							<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:BIC"/><xsl:value-of select="$Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:BIC"/>
						</xsl:when>
						<xsl:otherwise>
				<xsl:value-of select="$Platby[position()=$PrvniUcet]/isdoc:Details/isdoc:BankCode"/><xsl:value-of select="$Platby[position()=$PrvniUcet]/isdocX:Details/isdocX:BankCode"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>

			<!-- použije se první účet ze seznamu alternativních bankovních spojení -->
			<xsl:otherwise>
				<xsl:if test="(string-length($BankSpojeniUcet/isdoc:Name) &gt; 0)	or (string-length($BankSpojeniUcet/isdocX:Name) &gt; 0)">
					<xsl:element name="Banka">
						<xsl:value-of select="$BankSpojeniUcet/isdoc:Name"/><xsl:value-of select="$BankSpojeniUcet/isdocX:Name"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="Ucet">
					<xsl:choose>
						<xsl:when test="(string-length($BankSpojeniUcet/isdoc:IBAN) &gt; 0) or (string-length($BankSpojeniUcet/isdocX:IBAN) &gt; 0)">
							<xsl:value-of select="$BankSpojeniUcet/isdoc:IBAN"/><xsl:value-of select="$BankSpojeniUcet/isdocX:IBAN"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$BankSpojeniUcet/isdoc:ID"/><xsl:value-of select="$BankSpojeniUcet/isdocX:ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="KodBanky">
					<xsl:choose>
						<xsl:when test="(string-length($BankSpojeniUcet/isdoc:BIC) &gt; 0) or (string-length($BankSpojeniUcet/isdocX:BIC) &gt; 0)">
							<xsl:value-of select="$BankSpojeniUcet/isdoc:BIC"/><xsl:value-of select="$BankSpojeniUcet/isdocX:BIC"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$BankSpojeniUcet/isdoc:BankCode"/><xsl:value-of select="$BankSpojeniUcet/isdocX:BankCode"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>

	<!-- Seznam bankovních spojení se uvede pouze v případě, že na seznamu plateb existuje alespoň jedna platba převodem (na účet) nebo je neprázdný seznam alternativních bankovních spojení -->

	<xsl:if test="(string-length($PrvniUcet) &gt; 0) or ($BankSpojeniSz)">

		<xsl:element name="SeznamBankSpojeni">
			<xsl:for-each select="$Platby/isdoc:Details | $Platby/isdocX:Details">
				<xsl:variable name="ID" select="isdoc:ID | isdocX:ID"/>
				<xsl:variable name="IBAN" select="isdoc:IBAN | isdocX:IBAN"/>
				<xsl:variable name="BankCode" select="isdoc:BankCode | isdocX:BankCode"/>
				<xsl:variable name="BIC" select="isdoc:BIC | isdocX:BIC"/>

				<xsl:if test="(string-length($ID) &gt; 0) or (string-length($IBAN) &gt; 0)">
					<xsl:element name="BankSpojeni">
						<xsl:element name="Ucet">
							<xsl:choose>
								<xsl:when test="(string-length($IBAN) &gt; 0)">
									<xsl:value-of select="$IBAN"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$ID"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="KodBanky">
							<xsl:choose>
								<xsl:when test="(string-length($BIC) &gt; 0)">
									<xsl:value-of select="$BIC"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$BankCode"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
	
			<!-- bankovní spojení ze seznamu alternativních bankovních spojení se použije pouze v případě, pokud se neshoduje s některým bankovním spojením ze seznamu plateb -->
			<xsl:for-each select="$BankSpojeniUcet">
				<xsl:variable name="ID" select="isdoc:ID | isdocX:ID"/>
				<xsl:variable name="IBAN" select="isdoc:IBAN | isdocX:IBAN"/>
				<xsl:variable name="BankCode" select="isdoc:BankCode | isdocX:BankCode"/>
				<xsl:variable name="BIC" select="isdoc:BIC | isdocX:BIC"/>

				<xsl:variable name="Ucet">
					<xsl:choose>
						<xsl:when test="(string-length($IBAN) &gt; 0)">
							<xsl:value-of select="$IBAN"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$ID"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="Shoda">
					<xsl:for-each select="../../isdoc:Payment/isdoc:Details | ../../isdocX:Payment/isdocX:Details ">
						<xsl:if test="(string-length($Ucet) &gt; 0) and ((isdoc:ID = $Ucet) or (isdoc:IBAN = $Ucet)
																	or (isdocX:ID = $Ucet) or (isdocX:IBAN = $Ucet))">1</xsl:if>
					</xsl:for-each>
				</xsl:variable>
	
				<!-- účet se neshoduje s některým účtem ze seznamu plateb -->
				<xsl:if test="not(string-length($Shoda) &gt; 0)">
					<xsl:element name="BankSpojeni">
						<xsl:element name="Ucet">
							<xsl:choose>
								<xsl:when test="(string-length($IBAN) &gt; 0)">
									<xsl:value-of select="$IBAN"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$ID"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="KodBanky">
							<xsl:choose>
								<xsl:when test="(string-length($BIC) &gt; 0)">
									<xsl:value-of select="$BIC"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$BankCode"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>
		</xsl:element>
	</xsl:if>

</xsl:template>


<!-- pozice prvního kontaktu v adrese obsahující neprázdný telefon nebo email -->
<xsl:template name="KontaktPozice">
	<xsl:param name="Pozice"/>
	<xsl:param name="Pocet"/>
	<xsl:param name="Adresa"/>
	<xsl:param name="TypKontakt"/>

	<xsl:if test="$Pozice &lt;= $Pocet">
		<xsl:choose>
			<xsl:when test="(($TypKontakt = 1) and ((string-length($Adresa[$Pozice]/isdoc:Telephone) &gt; 0) or (string-length($Adresa[$Pozice]/isdocX:Telephone) &gt; 0)) )
							or (($TypKontakt= 2) and ((string-length($Adresa[$Pozice]/isdoc:ElectronicMail) &gt; 0) or (string-length($Adresa[$Pozice]/isdocX:ElectronicMail) &gt; 0)) )
							or (($TypKontakt= 3) and ((string-length($Adresa[$Pozice]/isdoc:Name) &gt; 0) or (string-length($Adresa[$Pozice]/isdocX:Name) &gt; 0)) ) ">
				<xsl:value-of select="$Pozice"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="KontaktPozice">
					<xsl:with-param name="Pozice" select="$Pozice+1"/>
					<xsl:with-param name="Pocet" select="$Pocet"/>
					<xsl:with-param name="Adresa" select="$Adresa"/>
					<xsl:with-param name="TypKontakt" select="$TypKontakt"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<!-- DODAVATEL - KONEC -->


<!-- ODBĚRATEL -->
<xsl:template name="Odberatel">
	<xsl:param name="ObchAdresa"/>
	<xsl:param name="DodAdresa"/>
	<xsl:param name="FaktAdresa"/>
	<xsl:param name="ObchAdresaKontakt" select="($ObchAdresa/isdoc:Contact) | ($ObchAdresa/isdocX:Contact)"/>
	<xsl:param name="DodAdresaKontakt" select="($DodAdresa/isdoc:Contact) | ($DodAdresa/isdocX:Contact)"/>
	<xsl:param name="FaktAdresaKontakt" select="($FaktAdresa/isdoc:Contact) | ($FaktAdresa/isdocX:Contact)"/>

	<xsl:choose>
		<xsl:when test="($ObchAdresa) and ($DodAdresa) and ($FaktAdresa) ">
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>

		<xsl:when test="($ObchAdresa) and ($DodAdresa) and not($FaktAdresa) ">
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">	<!-- fakturační adresa se nastaví podle obchodní adresy -->
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>
		
		<xsl:when test="($ObchAdresa) and not($DodAdresa) and ($FaktAdresa) ">
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">	<!-- dodací adresa se nastaví podle obchodní adresy -->
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>		

		<xsl:when test="not($ObchAdresa) and ($DodAdresa) and ($FaktAdresa) ">
			<xsl:apply-templates select="$FaktAdresa">	<!-- obchodní adresa se nastaví podle fakturační adresy -->
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>	

		<xsl:when test="not($ObchAdresa) and ($DodAdresa) and not($FaktAdresa)">
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$DodAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>

		<xsl:when test="not($ObchAdresa) and not($DodAdresa) and ($FaktAdresa)">
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$FaktAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:when>

		<xsl:otherwise>
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="1"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="2"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="$ObchAdresa">
				<xsl:with-param name="TypAdr" select="3"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>

	<!-- Telefon -->
	<!-- pozice prvního kontaktu obsahující neprázdný telefon v obchodní adrese odběratele -->
	<xsl:variable name="PoziceTel_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="1"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- pozice prvního kontaktu obsahující neprázdný telefon v dodací adrese odběratele -->
	<xsl:variable name="PoziceTel_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($DodAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$DodAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="1"/>
		</xsl:call-template>
	</xsl:variable>
	<!-- pozice prvního kontaktu obsahující neprázdný telefon ve fakturační adrese odběratele -->
	<xsl:variable name="PoziceTel_3">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="1"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:if test="($PoziceTel_1 &gt; 0) or ($PoziceTel_2 &gt; 0) or ($PoziceTel_3 &gt; 0)">
		<xsl:call-template name="Telefon">
			<xsl:with-param name="Telefon">
				<xsl:choose>
					<xsl:when test="($PoziceTel_1 &gt; 0)">
						<xsl:value-of select="translate($ObchAdresaKontakt[$PoziceTel_1]/isdoc:Telephone,' ','')"/>
						<xsl:value-of select="translate($ObchAdresaKontakt[$PoziceTel_1]/isdocX:Telephone,' ','')"/>
					</xsl:when>
					<xsl:when test="($PoziceTel_3 &gt; 0)">
						<xsl:value-of select="translate($FaktAdresaKontakt[$PoziceTel_3]/isdoc:Telephone,' ','')"/>
						<xsl:value-of select="translate($FaktAdresaKontakt[$PoziceTel_3]/isdocX:Telephone,' ','')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="translate($DodAdresaKontakt[$PoziceTel_2]/isdoc:Telephone,' ','')"/>
						<xsl:value-of select="translate($DodAdresaKontakt[$PoziceTel_2]/isdocX:Telephone,' ','')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>

	<!-- Email -->
	<xsl:variable name="PoziceEmail_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="2"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceEmail_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($DodAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$DodAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="2"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceEmail_3">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="2"/>
		</xsl:call-template>
	</xsl:variable>

	<xsl:if test="($PoziceEmail_1 &gt; 0) or ($PoziceEmail_2 &gt; 0) or ($PoziceEmail_3 &gt; 0) ">
		<xsl:element name="EMail">
			<xsl:choose>
				<xsl:when test="($PoziceEmail_1 &gt; 0)">
					<xsl:value-of select="$ObchAdresaKontakt[$PoziceEmail_1]/isdoc:ElectronicMail"/>
					<xsl:value-of select="$ObchAdresaKontakt[$PoziceEmail_1]/isdocX:ElectronicMail"/>
				</xsl:when>
				<xsl:when test="($PoziceEmail_3 &gt; 0)">
					<xsl:value-of select="$FaktAdresaKontakt[$PoziceEmail_3]/isdoc:ElectronicMail"/>
					<xsl:value-of select="$FaktAdresaKontakt[$PoziceEmail_3]/isdocX:ElectronicMail"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$DodAdresaKontakt[$PoziceEmail_2]/isdoc:ElectronicMail"/>
					<xsl:value-of select="$DodAdresaKontakt[$PoziceEmail_2]/isdocX:ElectronicMail"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:if>

	<!-- Kontaktní osoby -->
	<!-- pozice prvního kontaktu obsahující neprázdné jméno -> bude se jednat o jednatele -->
	<xsl:variable name="PoziceOsoba_1">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($ObchAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$ObchAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="3"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceOsoba_2">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($DodAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$DodAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="3"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="PoziceOsoba_3">
		<xsl:call-template name="KontaktPozice">
			<xsl:with-param name="Pozice" select="1"/>
			<xsl:with-param name="Pocet" select="count($FaktAdresaKontakt)"/>
			<xsl:with-param name="Adresa" select="$FaktAdresaKontakt"/>
			<xsl:with-param name="TypKontakt" select="3"/>
		</xsl:call-template>
	</xsl:variable>	


	<xsl:for-each select="$ObchAdresaKontakt">
		<xsl:variable name="Jmeno" select="isdoc:Name | isdocX:Name"/>
		<xsl:variable name="Telefon" select="isdoc:Telephone | isdocX:Telephone"/>
		<xsl:variable name="Email" select="isdoc:ElectronicMail | isdocX:ElectronicMail"/>
		<xsl:if test="string-length($Jmeno) &gt; 0">
			<xsl:call-template name="KontaktOsoba">
				<xsl:with-param name="Jmeno" select="$Jmeno"/>
				<xsl:with-param name="Telefon" select="$Telefon"/>
				<xsl:with-param name="Email" select="$Email"/>
				<xsl:with-param name="JednatelPozice" select="$PoziceOsoba_1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<!-- u fakturační adresy se vypisují pouze kontaktní osoby, jejichž jméno se nevyskytuje v seznamu kontaktních osob obchodní adresy -->
	<xsl:for-each select="$FaktAdresaKontakt">
		<xsl:variable name="Jmeno" select="isdoc:Name | isdocX:Name"/>
		<xsl:variable name="Telefon" select="isdoc:Telephone | isdocX:Telephone"/>
		<xsl:variable name="Email" select="isdoc:ElectronicMail | isdocX:ElectronicMail"/>
		<xsl:variable name="Shoda">
			<xsl:for-each select="$ObchAdresaKontakt">
				<xsl:variable name="JmenoObch" select="isdoc:Name | isdocX.Name"/>
				<xsl:if test="(string-length($JmenoObch) &gt; 0) and ($JmenoObch=$Jmeno)">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- řetězec je neprázdný a není shodný s některou kontaktní osobou u obchodní adresy -->
		<xsl:if test="(string-length($Jmeno) &gt; 0) and not(string-length($Shoda) &gt; 0)">
			<xsl:call-template name="KontaktOsoba">
				<xsl:with-param name="Jmeno" select="$Jmeno"/>
				<xsl:with-param name="Telefon" select="$Telefon"/>
				<xsl:with-param name="Email" select="$Email"/>
				<xsl:with-param name="JednatelPozice">
					<xsl:if test="not(string-length($PoziceOsoba_1) &gt; 0)">
						<xsl:value-of select="$PoziceOsoba_3"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

	<!-- u dodací adresy se vypisují pouze kontaktní osoby, jejichž jméno se nevyskytuje v seznamu kontaktních osob obchodní nebo fakturační adresy -->
	<xsl:for-each select="$DodAdresaKontakt">
		<xsl:variable name="Jmeno" select="isdoc:Name | isdocX:Name"/>
		<xsl:variable name="Telefon" select="isdoc:Telephone | isdocX:Telephone"/>
		<xsl:variable name="Email" select="isdoc:ElectronicMail | isdocX:ElectronicMail"/>
		<xsl:variable name="Shoda">
			<xsl:for-each select="$ObchAdresaKontakt">
				<xsl:variable name="JmenoObch" select="isdoc:Name | isdocX.Name"/>
				<xsl:if test="(string-length($JmenoObch) &gt; 0) and ($JmenoObch=$Jmeno)">1</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="$FaktAdresaKontakt">
				<xsl:variable name="JmenoObch" select="isdoc:Name | isdocX.Name"/>
				<xsl:if test="(string-length($JmenoObch) &gt; 0) and ($JmenoObch=$Jmeno)">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<!-- řetězec je neprázdný a není shodný s některou kontaktní osobou u obchodní nebo fakturační adresy -->
		<xsl:if test="(string-length($Jmeno) &gt; 0) and not(string-length($Shoda) &gt; 0)">
			<xsl:call-template name="KontaktOsoba">
				<xsl:with-param name="Jmeno" select="$Jmeno"/>
				<xsl:with-param name="Telefon" select="$Telefon"/>
				<xsl:with-param name="Email" select="$Email"/>
				<xsl:with-param name="JednatelPozice">
					<xsl:if test="not(string-length($PoziceOsoba_1) &gt; 0) and not(string-length($PoziceOsoba_3) &gt; 0) ">
						<xsl:value-of select="$PoziceOsoba_2"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

<!-- ODBĚRATEL - KONEC -->


<!-- FIRMA -->
<xsl:template match="isdoc:Party | isdocX:Party">
<xsl:param name="TypAdr"/>		<!-- 1 = obchodní adresa
										2 = dodací adresa
										3 = fakturační adresa -->
<xsl:param name="Nazev" select="(isdoc:PartyName/isdoc:Name) | (isdocX:PartyName/isdocX:Name)"/>
<xsl:param name="Adresa" select="(isdoc:PostalAddress) | (isdocX:PostalAddress)"/>
<xsl:param name="ID" select="(isdoc:PartyIdentification/isdoc:UserID) | (isdocX:PartyIdentification/isdocX:UserID)"/>
<xsl:param name="EAN" select="(isdoc:PartyIdentification/isdoc:CatalogFirmIdentification) | (isdocX:PartyIdentification/isdocX:CatalogFirmIdentification)"/>
<xsl:param name="IC" select="(isdoc:PartyIdentification/isdoc:ID) | (isdocX:PartyIdentification/isdocX:ID)"/>
<xsl:param name="DICSz" select="(isdoc:PartyTaxScheme) | (isdocX:PartyTaxScheme)"/>
<xsl:param name="SpisovaZnacka" select="(isdoc:RegisterIdentification) | (isdocX:RegisterIdentification)"/>
<xsl:param name="OznacDok"/>
<xsl:param name="Katalog"/>
<xsl:param name="UzivCode"/>

	<xsl:if test="($TypAdr = 1)">
		<xsl:element name="ObchNazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="ObchAdresa">
			<xsl:apply-templates select="$Adresa"/>
		</xsl:element>
	</xsl:if>

	<xsl:if test="($TypAdr = 2)">
		<xsl:element name="Nazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="Adresa">
			<xsl:apply-templates select="$Adresa"/>
		</xsl:element>
	</xsl:if>

	<xsl:if test="($TypAdr = 3)">
		<xsl:element name="FaktNazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="FaktAdresa">
			<xsl:apply-templates select="$Adresa"/>
		</xsl:element>
	</xsl:if>

	<xsl:if test="($TypAdr = 1)">		<!-- další údaje -->

		<!-- kód partnera (ID nebo EAN musí být vyplněn a současně musí být různý od nuly) -->
		<xsl:if test="((string-length($ID) &gt; 0) and ($ID !=0)) or ((string-length($EAN) &gt; 0) and ($EAN !=0)) ">
			<xsl:element name="KodPartn">
			<xsl:choose>
				<xsl:when test="(string-length($EAN) &gt; 0) and ($EAN !=0)">
					<xsl:value-of select="$EAN"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$ID"/>
				</xsl:otherwise>
			</xsl:choose>
			</xsl:element>
		</xsl:if>
	
		<!-- IČ -->
		<xsl:if test="(string-length($IC) &gt; 0) ">
			<xsl:element name="ICO">
					<xsl:value-of select="$IC"/>
			</xsl:element>
		</xsl:if>
	
		<!-- DIČ (IČ DPH), DIČ SK -->
		<xsl:for-each select="$DICSz">
			<xsl:variable name="CompanyID" select="isdoc:CompanyID | isdocX:CompanyID"/>
			<xsl:variable name="TaxScheme" select="isdoc:TaxScheme | isdocX:TaxScheme"/>
	
			<xsl:if test="(string-length($CompanyID) &gt; 0) and (($TaxScheme = 'VAT') or not($TaxScheme) or ($TaxScheme = '')) ">
				<xsl:element name="DIC">
					<xsl:value-of select="$CompanyID"/>
				</xsl:element>
				<xsl:element name="PlatceDPH">1</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($CompanyID) &gt; 0) and ($TaxScheme = 'TIN') ">
				<xsl:element name="DICSK"><xsl:value-of select="$CompanyID"/></xsl:element>
				<xsl:element name="DanIC"><xsl:value-of select="$CompanyID"/></xsl:element>
			</xsl:if>
		</xsl:for-each>
	
		<!-- spisová značka -->
		<xsl:if test="$SpisovaZnacka">
			<xsl:element name="SpisovaZnacka">
				<xsl:apply-templates select="$SpisovaZnacka"/>
			</xsl:element>
		</xsl:if>

		<xsl:if test="(string-length($Katalog) &gt; 0) or (string-length($UzivCode) &gt; 0) ">
			<xsl:element name="ISDOC">
				<!-- Označení dokumentu, kterým dal příjemce vystaviteli souhlas s elektronickou formou faktury.
					Nebudeme přenášet. Nejedná se o relevantní údaj pro příjemce faktury.
				<xsl:if test="(string-length($OznacDok) &gt; 0)">
					<xsl:attribute name="OznacDok">
						<xsl:value-of select="$OznacDok"/>
					</xsl:attribute>
				</xsl:if>	
				-->
				<xsl:attribute name="Katalog">
					<xsl:value-of select="$Katalog"/>
				</xsl:attribute>
				<xsl:attribute name="UzivCode">
					<xsl:value-of select="$UzivCode"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:if>

	</xsl:if>

</xsl:template>


<!-- Adresa firmy -->
<xsl:template match="isdoc:PostalAddress | isdocX:PostalAddress">
	<xsl:param name="Ulice" select="(isdoc:StreetName) | (isdocX:StreetName)"/>
	<xsl:param name="Cislo" select="(isdoc:BuildingNumber) | (isdocX:BuildingNumber)"/>
	<xsl:param name="Misto" select="(isdoc:CityName) | (isdocX:CityName)"/>
	<xsl:param name="PSC" select="(isdoc:PostalZone) | (isdocX:PostalZone)"/>
	<xsl:param name="Stat" select="(isdoc:Country/isdoc:Name) | (isdocX:Country/isdocX:Name)"/>
	<xsl:param name="KodStatu" select="(isdoc:Country/isdoc:IdentificationCode) | (isdocX:Country/isdocX:IdentificationCode)"/>

	<xsl:element name="Ulice">
		<xsl:choose>
			<xsl:when test="(string-length($Cislo) &gt; 0)">
				<xsl:value-of select="concat($Ulice,' ',$Cislo)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Ulice"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
	<xsl:element name="Misto">
		<xsl:value-of select="$Misto"/>
	</xsl:element>
	<xsl:element name="PSC">
		<xsl:value-of select="$PSC"/>
	</xsl:element>
	<xsl:element name="Stat">
		<xsl:value-of select="$Stat"/>
	</xsl:element>
	<xsl:element name="KodStatu">
		<xsl:value-of select="$KodStatu"/>
	</xsl:element>

</xsl:template>


<!-- Telefon -->
<xsl:template name="Telefon">
	<xsl:param name="Telefon"/>

		<xsl:variable name="Pred">
			<xsl:if test="contains($Telefon,'+')">
				<xsl:value-of select="substring($Telefon,1, 4)"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="Cislo">
			<xsl:choose>
				<xsl:when test="(contains($Telefon,'+')) and (contains($Telefon,'/'))">
					<xsl:value-of select="substring(substring-before($Telefon,'/' ),5)"/>
				</xsl:when>
				<xsl:when test="(contains($Telefon,'+'))">
					<xsl:value-of select="substring($Telefon,5)"/>
				</xsl:when>
				<xsl:when test="(contains($Telefon,'/'))">
					<xsl:value-of select="substring(substring-before($Telefon,'/' ),1)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Telefon"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Klap" select="substring-after($Telefon, '/')"/>

		<xsl:element name="Tel">
			<xsl:if test="(string-length($Pred) &gt; 0)">
				<xsl:element name="Pred">
						<xsl:value-of select="$Pred"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($Cislo) &gt; 0)">
				<xsl:element name="Cislo">
						<xsl:value-of select="$Cislo"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($Klap) &gt; 0)">
				<xsl:element name="Klap">
						<xsl:value-of select="$Klap"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
</xsl:template>


<!-- Spisová značka -->
<xsl:template match="isdoc:RegisterIdentification | isdocX:RegisterIdentification">
	<xsl:param name="Cislo" select="(isdoc:RegisterFileRef) | (isdocX:RegisterFileRef)"/>
	<xsl:param name="Spravce" select="(isdoc:RegisterKeptAt) | (isdocX:RegisterKeptAt)"/>
	<xsl:param name="Datum">
		<xsl:call-template name="_datum_">
			<xsl:with-param name="_datum"><xsl:value-of select="isdoc:RegisterDate"/><xsl:value-of select="isdocX:RegisterDate"/></xsl:with-param>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="Format" select="(isdoc:Preformatted) | (isdocX:Preformatted)"/>

	<xsl:choose>
		<xsl:when test="(string-length($Cislo) &gt; 0) and (string-length($Datum) &gt; 0) and (string-length($Spravce) &gt; 0)">
			<xsl:value-of select="concat($Cislo,', datum registrace: ',$Datum,', správce rejstříku: ',$Spravce)"/>
		</xsl:when>
		<xsl:when test="(string-length($Cislo) &gt; 0) and (string-length($Datum) &gt; 0)">
			<xsl:value-of select="concat($Cislo,', datum registrace: ',$Datum)"/>
		</xsl:when>
		<xsl:when test="(string-length($Cislo) &gt; 0) and (string-length($Spravce) &gt; 0)">
			<xsl:value-of select="concat($Cislo,', správce rejstříku: ',$Spravce)"/>
		</xsl:when>
		<xsl:when test="(string-length($Datum) &gt; 0) and (string-length($Spravce) &gt; 0)">
			<xsl:value-of select="concat('datum registrace: ',$Datum,', správce rejstříku: ',$Spravce)"/>
		</xsl:when>
		<xsl:when test="(string-length($Cislo) &gt; 0)">
			<xsl:value-of select="$Cislo"/>
		</xsl:when>
		<xsl:when test="(string-length($Datum) &gt; 0)">
			<xsl:value-of select="concat('datum registrace: ',$Datum)"/>
		</xsl:when>
		<xsl:when test="(string-length($Spravce) &gt; 0)">
			<xsl:value-of select="concat('správce rejstříku: ',$Spravce)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$Format"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- Kontaktní osoby -->
<xsl:template name="KontaktOsoba">
	<xsl:param name="Jmeno"/>
	<xsl:param name="Telefon"/>
	<xsl:param name="Email"/>
	<xsl:param name="JednatelPozice"/>
	
	<xsl:element name="Osoba">
		<xsl:apply-templates select="isdoc:Name | isdocX:Name">
			<xsl:with-param name="Osoba" select="normalize-space($Jmeno)"/>
		</xsl:apply-templates>

		<xsl:if test="(string-length($Telefon) &gt; 0)">
			<xsl:call-template name="Telefon">
				<xsl:with-param name="Telefon" select="translate($Telefon,' ','')"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="(string-length($Email) &gt; 0)">
			<xsl:element name="EMail">
				<xsl:value-of select="$Email"/>
			</xsl:element>
		</xsl:if>

		<xsl:if test="position() = $JednatelPozice ">
			<xsl:element name="Jednatel">1</xsl:element>
		</xsl:if>

	</xsl:element>
</xsl:template>


<!-- Kontaktní osoba -->
<xsl:template match="isdoc:Name | isdocX:Name">
	<xsl:param name="Osoba"/>

		<!-- vrací část řetězce před čárkou oddělující Titul za-->
		<xsl:variable name="PredTitulZa">
			<xsl:choose>
				<xsl:when test="contains($Osoba, ',')">
					<xsl:value-of select="normalize-space(substring-before($Osoba, ','))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Osoba"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="Prijmeni">
			<xsl:call-template name="Osoba">
				<xsl:with-param name="Retezec" select="$PredTitulZa"/>
				<xsl:with-param name="Oddelovac" select=" ' ' "/>
			</xsl:call-template>
		</xsl:variable>

		<!-- vrací část řetězce před příjmením -->
		<xsl:variable name="PredPrijmeni" select="normalize-space(substring($PredTitulZa,1,string-length($PredTitulZa)-string-length($Prijmeni)))"/>

		<xsl:variable name="Jmeno">
			<xsl:call-template name="Osoba">
				<!-- vrací část řetězce před příjmením -->
				<xsl:with-param name="Retezec" select="$PredPrijmeni"/>
				<xsl:with-param name="Oddelovac" select=" '.' "/>
			</xsl:call-template>
		</xsl:variable>

		<!-- vrací část řetězce před jménem -->
		<xsl:variable name="PredJmeno" select="normalize-space(substring($PredPrijmeni,1,string-length($PredPrijmeni)-string-length($Jmeno)))"/>

		<xsl:variable name="TitulPred" select="$PredJmeno"/>
		<xsl:variable name="TitulZa" select="normalize-space(substring-after($Osoba, ','))"/>


			<xsl:if test="(string-length($TitulPred) &gt; 0)">
				<xsl:element name="TitulPred">
						<xsl:value-of select="$TitulPred"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($TitulZa) &gt; 0)">
				<xsl:element name="TitulZa">
						<xsl:value-of select="$TitulZa"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($Jmeno) &gt; 0)">
				<xsl:element name="Jmeno">
						<xsl:value-of select="$Jmeno"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="(string-length($Prijmeni) &gt; 0)">
				<xsl:element name="Prijmeni">
						<xsl:value-of select="$Prijmeni"/>
				</xsl:element>
			</xsl:if>

</xsl:template>


<!-- Rozdělení titulu před, jména a příjmení -->
<xsl:template name="Osoba">
<xsl:param name="Retezec"/>
<xsl:param name="Oddelovac"/>
<xsl:param name="Delka" select="string-length($Retezec)"/>

<xsl:param name="Pozice">						<!-- pozice oddělovače, která odděluje jméno od příjmení resp. tituly před jménem -->
	<xsl:choose>
		<xsl:when test="(contains(normalize-space($Retezec),$Oddelovac))">		<!-- test, zda řetězec obsahuje oddělovač -->
			<xsl:call-template name="HledaniOddelovace">
				<xsl:with-param name="Retezec" select="substring-after($Retezec,$Oddelovac)"/>			<!-- vrací část řetězce za oddělovačem -->
				<xsl:with-param name="Oddelovac" select="$Oddelovac"/>							<!-- oddělovač -->
				<xsl:with-param name="Pozice" select="string-length(substring-before($Retezec,$Oddelovac))+1"/>	<!-- vrací pozici oddělovače v řetězci -->
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>			<!-- bez oddělovače -->
	</xsl:choose>
</xsl:param>

	<xsl:choose>			<!-- test, zda řetězec obsahuje oddělovač -->
		<xsl:when test="($Pozice &gt; 0)">
			<xsl:value-of select="normalize-space(substring($Retezec,$Pozice+1)) "/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="normalize-space($Retezec)"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!-- rozdělení titulu před, jména a příjmení - hledání posledního oddělovače -->
<xsl:template name="HledaniOddelovace">
<xsl:param name="Retezec"/>
<xsl:param name="Oddelovac"/>
<xsl:param name="Pozice"/>

	<xsl:choose>
		<xsl:when test="contains($Retezec,$Oddelovac)">		<!-- test, zda dílčí řetězec obsahuje oddělovač -->
			<xsl:call-template name="HledaniOddelovace">
				<xsl:with-param name="Retezec" select="substring-after($Retezec,$Oddelovac)"/>	<!-- vrací část řetězce za oddělovačem -->
				<xsl:with-param name="Oddelovac" select="$Oddelovac"/>					<!-- oddělovač -->
				<xsl:with-param name="Pozice" select="$Pozice+string-length(substring-before($Retezec,$Oddelovac))+1"/><!-- vrací pozici oddělovače v řetězci -->
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$Pozice"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<!-- FIRMA - KONEC-->



<!-- POLOŽKA -->
<xsl:template match="isdoc:InvoiceLine | isdocX:InvoiceLine">
<xsl:param name="Druh"/>
<xsl:param name="CiziMena"/>
<xsl:param name="Znamenko"/>						<!-- u dobropisů se v Money S3 uvádí částky záporně. Bude nutné obracet znaménko. -->
<xsl:param name="KatalogN"/>
<xsl:param name="UzivCodeN"/>
<xsl:param name="BarCodeN"/>

<xsl:param name="Popis" select="isdoc:Item/isdoc:Description | isdocX:Item/isdocX:Description"/>
<xsl:param name="Poznamka" select="isdoc:Note | isdocX:Note"/>
<xsl:param name="PocetMJ" select="isdoc:InvoicedQuantity | isdocX:InvoicedQuantity"/>
<xsl:param name="MJ" select="normalize-space($PocetMJ/@unitCode)"/>

<xsl:param name="Znamenko_PocetMJ">			<!-- pokud je množství záporné, tak se jedná o vratku. V Money musí být množství vždy kladné. -->
	<xsl:choose>
		<xsl:when test="($PocetMJ &lt; 0)">-1</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="Znamenko_CenaMJ">			<!-- v případě jednotkové ceny se v ISDOCU očekává vždy kladná hodnota, bude nutné obracet u dobropisů a vratek normálních faktur -->
	<xsl:choose>
		<!--	pokud je to vratka a současně to není dobropis NEBO to není vratka a současně je to dobropis, tak vynásobí jednotkovou cenu -1 -->
		<xsl:when test="(($Znamenko_PocetMJ = -1) and ($Znamenko = 1))
						or (($Znamenko_PocetMJ = 1) and ($Znamenko = -1))">-1</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="SazbaDPH" select="isdoc:ClassifiedTaxCategory/isdoc:Percent | isdocX:ClassifiedTaxCategory/isdocX:Percent"/>
<xsl:param name="MetodaDPH" select="isdoc:ClassifiedTaxCategory/isdoc:VATCalculationMethod | isdocX:ClassifiedTaxCategory/isdocX:VATCalculationMethod"/>
<xsl:param name="PredmPln" select="isdoc:ClassifiedTaxCategory/isdoc:LocalReverseCharge/isdoc:LocalReverseChargeCode
										 | isdocX:ClassifiedTaxCategory/isdocX:LocalReverseCharge/isdocX:LocalReverseChargeCode"/>

<xsl:param name="CenaMJ_bezDPH" select="isdoc:UnitPrice | isdocX:UnitPrice"/>
<xsl:param name="CenaMJ_vcetneDPH" select="isdoc:UnitPriceTaxInclusive | isdocX:UnitPriceTaxInclusive"/>

<xsl:param name="CelkemDM_zaklad" select="isdoc:LineExtensionAmount | isdocX:LineExtensionAmount"/>
<xsl:param name="CelkemDM_DPH" select="isdoc:LineExtensionTaxAmount | isdocX:LineExtensionTaxAmount"/>
<xsl:param name="CelkemDM_vcetneDPH" select="isdoc:LineExtensionAmountTaxInclusive | isdocX:LineExtensionAmountTaxInclusive"/>

<xsl:param name="CelkemCM_zaklad" select="isdoc:LineExtensionAmountCurr | isdocX:LineExtensionAmountCurr"/>
<xsl:param name="CelkemCM_vcetneDPH" select="isdoc:LineExtensionAmountTaxInclusiveCurr | isdocX:LineExtensionAmountTaxInclusiveCurr"/>

<xsl:param name="CenaTyp">
	<xsl:choose>		
		<!-- doklad v cizí měně -->
		<xsl:when test="($CiziMena)">
			<xsl:choose>		
				<!--	 jen DPH -> sazba DPH různá od nuly, celkem DPH v DM je různé od nuly, celkem základ v DM je roven nule, celkem DPH v DM se rovná celkem včetně DPH v DM, cena MJ základ je rovna nule, cena MJ včetně DPH je různá od nuly, celkem základ v CM je roven nule, celkem včetně DPH v CM je různé od nuly -->
				<xsl:when test="($SazbaDPH != 0) 
								and ($CelkemDM_DPH != 0) and ($CelkemDM_zaklad = 0) and ($CelkemDM_DPH = $CelkemDM_vcetneDPH)
								and ($CenaMJ_bezDPH = 0) and ($CenaMJ_vcetneDPH != 0) 
								and ($CelkemCM_zaklad = 0) and ($CelkemCM_vcetneDPH != 0)">2</xsl:when>
				<!-- jen základ -->
				<xsl:when test="($SazbaDPH != 0)
								and ($CelkemDM_zaklad != 0) and ($CelkemDM_DPH = 0) and ($CelkemDM_zaklad = $CelkemDM_vcetneDPH)
								and  ($CenaMJ_bezDPH = $CenaMJ_vcetneDPH) 
								and ($CelkemCM_zaklad != 0) and ($CelkemCM_zaklad = $CelkemCM_vcetneDPH)">3</xsl:when>
				<xsl:otherwise><xsl:value-of select="$MetodaDPH"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- doklad v domácí měně -->
		<xsl:otherwise>
			<xsl:choose>		
				<xsl:when test="($SazbaDPH != 0) 
								and ($CelkemDM_DPH != 0) and ($CelkemDM_zaklad = 0) and ($CelkemDM_DPH = $CelkemDM_vcetneDPH)
								and ($CenaMJ_bezDPH = 0) and ($CenaMJ_vcetneDPH != 0)">2</xsl:when>
				<xsl:when test="($SazbaDPH != 0)
								and ($CelkemDM_zaklad != 0) and ($CelkemDM_DPH = 0) and ($CelkemDM_zaklad = $CelkemDM_vcetneDPH)
								and  ($CenaMJ_bezDPH = $CenaMJ_vcetneDPH)">3</xsl:when>
				<xsl:otherwise><xsl:value-of select="$MetodaDPH"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="Cena">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:choose>
				<!-- jen DPH -->
				<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="($CelkemDM_DPH)*($Znamenko)"/></xsl:when>
				<!-- jen základ -->
				<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="($CelkemDM_zaklad)*($Znamenko)"/></xsl:when>
				<!-- bez DPH -->
				<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="($CelkemDM_zaklad)*($Znamenko)"/></xsl:when>
				<!-- s DPH -->
				<xsl:otherwise><xsl:value-of select="($CelkemDM_vcetneDPH)*($Znamenko)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:choose>
				<!-- jen DPH -->
				<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="($CenaMJ_vcetneDPH)*($Znamenko_CenaMJ)"/></xsl:when>
				<!-- jen základ -->
				<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="($CenaMJ_bezDPH)*($Znamenko_CenaMJ)"/></xsl:when>
				<!-- bez DPH -->
				<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="($CenaMJ_bezDPH)*($Znamenko_CenaMJ)"/></xsl:when>
				<!-- s DPH -->
				<xsl:otherwise><xsl:value-of select="($CenaMJ_vcetneDPH)*($Znamenko_CenaMJ)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladDM_MJ">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:value-of select="format-number(($CelkemDM_zaklad)*($Znamenko),'0.####' )"/>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:value-of select="format-number(($CenaMJ_bezDPH)*($Znamenko_CenaMJ),'0.####' )"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="DPHDM_MJ">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:value-of select="format-number(($CelkemDM_DPH)*($Znamenko),'0.####' )"/>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:value-of select="format-number((($CenaMJ_vcetneDPH)-($CenaMJ_bezDPH))*($Znamenko_CenaMJ),'0.####' )"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladDM">
	<xsl:value-of select="format-number(($CelkemDM_zaklad)*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="DPHDM">
	<xsl:value-of select="format-number(($CelkemDM_DPH)*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="Valuty">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:choose>
				<!-- jen DPH -->
				<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="($CelkemCM_vcetneDPH)*($Znamenko)"/></xsl:when>
				<!-- jen základ -->
				<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="($CelkemCM_zaklad)*($Znamenko)"/></xsl:when>
				<!-- bez DPH -->
				<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="($CelkemCM_zaklad)*($Znamenko)"/></xsl:when>
				<!-- s DPH -->
				<xsl:otherwise><xsl:value-of select="($CelkemCM_vcetneDPH)*($Znamenko)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:choose>
				<!-- jen DPH -->
				<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="format-number((($CelkemCM_vcetneDPH)div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/></xsl:when>
				<!-- jen základ -->
				<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="format-number((($CelkemCM_zaklad)div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/></xsl:when>
				<!-- bez DPH -->
				<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="format-number((($CelkemCM_zaklad)div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/></xsl:when>
				<!-- s DPH -->
				<xsl:otherwise><xsl:value-of select="format-number((($CelkemCM_vcetneDPH)div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladCM_MJ">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:value-of select="format-number(($CelkemCM_zaklad)*($Znamenko),'0.####' )"/>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:value-of select="format-number((($CelkemCM_zaklad)div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="DPHCM_MJ">
	<xsl:choose>
		<!-- počet MJ je nulový nebo prázdný -->
		<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">
			<xsl:value-of select="format-number((($CelkemCM_vcetneDPH)-($CelkemCM_zaklad))*($Znamenko),'0.####' )"/>
		</xsl:when>
		<!-- jinak -->
		<xsl:otherwise>
			<xsl:value-of select="format-number(((($CelkemCM_vcetneDPH)-($CelkemCM_zaklad))div($PocetMJ))*($Znamenko_CenaMJ),'0.####' )"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladCM">
	<xsl:value-of select="format-number(($CelkemCM_zaklad)*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="DPHCM">
	<xsl:value-of select="format-number((($CelkemCM_vcetneDPH)-($CelkemCM_zaklad))*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="BarCode">
	<xsl:call-template name="IdZbozi">
		<xsl:with-param name="Hodnota" select="$BarCodeN"/>
	</xsl:call-template>
</xsl:param>

<xsl:param name="Katalog">
	<xsl:call-template name="IdZbozi">
		<xsl:with-param name="Hodnota" select="$KatalogN"/>
	</xsl:call-template>
</xsl:param>

<xsl:param name="UzivCode">
	<xsl:call-template name="IdZbozi">
		<xsl:with-param name="Hodnota" select="$UzivCodeN"/>
	</xsl:call-template>
</xsl:param>

<xsl:param name="SeznamVC" select="isdoc:Item/isdoc:StoreBatches/isdoc:StoreBatch | isdocX:Item/isdocX:StoreBatches/isdocX:StoreBatch"/>

	<!-- první nalezené výrobní číslo v seznamu výrobních čísel (šarže ignoruje) - vrací název výrobního čísla -->
<xsl:param name="VyrobniCis" select="$SeznamVC[isdoc:BatchOrSerialNumber='S']/isdoc:Name | 
$SeznamVC[isdocX:BatchOrSerialNumber='S']/isdocX:Name"/>

	<!-- první nalezené výrobní číslo v seznamu výrobních čísel (šarže ignoruje) - vrací datum exspirace -->
<xsl:param name="DatExp" select="$SeznamVC[isdoc:BatchOrSerialNumber='S']/isdoc:ExpirationDate | 
$SeznamVC[isdocX:BatchOrSerialNumber='S']/isdocX:ExpirationDate"/>

	<!-- počet výrobních čísel (šarže ignoruje) -->
<xsl:param name="PocetVyrobniCis" select="count($SeznamVC[isdoc:BatchOrSerialNumber='S'])+count($SeznamVC[isdocX:BatchOrSerialNumber='S'])"/>

	<!-- počet výrobních čísel (šarže ignoruje) je roven počtu MJ-->
<xsl:param name="Shoda_VC_PocetMJ">
	<xsl:choose>
		<xsl:when test="($PocetVyrobniCis = ($PocetMJ)*($Znamenko_PocetMJ))">1</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
	</xsl:choose>
</xsl:param>

	<!-- test, zda všechna výrobní čísla a šarže mají shodné a neprázdné datum exspirace -->
<xsl:param name="Shoda_DatExp">
	<xsl:for-each select="$SeznamVC">
		<xsl:variable name="DatExpAkt" select="isdoc:ExpirationDate | isdocX:ExpirationDate"/>
		<xsl:if test="not($DatExpAkt) or (($DatExpAkt) and ($DatExpAkt != $DatExp))">1</xsl:if>
	</xsl:for-each>
</xsl:param>

		<!-- transformovaný popis na malá písmena -->
<xsl:param name="mpismena">abcdefghijklmnopqrstuvwxyzáčďéěíľňóřšťúůýž</xsl:param>
<xsl:param name="vpismena">ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍĽŇÓŘŠŤÚŮÝŽ</xsl:param>
<xsl:param name="PopisT">
	<xsl:value-of select="translate($Popis, $vpismena, $mpismena)"/>
</xsl:param>


	<!-- Tvorba položky (položka se bude generovat jen v případě, pokud jednotková cena nebo množství bude nenulové a současně se nebude jednat o zaokrouhlovací položku) -->
	<xsl:if test="(($Cena != 0) or ($PocetMJ != 0)) and not(contains($PopisT, 'zaokrouhl' ))">

		<xsl:element name="Polozka">

			<xsl:if test="(string-length($Popis) &gt; 0)">
				<xsl:element name="Popis">
					<xsl:value-of select="$Popis"/>
				</xsl:element>
			</xsl:if>

			<!-- Počet MJ musí být vždy kladný a větší než nula -->
			<xsl:element name="PocetMJ">
				<xsl:choose>
					<xsl:when test="($PocetMJ = 0) or ($PocetMJ = '') ">1</xsl:when>
					<xsl:otherwise><xsl:value-of select="($PocetMJ)*($Znamenko_PocetMJ)"/></xsl:otherwise>
				</xsl:choose>
			</xsl:element>
	
			<xsl:choose>
				<xsl:when test="($Druh = 'L' )">
					<xsl:element name="TypCeny"><xsl:value-of select="$CenaTyp"/></xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="CenaTyp"><xsl:value-of select="$CenaTyp"/></xsl:element>
				</xsl:otherwise>
			</xsl:choose>
	
			<xsl:element name="SazbaDPH"><xsl:value-of select="$SazbaDPH"/></xsl:element>
			<xsl:element name="Cena"><xsl:value-of select="$Cena"/></xsl:element>
			<xsl:if test="($CiziMena)">
				<xsl:element name="Valuty"><xsl:value-of select="$Valuty"/></xsl:element>
			</xsl:if>

			<xsl:element name="SouhrnDPH">
				<xsl:element name="Zaklad_MJ"><xsl:value-of select="$ZakladDM_MJ"/></xsl:element>
				<xsl:element name="DPH_MJ"><xsl:value-of select="$DPHDM_MJ"/></xsl:element>
				<xsl:element name="Zaklad"><xsl:value-of select="$ZakladDM"/></xsl:element>
				<xsl:element name="DPH"><xsl:value-of select="$DPHDM"/></xsl:element>
					<xsl:if test="($CiziMena)">
						<xsl:element name="Valuty">
							<xsl:element name="Zaklad_MJ"><xsl:value-of select="$ZakladCM_MJ"/></xsl:element>
							<xsl:element name="DPH_MJ"><xsl:value-of select="$DPHCM_MJ"/></xsl:element>
							<xsl:element name="Zaklad"><xsl:value-of select="$ZakladCM"/></xsl:element>
							<xsl:element name="DPH"><xsl:value-of select="$DPHCM"/></xsl:element>
						</xsl:element>
					</xsl:if>
			</xsl:element>

			<xsl:if test="(string-length($Poznamka) &gt; 0)">
				<xsl:element name="Poznamka">
					<xsl:value-of select="$Poznamka"/>
				</xsl:element>
			</xsl:if>
	
			<!-- Sleva bude vždy nulová a Importovaná cena bude vždy po slevě -->
			<xsl:element name="Sleva">0</xsl:element>
			<xsl:element name="CenaPoSleve">1</xsl:element>
	
			<xsl:choose>
				<!-- skladová položka (musí být uveden EAN nebo katalog nebo PLU a nesmí se jednat o daňový doklad k přijaté platbě) -->
				<xsl:when test="((string-length($BarCode) &gt; 0) or (string-length($Katalog) &gt; 0) or (string-length($UzivCode) &gt; 0)) and ($Druh != 'D' )">
					<xsl:choose>
						<xsl:when test="($Druh = 'L' )">	<!-- položka zálohové faktury -->
							<xsl:call-template name="KmKarta">
								<xsl:with-param name="Popis" select="$Popis"/>
								<xsl:with-param name="Katalog" select="$Katalog"/>
								<xsl:with-param name="BarCode" select="$BarCode"/>
								<xsl:with-param name="UzivCode" select="$UzivCode"/>
								<xsl:with-param name="MJ" select="$MJ"/>
								<xsl:with-param name="Shoda_VC_PocetMJ" select="$Shoda_VC_PocetMJ"/>
								<xsl:with-param name="SazbaDPH" select="$SazbaDPH"/>
								<xsl:with-param name="PredmPln" select="$PredmPln"/>
							</xsl:call-template>
							<!-- seznam výrobních čísel (počet výrobních čísel musí být roven počtu MJ) -->
								<xsl:if test="($Shoda_VC_PocetMJ = 1)">
								<xsl:element name="SeznamVC">
									<xsl:apply-templates select="$SeznamVC"/>
								</xsl:element>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="SklPolozka">	<!-- položka normální faktury -->
								<xsl:if test="($PocetMJ &lt; 0)">		<!-- jedná se o vratku -->
									<xsl:element name="Vratka">1</xsl:element>
								</xsl:if>
								<xsl:call-template name="KmKarta">
									<xsl:with-param name="Popis" select="$Popis"/>
									<xsl:with-param name="Katalog" select="$Katalog"/>
									<xsl:with-param name="BarCode" select="$BarCode"/>
									<xsl:with-param name="UzivCode" select="$UzivCode"/>
									<xsl:with-param name="MJ" select="$MJ"/>
									<xsl:with-param name="Shoda_VC_PocetMJ" select="$Shoda_VC_PocetMJ"/>
									<xsl:with-param name="SazbaDPH" select="$SazbaDPH"/>
									<xsl:with-param name="PredmPln" select="$PredmPln"/>
								</xsl:call-template>
								<xsl:if test="($Shoda_VC_PocetMJ = 1)">
									<xsl:element name="SeznamVC">
										<xsl:apply-templates select="$SeznamVC"/>
									</xsl:element>
								</xsl:if>
								<!-- pokud se jedná o položku normální faktury nebo o vratku dobropisu
									a současně popis položky je neprázdný nebo všechna výrobní čísla a šarže mají shodné a neprázdné datum exspirace,
									tak se uvede informace o dodávce -->
								<xsl:if test="((($PocetMJ &gt;= 0) and ($Znamenko = 1)) or (($PocetMJ &lt; 0) and ($Znamenko = -1)))
											and ((string-length($Popis) &gt; 0) or ((string-length($Shoda_DatExp) = 0) and (string-length($DatExp) &gt; 0)))">
									<xsl:element name="SeznamDodavek">
										<xsl:element name="Dodavka">
											<xsl:if test="(string-length($Popis) &gt; 0)">
												<xsl:element name="Oznaceni"><xsl:value-of select="$Popis"/></xsl:element>
											</xsl:if>
											<xsl:if test="(string-length($Shoda_DatExp) = 0) and (string-length($DatExp) &gt; 0)">
												<xsl:element name="DatExp"><xsl:value-of select="$DatExp"/></xsl:element>
											</xsl:if>
										</xsl:element>
									</xsl:element>
								</xsl:if>

							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- neskladová položka -->
				<xsl:otherwise>
						<xsl:element name="NesklPolozka">
							<xsl:element name="Katalog">				<!-- v případě neskladové položky musí být uveden alespoň jeden podřízený element -->
								<xsl:value-of select="$Katalog"/>
							</xsl:element>
							<xsl:if test="(string-length($BarCode) &gt; 0)">
								<xsl:element name="BarCode">
									<xsl:value-of select="$BarCode"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="(string-length($UzivCode) &gt; 0)">
								<xsl:element name="UzivCode">
									<xsl:value-of select="$UzivCode"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="(string-length($MJ) &gt; 0)">
								<xsl:element name="MJ">
									<xsl:value-of select="$MJ"/>
								</xsl:element>
							</xsl:if>
							<xsl:if test="(string-length($PredmPln) &gt; 0)">
								<xsl:element name="PredmPln">
									<xsl:value-of select="$PredmPln"/>
								</xsl:element>
							</xsl:if>
							<!-- elementy VyrobniCis a DatExp se použijí pouze v případě, že v seznamu výrobních čísel bude pouze jedno výrobní číslo -->
							<xsl:if test="($PocetVyrobniCis = 1)">
								<xsl:element name="VyrobniCis">	<xsl:value-of select="$VyrobniCis"/></xsl:element>
								<xsl:element name="DatExp"><xsl:value-of select="$DatExp"/></xsl:element>
							</xsl:if>
						</xsl:element>	
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:if>

</xsl:template>


<!-- Plnění čárového kódu, katalogu a PLU. Plní se dle nastavení a jen v případě, že je identifikátor zboží neprázdný a současně nenulový -->
<xsl:template name="IdZbozi">
<xsl:param name="Hodnota"/>
<!-- 
Identifikátor zboží dle prodejce 					1
Sekundární identifikátor zboží dle prodejce		2
Terciální identifikátor zboží dle prodejce			3
Identifikátor zboží dle kupujícího 					9
Čárový kód 										10
-->

	<xsl:choose>
		<xsl:when test="($Hodnota = 1) and 
				(((string-length(isdoc:Item/isdoc:SellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:Item/isdoc:SellersItemIdentification/isdoc:ID !=0))
				or ((string-length(isdocX:Item/isdocX:SellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:Item/isdocX:SellersItemIdentification/isdocX:ID !=0)))">
		<xsl:value-of select="isdoc:Item/isdoc:SellersItemIdentification/isdoc:ID"/><xsl:value-of select="isdocX:Item/isdocX:SellersItemIdentification/isdocX:ID"/>
		</xsl:when>

		<xsl:when test="($Hodnota = 2) and 
				(((string-length(isdoc:Item/isdoc:SecondarySellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:Item/isdoc:SecondarySellersItemIdentification/isdoc:ID !=0))
				or ((string-length(isdocX:Item/isdocX:SecondarySellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:Item/isdocX:SecondarySellersItemIdentification/isdocX:ID !=0)))">
		<xsl:value-of select="isdoc:Item/isdoc:SecondarySellersItemIdentification/isdoc:ID"/><xsl:value-of select="isdocX:Item/isdocX:SecondarySellersItemIdentification/isdocX:ID"/>
		</xsl:when>

		<xsl:when test="($Hodnota = 3) and 
				(((string-length(isdoc:Item/isdoc:TertiarySellersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:Item/isdoc:TertiarySellersItemIdentification/isdoc:ID !=0))
				or ((string-length(isdocX:Item/isdocX:TertiarySellersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:Item/isdocX:TertiarySellersItemIdentification/isdocX:ID !=0)))">
		<xsl:value-of select="isdoc:Item/isdoc:TertiarySellersItemIdentification/isdoc:ID"/><xsl:value-of select="isdocX:Item/isdocX:TertiarySellersItemIdentification/isdocX:ID"/>
		</xsl:when>

		<xsl:when test="($Hodnota = 9) and 
				(((string-length(isdoc:Item/isdoc:BuyersItemIdentification/isdoc:ID) &gt; 0) and (isdoc:Item/isdoc:BuyersItemIdentification/isdoc:ID !=0))
				or ((string-length(isdocX:Item/isdocX:BuyersItemIdentification/isdocX:ID) &gt; 0) and (isdocX:Item/isdocX:BuyersItemIdentification/isdocX:ID !=0)))">
		<xsl:value-of select="isdoc:Item/isdoc:BuyersItemIdentification/isdoc:ID"/><xsl:value-of select="isdocX:Item/isdocX:BuyersItemIdentification/isdocX:ID"/>
		</xsl:when>

		<xsl:when test="($Hodnota = 10) and 
				(((string-length(isdoc:Item/isdoc:CatalogueItemIdentification/isdoc:ID) &gt; 0) and (isdoc:Item/isdoc:CatalogueItemIdentification/isdoc:ID !=0))
				or ((string-length(isdocX:Item/isdocX:CatalogueItemIdentification/isdocX:ID) &gt; 0) and (isdocX:Item/isdocX:CatalogueItemIdentification/isdocX:ID !=0)))">
		<xsl:value-of select="isdoc:Item/isdoc:CatalogueItemIdentification/isdoc:ID"/><xsl:value-of select="isdocX:Item/isdocX:CatalogueItemIdentification/isdocX:ID"/>
		</xsl:when>
	</xsl:choose>

</xsl:template>


<!-- Kmenová karta -->
<xsl:template name="KmKarta">
<xsl:param name="Popis"/>
<xsl:param name="Katalog"/>
<xsl:param name="BarCode"/>
<xsl:param name="UzivCode"/>
<xsl:param name="MJ"/>
<xsl:param name="Shoda_VC_PocetMJ"/>
<xsl:param name="SazbaDPH"/>
<xsl:param name="PredmPln"/>

	<xsl:element name="KmKarta">
		<xsl:if test="(string-length($Popis) &gt; 0)">
			<xsl:element name="Popis">
				<xsl:value-of select="$Popis"/>
			</xsl:element>
			<xsl:element name="Zkrat">
				<xsl:value-of select="$Popis"/>
			</xsl:element>
		</xsl:if>

		<xsl:element name="TypKarty">jednoducha</xsl:element>

		<xsl:if test="(string-length($Katalog) &gt; 0)">
			<xsl:element name="Katalog">
				<xsl:value-of select="$Katalog"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($BarCode) &gt; 0) ">
			<xsl:element name="BarCode">
				<xsl:value-of select="$BarCode"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($UzivCode) &gt; 0) ">
			<xsl:element name="UzivCode">
				<xsl:value-of select="$UzivCode"/>
			</xsl:element>
		</xsl:if>

		<xsl:if test="(string-length($MJ) &gt; 0)">
			<xsl:element name="MJ">
				<xsl:value-of select="$MJ"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="(string-length($PredmPln) &gt; 0)">
			<xsl:element name="PredmPln">
				<xsl:value-of select="$PredmPln"/>
			</xsl:element>
		</xsl:if>
		<xsl:element name="EvVyrCis"><xsl:value-of select="$Shoda_VC_PocetMJ"/></xsl:element>
		
		<xsl:element name="konfigurace">
			<xsl:element name="SDPH_Nakup"><xsl:value-of select="$SazbaDPH"/></xsl:element>
			<xsl:element name="SDPH_Prod"><xsl:value-of select="$SazbaDPH"/></xsl:element>
		</xsl:element>
	</xsl:element>

</xsl:template>


<!-- Výrobní číslo -->
<xsl:template match="isdoc:StoreBatch | isdocX:StoreBatch">

<!-- vybírají se pouze výrobní čísla (šarže se ignorují) -->
<xsl:param name="VyrobniCislo" select="isdoc:Name[../isdoc:BatchOrSerialNumber = 'S' ] | isdocX:Name[../isdocX:BatchOrSerialNumber = 'S' ]"/>

	<xsl:if test="(string-length($VyrobniCislo) &gt; 0)">
		<xsl:element name="VyrobniCislo">
			<xsl:element name="VyrobniCis">
				<xsl:value-of select="$VyrobniCislo"/>
			</xsl:element>
		</xsl:element>
	</xsl:if>

</xsl:template>


<!-- Daňový odpočet (v nenulové sazbě) -->
<xsl:template match="isdoc:TaxedDeposit | isdocX:TaxedDeposit">
<xsl:param name="Druh"/>
<xsl:param name="CiziMena"/>
<xsl:param name="Znamenko"/>

<xsl:param name="Doklad" select="isdoc:ID  | isdocX:ID"/>
<xsl:param name="SazbaDPH" select="isdoc:ClassifiedTaxCategory/isdoc:Percent | isdocX:ClassifiedTaxCategory/isdocX:Percent"/>
<xsl:param name="MetodaDPH" select="isdoc:ClassifiedTaxCategory/isdoc:VATCalculationMethod | isdocX:ClassifiedTaxCategory/isdocX:VATCalculationMethod"/>
<xsl:param name="PredmPln" select="isdoc:ClassifiedTaxCategory/isdoc:LocalReverseCharge/isdoc:LocalReverseChargeCode
										 | isdocX:ClassifiedTaxCategory/isdocX:LocalReverseCharge/isdocX:LocalReverseChargeCode"/>

<xsl:param name="CelkemDM_zaklad" select="isdoc:TaxableDepositAmount | isdocX:TaxableDepositAmount"/>
<xsl:param name="CelkemDM_vcetneDPH" select="isdoc:TaxInclusiveDepositAmount | isdocX:TaxInclusiveDepositAmount"/>

<xsl:param name="CelkemCM_zaklad" select="isdoc:TaxableDepositAmountCurr | isdocX:TaxableDepositAmountCurr"/>
<xsl:param name="CelkemCM_vcetneDPH" select="isdoc:TaxInclusiveDepositAmountCurr | isdocX:TaxInclusiveDepositAmountCurr"/>

<xsl:param name="ID" select="isdoc:ID | isdocX:ID"/>

<xsl:param name="CenaTyp">
	<xsl:choose>		
		<!-- doklad v cizí měně -->
		<xsl:when test="($CiziMena)">
			<xsl:choose>		
				<!--	 jen DPH  -->
				<xsl:when test="($SazbaDPH != 0) 
								and ($CelkemDM_zaklad = 0) and ($CelkemDM_vcetneDPH != 0)
								and ($CelkemCM_zaklad = 0) and ($CelkemCM_vcetneDPH != 0)">2</xsl:when>
				<!-- jen základ -->
				<xsl:when test="($SazbaDPH != 0)
								and ($CelkemDM_zaklad != 0) and ($CelkemDM_zaklad = $CelkemDM_vcetneDPH)
								and ($CelkemCM_zaklad != 0) and ($CelkemCM_zaklad = $CelkemCM_vcetneDPH)">3</xsl:when>
				<xsl:otherwise><xsl:value-of select="$MetodaDPH"/></xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<!-- doklad v domácí měně -->
		<xsl:otherwise>
			<xsl:choose>		
				<xsl:when test="($SazbaDPH != 0) 
								and ($CelkemDM_zaklad = 0) and ($CelkemDM_vcetneDPH != 0)">2</xsl:when>
				<xsl:when test="($SazbaDPH != 0)
								and ($CelkemDM_zaklad != 0) and ($CelkemDM_zaklad = $CelkemDM_vcetneDPH)">3</xsl:when>
				<xsl:otherwise><xsl:value-of select="$MetodaDPH"/></xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="Cena">
	<xsl:choose>
		<!-- jen DPH -->
		<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="($CelkemDM_vcetneDPH)*($Znamenko)"/></xsl:when>
		<!-- jen základ -->
		<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="($CelkemDM_zaklad)*($Znamenko)"/></xsl:when>
		<!-- bez DPH -->
		<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="($CelkemDM_zaklad)*($Znamenko)"/></xsl:when>
		<!-- s DPH -->
		<xsl:otherwise><xsl:value-of select="($CelkemDM_vcetneDPH)*($Znamenko)"/></xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladDM">
	<xsl:value-of select="format-number(($CelkemDM_zaklad)*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="DPHDM">
	<xsl:value-of select="format-number((($CelkemDM_vcetneDPH)-($CelkemDM_zaklad))*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="Valuty">
	<xsl:choose>
		<!-- jen DPH -->
		<xsl:when test="($CenaTyp = 2)"><xsl:value-of select="($CelkemCM_vcetneDPH)*($Znamenko)"/></xsl:when>
		<!-- jen základ -->
		<xsl:when test="($CenaTyp = 3)"><xsl:value-of select="($CelkemCM_zaklad)*($Znamenko)"/></xsl:when>
		<!-- bez DPH -->
		<xsl:when test="($CenaTyp = 0)"><xsl:value-of select="($CelkemCM_zaklad)*($Znamenko)"/></xsl:when>
		<!-- s DPH -->
		<xsl:otherwise><xsl:value-of select="($CelkemCM_vcetneDPH)*($Znamenko)"/></xsl:otherwise>
	</xsl:choose>
</xsl:param>

<xsl:param name="ZakladCM">
	<xsl:value-of select="format-number(($CelkemCM_zaklad)*($Znamenko),'0.##' )"/>
</xsl:param>

<xsl:param name="DPHCM">
	<xsl:value-of select="format-number((($CelkemCM_vcetneDPH)-($CelkemCM_zaklad))*($Znamenko),'0.##' )"/>
</xsl:param>


	<!-- Tvorba položky -->
		<xsl:element name="Polozka">

			<xsl:element name="Popis"><xsl:value-of select="concat('Odpočet zálohy ',$Doklad)"/></xsl:element>
			<xsl:element name="PocetMJ">1</xsl:element>
			<xsl:element name="CenaTyp"><xsl:value-of select="$CenaTyp"/></xsl:element>
	
			<xsl:element name="SazbaDPH"><xsl:value-of select="$SazbaDPH"/></xsl:element>
			<xsl:element name="Cena"><xsl:value-of select="$Cena"/></xsl:element>
			<xsl:if test="($CiziMena)">
				<xsl:element name="Valuty"><xsl:value-of select="$Valuty"/></xsl:element>
			</xsl:if>

			<xsl:element name="SouhrnDPH">
				<xsl:element name="Zaklad_MJ"><xsl:value-of select="$ZakladDM"/></xsl:element>
				<xsl:element name="DPH_MJ"><xsl:value-of select="$DPHDM"/></xsl:element>
				<xsl:element name="Zaklad"><xsl:value-of select="$ZakladDM"/></xsl:element>
				<xsl:element name="DPH"><xsl:value-of select="$DPHDM"/></xsl:element>
					<xsl:if test="($CiziMena)">
						<xsl:element name="Valuty">
							<xsl:element name="Zaklad_MJ"><xsl:value-of select="$ZakladCM"/></xsl:element>
							<xsl:element name="DPH_MJ"><xsl:value-of select="$DPHCM"/></xsl:element>
							<xsl:element name="Zaklad"><xsl:value-of select="$ZakladCM"/></xsl:element>
							<xsl:element name="DPH"><xsl:value-of select="$DPHCM"/></xsl:element>
						</xsl:element>
					</xsl:if>
			</xsl:element>

			<xsl:element name="NesklPolozka">
				<xsl:element name="Zaloha">1</xsl:element>
				<xsl:if test="(string-length($PredmPln) &gt; 0)">
					<xsl:element name="PredmPln">
						<xsl:value-of select="$PredmPln"/>
					</xsl:element>
				</xsl:if>
			</xsl:element>	

			<!-- Seznam vazeb - související zálohová faktura k odpočtové položce -->
			<xsl:if test="string-length($ID) &gt; 0">
				<xsl:element name="SeznamVazeb">
					<xsl:element name="Vazba">
							<xsl:element name="Typ">ZL</xsl:element>
							<xsl:element name="Doklad">
								<xsl:element name="Druh">FP</xsl:element>
								<xsl:element name="PrijatDokl"><xsl:value-of select="$ID"/></xsl:element>
							</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:element>

</xsl:template>


<!-- Nedaňový odpočet (vždy v nulové sazbě) -->
<xsl:template match="isdoc:NonTaxedDeposit | isdocX:NonTaxedDeposit">
<xsl:param name="Druh"/>
<xsl:param name="CiziMena"/>
<xsl:param name="Znamenko"/>

<xsl:param name="Doklad" select="isdoc:ID  | isdocX:ID"/>
<xsl:param name="CelkemDM" select="isdoc:DepositAmount | isdocX:DepositAmount"/>
<xsl:param name="CelkemCM" select="isdoc:DepositAmountCurr | isdocX:DepositAmountCurr"/>

<xsl:param name="ID" select="isdoc:ID | isdocX:ID"/>

	<!-- Tvorba položky  -->
		<xsl:element name="Polozka">

			<xsl:element name="Popis"><xsl:value-of select="concat('Odpočet zálohy ',$Doklad)"/></xsl:element>
			<xsl:element name="PocetMJ">1</xsl:element>
			<xsl:element name="CenaTyp">0</xsl:element>
	
			<xsl:element name="SazbaDPH">0</xsl:element>
			<xsl:element name="Cena"><xsl:value-of select="($CelkemDM)*($Znamenko)"/></xsl:element>
			<xsl:if test="($CiziMena)">
				<xsl:element name="Valuty"><xsl:value-of select="($CelkemCM)*($Znamenko)"/></xsl:element>
			</xsl:if>

			<xsl:element name="SouhrnDPH">
				<xsl:element name="Zaklad_MJ"><xsl:value-of select="($CelkemDM)*($Znamenko)"/></xsl:element>
				<xsl:element name="DPH_MJ">0</xsl:element>
				<xsl:element name="Zaklad"><xsl:value-of select="($CelkemDM)*($Znamenko)"/></xsl:element>
				<xsl:element name="DPH">0</xsl:element>
					<xsl:if test="($CiziMena)">
						<xsl:element name="Valuty">
							<xsl:element name="Zaklad_MJ"><xsl:value-of select="($CelkemCM)*($Znamenko)"/></xsl:element>
							<xsl:element name="DPH_MJ">0</xsl:element>
							<xsl:element name="Zaklad"><xsl:value-of select="($CelkemCM)*($Znamenko)"/></xsl:element>
							<xsl:element name="DPH">0</xsl:element>
						</xsl:element>
					</xsl:if>
			</xsl:element>

			<xsl:element name="NesklPolozka">
				<xsl:element name="Zaloha">1</xsl:element>
			</xsl:element>	

			<!-- Seznam vazeb - související zálohová faktura k odpočtové položce -->
			<xsl:if test="string-length($ID) &gt; 0">
				<xsl:element name="SeznamVazeb">
					<xsl:element name="Vazba">
							<xsl:element name="Typ">ZL</xsl:element>
							<xsl:element name="Doklad">
								<xsl:element name="Druh">FP</xsl:element>
								<xsl:element name="PrijatDokl"><xsl:value-of select="$ID"/></xsl:element>
							</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>

		</xsl:element>

</xsl:template>

<!-- POLOŽKA - KONEC-->


<!-- PŘIPOJENÉ DOKUMENTY -->

<xsl:template name="Dokumenty">
	<!-- definice elementů (import přes strukturu MoneyData nebo ISDOC) -->
	<xsl:param name="Dokumenty" select="(../../../../isdoc:SupplementsList/isdoc:Supplement) | (../../../../isdocX:SupplementsList/isdocX:Supplement) |
											(isdoc:SupplementsList/isdoc:Supplement) | (isdocX:SupplementsList/isdocX:Supplement)"/>
	<xsl:param name="DokumentyImport">	<!-- příznak, zda je v souboru alespoň jedna příloha, která se bude importovat -->
		<xsl:for-each select="$Dokumenty">
			<xsl:if test="@Import = 1">1</xsl:if>
		</xsl:for-each>
	</xsl:param>

		<xsl:if test="(string-length($DokumentyImport) &gt; 0)">
			<xsl:element name="Dokumenty">
				<xsl:apply-templates select="$Dokumenty"/>
			</xsl:element>
		</xsl:if>
</xsl:template>

<xsl:template match="isdoc:SupplementsList/isdoc:Supplement| isdocX:Invoice//isdocX:Supplement">
	<xsl:if test="@Import = 1">
		<xsl:element name="Dokument"><xsl:value-of select="isdoc:Filename| isdocX:Filename"/></xsl:element>
	</xsl:if>
</xsl:template>

<!-- PŘIPOJENÉ DOKUMENTY - KONEC -->


<!-- Datumový formát výstupu -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum" />
		<xsl:variable name="den" select="substring($_datum, 9,2)"></xsl:variable>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"></xsl:variable>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"></xsl:variable>
		<xsl:variable name="datum" select="concat($den,'.',$mesic,'.',$rok)"></xsl:variable>
		<xsl:value-of select="$datum"></xsl:value-of>
	</xsl:template>

<!-- ISDOC - KONEC  -->

</xsl:stylesheet>