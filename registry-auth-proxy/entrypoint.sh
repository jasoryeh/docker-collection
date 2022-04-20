SUBSTITUTES="$(python -c 'import os; print(",".join( "${" + x + "}" for x in os.environ ))')"
echo "$SUBSTITUTES"
function substitute {
    mkdir -p /tmp/$1
    envsubst "$SUBSTITUTES" < $1 > /tmp/$1/tmp.txt
    cat /tmp/$1/tmp.txt > $2
}

if [ -z "$PROXIED" ]; then
    substitute /home/container/config/nginx.conf /etc/nginx/conf.d/default.conf
else
    echo "Using proxied config"
    substitute /home/container/config/nginx.conf.proxied /etc/nginx/conf.d/default.conf
fi

IFS=';'
read -ra CRED <<< $AUTH_CREDENTIALS
for i in "${CRED[@]}"; do
    echo "->"
    IFS=':'
    read -ra PAIR <<< $i
    htpasswd -b -B -c /auth.htpasswd "${PAIR[0]}" "${PAIR[1]}"
    IFS=';'
done
IFS=' '

echo "Ready."
nginx -g "daemon off;"