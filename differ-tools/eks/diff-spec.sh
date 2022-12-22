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
K8S_NAMESPACE=

function errorMessage {
	echo -e "${ERROR}$1${EOC}"
}

function informMessage {
	echo -e "${INFO}$1${EOC}"
}

function commandWithColorOutput {
	echo -en "${INFO}"
	echo -n "$1 "
	eval $2
	echo -en "${EOC}"
}

######################################################################################
# Option settings
######################################################################################
while getopts "t:" opt;
do
	case $opt in
	t)
	    RESOURCE_TYPE=$OPTARG
	    ;;
#	n)
#	    echo -e "option n"
#	    K8S_NAMESPACE=$OPTARG
#	    if [[ $K8S_NAMESPACE -eq "" ]]; then echo "Option Argument is missing"; exit -1; fi
#	    ;;
	?)
	    exit -1;
	esac
done

if [[ ! ("$RESOURCE_TYPE" == "deploy" || "$RESOURCE_TYPE" == "deployment" || "$RESOURCE_TYPE" == "cronjob") ]]; then 
	errorMessage "Resource Type is invaild. Either deployment or cronjob"; 
	exit -1; 
fi

shift $((OPTIND-1))

if [[ -z $1 ]]; then
        errorMessage "Old EKS Cluster name is missing"
        exit -1;
fi

if [[ -z $2 ]]; then
        errorMessage "New EKS Cluster name is missing"
        exit -1;
fi

if [[ -z $3 ]]; then
        errorMessage "Namespace is missing"
        exit -1;
fi

if [[ -z $4 ]]; then
        errorMessage "Resource is missing"
        exit -1;
fi

OLD_CLUSTER=$1
NEW_CLUSTER=$2
NAMESPACE=$3
TARGET=$4

######################################################################################
# 1. Setting config file 
# 2. Get Resource configuration
# 3. Using Colordiff command
######################################################################################

informMessage "====================================================================="

commandWithColorOutput "Old Cluster:" "aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $OLD_CLUSTER"

target1=$(kubectl get $RESOURCE_TYPE $TARGET -n $NAMESPACE -o=jsonpath={.spec})

commandWithColorOutput "New Cluster:" "aws eks update-kubeconfig --profile aws_mfa --region ap-northeast-2 --name $NEW_CLUSTER"

informMessage "Namespace: $NAMESPACE"
informMessage "Resource: $RESOURCE_TYPE"
informMessage "Target: $TARGET"
informMessage "====================================================================="

target2=$(kubectl get $RESOURCE_TYPE $TARGET -n $NAMESPACE -o=jsonpath={.spec})


echo ""
echo ""
colordiff -c <(echo $target1 | jq --sort-keys .) <(echo $target2 | jq --sort-keys .)

