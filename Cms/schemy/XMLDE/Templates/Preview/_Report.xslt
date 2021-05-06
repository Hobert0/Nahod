<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- Import znamych sablon, ktere budou transformovat prislusna DATA. Pokud zde odpovidajici sablona neni, pouzije se _XmlData.xslt -->
  <!-- Sablony musi byt ve stejne slozce jako tento soubor! -->
  <xsl:import href="_XmlData.xslt"/>
  <xsl:import href="_Adresar.xslt"/>
  <xsl:import href="_KmKarta.xslt"/>
  <xsl:import href="_Zasoba.xslt"/>
  <xsl:import href="_Zakazka.xslt"/>
  <xsl:import href="_FrFaktVyd.xslt"/>
  <xsl:import href="_FrFaktPrij.xslt"/>
  <xsl:import href="_FrPokDokl.xslt"/>
  <xsl:import href="_FrBankDokl.xslt"/>
  <xsl:import href="_FrIntDokl.xslt"/>
  <xsl:import href="_FrPohledavky.xslt"/>
  <xsl:import href="_FrZavazky.xslt"/>
  <xsl:import href="_FrPrijObj.xslt"/>
  <xsl:import href="_FrPrijNab.xslt"/>
  <xsl:import href="_FrPrijPop.xslt"/>
  <xsl:import href="_FrVystObj.xslt"/>
  <xsl:import href="_FrVystNab.xslt"/>
  <xsl:import href="_FrVystPop.xslt"/>
  <xsl:import href="_FrSklDokl.xslt"/>
  <xsl:import href="_FrInvDokl.xslt"/>
  <xsl:import href="_SzCiselniky.xslt"/>
  <xsl:import href="_SzSklady.xslt"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:preserve-space elements="*"/>

	<xsl:template match="/">
	<html>
		<head>
			<title>Report</title>
			<style><![CDATA[
        h1 {font-size: 160%}
        h2 {font-size: 150%}
        h3 {font-size: 140%}
        h4 {font-size: 130%}
        th {font-size: 80%}
        .zahlavi {background-color: silver}
	.Ok {background-color: white}
	.WarningError {background-color: yellow}
	.FatalError {background-color: red}

	body, td {font-family: "Arial", "Tahoma", helvetica; font-size: 70%; color: black;}
	td {vertical-align: middle;}

        BODY {font:x-small 'Verdana'; margin-right:1.5em}
        .c {}
        .b {color:red; font-family:'Courier New'; font-weight:bold; text-decoration:none}
        .e {margin-left:1em; text-indent:-1em; margin-right:1em}
        .k {margin-left:1em; text-indent:-1em; margin-right:1em}
        .t {color:#990000}
        .xt {color:#990099}
        .ns {color:red}
        .dt {color:green}
        .m {color:blue}
        .tx {font-weight:bold}
        .db {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; border-left:1px solid #CCCCCC; font:small Courier}
        .di {font:small Courier}
        .d {color:blue}
        .pi {color:blue}
        .cb {text-indent:0px; margin-left:1em; margin-top:0px; margin-bottom:0px; padding-left:.3em; font:small Courier; color:#888888}
        .ci {font:small Courier; color:#888888}
        PRE {margin:0px; display:inline}

	.pozadi1 {background-color: #D3D3D3;}
	.pozadi2 {background-color: #000;}
	.pismo1 {font-family: "Wingdings";}
	.barvapisma {color: #FFFFFF;}
	.tucne {font-weight: bold;}
	.kurziva {font-style: italic;}
	.velikost1 {font-size: 120%;}
	.velikost2 {font-size: 100%;}
    .velikost3 {font-size: 80%;}
	.velikost4 {font-size: 75%}
	.velikost5 {font-size: 72%;}
	.velikost6 {font-size: 70%;}
	.velikost7 {font-size: 60%;}
	.velikost8 {font-size: 20%;}
	.velikost9 {font-size: 95%;}
	.velikost10 {font-size: 90%;}
	.zarovnani_N {vertical-align: top;}
	.zarovnani_D {vertical-align: bottom;}
	.podtrzeni_P {border-right: 1px solid black;}
	.podtrzeni_L {border-left: 1px solid black;}
	.podtrzeni_N {border-top: 1px solid black;}
	.podtrzeni_D {border-bottom: 1px solid black;}
	.podtrzeni_P3 {border-right: 3px solid black;}
	.podtrzeni_L3 {border-left: 3px solid black;}
	.podtrzeni_N3 {border-top: 3px solid black;}
	.podtrzeni_D3 {border-bottom: 3px solid black;}
	.podtrzeni_NT {border-top: 1px dotted black;}
	.podtrzeni_DT {border-bottom: 1px dotted black;}
	.odsad_P {padding-right: 5px;}
	.odsad_L {padding-left: 5px;}
	.odsad_L2 {padding-left: 10px;}
	.odsad_N {padding-top: 5px;}
	.odsad_D {padding-bottom: 5px;}
	.radius {border-radius: 10px;}    

        ]]>
			</style>
		</head>
		<body>
			<xsl:apply-templates/>
		</body>
	</html>
	</xsl:template>

	<xsl:template match="MoneyReport">
		<xsl:param name="NadpisPerFakt"/>			<!-- nadpis pro výstupní zprávu z periodické nebo hromadné fakturace -->
	
		<!-- záhlaví reportu -->
		<a name="obsah"></a>

		<h1>
			<xsl:choose>
				<xsl:when test="string-length($NadpisPerFakt)>0">		<!-- nadpis pro výstupní zprávu z periodické nebo hromadné fakturace -->
					<xsl:value-of select="$NadpisPerFakt"/>
				</xsl:when>
				<xsl:otherwise>Import dát - výstupná správa</xsl:otherwise>	<!-- nadpis pro výstupní zprávu z XML importu -->
			</xsl:choose>
		</h1>

		<table border="1" class="normal">
		<tr>
		<th class="zahlavi">stav</th>
		<td class="{Status}"><xsl:value-of select="Status"/></td>
		</tr>
		</table>
		<!-- konec záhlaví reportu -->

		<!-- obsah -->
		<xsl:text disable-output-escaping="yes">&lt;br&gt;&lt;hr&gt;</xsl:text>
		<xsl:for-each select="*[*]">
			<xsl:element name="a">
				<xsl:attribute name="href">#<xsl:value-of select="name()"/><xsl:number level="single"/></xsl:attribute>
				<xsl:value-of select="name()"/>
			</xsl:element>
		<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
		</xsl:for-each>

		<!-- všechny entity 1. úrovně -->
		<xsl:for-each select="*">
			<xsl:call-template name="Global"/>
		</xsl:for-each>
		<!-- konec entit 1. úrovně -->


		<!-- rekurzivně detaily všech entit 1. úrovně a jejich vnořené entity -->
		<xsl:for-each select="*">
			<xsl:variable name="entita"><xsl:value-of select="name()"/></xsl:variable>
			<xsl:variable name="ref"><xsl:number level="single"/></xsl:variable>
			<xsl:call-template name="Detail">
				<xsl:with-param name="kontext"><xsl:value-of select="concat($entita,$ref)"/></xsl:with-param>
				<xsl:with-param name="uroven">2</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		
		<!-- Data -->
		<xsl:for-each select="*">
      <xsl:call-template name="ZobrazData"></xsl:call-template>
		</xsl:for-each>
		
	</xsl:template>

	<xsl:template name="Global">
	<!-- všechny entity 1. úrovně -->
		<xsl:variable name="entita"><xsl:value-of select="name()"/></xsl:variable>
		<xsl:variable name="ref"><xsl:number level="single"/></xsl:variable>
		<xsl:for-each select="*">
			<xsl:if test="position()=1">
				<xsl:text disable-output-escaping="yes">&lt;br&gt;&lt;hr&gt;</xsl:text>
				<xsl:element name="a">
					<xsl:attribute name="name"><xsl:value-of select="concat($entita,$ref)"/></xsl:attribute>
					<xsl:text> </xsl:text>
				</xsl:element>
				<table border="0" class="nadpis" width="100%">
				<tbody class="nadpis"><tr>
				<td align="left">
				<xsl:element name="h2">
					<xsl:value-of select="name()"/>
				</xsl:element>
				</td>
				<td align="right">
				<xsl:element name="a">
					<xsl:attribute name="href">#obsah</xsl:attribute>
					<xsl:text>[späť]</xsl:text>
				</xsl:element>
				</td>
				</tr></tbody>
				</table>
			</xsl:if>
			<xsl:call-template name="Tabulka">
				<xsl:with-param name="uroven">2</xsl:with-param>
				<xsl:with-param name="kontext"><xsl:value-of select="concat($entita,$ref)"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="*[Status]">
			<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
			<xsl:call-template name="Pocitadlo">
				<xsl:with-param name="pocet"><xsl:value-of select="count(*[Status])"/></xsl:with-param>
				<xsl:with-param name="Ok"><xsl:value-of select="count(*[Status='Ok'])"/></xsl:with-param>
				<xsl:with-param name="Warning"><xsl:value-of select="count(*[Status='WarningError'])"/></xsl:with-param>
				<xsl:with-param name="Fatal"><xsl:value-of select="count(*[Status='FatalError'])"/></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="Detail">
	<!-- rekurzivně detaily všech entit a jejich vnořené entity -->
		<xsl:param name="kontext"/>
		<xsl:param name="uroven"/>
		<xsl:for-each select="*[*[Status!='Ok']]">
			<xsl:text disable-output-escaping="yes">&lt;br&gt;&lt;hr&gt;</xsl:text>
			<xsl:variable name="entita"><xsl:value-of select="name()"/></xsl:variable>
			<xsl:variable name="ref"><xsl:number level="single"/></xsl:variable>
			<xsl:call-template name="ZahlaviDetail">
				<xsl:with-param name="uroven"><xsl:value-of select="$uroven"/></xsl:with-param>
				<xsl:with-param name="kontext"><xsl:value-of select="concat($kontext,$entita,$ref)"/></xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select="*[Status!='Ok']">
				<xsl:if test="position()=1">
					<xsl:element name="H{$uroven+1}"><xsl:value-of select="name()"/><xsl:if test="name()='DodOdb'"> (dodávateľ / odberateľ)</xsl:if>
          </xsl:element>
				</xsl:if>
				<xsl:call-template name="Tabulka">
					<xsl:with-param name="uroven"><xsl:value-of select="$uroven+1"/></xsl:with-param>
					<xsl:with-param name="kontext"><xsl:value-of select="concat($kontext,$entita,$ref)"/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:call-template name="Detail">
				<xsl:with-param name="kontext"><xsl:value-of select="concat($kontext,$entita,$ref)"/></xsl:with-param>
				<xsl:with-param name="uroven"><xsl:value-of select="$uroven+1"/></xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="ZahlaviDetail">
	<!-- univerzální zobrazení záhlaví detailu entity s referencí na řádek tabulky se seznamem entit -->
		<xsl:param name="uroven"/>
		<xsl:param name="kontext"/>
		<xsl:element name="a">
			<xsl:attribute name="name"><xsl:value-of select="concat($kontext,'_detail')"/></xsl:attribute>
		</xsl:element>
		<table border="0" class="nadpis" width="100%">
		<tbody class="nadpis"><tr>
		<td align="left">
		<xsl:element name="h{$uroven}">
				<xsl:value-of select="name()"/>
			<xsl:for-each select="Reference/ID[text()]">
				<xsl:value-of select="concat(' ',@keyName,' = ',text())"/>
				<xsl:if test="position()!=last()">,</xsl:if>
			</xsl:for-each>
		</xsl:element>
		</td>
		<td align="right">
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="concat('#',$kontext)"/></xsl:attribute>
			<xsl:text>[späť]</xsl:text>
		</xsl:element>
		</td>
		</tr></tbody>
		</table>
	</xsl:template>

	<xsl:template name="Tabulka">
	<!-- univerzální zobrazení seznamu entit do tabulky s odkazy na detaily-->
		<xsl:param name="uroven"/>
		<xsl:param name="kontext"/>
		<xsl:variable name="entita"><xsl:value-of select="name()"/></xsl:variable>
		<xsl:variable name="ref"><xsl:number level="single"/></xsl:variable>
		<xsl:variable name="pocetChyb"><xsl:value-of select="count(ErrorInfo)"/></xsl:variable>
	
		<xsl:if test="position()=1">
			<xsl:text disable-output-escaping="yes">&lt;table border="1" class="normal" width="100%"&gt;</xsl:text>
			<thead class="normal">
			<tr class="zahlavi">

      <xsl:choose>
			   <xsl:when test="$uroven=2">			
	     		<th width="7%" rowspan="2" valign="top">stav</th>
  		  	<th width="35%" colspan="2">referencie</th>
          <th width="53%" colspan="4">informácie o chybe</th>
          <th width="5%" rowspan="2">Dáta</th>
			   </xsl:when>
      	<xsl:otherwise>
	     		<th width="7%" rowspan="2" valign="top">stav</th>
  		  	<th width="35%" colspan="2">referencie</th>
          <th width="58%" colspan="4">informácie o chybe</th>
        </xsl:otherwise>
      </xsl:choose>
			</tr>

			<tr class="zahlavi">

      <xsl:choose>
			   <xsl:when test="$uroven=2">			
			    <th width="12%">kľúč</th>
			    <th width="23%">hodnota</th>
	     		<th width="7%">typ chyby</th>
	 		    <th width="7%">kód chyby</th>
    			<th width="39%" colspan="2">popis chyby</th>
			   </xsl:when>
      	<xsl:otherwise>
			    <th width="12%">kľúč</th>
			    <th width="23%">hodnota</th>
	     		<th width="7%">typ chyby</th>
	 		    <th width="7%">kód chyby</th>
    			<th width="44%" colspan="2">popis chyby</th>
        </xsl:otherwise>
      </xsl:choose>

			</tr>
			</thead>
			<xsl:text disable-output-escaping="yes">&lt;tbody class="normal"&gt;</xsl:text>
		</xsl:if>
		<tr>
			<xsl:if test="*[Status!='Ok']">
				<xsl:element name="a">
					<xsl:attribute name="name">
						<xsl:value-of select="concat($kontext,$entita,$ref)"/></xsl:attribute>
					<xsl:text> </xsl:text>
				</xsl:element>
			</xsl:if>

				<xsl:choose>	<!-- jestli je $pocetChyb větší než nula, tak doplňuje do řádků proměnnou rowspan, jinak ne -->
					<xsl:when test="$pocetChyb>0">
						<td rowspan="{$pocetChyb}" class="{Status}">
							<xsl:value-of select="Status"/>
						</td>
						<td rowspan="{$pocetChyb}">
							<xsl:for-each select="Reference/ID[text()]">
								<xsl:value-of select="@keyName"/>
								<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
							</xsl:for-each>
						</td>
						<td rowspan="{$pocetChyb}">
							<xsl:for-each select="Reference/ID[text()]">
								<xsl:value-of select="."/>
								<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
							</xsl:for-each>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td class="{Status}">
							<xsl:value-of select="Status"/>
						</td>
						<td>
							<xsl:for-each select="Reference/ID[text()]">
								<xsl:value-of select="@keyName"/>
								<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
							</xsl:for-each>
						</td>
						<td>
							<xsl:for-each select="Reference/ID[text()]">
								<xsl:value-of select="."/>
								<xsl:text disable-output-escaping="yes">&lt;br&gt;</xsl:text>
							</xsl:for-each>
						</td>
					</xsl:otherwise>
				</xsl:choose>

			<td><xsl:value-of select="ErrorInfo/ErrorTypeCoded"/></td>
			<td><xsl:value-of select="ErrorInfo/ErrorCode"/></td>
			<td><xsl:value-of select="ErrorInfo/ErrorDescription"/></td>
			
  				<xsl:choose>	<!-- jestli je $pocetChyb větší než nula, tak doplňuje do řádků proměnnou rowspan, jinak ne -->
					<xsl:when test="$pocetChyb>0">
						<td rowspan="{$pocetChyb}" align="right">
							<xsl:if test="*[Status!='Ok']">
								<xsl:element name="a">
									<xsl:attribute name="href">#<xsl:value-of select="concat($kontext,$entita,$ref,'_detail')"/></xsl:attribute>
									<xsl:text>detaily</xsl:text>
								</xsl:element>
							</xsl:if>
						</td>
					</xsl:when>
					<xsl:otherwise>
						<td align="right">
							<xsl:if test="*[Status!='Ok']">
								<xsl:element name="a">
									<xsl:attribute name="href">#<xsl:value-of select="concat($kontext,$entita,$ref,'_detail')"/></xsl:attribute>
									<xsl:text>detaily</xsl:text>
								</xsl:element>
							</xsl:if>
						</td>
					</xsl:otherwise>
				</xsl:choose>    
  
      <xsl:if test="$uroven=2">
        <td align="right">
          <xsl:if test="Data">
            <xsl:element name="a">
			  		<xsl:attribute name="href">#<xsl:value-of select="Reference/ID[text()]"/>_data</xsl:attribute>
		  	 		<xsl:text>data</xsl:text>
	   	  		</xsl:element>
          </xsl:if>
        </td>
      </xsl:if>

		</tr>
		<xsl:for-each select="ErrorInfo[position()&gt;1]">
			<tr>
				<td><xsl:value-of select="ErrorTypeCoded"/></td>
				<td><xsl:value-of select="ErrorCode"/></td>
				<td><xsl:value-of select="ErrorDescription"/></td>
			</tr>
		</xsl:for-each>
		<xsl:if test="position()=last()">
			<xsl:text disable-output-escaping="yes">&lt;/tbody&gt;&lt;/table&gt;</xsl:text>
		</xsl:if>

	</xsl:template>

	<xsl:template name="Pocitadlo">
		<xsl:param name="pocet"/>
		<xsl:param name="Ok"/>
		<xsl:param name="Warning"/>
		<xsl:param name="Fatal"/>
		<table border="0" class="pocitadlo">
		<tr class="zahlavi"><td align="left">počet:</td><th align="right"><xsl:value-of select="$pocet"/></th></tr>
		<xsl:if test="$Ok!=0">
			<tr class="Ok"><td align="left">Ok:</td><th align="right"><xsl:value-of select="$Ok"/></th></tr>
		</xsl:if>
		<xsl:if test="$Warning!=0">
			<tr class="WarningError"><td align="left">WarningError:</td><th align="right"><xsl:value-of select="$Warning"/></th></tr>
		</xsl:if>
		<xsl:if test="$Fatal!=0">
			<tr class="FatalError"><td align="left">FatalError:</td><th align="right"><xsl:value-of select="$Fatal"/></th></tr>
		</xsl:if>
		</table>
	</xsl:template>

  <xsl:template match="DataNezname" name="DataNezname">
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template match="Data" name="Data">
    <xsl:variable name="TypDat"><xsl:value-of select="name(*[1])"/></xsl:variable>
    <xsl:choose>
		<xsl:when test="$TypDat='Firma' "><xsl:apply-templates select="Firma"/></xsl:when>
		<xsl:when test="$TypDat='SeznamFirem' "><xsl:apply-templates select="SeznamFirem"/></xsl:when>
		<xsl:when test="$TypDat='KmKarta' "><xsl:apply-templates select="KmKarta"/></xsl:when>
		<xsl:when test="$TypDat='SeznamKmKarta' "><xsl:apply-templates select="SeznamKmKarta"/></xsl:when>
		<xsl:when test="$TypDat='Sklad' "><xsl:apply-templates select="Sklad"/></xsl:when>
		<xsl:when test="$TypDat='SeznamSkladu' "><xsl:apply-templates select="SeznamSkladu"/></xsl:when>
		<xsl:when test="$TypDat='Zasoba' "><xsl:apply-templates select="Zasoba"/></xsl:when>
		<xsl:when test="$TypDat='SeznamZasoba' "><xsl:apply-templates select="SeznamZasoba"/></xsl:when>
		<xsl:when test="$TypDat='Zakazka' "><xsl:apply-templates select="Zakazka"/></xsl:when>
		<xsl:when test="$TypDat='FaktVyd' "><xsl:apply-templates select="FaktVyd"/></xsl:when>
		<xsl:when test="$TypDat='FaktVyd_DPP' "><xsl:apply-templates select="FaktVyd"/></xsl:when>
		<xsl:when test="$TypDat='FaktPrij' "><xsl:apply-templates select="FaktPrij"/></xsl:when>
		<xsl:when test="$TypDat='FaktPrij_DPP' "><xsl:apply-templates select="FaktPrij"/></xsl:when>
		<xsl:when test="$TypDat='PokDokl' "><xsl:apply-templates select="PokDokl"/></xsl:when>
		<xsl:when test="$TypDat='BankDokl' "><xsl:apply-templates select="BankDokl"/></xsl:when>
		<xsl:when test="$TypDat='IntDokl' "><xsl:apply-templates select="IntDokl"/></xsl:when>
		<xsl:when test="$TypDat='Pohledavka' "><xsl:apply-templates select="Pohledavka"/></xsl:when>
		<xsl:when test="$TypDat='Zavazek' "><xsl:apply-templates select="Zavazek"/></xsl:when>
		<xsl:when test="$TypDat='ObjPrij' "><xsl:apply-templates select="ObjPrij"/></xsl:when>
		<xsl:when test="$TypDat='NabPrij' "><xsl:apply-templates select="NabPrij"/></xsl:when>
		<xsl:when test="$TypDat='PoptPrij' "><xsl:apply-templates select="PoptPrij"/></xsl:when>
		<xsl:when test="$TypDat='ObjVyd' "><xsl:apply-templates select="ObjVyd"/></xsl:when>
		<xsl:when test="$TypDat='NabVyd' "><xsl:apply-templates select="NabVyd"/></xsl:when>
		<xsl:when test="$TypDat='PoptVyd' "><xsl:apply-templates select="PoptVyd"/></xsl:when>
		<xsl:when test="$TypDat='Prijemka' "><xsl:apply-templates select="Prijemka"/></xsl:when>
		<xsl:when test="$TypDat='Vydejka' "><xsl:apply-templates select="Vydejka"/></xsl:when>
		<xsl:when test="$TypDat='DLPrij' "><xsl:apply-templates select="DLPrij"/></xsl:when>
		<xsl:when test="$TypDat='DLVyd' "><xsl:apply-templates select="DLVyd"/></xsl:when>
		<xsl:when test="$TypDat='Prodejka' "><xsl:apply-templates select="Prodejka"/></xsl:when>
		<xsl:when test="$TypDat='Prevodka' "><xsl:apply-templates select="Prevodka"/></xsl:when>
		<xsl:when test="$TypDat='InvDoklad' "><xsl:apply-templates select="InvDoklad"/></xsl:when>
		<xsl:when test="$TypDat='Cinnost' "><xsl:apply-templates select="Cinnost"/></xsl:when>
		<xsl:when test="$TypDat='Stredisko' "><xsl:apply-templates select="Stredisko"/></xsl:when>
		<xsl:when test="$TypDat='ClenDPH' "><xsl:apply-templates select="ClenDPH"/></xsl:when>
		<xsl:when test="$TypDat='UcOsnova' "><xsl:apply-templates select="UcOsnova"/></xsl:when>
		<xsl:when test="$TypDat='UcPohyb' "><xsl:apply-templates select="UcPohyb"/></xsl:when>
		<xsl:when test="$TypDat='ZauctovaniDPH' "><xsl:apply-templates select="ZauctovaniDPH"/></xsl:when>
		<xsl:when test="$TypDat='ZauctovaniDPH_DE' "><xsl:apply-templates select="ZauctovaniDPH_DE"/></xsl:when>
		<xsl:when test="$TypDat='Predkontace' "><xsl:apply-templates select="Predkontace"/></xsl:when>
		<xsl:when test="$TypDat='PredkontaceDE' "><xsl:apply-templates select="PredkontaceDE"/></xsl:when>
		<xsl:when test="$TypDat='BankUcetPokladna' "><xsl:apply-templates select="BankUcetPokladna"/></xsl:when>
	      <xsl:otherwise>
	        <xsl:for-each select="*">
	          <xsl:call-template name="DataNezname"/>
	        </xsl:for-each>
	      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ZobrazData">
		<xsl:for-each select="*">
		<xsl:if test="Data">
		  <xsl:text disable-output-escaping="yes">&lt;br&gt;&lt;hr&gt;</xsl:text>
      <xsl:element name="a">
			  <xsl:attribute name="name"><xsl:value-of select="Reference/ID[text()]"/>_data</xsl:attribute>
		  </xsl:element>
      <table border="0" class="nadpis" width="100%">
				<tbody class="nadpis"><tr>
				<td align="left">
				<xsl:element name="h2">
					<xsl:value-of select="Reference/ID[text()]"/>
				</xsl:element>
				</td>
				<td align="right">
				<xsl:element name="a">
					<xsl:attribute name="href">#obsah</xsl:attribute><xsl:text>[späť]</xsl:text>
				</xsl:element>
				</td>
				</tr></tbody>
			</table>
		  <xsl:apply-templates select="Data"/>
    </xsl:if>
    </xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
