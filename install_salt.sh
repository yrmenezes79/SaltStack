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

FASE="Inserir repositório"

echo "$(date '+%Y-%m-%d %H:%M:%S') - $FASE"
rpm --import https://repo.saltproject.io/salt/py3/redhat/9/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
check_return_code "$FASE"
curl -fsSL https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest.repo | sudo tee /etc/yum.repos.d/salt.repo
check_return_code "$FASE"

FASE="Instacao SaltStack"

echo "$(date '+%Y-%m-%d %H:%M:%S') - $FASE"
dnf install salt-master salt-minion salt-ssh salt-syndic salt-cloud salt-api
check_return_code "$FASE"
systemctl enable salt-master && systemctl start salt-master
check_return_code "$FASE"
systemctl enable salt-minion && systemctl start salt-minion
check_return_code "$FASE"
systemctl enable salt-syndic && systemctl start salt-syndic
check_return_code "$FASE"
systemctl enable salt-api && systemctl start salt-api

