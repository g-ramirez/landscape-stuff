#!/bin/bash


echo "Enter HTTP verb:"
read verb

echo "Enter FQDN:"
read host

echo "Eenter the Action (eg. GetComputers):"
read action

echo "Enter Access Key:"
read key

echo "Enter Secret:"
read secret

signature=''
timestamp=$(date -Iminutes -u)


# function taken from https://gist.github.com/cdown/1163649
function url_encode() {
    local LANG=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;; 
        esac
    done
}


function gen_string_to_sign() {
	echo "${verb^^}\n$host\n/api/\naccess_key_id=$key&action=$action&signature_method=HmacSHA256&signature_version=2&timestamp=$(url_encode $timestamp)&version=2011-08-01"

}


function gen_signature() {
	local to_sign=$(gen_string_to_sign)
	local signed=$(echo -ne $to_sign | openssl dgst -sha256 -hmac $secret -binary | base64)
	signature=$(url_encode $signed)
}

function generate_url() {
	echo -e "this is you're URL:...\n"
	gen_signature
	echo "https://$host/api/?action=$action&access_key_id=$key&signature_method=HmacSHA256&signature_version=2&timestamp=$(url_encode $timestamp)&version=2011-08-01&signature=$signature"
}

generate_url
