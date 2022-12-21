#!/bin/bash

# diff with files
# target=
# diff1=$(kubectl get deploy $target -o=jsonpath={.spec.template} | jq --sort-keys .)
# diff2=$(yq <file> -o json | jq --sort-keys '.spec.template')

#diff -c <(jq --sort-keys . prod_item-api.json) <(jq --sort-keys . prod2_item-api.json)

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


echo "====================================================================="
aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $1


target1=$(kubectl get deploy $4 -n $3 -o=jsonpath={.spec.template})

aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $2

echo ""
echo "Namespace: $3"
echo "Target: $4"
echo "====================================================================="

target2=$(kubectl get deploy $4 -n $3 -o=jsonpath={.spec.template})


echo ""
echo ""
colordiff -c <(echo $target1 | jq --sort-keys .) <(echo $target2 | jq --sort-keys .)

