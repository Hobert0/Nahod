V tomto adresáøi 
XMLDE \ TEMPLATES \ EXPORT: se nachází šablony pro transformaci vyexportovaných dokumentù

POPIS TRANSFORMAÈNÍCH ŠABLON XML DOKUMENTÙ DODÁVANÝCH SPOLEÈNOSTÍ CÍGLER SOFTWARE, A. S.
========================================================================================

Transformaèní šablony XML dokumentù dodávané s instalací programu slouží k modifikacím XML dokumentù ve struktuøe Money S3. Jsou urèené pro výbìr do pole "transformaèní šablona" v definici exportu.

Standardní umístìní šablon je <DATA>\XMLDE\Templates\Export, kde <DATA> je koøenový adresáø dat Money.

POZOR!!! Pøi úpravách zde vyjmenovaných šablon napøed vytvoøte jejich kopie a teprve na nich provádìjte úpravy! Soubory s pùvodními názvy umístìné ve standardním adresáøi mohou být instalací nových verzí Money pøepsány.


Dochazka_export.xslt
--------------------
Šablona je urèena pro export dat do docházkového systému. Šablona se nastavuje v systémovém XML exportu, který je automaticky založen po vytvoøení definice propojení programu Money S3
s docházkovým systémem prostøednictvím aparátu externích aplikací.

ISDOC_export.xslt
---------------------
Šablona je urèena pro pøenos faktur vydaných ve formátu ISDOC. Šablona se nastavuje v systémovém XML exportu, který je automaticky založen pøi prvním exportu dokladu.

Xml-Money_export.xslt
---------------------
Šablona je urèena pro pøenos faktur vydaných a objednávek vydaných na odbìratele (viz volba "Mail PDF s datovým souborem"). Šablona se nastavuje v systémovém XML exportu, který je automaticky založen pøi prvním exportu dokladu.
