V tomto adres��i 
XMLDE \ TEMPLATES \ EXPORT: se nach�z� �ablony pro transformaci vyexportovan�ch dokument�

POPIS TRANSFORMA�N�CH �ABLON XML DOKUMENT� DOD�VAN�CH SPOLE�NOST� C�GLER SOFTWARE, A. S.
========================================================================================

Transforma�n� �ablony XML dokument� dod�van� s instalac� programu slou�� k modifikac�m XML dokument� ve struktu�e Money S3. Jsou ur�en� pro v�b�r do pole "transforma�n� �ablona" v definici exportu.

Standardn� um�st�n� �ablon je <DATA>\XMLDE\Templates\Export, kde <DATA> je ko�enov� adres�� dat Money.

POZOR!!! P�i �prav�ch zde vyjmenovan�ch �ablon nap�ed vytvo�te jejich kopie a teprve na nich prov�d�jte �pravy! Soubory s p�vodn�mi n�zvy um�st�n� ve standardn�m adres��i mohou b�t instalac� nov�ch verz� Money p�eps�ny.


Dochazka_export.xslt
--------------------
�ablona je ur�ena pro export dat do doch�zkov�ho syst�mu. �ablona se nastavuje v syst�mov�m XML exportu, kter� je automaticky zalo�en po vytvo�en� definice propojen� programu Money S3
s doch�zkov�m syst�mem prost�ednictv�m apar�tu extern�ch aplikac�.

ISDOC_export.xslt
---------------------
�ablona je ur�ena pro p�enos faktur vydan�ch ve form�tu ISDOC. �ablona se nastavuje v syst�mov�m XML exportu, kter� je automaticky zalo�en p�i prvn�m exportu dokladu.

Xml-Money_export.xslt
---------------------
�ablona je ur�ena pro p�enos faktur vydan�ch a objedn�vek vydan�ch na odb�ratele (viz volba "Mail PDF s datov�m souborem"). �ablona se nastavuje v syst�mov�m XML exportu, kter� je automaticky zalo�en p�i prvn�m exportu dokladu.
