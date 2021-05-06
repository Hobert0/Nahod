<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>


<!-- Transformační šablona převede skladové položky faktur na neskladové a to včetně složených položek. U složených položek se převádí ty položky, které ovlivňují cenový přehled dokladu, tzn.:
				- u faktury přijaté se převádí všechny jednoduché podřízené položky sady a kompletu
				- u faktury vydané jednoduché položky sady, které nemají žádnou nadřízenou položku typu komplet a dále všechny položky typu komplet taktéž bez jiné nadřízené položky typu komplet 
	Dále transformační šablona odebere u všech dokladů elementy ZpusobUctovani a SeznamVazeb (daňové doklady k přijaté platbě se nepřenáší, objednávky se při importu nevyřizují, odpočtové položky
	jsou bez vazby na zálohovou fakturu).
Autor: Marek Vykydal
-->


	<xsl:template match="/">						<!--	Pro všechny elementy na vrcholu vstupního dokumentu proveď  -->
			<xsl:apply-templates/>				<!--	Volá všechny funkce pro ty elementy, které se nachází na vrcholu vstupního dokumentu, tzn. MoneyData -->
	</xsl:template>

	<xsl:template match="MoneyData/*">										<!--	Pro všechny elementy pod elementem MoneyData proveď -->
		<xsl:choose>

			<xsl:when test="name()='SeznamFaktVyd'">
				<xsl:element name="SeznamFaktVyd">
					<xsl:apply-templates select="FaktVyd"/>					<!--	Volá funkce pro element FaktVyd -->
				</xsl:element>
			</xsl:when>

			<xsl:when test="name()='SeznamFaktPrij'">
				<xsl:element name="SeznamFaktPrij">
					<xsl:apply-templates select="FaktPrij"/>
				</xsl:element>
			</xsl:when>

			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


<!--	Založení faktury vydané -->
	<xsl:template match="FaktVyd">
		<xsl:element name="FaktVyd">
				<xsl:apply-templates select="./*">								<!--	Zavolej všechny funkce určené pro elementy pod FaktVyd -->
					<xsl:with-param name="DokladDruh" select="name()" />		<!--	DokladDruh = informace, že se jedná o fakturu vydanou -->
				</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FaktVyd/*">											<!--	Proveď pro všechny elementy pod FaktVyd -->
	<xsl:param name="DokladDruh"/>
				<xsl:call-template name="Kopiruj">
					<xsl:with-param name="DokladDruh" select="$DokladDruh" />
				</xsl:call-template>
	</xsl:template>


<!--	Založení faktury přijaté -->
	<xsl:template match="FaktPrij">	
		<xsl:element name="FaktPrij">
				<xsl:apply-templates select="./*">
					<xsl:with-param name="DokladDruh" select="name()" />		<!--	DokladDruh = informace, že se jedná o fakturu přijatou -->
				</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FaktPrij/*">
	<xsl:param name="DokladDruh"/>
				<xsl:call-template name="Kopiruj">
					<xsl:with-param name="DokladDruh" select="$DokladDruh" />
				</xsl:call-template>
	</xsl:template>


<!--	Kopírování dokumentu, způsob účtování se nekopíruje -->
<xsl:template match="*[not(self::ZpusobUctovani)]|@*|comment()|text()" name="Kopiruj">
<xsl:param name="DokladDruh"/>

	<xsl:choose>
		<xsl:when test="name(.)='SklPolozka' ">								<!--	převod jednoduché skladové položky na neskladovou u normální faktury -->
					<xsl:element name="NesklPolozka">
						<xsl:element name="MJ"><xsl:value-of select="KmKarta/MJ"/></xsl:element>
						<xsl:element name="Katalog"><xsl:value-of select="KmKarta/Katalog"/></xsl:element>
						<xsl:element name="TypZarDoby"><xsl:value-of select="KmKarta/TypZarDoby"/></xsl:element>
						<xsl:element name="ZarDoba"><xsl:value-of select="KmKarta/ZarDoba"/></xsl:element>
						<xsl:element name="PredmPln"><xsl:value-of select="KmKarta/PredmPln"/></xsl:element>
						<xsl:element name="Zaloha">0</xsl:element>
						<xsl:element name="Protizapis">0</xsl:element>
					</xsl:element>
		</xsl:when>

		<xsl:when test="name(.)='KmKarta' ">									<!--	převod jednoduché skladové položky na neskladovou u zálohové faktury -->
					<xsl:element name="NesklPolozka">
						<xsl:element name="Zkrat"><xsl:value-of select="Zkrat"/></xsl:element>
						<xsl:element name="MJ"><xsl:value-of select="MJ"/></xsl:element>
						<xsl:element name="UzivCode"><xsl:value-of select="UzivCode"/></xsl:element>
						<xsl:element name="Katalog"><xsl:value-of select="Katalog"/></xsl:element>
						<xsl:element name="BarCode"><xsl:value-of select="BarCode"/></xsl:element>
						<xsl:element name="TypZarDoby"><xsl:value-of select="TypZarDoby"/></xsl:element>
						<xsl:element name="ZarDoba"><xsl:value-of select="ZarDoba"/></xsl:element>
					</xsl:element>
		</xsl:when>

		<xsl:when test="name(.)='Sklad' ">									<!--	odstranění elementu Sklad u jednoduché položky zálohové faktury -->
		</xsl:when>
		<xsl:when test="name(.)='SeznamVC' ">								<!--	odstranění elementu SeznamVC u jednoduché položky zálohové faktury -->
		</xsl:when>
		<xsl:when test="name(.)='Slozeni' ">									<!--	odstranění elementu Slozeni u kompletu zálohové faktury -->
		</xsl:when>
		<xsl:when test="name(.)='Poradi' ">									<!--	odstranění elementu Pořadí -->
		</xsl:when>

		<xsl:when test="name(.)='SeznamPolozek' ">								<!-- volá seznam položek normální faktury -->
			<xsl:call-template name="Vytvor_SeznamPolozek_NZP">
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="name(.)='SeznamZalPolozek' ">							<!--	volá seznam položek zálohové faktury -->
			<xsl:call-template name="Vytvor_SeznamPolozek_LF">
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
			</xsl:call-template>
		</xsl:when>

		<xsl:when test="name(.)='SeznamVazeb' ">							<!--	odstranění elementu SeznamVazeb -->
		</xsl:when>

		<xsl:when test="(name(.)='EETOdesl') and (.='1') ">					<!--	změna hodnoty elementu EETOdesl v případě, že je rovno 1 -->
					<xsl:element name="EETOdesl">2</xsl:element>
		</xsl:when>

		<xsl:when test="name(.)='PokDokl' ">
			<xsl:call-template name="Vytvor_PokDokl">
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
			</xsl:call-template>
		</xsl:when>

		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates select="*[not(self::ZpusobUctovani)]|@*|comment()|text()"/>	<!-- kopírování ostatních elementů, způsob účtování se nekopíruje -->
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!--	Založení pokladního dokladu -->
<xsl:template name="Vytvor_PokDokl">
<xsl:param name="DokladDruh"/>

		<xsl:element name="PokDokl">

				<xsl:if test="not(EET)">
					<xsl:element name="EET">
						<xsl:element name="EETOdesl">3</xsl:element>		<!--	EETOdesl = 3 v případě, že doklad nepodléhá EET -->
					</xsl:element>
				</xsl:if>

				<xsl:apply-templates select="./*">								<!--	Zavolej všechny funkce určené pro elementy pod PokDokl-->
					<xsl:with-param name="DokladDruh" select="name()" />		<!--	DokladDruh = informace, že se jedná o pokladní doklad -->
				</xsl:apply-templates>
		</xsl:element>
	</xsl:template>


<!--	Založení seznamu položek u normální faktury -->
<xsl:template name="Vytvor_SeznamPolozek_NZP">
<xsl:param name="DokladDruh"/>

		<xsl:element name="SeznamPolozek">
				<xsl:apply-templates select="Polozka">							<!--	prochází položky -->
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
				</xsl:apply-templates>
		</xsl:element>
</xsl:template>


<!--	Založení seznamu položek u zálohové faktury -->
<xsl:template name="Vytvor_SeznamPolozek_LF">
<xsl:param name="DokladDruh"/>

		<xsl:element name="SeznamZalPolozek">
				<xsl:apply-templates select="Polozka">							<!--	prochází položky -->
				<xsl:with-param name="FakturaDruh" select="name()" />			<!--	FakturaDruh = informace, že se jedná o položky zálohové faktury -->
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
				</xsl:apply-templates>
		</xsl:element>
</xsl:template>


<!--	Prochází položky -->
<xsl:template match="Polozka">
	<xsl:param name="FakturaDruh"/>
	<xsl:param name="DokladDruh"/>

	<xsl:choose>
		<xsl:when test="($DokladDruh = 'FaktPrij'  and  (SklPolozka/KmKarta/TypKarty = 'sada'  or  SklPolozka/KmKarta/TypKarty = 'komplet' ))
							or ($DokladDruh = 'FaktVyd'  and  SklPolozka/KmKarta/TypKarty = 'sada' )">	
			<!--	prochází sadu u normání faktury vydané a sadu a komplet u normální faktury přijaté -->
			<xsl:apply-templates select="SklPolozka/Slozeni/SubPolozka/Polozka">	
				<xsl:with-param name="PredkontacTop" select="Predkontac"/>
				<xsl:with-param name="KodDPHTop" select="KodDPH"/>
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
			</xsl:apply-templates>
		</xsl:when>

		<xsl:when test="($DokladDruh = 'FaktPrij'  and  (KmKarta/TypKarty = 'sada'  or  KmKarta/TypKarty = 'komplet' ))
							or ($DokladDruh = 'FaktVyd'  and  KmKarta/TypKarty = 'sada' )">	
			<!--	prochází sadu u zálohové faktury vydané a sadu a komplet u zálohové faktury přijaté -->
			<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">			
			<xsl:with-param name="FakturaDruh" select="$FakturaDruh" />
			<xsl:with-param name="DokladDruh" select="$DokladDruh" />
			</xsl:apply-templates>
		</xsl:when>

		<xsl:otherwise>															<!--	ostatní typy položek - volá kopírování -->
			<xsl:copy>
				<xsl:apply-templates select="*|@*|comment()|text()"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!--	Tvorba nových položek ze složené položky:
		- u faktury přijaté se převádí jednoduché položky sady a kompletu
		- u faktury vydané jednoduché položky sady, které nemají žádnou nadřízenou položku typu komplet a dále položky typu komplet taktéž bez jiné nadřízené položky typu komplet  -->
<xsl:template match="Slozeni/SubPolozka/Polozka">
	<xsl:param name="PredkontacTop"/>
	<xsl:param name="KodDPHTop"/>
	<xsl:param name="FakturaDruh"/>
	<xsl:param name="DokladDruh"/>

	<xsl:choose>
		<!--	test jestli to jsou položky normální faktury -->
		<xsl:when test="$FakturaDruh != 'SeznamZalPolozek' ">						

			<!--	test jestli to není u faktury přijaté položka typu sada nebo komplet, u faktury vydané položka typu sada -->
			<xsl:if test="($DokladDruh = 'FaktPrij'  and  KmKarta/TypKarty != 'sada'  and  KmKarta/TypKarty != 'komplet' )
							or ($DokladDruh = 'FaktVyd'  and  KmKarta/TypKarty != 'sada' ) ">
				<xsl:element name="Polozka">
					<xsl:element name="Popis"><xsl:value-of select="Nazev"/></xsl:element>
					<xsl:element name="PocetMJ"><xsl:value-of select="PocetMJ"/></xsl:element>
					<xsl:element name="SazbaDPH"><xsl:value-of select="DPH"/></xsl:element>
					<xsl:element name="Cena"><xsl:value-of select="Cena"/></xsl:element>
					<xsl:element name="CenaTyp"><xsl:value-of select="CenaTyp"/></xsl:element>
					<xsl:element name="Sleva"><xsl:value-of select="Sleva"/></xsl:element>
					<xsl:element name="Predkontac"><xsl:value-of select="$PredkontacTop"/></xsl:element>
					<xsl:element name="KodDPH"><xsl:value-of select="$KodDPHTop"/></xsl:element>
					<xsl:element name="Valuty"><xsl:value-of select="Valuty"/></xsl:element>
					<xsl:element name="CenaPoSleve"><xsl:value-of select="CenaPoSleve"/></xsl:element>
					<xsl:element name="Stredisko"><xsl:value-of select="Stredisko"/></xsl:element>
					<xsl:element name="Zakazka"><xsl:value-of select="Zakazka"/></xsl:element>
					<xsl:element name="Cinnost"><xsl:value-of select="Cinnost"/></xsl:element>
					<xsl:element name="Poznamka"><xsl:value-of select="Poznamka"/></xsl:element>
							<xsl:element name="NesklPolozka">
								<xsl:element name="MJ"><xsl:value-of select="KmKarta/MJ"/></xsl:element>
								<xsl:element name="Katalog"><xsl:value-of select="KmKarta/Katalog"/></xsl:element>
								<xsl:element name="TypZarDoby"><xsl:value-of select="KmKarta/TypZarDoby"/></xsl:element>
								<xsl:element name="ZarDoba"><xsl:value-of select="KmKarta/ZarDoba"/></xsl:element>
								<xsl:element name="PredmPln"><xsl:value-of select="KmKarta/PredmPln"/></xsl:element>
								<xsl:element name="Zaloha">0</xsl:element>
								<xsl:element name="Protizapis">0</xsl:element>
							</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:when>

		<!--	položky zálohové faktury -->
		<xsl:otherwise>																

			<!--	test jestli to není u faktury přijaté položka typu sada nebo komplet, u faktury vydané položka typu sada -->			
			<xsl:if test="($DokladDruh = 'FaktPrij'  and  KmKarta/TypKarty != 'sada'  and  KmKarta/TypKarty != 'komplet' )
							or ($DokladDruh = 'FaktVyd'  and  KmKarta/TypKarty != 'sada' ) ">
					<xsl:element name="Polozka">
					<xsl:element name="Popis"><xsl:value-of select="Popis"/></xsl:element>
					<xsl:element name="PocetMJ"><xsl:value-of select="PocetMJ"/></xsl:element>
					<xsl:element name="ZbyvaMJ"><xsl:value-of select="ZbyvaMJ"/></xsl:element>
					<xsl:element name="Cena"><xsl:value-of select="Cena"/></xsl:element>
					<xsl:element name="SazbaDPH"><xsl:value-of select="SazbaDPH"/></xsl:element>
					<xsl:element name="TypCeny"><xsl:value-of select="TypCeny"/></xsl:element>
					<xsl:element name="Sleva"><xsl:value-of select="Sleva"/></xsl:element>
					<xsl:element name="Vystaveno"><xsl:value-of select="Vystaveno"/></xsl:element>
					<xsl:element name="VyriditNej"><xsl:value-of select="VyriditNej"/></xsl:element>
					<xsl:element name="Vyridit_do"><xsl:value-of select="Vyridit_do"/></xsl:element>
					<xsl:element name="CenovaHlad"><xsl:value-of select="CenovaHlad"/></xsl:element>
					<xsl:element name="Valuty"><xsl:value-of select="Valuty"/></xsl:element>
					<xsl:element name="KodStatuPuv"><xsl:value-of select="KodStatuPuv"/></xsl:element>
					<xsl:element name="Hmotnost"><xsl:value-of select="Hmotnost"/></xsl:element>
					<xsl:element name="CenaPoSleve"><xsl:value-of select="CenaPoSleve"/></xsl:element>
					<xsl:element name="Stredisko"><xsl:value-of select="Stredisko"/></xsl:element>
					<xsl:element name="Zakazka"><xsl:value-of select="Zakazka"/></xsl:element>
					<xsl:element name="Cinnost"><xsl:value-of select="Cinnost"/></xsl:element>
					<xsl:element name="Poznamka"><xsl:value-of select="Poznamka"/></xsl:element>
							<xsl:element name="NesklPolozka">
								<xsl:element name="Zkrat"><xsl:value-of select="KmKarta/Zkrat"/></xsl:element>
								<xsl:element name="MJ"><xsl:value-of select="KmKarta/MJ"/></xsl:element>
								<xsl:element name="UzivCode"><xsl:value-of select="KmKarta/UzivCode"/></xsl:element>
								<xsl:element name="Katalog"><xsl:value-of select="KmKarta/Katalog"/></xsl:element>
								<xsl:element name="BarCode"><xsl:value-of select="KmKarta/BarCode"/></xsl:element>
								<xsl:element name="TypZarDoby"><xsl:value-of select="KmKarta/TypZarDoby"/></xsl:element>
								<xsl:element name="ZarDoba"><xsl:value-of select="KmKarta/ZarDoba"/></xsl:element>
							</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>

	<!--	pokud je to faktura přijatá anebo faktura vydaná, kde převáděná položka není komplet, tak pokračuje dále do nižší úrovně -->
	<xsl:if test="($DokladDruh = 'FaktPrij') or ($DokladDruh = 'FaktVyd'  and  KmKarta/TypKarty != 'komplet' ) "> 	
		<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
				<xsl:with-param name="PredkontacTop" select="$PredkontacTop"/>
				<xsl:with-param name="KodDPHTop" select="$KodDPHTop"/>
				<xsl:with-param name="FakturaDruh" select="$FakturaDruh"/>
				<xsl:with-param name="DokladDruh" select="$DokladDruh" />
		</xsl:apply-templates>
	</xsl:if>

</xsl:template>

</xsl:stylesheet>
