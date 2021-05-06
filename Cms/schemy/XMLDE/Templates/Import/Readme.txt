V tomto adres��i 
XMLDE \ TEMPLATES \ IMPORT: se nach�z� �ablony pro transformaci importovan�ch dokument�

POPIS TRANSFORMA�N�CH �ABLON XML DOKUMENT� DOD�VAN�CH SPOLE�NOST� C�GLER SOFTWARE, A. S.
========================================================================================

Transforma�n� �ablony XML dokument� dod�van� s instalac� programu slou�� k modifikac�m XML dokument� ve struktu�e Money S3. A� na uveden� vyj�mky (viz d�le) jsou ur�en� pro v�b�r do pole "transforma�n� �ablona" v definici importu nebo exportu.

Standardn� um�st�n� �ablon je <DATA>\XMLDE\Templates\Import, kde <DATA> je ko�enov� adres�� dat Money.

POZOR!!! P�i �prav�ch zde vyjmenovan�ch �ablon nap�ed vytvo�te jejich kopie a teprve na nich prov�d�jte �pravy! Soubory s p�vodn�mi n�zvy um�st�n� ve standardn�m adres��i mohou b�t instalac� nov�ch verz� Money p�eps�ny.


_ZrcadleniDokladu.xslt
----------------------
�ablona je ur�ena pro vytvo�en� p�ijat�ch doklad� z vydan�ch doklad� p�i v�m�n� dat mezi dv�ma obchodn�mi partnery pou��vaj�c�mi Money. Vybere z dokumentu pouze doklady vydan�, z nich vytvo�� "zrcadlov�" doklady p�ijat�. Vytvo�en� p�ijat� doklady obsahuj� pouze �daje, kter� jsou relevantn� p�i v�m�n� dokument� mezi dv�ma nez�visl�mi subjekty. Doklady tedy neobsahuj� �daje specifick� pouze pro subjekt, kter� je p�vodcem vydan�ch doklad�. Jedn� se nap��klad o �daje t�kaj�c� se ��seln� �ady a typu dokladu, skladu, st�edisek / �innost� / zak�zek apod. - tyto �daje postr�daj� pro p��jemce dokladu smysl.

_Dok1ku1_BezCD.xslt
-------------------
Doklady 1:1 bez ��sel doklad�
�ablona je ur�ena pro p�enos dat Money "1:1" mezi instancemi programu v r�mci jednoho subjektu. U doklad� vynech� ��slo dokladu. Na stran� p��jmu se doklady o��sluj�
a) podle ��seln� �ady, pokud je sou��st� p�en�en�ch dat, nebo
b) podle ��seln� �ady, kter� je ur�ena typem dokladu, pokud je sou��st� p�en�en�ch dat, nebo
c) podle ��seln� �ady, kter� je ur�ena typem dokladu specifikovan�m v konfiguraci dat v definici importu

_Dok1ku1_BezCDaSkl.xslt
-----------------------
Doklady 1:1 bez ��sel doklad� a skladu
Jako p�edchoz� �ablona. Nav�c u polo�ek dokladu vynech� �daje o skladu. Na stran� p��jmu se polo�ky za�ad� na sklad, kter� mus� b�t specifikov�n v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCR.xslt
----------------------
Doklady 1:1 bez ��sel doklad� a ��seln�ch �ad
�ablona je ur�ena pro p�enos dat Money "1:1" mezi instancemi programu v r�mci jednoho subjektu. U doklad� vynech� ��slo dokladu a ��selnou �adu. Na stran� p��jmu se doklady o��sluj�
a) podle ��seln� �ady, kter� je ur�ena typem dokladu, pokud je sou��st� p�en�en�ch dat, nebo
b) podle ��seln� �ady, kter� je ur�ena typem dokladu specifikovan�m v konfiguraci dat v definici importu

_Dok1ku1_BezCDaCRaSkl.xslt
--------------------------
Doklady 1:1 bez ��sel doklad�, ��seln�ch �ad a sklad�
Jako p�edchoz� �ablona. Nav�c u polo�ek dokladu vynech� �daje o skladu. Na stran� p��jmu se polo�ky za�ad� na sklad, kter� mus� b�t specifikov�n v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCRaTD.xslt
-------------------------
Doklady 1:1 bez ��sel doklad�, ��seln�ch �ad a typ� doklad�
�ablona je ur�ena pro p�enos dat Money "1:1" mezi instancemi programu v r�mci jednoho subjektu. U doklad� vynech� ��slo dokladu, ��selnou �adu a typ dokladu. Na stran� p��jmu se doklady o��sluj� podle ��seln� �ady, kter� je ur�ena typem dokladu, jen� mus� b�t specifikovan� v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaCRaTDaSkl.xslt
-----------------------------
Doklady 1:1 bez ��sel doklad�, ��seln�ch �ad, typ� doklad� a skladu
Jako p�edchoz� �ablona. Nav�c u polo�ek dokladu vynech� �daje o skladu. Na stran� p��jmu se polo�ky za�ad� na sklad, kter� mus� b�t specifikov�n v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaINV.xslt
-----------------------
Inventurn� doklady 1:1 bez ��sel doklad� a ��sla inventury
�ablona je ur�ena pro p�enos dat Money "1:1" mezi instancemi programu v r�mci jednoho subjektu. U inventurn�ch doklad� vynech� ��slo dokladu a ��slo inventury.
Na stran� p��jmu se doklady o��sluj� a p�i�ad� inventu�e, kter� mus� b�t specifikov�na v konfiguraci dat v definici importu.

_Dok1ku1_BezCDaINVaSkl.xslt
---------------------------
Inventurn� doklady 1:1 bez ��sel doklad�, ��sla inventury a skladu
Jako p�edchoz� �ablona. Nav�c u polo�ek dokladu vynech� �daje o skladu. Na stran� p��jmu se polo�ky p�i�ad� skladu, kter� mus� b�t specifikov�n v konfiguraci dat v definici importu.

__BezCD.xslt
__BezCDaCR.xslt
__BezCDaCRaTD.xslt
__BezCDaINV.xslt
__BezSkl.xslt
------------------
Tyto �ablony jsou pouze pomocn�, jsou vyu��van� v��e uveden�mi �ablonami a NEJSOU UR�EN� K P��M�MU POU�IT� V DEFINICI P�ENOSU!

PrenosyUc_Doklady.xslt
----------------------
�ablona p�evede skladov� polo�ky faktur na neskladov� a to v�etn� slo�en�ch polo�ek (sad a komplet�). U slo�en�ch polo�ek se p�ev�d� ty polo�ky, kter� ovliv�uj� cenov� p�ehled dokladu, tzn.:
 - u faktury p�ijat� se p�ev�d� v�echny jednoduch� pod��zen� polo�ky sady a kompletu
 - u faktury vydan� se p�ev�d� jednoduch� polo�ky sady, kter� nemaj� ��dnou nad��zenou polo�ku typu komplet a d�le v�echny polo�ky typu komplet bez jin� nad��zen� polo�ky typu komplet 
�ablona se nastavuje v syst�mov�m XML importu, kter� je automaticky zalo�en po vytvo�en� ��etn� centr�ly prost�ednictv�m apar�tu extern�ch aplikac� (viz ��etn� centr�la - propojen�
s ��etn�m klientem).

PrenosyUc_Uhrady.xslt
----------------------
Intern� �ablona pro pot�eby importu �hrad faktur p�ijat�ch a faktur vydan�ch na ��etn�m klientovi. �ablona se nastavuje v syst�mov�m XML importu, kter� je automaticky zalo�en
po vytvo�en� ��etn�ho klienta prost�ednictv�m apar�tu extern�ch aplikac� (viz ��etn� klient - propojen� s ��etn� centr�lou).

iDoklad.xslt
------------
�ablona je ur�ena pro p�enos dat z iDokladu (www.idoklad.cz). Vytv��� faktury vydan� a adresy, kter� byly po��zeny na iDokladu. �ablona se nastavuje v syst�mov�m XML importu,
kter� je automaticky zalo�en po vytvo�en� definice propojen� programu Money S3 s iDokladem prost�ednictv�m apar�tu extern�ch aplikac�.

Dochazka_import.xslt
--------------------
�ablona je ur�ena pro import dat z doch�zkov�ho syst�mu. �ablona se nastavuje v syst�mov�m XML importu, kter� je automaticky zalo�en po vytvo�en� definice propojen� programu Money S3
s doch�zkov�m syst�mem prost�ednictv�m apar�tu extern�ch aplikac�.

Xml-Money_import.xslt
---------------------
�ablona je ur�ena pro zrcadlen� faktur vydan�ch a objedn�vek vydan�ch na faktury p�ijat� a objedn�vky p�ijat�. Pou��v� se p�i p�enosu t�chto doklad� na odb�ratele.
�ablona podporuje import faktur z form�tu ISDOC. �ablona se nastavuje v syst�mov�m XML importu, kter� je automaticky zalo�en p�i prvn�m importu dokladu.

