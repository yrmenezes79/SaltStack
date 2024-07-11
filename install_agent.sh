#!/bin/bash

check_return_code() {
    local return_code=$?
    local message=$1

    if [ $return_code -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Erro: $message (Código de retorno: $return_code)"
        exit $return_code
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sucesso: $message"
    fi
}


function validar_ip() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}
FASE="Inserir repositório"

echo "$(date '+%Y-%m-%d %H:%M:%S') - $FASE"
rpm --import https://repo.saltproject.io/salt/py3/redhat/9/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
check_return_code "$FASE"
curl -fsSL https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo
check_return_code "$FASE"

FASE="Instacao SaltStack"

echo "$(date '+%Y-%m-%d %H:%M:%S') - $FASE"
dnf install salt-minion -y
check_return_code "$FASE"
systemctl enable salt-minion && systemctl start salt-minion
check_return_code "$FASE"

FASE="Validar IP"
# Solicita o nome
read -p "Digite o nome: " nome

# Solicita o IP
read -p "Digite o IP: " ip

# Valida o IP
if validar_ip $ip; then
    echo "$ip    $nome" | sudo tee -a /etc/hosts > /dev/null
    check_return_code "$FASE"
    sed -i 's/#master: salt/master $nome/g' /etc/salt/minion
    check_return_code "$FASE"
    systemctl restart salt-minion 
    check_return_code "$FASE"
fi
