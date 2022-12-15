#!/bin/bash

#diff -c <(jq --sort-keys . prod_item-api.json) <(jq --sort-keys . prod2_item-api.json)
#yq 6.\ ep-sync-cdc-delivery-info.yaml -o json | jq '.spec.template'

if [[ -z $1 ]]; then
	echo "1st argument is missing"
	exit -1;
fi

if [[ -z $2 ]]; then
	echo "2nd argument is missing"
	exit -1;
fi

if [[ -z $3 ]]; then
	echo "3rd argument is missing"
	exit -1;
fi

if [[ -z $4 ]]; then
	echo "4th argument is missing"
	exit -1;
fi


# script athena-prod-eks athena-prod item-api ./item-api.yaml

echo "====================================================================="
aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $1

target1=$(kubectl get deploy $3 -n $2 -o=jsonpath={.spec.template})

echo ""
echo "Namespace: $2"
echo "Target: $3"
echo "With File Name: $4"
echo "====================================================================="


target2=$(yq $4 -o json | jq '.spec.template')


echo ""
echo ""
colordiff -c <(echo $target1 | jq --sort-keys .) <(echo $target2 | jq --sort-keys .)

