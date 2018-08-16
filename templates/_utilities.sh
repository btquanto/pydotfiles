function set_proxy_simple () {
    echo -n 'Proxy uri: '
    read proxy_uri
    export HTTP_PROXY="${proxy_uri}"
    export HTTPS_PROXY="${proxy_uri}"
    export FTP_PROXY="${proxy_uri}"
    echo "Proxy is set to $proxy_uri"
}

function set_proxy () {
    if [ $# -eq 0 ]
    then
        set_proxy_simple
        return
    fi
    export HTTP_PROXY="$1"
    export HTTPS_PROXY="$1"
    export FTP_PROXY="$1"
    echo "Proxy is set to $1"
}

function set_proxy_secure () {
    echo -n 'Proxy schema (http/https): '
    read proxy_schema
    echo -n 'Proxy address: '
    read proxy_uri
    echo -n 'Proxy user: '
    read proxy_id
    echo -n 'Proxy password: '
    read -s proxy_pw
    echo
    export HTTP_PROXY="${proxy_schema}://${proxy_id}:${proxy_pw}@${proxy_uri}"
    export HTTPS_PROXY="${proxy_schema}://${proxy_id}:${proxy_pw}@${proxy_uri}"
    export FTP_PROXY="${proxy_schema}://${proxy_id}:${proxy_pw}@${proxy_uri}"
    echo "Proxy is set"
}

function disable_proxy() {
    export HTTP_PROXY=""
    export HTTPS_PROXY=""
    export FTP_PROXY=""
    echo "Proxy is disabled"
}

function mux() {
    if [ $# -eq 0 ]
    then
        session=$USER
    else
        session=$1
    fi
    (tmux has -t $session && tmux attach -t $session) || tmux new -s $session;
}

function truncate_docker_logs() {
    sudo find /var/lib/docker/containers/ -type f -name '*-json.log' | xargs sudo truncate -s 0 {}
}