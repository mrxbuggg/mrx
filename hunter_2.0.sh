#!/bin/bash

# set target
read -p "Digite o domínio-alvo: " target
#
mkdir -p "$target"
#
echo echo "Please choose from the following options for crate more folders:"
echo "1. ALL"
read menu1

if [[ $menu1 == *"1" ]]; then
   mkdir JS
   mkdir JSON
   mkdir TXT
   mkdir XML
   mkdir PDF
fi
echo "movendo para pasta do alvo"
mv JS JSON TXT XML PDF "$target"
#
echo "directory created" | lolcat
# Enumerating subdomains 
echo "running first enumeration"
subfinder -d "$target" -silent | anew "$target/subdomains.txt" | lolcat 
amass enum -d "$target" -silent | anew "$target/subdomains.txt" | lolcat
assetfinder "$target" | anew "$target/subdomains.txt" | lolcat
echo "first enumeration finished"
# premut
echo "premut running"
cat "$target/subdomains.txt" | alterx -enrinch | anew "$target/premut.txt" | lolcat
# validating domains and passing to http
echo "domain validation running"
cat "$target/subdomains.txt" "$target/premut.txt" | dnsx | anew "$target/dnx_domains.txt" | lolcat
echo "domain validation finished"
# collecting urls
echo "running url collection"
cat "$target/dnx_domains.txt" | waybackurls | anew "$target/wayback_urls.txt" | lolcat
cat "$target/dnx_domains.txt" | gau | anew  "$target/gau_urls.txt" | lolcat
cat "$target/dnx_domains.txt" | katana | anew "$target/katana.urls.txt" | lolcat
cat "$target/wayback_urls.txt" "$target/gau_urls.txt" "$target/katana.urls.txt" | anew "$target/final_crawler.txt" | lolcat
echo "finished url collection"
# + urls
echo "JS urls"
cat "$target/final_crawler.txt" | grep .js | anew "$target/JS/js.txt"
cat "$target/final_crawler.txt" | grep .json | anew "$target/JSON/json.txt"
cat "$target/final_crawler.txt" | grep .txt | anew "$target/TXT/text.txt"
cat "$target/final_crawler.txt" | grep .xml | anew "$target/XML/Xml.txt"
# Filter only URLs parameters and save to file "parameters.txt"
echo "leaving only parameters"
cat anew "$target/final_crawler.txt" | grep = | anew "$target/parametros.txt" | lolcat
#
echo "Please choose from the following options for nuclei templates:"
echo "1. cves"
echo "2. vulnerabilities"
echo "3. exposed-panels"
echo "4. exposures"
echo "5. file"
echo "6. miscellaneous"
echo "7. misconfiguration"
echo "8. technologies"
echo "9. All Templates AKA Hail Mary (Takes Hours)"
echo "Enter the numbers separated by commas:"
read templates

if [[ $templates == *"1"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/cves/"
fi

if [[ $templates == *"2"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/vulnerabilities/"
fi

if [[ $templates == *"3"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/exposed-panels/"
fi

if [[ $templates == *"4"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/exposures/"
fi

if [[ $templates == *"5"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/file/"
fi

if [[ $templates == *"6"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/miscellaneous/"
fi

if [[ $templates == *"7"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/misconfiguration/"
fi

if [[ $templates == *"8"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/technologies/"
fi

if [[ $templates == *"9"* ]]; then
  t_args="$t_args -t /root/nuclei-templates"
fi

echo "Starting Nuclei scan with the selected templates..."
cat "$target/parametros.txt" | nuclei -stats -si 100 $t_args -o "$target/nuclei_results_for_$target.txt" | notify
# Matrix effect
echo "Entering the Matrix for 5 seconds:" | toilet --metal -f term -F border

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
P='\033[0;35m'
C='\033[0;36m'
W='\033[1;37m'

for ((i=0; i<5; i++)); do
    echo -ne "${R}10 ${G}01 ${Y}11 ${B}00 ${P}01 ${C}10 ${W}00 ${G}11 ${P}01 ${B}10 ${Y}11 ${C}00\r"
    sleep 0.2
    echo -ne "${R}01 ${G}10 ${Y}00 ${B}11 ${P}10 ${C}01 ${W}11 ${G}00 ${P}10 ${B}01 ${Y}00 ${C}11\r"
    sleep 0.2
    echo -ne "${R}11 ${G}00 ${Y}10 ${B}01 ${P}00 ${C}11 ${W}01 ${G}10 ${P}00 ${B}11 ${Y}10 ${C}01\r"
    sleep 0.2
    echo -ne "${R}00 ${G}11 ${Y}01 ${B}10 ${P}11 ${C}00 ${W}10 ${G}01 ${P}11 ${B}00 ${Y}01 ${C}10\r"
    sleep 0.2
done