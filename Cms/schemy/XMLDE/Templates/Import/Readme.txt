V tomto adresáøi 
XMLDE \ TEMPLATES \ IMPORT: se nachází šablony pro transformaci importovaných dokumentù

POPIS TRANSFORMAÈNÍCH ŠABLON XML DOKUMENTÙ DODÁVANÝCH SPOLEÈNOSTÍ CÍGLER SOFTWARE, A. S.
========================================================================================

Transformaèní šablony XML dokumentù dodávané s instalací programu slouží k modifikacím XML dokumentù ve struktuøe Money S3. Až na uvedené vyjímky (viz dále) jsou urèené pro výbìr do pole "transformaèní šablona" v definici importu nebo exportu.

Standardní umístìní šablon je <DATA>\XMLDE\Templates\Import, kde <DATA> je koøenový adresáø dat Money.

POZOR!!! Pøi úpravách zde vyjmenovaných šablon napøed vytvoøte jejich kopie a teprve na nich provádìjte úpravy! Soubory s pùvodními názvy umístìné ve standardním adresáøi mohou být instalací nových verzí Money pøepsány.


_ZrcadleniDokladu.xslt
----------------------
Šablona je urèena pro vytvoøení pøijatých dokladù z vydaných dokladù pøi výmìnì dat mezi dvìma obchodními partnery používajícími Money. Vybere z dokumentu pouze doklady vydané, z nich vytvoøí "zrcadlové" doklady pøijaté. Vytvoøené pøijaté doklady obsahují pouze údaje, které jsou relevantní pøi výmìnì dokumentù mezi dvìma nezávislými subjekty. Doklady tedy neobsahují údaje specifické pouze pro subjekt, který je pùvodcem vydaných dokladù. Jedná se napøíklad o údaje týkající se èíselné øady a typu dokladu, skladu, støedisek / èinností / zakázek apod. - tyto údaje postrádají pro pøíjemce dokladu smysl.

_Dok1ku1_BezCD.xslt
-------------------
Doklady 1:1 bez èísel dokladù
Šablona je urèena pro pøenos dat Money "1:1" mezi instancemi programu v rámci jednoho subjektu. U dokladù vynechá èíslo dokladu. Na stranì pøíjmu se doklady oèíslují
a) podle èíselné øady, pokud je souèástí pøenášených dat, nebo
b) podle èíselné øady, která je urèena typem dokladu, pokud je souèástí pøenášených dat, nebo
c) podle èíselné øady, která je urèena typem dokladu specifikovaným v konfiguraci dat v definici importu

_Dok1ku1_BezCDaSkl.xslt
-----------------------
Doklady 1:1 bez èísel dokladù a skladu
Jako pøedchozí šablona. Navíc u položek dokladu vynechá údaje o skladu. Na stranì pøíjmu se položky zaøadí na sklad, který musí být specifikován v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCR.xslt
----------------------
Doklady 1:1 bez èísel dokladù a èíselných øad
Šablona je urèena pro pøenos dat Money "1:1" mezi instancemi programu v rámci jednoho subjektu. U dokladù vynechá èíslo dokladu a èíselnou øadu. Na stranì pøíjmu se doklady oèíslují
a) podle èíselné øady, která je urèena typem dokladu, pokud je souèástí pøenášených dat, nebo
b) podle èíselné øady, která je urèena typem dokladu specifikovaným v konfiguraci dat v definici importu

_Dok1ku1_BezCDaCRaSkl.xslt
--------------------------
Doklady 1:1 bez èísel dokladù, èíselných øad a skladù
Jako pøedchozí šablona. Navíc u položek dokladu vynechá údaje o skladu. Na stranì pøíjmu se položky zaøadí na sklad, který musí být specifikován v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCRaTD.xslt
-------------------------
Doklady 1:1 bez èísel dokladù, èíselných øad a typù dokladù
Šablona je urèena pro pøenos dat Money "1:1" mezi instancemi programu v rámci jednoho subjektu. U dokladù vynechá èíslo dokladu, èíselnou øadu a typ dokladu. Na stranì pøíjmu se doklady oèíslují podle èíselné øady, která je urèena typem dokladu, jenž musí být specifikovaný v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCRaTDaSkl.xslt
-----------------------------
Doklady 1:1 bez èísel dokladù, èíselných øad, typù dokladù a skladu
Jako pøedchozí šablona. Navíc u položek dokladu vynechá údaje o skladu. Na stranì pøíjmu se položky zaøadí na sklad, který musí být specifikován v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaINV.xslt
-----------------------
Inventurní doklady 1:1 bez èísel dokladù a èísla inventury
Šablona je urèena pro pøenos dat Money "1:1" mezi instancemi programu v rámci jednoho subjektu. U inventurních dokladù vynechá èíslo dokladu a èíslo inventury.
Na stranì pøíjmu se doklady oèíslují a pøiøadí inventuøe, která musí být specifikována v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaINVaSkl.xslt
---------------------------
Inventurní doklady 1:1 bez èísel dokladù, èísla inventury a skladu
Jako pøedchozí šablona. Navíc u položek dokladu vynechá údaje o skladu. Na stranì pøíjmu se položky pøiøadí skladu, který musí být specifikován v konfiguraci dat v definici importu.

__BezCD.xslt
__BezCDaCR.xslt
__BezCDaCRaTD.xslt
__BezCDaINV.xslt
__BezSkl.xslt
------------------
Tyto šablony jsou pouze pomocné, jsou využívané výše uvedenými šablonami a NEJSOU URÈENÉ K PØÍMÉMU POUŽITÍ V DEFINICI PØENOSU!

PrenosyUc_Doklady.xslt
----------------------
Šablona pøevede skladové položky faktur na neskladové a to vèetnì složených položek (sad a kompletù). U složených položek se pøevádí ty položky, které ovlivòují cenový pøehled dokladu, tzn.:
 - u faktury pøijaté se pøevádí všechny jednoduché podøízené položky sady a kompletu
 - u faktury vydané se pøevádí jednoduché položky sady, které nemají žádnou nadøízenou položku typu komplet a dále všechny položky typu komplet bez jiné nadøízené položky typu komplet 
Šablona se nastavuje v systémovém XML importu, který je automaticky založen po vytvoøení úèetní centrály prostøednictvím aparátu externích aplikací (viz úèetní centrála - propojení
s úèetním klientem).

PrenosyUc_Uhrady.xslt
----------------------
Interní šablona pro potøeby importu úhrad faktur pøijatých a faktur vydaných na úèetním klientovi. Šablona se nastavuje v systémovém XML importu, který je automaticky založen
po vytvoøení úèetního klienta prostøednictvím aparátu externích aplikací (viz úèetní klient - propojení s úèetní centrálou).

iDoklad.xslt
------------
Šablona je urèena pro pøenos dat z iDokladu (www.idoklad.cz). Vytváøí faktury vydané a adresy, které byly poøízeny na iDokladu. Šablona se nastavuje v systémovém XML importu,
který je automaticky založen po vytvoøení definice propojení programu Money S3 s iDokladem prostøednictvím aparátu externích aplikací.

Dochazka_import.xslt
--------------------
Šablona je urèena pro import dat z docházkového systému. Šablona se nastavuje v systémovém XML importu, který je automaticky založen po vytvoøení definice propojení programu Money S3
s docházkovým systémem prostøednictvím aparátu externích aplikací.

Xml-Money_import.xslt
---------------------
Šablona je urèena pro zrcadlení faktur vydaných a objednávek vydaných na faktury pøijaté a objednávky pøijaté. Používá se pøi pøenosu tìchto dokladù na odbìratele.
Šablona podporuje import faktur z formátu ISDOC. Šablona se nastavuje v systémovém XML importu, který je automaticky založen pøi prvním importu dokladu.

