#!/bin/bash


echo "Afiseaza lista de produse:"
echo " "
produsele="
----------------------------------------------------------
| Nume produs                     | Pret (cu TVA inclus) |
----------------------------------------------------------
| 1. Bratara de argint            | 150 RON              |
| 2. Ceas Casio                   | 200 RON              |
| 3. Casti wireless               | 300 RON              |
----------------------------------------------------------
"

echo "$produsele"

echo " "
echo "Introdu datele de facturare:"
echo " "

read -p "Numele:" nume
read -p "CIF(lasa necompletat daca nu exista):" cif
read -p "Adresa:" adresa
adresa_c=$(echo "$adresa" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
read -p "Oras:" oras
oras_c=$(echo "$oras" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
read -p "Tara:" tara

if [[ $tara == "" ]];
then
	tara="Romania"
	tara_c=$tara
else
	tara_c=$(echo "$tara" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
fi

read -p "Telefon:" telefon

echo " "

lista_produse=""

while true;
do
	read -p "Alege produsele (daca ti-ai ales produsele dorite sau daca vrei sa renunti la comanda, alege optiunea 4):" produse
	while [[ $produse -lt 1 || $produse -gt 4  ]];
	do
		read -p "Optiune invalida, alege unul dintre articolele sau optiunile din lista (1, 2, 3, etc.):" produse
	done

	case $produse in
		"4") break && echo "Terminat";;
	esac

	read -p "Ce cantitate:" cantitate
	
	produs1="<product>
        <name>Bratara de argint</name>
        <code>5443321</code>
        <isDiscount>false</isDiscount>
        <measuringUnitName>buc</measuringUnitName>
        <currency>RON</currency>
        <quantity>$cantitate</quantity>
    	<price>150</price>
    	<isTaxIncluded>true</isTaxIncluded>
    	<taxName>Normala</taxName>
    	<taxPercentage>21</taxPercentage>
    	<saveToDb>false</saveToDb>
    	<isService>false</isService>
    	</product>"

	produs2="<product>
    	<name>Ceas Casio</name>
    	<code>554453321</code>
    	<isDiscount>false</isDiscount>
    	<measuringUnitName>buc</measuringUnitName>
    	<currency>RON</currency>
    	<quantity>$cantitate</quantity>
    	<price>250</price>
    	<isTaxIncluded>true</isTaxIncluded>
    	<taxName>Normala</taxName>
    	<taxPercentage>21</taxPercentage>
    	<saveToDb>false</saveToDb>
    	<isService>false</isService>
	</product>"

	produs3="<product>
    	<name>Casti wireless</name>
    	<code>44554433</code>
    	<isDiscount>false</isDiscount>
    	<measuringUnitName>buc</measuringUnitName>
    	<currency>RON</currency>
    	<quantity>$cantitate</quantity>
    	<price>350</price>
    	<isTaxIncluded>true</isTaxIncluded>
    	<taxName>Normala</taxName>
    	<taxPercentage>21</taxPercentage>
    	<saveToDb>false</saveToDb>
    	<isService>false</isService>
	</product>"

	 case $produse in
                "1") lista_produse+=$produs1;;
                "2") lista_produse+=$produs2;;
                "3") lista_produse+=$produs3;;
        esac

 
done

#echo "$lista_produse"


echo " "

payload="
<invoice>
  <companyVatCode>ROW180986</companyVatCode>
  <client>
    <name>"$nume"</name>
    <vatCode>"$cif"</vatCode>
    <isTaxPayer>true</isTaxPayer>
    <address>"$adresa_c"</address>
    <city>"$oras_c"</city>
    <country>"$tara_c"</country>
    <phone>"$telefon"</phone>
    <saveToDb>true</saveToDb>
  </client>
  <seriesName>TestF</seriesName>
  <isDraft>false</isDraft>
  $lista_produse  
</invoice>"


raspuns=$(curl -s -H "Content-Type:application/xml"\
     -H "Accept:application/xml"\
     -H "authorization:Basic Z2VvcmdlLm5pY29sYWU4NkB5YWhvby5jb206MDAyfDk2MmU1NzVhNWE5OTYyY2JiYmU4NDQyYzI4YTQ5ODU1"\
     -X POST -d "$payload"\
     https://ws.smartbill.ro/SBORO/api/invoice | xmllint --format -)

serie_factura=$(echo "$raspuns" | grep 'series' | cut -c11- | grep -o '^[^<]*')
nr_factura=$(echo "$raspuns" | grep 'number' |  cut -c11- | grep -o '^[^<]*')

#curl -s -H "Content-Type:application/xml"\
#     -H "Accept:application/xml"\
#     -H "authorization:Basic Z2VvcmdlLm5pY29sYWU4NkB5YWhvby5jb206MDAyfDk2MmU1NzVhNWE5OTYyY2JiYmU4NDQyYzI4YTQ5ODU1"\
#     -X POST -d "$payload"\
#     https://ws.smartbill.ro/SBORO/api/invoice | xmllint --format -



echo -e "\nS-a emis factura cu seria $serie_factura si numarul $nr_factura".

# Punem rezultatul unei facturi intr-un director numit "/facturi_emise_logs" si intr-un fisier de forma factura_serie_nr.txt"
# Punem in fisier: payload-ul folosit, data exacta de emitere si numarul facturii
# Daca la emitere se genereaza eroare, atunci punem payload-ul si eroarea in fisierul facturi_emise_error_logs.txt"


rezultat_factura=$(echo "Data emiterii este:"; date ; echo " " ; echo "$payload" ; echo " " ; echo "$raspuns")
echo "$rezultat_factura" >> /home/george/teste/bash_scripting/exercices/emitere_api/facturi_emis_logs/factura_"$serie_factura"_"$nr_factura".txt






