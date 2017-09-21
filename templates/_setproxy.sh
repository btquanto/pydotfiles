function setproxy () {
    echo -n 'Proxy url: '
    read proxy_uri
    echo -n 'Proxy user: '
    read proxy_id
    echo -n 'Proxy password: '
    read -s proxy_pw
    echo
    export http_proxy="http://${proxy_id}:${proxy_pw}@${proxy_uri}"
    export https_proxy="http://${proxy_id}:${proxy_pw}@${proxy_uri}"
    export ftp_proxy="http://${proxy_id}:${proxy_pw}@${proxy_uri}"
    echo "Proxy set"
}
