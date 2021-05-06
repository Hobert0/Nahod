<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"

xmlns="http://isdoc.cz/namespace/2013"
xmlns:money="http://www.money.cz"
>

<!--	Transformační šablona určená pro transformaci faktury vydané do formátu ISDOC. Pokud je na vstupu jiná struktura, tak tuto strukturu pouze zkopíruje.
	Autor: Marek Vykydal
 -->

	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:choose>
			<!--	pokud je na vstupu faktura vydaná, tak provede transformaci do formátu ISDOC -->
			<xsl:when test="MoneyData/SeznamFaktVyd | MoneyData/SeznamFaktVyd_DPP ">
				<xsl:apply-templates select="MoneyData/SeznamFaktVyd/FaktVyd[1]"/>
				<xsl:apply-templates select="MoneyData/SeznamFaktVyd_DPP/FaktVyd_DPP[1]"/>
			</xsl:when>
			<!--	pokud je na vstupu objednávka vydaná, tak provede transformaci do formátu ISDOC - struktura CommonDocument -> NEŘEŠENO
			<xsl:when test="MoneyData/SeznamObjVyd">
				<xsl:apply-templates select="MoneyData/SeznamObjVyd/ObjVyd[1]"/>
			</xsl:when>
			-->
			<!--	na vstupu je jiná struktura, provede pouze její zkopírování -->
			<xsl:otherwise>
				<xsl:apply-templates select="*|@*|text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="FaktVyd">
		<xsl:call-template name="Invoice"/>
	</xsl:template>

	<xsl:template match="FaktVyd_DPP">
		<xsl:call-template name="Invoice"/>
	</xsl:template>

	<!--
	<xsl:template match="ObjVyd">
		<xsl:call-template name="CommonDocument"/>
	</xsl:template>
	-->

<!--	FAKTURA - INVOICE -->
	<xsl:template name="Invoice">

	<!--	ISDOC verze  -->
	<xsl:param name="ISDOC_Verze">6.0.1</xsl:param>

	<xsl:param name="MenaDM">		<!--	Tuzemská měna -->
		<xsl:choose>
			<xsl:when test="string-length(MojeFirma/MenaKod) &gt; 0 ">
				<xsl:value-of select="MojeFirma/MenaKod"/>
			</xsl:when>
			<xsl:otherwise>CZK</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:param name="MenaCM">	<!--	Cizí měna -->
		<xsl:if test="string-length(Valuty/Mena/Kod) &gt; 0 ">
			<xsl:value-of select="Valuty/Mena/Kod"/>
		</xsl:if>
	</xsl:param>

	<xsl:param name="Znamenko">	<!--	Znaménko. V případě dobropisu se musí částky v ISDOCU uvádět kladně. Bude tedy docházet k obracení znaménka. -->
		<xsl:choose>
			<xsl:when test="Dobropis = 1">-1</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:param name="Razeni" select="1"/>		<!--	Řazení sazeb DPH: 1 - vzestupně, 2 - sestupně -->

	<xsl:param name="Polozka">	<!-- Informace, zda normální faktura obsahuje alespoň jednu neodpočtovou položku -->
		<xsl:for-each select="SeznamPolozek/Polozka">
			<xsl:if test="(not(NesklPolozka)) or (NesklPolozka/Zaloha = 0) "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="IdZboziKupujici">			<!-- Způsob plnění elementu BuyersItemIdentification / ID -->
		<xsl:value-of select="DodOdb/ISDOC/@IdZboziKupujici"/>
	</xsl:param>

	<xsl:param name="IdZboziProdejce1">		<!-- Způsob plnění elementu SellersItemIdentification / ID -->
		<xsl:value-of select="DodOdb/ISDOC/@IdZboziProdejce1"/>
	</xsl:param>

	<xsl:param name="IdZboziProdejce2">		<!-- Způsob plnění elementu SecondarySellersItemIdentification / ID -->
		<xsl:value-of select="DodOdb/ISDOC/@IdZboziProdejce2"/>
	</xsl:param>

	<xsl:param name="IdZboziProdejce3">		<!-- Způsob plnění elementu TertiarySellersItemIdentification / ID -->
		<xsl:value-of select="DodOdb/ISDOC/@IdZboziProdejce3"/>
	</xsl:param>

	<xsl:param name="Odpocet">	<!-- Informace, zda faktura obsahuje alespoň jednu odpočtovou položku v nenulové sazbě - viz TaxedDeposits -->
		<xsl:for-each select="SeznamPolozek/Polozka">
			<xsl:if test="(NesklPolozka/Zaloha = 1) and (SazbaDPH != 0) "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="OdpocetN">	<!-- Informace, zda faktura obsahuje alespoň jednu odpočtovou položku v nulové sazbě - viz NonTaxedDeposits-->
		<xsl:for-each select="SeznamPolozek/Polozka">
			<xsl:if test="(NesklPolozka/Zaloha = 1) and (SazbaDPH = 0) "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="ZpusobPlatby">	<!-- Způsob platby -->
		<xsl:variable name="mpismena">abcdefghijklmnopqrstuvwxyzáčďéěíľňóřšťúůýž</xsl:variable>
		<xsl:variable name="vpismena">ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍĽŇÓŘŠŤÚŮÝŽ</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'hotov')">10</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'šek')">20</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'credit transfer')">31</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'převod')">42</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'kart')">48</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'direct debit')">49</xsl:when>
				<xsl:when test="contains(translate(Uhrada, $vpismena, $mpismena), 'dobírk')">50</xsl:when>
				<xsl:when test="(contains(translate(Uhrada, $vpismena, $mpismena), 'zaúčtování mezi partnery')) or (contains(translate(Uhrada, $vpismena, $mpismena), 'zápoč'))">97</xsl:when>
				<xsl:otherwise>42</xsl:otherwise>
			</xsl:choose>
	</xsl:param>

	<xsl:param name="PoklDoklad">	<!-- Informace, zda je v seznamu úhrad alespoň jeden pokladní doklad (platba hotově) -->
		<xsl:for-each select="SeznamUhrad/Uhrada">
			<xsl:if test="(DokladUhr/DruhDokladu = 'P') ">1</xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="Doklad_Celkem">	<!-- Celková cena dokladu s ohledem na měnu dokladu -->
		<xsl:choose>
			<xsl:when test="string-length($MenaCM) &gt; 0 ">
				<xsl:value-of select="(Valuty/Celkem)*($Znamenko)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="(Celkem)*($Znamenko)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>

	<xsl:param name="Vazba_DD_ZF">		<!-- informace, zda se v seznamu vazeb vyskytuje zálohová faktura k daňovému dokladu -->
		<xsl:for-each select="SeznamVazeb/Vazba">
			<xsl:if test="(Typ = 'DD') and (PodTyp = 'ZF') "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="Vazba_DD_HR">		<!-- informace, zda se v seznamu vazeb vyskytuje hradicí doklad k daňovému dokladu -->
		<xsl:for-each select="SeznamVazeb/Vazba">
			<xsl:if test="(Typ = 'DD') and (PodTyp = 'HR') "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="Vazba_DB">			<!-- informace, zda je v seznamu vazeb původní doklad k dobropisu -->
		<xsl:for-each select="SeznamVazeb/Vazba">
			<xsl:if test="(Typ = 'DB') "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="Vazba_PR_OB">		<!-- informace, zda se v seznamu vazeb vyskytuje objednávka -->
		<xsl:for-each select="SeznamVazeb/Vazba">
			<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'OP') "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>

	<xsl:param name="Vazba_PR_DL">		<!-- informace, zda se v seznamu vazeb vyskytuje dodací list -->
		<xsl:for-each select="SeznamVazeb/Vazba">
			<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'DV') "><xsl:value-of select="position()"/></xsl:if>
		</xsl:for-each>
	</xsl:param>


		<xsl:element name="Invoice" namespace="http://isdoc.cz/namespace/2013">
			<xsl:attribute name="version">
				<xsl:value-of select="$ISDOC_Verze"/>
			</xsl:attribute>

			<xsl:element name="DocumentType">
				<xsl:choose>
					<xsl:when test="(Dobropis = 1) and (Druh = 'D' ) ">6</xsl:when>			<!-- prozatím nepodporujeme -->
					<xsl:when test="(Dobropis = 1) and (Druh != 'D' ) ">2</xsl:when>
					<xsl:when test="ZjednD = 1 ">7</xsl:when>
					<xsl:when test="(Druh = 'L') or (Druh = 'F') or (Druh = 'Z') or (Druh = 'P')">4</xsl:when>	<!-- zálohová, proforma faktura -->
					<xsl:when test="Druh = 'D' ">5</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>	<!--	faktura - daňový doklad -->
				</xsl:choose>
			</xsl:element>

			<xsl:if test="((substring(DodOdb/Ucet,1,1) &gt;= 0) and (substring(DodOdb/Ucet,1,1) &lt; 9) and (string-length(DodOdb/KodBanky) &gt; 0))
						or (string-length(DodOdb/Ucet) &gt; 0)">
				<xsl:element name="ClientBankAccount">
					<xsl:choose>
						<xsl:when test="(substring(DodOdb/Ucet,1,1) &gt;= 0) and (substring(DodOdb/Ucet,1,1) &lt; 9)">	<!-- tuzemský formát -->
							<xsl:value-of select="DodOdb/Ucet"/>/<xsl:value-of select="DodOdb/KodBanky"/>
						</xsl:when>
						<xsl:otherwise><xsl:value-of select="DodOdb/Ucet"/></xsl:otherwise>				<!-- formát IBAN -->
					</xsl:choose>
				</xsl:element>
			</xsl:if>

			<xsl:element name="ID">
				<xsl:value-of select="Doklad"/>
			</xsl:element>

			<xsl:element name="UUID"><xsl:value-of select="translate(GUID,'{}','')"/></xsl:element>

			<xsl:element name="IssuingSystem">Ekonomický a informační systém Money S3</xsl:element>

			<xsl:element name="IssueDate">
				<xsl:value-of select="Vystaveno"/>
			</xsl:element>

			<xsl:if test="((Druh = 'N') or (Druh = 'D')) and (string-length(PlnenoDPH)&gt;0)">			<!-- datum zdanitelného plnění se uvádí jen u normální faktury nebo daňového dokladu k přijaté platbě -->
				<xsl:element name="TaxPointDate">
					<xsl:value-of select="PlnenoDPH"/>
				</xsl:element>
			</xsl:if>

			<xsl:element name="VATApplicable">
				<xsl:choose>
					<xsl:when test="(Druh = 'L') or (Druh = 'F') or (Druh = 'Z') or (Druh = 'P')">false</xsl:when>		<!-- zálohová, proforma faktura - nejsou předmětem daně -->
					<xsl:otherwise>true</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="ElectronicPossibilityAgreementReference">
				<xsl:attribute name="languageID">cs</xsl:attribute>
				<xsl:value-of select="normalize-space(DodOdb/ISDOC/@OznacDok)"/>
			</xsl:element>

			<xsl:if test="string-length(ZpDopravy) &gt; 0">
				<xsl:element name="Note">
					<xsl:attribute name="languageID">cs</xsl:attribute>
					<xsl:value-of select="ZpDopravy"/>
				</xsl:element>
			</xsl:if>

			<xsl:element name="LocalCurrencyCode">
				<xsl:value-of select="$MenaDM"/>
			</xsl:element>

			<xsl:if test="string-length($MenaCM) &gt; 0 ">
				<xsl:element name="ForeignCurrencyCode">
					<xsl:value-of select="$MenaCM"/>
				</xsl:element>
			</xsl:if>

			<xsl:element name="CurrRate">
				<xsl:choose>
					<xsl:when test="string-length(Valuty/Mena/Kurs) &gt; 0 ">
						<xsl:value-of select="Valuty/Mena/Kurs"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:element>

			<xsl:element name="RefCurrRate">
				<xsl:choose>
					<xsl:when test="string-length(Valuty/Mena/Mnozstvi) &gt; 0 ">
						<xsl:value-of select="Valuty/Mena/Mnozstvi"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:element>


			<!-- Kopie struktury XML exportu z Money S3 -->
			<xsl:element name="Extensions">
				<xsl:element name="money:MoneyData" namespace="http://www.money.cz">
				<!--	<xsl:text disable-output-escaping="yes">&lt;		!-</xsl:text>		chybí jedna pomlčka 
					Zobrazování uživatelských elementů (položek) je možné v programu ISDOCReader vypnout. Proto je není nutné uvádět v uvozovkách. -->
						<xsl:choose>
							<xsl:when test="name() = 'FaktVyd_DPP' ">
								<xsl:element name="money:SeznamFaktVyd_DPP" namespace="http://www.money.cz">
									<xsl:call-template name="Kopiruj"/>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="money:SeznamFaktVyd" namespace="http://www.money.cz" >
									<xsl:call-template name="Kopiruj"/>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
				<!--	<xsl:text disable-output-escaping="yes">-	&gt;</xsl:text>		chybí jedna pomlčka -->
				</xsl:element>
			</xsl:element>


			<!-- Dodavatel - obchodní adresa -->
			<xsl:element name="AccountingSupplierParty">
				<xsl:apply-templates select="MojeFirma">
					<xsl:with-param name="TypAdr" select="1"/>
				</xsl:apply-templates>
			</xsl:element>

			<!-- Dodavatel - fakturační adresa -->
			<xsl:if test="(MojeFirma/FaktNazev) or (MojeFirma/FaktAdresa)">
				<xsl:element name="SellerSupplierParty">
					<xsl:apply-templates select="MojeFirma">
						<xsl:with-param name="TypAdr" select="3"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>

			<!-- Odběratel - obchodní adresa -->
			<xsl:choose>
				<xsl:when test="ZjednD = 0 ">		<!--	nejedná se o zjednodušený daňový doklad -->
					<xsl:choose>
						<!-- pokud nebude na vstupu uveden DodOdb, tak se namísto tohoto elementu použije AnonymousCustomerParty -->
						<xsl:when test="(DodOdb)">
							<xsl:element name="AccountingCustomerParty">
								<xsl:apply-templates select="DodOdb">
									<xsl:with-param name="TypAdr" select="1"/>
								</xsl:apply-templates>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="AnonymousCustomerParty">
								<xsl:element name="ID">
									<xsl:value-of select="Doklad"/>
								</xsl:element>
								<xsl:element name="IDScheme">CSW</xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<xsl:otherwise>					<!--	zjednodušený daňový doklad -->
					<!-- u tohoto dokladu je AnonymousCustomerParty povinný -->
					<xsl:element name="AnonymousCustomerParty">
						<xsl:element name="ID">
							<xsl:choose>
								<xsl:when test="string-length(DodOdb/ICO) &gt; 0 ">
									<xsl:value-of select="DodOdb/ICO"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="Doklad"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="IDScheme">
							<xsl:choose>
								<xsl:when test="string-length(DodOdb/ICO) &gt; 0 ">IČ</xsl:when>
								<xsl:otherwise>CSW</xsl:otherwise>
							</xsl:choose>						
						</xsl:element>
					</xsl:element>
					<!-- pokud je na dokladu uveden DodOdb, tak se navíc také použije -->
					<xsl:if test="(DodOdb)">
						<xsl:element name="AccountingCustomerParty">
							<xsl:apply-templates select="DodOdb">
								<xsl:with-param name="TypAdr" select="1"/>
							</xsl:apply-templates>
						</xsl:element>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

			<!-- Odběratel - fakturační adresa -->
			<xsl:if test="(DodOdb/FaktNazev) or (DodOdb/FaktAdresa)">
				<xsl:element name="BuyerCustomerParty">
					<xsl:apply-templates select="DodOdb">
						<xsl:with-param name="TypAdr" select="3"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>

			<!-- hlavičková kolekce objednávek -->
			<xsl:if test="string-length($Vazba_PR_OB) &gt; 0  ">
				<xsl:element name="OrderReferences">
					<xsl:for-each select="SeznamVazeb/Vazba">
						<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'OP') ">
							<xsl:element name="OrderReference">
								<xsl:attribute name="id">
									<xsl:value-of select="Doklad/Cislo"/>
								</xsl:attribute>
								<xsl:element name="SalesOrderID">
									<xsl:value-of select="Doklad/Cislo"/>
								</xsl:element>
								<xsl:element name="ExternalOrderID">
									<xsl:value-of select="Doklad/PrijatDokl"/>
								</xsl:element>
								<xsl:element name="IssueDate">
									<xsl:value-of select="Doklad/Vystaveno"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>

			<!-- hlavičková kolekce dodacích listů -->
			<xsl:if test="string-length($Vazba_PR_DL) &gt; 0  ">
				<xsl:element name="DeliveryNoteReferences">
					<xsl:for-each select="SeznamVazeb/Vazba">
						<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'DV') ">
							<xsl:element name="DeliveryNoteReference">
								<xsl:attribute name="id">
									<xsl:value-of select="Doklad/Cislo"/>
								</xsl:attribute>
								<xsl:element name="ID">
									<xsl:value-of select="Doklad/Cislo"/>
								</xsl:element>
								<xsl:element name="IssueDate">
									<xsl:value-of select="Doklad/Vystaveno"/>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>

			<!-- Dobropis - odkaz na původní doklad  -->
			<xsl:if test="Dobropis = 1 ">
				<xsl:element name="OriginalDocumentReferences">
					<xsl:choose>
						<!-- v seznamu vazeb je alespoň jeden původní doklad k dobropisu -->
						<xsl:when test="string-length($Vazba_DB) &gt; 0 ">
							<xsl:for-each select="SeznamVazeb/Vazba">
								<xsl:if test="(Typ = 'DB') ">
									<xsl:element name="OriginalDocumentReference">
										<xsl:element name="ID">
											<xsl:value-of select="Doklad/Cislo"/>
										</xsl:element>
										<xsl:element name="IssueDate">
											<xsl:value-of select="Doklad/Vystaveno"/>
										</xsl:element>
										<xsl:element name="UUID"><xsl:value-of select="translate(Doklad/GUID,'{}','')"/></xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- v seznamu vazeb není žádný původní doklad k dobropisu -->
							<xsl:element name="OriginalDocumentReference">
								<xsl:element name="ID"/>
								<xsl:element name="IssueDate"><xsl:value-of select="Vystaveno"/></xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:if>

			<!-- Konečný příjemce - provozovna (dodací adresa) -->
			<xsl:if test="(KonecPrij)">
				<xsl:element name="Delivery">
					<xsl:apply-templates select="KonecPrij">
						<xsl:with-param name="TypAdr" select="2"/>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>


			<!-- POLOŽKY DOKLADU -->
			<xsl:element name="InvoiceLines">

				<xsl:variable name="PopisDokladu" select="Popis"/>
				<!-- Prochází všechny položky (včetně podřízených a kromě odpočtových), které ovlivňují cenový panel dokladu a porovnává jejich popis s popisem dokladu -->
				<xsl:variable name="PopisPolozky">
					<xsl:for-each select="//Polozka">
						<xsl:if test="
						((
						(KmKarta/TypKarty != 'sada')
							and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet'))
											or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
						or (SklPolozka/KmKarta/TypKarty != 'sada')
						or ((NesklPolozka) and not(NesklPolozka/Zaloha = 1)))
						and ((Popis = $PopisDokladu) or (Nazev = $PopisDokladu))
						 ">1</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<!-- Pokud neexistuje žádná položka, která by měla popis shodný s popisem dokladu, tak se vygeneruje první prázdná položka s popisem dokladu.
					Tato podmínka zajistí to, že každý doklad v ISDOCU bude mít minimálně jednu položku. -->
				<xsl:if test="string-length($PopisPolozky) = 0 ">
					<xsl:call-template name="PolozkaPopisDokladu">
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="SeznamPolozek/Polozka | SeznamZalPolozek/Polozka">
						<xsl:apply-templates select="SeznamPolozek | SeznamZalPolozek">
							<xsl:with-param name="TypPolozek" select="0"/>		<!-- 0 = položky dokladu, 1 = odpočtové položky -->
							<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
							<xsl:with-param name="Znamenko" select="$Znamenko"/>	<!-- znaménko - u dobropisů musí být částky kladně -->
							<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>		<!-- způsob plnění identifikátoru dle kupujícího -->
							<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>	<!-- způsob plnění identifikátoru dle prodejce -->
							<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>	<!-- způsob plnění sekundárního identifikátoru dle prodejce -->
							<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>	<!-- způsob plnění terciálního identifikátoru dle prodejce -->
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="BezPolozek">
							<xsl:with-param name="Razeni" select="$Razeni"/>		<!-- Způsob řazení sazeb DPH : 1 = vzestupně, 2 = sestupně -->
							<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
							<xsl:with-param name="Znamenko" select="$Znamenko"/>	<!-- znaménko - u dobropisů musí být částky kladně -->
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>

				<!-- Zaokrouhlovací položky: pro každou sazbu DPH se vypočítá rozdíl mezi základním plněním z hlavičky dokladu a základním plněním z položek
					a v případě rozdílu se vygeneruje zaokrouhlovací položka.
					Zaokrouhlovací položky se generují pouze v případě, že doklad obsahuje alespoň jednu položku -->
				<xsl:if test="(SeznamZalPolozek/Polozka) or (SeznamPolozek/Polozka)">
					<xsl:call-template name="ZaokPolozky">
						<xsl:with-param name="Razeni" select="$Razeni"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
					</xsl:call-template>
				</xsl:if>

			</xsl:element>


			<!-- DAŇOVÝ DOKLAD K PŘIJATÉ PLATBĚ - informace o zálohové faktuře (nedaňový zálohový list) -->
			<xsl:if test="Druh = 'D' ">
				<xsl:element name="NonTaxedDeposits">
					<xsl:choose>
						<!-- v seznamu vazeb je zálohová faktura k daňovému dokladu -->
						<xsl:when test="string-length($Vazba_DD_ZF) &gt; 0 ">
							<xsl:for-each select="SeznamVazeb/Vazba">
								<xsl:if test="(Typ = 'DD') and (PodTyp = 'ZF') ">
									<xsl:element name="NonTaxedDeposit">
										<xsl:element name="ID">
											<xsl:value-of select="Doklad/Cislo"/>
										</xsl:element>
										<xsl:element name="VariableSymbol">
											<xsl:value-of select="Doklad/VarSymbol"/>
										</xsl:element>
										<xsl:if test="string-length($MenaCM) &gt; 0 ">
											<xsl:element name="DepositAmountCurr">
												<xsl:value-of select="(../../Valuty/Celkem)*($Znamenko)"/>
											</xsl:element>
										</xsl:if>
										<xsl:element name="DepositAmount">
											<xsl:value-of select="(../../Celkem)*($Znamenko)"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<!-- v seznamu vazeb není zálohová faktura, ale je tam hradicí doklad, který je v tomto případě zálohovým listem -->
						<xsl:when test="string-length($Vazba_DD_HR) &gt; 0 ">
							<xsl:for-each select="SeznamVazeb/Vazba">
								<xsl:if test="(Typ = 'DD') and (PodTyp = 'HR') ">
									<xsl:element name="NonTaxedDeposit">
										<xsl:element name="ID">
											<xsl:value-of select="Doklad/Cislo"/>
										</xsl:element>
										<xsl:element name="VariableSymbol">
											<xsl:value-of select="Doklad/VarSymbol"/>
										</xsl:element>
										<xsl:if test="string-length($MenaCM) &gt; 0 ">
											<xsl:element name="DepositAmountCurr">
												<xsl:value-of select="(../../Valuty/Celkem)*($Znamenko)"/>
											</xsl:element>
										</xsl:if>
										<xsl:element name="DepositAmount">
											<xsl:value-of select="(../../Celkem)*($Znamenko)"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- v seznamu vazeb není žádný zálohový list k daňovému dokladu -->
							<xsl:element name="NonTaxedDeposit">
								<xsl:element name="ID"/>
								<xsl:element name="VariableSymbol"/>
								<xsl:if test="string-length($MenaCM) &gt; 0 ">
									<xsl:element name="DepositAmountCurr">
										<xsl:value-of select="(Valuty/Celkem)*($Znamenko)"/>
									</xsl:element>
								</xsl:if>
								<xsl:element name="DepositAmount">
									<xsl:value-of select="(Celkem)*($Znamenko)"/>
								</xsl:element>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:if>

			<!-- Odpočtové položky v nulové sazbě -->
			<xsl:if test="string-length($OdpocetN) &gt; 0  ">	<!-- faktura obsahuje alespoň jednu odpočtovou položku v nulové sazbě -->
				<xsl:element name="NonTaxedDeposits">
					<xsl:apply-templates select="SeznamPolozek">
						<xsl:with-param name="TypPolozek" select="2"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
						<xsl:with-param name="Znamenko">	<!-- znaménko - u normálních faktur musí být částky kladně -->
							<xsl:choose>
								<xsl:when test="$Znamenko = 1">-1</xsl:when>	<!-- normální faktura -->
								<xsl:otherwise>1</xsl:otherwise>					<!-- dobropis -->
							</xsl:choose>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>

			<!-- Odpočtové položky v nenulové sazbě -->
			<xsl:if test="string-length($Odpocet) &gt; 0  ">	<!-- faktura obsahuje alespoň jednu odpočtovou položku v nenulové sazbě -->
				<xsl:element name="TaxedDeposits">
					<xsl:apply-templates select="SeznamPolozek">
						<xsl:with-param name="TypPolozek" select="1"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
						<xsl:with-param name="Znamenko">	<!-- znaménko - u normálních faktur musí být částky kladně -->
							<xsl:choose>
								<xsl:when test="$Znamenko = 1">-1</xsl:when>	<!-- normální faktura -->
								<xsl:otherwise>1</xsl:otherwise>					<!-- dobropis -->
							</xsl:choose>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>


			<!-- Daňová rekapitulace -->
			<xsl:element name="TaxTotal">
				<xsl:call-template name="DanovaRekapitulace">
					<xsl:with-param name="Razeni" select="$Razeni"/>		<!-- Způsob řazení sazeb DPH : 1 = vzestupně, 2 = sestupně -->
					<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
					<xsl:with-param name="Odpocet" select="$Odpocet"/>	<!-- informace, zda se jedná o vyúčtovací fakturu-->
					<xsl:with-param name="Znamenko" select="$Znamenko"/>	<!-- znaménko - u dobropisů musí být částky kladně -->
				</xsl:call-template>
			</xsl:element>


			<!-- Cenová rekapitulace -->
			<xsl:element name="LegalMonetaryTotal">
					<xsl:call-template name="CelkovaRekapitulace">
						<xsl:with-param name="MenaCM" select="$MenaCM"/>	<!-- informace, zda je doklad v cizí měně -->
						<xsl:with-param name="Odpocet" select="$Odpocet"/>	<!-- informace, zda se jedná o vyúčtovací fakturu-->
						<xsl:with-param name="Znamenko" select="$Znamenko"/>	<!-- znaménko - u dobropisů musí být částky kladně -->
					</xsl:call-template>
			</xsl:element>
	

			<!-- KOLEKCE PLATEB (způsob platby) -->
			<xsl:if test="Druh != 'D' ">					
			<!-- Budeme uvádět jen v případě, že se nejedná o daňový doklad k přijaté platbě, který se v programu Money S3 nikdy nehradí.
				V původním algoritmu je totiž uvedeno, že se hradí vždy hotově, ale v MS3 tomu tak není. Muselo by se jedině jednat o situaci, kdy je hradicí doklad současně daňovým 					dokladem, ale i zde to nemusí být vždy pokladní doklad. Původní algoritmus vycházel pravděpodobně z příkladů ISDOCU, kde byl daňový doklad hrazen hotově.
				-->
				<xsl:element name="PaymentMeans">
					<xsl:call-template name="KolekcePlateb">
						<xsl:with-param name="MenaDM" select="$MenaDM"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="ZpusobPlatby">
							<xsl:choose>
								<xsl:when test="Druh = 'D'  ">10</xsl:when>			<!-- v případě daňového dokladu vždy hotově -->
								<xsl:otherwise><xsl:value-of select="$ZpusobPlatby"/></xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="PoklDoklad" select="$PoklDoklad"/>
						<xsl:with-param name="Doklad_Celkem" select="$Doklad_Celkem"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
	
		</xsl:element>
	</xsl:template>

<!-- FAKTURA (INVOICE) - KONEC-->


<!--	OBJEDNÁVKA - COMMONDOCUMENT -->
	<xsl:template name="CommonDocument">

	<!--	ISDOC verze  -->
	<xsl:param name="ISDOC_Verze">6.0.1</xsl:param>

		<xsl:element name="CommonDocument">
			<xsl:attribute name="version">
				<xsl:value-of select="$ISDOC_Verze"/>
			</xsl:attribute>

			<xsl:element name="SubDocumentType">1</xsl:element>	<!-- 1 = objednávka vydaná -->
			<xsl:element name="SubDocumentTypeOrigin">CBA</xsl:element>

			<xsl:element name="ID">
				<xsl:value-of select="Doklad"/>
			</xsl:element>

			<xsl:element name="UUID"><xsl:value-of select="translate(GUID,'{}','')"/></xsl:element>

			<xsl:element name="IssueDate">
				<xsl:value-of select="Vystaveno"/>
			</xsl:element>

			<xsl:if test="string-length(Vyridit_do) &gt; 0 ">
				<xsl:element name="LastValidDate">
					<xsl:value-of select="Vyridit_do"/>
				</xsl:element>
			</xsl:if>

			<xsl:if test="string-length(Poznamka) &gt; 0 ">
				<xsl:element name="Note">
					<xsl:attribute name="languageID">cs</xsl:attribute>
					<xsl:value-of select="Poznamka"/>
				</xsl:element>
			</xsl:if>

			<!-- Kopie struktury XML exportu z Money S3 -->
			<xsl:element name="Extensions">
				<xsl:element name="money:MoneyData" namespace="http://www.money.cz">
				<!--	<xsl:text disable-output-escaping="yes">&lt;		!-</xsl:text>		chybí jedna pomlčka 
					Zobrazování uživatelských elementů (položek) je možné v programu ISDOCReader vypnout. Proto je není nutné uvádět v uvozovkách. -->
					<xsl:element name="money:SeznamObjVyd" namespace="http://www.money.cz">
						<xsl:call-template name="Kopiruj"/>
					</xsl:element>
				<!--	<xsl:text disable-output-escaping="yes">-	&gt;</xsl:text>		chybí jedna pomlčka -->
				</xsl:element>
			</xsl:element>

			<!-- Dodavatel - obchodní adresa -->
			<xsl:element name="AccountingSupplierParty">
				<xsl:apply-templates select="DodOdb">
					<xsl:with-param name="TypAdr" select="1"/>
				</xsl:apply-templates>
			</xsl:element>

			<!-- Odběratel - obchodní adresa -->
			<xsl:element name="AccountingCustomerParty">
				<xsl:apply-templates select="MojeFirma">
					<xsl:with-param name="TypAdr" select="1"/>
				</xsl:apply-templates>
			</xsl:element>

		</xsl:element>

	</xsl:template>
<!-- OBJEDNÁVKA (COMMONDOCUMENT) - KONEC-->


<!-- SUBJEKT (ADRESA) -->
<xsl:template match="MojeFirma | DodOdb | KonecPrij">
	<xsl:param name="TypAdr"/>		<!-- Typ adresy: 1 = obchodní jméno, 2 = provozovna (dodací adresa), 3 = fakturační adresa -->
	<xsl:param name="Rezim"/>		<!-- 1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions -->
	
	<xsl:param name="Nazev">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="ObchNazev"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="Nazev"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FaktNazev"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:param name="Ulice">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="ObchAdresa/Ulice"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="Adresa/Ulice"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FaktAdresa/Ulice"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:param name="Obec">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="ObchAdresa/Misto"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="Adresa/Misto"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FaktAdresa/Misto"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:param name="PSC">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="ObchAdresa/PSC"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="Adresa/PSC"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FaktAdresa/PSC"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:param name="KodStatu">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="ObchAdresa/KodStatu"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="Adresa/KodStatu"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="FaktAdresa/KodStatu"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	
	<xsl:variable name="mpismena">abcdefghijklmnopqrstuvwxyzáčďéěíľňóřšťúůýž</xsl:variable>
	<xsl:variable name="vpismena">ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍĽŇÓŘŠŤÚŮÝŽ</xsl:variable>
	<xsl:variable name="Stat">
		<xsl:choose>
			<xsl:when test="$TypAdr = 1 ">
				<xsl:value-of select="translate(ObchAdresa/Stat, $vpismena, $mpismena)"/>
			</xsl:when>
			<xsl:when test="$TypAdr = 2 ">
				<xsl:value-of select="translate(Adresa/Stat, $vpismena, $mpismena)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate(FaktAdresa/Stat, $vpismena, $mpismena)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:choose>
		<xsl:when test="$Rezim = 1">	<!-- 1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions -->
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>		<!-- jinak transformace na formát ISDOC -->
	
			<xsl:element name="Party">
	
				<xsl:element name="PartyIdentification">
					<xsl:if test="string-length(KodPartn) &gt; 0 ">
						<!-- <xsl:element name="UserID"><xsl:value-of select="normalize-space(KodPartn)"/></xsl:element>-->
						<xsl:element name="CatalogFirmIdentification"><xsl:value-of select="normalize-space(KodPartn)"/></xsl:element>
					</xsl:if>
					<xsl:element name="ID"><xsl:value-of select="normalize-space(ICO)"/></xsl:element>
				</xsl:element>
	
				<xsl:element name="PartyName">
					<xsl:element name="Name">
						<xsl:value-of select="normalize-space($Nazev)"/>
					</xsl:element>
				</xsl:element>
	
				<xsl:element name="PostalAddress">
					<xsl:element name="StreetName">
						<xsl:call-template name="Ulice_CisloDomu">
							<xsl:with-param name="Retezec" select="normalize-space($Ulice)"/>
							<xsl:with-param name="Typ" select="0" />
						</xsl:call-template>
					</xsl:element>
					<xsl:element name="BuildingNumber">
						<xsl:call-template name="Ulice_CisloDomu">
							<xsl:with-param name="Retezec" select="normalize-space($Ulice)"/>
							<xsl:with-param name="Typ" select="1" />
						</xsl:call-template>
					</xsl:element>
					<xsl:element name="CityName"><xsl:value-of select="normalize-space($Obec)"/></xsl:element>
					<xsl:element name="PostalZone"><xsl:value-of select="normalize-space($PSC)"/></xsl:element>
					<xsl:element name="Country">
						<xsl:element name="IdentificationCode">
							<xsl:choose>
								<xsl:when test="normalize-space($Stat)='česká republika' ">CZ</xsl:when>
								<xsl:when test="normalize-space($Stat)='česká rep.' ">CZ</xsl:when>
								<xsl:when test="normalize-space($Stat)='česká r.' ">CZ</xsl:when>
								<xsl:when test="normalize-space($Stat)='čr' ">CZ</xsl:when>
								<xsl:when test="normalize-space($Stat)='cz' ">CZ</xsl:when>

								<xsl:when test="normalize-space($Stat)='slovenská republika' ">SK</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovenská rep.' ">SK</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovenská r.' ">SK</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovensko' ">SK</xsl:when>
								<xsl:when test="normalize-space($Stat)='sr' ">SK</xsl:when>
								<xsl:when test="normalize-space($Stat)='sk' ">SK</xsl:when>

								<xsl:otherwise><xsl:value-of select="normalize-space($KodStatu)"/></xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="Name">
							<xsl:choose>
								<xsl:when test="normalize-space($Stat)='česká republika' ">Česká republika</xsl:when>
								<xsl:when test="normalize-space($Stat)='česká rep.' ">Česká republika</xsl:when>
								<xsl:when test="normalize-space($Stat)='česká r.' ">Česká republika</xsl:when>
								<xsl:when test="normalize-space($Stat)='čr' ">Česká republika</xsl:when>
								<xsl:when test="normalize-space($Stat)='cz' ">Česká republika</xsl:when>

								<xsl:when test="normalize-space($Stat)='slovenská republika' ">Slovensko</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovenská rep.' ">Slovensko</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovenská r.' ">Slovensko</xsl:when>
								<xsl:when test="normalize-space($Stat)='slovensko' ">Slovensko</xsl:when>
								<xsl:when test="normalize-space($Stat)='sr' ">Slovensko</xsl:when>
								<xsl:when test="normalize-space($Stat)='sk' ">Slovensko</xsl:when>

								<xsl:when test="normalize-space($KodStatu)='CZ' ">Česká republika</xsl:when>
								<xsl:when test="normalize-space($KodStatu)='SK' ">Slovensko</xsl:when>

								<xsl:otherwise><xsl:value-of select="normalize-space($Stat)"/></xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
	
				<xsl:if test="string-length(DIC) &gt; 0 ">
					<xsl:element name="PartyTaxScheme">
						<xsl:element name="CompanyID"><xsl:value-of select="normalize-space(DIC)"/></xsl:element>
						<xsl:element name="TaxScheme">VAT</xsl:element>
					</xsl:element>
				</xsl:if>


				<!-- element DanIC se vyskytuje pod elementem MojeFirma v SK verzi namísto elementu DICSK -->
				<xsl:if test="(string-length(DICSK) &gt; 0) or (string-length(DanIC) &gt; 0)  ">
					<xsl:element name="PartyTaxScheme">
						<xsl:element name="CompanyID"><xsl:value-of select="normalize-space(DICSK)"/><xsl:value-of select="normalize-space(DanIC)"/></xsl:element>
						<xsl:element name="TaxScheme">TIN</xsl:element>
					</xsl:element>
				</xsl:if>
	
				<xsl:if test="string-length(SpisovaZnacka) &gt; 0 ">
					<xsl:element name="RegisterIdentification">
						<xsl:element name="Preformatted"><xsl:value-of select="normalize-space(SpisovaZnacka)"/></xsl:element>
					</xsl:element>
				</xsl:if>
	
				<xsl:variable name="Jednatel">		<!-- nalezení jednatele v seznamu osob -->
					<xsl:choose>
						<xsl:when test="count(Osoba/Jednatel)  &gt; 0 ">
							<xsl:for-each select="Osoba">
								<xsl:if test="Jednatel = 1 "><xsl:value-of select="position()"/></xsl:if>
							</xsl:for-each>					
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
		
					<!-- CONTACT, uvádí se pouze v případě, že je uvedeno příjmení kontaktní osoby, telefon adresy nebo mail adresy -->
					<xsl:if test="(string-length(Osoba[position() = $Jednatel]/Prijmeni) &gt; 0) or (string-length(Tel/Cislo) &gt; 0) or (string-length(EMail) &gt; 0) ">
						<xsl:element name="Contact">
		
							<xsl:choose>
									<xsl:when test="string-length(Osoba[position() = $Jednatel]/Prijmeni) &gt; 0 ">
											<xsl:for-each select="Osoba[position() = $Jednatel]">
												<xsl:element name="Name">
													<xsl:if test="(string-length(TitulPred) &gt; 0)"><xsl:value-of select="concat(TitulPred,' ')"/></xsl:if>
													<xsl:if test="(string-length(Jmeno) &gt; 0)"><xsl:value-of select="concat(Jmeno,' ')"/></xsl:if>
													<xsl:value-of select="Prijmeni"/>
													<xsl:if test="(string-length(TitulZa) &gt; 0)"><xsl:value-of select="concat(', ',TitulZa)"/></xsl:if>
												</xsl:element>
			
												<xsl:if test="string-length(Tel/Cislo) &gt; 0 ">
													<xsl:element name="Telephone">
														<xsl:value-of select="concat(Tel/Pred,Tel/Cislo)"/>
														<xsl:if test="(string-length(Tel/Klap) &gt; 0)"><xsl:value-of select="concat('/',Tel/Klap)"/></xsl:if>	
													</xsl:element>
												</xsl:if>
			
												<xsl:if test="string-length(EMail) &gt; 0 ">
													<xsl:element name="ElectronicMail">
														<xsl:value-of select="EMail"/>
													</xsl:element>
												</xsl:if>
											</xsl:for-each>
									</xsl:when>
			
									<xsl:otherwise>
												<xsl:if test="string-length(Tel/Cislo) &gt; 0 ">
													<xsl:element name="Telephone">
														<xsl:value-of select="concat(Tel/Pred,Tel/Cislo)"/>
														<xsl:if test="(string-length(Tel/Klap) &gt; 0)"><xsl:value-of select="concat('/',Tel/Klap)"/></xsl:if>	
													</xsl:element>
												</xsl:if>
			
												<xsl:if test="string-length(EMail) &gt; 0 ">
													<xsl:element name="ElectronicMail">
														<xsl:value-of select="EMail"/>
													</xsl:element>
												</xsl:if>
									</xsl:otherwise>
							</xsl:choose>
		
					</xsl:element>
				</xsl:if>
			</xsl:element>

		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!-- Rozdělení ulice a čísla domu -->
<xsl:template name="Ulice_CisloDomu">
<xsl:param name="Retezec"/>
<xsl:param name="Typ"/>
<xsl:param name="Delka" select="string-length($Retezec)"/>
<xsl:param name="Mezera">						<!-- pozice mezery, která odděluje ulici od čísla -->
	<xsl:choose>
		<xsl:when test="contains(normalize-space($Retezec),' ')">		<!-- test, zda řetězec obsahuje mezeru -->
			<xsl:call-template name="HledaniMezery">
				<xsl:with-param name="Retezec" select="substring-after($Retezec,' ')"/>			<!-- vrací část řetězce za mezerou -->
				<xsl:with-param name="Pozice" select="string-length(substring-before($Retezec,' '))+1"/>	<!-- vrací pozici mezery v řetězci -->
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>			<!-- bez mezery -->
	</xsl:choose>
</xsl:param>

	<xsl:choose>			<!-- test, zda řetězec obsahuje mezeru a zda text za poslední mezerou obsahuje číslici -->
		<xsl:when test="($Mezera &gt; 0) and
						 ((contains(substring($Retezec,$Mezera+1),'0')
						 or (contains(substring($Retezec,$Mezera+1),'1'))
 						 or (contains(substring($Retezec,$Mezera+1),'2'))
						 or (contains(substring($Retezec,$Mezera+1),'3'))
						 or (contains(substring($Retezec,$Mezera+1),'4'))
						 or (contains(substring($Retezec,$Mezera+1),'5'))
						 or (contains(substring($Retezec,$Mezera+1),'6'))
						 or (contains(substring($Retezec,$Mezera+1),'7'))
						 or (contains(substring($Retezec,$Mezera+1),'8'))
						 or (contains(substring($Retezec,$Mezera+1),'9')))) ">
			<xsl:choose>
				<xsl:when test="$Typ = '0' ">				<!-- vrací ulici -->
					<xsl:value-of select="substring($Retezec,1,($Mezera)-1) "/>
				</xsl:when>
				<xsl:otherwise>								<!-- vrací číslo domu -->
					<xsl:value-of select="substring($Retezec,$Mezera+1) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$Typ = '0' ">				<!-- vrací pouze ulici -->
				<xsl:value-of select="normalize-space($Retezec)"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!-- Rozdělení ulice a čísla domu - hledání mezery -->
<xsl:template name="HledaniMezery">
<xsl:param name="Retezec"/>
<xsl:param name="Pozice"/>

	<xsl:choose>
		<xsl:when test="contains($Retezec,' ')">		<!-- test, zda dílčí řetězec obsahuje mezeru -->
				<xsl:call-template name="HledaniMezery">
					<xsl:with-param name="Retezec" select="substring-after($Retezec,' ')"/>				<!-- vrací část řetězce za mezerou -->
					<xsl:with-param name="Pozice" select="$Pozice+string-length(substring-before($Retezec,' '))+1"/>		<!-- vrací pozici mezery v řetězci -->
				</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$Pozice"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<!-- SUBJEKT (ADRESA) - KONEC-->



<!-- KOLEKCE PLATEB SEZNAM PLATEB HOTOVĚ -->
<xsl:template name="KolekcePlateb">
<xsl:param name="MenaDM"/>
<xsl:param name="MenaCM"/>
<xsl:param name="ZpusobPlatby"/>
<xsl:param name="PoklDoklad"/>
<xsl:param name="Doklad_Celkem"/>

		<xsl:choose>
			<!-- Hotově -->
			<xsl:when test="($ZpusobPlatby = 10) or (string-length($PoklDoklad) &gt; 0) ">
				<xsl:call-template name="Hotove">
					<xsl:with-param name="MenaDM" select="$MenaDM"/>
					<xsl:with-param name="MenaCM" select="$MenaCM"/>
					<xsl:with-param name="ZpusobPlatby" select="10"/>
					<xsl:with-param name="PoklDoklad" select="$PoklDoklad"/>
					<xsl:with-param name="Doklad_Celkem" select="$Doklad_Celkem"/>
				</xsl:call-template>
			</xsl:when>

			<!-- Bankovním převodem -->
			<xsl:otherwise>
				<xsl:call-template name="BankUcet">
					<xsl:with-param name="MenaDM" select="$MenaDM"/>
					<xsl:with-param name="MenaCM" select="$MenaCM"/>
					<xsl:with-param name="ZpusobPlatby" select="$ZpusobPlatby"/>
					<xsl:with-param name="Doklad_Celkem" select="$Doklad_Celkem"/>
				</xsl:call-template>
		</xsl:otherwise>

	</xsl:choose>
</xsl:template>


<!-- Seznam plateb hotově  -->
<xsl:template name="Hotove">
<xsl:param name="MenaDM"/>
<xsl:param name="MenaCM"/>
<xsl:param name="ZpusobPlatby"/>
<xsl:param name="PoklDoklad"/>
<xsl:param name="PoklDoklad_Celkem">
	<xsl:call-template name="PoklDoklad_Celkem">
		<xsl:with-param name="Pozice" select="1"/>
		<xsl:with-param name="MenaCM" select="$MenaCM"/>
		<xsl:with-param name="Celkem" select="0"/>
	</xsl:call-template>
</xsl:param>
<xsl:param name="Doklad_Celkem"/>

	<xsl:choose>
		<!-- alespoň jedna úhrada prostřednictvím pokladního dokladu -->
		<xsl:when test="string-length($PoklDoklad) &gt; 0">
			<xsl:for-each select="SeznamUhrad/Uhrada">
				<xsl:if test="(DokladUhr/DruhDokladu = 'P') ">
					<xsl:element name="Payment">
						<xsl:element name="PaidAmount">
							<xsl:choose>
								<xsl:when test="string-length($MenaCM) &gt; 0 ">
									<xsl:value-of select="ValutyHraz/Castka"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="Castka"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="PaymentMeansCode">
							<xsl:value-of select="$ZpusobPlatby"/>
						</xsl:element>
						<xsl:element name="Details">
							<xsl:element name="DocumentID"><xsl:value-of select="DokladUhr/CisloDokladu"/></xsl:element>
							<xsl:element name="IssueDate"><xsl:value-of select="Datum"/></xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:for-each>

			<!-- celková částka úhrad prostřednictvím pokladních dokladů je menší než celková cena dokladu, zbytek se bude hradit převodem -->
			<xsl:if test="($Doklad_Celkem &gt; $PoklDoklad_Celkem)">
				<xsl:call-template name="BankUcet">
					<xsl:with-param name="MenaDM" select="$MenaDM"/>
					<xsl:with-param name="MenaCM" select="$MenaCM"/>
					<xsl:with-param name="ZpusobPlatby" select="42"/>
					<xsl:with-param name="Doklad_Celkem" select="($Doklad_Celkem)-($PoklDoklad_Celkem)"/>
				</xsl:call-template>
			</xsl:if>

		</xsl:when>

		<!-- bez pokladního dokladu -->
		<xsl:otherwise>
			<xsl:element name="Payment">
				<xsl:element name="PaidAmount">
					<xsl:value-of select="$Doklad_Celkem"/>
				</xsl:element>
				<xsl:element name="PaymentMeansCode">
					<xsl:value-of select="$ZpusobPlatby"/>
				</xsl:element>
				<xsl:element name="Details">
					<xsl:element name="DocumentID">
					<!-- v případě daňového dokladu se uvede číslo zálohového dokladu -->
						<xsl:if test="Druh = 'D' ">
							<xsl:choose>
								<xsl:when test="string-length(DanovyDoklad/ZalohaCislo) &gt; 0 ">
									<xsl:value-of select="DanovyDoklad/ZalohaCislo"/>
								</xsl:when>
								<xsl:otherwise><xsl:value-of select="DanovyDoklad/HrDoklCislo"/></xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</xsl:element>
					<xsl:element name="IssueDate">
						<xsl:choose>
						<!-- v případě daňového dokladu se uvede datum zdanitelného plnění (daňový doklad je vždy hotově) -->
							<xsl:when test="Druh = 'D'  ">
								<xsl:value-of select="PlnenoDPH"/>
							</xsl:when>
							<xsl:otherwise><xsl:value-of select="Vystaveno"/></xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!-- Seznam plateb na bankovní účet -->
<xsl:template name="BankUcet">
<xsl:param name="MenaDM"/>
<xsl:param name="MenaCM"/>
<xsl:param name="ZpusobPlatby"/>
<xsl:param name="Doklad_Celkem"/>

		<!-- Bankovní spojení -->
		<xsl:element name="Payment">
			<xsl:element name="PaidAmount">
				<xsl:value-of select="$Doklad_Celkem"/>
			</xsl:element>
			<xsl:element name="PaymentMeansCode">
				<xsl:value-of select="$ZpusobPlatby"/>
			</xsl:element>
			<xsl:element name="Details">
				<xsl:element name="PaymentDueDate"><xsl:value-of select="Splatno"/></xsl:element>

					<xsl:choose>
						<xsl:when test="(substring(MojeFirma/Ucet,1,1) &gt;= 0) and (substring(MojeFirma/Ucet,1,1) &lt; 9)">
							<xsl:element name="ID"><xsl:value-of select="MojeFirma/Ucet"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="ID"/>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="(substring(MojeFirma/KodBanky,1,1) &gt;= 0) and (substring(MojeFirma/KodBanky,1,1) &lt; 9)">
							<xsl:element name="BankCode"><xsl:value-of select="MojeFirma/KodBanky"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="BankCode"/>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:element name="Name"><xsl:value-of select="MojeFirma/Banka"/></xsl:element>

					<xsl:choose>
						<xsl:when test="not((substring(MojeFirma/Ucet,1,1) &gt;= 0) and (substring(MojeFirma/Ucet,1,1) &lt; 9))">
							<xsl:element name="IBAN"><xsl:value-of select="MojeFirma/Ucet"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="IBAN"/>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="not((substring(MojeFirma/KodBanky,1,1) &gt;= 0) and (substring(MojeFirma/KodBanky,1,1) &lt; 9))">
							<xsl:element name="BIC"><xsl:value-of select="MojeFirma/KodBanky"/></xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="BIC"/>
						</xsl:otherwise>
					</xsl:choose>

				<xsl:element name="VariableSymbol"><xsl:value-of select="VarSymbol"/></xsl:element>
				<xsl:element name="ConstantSymbol"><xsl:value-of select="KonstSym"/></xsl:element>
				<xsl:element name="SpecificSymbol"><xsl:value-of select="SpecSymbol"/></xsl:element>
			</xsl:element>
		</xsl:element>

		<!-- Alternativní bankovní spojení -->
		<xsl:if test="count(MojeFirma/SeznamBankSpojeni/BankSpojeni) &gt; 0 ">
			<xsl:element name="AlternateBankAccounts">
				<xsl:for-each select="MojeFirma/SeznamBankSpojeni/BankSpojeni">
					<xsl:element name="AlternateBankAccount">

						<xsl:choose>
							<xsl:when test="(substring(Ucet,1,1) &gt;= 0) and (substring(Ucet,1,1) &lt; 9)">
								<xsl:element name="ID"><xsl:value-of select="Ucet"/></xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="ID"/>
							</xsl:otherwise>
						</xsl:choose>
	
						<xsl:choose>
							<xsl:when test="(substring(KodBanky,1,1) &gt;= 0) and (substring(KodBanky,1,1) &lt; 9)">
								<xsl:element name="BankCode"><xsl:value-of select="KodBanky"/></xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="BankCode"/>
							</xsl:otherwise>
						</xsl:choose>
	
						<xsl:element name="Name"><xsl:value-of select="Banka"/></xsl:element>
						
						<xsl:choose>
							<xsl:when test="not((substring(Ucet,1,1) &gt;= 0) and (substring(Ucet,1,1) &lt; 9))">
								<xsl:element name="IBAN"><xsl:value-of select="Ucet"/></xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="IBAN"/>
							</xsl:otherwise>
						</xsl:choose>
	
						<xsl:choose>
							<xsl:when test="not((substring(KodBanky,1,1) &gt;= 0) and (substring(KodBanky,1,1) &lt; 9))">
								<xsl:element name="BIC"><xsl:value-of select="KodBanky"/></xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:element name="BIC"/>
							</xsl:otherwise>
						</xsl:choose>

					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>

</xsl:template>


<!-- Uhrazeno celkem prostřednictvím pokladních dokladů (respektuje měnu dokladu) -->
<xsl:template name="PoklDoklad_Celkem">
<xsl:param name="Pozice"/>
<xsl:param name="MenaCM"/>
<xsl:param name="Celkem"/>

		<xsl:choose>
			<xsl:when test="($Pozice &lt;= count(SeznamUhrad/Uhrada))">
				<xsl:choose>
						<xsl:when test="(SeznamUhrad/Uhrada[position()=$Pozice]/DokladUhr/DruhDokladu = 'P')">
					 		<xsl:choose>
								<xsl:when test="string-length($MenaCM) &gt; 0 ">
									<xsl:call-template name="PoklDoklad_Celkem">
										<xsl:with-param name="Pozice" select="$Pozice+1"/>
										<xsl:with-param name="MenaCM" select="$MenaCM"/>
										<xsl:with-param name="Celkem" select="$Celkem+SeznamUhrad/Uhrada[$Pozice]/ValutyHraz/Castka"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="PoklDoklad_Celkem">
										<xsl:with-param name="Pozice" select="$Pozice+1"/>
										<xsl:with-param name="MenaCM" select="$MenaCM"/>
										<xsl:with-param name="Celkem" select="$Celkem+SeznamUhrad/Uhrada[$Pozice]/Castka"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
					</xsl:when>

					<xsl:otherwise>
						<xsl:call-template name="PoklDoklad_Celkem">
							<xsl:with-param name="Pozice" select="$Pozice+1"/>
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Celkem" select="$Celkem"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="$Celkem"/>
			</xsl:otherwise>
		</xsl:choose>

</xsl:template>

<!-- KOLEKCE PLATEB - KONEC -->



<!-- SEZNAM POLOŽEK -->
<xsl:template match="SeznamPolozek">
<xsl:param name="Rezim"/>				<!-- "" = generování položek ve formátu ISDOC
												1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions
											-->
<xsl:param name="TypPolozek"/>			<!--	0 = položky dokladu, 1 = odpočtové položky v nenulové sazbě, 2 = odpočtové položky v nulové sazbě  -->
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Znamenko"/>				<!--	znaménko - v případě dobropisu se musí částky uvádět kladně -->
<xsl:param name="IdZboziKupujici"/>		<!-- způsob plnění identifikátoru dle kupujícího -->
<xsl:param name="IdZboziProdejce1"/>		<!-- způsob plnění identifikátoru dle prodejce -->
<xsl:param name="IdZboziProdejce2"/>		<!-- způsob plnění sekundárního identifikátoru dle prodejce -->
<xsl:param name="IdZboziProdejce3"/>		<!-- způsob plnění terciálního identifikátoru dle prodejce -->

	<xsl:choose>
		<xsl:when test="$Rezim = 1">	<!-- 1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions -->
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>		<!-- transformace na formát ISDOC -->
			<xsl:apply-templates select="Polozka">
				<xsl:with-param name="TypPolozek" select="$TypPolozek"/>
				<xsl:with-param name="MenaCM" select="$MenaCM"/>
				<xsl:with-param name="Rezim" select="$Rezim"/>
				<xsl:with-param name="Znamenko" select="$Znamenko"/>
				<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
				<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
				<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
				<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="SeznamZalPolozek">
<xsl:param name="Rezim"/>
<xsl:param name="TypPolozek"/>
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Znamenko"/>
<xsl:param name="IdZboziKupujici"/>
<xsl:param name="IdZboziProdejce1"/>
<xsl:param name="IdZboziProdejce2"/>
<xsl:param name="IdZboziProdejce3"/>

	<xsl:choose>
		<xsl:when test="$Rezim= 1">
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>		<!-- transformace na formát ISDOC -->
			<xsl:apply-templates select="Polozka">
				<xsl:with-param name="TypPolozek" select="$TypPolozek"/>	
				<xsl:with-param name="MenaCM" select="$MenaCM"/>
				<xsl:with-param name="Rezim" select="$Rezim"/>
				<xsl:with-param name="Znamenko" select="$Znamenko"/>
				<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
				<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
				<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
				<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<xsl:template match="Polozka">
<xsl:param name="TypPolozek"/>			<!--	0 = položky dokladu, 1 = odpočtové položky -->
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Rezim"/>
<xsl:param name="Znamenko"/>
<xsl:param name="IdZboziKupujici"/>
<xsl:param name="IdZboziProdejce1"/>
<xsl:param name="IdZboziProdejce2"/>
<xsl:param name="IdZboziProdejce3"/>

	<xsl:choose>
		<xsl:when test="$Rezim = 1">
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>		<!-- jinak transformace na formát ISDOC -->

			<xsl:choose>
				<xsl:when test="($TypPolozek = '0') and (SklPolozka/KmKarta/TypKarty = 'sada' )">	
					<!--	prochází sadu u normální faktury vydané -->
					<xsl:apply-templates select="SklPolozka/Slozeni/SubPolozka/Polozka">
						<xsl:with-param name="Poradi" select="position()"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
						<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
						<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
						<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
						<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
					</xsl:apply-templates>
				</xsl:when>
		
				<xsl:when test="($TypPolozek = '0') and (KmKarta/TypKarty = 'sada' )">	
					<!--	prochází sadu u zálohové faktury vydané -->
					<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
						<xsl:with-param name="Poradi" select="position()"/>
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
						<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
						<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
						<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
						<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
					</xsl:apply-templates>
				</xsl:when>
		
				<xsl:when test="($TypPolozek = '0') and ((not(NesklPolozka/Zaloha)) or (NesklPolozka/Zaloha != '1' ))">
					<!--	ostatní typy položek, které nejsou odpočtové -->
					<xsl:call-template name="Polozka_Obsah">
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
						<xsl:with-param name="Rezim" select="$Rezim"/>
						<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
						<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
						<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
						<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
					</xsl:call-template>
				</xsl:when>
		
				<xsl:when test="($TypPolozek = '1') and (NesklPolozka/Zaloha = '1' )">
					<!--	odpočtové položky v nenulové sazbě - odúčtování zdaněných zálohových listů -->
					<xsl:call-template name="Odpocet_Obsah">
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
					</xsl:call-template>
				</xsl:when>

				<xsl:when test="($TypPolozek = '2') and (NesklPolozka/Zaloha = '1' )">
					<!--	odpočtové položky v nulové sazbě - odúčtování nezdaněných zálohových listů -->
					<xsl:call-template name="OdpocetN_Obsah">
						<xsl:with-param name="MenaCM" select="$MenaCM"/>
						<xsl:with-param name="Znamenko" select="$Znamenko"/>
					</xsl:call-template>
				</xsl:when>

			</xsl:choose>

		</xsl:otherwise>
	</xsl:choose>

</xsl:template>



<!--	Průchod složených položek 
	- u faktury vydané jednoduché položky sady, které nemají žádnou nadřízenou položku typu komplet a dále položky typu komplet taktéž bez jiné nadřízené položky typu komplet  -->
<xsl:template match="Slozeni/SubPolozka/Polozka">
<xsl:param name="Poradi"/>
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Rezim"/>
											<!-- "" = generování položek ve formátu ISDOC
												1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions
											-->
<xsl:param name="Znamenko"/>	
<xsl:param name="IdZboziKupujici"/>
<xsl:param name="IdZboziProdejce1"/>
<xsl:param name="IdZboziProdejce2"/>
<xsl:param name="IdZboziProdejce3"/>

	<xsl:choose>
		<xsl:when test="$Rezim = 1">
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>		<!-- jinak transformace na formát ISDOC -->

			<!--	test jestli to není u faktury vydané položka typu sada -->
			<xsl:if test="(KmKarta/TypKarty != 'sada' ) ">
				<xsl:call-template name="Polozka_Obsah">
					<xsl:with-param name="Poradi">
						<xsl:value-of select="concat($Poradi,'-')"/>
					</xsl:with-param>
					<xsl:with-param name="MenaCM" select="$MenaCM"/>
					<xsl:with-param name="Znamenko" select="$Znamenko"/>
					<xsl:with-param name="Rezim" select="$Rezim"/>
					<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
					<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
					<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
					<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
				</xsl:call-template>
			</xsl:if>
		
			<!--	pokud je to faktura vydaná, kde převáděná položka není komplet, tak pokračuje dále do nižší úrovně -->
			<xsl:if test="(KmKarta/TypKarty != 'komplet' ) "> 	
				<xsl:apply-templates select="Slozeni/SubPolozka/Polozka">
					<xsl:with-param name="Poradi">
						<xsl:value-of select="concat($Poradi,'-',position())"/>
					</xsl:with-param>
					<xsl:with-param name="MenaCM" select="$MenaCM"/>
					<xsl:with-param name="Znamenko" select="$Znamenko"/>
					<xsl:with-param name="IdZboziKupujici" select="$IdZboziKupujici"/>
					<xsl:with-param name="IdZboziProdejce1" select="$IdZboziProdejce1"/>
					<xsl:with-param name="IdZboziProdejce2" select="$IdZboziProdejce2"/>
					<xsl:with-param name="IdZboziProdejce3" select="$IdZboziProdejce3"/>
				</xsl:apply-templates>
			</xsl:if>

		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!--	Tvorba položky -->
<xsl:template name="Polozka_Obsah">
<xsl:param name="Poradi"/>
<xsl:param name="Rezim"/>
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Znamenko"/>				<!--	znaménko pro celkové částky - v případě dobropisu se musí částky uvádět kladně, u vratek budou celkové částky záporné -->
<xsl:param name="Znamenko_PocetMJ">		<!--	znaménko pro množství - v případě vratky se bude uvádět záporně  -->
	<xsl:choose>
		<xsl:when test="(SklPolozka/Vratka = 1)">-1</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:param>
<xsl:param name="Znamenko_CenaMJ">		<!--	znaménko pro jednotkovou cenu - vždy bude uvedeno kladně  -->
	<xsl:choose>
		<!--	pokud je to vratka a současně to není dobropis NEBO to není vratka a současně je to dobropis, tak vynásobí jednotkovou cenu -1 -->
		<xsl:when test="((SklPolozka/Vratka = 1) and ($Znamenko = 1))
						or (((SklPolozka/Vratka = 0) or not(SklPolozka/Vratka)) and ($Znamenko = -1))">-1</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
	</xsl:choose>
</xsl:param>
<xsl:param name="IdZboziKupujici"/>
<xsl:param name="IdZboziProdejce1"/>
<xsl:param name="IdZboziProdejce2"/>
<xsl:param name="IdZboziProdejce3"/>

<xsl:param name="Vazba_PR_OB">		<!-- informace, zda se v seznamu vazeb vyskytuje objednávka -->
	<xsl:for-each select="SeznamVazeb/Vazba">
		<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'OP') "><xsl:value-of select="position()"/></xsl:if>
	</xsl:for-each>
</xsl:param>

<xsl:param name="Vazba_PR_DL">		<!-- informace, zda se v seznamu vazeb vyskytuje dodací list -->
	<xsl:for-each select="SeznamVazeb/Vazba">
		<xsl:if test="(Typ = 'PR') and (Doklad/Druh = 'DV') "><xsl:value-of select="position()"/></xsl:if>
	</xsl:for-each>
</xsl:param>


		<xsl:element name="InvoiceLine">
				<xsl:element name="ID"><xsl:value-of select="concat($Poradi,position())"/></xsl:element>

				<!-- vazba na položku objednávky (použije první nalezenou objednávku) -->
				<xsl:if test="string-length($Vazba_PR_OB) &gt; 0  ">
					<xsl:element name="OrderReference">
						<xsl:attribute name="ref">
							<xsl:value-of select="SeznamVazeb/Vazba[(Typ='PR') and (Doklad/Druh='OP')]/Doklad/Cislo"/>
						</xsl:attribute>
						<xsl:element name="LineID">
							<xsl:value-of select="SeznamVazeb/Vazba[(Typ='PR') and (Doklad/Druh='OP')]/Doklad/CisloPol"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
	
				<!-- vazba na položku dodacího listu (použije první nalezený dodací list) -->
				<xsl:if test="string-length($Vazba_PR_DL) &gt; 0  ">
					<xsl:element name="DeliveryNoteReference">
						<xsl:attribute name="ref">
							<xsl:value-of select="SeznamVazeb/Vazba[(Typ='PR') and (Doklad/Druh='DV')]/Doklad/Cislo"/>
						</xsl:attribute>
						<xsl:element name="LineID">
							<xsl:value-of select="SeznamVazeb/Vazba[(Typ='PR') and (Doklad/Druh='DV')]/Doklad/CisloPol"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>

				<xsl:element name="InvoicedQuantity">
						<xsl:if test="(NesklPolozka/MJ) or (SklPolozka/KmKarta/MJ) or (KmKarta/MJ)">
							<xsl:attribute name="unitCode">
								<xsl:value-of select="NesklPolozka/MJ"/>
								<xsl:value-of select="SklPolozka/KmKarta/MJ"/>
								<xsl:value-of select="KmKarta/MJ"/>
							</xsl:attribute>
						</xsl:if>
					<xsl:value-of select="(PocetMJ)*($Znamenko_PocetMJ)"/>
				</xsl:element>

				<xsl:if test="string-length($MenaCM) &gt; 0 ">
					<xsl:element name="LineExtensionAmountCurr"><xsl:value-of select="(SouhrnDPH/Valuty/Zaklad)*($Znamenko)"/></xsl:element>
				</xsl:if>
				<xsl:element name="LineExtensionAmount"><xsl:value-of select="(SouhrnDPH/Zaklad)*($Znamenko)"/></xsl:element>

				<xsl:if test="Sleva != 0 ">		<!--	Cena bez DPH v domácí měně před slevou -->
					<xsl:element name="LineExtensionAmountBeforeDiscount">
						<xsl:value-of select="format-number(100*(SouhrnDPH/Zaklad)div(100-Sleva)*($Znamenko),'#.##' )"/>
					</xsl:element>
				</xsl:if>

				<xsl:if test="string-length($MenaCM) &gt; 0 ">
					<xsl:element name="LineExtensionAmountTaxInclusiveCurr">
						<xsl:value-of select="(SouhrnDPH/Valuty/Zaklad+SouhrnDPH/Valuty/DPH)*($Znamenko)"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="LineExtensionAmountTaxInclusive">
					<xsl:value-of select="(SouhrnDPH/Zaklad+SouhrnDPH/DPH)*($Znamenko)"/>
				</xsl:element>

				<xsl:if test="Sleva != 0 ">	<!--	Cena s DPH v domácí měně před slevou -->
					<xsl:element name="LineExtensionAmountTaxInclusiveBeforeDiscount">
						<xsl:value-of select="format-number(100*(SouhrnDPH/Zaklad+SouhrnDPH/DPH)div(100-Sleva)*($Znamenko),'#.##' )"/>
					</xsl:element>
				</xsl:if>

				<xsl:element name="LineExtensionTaxAmount"><xsl:value-of select="(SouhrnDPH/DPH)*($Znamenko)"/></xsl:element>

				<xsl:element name="UnitPrice"><xsl:value-of select="(SouhrnDPH/Zaklad_MJ)*($Znamenko_CenaMJ)"/></xsl:element>
				<xsl:element name="UnitPriceTaxInclusive"><xsl:value-of select="(SouhrnDPH/Zaklad_MJ+SouhrnDPH/DPH_MJ)*($Znamenko_CenaMJ)"/></xsl:element>

				<xsl:element name="ClassifiedTaxCategory">
					<xsl:element name="Percent">
						<xsl:value-of select="SazbaDPH"/>
						<xsl:value-of select="DPH"/>
					</xsl:element>
					<xsl:element name="VATCalculationMethod">
						<xsl:choose>
							<xsl:when test="(CenaTyp = 1) or (TypCeny = 1) ">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				<!-- 	<xsl:element name="VATApplicable">	není nutné uvádět
						<xsl:choose>
							<xsl:when test="(SazbaDPH = 0) or (DPH = 0) ">false</xsl:when>
							<xsl:otherwise>true</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				-->
					<xsl:if test="(string-length(NesklPolozka/PredmPln) &gt; 0) or (string-length(SklPolozka/KmKarta/PredmPln) &gt; 0) or (string-length(KmKarta/PredmPln) &gt; 0)  ">
						<xsl:element name="LocalReverseCharge">
							<xsl:element name="LocalReverseChargeCode">
								<xsl:value-of select="NesklPolozka/PredmPln"/>
								<xsl:value-of select="SklPolozka/KmKarta/PredmPln"/>
								<xsl:value-of select="KmKarta/PredmPln"/>
							</xsl:element>
							<xsl:element name="LocalReverseChargeQuantity">
								<xsl:if test="(NesklPolozka/MJ) or (SklPolozka/KmKarta/MJ) or (KmKarta/MJ)">
									<xsl:attribute name="unitCode">
										<xsl:value-of select="NesklPolozka/MJ"/>
										<xsl:value-of select="SklPolozka/KmKarta/MJ"/>
										<xsl:value-of select="KmKarta/MJ"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="(PocetMJ)*($Znamenko_PocetMJ)"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:element>

				<xsl:if test="string-length(Poznamka) &gt; 0 ">
					<xsl:element name="Note">
						<xsl:attribute name="languageID">cs</xsl:attribute>
						<xsl:value-of select="Poznamka"/>
					</xsl:element>
				</xsl:if>

				<xsl:element name="Item">
						<xsl:element name="Description">
							<xsl:value-of select="concat(Popis,Nazev)"/>
						</xsl:element>

						<xsl:element name="CatalogueItemIdentification">
							<xsl:element name="ID">
								<xsl:call-template name="IdZbozi">
									<xsl:with-param name="Hodnota">3</xsl:with-param>	<!-- defaultní hodnota - čárový kód (3) -->
								</xsl:call-template>
							</xsl:element>
						</xsl:element>

						<xsl:element name="SellersItemIdentification">
							<xsl:element name="ID">
								<xsl:call-template name="IdZbozi">
									<xsl:with-param name="Hodnota" select="$IdZboziProdejce1"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>

						<xsl:element name="SecondarySellersItemIdentification">
							<xsl:element name="ID">
								<xsl:call-template name="IdZbozi">
									<xsl:with-param name="Hodnota" select="$IdZboziProdejce2"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>

						<xsl:element name="TertiarySellersItemIdentification">
							<xsl:element name="ID">
								<xsl:call-template name="IdZbozi">
									<xsl:with-param name="Hodnota" select="$IdZboziProdejce3"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>

						<xsl:element name="BuyersItemIdentification">
							<xsl:element name="ID">
								<xsl:call-template name="IdZbozi">
									<xsl:with-param name="Hodnota" select="$IdZboziKupujici"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>

						<!--	test, zda je na položce výrobní číslo - včetně podřízených položek -->
						<xsl:if test="(NesklPolozka/VyrobniCis) or (SklPolozka/SeznamVC) or (SeznamVC)">
							<xsl:element name="StoreBatches">
								<xsl:for-each select="NesklPolozka | SklPolozka/SeznamVC/VyrobniCislo | SeznamVC/VyrobniCislo">
									<xsl:element name="StoreBatch">
										<xsl:element name="Name"><xsl:value-of select="VyrobniCis"/></xsl:element>
										<xsl:element name="Note"/>
											<xsl:if test="string-length(DatExp) &gt; 0 ">
												<xsl:element name="ExpirationDate">
													<!-- Datum exspirace se použije z dodávky - NEŘEŠENO - seznam dodávek neexportujeme.
														Bude podporovaná pouze neskladová položka s výrobním číslem.
													<xsl:apply-templates select="../../SeznamDodavek/Dodavka">
														<xsl:with-param name="Poradi" select="position()"/>
														<xsl:with-param name="Rezim" select="$Rezim"/>
													</xsl:apply-templates>
													 -->
													<xsl:value-of select="DatExp"/>
												</xsl:element>
											</xsl:if>
										<xsl:element name="Specification"/>
										<xsl:element name="Quantity">1</xsl:element>
										<xsl:element name="BatchOrSerialNumber">S</xsl:element>
									</xsl:element>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
				</xsl:element>

		</xsl:element>
</xsl:template>

<!-- Plnění identifikátorů zboží dle nastavení -->
<xsl:template name="IdZbozi">
<xsl:param name="Hodnota"/>
<!-- 
Popis zboží			1
Katalog				2
Čárový kód			3
PLU				4
Zkratka				5
-->

	<xsl:choose>
		<xsl:when test="$Hodnota = 1">
			<xsl:value-of select="concat(Popis,Nazev)"/>
		</xsl:when>
		<xsl:when test="$Hodnota = 2">
			<xsl:value-of select="NesklPolozka/Katalog"/><xsl:value-of select="SklPolozka/KmKarta/Katalog"/><xsl:value-of select="KmKarta/Katalog"/>
		</xsl:when>
		<xsl:when test="$Hodnota = 3">
			<xsl:value-of select="NesklPolozka/BarCode"/><xsl:value-of select="SklPolozka/KmKarta/BarCode"/><xsl:value-of select="KmKarta/BarCode"/>
		</xsl:when>
		<xsl:when test="$Hodnota = 4">
			<xsl:value-of select="NesklPolozka/UzivCode"/><xsl:value-of select="SklPolozka/KmKarta/UzivCode"/><xsl:value-of select="KmKarta/UzivCode"/>
		</xsl:when>
		<xsl:when test="$Hodnota = 5">
			<xsl:value-of select="NesklPolozka/Zkrat"/><xsl:value-of select="SklPolozka/KmKarta/Zkrat"/><xsl:value-of select="KmKarta/Zkrat"/>
		</xsl:when>
	</xsl:choose>

</xsl:template>


<!-- Datum exspirace z odepisované dodávky podle pořadí výrobního čísla a počtu MJ dodávky s ohledem na počet MJ z předchozích dodávek.
NEŘEŠENO - seznam dodávek neexportujeme.
-->
<xsl:template match="SeznamDodavek/Dodavka">
<xsl:param name="Poradi"/>
<xsl:param name="Min" select="sum(preceding-sibling::*/PocetMJ)+1"/>
<xsl:param name="Max" select="sum(preceding-sibling::*/PocetMJ)+PocetMJ"/>
<xsl:param name="Rezim"/>		<!-- 	1 = jedná se o pouhé zkopírování původní struktury pro potřeby elementu Extensions -->

	<xsl:choose>
		<xsl:when test="$Rezim = 1">
				<xsl:call-template name="Kopiruj"/>
		</xsl:when>

		<xsl:otherwise>
			<xsl:if test="($Poradi &gt;= $Min) and ($Poradi &lt;= $Max)">
				<xsl:value-of select="DatExp"/>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>


<!--	Tvorba odpočtové položky v nenulové sazbě (odúčtování zdaněných zálohových listů) -->
<xsl:template name="Odpocet_Obsah">
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Znamenko"/>				<!--	znaménko - v případě normální faktury se musí částky uvádět kladně -->

	<xsl:if test="SazbaDPH != 0 ">

		<xsl:element name="TaxedDeposit">
			<xsl:element name="ID"><xsl:value-of select="SeznamVazeb/Vazba[Typ = 'ZL' ]/Doklad/Cislo"/></xsl:element>
			<xsl:element name="VariableSymbol"><xsl:value-of select="SeznamVazeb/Vazba[Typ = 'ZL' ]/Doklad/VarSymbol"/></xsl:element>
	
			<xsl:if test="string-length($MenaCM) &gt; 0 ">
				<xsl:element name="TaxableDepositAmountCurr"><xsl:value-of select="(SouhrnDPH/Valuty/Zaklad)*($Znamenko)"/></xsl:element>
			</xsl:if>
			<xsl:element name="TaxableDepositAmount"><xsl:value-of select="(SouhrnDPH/Zaklad)*($Znamenko)"/></xsl:element>
			<xsl:if test="string-length($MenaCM) &gt; 0 ">
				<xsl:element name="TaxInclusiveDepositAmountCurr">
					<xsl:value-of select="(SouhrnDPH/Valuty/Zaklad+SouhrnDPH/Valuty/DPH)*($Znamenko)"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="TaxInclusiveDepositAmount">
				<xsl:value-of select="(SouhrnDPH/Zaklad+SouhrnDPH/DPH)*($Znamenko)"/>
			</xsl:element>
	
			<xsl:element name="ClassifiedTaxCategory">
				<xsl:element name="Percent">
					<xsl:value-of select="SazbaDPH"/>
				</xsl:element>
				<xsl:element name="VATCalculationMethod">
					<xsl:choose>
						<xsl:when test="CenaTyp = 1 ">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			<!-- 	<xsl:element name="VATApplicable"> 	není nutné uvádět
					<xsl:choose>
						<xsl:when test="SazbaDPH = 0 ">false</xsl:when>
						<xsl:otherwise>true</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			-->
				<xsl:if test="(string-length(NesklPolozka/PredmPln) &gt; 0) ">
					<xsl:element name="LocalReverseCharge">
						<xsl:element name="LocalReverseChargeCode">
							<xsl:value-of select="NesklPolozka/PredmPln"/>
						</xsl:element>
						<xsl:element name="LocalReverseChargeQuantity">
							<xsl:if test="(NesklPolozka/MJ)">
								<xsl:attribute name="unitCode">
									<xsl:value-of select="NesklPolozka/MJ"/>
								</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="PocetMJ"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>


			</xsl:element>
		</xsl:element>

	</xsl:if>

</xsl:template>

<!--	Tvorba odpočtové položky v nulové sazbě (odúčtování nezdaněných zálohových listů) -->
<xsl:template name="OdpocetN_Obsah">
<xsl:param name="MenaCM"/>				<!--	informace, zda je doklad v cizí měně -->
<xsl:param name="Znamenko"/>				<!--	znaménko - v případě normální faktury se musí částky uvádět kladně -->

	<xsl:if test="SazbaDPH = 0 ">

		<xsl:element name="NonTaxedDeposit">
			<xsl:element name="ID"><xsl:value-of select="SeznamVazeb/Vazba[Typ = 'ZL' ]/Doklad/Cislo"/></xsl:element>
			<xsl:element name="VariableSymbol"><xsl:value-of select="SeznamVazeb/Vazba[Typ = 'ZL' ]/Doklad/VarSymbol"/></xsl:element>
			<xsl:if test="string-length($MenaCM) &gt; 0 ">
				<xsl:element name="DepositAmountCurr">
					<xsl:value-of select="(SouhrnDPH/Valuty/Zaklad+SouhrnDPH/Valuty/DPH)*($Znamenko)"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="DepositAmount">
				<xsl:value-of select="(SouhrnDPH/Zaklad+SouhrnDPH/DPH)*($Znamenko)"/>
			</xsl:element>
		</xsl:element>
	</xsl:if>

</xsl:template>


<!-- SEZNAM POLOŽEK - KONEC -->


<!-- FAKTURA BEZ POLOŽEK - GENEROVÁNÍ POLOŽEK -->

	<xsl:template name="BezPolozek">
	<xsl:param name="Razeni"/>
	<xsl:param name="MenaCM"/>
	<xsl:param name="Znamenko"/>				<!--	znaménko - v případě dobropisu se musí částky uvádět kladně -->

			<!-- Generování položek v jednotlivých sazbách -->
			<xsl:choose>
				<!-- Vzestupné řazení -->
				<xsl:when test="$Razeni = 1">
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="ascending" data-type="number"/>
						<xsl:call-template name="GenerPolozka">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>

				<!-- Sestupné řazení -->
				<xsl:otherwise>
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="descending" data-type="number"/>
						<xsl:call-template name="GenerPolozka">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

	</xsl:template>


<!-- Generování položek v sazbách DPH -->

	<xsl:template name="GenerPolozka">
	<xsl:param name="MenaCM"/>
	<xsl:param name="Znamenko"/>

		<xsl:variable name="Sazba"><xsl:value-of select="Sazba"/></xsl:variable>

		<xsl:variable name="Zaklad_DM"><xsl:value-of select="Zaklad"/></xsl:variable>
		<xsl:variable name="DPH_DM"><xsl:value-of select="DPH"/></xsl:variable>

		<xsl:variable name="Zaklad_CM">
			<xsl:value-of select="../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/Zaklad"/>
		</xsl:variable>
		<xsl:variable name="DPH_CM"><xsl:value-of select="../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/DPH"/></xsl:variable>

		<!-- koeficient DPH pro výpočet DPH metodou shora  -->
		<xsl:variable name="Koeficient_DPH"><xsl:value-of select="format-number(($Sazba)div(100+$Sazba),'0.####' )"/>
		</xsl:variable>

		<!-- DPH v DM vypočítané metodou shora -->
		<xsl:variable name="Vypocet_DPH_DM_Shora"><xsl:value-of select="format-number(($Zaklad_DM+$DPH_DM)*($Koeficient_DPH),'#.##' )"/>
		</xsl:variable>

		<!-- DPH v CM vypočítané metodou shora -->
		<xsl:variable name="Vypocet_DPH_CM_Shora"><xsl:value-of select="format-number(($Zaklad_CM+$DPH_CM)*($Koeficient_DPH),'#.##' )"/>
		</xsl:variable>

				<!-- některá z částek základu nebo DPH v DM je různá od nuly
					nebo v případě cizí měny je některá z částek základu nebo DPH v CM různá  od nuly -->
				<xsl:if test="($Zaklad_DM != 0) or ($DPH_DM != 0)
							or ((string-length($MenaCM) &gt; 0) and (($Zaklad_CM != 0) or ($DPH_CM != 0)))">


				<xsl:element name="InvoiceLine">
						<xsl:element name="ID"><xsl:value-of select="concat('S-',$Sazba)"/></xsl:element>
		
						<xsl:element name="InvoicedQuantity">0</xsl:element>
		
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="LineExtensionAmountCurr"><xsl:value-of select="($Zaklad_CM)*($Znamenko)"/></xsl:element>
						</xsl:if>
						<xsl:element name="LineExtensionAmount"><xsl:value-of select="($Zaklad_DM)*($Znamenko)"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="LineExtensionAmountTaxInclusiveCurr"><xsl:value-of select="($Zaklad_CM+$DPH_CM)*($Znamenko)"/></xsl:element>
						</xsl:if>
						<xsl:element name="LineExtensionAmountTaxInclusive"><xsl:value-of select="($Zaklad_DM+$DPH_DM)*($Znamenko)"/></xsl:element>
						<xsl:element name="LineExtensionTaxAmount"><xsl:value-of select="($DPH_DM)*($Znamenko)"/></xsl:element>
						<xsl:element name="UnitPrice">0</xsl:element>
						<xsl:element name="UnitPriceTaxInclusive">0</xsl:element>
		
						<xsl:element name="ClassifiedTaxCategory">
							<xsl:element name="Percent"><xsl:value-of select="$Sazba"/></xsl:element>
							<xsl:element name="VATCalculationMethod">
								<xsl:choose>
									<xsl:when test="string-length($MenaCM) &gt; 0 ">	<!-- doklad v cizí měně -->
										<xsl:choose>
								<!-- pokud je DPH vypočítané v transformační šabloně metodu shora shodné s částkou DPH v XML datech, tak se použije typ ceny "s DPH" -->
											<xsl:when test="$Vypocet_DPH_CM_Shora = $DPH_CM ">1</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>									<!-- doklad v domácí měně -->
										<xsl:choose>
											<xsl:when test="$Vypocet_DPH_DM_Shora = $DPH_DM ">1</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:element>
						<xsl:element name="Item">
								<xsl:element name="Description">
									<xsl:value-of select="concat('Položka v sazbě ',$Sazba,' %')"/>
								</xsl:element>
						</xsl:element>
			</xsl:element>

		</xsl:if>


	</xsl:template>

<!-- FAKTURA BEZ POLOŽEK - KONEC -->


<!-- PRVNÍ POLOŽKA S POPISEM DOKLADU  -->

	<xsl:template name="PolozkaPopisDokladu">
	<xsl:param name="MenaCM"/>

		<xsl:element name="InvoiceLine">
				<xsl:element name="ID">P-1</xsl:element>

				<xsl:element name="InvoicedQuantity">0</xsl:element>

				<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="LineExtensionAmountCurr">0</xsl:element></xsl:if>
				<xsl:element name="LineExtensionAmount">0</xsl:element>
				<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="LineExtensionAmountTaxInclusiveCurr">0</xsl:element></xsl:if>
				<xsl:element name="LineExtensionAmountTaxInclusive">0</xsl:element>
				<xsl:element name="LineExtensionTaxAmount">0</xsl:element>
				<xsl:element name="UnitPrice">0</xsl:element>
				<xsl:element name="UnitPriceTaxInclusive">0</xsl:element>

				<xsl:element name="ClassifiedTaxCategory">
					<xsl:element name="Percent">0</xsl:element>
					<xsl:element name="VATCalculationMethod">1</xsl:element>
				</xsl:element>
				<xsl:element name="Item">
					<xsl:element name="Description"><xsl:value-of select="Popis"/></xsl:element>
				</xsl:element>

		</xsl:element>

	</xsl:template>

<!-- PRVNÍ POLOŽKA S POPISEM DOKLADU - KONEC -->


<!-- ZAOKROUHLOVACÍ POLOŽKY -->

	<xsl:template name="ZaokPolozky">
		<xsl:param name="Razeni"/>
		<xsl:param name="MenaCM"/>
		<xsl:param name="Znamenko"/>				<!--	znaménko - v případě dobropisu se musí částky uvádět kladně -->
	
			<!-- Generování položek v jednotlivých sazbách -->
			<xsl:choose>
				<!-- Vzestupné řazení -->
				<xsl:when test="$Razeni = 1">
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="ascending" data-type="number"/>
						<xsl:call-template name="GenerZaokrPolozka">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>

				<!-- Sestupné řazení -->
				<xsl:otherwise>
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="descending" data-type="number"/>
						<xsl:call-template name="GenerZaokrPolozka">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

	</xsl:template>


<!-- Generování zaokrouhlovacích položek v jednotlivých sazbách -->

	<xsl:template name="GenerZaokrPolozka">
	<xsl:param name="MenaCM"/>
	<xsl:param name="Znamenko"/>

				<xsl:variable name="Sazba"><xsl:value-of select="Sazba"/></xsl:variable>

				<!-- Suma základního plnění z položek -->
				<xsl:variable name="ZP_Zaklad_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Zaklad)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ZP_Zaklad_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Valuty/Zaklad)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Valuty/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ZP_DPH_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/DPH)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/DPH)"/>
				</xsl:variable>

				<xsl:variable name="ZP_DPH_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Valuty/DPH)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Valuty/DPH)"/>
				</xsl:variable>

				<!-- Suma odpočtů z položek -->
				<xsl:variable name="ODP_Zaklad_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ODP_DPH_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/DPH)"/>
				</xsl:variable>

				<xsl:variable name="ODP_Zaklad_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ODP_DPH_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/DPH)"/>
				</xsl:variable>

				<!-- Suma základního plnění z hlavičky dokladu (je včetně zaokrouhlení a korekce) -->
				<xsl:variable name="Zaklad_DM"><xsl:value-of select="(Zaklad)-($ODP_Zaklad_DM)"/></xsl:variable>
				<xsl:variable name="Zaklad_CM">
					<xsl:value-of select="(../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/Zaklad)-($ODP_Zaklad_CM)"/>
				</xsl:variable>

				<xsl:variable name="DPH_DM"><xsl:value-of select="(DPH)-($ODP_DPH_DM)"/></xsl:variable>
				<xsl:variable name="DPH_CM"><xsl:value-of select="(../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/DPH)-($ODP_DPH_CM)"/></xsl:variable>

				<!-- Rozdíl mezi základním plněním z hlavičky a základním plněním z položek -->
				<xsl:variable name="R_Zaklad_DM">
					<xsl:value-of select="format-number(($Zaklad_DM)-($ZP_Zaklad_DM),'0.##' )"/>
				</xsl:variable>
				<xsl:variable name="R_DPH_DM">
					<xsl:value-of select="format-number(($DPH_DM)-($ZP_DPH_DM),'0.##' )"/>
				</xsl:variable>
				<xsl:variable name="R_Zaklad_CM">
					<xsl:value-of select="format-number(($Zaklad_CM)-($ZP_Zaklad_CM),'0.##' )"/>
				</xsl:variable>
				<xsl:variable name="R_DPH_CM">
					<xsl:value-of select="format-number(($DPH_CM)-($ZP_DPH_CM),'0.##' )"/>
				</xsl:variable>

				<!-- některá z rozdílových částek základu nebo DPH v DM je různá od nuly
					nebo v případě cizí měny je některá z částek základu nebo DPH v CM různá  od nuly -->
				<xsl:if test="($R_Zaklad_DM != 0) or ($R_DPH_DM != 0)
							or ((string-length($MenaCM) &gt; 0) and (($R_Zaklad_CM != 0) or ($R_DPH_CM != 0)))">

					<xsl:element name="InvoiceLine">
							<xsl:element name="ID"><xsl:value-of select="concat('Z-',$Sazba)"/></xsl:element>

							<xsl:element name="InvoicedQuantity">0</xsl:element>

							<xsl:if test="string-length($MenaCM) &gt; 0 ">
								<xsl:element name="LineExtensionAmountCurr"><xsl:value-of select="($R_Zaklad_CM)*($Znamenko)"/></xsl:element>
							</xsl:if>
							<xsl:element name="LineExtensionAmount"><xsl:value-of select="($R_Zaklad_DM)*($Znamenko)"/></xsl:element>
							<xsl:if test="string-length($MenaCM) &gt; 0 ">
								<xsl:element name="LineExtensionAmountTaxInclusiveCurr"><xsl:value-of select="($R_Zaklad_CM+$R_DPH_CM)*($Znamenko)"/></xsl:element>
							</xsl:if>
							<xsl:element name="LineExtensionAmountTaxInclusive"><xsl:value-of select="($R_Zaklad_DM+$R_DPH_DM)*($Znamenko)"/></xsl:element>
							<xsl:element name="LineExtensionTaxAmount"><xsl:value-of select="($R_DPH_DM)*($Znamenko)"/></xsl:element>
							<xsl:element name="UnitPrice">0</xsl:element>
							<xsl:element name="UnitPriceTaxInclusive">0</xsl:element>

							<xsl:element name="ClassifiedTaxCategory">
								<xsl:element name="Percent"><xsl:value-of select="$Sazba"/></xsl:element>
								<xsl:element name="VATCalculationMethod">0</xsl:element>
							</xsl:element>

							<xsl:element name="Item">
									<xsl:element name="Description">
										<xsl:value-of select="concat('Zaokrouhlení v sazbě ',$Sazba,' %')"/>
									</xsl:element>
							</xsl:element>

					</xsl:element>
				</xsl:if>

	</xsl:template>


<!-- ZAOKROUHLOVACÍ POLOŽKY - KONEC -->


<!-- DAŇOVÁ REKAPITULACE -->
	<xsl:template name="DanovaRekapitulace">
	<xsl:param name="Razeni"/>
	<xsl:param name="MenaCM"/>
	<xsl:param name="Znamenko"/>
	<xsl:param name="Odpocet"/>			<!-- informace, zda se jedná o vyúčtovací fakturu
										 	Základní plnění a Odpočty se počítá z položek, výsledné plnění se počítá z částek v hlavičce stejně
										 	jako u ostatních faktur.

										 	Sazba se uvádí pouze v případě, že existuje alespoň jedna položka s touto sazbou.
										 	 -->

			<!-- Počet sazeb DPH -->
			<xsl:variable name="Pocet" select="count(SouhrnDPH/SeznamDalsiSazby/DalsiSazba)"/>
			
			<!-- Nejvyšší sazba DPH (bude poslední v seznamu) -->
			<xsl:variable name="NejSazba" select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba[position()=$Pocet]/Sazba"/>

			<!-- Daň v jednotlivých sazbách -->
			<xsl:choose>
				<!-- Vzestupné řazení -->
				<xsl:when test="$Razeni = 1">
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="ascending" data-type="number"/>
						<xsl:call-template name="SazbaDPH">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Odpocet" select="$Odpocet"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
							<xsl:with-param name="NejSazba" select="$NejSazba"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:when>

				<!-- Sestupné řazení -->
				<xsl:otherwise>
					<xsl:for-each select="SouhrnDPH/SeznamDalsiSazby/DalsiSazba">
						<xsl:sort select="Sazba" order="descending" data-type="number"/>
						<xsl:call-template name="SazbaDPH">
							<xsl:with-param name="MenaCM" select="$MenaCM"/>
							<xsl:with-param name="Odpocet" select="$Odpocet"/>
							<xsl:with-param name="Znamenko" select="$Znamenko"/>
							<xsl:with-param name="NejSazba" select="$NejSazba"/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

			<!-- Celková daň za doklad -->
			<xsl:if test="string-length($MenaCM) &gt; 0 ">
				<xsl:element name="TaxAmountCurr">
					<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)*($Znamenko)"/>
				</xsl:element>
			</xsl:if>

			<xsl:element name="TaxAmount">
				<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)*($Znamenko)"/>
			</xsl:element>

	</xsl:template>



	<!-- SAZBA DPH -->
	<xsl:template name="SazbaDPH">
		<xsl:param name="MenaCM"/>
		<xsl:param name="Odpocet"/>
		<xsl:param name="Znamenko"/>
		<xsl:param name="NejSazba"/>

				<xsl:variable name="Sazba"><xsl:value-of select="Sazba"/></xsl:variable>

				<!-- Základní plnění (z položek) -->

				<!-- Popis algoritmu:
				prohledává položky normálních i zálohových faktur do libovolné hloubky, k čemuž slouží dvojité lomítko. V hranaté závorce je predikát (podmínka na vyhodnocování položek).
				Hodnota elementu SazbaDPH nebo DPH musí být rovna zpracovávané sazbě a současně musí být splněna jedna z těchto podmínek:
				1) typ karty je různý od sady a současně nesmí platit, že některý z předků aktuální položky (viz zápis ancestor::* kde hvězdička představuje aktuální položku) je komplet. Pro vyhodnocení všech předků je uveden v hranaté závorce další predikát. V rámci této podmínky se nejprve provádí test na existenci elementu SklPolozka/KmKarta/TypKarty (toplevel předek) nebo elementu KmKarta/TypKarty (ostatní předci) s následným vyhodnocením typu karty.
				2) jedná se o toplevel položku (nemá již žádného předka), kde SklPolozka/KmKarta/TypKarty je různá od sady
				3) jedná se o neskladovou položku a současně u normálních faktur element Zaloha je různý od 1 (není to odpočtová položka)
				Za predikátem položky následuje podřízený element SouhrnDPH/Zaklad, ze kterého čte hodnotu a provádí její sumaci.
				U zálohových faktur je zápis jednodušší v tom, že odpadá element SklPolozka.
				-->

				<xsl:variable name="ZP_Zaklad_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Zaklad)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ZP_Zaklad_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Valuty/Zaklad)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Valuty/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ZP_DPH_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/DPH)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/DPH)"/>
				</xsl:variable>

				<xsl:variable name="ZP_DPH_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1)) )]/SouhrnDPH/Valuty/DPH)
								+ sum(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))]/SouhrnDPH/Valuty/DPH)"/>
				</xsl:variable>

				<!-- Suma odpočtů s nenulovou sazbou (z položek) - prochází položky pouze normálních faktur -->
				<xsl:variable name="ODP_Zaklad_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ODP_DPH_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/DPH)"/>
				</xsl:variable>

				<xsl:variable name="ODP_Zaklad_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ODP_DPH_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/DPH)"/>
				</xsl:variable>

				<!-- Suma odpočtů s nulovou sazbou (z položek) - prochází položky pouze normálních faktur -->
				<xsl:variable name="ODP0_DM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH = 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Zaklad)"/>
				</xsl:variable>

				<xsl:variable name="ODP0_CM">
					<xsl:value-of select="sum(../../../SeznamPolozek//Polozka[(SazbaDPH=$Sazba) and (SazbaDPH = 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/Zaklad)"/>
				</xsl:variable>


				<!-- Výsledné plnění - počítá se z hlavičky dokladu (je včetně zaokrouhlení a korekce) - nulové odpočty nejsou součástí výsledného plnění -->
				<xsl:variable name="Zaklad_DM"><xsl:value-of select="(Zaklad) - ($ODP0_DM)"/></xsl:variable>
				<xsl:variable name="Zaklad_CM">
					<xsl:value-of select="(../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/Zaklad) - ($ODP0_CM)"/>
				</xsl:variable>

				<xsl:variable name="DPH_DM"><xsl:value-of select="DPH"/></xsl:variable>
				<xsl:variable name="DPH_CM"><xsl:value-of select="../../../Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba[Sazba=$Sazba]/DPH"/></xsl:variable>


				<!-- počet položek s výskytem sazby, které ovlivňují cenový panel dokladu -->

				<!-- Popis algoritmu:
				prohledává položky normálních i zálohových faktur do libovolné hloubky, k čemuž slouží dvojité lomítko. V hranaté závorce je predikát (podmínka na vyhodnocování položek).
				Hodnota elementu SazbaDPH nebo DPH musí být rovna zpracovávané sazbě a současně musí být splněna jedna z těchto podmínek:
				1) typ karty je různý od sady a současně nesmí platit, že některý z předků aktuální položky (viz zápis ancestor::* kde hvězdička představuje aktuální položku) je komplet. Pro vyhodnocení všech předků je uveden v hranaté závorce další predikát. V rámci této podmínky se nejprve provádí test na existenci elementu SklPolozka/KmKarta/TypKarty (toplevel předek) nebo elementu KmKarta/TypKarty (ostatní předci) s následným vyhodnocením typu karty.
				2) jedná se o toplevel položku (nemá již žádného předka), kde SklPolozka/KmKarta/TypKarty je různá od sady
				3) jedná se o neskladovou položku a současně nesmí to být odpočtová položka v nulové sazbě
				U zálohových faktur je zápis jednodušší v tom, že odpadá element SklPolozka.
				-->
				<xsl:variable name="SazbaVyskytPolozek">
					<xsl:value-of select="count(../../../SeznamPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
								or (SklPolozka/KmKarta/TypKarty != 'sada')
								or ((NesklPolozka) and not((NesklPolozka/Zaloha = 1) and (SazbaDPH = 0)))		)])
								+ count(../../../SeznamZalPolozek//Polozka[((SazbaDPH=$Sazba) or (DPH=$Sazba))
								and (((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka))])"/>
 				</xsl:variable>

				<xsl:variable name="PocetPolozek">
					<xsl:value-of select="count(../../../SeznamPolozek/Polozka) + count(../../../SeznamZalPolozek/Polozka)"/>
 				</xsl:variable>


				<!-- (počet položek s danou sazbou, které ovlivňují cenový panel dokladu, je větší než nula
						nebo některá z částek základu nebo DPH v DM je různá od nuly
						nebo v případě dokladu v cizí měně je některá z částek základu nebo DPH v CM různá od nuly
					 	nebo počet položek je nulový a současně na dokladu v cizí měně je celková částka dokladu rovna nule a aktuálně zpracovávaná sazba je nejvyšší sazbou
					 	nebo počet položek je nulový a současně na dokladu v domácí měně je celková částka dokladu rovna nule a aktuálně zpracovávaná sazba je nejvyšší sazbou
					 	 -->
				<xsl:if test="($SazbaVyskytPolozek &gt; 0)
								or (($Zaklad_DM != 0) or ($DPH_DM != 0))
								or ((string-length($MenaCM) &gt; 0) and (($Zaklad_CM != 0) or ($DPH_CM != 0)))
							 	or (($PocetPolozek = 0) and (string-length($MenaCM) &gt; 0) and (../../../Valuty/Celkem = 0) and ($Sazba = $NejSazba))
							 	or (($PocetPolozek = 0) and (../../../Celkem = 0) and ($Sazba = $NejSazba))
							 	">

					<xsl:element name="TaxSubTotal">

<!-- Jelikož daňová rekapitulace za doklad musí být vždy rovna součtu cen z položek (InvoiceLines), tak základní plnění se vypočítá jako rozdíl mezi výsledným plněním a odpočty. Pokud bude existovat rozdíl mezi vypočítaným základním plněním a součtem cen z položek, tak se vygeneruje zaokrouhlovací položka. Proměnné pro výpočet základního plnění z položek, které jsou uvedeny výše, se nepoužijí. Součet odpočtů a výsledné plnění neobsahují odpočtové položky v nulové sazbě. -->

						<!-- základní plnění  -->
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="TaxableAmountCurr">
								<xsl:value-of select="format-number((($Zaklad_CM)-($ODP_Zaklad_CM))*($Znamenko),'0.##' )"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="TaxableAmount"><xsl:value-of select="format-number((($Zaklad_DM)-($ODP_Zaklad_DM))*($Znamenko),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="TaxAmountCurr"><xsl:value-of select="format-number((($DPH_CM)-($ODP_DPH_CM))*($Znamenko),'0.##' )"/></xsl:element>
						</xsl:if>
						<xsl:element name="TaxAmount"><xsl:value-of select="format-number((($DPH_DM)-($ODP_DPH_DM))*($Znamenko),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="TaxInclusiveAmountCurr">
								<xsl:value-of select="format-number((($Zaklad_CM)+($DPH_CM)-($ODP_Zaklad_CM)-($ODP_DPH_CM))*($Znamenko),'0.##' )"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="TaxInclusiveAmount">
							<xsl:value-of select="format-number((($Zaklad_DM)+($DPH_DM)-($ODP_Zaklad_DM)-($ODP_DPH_DM))*($Znamenko),'0.##' )"/>
						</xsl:element>

						<!-- odpočtové částky se v ISDOCU uvádí kladně -->
						<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="AlreadyClaimedTaxableAmountCurr">
							<xsl:value-of select="format-number(($ODP_Zaklad_CM)*($Znamenko)*(-1),'0.##' )"/></xsl:element></xsl:if>
						<xsl:element name="AlreadyClaimedTaxableAmount"><xsl:value-of select="format-number(($ODP_Zaklad_DM)*($Znamenko)*(-1),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="AlreadyClaimedTaxAmountCurr">
							<xsl:value-of select="format-number(($ODP_DPH_CM)*($Znamenko)*(-1),'0.##' )"/></xsl:element></xsl:if>
						<xsl:element name="AlreadyClaimedTaxAmount"><xsl:value-of select="format-number(($ODP_DPH_DM)*($Znamenko)*(-1),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="AlreadyClaimedTaxInclusiveAmountCurr">
							<xsl:value-of select="format-number(($ODP_Zaklad_CM+$ODP_DPH_CM)*($Znamenko)*(-1),'0.##' )"/></xsl:element></xsl:if>
						<xsl:element name="AlreadyClaimedTaxInclusiveAmount">
							<xsl:value-of select="format-number(($ODP_Zaklad_DM+$ODP_DPH_DM)*($Znamenko)*(-1),'0.##' )"/>
						</xsl:element>

						<!-- výsledné plnění z hlavičky (včetně korekce a zaokrouhlení) -->
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="DifferenceTaxableAmountCurr"><xsl:value-of select="format-number(($Zaklad_CM)*($Znamenko),'0.##' )"/></xsl:element>
						</xsl:if>
						<xsl:element name="DifferenceTaxableAmount"><xsl:value-of select="format-number(($Zaklad_DM)*($Znamenko),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 ">
							<xsl:element name="DifferenceTaxAmountCurr"><xsl:value-of select="format-number(($DPH_CM)*($Znamenko),'0.##' )"/></xsl:element>
						</xsl:if>
						<xsl:element name="DifferenceTaxAmount"><xsl:value-of select="format-number(($DPH_DM)*($Znamenko),'0.##' )"/></xsl:element>
						<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="DifferenceTaxInclusiveAmountCurr">
								<xsl:value-of select="format-number(($Zaklad_CM+$DPH_CM)*($Znamenko),'0.##' )"/></xsl:element></xsl:if>
						<xsl:element name="DifferenceTaxInclusiveAmount"><xsl:value-of select="format-number(($Zaklad_DM+$DPH_DM)*($Znamenko),'0.##' )"/></xsl:element>

						<xsl:element name="TaxCategory">
							<xsl:element name="Percent"><xsl:value-of select="$Sazba"/></xsl:element>
						</xsl:element>

					</xsl:element>

				</xsl:if>	

	</xsl:template>


<!-- DAŇOVÁ REKAPITULACE - KONEC -->



<!-- CELKOVÁ  REKAPITULACE -->
	<xsl:template name="CelkovaRekapitulace">
	<xsl:param name="MenaCM"/>
	<xsl:param name="Odpocet"/>			<!-- informace, zda se jedná o vyúčtovací fakturu -->
	<xsl:param name="Znamenko"/>

	<!-- Základní plnění (z položek) za všechny sazby DPH -->

	<xsl:variable name="ZP_Zaklad_DM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
					or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1))]/SouhrnDPH/Zaklad)
					+ sum(SeznamZalPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka)]/SouhrnDPH/Zaklad)"/>
	</xsl:variable>

	<xsl:variable name="ZP_Zaklad_CM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
					or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1))]/SouhrnDPH/Valuty/Zaklad)
					+ sum(SeznamZalPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka)]/SouhrnDPH/Valuty/Zaklad)"/>
	</xsl:variable>

	<xsl:variable name="ZP_DPH_DM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
					or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1))]/SouhrnDPH/DPH)
					+ sum(SeznamZalPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka)]/SouhrnDPH/DPH)"/>
	</xsl:variable>

	<xsl:variable name="ZP_DPH_CM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[((SklPolozka/KmKarta/TypKarty) and (SklPolozka/KmKarta/TypKarty = 'komplet')) or ((KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet'))]))
					or (SklPolozka/KmKarta/TypKarty != 'sada') or ((NesklPolozka) and (NesklPolozka/Zaloha != 1))]/SouhrnDPH/Valuty/DPH)
					+ sum(SeznamZalPolozek//Polozka[((KmKarta/TypKarty != 'sada') and not(ancestor::*[(KmKarta/TypKarty) and (KmKarta/TypKarty = 'komplet')])) or (NesklPolozka)]/SouhrnDPH/Valuty/DPH)"/>
	</xsl:variable>


	<!-- Odpočty v nenulové sazbě (z položek) za všechny sazby DPH (zdaněné zálohové listy) - prochází položky pouze normálních faktur -->
	<xsl:variable name="ODP_Zaklad_DM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Zaklad)"/>
	</xsl:variable>

	<xsl:variable name="ODP_DPH_DM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/DPH)"/>
	</xsl:variable>

	<xsl:variable name="ODP_Zaklad_CM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/Zaklad)"/>
	</xsl:variable>

	<xsl:variable name="ODP_DPH_CM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH != 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/DPH)"/>
	</xsl:variable>

	<!-- Odpočty v nulové sazbě (nezdaněné zálohové listy) - prochází položky pouze normálních faktur -->
	<xsl:variable name="ODP0_DM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH = 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Zaklad)"/>
	</xsl:variable>

	<xsl:variable name="ODP0_CM">
		<xsl:value-of select="sum(SeznamPolozek//Polozka[(SazbaDPH = 0) and (NesklPolozka/Zaloha = 1)]/SouhrnDPH/Valuty/Zaklad)"/>
	</xsl:variable>

	<!-- Výsledné plnění - počítá se z hlavičky dokladu (je včetně zaokrouhlení a korekce) - nulové odpočty nejsou součástí výsledného plnění -->
	<xsl:variable name="Zaklad_DM">
			<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad) - ($ODP0_DM)"/>
	</xsl:variable>

	<xsl:variable name="Zaklad_CM">
			<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/Zaklad) - ($ODP0_CM)"/>
	</xsl:variable>

	<xsl:variable name="DPH_DM">
			<xsl:value-of select="sum(SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>
	</xsl:variable>

	<xsl:variable name="DPH_CM">
			<xsl:value-of select="sum(Valuty/SouhrnDPH/SeznamDalsiSazby/DalsiSazba/DPH)"/>
	</xsl:variable>


<!-- Jelikož celková rekapitulace za doklad musí být vždy rovna součtu cen z položek (InvoiceLines), tak základní plnění se vypočítá jako rozdíl mezi výsledným plněním a odpočty. Pokud bude existovat rozdíl mezi vypočítaným základním plněním a součtem cen z položek, tak se vygeneruje zaokrouhlovací položka. Proměnné pro výpočet základního plnění z položek, které jsou uvedeny výše, se nepoužijí. Součet odpočtů a výsledné plnění neobsahují odpočtové položky v nulové sazbě. -->

		<!-- základní plnění -->
		<xsl:element name="TaxExclusiveAmount"><xsl:value-of select="format-number((($Zaklad_DM)-($ODP_Zaklad_DM))*($Znamenko),'0.##' )"/></xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="TaxExclusiveAmountCurr"><xsl:value-of select="format-number((($Zaklad_CM)-($ODP_Zaklad_CM))*($Znamenko),'0.##' )"/></xsl:element>
		</xsl:if>
		<xsl:element name="TaxInclusiveAmount">
			<xsl:value-of select="format-number((($Zaklad_DM)+($DPH_DM)-($ODP_Zaklad_DM)-($ODP_DPH_DM))*($Znamenko),'0.##' )"/>
		</xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="TaxInclusiveAmountCurr">
				<xsl:value-of select="format-number((($Zaklad_CM)+($DPH_CM)-($ODP_Zaklad_CM)-($ODP_DPH_CM))*($Znamenko),'0.##' )"/>
			</xsl:element>
		</xsl:if>

		<!-- odpočtové částky se v ISDOCU uvádí kladně -->
		<xsl:element name="AlreadyClaimedTaxExclusiveAmount"><xsl:value-of select="format-number(($ODP_Zaklad_DM)*($Znamenko)*(-1),'0.##' )"/></xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="AlreadyClaimedTaxExclusiveAmountCurr"><xsl:value-of select="format-number(($ODP_Zaklad_CM)*($Znamenko)*(-1),'0.##' )"/></xsl:element>
		</xsl:if>
		<xsl:element name="AlreadyClaimedTaxInclusiveAmount">
			<xsl:value-of select="format-number(($ODP_Zaklad_DM+$ODP_DPH_DM)*($Znamenko)*(-1),'0.##' )"/>
		</xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="AlreadyClaimedTaxInclusiveAmountCurr">
				<xsl:value-of select="format-number(($ODP_Zaklad_CM+$ODP_DPH_CM)*($Znamenko)*(-1),'0.##' )"/>
			</xsl:element>
		</xsl:if>

		<!-- výsledné plnění z hlavičky (včetně korekce a zaokrouhlení) - nulové odpočty nejsou součástí výsledného plnění -->	
		<xsl:element name="DifferenceTaxExclusiveAmount"><xsl:value-of select="format-number(($Zaklad_DM)*($Znamenko),'0.##' )"/></xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="DifferenceTaxExclusiveAmountCurr"><xsl:value-of select="format-number(($Zaklad_CM)*($Znamenko),'0.##' )"/></xsl:element>
		</xsl:if>
		<xsl:element name="DifferenceTaxInclusiveAmount"><xsl:value-of select="format-number(($Zaklad_DM+$DPH_DM)*($Znamenko),'0.##' )"/></xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 ">
			<xsl:element name="DifferenceTaxInclusiveAmountCurr"><xsl:value-of select="format-number(($Zaklad_CM+$DPH_CM)*($Znamenko),'0.##' )"/></xsl:element>
		</xsl:if>
	
		<!-- ZAOKROUHLENÍ - celkové zaokrouhlení dokladu bude vždy nulové (zaokrouhlení za jednotlivé sazby bude uvedeno jako samostatná položka dokladu -->
		<xsl:element name="PayableRoundingAmount">0</xsl:element>
		<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="PayableRoundingAmountCurr">0</xsl:element></xsl:if>

		<!-- 
		PaidDepositsAmount - u daňových dokladů k přijaté platbě rovno DepositAmount ze seznamu NonTaxedDeposits, což odpovídá hodnotě elementu "Celkem", u ostatních faktur rovno sumě odpočtů v nulové sazbě.
		PayableAmount - částka k úhradě (budeme plnit elementem Celkem), údaj zbývá uhradit (element Proplatit) je ponížená o úhrady a v ISDOCU se neuvádí. U daňových dokladů k přijaté platbě rovno nule.
		-->
		<xsl:choose>
			<xsl:when test="Druh = 'D' ">			<!-- daňový doklad k přijaté platbě -->
				<xsl:element name="PaidDepositsAmount"><xsl:value-of select="(Celkem)*($Znamenko)"/></xsl:element>
				<xsl:if test="string-length($MenaCM) &gt; 0 ">
					<xsl:element name="PaidDepositsAmountCurr"><xsl:value-of select="(Valuty/Celkem)*($Znamenko)"/></xsl:element>
				</xsl:if>
				<xsl:element name="PayableAmount">0</xsl:element>
				<xsl:if test="string-length($MenaCM) &gt; 0 "><xsl:element name="PayableAmountCurr">0</xsl:element></xsl:if>
			</xsl:when>

			<xsl:otherwise>							<!-- ostatní faktury -->
													<!-- odpočtové částky se v ISDOCU uvádí kladně -->
				<xsl:element name="PaidDepositsAmount"><xsl:value-of select="($ODP0_DM)*($Znamenko)*(-1)"/></xsl:element>
				<xsl:if test="string-length($MenaCM) &gt; 0 ">
					<xsl:element name="PaidDepositsAmountCurr"><xsl:value-of select="($ODP0_CM)*($Znamenko)*(-1)"/></xsl:element>
				</xsl:if>
				<xsl:element name="PayableAmount"><xsl:value-of select="(Celkem)*($Znamenko)"/></xsl:element>
				<xsl:if test="string-length($MenaCM) &gt; 0 ">
					<xsl:element name="PayableAmountCurr"><xsl:value-of select="(Valuty/Celkem)*($Znamenko)"/></xsl:element>
				</xsl:if>
			</xsl:otherwise>

		</xsl:choose>

	</xsl:template>
	
<!-- CELKOVÁ  REKAPITULACE - KONEC -->


<!-- KOPÍROVÁNÍ STRUKTURY MONEY S3 POD ELEMENT EXTENSIONS -->
<xsl:template match="node()" name="Kopiruj">

	<xsl:element name="money:{name()}" namespace="http://www.money.cz">
		<xsl:apply-templates select="*|@*|text()" >
			<xsl:with-param name="Rezim" select="1"/>		<!-- při kopírování nesmí provádět transformaci na formát ISDOC (viz šablony template match) -->
		</xsl:apply-templates>
	</xsl:element>

</xsl:template>

<xsl:template match="@*">
	<xsl:attribute name="money:{name()}">
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>

<xsl:template match="text()">
	<xsl:value-of select="."/>
</xsl:template>

<!-- KOPÍROVÁNÍ STRUKTURY MONEY S3 - KONEC -->

</xsl:stylesheet>
