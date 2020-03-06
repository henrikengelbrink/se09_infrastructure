sleep 30

VAULT_TOKEN_NAME=`kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml describe sa vault -n vault | grep "Tokens" | awk '{print $2}'`
VAULT_TOKEN=`kubectl --kubeconfig ../L1_CloudInfrastructure/kubeconfig.yaml describe secret $VAULT_TOKEN_NAME -n vault | grep "token:" | awk '{print $2}'`
echo "{\"token\":\"$VAULT_TOKEN\"}"
