<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2008 sp1 (http://www.altova.com) by Dusan Pesko (CIGLER SOFTWARE, a.s.) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:root="http://schemas.datacontract.org/2004/07/Doklad.Api.ResultModels.Wrappers" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d2p1="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.IssuedInvoice" xmlns:dobr="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.CreditNote" xmlns:faktprij="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.ReceivedInvoice" xmlns:prodej="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.SalesReceipt" xmlns:zasoba="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels" xmlns:id="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.BaseModels" xmlns:d4p1="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels" xmlns:d4p1X="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.ReadOnlyEntites" xmlns:d5p1="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.ReadOnlyEntites" xmlns:d6p1="http://schemas.microsoft.com/2003/10/Serialization/Arrays" exclude-result-prefixes="root">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- Transformační šablona na import dat z iDokladu do Money S3 verzia 20.300.1
	  Autor: Marek Vykydal
	-->
	<xsl:template match="/*">
		<xsl:element name="MoneyData">
			<xsl:choose>
				<xsl:when test="(root:Data/d2p1:IssuedInvoiceApiModelExpand) or (root:Data/dobr:CreditNoteApiModelExpand) or (root:Data/d2p1:IssuedInvoiceApiModel) or (root:Data/dobr:CreditNoteApiModel)">
					<!-- faktury vydané -->
					<xsl:element name="SeznamFaktVyd">
						<xsl:choose>
							<xsl:when test="root:Data/d2p1:IssuedInvoiceApiModel | root:Data/d2p1:IssuedInvoiceApiModelExpand">
								<!-- normální faktury -->
								<xsl:apply-templates select="root:Data/d2p1:IssuedInvoiceApiModel | root:Data/d2p1:IssuedInvoiceApiModelExpand">
									<!-- ID agendy - do vstupních XML dat doplňuje program Money jako atribut kořenového elementu -->
									<xsl:with-param name="iDokladAgend" select="@iDokladAgend"/>
									<xsl:with-param name="iDokladSklPol" select="@iDokladSklPol"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:otherwise>
								<!-- dobropisy -->
								<xsl:apply-templates select="root:Data/dobr:CreditNoteApiModel | root:Data/dobr:CreditNoteApiModelExpand">
									<!-- Příznak, že se jedná o dobropis -->
									<xsl:with-param name="Dobropis" select="1"/>
									<!-- ID agendy - do vstupních XML dat doplňuje program Money jako atribut kořenového elementu -->
									<xsl:with-param name="iDokladAgend" select="@iDokladAgend"/>
									<xsl:with-param name="iDokladSklPol" select="@iDokladSklPol"/>
								</xsl:apply-templates>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:when>
				<xsl:when test="root:Data/faktprij:ReceivedInvoiceApiModel | root:Data/faktprij:ReceivedInvoiceApiModelExpand">
					<!-- faktury přjaté -->
					<xsl:element name="SeznamFaktPrij">
						<xsl:apply-templates select="root:Data/faktprij:ReceivedInvoiceApiModel | root:Data/faktprij:ReceivedInvoiceApiModelExpand">
							<!-- ID agendy - do vstupních XML dat doplňuje program Money jako atribut kořenového elementu -->
							<xsl:with-param name="iDokladAgend" select="@iDokladAgend"/>
							<xsl:with-param name="iDokladSklPol" select="@iDokladSklPol"/>
						</xsl:apply-templates>
					</xsl:element>
				</xsl:when>
				<xsl:when test="root:Data/prodej:SalesReceiptApiModel | root:Data/prodej:SalesReceiptApiModelExpand">
					<!-- prodejky -->
					<xsl:element name="SeznamProdejka">
						<xsl:apply-templates select="root:Data/prodej:SalesReceiptApiModel | root:Data/prodej:SalesReceiptApiModelExpand">
							<xsl:with-param name="iDokladAgend" select="@iDokladAgend"/>
							<xsl:with-param name="iDokladSluzba" select="@iDokladSluzba"/>
							<xsl:with-param name="iDokladSluzbaSklad" select="@iDokladSluzbaSklad"/>
							<xsl:with-param name="iDokladPlatidlo" select="@iDokladPlatidlo"/>
						</xsl:apply-templates>
					</xsl:element>
				</xsl:when>
				<xsl:when test="root:Data/zasoba:PriceListApiModel | root:Data/zasoba:PriceListApiModelExpand">
					<!-- zásoby -->
					<xsl:element name="SeznamZasoba">
						<xsl:apply-templates select="root:Data/zasoba:PriceListApiModel | root:Data/zasoba:PriceListApiModelExpand">
							<xsl:with-param name="iDokladAgend" select="@iDokladAgend"/>
							<xsl:with-param name="iDokladSazbaDPH_SS" select="@iDokladSazbaDPH_SS"/>
							<xsl:with-param name="iDokladSazbaDPH_ZS" select="@iDokladSazbaDPH_ZS"/>
							<xsl:with-param name="iDokladSazbaDPH_3" select="@iDokladSazbaDPH_3"/>
						</xsl:apply-templates>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<!-- FAKTURA VYDANÁ -->
	<xsl:template match="d2p1:IssuedInvoiceApiModel | dobr:CreditNoteApiModel | d2p1:IssuedInvoiceApiModelExpand | dobr:CreditNoteApiModelExpand">
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSklPol"/>
		<xsl:param name="Dobropis"/>
		<xsl:param name="MenaDokladu" select="d2p1:Currency/d4p1X:Code | dobr:Currency/d4p1X:Code"/>
		<!-- Test, zda faktura z iDokladu existuje v Money S3 (porovnává se uživatelské číslo dokladu) -->
		<xsl:variable name="Doklad" select="d2p1:DocumentNumber"/>
		<xsl:variable name="DokladExist">
			<xsl:for-each select="../../root:ReferenceDoklad/root:Doklad">
				<xsl:if test=".=$Doklad">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda faktura z iDokladu je již v Money S3 hrazena -->
		<xsl:variable name="DokladUhrada">
			<xsl:for-each select="../../root:ReferenceDoklad/root:Doklad">
				<xsl:if test="(.=$Doklad) and (@Uhrada=1)">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda faktura obsahuje alespoň jednu ceníkovou položku, pro kterou existuje související zásoba v Money S3 -->
		<xsl:variable name="ZasobaExist">
			<xsl:for-each select="d2p1:IssuedInvoiceItems/d4p1:IssuedInvoiceItemApiModel | dobr:CreditNoteItems/dobr:CreditNoteItemApiModel">
				<xsl:variable name="Polozka" select="d4p1:PriceListItemId"/>
				<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
					<xsl:if test="$Polozka = root:iDoklPol">1</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="FaktVyd">
			<!-- Pokud již bude faktura v Money S3 existovat a současně (již bude v Money S3 hrazena nebo bude obsahovat skladové položky a současně bude existovat požadavek na import skladových položek), tak se neprovede
					její import a pouze se zapíše nemožnost importu tohoto dokladu do Reportu - viz element Import -->
			<xsl:if test="(string-length($DokladExist) &gt; 0) and ((string-length($DokladUhrada) &gt; 0) or ((string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)))">
				<xsl:element name="Import">
					<xsl:attribute name="Exported">1</xsl:attribute>
					<xsl:element name="Status">FatalError</xsl:element>
					<xsl:element name="Reference">
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Číslo dokladu</xsl:attribute>
						</xsl:element>
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Doklad</xsl:attribute>
							<xsl:value-of select="d2p1:DocumentNumber"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ErrorInfo">
						<xsl:element name="ErrorTypeCoded">BusinessError</xsl:element>
						<xsl:element name="ErrorTypeOther"/>
						<xsl:element name="ErrorCode">
							<xsl:choose>
								<xsl:when test="(string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)">-99901</xsl:when>
								<xsl:otherwise>-99902</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="ErrorDescription">
							<xsl:choose>
								<xsl:when test="(string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)">
									<xsl:value-of select="concat('Faktúru vystavenú č.', d2p1:DocumentNumber, ' nie je možné naimportovať, pretože obsahuje skladové položky a po exporte do Money S3 bola zmenená. Zmenené faktúry sa importujú iba v prípade, ak obsahujú neskladové položky a v programe Money S3 neboli doteraz hradené. Program Vás informuje o zmenených faktúrach, ktoré nie je možné importovať iba jedenkrát.')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('Faktúru vystavenú č.', d2p1:DocumentNumber, ' nie je možné naimportovať, pretože bola po exporte do Money S3 zmenená a zároveň je už hradená. Zmenené faktúry sa importujú iba v prípade, ak obsahujú neskladové položky a v programe Money S3 neboli doteraz hradené. Program vás informuje o zmenených faktúrach, ktoré nie je možné importovať iba jedenkrát.')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Doklad">
				<xsl:value-of select="d2p1:DocumentNumber"/>
			</xsl:element>
			<xsl:element name="iDokladID">
				<xsl:value-of select="id:Id"/>
			</xsl:element>
			<xsl:element name="iDoklAgend">
				<xsl:value-of select="$iDokladAgend"/>
			</xsl:element>
			<xsl:element name="Popis">
				<xsl:value-of select="d2p1:Description"/>
			</xsl:element>
			<xsl:element name="Druh">N</xsl:element>
			<xsl:if test="$Dobropis = 1">
				<!-- Dobropis -->
				<xsl:element name="Dobropis">1</xsl:element>
				<xsl:element name="ParSymbol">
					<xsl:value-of select="@VariableSymbolSource"/>
				</xsl:element>
				<xsl:element name="PuvDoklad">
					<xsl:value-of select="@DocumentNumberSource"/>
				</xsl:element>
			</xsl:if>
			<!--
				<xsl:element name="ZpDopravy">
					<xsl:value-of select="d2p1:Note"/>
				</xsl:element>
			-->
			<xsl:element name="VarSymbol">
				<xsl:value-of select="d2p1:VariableSymbol"/>
			</xsl:element>
			<xsl:element name="TextPredFa">
				<xsl:value-of select="d2p1:ItemsTextPrefix"/>
			</xsl:element>
			<xsl:element name="TextZaFa">
				<xsl:value-of select="d2p1:ItemsTextSuffix"/>
			</xsl:element>
			<xsl:element name="Vystaveno">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="d2p1:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="CObjednavk">
				<xsl:value-of select="d2p1:OrderNumber"/>
			</xsl:element>
			<!--
					<xsl:element name="DatUcPr">
						<xsl:call-template name="_datum_">
							<xsl:with-param name="_datum"><xsl:value-of select="d2p1:DateOfIssue"/></xsl:with-param>
						</xsl:call-template>
					</xsl:element>
			 -->
			<xsl:element name="PlnenoDPH">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="d2p1:DateOfTaxing"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="Splatno">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="d2p1:DateOfMaturity"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:if test="d2p1:PaymentStatus=1 ">
				<xsl:element name="Uhrazeno">
					<xsl:call-template name="_datum_">
						<xsl:with-param name="_datum">
							<xsl:value-of select="d2p1:DateOfPayment"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
			<xsl:element name="KonstSym">
				<xsl:value-of select="d2p1:ConstantSymbol/d4p1X:Code | dobr:ConstantSymbol/d4p1X:Code "/>
			</xsl:element>
			<xsl:variable name="Uhrada">
				<xsl:call-template name="ZpusobUhrady">
					<xsl:with-param name="Uhrada">
						<xsl:value-of select="d2p1:PaymentOption/d4p1X:Name | dobr:PaymentOption/d4p1X:Name"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:element name="Uhrada">
				<xsl:value-of select="$Uhrada"/>
			</xsl:element>
			<!--osobitny režim uplatnovania dph po prijati platby / neplni sa datum vstupu do dph a nastavuje sa rezim zaplatenim-->
			<xsl:choose>
				<xsl:when test="d2p1:VatOnPayStatus=0 and $Dobropis != 1">
					<xsl:element name="Doruceno">
						<xsl:call-template name="_datum_">
							<xsl:with-param name="_datum">
								<xsl:value-of select="d2p1:DateOfTaxing"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:when test="d2p1:VatOnPayStatus=0 and $Dobropis = 1">
					<xsl:element name="Doruceno">
						<xsl:call-template name="_datum_">
							<xsl:with-param name="_datum">
								<xsl:value-of select="d2p1:DateOfIssue"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
			<xsl:element name="PlnenDPH">
				<xsl:choose>
					<xsl:when test="d2p1:VatOnPayStatus !=0">
						<xsl:text>2</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:if test="d2p1:VatRateReduced1 != '0.0000' ">
				<xsl:element name="SazbaDPH1">
					<xsl:value-of select="d2p1:VatRateReduced1"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="d2p1:VatRateBasic != '0.0000' ">
				<xsl:element name="SazbaDPH2">
					<xsl:value-of select="d2p1:VatRateBasic"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="SouhrnDPH">
				<xsl:element name="Zaklad0">
					<xsl:value-of select="d2p1:BaseTaxZeroRateHc"/>
				</xsl:element>
				<xsl:element name="Zaklad5">
					<xsl:value-of select="d2p1:BaseTaxReducedRate1Hc"/>
				</xsl:element>
				<xsl:element name="Zaklad22">
					<xsl:value-of select="d2p1:BaseTaxBasicRateHc"/>
				</xsl:element>
				<xsl:element name="DPH5">
					<xsl:value-of select="d2p1:TaxReducedRate1Hc"/>
				</xsl:element>
				<xsl:element name="DPH22">
					<xsl:value-of select="d2p1:TaxBasicRateHc"/>
				</xsl:element>
				<xsl:if test="d2p1:VatRateReduced2 != '0.0000' ">
					<xsl:element name="SeznamDalsiSazby">
						<xsl:element name="DalsiSazba">
							<xsl:element name="HladinaDPH">1	</xsl:element>
							<xsl:element name="Sazba">
								<xsl:value-of select="d2p1:VatRateReduced2"/>
							</xsl:element>
							<xsl:element name="Zaklad">
								<xsl:value-of select="d2p1:BaseTaxReducedRate2Hc"/>
							</xsl:element>
							<xsl:element name="DPH">
								<xsl:value-of select="d2p1:TaxReducedRate2Hc"/>
							</xsl:element>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:element>
			<xsl:element name="Celkem">
				<xsl:value-of select="d2p1:TotalWithVatHc"/>
			</xsl:element>
			<xsl:element name="Proplatit">
				<xsl:choose>
					<xsl:when test="d2p1:PaymentStatus != 1 ">
						<xsl:value-of select="d2p1:TotalWithVatHc"/>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="SumZaloha">0</xsl:element>
			<xsl:if test="$MenaDokladu!='EUR' ">
				<!-- Měna dokladu je různá od EUR -->
				<xsl:element name="Valuty">
					<xsl:element name="Mena">
						<xsl:element name="Kod">
							<xsl:value-of select="$MenaDokladu"/>
						</xsl:element>
						<xsl:element name="Kurs">
							<xsl:value-of select="concat('-',d2p1:ExchangeRateAmount)"/>
						</xsl:element>
						<xsl:element name="Mnozstvi">
							<xsl:value-of select="d2p1:ExchangeRate"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="SouhrnDPH">
						<xsl:element name="Zaklad0">
							<xsl:value-of select="d2p1:BaseTaxZeroRate"/>
						</xsl:element>
						<xsl:element name="Zaklad5">
							<xsl:value-of select="d2p1:BaseTaxReducedRate1"/>
						</xsl:element>
						<xsl:element name="Zaklad22">
							<xsl:value-of select="d2p1:BaseTaxBasicRate"/>
						</xsl:element>
						<xsl:element name="DPH5">
							<xsl:value-of select="d2p1:TaxReducedRate1"/>
						</xsl:element>
						<xsl:element name="DPH22">
							<xsl:value-of select="d2p1:TaxBasicRate"/>
						</xsl:element>
						<xsl:if test="d2p1:VatRateReduced2 != '0.0000' ">
							<xsl:element name="SeznamDalsiSazby">
								<xsl:element name="DalsiSazba">
									<xsl:element name="HladinaDPH">1	</xsl:element>
									<xsl:element name="Sazba">
										<xsl:value-of select="d2p1:VatRateReduced2"/>
									</xsl:element>
									<xsl:element name="Zaklad">
										<xsl:value-of select="d2p1:BaseTaxReducedRate2"/>
									</xsl:element>
									<xsl:element name="DPH">
										<xsl:value-of select="d2p1:TaxReducedRate2"/>
									</xsl:element>
								</xsl:element>
							</xsl:element>
						</xsl:if>
					</xsl:element>
					<xsl:element name="Celkem">
						<xsl:value-of select="d2p1:TotalWithVat"/>
					</xsl:element>
				</xsl:element>
				<xsl:element name="ValutyProp">
					<xsl:choose>
						<xsl:when test="d2p1:PaymentStatus != 1 ">
							<xsl:value-of select="d2p1:TotalWithVat"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="SumZalohaC">0</xsl:element>
			</xsl:if>
			<!-- Odběratel -->
			<xsl:element name="DodOdb">
				<xsl:call-template name="DodOdb"/>
			</xsl:element>
			<!-- Moje firma -->
			<xsl:element name="MojeFirma">
				<xsl:call-template name="MojeFirma"/>
			</xsl:element>
			<!-- seznam položek -->
			<xsl:element name="SeznamPolozek">
				<xsl:apply-templates select="d2p1:IssuedInvoiceItems/d4p1:IssuedInvoiceItemApiModel | dobr:CreditNoteItems/dobr:CreditNoteItemApiModel">
					<xsl:with-param name="MenaDokladu" select="$MenaDokladu"/>
					<xsl:with-param name="iDokladAgend" select="$iDokladAgend"/>
					<xsl:with-param name="iDokladSklPol" select="$iDokladSklPol"/>
					<xsl:with-param name="Pocet" select="count(d2p1:IssuedInvoiceItems/d4p1:IssuedInvoiceItemApiModel)
																+count(dobr:CreditNoteItems/dobr:CreditNoteItemApiModel)"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!-- FAKTURA PŘIJATÁ -->
	<xsl:template match="faktprij:ReceivedInvoiceApiModel | faktprij:ReceivedInvoiceApiModelExpand">
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSklPol"/>
		<xsl:param name="Dobropis"/>
		<xsl:param name="MenaDokladu" select="faktprij:Currency/d4p1X:Code"/>
		<!-- Test, zda faktura z iDokladu existuje v Money S3 (porovnává se uživatelské číslo dokladu) -->
		<xsl:variable name="Doklad" select="faktprij:DocumentNumber"/>
		<xsl:variable name="DokladExist">
			<xsl:for-each select="../../root:ReferenceDoklad/root:Doklad">
				<xsl:if test=".=$Doklad">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda faktura z iDokladu je již v Money S3 hrazena -->
		<xsl:variable name="DokladUhrada">
			<xsl:for-each select="../../root:ReferenceDoklad/root:Doklad">
				<xsl:if test="(.=$Doklad) and (@Uhrada=1)">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda faktura obsahuje alespoň jednu ceníkovou položku, pro kterou existuje související zásoba v Money S3 -->
		<xsl:variable name="ZasobaExist">
			<xsl:for-each select="faktprij:Items/faktprij:ReceivedInvoiceItemApiModel">
				<xsl:variable name="Polozka" select="faktprij:PriceListItemId"/>
				<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
					<xsl:if test="$Polozka = root:iDoklPol">1</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="FaktPrij">
			<!-- Pokud již bude faktura v Money S3 existovat a současně (již bude v Money S3 hrazena nebo bude obsahovat skladové položky a současně bude existovat požadavek na import skladových položek), tak se neprovede
					její import a pouze se zapíše nemožnost importu tohoto dokladu do Reportu - viz element Import -->
			<xsl:if test="(string-length($DokladExist) &gt; 0) and ((string-length($DokladUhrada) &gt; 0) or ((string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)))">
				<xsl:element name="Import">
					<xsl:attribute name="Exported">1</xsl:attribute>
					<xsl:element name="Status">FatalError</xsl:element>
					<xsl:element name="Reference">
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Číslo dokladu</xsl:attribute>
						</xsl:element>
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Doklad</xsl:attribute>
							<xsl:value-of select="faktprij:DocumentNumber"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ErrorInfo">
						<xsl:element name="ErrorTypeCoded">BusinessError</xsl:element>
						<xsl:element name="ErrorTypeOther"/>
						<xsl:element name="ErrorCode">
							<xsl:choose>
								<xsl:when test="(string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)">-99901</xsl:when>
								<xsl:otherwise>-99902</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="ErrorDescription">
							<xsl:choose>
								<xsl:when test="(string-length($ZasobaExist) &gt; 0) and ($iDokladSklPol = 1)">
									<xsl:value-of select="concat('Faktúru prijatú č.', faktprij:DocumentNumber, ' nie je možné naimportovať, pretože obsahuje skladové položky a po exporte do Money S3 bola zmenená. Zmenené faktúry sa importujú iba v prípade, ak obsahujú neskladové položky a v programe Money S3 neboli doteraz hradené. Program vás informuje o zmenených faktúrach, ktoré nie je možné importovať iba jedenkrát')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('Faktúru prijatú č.', faktprij:DocumentNumber, ' nie je možné naimportovať, pretože bola po exporte do Money S3 zmenená a zároveň je už hradená. Zmenené faktúry sa importujú iba v prípade, ak obsahujú neskladové položky a v programe Money S3 neboli doteraz hradené. Program vás informuje o zmenených faktúrach, ktoré nie je možné importovať iba jedenkrát.')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Doklad">
				<xsl:value-of select="faktprij:DocumentNumber"/>
			</xsl:element>
			<xsl:element name="iDokladID">
				<xsl:value-of select="id:Id"/>
			</xsl:element>
			<xsl:element name="iDoklAgend">
				<xsl:value-of select="$iDokladAgend"/>
			</xsl:element>
			<xsl:element name="Popis">
				<xsl:value-of select="faktprij:Description"/>
			</xsl:element>
			<xsl:element name="Druh">N</xsl:element>
			<xsl:element name="PrijatDokl">
				<xsl:value-of select="faktprij:ReceivedDocumentNumber"/>
			</xsl:element>
			<xsl:element name="VarSymbol">
				<xsl:value-of select="faktprij:VariableSymbol"/>
			</xsl:element>
			<xsl:element name="Poznamka">
				<xsl:value-of select="faktprij:Note"/>
			</xsl:element>
			<xsl:element name="Vystaveno">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="faktprij:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="PlnenoDPH">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="faktprij:DateOfTaxing"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="PlnenDPH">
				<xsl:choose>
					<xsl:when test="faktprij:VatOnPayStatus !=0">
						<xsl:text>2</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="Splatno">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="faktprij:DateOfMaturity"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:if test="faktprij:PaymentStatus=1 ">
				<xsl:element name="Uhrazeno">
					<xsl:call-template name="_datum_">
						<xsl:with-param name="_datum">
							<xsl:value-of select="faktprij:DateOfPayment"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Uhrada">
				<xsl:call-template name="ZpusobUhrady">
					<xsl:with-param name="Uhrada">
						<xsl:value-of select="faktprij:PaymentOption/d4p1X:Name"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:variable name="SazbaMax" select="30"/>
			<!-- Maximální podporovaná sazba při generování rozpisu sazeb DPH -->
			<xsl:if test="count(faktprij:Items) &gt; 0">
				<xsl:element name="SouhrnDPH">
					<xsl:element name="SeznamDalsiSazby">
						<xsl:call-template name="SazbyDPH">
							<xsl:with-param name="Pocitadlo" select="0"/>
							<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Celkem">
				<xsl:value-of select="faktprij:TotalWithVatHc"/>
			</xsl:element>
			<xsl:element name="Proplatit">
				<xsl:choose>
					<xsl:when test="faktprij:PaymentStatus != 1 ">
						<xsl:value-of select="faktprij:TotalPaidHc"/>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="SumZaloha">0</xsl:element>
			<xsl:if test="$MenaDokladu!='EUR' ">
				<!-- Měna dokladu je různá od EUR -->
				<xsl:element name="Valuty">
					<xsl:element name="Mena">
						<xsl:element name="Kod">
							<xsl:value-of select="$MenaDokladu"/>
						</xsl:element>
						<xsl:element name="Kurs">
							<xsl:value-of select="concat('-',faktprij:ExchangeRateAmount)"/>
						</xsl:element>
						<xsl:element name="Mnozstvi">
							<xsl:value-of select="faktprij:ExchangeRate"/>
						</xsl:element>
					</xsl:element>
					<xsl:if test="count(faktprij:Items) &gt; 0">
						<xsl:element name="SouhrnDPH">
							<xsl:element name="SeznamDalsiSazby">
								<xsl:call-template name="SazbyDPH">
									<xsl:with-param name="Pocitadlo" select="0"/>
									<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
									<xsl:with-param name="CiziMena" select="1"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="Celkem">
						<xsl:value-of select="faktprij:TotalWithVat"/>
					</xsl:element>
				</xsl:element>
				<xsl:element name="ValutyProp">
					<xsl:choose>
						<xsl:when test="faktprij:PaymentStatus != 1 ">
							<xsl:value-of select="faktprij:TotalPaid"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="SumZalohaC">0</xsl:element>
			</xsl:if>
			<!-- Dodavatel -->
			<xsl:element name="DodOdb">
				<xsl:call-template name="DodOdb"/>
			</xsl:element>
			<!-- Moje firma -->
			<xsl:element name="MojeFirma">
				<xsl:call-template name="MojeFirma"/>
			</xsl:element>
			<!-- seznam položek -->
			<xsl:element name="SeznamPolozek">
				<xsl:apply-templates select="faktprij:Items/faktprij:ReceivedInvoiceItemApiModel">
					<xsl:with-param name="MenaDokladu" select="$MenaDokladu"/>
					<xsl:with-param name="iDokladAgend" select="$iDokladAgend"/>
					<xsl:with-param name="iDokladSklPol" select="$iDokladSklPol"/>
				</xsl:apply-templates>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<!-- Položka faktury -->
	<xsl:template match="d4p1:IssuedInvoiceItemApiModel | dobr:CreditNoteItemApiModel | faktprij:ReceivedInvoiceItemApiModel">
		<xsl:param name="MenaDokladu"/>
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSklPol"/>
		<xsl:param name="Pocet"/>
		<!-- počet položek -->
		<xsl:if test="((d4p1:ItemType!='1') or (faktprij:ItemType!='1')) and ((d4p1:Amount !=0) or (faktprij:Amount !=0))">
			<!-- neimportuje se zaokrouhlovací položka  a položka s nulovým množstvom-->
			<xsl:element name="Polozka">
				<!--	<xsl:element name="Poradi"><xsl:value-of select="d4p1:Rank | d4p1:Rank"/></xsl:element> -->
				<xsl:element name="Popis">
					<xsl:value-of select="d4p1:Name | faktprij:Name"/>
				</xsl:element>
				<xsl:element name="PocetMJ">
					<!--Pokud je počet MJ záporný, násobí se -1 aby byl kladný. U skladových položek se navíc přidá element vratka. Ceny přichází už záporné, ty řešit 				nemusíme -->
					<xsl:choose>
						<xsl:when test="(d4p1:Amount &lt; 0) or (faktprij:Amount &lt; 0)">
							<xsl:choose>
								<xsl:when test="string-length(d4p1:Amount)>0">
									<xsl:value-of select="d4p1:Amount * -1"/>
								</xsl:when>
								<xsl:when test="string-length(faktprij:Amount)>0">
									<xsl:value-of select="faktprij:Amount * -1"/>
								</xsl:when>
								<xsl:otherwise>
									0
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="d4p1:Amount | faktprij:Amount "/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="SazbaDPH">
					<xsl:value-of select="d4p1:VatRate | faktprij:VatRate"/>
				</xsl:element>
				<xsl:element name="CenaTyp">
					<xsl:choose>
						<xsl:when test="(d4p1:PriceType='0') or (faktprij:PriceType='0')">1</xsl:when>
						<!-- s DPH -->
						<xsl:when test="(d4p1:PriceType='1') or (faktprij:PriceType='1')">0</xsl:when>
						<!-- bez DPH -->
						<xsl:when test="(d4p1:PriceType='2') or (faktprij:PriceType='2')">3</xsl:when>
						<!-- jen základ -->
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="Cena">
					<!--Vydělení celkové částky položky s daní v domácí měně celkovým počtem MJ položky a zaokrouhlení na 4 desetinná místa.
						Funkce "Round" zaokrouhluje na nejbližší celé číslo, proto dochází nejprve k vynásobení 10000 a po zaokrouhlení k následnému dělení 10000.
						Výpočet z celkové ceny položky se musí dělat proto, že idkolad nevrací jednotkovou cenu u PF a vratek VF-->
					<xsl:choose>
						<!-- Výpočet ceny v DM když je počet MJ záporný (vratka).-10000 se násobí aby vyšla záporná cena. -->
						<xsl:when test="(d4p1:Amount &lt; 0) or (faktprij:Amount &lt; 0)">
							<xsl:choose>
								<!-- Typ ceny je s DPH -->
								<xsl:when test="(d4p1:PriceType='0') or (faktprij:PriceType='0') ">
									<!-- Vystavené faktury -->
									<xsl:if test="string-length(d4p1:PriceTotalWithVatHc)>0">
										<xsl:value-of select="round((d4p1:PriceTotalWithVatHc div d4p1:Amount) * -10000) div 10000"/>
									</xsl:if>
									<!-- Přijaté faktury -->
									<xsl:if test="string-length(faktprij:PriceTotalWithVatHc)>0">
										<xsl:value-of select="round((faktprij:PriceTotalWithVatHc div faktprij:Amount) * -10000) div 10000"/>
									</xsl:if>
								</xsl:when>
								<!-- Typ ceny je bez DPH nebo jen základ-->
								<xsl:otherwise>
									<!-- Vystavené faktury -->
									<xsl:if test="string-length(d4p1:PriceTotalWithoutVatHc)>0">
										<xsl:value-of select="round((d4p1:PriceTotalWithoutVatHc div d4p1:Amount) * -10000) div 10000"/>
									</xsl:if>
									<!-- Přijaté faktury -->
									<xsl:if test="string-length(faktprij:PriceTotalWithoutVatHc)>0">
										<xsl:value-of select="round((faktprij:PriceTotalWithoutVatHc div faktprij:Amount) * -10000) div 10000"/>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- Výpočet ceny v DM když je počet MJ kladný -->
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="(d4p1:PriceType='0') or (faktprij:PriceType='0') ">
									<!-- Vystavené faktury -->
									<xsl:value-of select="d4p1:PriceUnitWithVatHc"/>
									<!-- Vydělení celkové částky položky s daní v domácí měně celkovým počtem MJ položky a zaokrouhlení na 4 desetinná místa.
									 Funkce "Round" zaokrouhluje na nejbližší celé číslo, proto dochází nejprve k vynásobení 10000 a po zaokrouhlení k následnému dělení 10000.
									 Výpočet z celkové ceny položky se musí dělat proto, že idkolad nevrací jednotkovou cenu u PF a vratek VF-->
									<!-- Přijaté faktury -->
									<xsl:if test="string-length(faktprij:PriceTotalWithVatHc)>0">
										<xsl:value-of select="round((faktprij:PriceTotalWithVatHc div faktprij:Amount) * 10000) div 10000"/>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<!-- Vystavené faktury -->
									<xsl:value-of select="d4p1:PriceUnitWithoutVatHc"/>
									<!-- Přijaté faktury -->
									<xsl:if test="string-length(faktprij:PriceTotalWithoutVatHc)>0">
										<xsl:value-of select="round((faktprij:PriceTotalWithoutVatHc div faktprij:Amount) * 10000) div 10000"/>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:if test="$MenaDokladu!='EUR' ">
					<!-- Měna dokladu je různá od EUR -->
					<xsl:element name="Valuty">
						<xsl:choose>
							<!-- Výpočet ceny v DM když je počet MJ záporný (vratka) -->
							<xsl:when test="(d4p1:Amount &lt; 0) or (faktprij:Amount &lt; 0)">
								<xsl:choose>
									<!-- Typ ceny je s DPH -->
									<xsl:when test="(d4p1:PriceType='0') or (faktprij:PriceType='0')  ">
										<!-- Vystavené faktury -->
										<xsl:if test="string-length(d4p1:PriceTotalWithVat)>0">
											<xsl:value-of select="round((d4p1:PriceTotalWithVat div d4p1:Amount) * -10000) div 10000"/>
										</xsl:if>
										<!-- Přijaté faktury -->
										<xsl:if test="string-length(faktprij:PriceTotalWithVat)>0">
											<xsl:value-of select="round((faktprij:PriceTotalWithVat div faktprij:Amount) * -10000) div 10000"/>
										</xsl:if>
									</xsl:when>
									<!-- Typ ceny je bez DPH nebo jen základ-->
									<xsl:otherwise>
										<!-- Vystavené faktury -->
										<xsl:if test="string-length(d4p1:PriceTotalWithoutVat)>0">
											<xsl:value-of select="round((d4p1:PriceTotalWithoutVat div d4p1:Amount) * -10000) div 10000"/>
										</xsl:if>
										<!-- Přijaté faktury -->
										<xsl:if test="string-length(faktprij:PriceTotalWithoutVat)>0">
											<xsl:value-of select="round((faktprij:PriceTotalWithoutVat div faktprij:Amount) * -10000) div 10000"/>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!-- Výpočet ceny v CM když je počet MJ kladný -->
							<xsl:otherwise>
								<xsl:choose>
									<!-- Typ ceny je s DPH-->
									<xsl:when test="(d4p1:PriceType='0') or (faktprij:PriceType='0')  ">
										<!-- Vystavené faktury -->
										<xsl:value-of select="d4p1:PriceUnitWithVat"/>
										<!-- Přijaté faktury -->
										<xsl:if test="string-length(faktprij:PriceTotalWithVat)>0">
											<xsl:value-of select="round((faktprij:PriceTotalWithVat div faktprij:Amount) * 10000) div 10000"/>
										</xsl:if>
									</xsl:when>
									<!-- Typ ceny je bez DPH nebo jen základ -->
									<xsl:otherwise>
										<!-- Vystavené faktury -->
										<xsl:value-of select="d4p1:PriceUnitWithoutVat"/>
										<!-- Přijaté faktury -->
										<xsl:if test="string-length(faktprij:PriceTotalWithoutVat)>0">
											<xsl:value-of select="round((faktprij:PriceTotalWithoutVat div faktprij:Amount) * 10000) div 10000"/>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:if>
				<!-- Test, zda pro ceníkovou položku existuje související zásoba v Money S3 -->
				<xsl:variable name="PriceListItemId" select="d4p1:PriceListItemId | faktprij:PriceListItemId"/>
				<xsl:variable name="GUID">
					<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
						<xsl:if test="$PriceListItemId = root:iDoklPol">
							<xsl:value-of select="root:GUID"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:choose>
					<!-- skladová položka (v konfiguraci je zapnuta podpora importu skladových položek a současně pro položku existuje související zásoba v Money S3) -->
					<xsl:when test="($iDokladSklPol = 1) and (string-length($GUID) &gt; 0) ">
						<xsl:if test="(d4p1:Amount &lt; 0) or (faktprij:Amount &lt; 0)">
							<xsl:element name="Vratka">1</xsl:element>
						</xsl:if>
						<xsl:element name="SklPolozka">
							<xsl:element name="KmKarta">
								<xsl:element name="GUID">
									<xsl:value-of select="$GUID"/>
								</xsl:element>
								<xsl:element name="iDoklPol">
									<xsl:value-of select="$PriceListItemId"/>
								</xsl:element>
								<xsl:element name="iDoklAgend">
									<xsl:value-of select="$iDokladAgend"/>
								</xsl:element>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					<!-- neskladová položka -->
					<xsl:otherwise>
						<xsl:element name="NesklPolozka">
							<xsl:element name="Zaloha">
								<xsl:choose>
									<xsl:when test="(d4p1:ItemType='2') or (faktprij:ItemType='2') ">1</xsl:when>
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<xsl:element name="Protizapis">0</xsl:element>
							<xsl:if test="(string-length(d4p1:Unit) &gt; 0) or (string-length(faktprij:Unit) &gt; 0)">
								<xsl:element name="MJ">
									<xsl:value-of select="d4p1:Unit | faktprij:Unit"/>
								</xsl:element>
							</xsl:if>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- ODBĚRATEL, DODAVATEL -->
	<xsl:template name="DodOdb">
		<!-- GUID -->
		<xsl:variable name="GUID" select="d2p1:Purchaser/d4p1:AddressIdg | dobr:Purchaser/d4p1:AddressIdg | faktprij:Supplier/d4p1:AddressIdg "/>
		<xsl:element name="GUID">{<xsl:value-of select="translate($GUID,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWYXZ')"/>}</xsl:element>
		<!-- Adresa -->
		<xsl:variable name="Ulice" select="d2p1:PurchaserDocumentAddress/d4p1:Street | dobr:PurchaserDocumentAddress/d4p1:Street
											| faktprij:SupplierDocumentAddress/d4p1:Street"/>
		<xsl:variable name="Misto" select="d2p1:PurchaserDocumentAddress/d4p1:City | dobr:PurchaserDocumentAddress/d4p1:City
											| faktprij:SupplierDocumentAddress/d4p1:City"/>
		<xsl:variable name="PSC" select="d2p1:PurchaserDocumentAddress/d4p1:PostalCode | dobr:PurchaserDocumentAddress/d4p1:PostalCode
											| faktprij:SupplierDocumentAddress/d4p1:PostalCode"/>
		<xsl:variable name="Stat" select="d2p1:PurchaserDocumentAddress/d4p1:Country | dobr:PurchaserDocumentAddress/d4p1:Country
											| faktprij:SupplierDocumentAddress/d4p1:Country"/>
		<xsl:variable name="KodStatu" select="d2p1:Purchaser/d4p1:Country/d5p1:Code | dobr:Purchaser/d4p1:Country/d5p1:Code
											| faktprij:SupplierDocumentAddress/d4p1:Code"/>
		<xsl:element name="Adresa">
			<xsl:element name="Ulice">
				<xsl:value-of select="$Ulice"/>
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
		</xsl:element>
		<xsl:element name="ObchAdresa">
			<xsl:element name="Ulice">
				<xsl:value-of select="$Ulice"/>
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
		</xsl:element>
		<xsl:element name="FaktAdresa">
			<xsl:element name="Ulice">
				<xsl:value-of select="$Ulice"/>
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
		</xsl:element>
		<!-- ostatní údaje -->
		<xsl:variable name="Nazev" select="d2p1:PurchaserDocumentAddress/d4p1:NickName | dobr:PurchaserDocumentAddress/d4p1:NickName
											| faktprij:SupplierDocumentAddress/d4p1:NickName"/>
		<xsl:variable name="ICO" select="d2p1:PurchaserDocumentAddress/d4p1:IdentificationNumber | dobr:PurchaserDocumentAddress/d4p1:IdentificationNumber
											| faktprij:SupplierDocumentAddress/d4p1:IdentificationNumber "/>
		<xsl:variable name="DIC" select="d2p1:PurchaserDocumentAddress/d4p1:VatIdentificationNumber | dobr:PurchaserDocumentAddress/d4p1:VatIdentificationNumber
											| faktprij:SupplierDocumentAddress/d4p1:VatIdentificationNumber "/>
		<xsl:variable name="DICSK" select="d2p1:PurchaserDocumentAddress/d4p1:VatIdentificationNumberSk | 
											dobr:PurchaserDocumentAddress/d4p1:VatIdentificationNumberSk | 
											faktprij:SupplierDocumentAddress/d4p1:VatIdentificationNumberSk "/>
		<xsl:element name="Nazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="ObchNazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="FaktNazev">
			<xsl:value-of select="$Nazev"/>
		</xsl:element>
		<xsl:element name="ICO">
			<xsl:value-of select="$ICO"/>
		</xsl:element>
		<xsl:element name="DIC">
			<xsl:value-of select="$DIC"/>
		</xsl:element>
		<xsl:element name="DICSK">
			<xsl:value-of select="$DICSK"/>
		</xsl:element>
		<xsl:variable name="Telefon" select="d2p1:PurchaserDocumentAddress/d4p1:Phone | dobr:PurchaserDocumentAddress/d4p1:Phone | faktprij:SupplierDocumentAddress/d4p1:Phone"/>
		<xsl:element name="Tel">
			<xsl:choose>
				<xsl:when test="substring($Telefon,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($Telefon,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($Telefon,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$Telefon"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:variable name="Fax" select="d2p1:PurchaserDocumentAddress/d4p1:Fax | dobr:PurchaserDocumentAddress/d4p1:Fax | faktprij:SupplierDocumentAddress/d4p1:Fax"/>
		<xsl:element name="Fax">
			<xsl:choose>
				<xsl:when test="substring($Fax,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($Fax,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($Fax,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$Fax"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:variable name="Mobil" select="d2p1:PurchaserDocumentAddress/d4p1:Mobile | dobr:PurchaserDocumentAddress/d4p1:Mobile | faktprij:SupplierDocumentAddress/d4p1:Mobile"/>
		<xsl:element name="Mobil">
			<!-- KontaktOsoba -->
			<xsl:choose>
				<xsl:when test="substring($Mobil,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($Mobil,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($Mobil,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$Mobil"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:variable name="EMail" select="d2p1:PurchaserDocumentAddress/d4p1:Email | dobr:PurchaserDocumentAddress/d4p1:Email | faktprij:SupplierDocumentAddress/d4p1:Email"/>
		<xsl:element name="EMail">
			<xsl:value-of select="$EMail"/>
		</xsl:element>
		<xsl:variable name="WWW" select="d2p1:PurchaserDocumentAddress/d4p1:Www | dobr:PurchaserDocumentAddress/d4p1:Www  | faktprij:SupplierDocumentAddress/d4p1:Www"/>
		<xsl:element name="WWW">
			<xsl:value-of select="$WWW"/>
		</xsl:element>
		<!-- KontaktOsoba -->
		<xsl:variable name="Osloveni" select="d2p1:PurchaserDocumentAddress/d4p1:Title | dobr:PurchaserDocumentAddress/d4p1:Title | faktprij:SupplierDocumentAddress/d4p1:Title"/>
		<xsl:variable name="Jmeno" select="d2p1:PurchaserDocumentAddress/d4p1:Firstname | dobr:PurchaserDocumentAddress/d4p1:Firstname | faktprij:SupplierDocumentAddress/d4p1:Firstname"/>
		<xsl:variable name="Prijmeni" select="d2p1:PurchaserDocumentAddress/d4p1:Surname | dobr:PurchaserDocumentAddress/d4p1:Surname | faktprij:SupplierDocumentAddress/d4p1:Surname"/>
		<xsl:if test="string-length($Prijmeni)>0 ">
			<xsl:element name="Osoba">
				<xsl:element name="Osloveni">
					<xsl:value-of select="$Osloveni"/>
				</xsl:element>
				<xsl:element name="Jmeno">
					<xsl:value-of select="$Jmeno"/>
				</xsl:element>
				<xsl:element name="Prijmeni">
					<xsl:value-of select="$Prijmeni"/>
				</xsl:element>
				<xsl:element name="Pohlavi">
					<xsl:choose>
						<xsl:when test="substring($Prijmeni,string-length($Prijmeni),1)='á' ">0</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="Jednatel">1</xsl:element>
				<xsl:element name="Mobil">
					<xsl:choose>
						<xsl:when test="substring($Mobil,1,1)='+' ">
							<xsl:element name="Pred">
								<xsl:value-of select="substring($Mobil,1,4)"/>
							</xsl:element>
							<xsl:element name="Cislo">
								<xsl:value-of select="substring($Mobil,5,20)"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="Cislo">
								<xsl:value-of select="$Mobil"/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="EMail">
					<xsl:value-of select="$EMail"/>
				</xsl:element>
			</xsl:element>
		</xsl:if>
		<!-- bankovní spojení -->
		<xsl:variable name="Banka" select="d2p1:PurchaserDocumentAddress/d4p1:Bank | dobr:PurchaserDocumentAddress/d4p1:Bank | faktprij:SupplierDocumentAddress/d4p1:Bank"/>
		<xsl:variable name="Ucet" select="d2p1:PurchaserDocumentAddress/d4p1:AccountNumber | dobr:PurchaserDocumentAddress/d4p1:AccountNumber | faktprij:SupplierDocumentAddress/d4p1:AccountNumber"/>
		<xsl:variable name="Iban" select="d2p1:PurchaserDocumentAddress/d4p1:Iban | dobr:PurchaserDocumentAddress/d4p1:Iban | faktprij:SupplierDocumentAddress/d4p1:Iban"/>
		<xsl:variable name="KodBanky" select="d2p1:PurchaserDocumentAddress/d4p1:BankNumberCode | dobr:PurchaserDocumentAddress/d4p1:BankNumberCode | faktprij:SupplierDocumentAddress/d4p1:BankNumberCode"/>
		<xsl:element name="Banka">
			<xsl:value-of select="$Banka"/>
		</xsl:element>
		<xsl:element name="Ucet">
			<xsl:choose>
				<xsl:when test="string-length($Ucet)>0 ">
					<xsl:value-of select="$Ucet"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Iban"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="KodBanky">
			<xsl:value-of select="$KodBanky"/>
		</xsl:element>
		<!-- seznam bankovních spojení -->
		<xsl:variable name="SeznamBankSpojeni" select="d2p1:Purchaser/d4p1:BankAccounts/d4p1:BankAccountApiModel |
															 dobr:Purchaser/d4p1:BankAccounts/d4p1:BankAccountApiModel |
															 faktprij:Supplier/d4p1:BankAccounts/d4p1:BankAccountApiModel "/>
		<xsl:element name="SeznamBankSpojeni">
			<xsl:for-each select="$SeznamBankSpojeni">
				<xsl:element name="BankSpojeni">
					<xsl:element name="Ucet">
						<xsl:choose>
							<xsl:when test="string-length(d4p1:AccountNumber)>0 ">
								<xsl:value-of select="d4p1:AccountNumber"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="d4p1:Iban"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="KodBanky">
						<xsl:choose>
							<xsl:when test="string-length(d4p1:BankNumberCode)>0 ">
								<xsl:value-of select="d4p1:BankNumberCode"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="d4p1:Swift"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
      <xsl:if test="string-length($Ucet)>0 ">
  		  <xsl:element name="BankSpojeni">
				  <xsl:element name="Ucet">
            <xsl:value-of select="$Ucet"/>
          </xsl:element>
          <xsl:element name="KodBanky">
            <xsl:value-of select="$KodBanky"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
      <xsl:if test="string-length($Iban)>0 ">
			  <xsl:element name="BankSpojeni">
				  <xsl:element name="Ucet">
            <xsl:value-of select="$Iban"/>
          </xsl:element>
          <xsl:element name="KodBanky">
            <xsl:value-of select="$KodBanky"/>
          </xsl:element>
        </xsl:element>
      </xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- MOJE FIRMA -->
	<xsl:template name="MojeFirma">
		<xsl:variable name="MojeFirmaNazev" select="d2p1:MyCompanyDocumentAddress/d4p1:NickName | dobr:MyCompanyDocumentAddress/d4p1:NickName
														| faktprij:MyCompanyDocumentAddress/d4p1:NickName"/>
		<xsl:variable name="MojeFirmaUlice" select="d2p1:MyCompanyDocumentAddress/d4p1:Street | dobr:MyCompanyDocumentAddress/d4p1:Street
														| faktprij:MyCompanyDocumentAddress/d4p1:Street"/>
		<xsl:variable name="MojeFirmaMisto" select="d2p1:MyCompanyDocumentAddress/d4p1:City | dobr:MyCompanyDocumentAddress/d4p1:City
														| faktprij:MyCompanyDocumentAddress/d4p1:City"/>
		<xsl:variable name="MojeFirmaPSC" select="d2p1:MyCompanyDocumentAddress/d4p1:PostalCode | dobr:MyCompanyDocumentAddress/d4p1:PostalCode
														| faktprij:MyCompanyDocumentAddress/d4p1:PostalCode"/>
		<xsl:variable name="MojeFirmaStat" select="d2p1:MyCompanyDocumentAddress/d4p1:Country | dobr:MyCompanyDocumentAddress/d4p1:Country
														| faktprij:MyCompanyDocumentAddress/d4p1:Country"/>
		<xsl:variable name="MojeFirmaICO" select="d2p1:MyCompanyDocumentAddress/d4p1:IdentificationNumber |
														dobr:MyCompanyDocumentAddress/d4p1:IdentificationNumber |
														faktprij:MyCompanyDocumentAddress/d4p1:IdentificationNumber"/>
		<xsl:variable name="MojeFirmaDIC" select="d2p1:MyCompanyDocumentAddress/d4p1:VatIdentificationNumber | 
														dobr:MyCompanyDocumentAddress/d4p1:VatIdentificationNumber |
														faktprij:MyCompanyDocumentAddress/d4p1:VatIdentificationNumber"/>
		<xsl:variable name="MojeFirmaDanIC" select="d2p1:MyCompanyDocumentAddress/d4p1:VatIdentificationNumberSk | 
														dobr:MyCompanyDocumentAddress/d4p1:VatIdentificationNumberSk |
														faktprij:MyCompanyDocumentAddress/d4p1:VatIdentificationNumberSk"/>
		<xsl:variable name="MojeFirmaTel" select="d2p1:MyCompanyDocumentAddress/d4p1:Phone | dobr:MyCompanyDocumentAddress/d4p1:Phone
														| faktprij:MyCompanyDocumentAddress/d4p1:Phone"/>
		<xsl:variable name="MojeFirmaFax" select="d2p1:MyCompanyDocumentAddress/d4p1:Fax | dobr:MyCompanyDocumentAddress/d4p1:Fax
														| faktprij:MyCompanyDocumentAddress/d4p1:Fax"/>
		<xsl:variable name="MojeFirmaMobil" select="d2p1:MyCompanyDocumentAddress/d4p1:Mobile | dobr:MyCompanyDocumentAddress/d4p1:Mobile
														| faktprij:MyCompanyDocumentAddress/d4p1:Mobile"/>
		<xsl:variable name="MojeFirmaEMail" select="d2p1:MyCompanyDocumentAddress/d4p1:Email | dobr:MyCompanyDocumentAddress/d4p1:Email
														| faktprij:MyCompanyDocumentAddress/d4p1:Email"/>
		<xsl:variable name="MojeFirmaWWW" select="d2p1:MyCompanyDocumentAddress/d4p1:Www | dobr:MyCompanyDocumentAddress/d4p1:Www
														| faktprij:MyCompanyDocumentAddress/d4p1:Www"/>
		<xsl:variable name="MojeFirmaBanka" select="d2p1:MyCompanyDocumentAddress/d4p1:Bank | dobr:MyCompanyDocumentAddress/d4p1:Bank
														| faktprij:MyCompanyDocumentAddress/d4p1:Bank"/>
		<xsl:variable name="MojeFirmaUcet" select="d2p1:MyCompanyDocumentAddress/d4p1:AccountNumber | 
															dobr:MyCompanyDocumentAddress/d4p1:AccountNumber |
															faktprij:MyCompanyDocumentAddress/d4p1:AccountNumber"/>
		<xsl:variable name="MojeFirmaIban" select="d2p1:MyCompanyDocumentAddress/d4p1:Iban | dobr:MyCompanyDocumentAddress/d4p1:Iban
															| faktprij:MyCompanyDocumentAddress/d4p1:Iban"/>
		<xsl:variable name="MojeFirmaKodBanky" select="d2p1:MyCompanyDocumentAddress/d4p1:BankNumberCode |
															dobr:MyCompanyDocumentAddress/d4p1:BankNumberCode |
															faktprij:MyCompanyDocumentAddress/d4p1:BankNumberCode
															"/>
		<xsl:element name="Nazev">
			<xsl:value-of select="$MojeFirmaNazev"/>
		</xsl:element>
		<xsl:element name="ObchAdresa">
			<xsl:element name="Ulice">
				<xsl:value-of select="$MojeFirmaUlice"/>
			</xsl:element>
			<xsl:element name="Misto">
				<xsl:value-of select="$MojeFirmaMisto"/>
			</xsl:element>
			<xsl:element name="PSC">
				<xsl:value-of select="$MojeFirmaPSC"/>
			</xsl:element>
			<xsl:element name="Stat">
				<xsl:value-of select="$MojeFirmaStat"/>
			</xsl:element>
		</xsl:element>
		<xsl:element name="ICO">
			<xsl:value-of select="$MojeFirmaICO"/>
		</xsl:element>
		<xsl:element name="DIC">
			<xsl:value-of select="$MojeFirmaDIC"/>
		</xsl:element>
		<xsl:element name="DICSK">
			<xsl:value-of select="$MojeFirmaDanIC"/>
		</xsl:element>
		<xsl:element name="Tel">
			<xsl:choose>
				<xsl:when test="substring($MojeFirmaTel,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($MojeFirmaTel,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($MojeFirmaTel,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$MojeFirmaTel"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="Fax">
			<xsl:choose>
				<xsl:when test="substring($MojeFirmaFax,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($MojeFirmaFax,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($MojeFirmaFax,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$MojeFirmaFax"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="Mobil">
			<xsl:choose>
				<xsl:when test="substring($MojeFirmaMobil,1,1)='+' ">
					<xsl:element name="Pred">
						<xsl:value-of select="substring($MojeFirmaMobil,1,4)"/>
					</xsl:element>
					<xsl:element name="Cislo">
						<xsl:value-of select="substring($MojeFirmaMobil,5,20)"/>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="Cislo">
						<xsl:value-of select="$MojeFirmaMobil"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="EMail">
			<xsl:value-of select="$MojeFirmaEMail"/>
		</xsl:element>
		<xsl:element name="WWW">
			<xsl:value-of select="$MojeFirmaWWW"/>
		</xsl:element>
		<xsl:element name="Banka">
			<xsl:value-of select="$MojeFirmaBanka"/>
		</xsl:element>
		<xsl:element name="Ucet">
			<xsl:choose>
				<xsl:when test="string-length($MojeFirmaUcet)>0 ">
					<xsl:value-of select="$MojeFirmaUcet"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$MojeFirmaIban"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<xsl:element name="KodBanky">
			<xsl:value-of select="$MojeFirmaKodBanky"/>
		</xsl:element>
	</xsl:template>
	<!-- Rozpis sazeb DPH u faktury přijaté a prodejky -->
	<xsl:template name="SazbyDPH">
		<xsl:param name="Pocitadlo"/>
		<xsl:param name="SazbaMax"/>
		<xsl:param name="CiziMena"/>
		<xsl:param name="Zaklad">
			<xsl:choose>
				<xsl:when test="$CiziMena != 1">
					<xsl:value-of select="sum(faktprij:Items/faktprij:ReceivedInvoiceItemApiModel[faktprij:VatRate=$Pocitadlo]/faktprij:PriceTotalWithoutVatHc)
										+sum(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel[prodej:VatRate=$Pocitadlo]/prodej:PriceTotalWithoutVatHc)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(faktprij:Items/faktprij:ReceivedInvoiceItemApiModel[faktprij:VatRate=$Pocitadlo]/faktprij:PriceTotalWithoutVat)
										+sum(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel[prodej:VatRate=$Pocitadlo]/prodej:PriceTotalWithoutVat)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="DPH">
			<xsl:choose>
				<xsl:when test="$CiziMena != 1">
					<xsl:value-of select="sum(faktprij:Items/faktprij:ReceivedInvoiceItemApiModel[faktprij:VatRate=$Pocitadlo]/faktprij:VatTotalHc)
										+sum(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel[prodej:VatRate=$Pocitadlo]/prodej:VatTotalHc)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(faktprij:Items/faktprij:ReceivedInvoiceItemApiModel[faktprij:VatRate=$Pocitadlo]/faktprij:VatTotal)
										+sum(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel[prodej:VatRate=$Pocitadlo]/prodej:VatTotal)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:if test="($Pocitadlo &lt;= $SazbaMax)">
			<xsl:choose>
				<xsl:when test="($Zaklad !=0 ) or ($DPH !=0 )">
					<xsl:element name="DalsiSazba">
						<xsl:element name="HladinaDPH">
							<xsl:choose>
								<xsl:when test="($Pocitadlo = 0)">0</xsl:when>
								<xsl:when test="($Pocitadlo &lt;= 15)">1</xsl:when>
								<!-- do 15ti % včetně se jedná o sníženou hladinu -->
								<xsl:otherwise>2</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="Sazba">
							<xsl:value-of select="$Pocitadlo"/>
						</xsl:element>
						<xsl:element name="Zaklad">
							<xsl:value-of select="format-number($Zaklad,'0.####' )"/>
						</xsl:element>
						<xsl:if test="$Pocitadlo != 0">
							<xsl:element name="DPH">
								<xsl:value-of select="format-number($DPH,'0.####' )"/>
							</xsl:element>
						</xsl:if>
					</xsl:element>
					<xsl:call-template name="SazbyDPH">
						<xsl:with-param name="Pocitadlo" select="$Pocitadlo+0.5"/>
						<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
						<xsl:with-param name="CiziMena" select="$CiziMena"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="SazbyDPH">
						<xsl:with-param name="Pocitadlo" select="$Pocitadlo+0.5"/>
						<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
						<xsl:with-param name="CiziMena" select="$CiziMena"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- PRODEJKA -->
	<xsl:template match="prodej:SalesReceiptApiModel | prodej:SalesReceiptApiModelExpand">
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSluzba"/>
		<xsl:param name="iDokladSluzbaSklad"/>
		<xsl:param name="iDokladPlatidlo"/>
		<xsl:param name="MenaDokladu" select="prodej:Currency/d4p1X:Code"/>
		<!-- Test, zda prodejka z iDokladu existuje v Money S3 (porovnává se uživatelské číslo dokladu) -->
		<xsl:variable name="CisloDokla" select="prodej:DocumentNumber"/>
		<xsl:variable name="DokladExist">
			<xsl:for-each select="../../root:ReferenceDoklad">
				<xsl:if test="$CisloDokla = root:Doklad">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda prodejka obsahuje alespoň jednu položku bez vazby na ceník nebo ceníkovou položku, pro kterou neexistuje zásoba v Money S3 -->
		<xsl:variable name="PolozkaNeexist">
			<xsl:for-each select="prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel">
				<xsl:variable name="PolozkaExist" select="prodej:PriceListItemId"/>
				<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
					<xsl:if test="$PolozkaExist = root:iDoklPol">1</xsl:if>
				</xsl:for-each>
				<xsl:if test="(not(contains($PolozkaExist,'1'))) and (not(prodej:ItemType) or (prodej:ItemType != '1'))">0</xsl:if>
				<!-- pro položku iDokladu neexistuje související položka v Money S3 a současně se nejedná o zaokrouhlovací položku -->
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="Prodejka">
			<!-- Pokud již bude prodejka v Money S3 existovat nebo (na prodejce bude existovat neskladová položka a současně nebude přednastavena zásoba typu "služba"), tak se neprovede
					její import a pouze se zapíše nemožnost importu tohoto dokladu do Reportu - viz element Import -->
			<xsl:if test="(string-length($DokladExist) &gt; 0) or ((contains($PolozkaNeexist,'0')) and (string-length($iDokladSluzba) = 0))">
				<xsl:element name="Import">
					<xsl:attribute name="Exported"><xsl:choose><xsl:when test="(string-length($DokladExist) &gt; 0)">1</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:element name="Status">FatalError</xsl:element>
					<xsl:element name="Reference">
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Číslo dokladu</xsl:attribute>
						</xsl:element>
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Doklad</xsl:attribute>
							<xsl:value-of select="prodej:DocumentNumber"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ErrorInfo">
						<xsl:element name="ErrorTypeCoded">BusinessError</xsl:element>
						<xsl:element name="ErrorTypeOther"/>
						<xsl:element name="ErrorCode">
							<xsl:choose>
								<xsl:when test="(string-length($DokladExist) &gt; 0)">-99911</xsl:when>
								<xsl:otherwise>-99912</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="ErrorDescription">
							<xsl:choose>
								<xsl:when test="(string-length($DokladExist) &gt; 0)">
									<xsl:value-of select="concat('Prodejku č.', prodej:DocumentNumber, ' nelze naimportovat, protože byla po přenosu do Money S3 změněna v iDokladu. Import změněných prodejek není podporován. Program Vás informuje o změněných prodejkách, které nelze importovat, pouze jedenkrát.')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('Prodejku č.', prodej:DocumentNumber, ' nelze naimportovat, protože obsahuje neskladové položky, pro které není v programu Money S3 přednastavena zásoba typu &quot;služba&quot; (viz karta Money / Možnosti a nastavení / Externí aplikace). Položky iDokladu bez vazby na ceník se importují jako skladové položky s přednastavenou zásobou typu &quot;služba&quot;.')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="CisloDokla">
				<xsl:value-of select="prodej:DocumentNumber"/>
			</xsl:element>
			<xsl:element name="iDokladID">
				<xsl:value-of select="id:Id"/>
			</xsl:element>
			<xsl:element name="iDoklAgend">
				<xsl:value-of select="$iDokladAgend"/>
			</xsl:element>
			<xsl:element name="PopisX">
				<xsl:value-of select="prodej:Name"/>
			</xsl:element>
			<xsl:element name="Datum">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="prodej:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="DatSkPoh">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="prodej:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:variable name="SazbaMax" select="30"/>
			<!-- Maximální podporovaná sazba při generování rozpisu sazeb DPH -->
			<xsl:if test="count(prodej:SalesReceiptItems) &gt; 0">
				<xsl:element name="SouhrnDPH">
					<xsl:element name="SeznamDalsiSazby">
						<xsl:call-template name="SazbyDPH">
							<xsl:with-param name="Pocitadlo" select="0"/>
							<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Celkem">
				<xsl:value-of select="prodej:TotalWithVatHc"/>
			</xsl:element>
			<xsl:if test="$MenaDokladu!='EUR' ">
				<!-- Měna dokladu je různá od EUR-->
				<xsl:element name="Valuty">
					<xsl:element name="Mena">
						<xsl:element name="Kod">
							<xsl:value-of select="$MenaDokladu"/>
						</xsl:element>
						<xsl:element name="Mnozstvi">
							<xsl:value-of select="prodej:ExchangeRate"/>
						</xsl:element>
						<xsl:element name="Kurs">
							<xsl:value-of select="concat('-',prodej:ExchangeRateAmount)"/>
						</xsl:element>
					</xsl:element>
					<xsl:if test="count(prodej:SalesReceiptItems) &gt; 0">
						<xsl:element name="SouhrnDPH">
							<xsl:element name="SeznamDalsiSazby">
								<xsl:call-template name="SazbyDPH">
									<xsl:with-param name="Pocitadlo" select="0"/>
									<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
									<xsl:with-param name="CiziMena" select="1"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="Celkem">
						<xsl:value-of select="prodej:TotalWithVat"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- seznam položek -->
			<xsl:apply-templates select="prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel">
				<xsl:with-param name="MenaDokladu" select="$MenaDokladu"/>
				<xsl:with-param name="iDokladAgend" select="$iDokladAgend"/>
				<xsl:with-param name="iDokladSluzba" select="$iDokladSluzba"/>
				<xsl:with-param name="iDokladSluzbaSklad" select="$iDokladSluzbaSklad"/>
				<xsl:with-param name="Pocet" select="count(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel)"/>
			</xsl:apply-templates>
			<!-- seznam nepeněžních plateb -->
			<xsl:variable name="PlatbaKartou">
				<xsl:value-of select="sum(prodej:SalesReceiptPayments/prodej:SalesReceiptPaymentApiModel[prodej:PaymentOptionId = 2]/prodej:PaymentAmount)"/>
			</xsl:variable>
			<xsl:variable name="PlatbaOstatni">
				<xsl:value-of select="sum(prodej:SalesReceiptPayments/prodej:SalesReceiptPaymentApiModel[prodej:PaymentOptionId != 2]/prodej:PaymentAmount)"/>
			</xsl:variable>
			<xsl:if test="(string-length($iDokladPlatidlo) &gt; 0) and ($PlatbaKartou != 0) ">
				<xsl:element name="SeznamNepPlateb">
					<xsl:if test="$PlatbaOstatni != 0 ">
						<xsl:element name="NepPlatba">
							<xsl:element name="MnozstviMJ">1</xsl:element>
							<xsl:element name="Castka">
								<xsl:value-of select="$PlatbaOstatni"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="NepPlatba">
						<xsl:element name="Platidlo">
							<xsl:element name="Kod">
								<xsl:value-of select="$iDokladPlatidlo"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="MnozstviMJ">
							<xsl:value-of select="$PlatbaKartou"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- Prodejka - EET - pre SK zatiaľ nepoužite-->
	<xsl:template match="prodej:SalesReceiptApiModel | prodej:SalesReceiptApiModelExpand">
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSluzba"/>
		<xsl:param name="iDokladSluzbaSklad"/>
		<xsl:param name="iDokladPlatidlo"/>
		<xsl:param name="MenaDokladu" select="prodej:Currency/d4p1X:Code"/>
		<!-- Test, zda prodejka z iDokladu existuje v Money S3 (porovnává se uživatelské číslo dokladu) -->
		<xsl:variable name="CisloDokla" select="prodej:DocumentNumber"/>
		<xsl:variable name="DokladExist">
			<xsl:for-each select="../../root:ReferenceDoklad">
				<xsl:if test="$CisloDokla = root:Doklad">1</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- Test, zda prodejka obsahuje alespoň jednu položku bez vazby na ceník nebo ceníkovou položku, pro kterou neexistuje zásoba v Money S3 -->
		<xsl:variable name="PolozkaNeexist">
			<xsl:for-each select="prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel">
				<xsl:variable name="PolozkaExist" select="prodej:PriceListItemId"/>
				<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
					<xsl:if test="$PolozkaExist = root:iDoklPol">1</xsl:if>
				</xsl:for-each>
				<xsl:if test="(not(contains($PolozkaExist,'1'))) and (not(prodej:ItemType) or (prodej:ItemType != '1'))">0</xsl:if>
				<!-- pro položku iDokladu neexistuje související položka v Money S3 a současně se nejedná o zaokrouhlovací položku -->
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="Prodejka">
			<!-- Pokud již bude prodejka v Money S3 existovat nebo (na prodejce bude existovat neskladová položka a současně nebude přednastavena zásoba typu "služba"), tak se neprovede
					její import a pouze se zapíše nemožnost importu tohoto dokladu do Reportu - viz element Import -->
			<xsl:if test="(string-length($DokladExist) &gt; 0) or ((contains($PolozkaNeexist,'0')) and (string-length($iDokladSluzba) = 0))">
				<xsl:element name="Import">
					<xsl:attribute name="Exported"><xsl:choose><xsl:when test="(string-length($DokladExist) &gt; 0)">1</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose></xsl:attribute>
					<xsl:element name="Status">FatalError</xsl:element>
					<xsl:element name="Reference">
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Číslo dokladu</xsl:attribute>
						</xsl:element>
						<xsl:element name="ID">
							<xsl:attribute name="keyName">Doklad</xsl:attribute>
							<xsl:value-of select="prodej:DocumentNumber"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="ErrorInfo">
						<xsl:element name="ErrorTypeCoded">BusinessError</xsl:element>
						<xsl:element name="ErrorTypeOther"/>
						<xsl:element name="ErrorCode">
							<xsl:choose>
								<xsl:when test="(string-length($DokladExist) &gt; 0)">-99911</xsl:when>
								<xsl:otherwise>-99912</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="ErrorDescription">
							<xsl:choose>
								<xsl:when test="(string-length($DokladExist) &gt; 0)">
									<xsl:value-of select="concat('Prodejku č.', prodej:DocumentNumber, ' nelze naimportovat, protože byla po přenosu do Money S3 změněna v iDokladu. Import změněných prodejek není podporován. Program Vás informuje o změněných prodejkách, které nelze importovat, pouze jedenkrát.')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('Prodejku č.', prodej:DocumentNumber, ' nelze naimportovat, protože obsahuje neskladové položky, pro které není v programu Money S3 přednastavena zásoba typu &quot;služba&quot; (viz karta Money / Možnosti a nastavení / Externí aplikace). Položky iDokladu bez vazby na ceník se importují jako skladové položky s přednastavenou zásobou typu &quot;služba&quot;.')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="CisloDokla">
				<xsl:value-of select="prodej:DocumentNumber"/>
			</xsl:element>
			<!-- EET -->
			<xsl:apply-templates select="prodej:RegisteredSale"/>
			<xsl:element name="iDokladID">
				<xsl:value-of select="id:Id"/>
			</xsl:element>
			<xsl:element name="iDoklAgend">
				<xsl:value-of select="$iDokladAgend"/>
			</xsl:element>
			<xsl:element name="PopisX">
				<xsl:value-of select="prodej:Name"/>
			</xsl:element>
			<xsl:element name="Datum">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="prodej:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:element name="DatSkPoh">
				<xsl:call-template name="_datum_">
					<xsl:with-param name="_datum">
						<xsl:value-of select="prodej:DateOfIssue"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
			<xsl:variable name="SazbaMax" select="30"/>
			<!-- Maximální podporovaná sazba při generování rozpisu sazeb DPH -->
			<xsl:if test="count(prodej:SalesReceiptItems) &gt; 0">
				<xsl:element name="SouhrnDPH">
					<xsl:element name="SeznamDalsiSazby">
						<xsl:call-template name="SazbyDPH">
							<xsl:with-param name="Pocitadlo" select="0"/>
							<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="Celkem">
				<xsl:value-of select="prodej:TotalWithVatHc"/>
			</xsl:element>
			<xsl:if test="$MenaDokladu!='EUR'">
				<!-- Měna dokladu je různá od EUR -->
				<xsl:element name="Valuty">
					<xsl:element name="Mena">
						<xsl:element name="Kod">
							<xsl:value-of select="$MenaDokladu"/>
						</xsl:element>
						<xsl:element name="Kurs">
							<xsl:value-of select="concat('-',prodej:ExchangeRateAmount)"/>
						</xsl:element>
						<xsl:element name="Mnozstvi">
							<xsl:value-of select="prodej:ExchangeRate"/>
						</xsl:element>
					</xsl:element>
					<xsl:if test="count(prodej:SalesReceiptItems) &gt; 0">
						<xsl:element name="SouhrnDPH">
							<xsl:element name="SeznamDalsiSazby">
								<xsl:call-template name="SazbyDPH">
									<xsl:with-param name="Pocitadlo" select="0"/>
									<xsl:with-param name="SazbaMax" select="$SazbaMax"/>
									<xsl:with-param name="CiziMena" select="1"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="Celkem">
						<xsl:value-of select="prodej:TotalWithVat"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- seznam položek -->
			<xsl:apply-templates select="prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel">
				<xsl:with-param name="MenaDokladu" select="$MenaDokladu"/>
				<xsl:with-param name="iDokladAgend" select="$iDokladAgend"/>
				<xsl:with-param name="iDokladSluzba" select="$iDokladSluzba"/>
				<xsl:with-param name="iDokladSluzbaSklad" select="$iDokladSluzbaSklad"/>
				<xsl:with-param name="Pocet" select="count(prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel)"/>
			</xsl:apply-templates>
			<!-- seznam nepeněžních plateb -->
			<xsl:variable name="PlatbaKartou">
				<xsl:value-of select="sum(prodej:SalesReceiptPayments/prodej:SalesReceiptPaymentApiModel[prodej:PaymentOptionId = 2]/prodej:PaymentAmount)"/>
			</xsl:variable>
			<xsl:variable name="PlatbaOstatni">
				<xsl:value-of select="sum(prodej:SalesReceiptPayments/prodej:SalesReceiptPaymentApiModel[prodej:PaymentOptionId != 2]/prodej:PaymentAmount)"/>
			</xsl:variable>
			<xsl:if test="(string-length($iDokladPlatidlo) &gt; 0) and ($PlatbaKartou != 0) ">
				<xsl:element name="SeznamNepPlateb">
					<xsl:if test="$PlatbaOstatni != 0 ">
						<xsl:element name="NepPlatba">
							<xsl:element name="MnozstviMJ">1</xsl:element>
							<xsl:element name="Castka">
								<xsl:value-of select="$PlatbaOstatni"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
					<xsl:element name="NepPlatba">
						<xsl:element name="Platidlo">
							<xsl:element name="Kod">
								<xsl:value-of select="$iDokladPlatidlo"/>
							</xsl:element>
						</xsl:element>
						<xsl:element name="MnozstviMJ">
							<xsl:value-of select="$PlatbaKartou"/>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- Položka prodejky -->
	<xsl:template match="prodej:SalesReceiptItems/prodej:SalesReceiptItemApiModel">
		<xsl:param name="MenaDokladu"/>
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSluzba"/>
		<xsl:param name="iDokladSluzbaSklad"/>
		<xsl:param name="Pocet"/>
		<!-- počet položek -->
		<!-- neimportuje se zaokrouhlovací položka a položka s nulovým množstvím -->
		<xsl:if test="(not(prodej:ItemType) or (prodej:ItemType != '1')) and (prodej:Amount !=0)">
			<xsl:element name="Polozka">
				<xsl:element name="Nazev">
					<xsl:value-of select="prodej:Name"/>
				</xsl:element>
				<!-- Počet MJ je záporný, násobí se proto -1 početMJ, cena a valuty a položce se nastavuje příznak vratka -->
				<xsl:choose>
					<xsl:when test="prodej:Amount &lt; 0">
						<xsl:element name="Vratka">1</xsl:element>
						<xsl:element name="PocetMJ">
							<xsl:value-of select="prodej:Amount * -1"/>
						</xsl:element>
						<xsl:element name="Cena">
							<xsl:value-of select="prodej:Price * -1"/>
						</xsl:element>
					</xsl:when>
					<!-- Počet MJ je kladný-->
					<xsl:otherwise>
						<xsl:element name="PocetMJ">
							<xsl:value-of select="prodej:Amount"/>
						</xsl:element>
						<xsl:element name="Cena">
							<xsl:value-of select="prodej:Price"/>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:element name="MJ">
					<xsl:value-of select="prodej:Unit"/>
				</xsl:element>
				<xsl:element name="DPH">
					<xsl:value-of select="prodej:VatRate"/>
				</xsl:element>
				<xsl:element name="CenaTyp">
					<xsl:choose>
						<xsl:when test="(prodej:PriceType='0')">1</xsl:when>
						<!-- s DPH -->
						<xsl:when test="(prodej:PriceType='1')">0</xsl:when>
						<!-- bez DPH -->
						<xsl:when test="(prodej:PriceType='2')">3</xsl:when>
						<!-- jen základ -->
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:if test="$MenaDokladu!='EUR' ">
					<!-- Měna dokladu je různá od EUR - to ale idoklad zatím neumí-->
					<!-- u záporného počtu MJ se násobí -1 počet i cena a valuty a nastavuje se vratka -->
					<xsl:choose>
						<xsl:when test="prodej:Amount &lt; 0">
							<xsl:element name="Valuty">
								<xsl:value-of select="prodej:Price * -1"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="Valuty">
								<xsl:value-of select="prodej:Price"/>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<!-- Test, zda pro ceníkovou položku existuje související zásoba v Money S3 -->
				<xsl:variable name="PriceListItemId" select="prodej:PriceListItemId"/>
				<xsl:variable name="GUID">
					<xsl:for-each select="../../../../root:ReferenceKmK/root:KmKarta">
						<xsl:if test="$PriceListItemId = root:iDoklPol">
							<xsl:value-of select="root:GUID"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:element name="KmKarta">
					<xsl:element name="GUID">
						<xsl:choose>
							<xsl:when test="string-length($GUID) &gt; 0 ">
								<xsl:value-of select="$GUID"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$iDokladSluzba"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:if test="string-length($GUID) &gt; 0 ">
						<xsl:element name="iDoklPol">
							<xsl:value-of select="$PriceListItemId"/>
						</xsl:element>
						<xsl:element name="iDoklAgend">
							<xsl:value-of select="$iDokladAgend"/>
						</xsl:element>
					</xsl:if>
				</xsl:element>
				<xsl:if test="string-length($GUID) = 0 ">
					<xsl:element name="Sklad">
						<xsl:element name="GUID">
							<xsl:value-of select="$iDokladSluzbaSklad"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- ZÁSOBA -->
	<xsl:template match="zasoba:PriceListApiModel | zasoba:PriceListApiModelExpand">
		<xsl:param name="iDokladAgend"/>
		<xsl:param name="iDokladSazbaDPH_SS"/>
		<xsl:param name="iDokladSazbaDPH_ZS"/>
		<xsl:param name="iDokladSazbaDPH_3"/>
		<xsl:variable name="Id" select="id:Id"/>
		<xsl:variable name="GUID">
			<xsl:for-each select="../../root:ReferenceKmK/root:KmKarta">
				<xsl:if test="($Id = root:iDoklPol)">
					<xsl:value-of select="root:GUID"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="Zasoba">
			<xsl:if test="string-length($GUID) = 0">
				<xsl:element name="konfigurace">
					<xsl:element name="SDPH_Prod">
						<xsl:choose>
							<xsl:when test="zasoba:VatRateType = '0' ">
								<xsl:value-of select="$iDokladSazbaDPH_SS"/>
							</xsl:when>
							<xsl:when test="zasoba:VatRateType = '1' ">
								<xsl:value-of select="$iDokladSazbaDPH_ZS"/>
							</xsl:when>
							<xsl:when test="zasoba:VatRateType = '3' ">
								<xsl:value-of select="$iDokladSazbaDPH_3"/>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="SDPH_Nakup">
						<xsl:choose>
							<xsl:when test="zasoba:VatRateType = '0' ">
								<xsl:value-of select="$iDokladSazbaDPH_SS"/>
							</xsl:when>
							<xsl:when test="zasoba:VatRateType = '1' ">
								<xsl:value-of select="$iDokladSazbaDPH_ZS"/>
							</xsl:when>
							<xsl:when test="zasoba:VatRateType = '3' ">
								<xsl:value-of select="$iDokladSazbaDPH_3"/>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:element name="KmKarta">
				<xsl:if test="string-length($GUID) &gt; 0">
					<xsl:element name="GUID">
						<xsl:value-of select="$GUID"/>
					</xsl:element>
				</xsl:if>
				<xsl:if test="string-length($GUID) = 0">
					<xsl:element name="Popis">
						<xsl:value-of select="zasoba:Name"/>
					</xsl:element>
					<xsl:element name="MJ">
						<xsl:value-of select="zasoba:Unit"/>
					</xsl:element>
					<xsl:element name="DesMist">4</xsl:element>
					<xsl:element name="TypKarty">
						<xsl:choose>
							<xsl:when test="zasoba:HasStockMovement= 'true' ">jednoducha</xsl:when>
							<xsl:otherwise>sluzba</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="BarCode">
						<xsl:value-of select="zasoba:BarCode"/>
					</xsl:element>
				</xsl:if>
				<xsl:element name="iDoklAgend">
					<xsl:value-of select="$iDokladAgend"/>
				</xsl:element>
				<xsl:element name="iDoklPol">
					<xsl:value-of select="id:Id"/>
				</xsl:element>
			</xsl:element>
			<xsl:if test="(zasoba:CurrencyId = '1') and (string-length($GUID) = 0) ">
				<xsl:element name="PC">
					<xsl:element name="Cena1">
						<xsl:element name="Cena">
							<xsl:value-of select="zasoba:Price"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="SDPH">
						<xsl:choose>
							<xsl:when test="zasoba:PriceType= '0' ">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- ZPŮSOBY ÚHRADY -->
	<xsl:template name="ZpusobUhrady">
		<xsl:param name="Uhrada"/>
		<xsl:choose>
			<xsl:when test="$Uhrada = 'Převodem' ">prevodom</xsl:when>
			<xsl:when test="$Uhrada = 'Hotově' ">v hotovosti</xsl:when>
			<xsl:when test="$Uhrada = 'Kartou' ">platobnou kartou</xsl:when>
			<xsl:when test="$Uhrada = 'Dobírka' ">dobierkou</xsl:when>
			<xsl:when test="$Uhrada = 'Zápočtem' ">zápočtom</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Uhrada"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- DATUMOVÝ FORMÁT VÝSTUPU -->
	<xsl:template name="_datum_">
		<xsl:param name="_datum"/>
		<xsl:variable name="rok" select="substring($_datum, 1,4)"/>
		<xsl:variable name="mesic" select="substring($_datum, 6,2)"/>
		<xsl:variable name="den" select="substring($_datum, 9,2)"/>
		<xsl:variable name="datum" select="concat($rok,'-',$mesic,'-',$den)"/>
		<xsl:value-of select="$datum"/>
	</xsl:template>
</xsl:stylesheet>
