#!/bin/sh
json=`mktemp`
date_csv=$(date +%Y%m%d)
date_curl=$(date +%m/%d/%Y)
echo $date_csv $date_curl
curl "https://services.arcgis.com/0L95CJ0VTaxqcmED/arcgis/rest/services/Daily_Count_COVID_view/FeatureServer/0/query?where=%20(Updated%20%3E%20%27${date_curl}%27%20AND%20RecordStat%20=%20%27Active%27)%20&outFields=*&outSR=4326&f=json" > $json

cat $json

pcr=$(jq .features[0].attributes.PCR $json)
antigen=$(jq .features[0].attributes.Antigen $json)
total=$(jq .features[0].attributes.TotalCases $json)
rm $json

if [ "$pcr" != "null" ] ; then
  echo "$date_csv,$pcr,$antigen=$total" >> cases.csv
fi
