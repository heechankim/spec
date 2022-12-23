#!/bin/bash

# diff with files
# target=
# diff1=$(kubectl get deploy $target -o=jsonpath={.spec.template} | jq --sort-keys .)
# diff2=$(yq <file> -o json | jq --sort-keys '.spec.template')
#diff -c <(jq --sort-keys . prod_item-api.json) <(jq --sort-keys . prod2_item-api.json)

ERROR='\033[1;91m' # Red
RESULT='\033[0;101m' # Background Red
INFO='\033[1;36m' # Cyan
EOC='\033[0m' # End of Color

RESOURCE_TYPE=
NAMESPACE=
COLOR="true"

function errorMessage {
	if [[ $COLOR == "true" ]]; then
		echo -e "${ERROR}$1${EOC}"	
		return 0;
	fi

	echo $1
}

function informMessage {
	if [[ $COLOR == "true" ]]; then
		echo -e "${INFO}$1${EOC}"	
		return 0;
	fi

	echo $1
}

function commandWithColorOutput {
	if [[ $COLOR == "true" ]]; then
		echo -en "${INFO}"
		echo -n "$1 "
		eval $2
		echo -en "${EOC}"
		return 0;
	fi
	
	echo -n "$1 "
	eval $2
}

function getKubernetesResource {
	echo $(kubectl get $1 $2 -n $3 -o=jsonpath={.spec})
}

######################################################################################
# Option settings
######################################################################################
while getopts "t:n:c" opt;
	do
		case $opt in
		t)
			RESOURCE_TYPE=$OPTARG
			;;
		n)
			NAMESPACE=$OPTARG
			;;
		c)
			COLOR="false"
			;;
		?)
			exit 2;
		esac
	done

if ! (kubectl api-resources | grep -q $RESOURCE_TYPE &> /dev/null); then
	errorMessage "Option error [t]: Wrong Kubernetes Resource."
	exit 2;
fi

# if [[ -z "$NAMESPACE" ]]; then
# 	errorMessage "Option error [n]: Namespace is missing."
# 	exit 2;
# fi

shift $((OPTIND-1))

if [[ -n "$NAMESPACE" ]]; then
	if [[ -z $1 ]]; then
        	errorMessage "Original EKS Cluster name is missing"
        	exit 2;
	fi

	if [[ -z $2 ]]; then
        	errorMessage "Target EKS Cluster name is missing"
        	exit 2;
	fi

	if [[ -z $3 ]]; then
			errorMessage "Resource is missing"
			exit 2;
	fi

	ORIGIN_CLUSTER=$1
	TARGET_CLUSTER=$2
	RESOURCE=$3
else

	if [[ -z $1 ]]; then
       		errorMessage "Original EKS Cluster name is missing"
        	exit 2;
	fi

	if [[ -z $2 ]]; then
			errorMessage "Original EKS Cluster Namespace is missing"
			exit 2;
	fi

	if [[ -z $3 ]]; then
			errorMessage "Target EKS Cluster name is missing"
			exit 2;
	fi

	if [[ -z $4 ]]; then
			errorMessage "Target EKS Cluster Namespace is missing"
			exit 2;
	fi

	if [[ -z $5 ]]; then
			errorMessage "Resource is missing"
			exit 2;
	fi

	ORIGIN_CLUSTER=$1
	ORIGIN_NAMESPACE=$2
	TARGET_CLUSTER=$3
	TARGET_NAMESPACE=$4
	RESOURCE=$5

fi
######################################################################################
# 1. Setting config file 
# 2. Get Resource configuration
# 3. Using Colordiff command
######################################################################################

informMessage "================================================================================================================================="

commandWithColorOutput "Original Cluster:" "aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $ORIGIN_CLUSTER"

if [[ -n "$NAMESPACE" ]]; then
	target1=$(getKubernetesResource $RESOURCE_TYPE $RESOURCE $NAMESPACE)
else
	target1=$(getKubernetesResource $RESOURCE_TYPE $RESOURCE $ORIGIN_NAMESPACE)
fi

commandWithColorOutput "Target Cluster:" "aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $TARGET_CLUSTER"

if [[ -n "$NAMESPACE" ]]; then
	target2=$(getKubernetesResource $RESOURCE_TYPE $RESOURCE $NAMESPACE)
else
	target2=$(getKubernetesResource $RESOURCE_TYPE $RESOURCE $TARGET_NAMESPACE)
fi

informMessage "Resource Type: $RESOURCE_TYPE"
informMessage "Resource: $RESOURCE"
informMessage "================================================================================================================================="
informMessage "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"

echo ""
echo ""

if [[ $COLOR == "true" ]]; then
	colordiff -c <(echo $target1 | jq --sort-keys .) <(echo $target2 | jq --sort-keys .)
else
	diff -c <(echo $target1 | jq --sort-keys .) <(echo $target2 | jq --sort-keys .)
fi

informMessage "================================================================================================================================="
