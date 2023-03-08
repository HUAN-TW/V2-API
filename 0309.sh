#更改源站
#$1 Your-key
#$2 Domain to be changed".
#$3 New origin FQDN or IPs
#You can input multiple IP addresses, separated by spaces
if echo "$3" | grep -E -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$|^([A-F0-9]{1,4}:){7}[A-F0-9]{1,4}$'; then
    #echo "IPcheck";
    values=("${@:3}")
        if [ "${#values[@]}" -eq 1 ]; then
            echo "\"${values[0]}\""
            ip_list="\"${values[0]}\""
                else
                    output=$(printf '"%s",' "${values[@]}")
                    echo "${output%,}"
                    ip_list="${output%,}"
        fi
            for DOMAIN in $2
                do
                    ID=$(curl --request GET   --url "https://api.mlytics.com/zone/apiv2/zones/?page_size=-1&absolute_page=1" --header 'apikey: ywhYbFyanJIr0q9xeJezgU884STJpoxu' -s | jq -c '.data[]? |{domain: .domain, ID: .organizationID } |select(.domain == "'$DOMAIN'")' |xargs |grep -Eo 'ID:[0-9]+'| cut -d ":" -f2)
                    echo "$ID"
                    echo "$2"
                    datetime=$(date +"%Y-%m-%d %H:%M:%S")
                    sleep 3;
                    output=$(
                    curl "https://api-v2.mlytics.com/web/v2/zones/$2/?org_id=$ID" \
                    -X 'PATCH' \
                    --header "apikey: $1" -s\
                    --data-raw '{"origin":{"sources":['$ip_list'],"type":"IPv4","balanceMode":"consistent"}}'\
                    --compressed)| jq '{domain: .data.domain, status: .meta.status}'  ;
                    output_with_datetime="$datetime $output";
                    echo "$output_with_datetime" >>/private/tmp/origin-change.log;
            done
    
else
    #echo "FQDNcheck";
        for DOMAIN in $2
        do
        ID=$(curl --request GET   --url "https://api.mlytics.com/zone/apiv2/zones/?page_size=-1&absolute_page=1" --header 'apikey: ywhYbFyanJIr0q9xeJezgU884STJpoxu' -s | jq -c '.data[]? |{domain: .domain, ID: .organizationID } |select(.domain == "'$DOMAIN'")' |xargs |grep -Eo 'ID:[0-9]+'| cut -d ":" -f2)
        datetime=$(date +"%Y-%m-%d %H:%M:%S")
        sleep 3;
        output=$(  
        curl "https://api-v2.mlytics.com/web/v2/zones/$2/?org_id=$ID" \
        -X "PATCH" \
        --header "apikey: $1" -s\
        --data-raw '{"origin":{"sources":["'$3'"],"type":"FQDN","balanceMode":"consistent"}}'\
        --compressed | jq '{domain: .data.domain, status: .meta.status}' ) ;
        output_with_datetime="$datetime $output";
        echo "$output_with_datetime" >>/private/tmp/origin-change.log ;
    done
fi