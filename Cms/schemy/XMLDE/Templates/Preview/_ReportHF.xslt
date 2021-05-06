<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">

<!-- Transformační šablona náhledu určená pro zobrazení výstupní zprávy z generování hromadných faktur ve tvaru HTML. -->

  <xsl:import href="_Report.xslt"/>

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:preserve-space elements="*"/>

	<xsl:template match="/">
	<html>
		<head>
			<title>Hromadná fakturácia</title>
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
	.odsad_N {padding-top: 5px;}
	.odsad_D {padding-bottom: 5px;}
	.radius {border-radius: 10px;}    

        ]]>
			</style>
		</head>
		<body>
			<xsl:apply-templates>
				<xsl:with-param name="NadpisPerFakt">Hromadná fakturácia - výstupná správa</xsl:with-param>
			</xsl:apply-templates>
		</body>
	</html>
	</xsl:template>

</xsl:stylesheet>
