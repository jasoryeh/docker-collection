SUBSTITUTES="$(python -c 'import os; print(",".join( "${" + x + "}" for x in os.environ ))')"
echo "$SUBSTITUTES"
function substitute {
    mkdir -p /tmp/$1
    envsubst "$SUBSTITUTES" < $1 > /tmp/$1/tmp.txt
    cat /tmp/$1/tmp.txt > $2
}

substitute /home/container/config/nginx.conf /etc/nginx/conf.d/default.conf

if [ ! -z "$SSL_ENABLED" ]; then
    echo "Enabling SSL"
    sed -i "s/#ssl://g" /etc/nginx/conf.d/default.conf
else
    echo "Using HTTP"
    sed -i "s/#http://g" /etc/nginx/conf.d/default.conf
fi

if [ ! -z "$PROXIED" ]; then
    echo "Using proxied config"
    sed -i 's/proxy_set_header  X-Real-IP         $remote_addr;/#proxy_set_header  X-Real-IP         $remote_addr;/g' /etc/nginx/conf.d/default.conf
    sed -i 's/proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;/#proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;/g' /etc/nginx/conf.d/default.conf
    sed -i 's/proxy_set_header  X-Forwarded-Proto $scheme;/#proxy_set_header  X-Forwarded-Proto $scheme;/g' /etc/nginx/conf.d/default.conf
    sed -i 's/proxy_read_timeout                  900;/#proxy_read_timeout                  900;/g' /etc/nginx/conf.d/default.conf
fi

if [ ! -f /auth.htpasswd ]; then
    touch /auth.htpasswd
fi

IFS=';'
read -ra CRED <<< $AUTH_CREDENTIALS
for i in "${CRED[@]}"; do
    echo "->"
    IFS=':'
    read -ra PAIR <<< $i
    htpasswd -b -B /auth.htpasswd "${PAIR[0]}" "${PAIR[1]}"
    IFS=';'
done
IFS=' '

echo "Ready."
nginx -g "daemon off;"