#!/bin/sh
if [[ $(hostname -s) = vault-0 ]]; then 
  sleep 5
  OUTPUT=/vault/output.txt
  STATUS=/vault/status.txt
  vault status >> ${STATUS?}
  export VAULT_SKIP_VERIFY=true
  
  vault operator init   >> ${OUTPUT?}
  sleep 5
  key1=$(cat ${OUTPUT?} | grep "Unseal Key 1:" | sed -e "s/Unseal Key 1: //g")
  key2=$(cat ${OUTPUT?} | grep "Unseal Key 2:" | sed -e "s/Unseal Key 2: //g")
  key3=$(cat ${OUTPUT?} | grep "Unseal Key 3:" | sed -e "s/Unseal Key 3: //g")
  root=$(cat ${OUTPUT?} | grep "Initial Root Token:" | sed -e "s/Initial Root Token: //g")
  sealed=$(cat ${STATUS?} | grep "Sealed" | sed -e "s/Sealed//g" | sed 's/[[:space:]]//g')

  if [[ "$(printf '%s' "$sealed")" == 'true' ]]; then
    vault operator  unseal ${key1?}
    vault operator  unseal ${key2?}
    vault operator  unseal ${key3?}  
    sleep 10
    vault login -no-print ${root?}
    vault operator raft snapshot restore -force /share/latestbackup.snap
    rm /share/latestbackup.snap /vault/output.txt /vault/status.txt
  else
    vault login -no-print ${root?}
    vault operator raft snapshot restore -force /share/latestbackup.snap
    rm /share/latestbackup.snap /vault/output.txt /vault/status.txt
  fi
fi
