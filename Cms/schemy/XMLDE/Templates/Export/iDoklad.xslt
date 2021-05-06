<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2008 sp1 (http://www.altova.com) by Dusan Pesko (CIGLER SOFTWARE, a.s.) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d2p1="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<!-- Transformační šablona na export dat z Money S3 do iDokladu
	  Autor: Marek Vykydal
	-->
	<xsl:template match="/">
		<xsl:element name="MoneyData">
			<xsl:if test="MoneyData/SeznamFaktVyd | MoneyData/SeznamFaktPrij | MoneyData/SeznamZasoba">
				<xsl:apply-templates select="MoneyData/SeznamFaktVyd"/>
				<!-- Úhrady faktur vydaných -->
				<xsl:apply-templates select="MoneyData/SeznamFaktPrij"/>
				<!-- Úhrady faktur přijatých -->
				<xsl:apply-templates select="MoneyData/SeznamZasoba" mode="Nove"/>
				<!-- Nové zásoby -->
				<xsl:apply-templates select="MoneyData/SeznamZasoba" mode="Exist"/>
				<!-- Existující zásoby -->
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- Úhrady faktur vydaných -->
	<xsl:template match="SeznamFaktVyd">
		<xsl:element name="FaktVyd">
			<xsl:apply-templates select="FaktVyd">
				<xsl:with-param name="DruhFaktury" select=" 'FaktVyd' "/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<!-- Úhrady faktur přijatých -->
	<xsl:template match="SeznamFaktPrij">
		<xsl:element name="FaktPrij">
			<xsl:apply-templates select="FaktPrij">
				<xsl:with-param name="DruhFaktury" select=" 'FaktPrij' "/>
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	<!-- Nové zásoby -->
	<xsl:template match="SeznamZasoba" mode="Nove">
		<xsl:element name="Zasoby_Nove">
			<!-- Uvádí se jen v případě, že existuje alespoň jedna zásoba, která nebyla doposud exportována do iDokladu a současně se nejedná o zásobu s evidencí výrobních čísel.
				Zápis .// vybere všechny elementy KmKarta/EvVyrCis, které jsou potomky aktuálního uzlu (viz element Zasoba). -->
			<xsl:if test="count(Zasoba[(string-length(KmKarta/iDoklPol) = 0) and (not(.//KmKarta/EvVyrCis = 1))]) &gt; 0">
				<xsl:element name="i:BatchModelOfPriceListApiModel5BFZeHoS" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.BaseModels">
					<xsl:element name="d2p1:Items">
						<xsl:apply-templates select="Zasoba" mode="Nove"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- Existující zásoby -->
	<xsl:template match="SeznamZasoba" mode="Exist">
		<xsl:element name="Zasoby_Exist">
			<!-- Uvádí se jen v případě, že existuje alespoň jedna zásoba, která již byla exportována do iDokladu a současně se nejedná o zásobu s evidencí výrobních čísel. -->
			<xsl:if test="count(Zasoba[(KmKarta/iDoklPol &gt; 0) and (not(.//KmKarta/EvVyrCis = 1))]) &gt; 0">
				<xsl:element name="i:BatchModelOfPriceListPutModelV25BFZeHoS" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels.BaseModels">
					<xsl:element name="d2p1:Items">
						<xsl:apply-templates select="Zasoba" mode="Exist"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- FAKTURY -->
	<xsl:template match="FaktVyd | FaktPrij">
		<xsl:param name="DruhFaktury"/>
		<xsl:if test="(string-length(iDokladID) &gt; 0) and (iDokladID != 0) ">
			<!-- 		<xsl:if test="(string-length(iDokladID) &gt; 0) and (count(SeznamUhrad/Uhrada[not(KurzRozd/Typ = 'I') and not (KurzRozd/Typ = 'T') and not(KurzRozd/Preceneni = 1) ]) &gt; 0) ">-->
			<xsl:element name="Items">
				<xsl:attribute name="InvoiceId"><xsl:value-of select="iDokladID"/></xsl:attribute>
				<xsl:attribute name="Doklad"><xsl:value-of select="Doklad"/></xsl:attribute>
				<xsl:attribute name="Dobropis"><xsl:choose><xsl:when test="Dobropis = 1">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose></xsl:attribute>
				<!-- 
				<xsl:variable name="IsEet">				test, zda existuje alespoň jedna úhrada EET, která se bude exportovat 
					<xsl:for-each select="SeznamUhrad/Uhrada">
						<xsl:if test="((DokladUhr/EET/EETOdesl = 1) or (DokladUhr/EET/EETOdesl = 2))
									and not(KurzRozd/Typ = 'I') and not (KurzRozd/Typ = 'T') and not(KurzRozd/Preceneni = 1)">1</xsl:if>
					</xsl:for-each>
				</xsl:variable>
					<xsl:attribute name="IsEet">
						<xsl:choose>
							<xsl:when test="string-length($IsEet) &gt; 0">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
-->
				<xsl:if test="count(SeznamUhrad/Uhrada) &gt; 0">
					<xsl:apply-templates select="SeznamUhrad/Uhrada">
						<xsl:with-param name="DruhFaktury" select="$DruhFaktury"/>
						<xsl:with-param name="Dobropis" select="Dobropis"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- Úhrada faktury -->
	<xsl:template match="Uhrada">
		<xsl:param name="DruhFaktury"/>
		<xsl:param name="Dobropis"/>
		<xsl:if test="not(KurzRozd/Typ = 'I') and not (KurzRozd/Typ = 'T') and not(KurzRozd/Preceneni = 1) ">
			<!-- kurzové rozdíly a přecenění úhrad se ignorují -->
			<xsl:choose>
				<xsl:when test="$DruhFaktury = 'FaktVyd' ">
					<xsl:element name="IssuedDocumentPaymentApiModelInsert" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
						<xsl:call-template name="Uhrada">
							<xsl:with-param name="DruhFaktury" select="$DruhFaktury"/>
							<xsl:with-param name="Dobropis" select="$Dobropis"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="ReceivedDocumentPaymentApiModelInsert" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
						<xsl:call-template name="Uhrada">
							<xsl:with-param name="DruhFaktury" select="$DruhFaktury"/>
							<xsl:with-param name="Dobropis" select="$Dobropis"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- Úhrada faktury - údaje -->
	<xsl:template name="Uhrada">
		<xsl:param name="DruhFaktury"/>
		<xsl:param name="Dobropis"/>
		<!-- 
				<xsl:element name="CurrencyId" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:call-template name="Mena">
						<xsl:with-param name="Mena" select="ValutyHraz/Mena/Kod"/>
					</xsl:call-template>
				</xsl:element>
-->
		<xsl:if test="string-length(Datum) &gt; 0">
			<xsl:element name="DateOfPayment" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
				<xsl:value-of select="concat(Datum,'T00:00:00.0000000')  "/>
			</xsl:element>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="string-length(DatUplDPH) &gt; 0">
				<xsl:element name="DateOfVatApplication" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:value-of select="concat(DatUplDPH,'T00:00:00.0000000')  "/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="string-length(Datum) &gt; 0">
				<xsl:element name="DateOfVatApplication" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:value-of select="concat(Datum,'T00:00:00.0000000')  "/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
		<!-- 
				<xsl:element name="ExchangeRate" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:choose>
						<xsl:when test="(string-length(ValutyHraz/Mena/Kod) &gt; 0) and (string-length(ValutyHraz/Mena/Mnozstvi) &gt; 0)">
							<xsl:value-of select="format-number(ValutyHraz/Mena/Mnozstvi,'0.0000' )"/>
						</xsl:when>
						<xsl:otherwise>1.0000</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
	
				<xsl:element name="ExchangeRateAmount" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:choose>
						<xsl:when test="(string-length(ValutyHraz/Mena/Kod) &gt; 0) and (string-length(ValutyHraz/Mena/Kurs) &gt; 0)">
							<xsl:value-of select="format-number(substring(ValutyHraz/Mena/Kurs,2,10),'0.0000' )"/>
						</xsl:when>
						<xsl:otherwise>1.0000</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
-->
		<xsl:element name="Exported" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">1</xsl:element>
		<xsl:element name="InvoiceId" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
			<xsl:value-of select="../../iDokladID"/>
		</xsl:element>
		<xsl:element name="PaymentAmount" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
			<xsl:choose>
				<xsl:when test="(string-length(ValutyHraz/Mena/Kod) &gt; 0) and (string-length(ValutyHraz/Castka) &gt; 0)">
					<xsl:choose>
						<xsl:when test="$Dobropis = 1">
							<xsl:value-of select="format-number((ValutyHraz/Castka)*(-1),'0.0000' )"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(ValutyHraz/Castka,'0.0000' )"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$Dobropis = 1">
							<xsl:value-of select="format-number((Castka)*(-1),'0.0000' )"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(Castka,'0.0000' )"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
		<!-- 
				<xsl:element name="PaymentAmountHc" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
					<xsl:choose>
						<xsl:when test="$Dobropis = 1">
							<xsl:value-of select="format-number((Castka)*(-1),'0.0000' )"/>
						</xsl:when>
						<xsl:otherwise>	<xsl:value-of select="format-number(Castka,'0.0000' )"/></xsl:otherwise>
					</xsl:choose>
				</xsl:element>
-->
		<xsl:element name="PaymentOptionId" xmlns="http://schemas.datacontract.org/2004/07/Doklad.Api.ApiModels">
			<xsl:call-template name="ZpusobUhrady">
				<xsl:with-param name="Uhrada" select="../../Uhrada"/>
				<xsl:with-param name="UhrDokladDruh" select="DokladUhr/DruhDokladu"/>
				<xsl:with-param name="KurzRozd" select="KurzRozd/Typ"/>
				<xsl:with-param name="Preceneni" select="KurzRozd/Preceneni"/>
			</xsl:call-template>
		</xsl:element>
		<!-- 
					<xsl:if test="(../../../FaktVyd) and ((DokladUhr/EET/EETOdesl = 1) or (DokladUhr/EET/EETOdesl = 2))">

					<xsl:element name="ElectronicRecordsOfSales">

						Určuje odpovědnost za správu elektronické evidence tržeb - vždy Money S3 a to i v případě, že tržba není evidována. 
						<xsl:element name="EetResponsibility">ExternalApplication</xsl:element>

						<xsl:element name="EetStatus">
							<xsl:choose>
								<xsl:when test="string-length(DokladUhr/EET/FIK) &gt; 0">Registered</xsl:when>
								<xsl:otherwise>NotRegistered</xsl:otherwise>
							</xsl:choose>
						</xsl:element>

						<xsl:element name="IsEet">
							<xsl:choose>
								<xsl:when test="(DokladUhr/EET/EETOdesl = 1) or (DokladUhr/EET/EETOdesl = 2)">true</xsl:when>
								<xsl:otherwise>false</xsl:otherwise>
							</xsl:choose>
						</xsl:element>

	
						Test na vybrané údaje, které jsou povinné v iDokladu 
						<xsl:if test="(string-length(DokladUhr/EET/FIK) &gt; 0) and (string-length(DokladUhr/EET/BKP) &gt; 0) and (string-length(DokladUhr/EET/PKP) &gt; 0) and (string-length(DokladUhr/EET/UUID) &gt; 0)
									and (string-length(DokladUhr/EET/DICPopl) &gt; 0) and (string-length(DokladUhr/EET/PoradCis) &gt; 0) and (string-length(DokladUhr/EET/Provozovna) &gt; 0)">
							<xsl:apply-templates select="DokladUhr/EET"/>
						</xsl:if>

					</xsl:element>
				</xsl:if>
-->
	</xsl:template>
	<!-- Úhrady - EET -->
	<!-- ZÁSOBY -->
	<xsl:template match="Zasoba" mode="Nove">
		<!-- Zásoby s evidencí výrobních čísel se neuvádí. Zápis .// vybere všechny elementy KmKarta/EvVyrCis, které jsou potomky aktuálního uzlu. -->
		<xsl:if test="(string-length(KmKarta/iDoklPol) = 0) and (not(.//KmKarta/EvVyrCis = 1))">
			<xsl:element name="d2p1:PriceListApiModel">
				<xsl:call-template name="Zasoba"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template match="Zasoba" mode="Exist">
		<xsl:if test="(KmKarta/iDoklPol &gt; 0) and (not(.//KmKarta/EvVyrCis = 1))">
			<xsl:element name="d2p1:PriceListPutModelV2">
				<xsl:element name="Id">
					<xsl:value-of select="KmKarta/iDoklPol"/>
				</xsl:element>
				<xsl:call-template name="Zasoba"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- Proměnné zásoby -->
	<xsl:template name="Zasoba">
		<xsl:element name="d2p1:Amount">1</xsl:element>
		<!-- Nalezení čísla kmenové karty, které se uvádí v elementu Code -->
		<xsl:variable name="GUID" select="KmKarta/GUID"/>
		<xsl:variable name="KmKCislo">
			<xsl:for-each select="../../ReferenceKmK/KmKarta">
				<xsl:if test="$GUID = GUID">
					<xsl:value-of select="KmKCislo"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:element name="d2p1:Code">
			<xsl:value-of select="$KmKCislo"/>
		</xsl:element>
		<!-- Cenová hladina, která se použije při exportu zásoby -->
		<xsl:variable name="Hladina">
			<xsl:for-each select="PC">
				<xsl:if test="../../../@iDokladCenHl = Hladina/Zkrat">
					<xsl:value-of select="position()"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:apply-templates select="PC">
			<xsl:with-param name="Hladina">
				<xsl:choose>
					<xsl:when test="string-length($Hladina) &gt; 0">
						<xsl:value-of select="$Hladina"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Udaj" select="1"/>
			<!-- CurrencyId -->
		</xsl:apply-templates>
		<!--	
		<xsl:element name="d2p1:HasStockMovement">0</xsl:element>
			<xsl:choose>
				<xsl:when test="not(KmKarta/TypKarty = 'sluzba')">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
	-->
		<!-- Podle nastavení přepínače "Sledovat stav skladu" se tento příznak nastaví na všech exportovaných zásobách-->
		<xsl:if test="/MoneyData/@iDokladSledovatStavSkladu = 1">
			<xsl:element name="d2p1:HasStockMovement">1</xsl:element>
		</xsl:if>
		<xsl:if test="/MoneyData/@iDokladSledovatStavSkladu = 0">
			<xsl:element name="d2p1:HasStockMovement">0</xsl:element>
		</xsl:if>
		<xsl:element name="d2p1:Name">
			<xsl:value-of select="KmKarta/Popis"/>
		</xsl:element>
		<xsl:apply-templates select="PC">
			<xsl:with-param name="Hladina">
				<xsl:choose>
					<xsl:when test="string-length($Hladina) &gt; 0">
						<xsl:value-of select="$Hladina"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Udaj" select="2"/>
			<!-- Price, PriceType -->
		</xsl:apply-templates>
		<xsl:if test="string-length(KmKarta/MJ) &gt; 0">
			<xsl:element name="d2p1:Unit">
				<xsl:value-of select="KmKarta/MJ"/>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(KmKarta/BarCode) &gt; 0">
			<xsl:element name="d2p1:BarCode">
				<xsl:value-of select="KmKarta/BarCode"/>
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates select="PC">
			<xsl:with-param name="Hladina">
				<xsl:choose>
					<xsl:when test="string-length($Hladina) &gt; 0">
						<xsl:value-of select="$Hladina"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Udaj" select="3"/>
			<!-- VatRateType -->
		</xsl:apply-templates>
	</xsl:template>
	<!-- Ceny zásoby -->
	<xsl:template match="PC">
		<xsl:param name="Hladina"/>
		<xsl:param name="Udaj"/>
		<xsl:if test="$Hladina = position()">
			<xsl:choose>
				<xsl:when test="$Udaj = 1">
					<xsl:element name="d2p1:CurrencyId">
						<xsl:call-template name="Mena">
							<xsl:with-param name="Mena" select="Mena/Kod"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$Udaj = 2">
					<xsl:element name="d2p1:Price">
						<xsl:value-of select="format-number(Cena1/Cena,'0.0000' )"/>
					</xsl:element>
					<xsl:element name="d2p1:PriceType">
						<xsl:choose>
							<xsl:when test="SDPH = 0">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:when>
				<xsl:when test="$Udaj = 3">
					<xsl:element name="d2p1:VatRateType">
						<xsl:choose>
							<xsl:when test="../konfigurace/SDPH_Prod  &gt;= 19">1</xsl:when>
							<xsl:when test="../konfigurace/SDPH_Prod  &gt;= 15">0</xsl:when>
							<xsl:when test="../konfigurace/SDPH_Prod  &gt; 0">3</xsl:when>
							<xsl:otherwise>2</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- MĚNA -->
	<xsl:template name="Mena">
		<xsl:param name="Mena"/>
		<xsl:choose>
			<xsl:when test="$Mena = 'CZK' ">1</xsl:when>
			<xsl:when test="$Mena = 'BGN' ">3</xsl:when>
			<xsl:when test="$Mena = 'DKK' ">4</xsl:when>
			<xsl:when test="$Mena = 'HUF' ">5</xsl:when>
			<xsl:when test="$Mena = 'LVL' ">6</xsl:when>
			<xsl:when test="$Mena = 'LTL' ">7</xsl:when>
			<xsl:when test="$Mena = 'PLN' ">8</xsl:when>
			<xsl:when test="$Mena = 'RON' ">9</xsl:when>
			<xsl:when test="$Mena = 'GBP' ">10</xsl:when>
			<xsl:when test="$Mena = 'USD' ">11</xsl:when>
			<xsl:when test="$Mena = 'AUD' ">12</xsl:when>
			<xsl:when test="$Mena = 'BRL' ">13</xsl:when>
			<xsl:when test="$Mena = 'CNY' ">14</xsl:when>
			<xsl:when test="$Mena = 'PHP' ">15</xsl:when>
			<xsl:when test="$Mena = 'HKD' ">16</xsl:when>
			<xsl:when test="$Mena = 'HRK' ">17</xsl:when>
			<xsl:when test="$Mena = 'INR' ">18</xsl:when>
			<xsl:when test="$Mena = 'IDR' ">19</xsl:when>
			<xsl:when test="$Mena = 'ILS' ">20</xsl:when>
			<xsl:when test="$Mena = 'JPY' ">21</xsl:when>
			<xsl:when test="$Mena = 'ZAR' ">22</xsl:when>
			<xsl:when test="$Mena = 'KRW' ">23</xsl:when>
			<xsl:when test="$Mena = 'CAD' ">24</xsl:when>
			<xsl:when test="$Mena = 'MYR' ">25</xsl:when>
			<xsl:when test="$Mena = 'MXN' ">26</xsl:when>
			<xsl:when test="$Mena = 'NOK' ">27</xsl:when>
			<xsl:when test="$Mena = 'NZD' ">28</xsl:when>
			<xsl:when test="$Mena = 'RUB' ">29</xsl:when>
			<xsl:when test="$Mena = 'SGD' ">30</xsl:when>
			<xsl:when test="$Mena = 'SEK' ">31</xsl:when>
			<xsl:when test="$Mena = 'CHF' ">32</xsl:when>
			<xsl:when test="$Mena = 'THB' ">33</xsl:when>
			<xsl:when test="$Mena = 'TRY' ">34</xsl:when>
			<xsl:otherwise>2</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ZPŮSOBY ÚHRADY -->
	<xsl:template name="ZpusobUhrady">
		<xsl:param name="Uhrada"/>
		<xsl:param name="UhrDokladDruh"/>
		<xsl:param name="KurzRozd"/>
		<xsl:param name="Preceneni"/>
		<xsl:param name="mpismena">abcdefghijklmnopqrstuvwxyzáčďéěíľňóřšťúůýž</xsl:param>
		<xsl:param name="vpismena">ABCDEFGHIJKLMNOPQRSTUVWXYZÁČĎÉĚÍĽŇÓŘŠŤÚŮÝŽ</xsl:param>
		<xsl:param name="UhradaT" select="translate($Uhrada, $vpismena, $mpismena)"/>
		<xsl:choose>
			<xsl:when test="($KurzRozd = 'I') or ($KurzRozd = 'T') or ($Preceneni = 1) ">7</xsl:when>
			<!-- nenastane -->
			<xsl:when test="($UhrDokladDruh = 'B') or ($UhrDokladDruh = 'A') ">1</xsl:when>
			<xsl:when test="($UhrDokladDruh = 'P') or ($UhrDokladDruh = 'O') ">3</xsl:when>
			<xsl:when test="contains($UhradaT, 'prevod')">1</xsl:when>
			<xsl:when test="contains($UhradaT, 'kart')">2</xsl:when>
			<xsl:when test="contains($UhradaT, 'hotov')">3</xsl:when>
			<xsl:when test="contains($UhradaT, 'dobi')">4</xsl:when>
			<xsl:when test="(contains($UhradaT, 'zaúčtování mezi partnery')) or (contains($UhradaT, 'zápoč'))">5</xsl:when>
			<xsl:when test="contains($UhradaT, 'záloh')">6</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
