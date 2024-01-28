#!/bin/bash

source ./.env

# check
if [ "$_NAMESPACE" = "" ];then
 echo "please input \\$_NAMESPACE"
 exit 1
fi
if [ "$_SERVICE_ACCOUNT" = "" ];then
 echo "please input \\$_SERVICE_ACCOUNT"
 exit 1
fi

kubectl get namespaces/$_NAMESPACE 2>/dev/null
check=$?
if [ $check = 1 ];then
 echo "No such namespace."
 exit 1
fi

kubectl get serviceaccount/$_SERVICE_ACCOUNT -n $_NAMESPACE 2>/dev/null
check=$?
echo $check
if [ $check = 0 ];then
 echo "$_SERVICE_ACCOUNT is already exist."
 exit 1
fi

# create manifests
_WORKDIR=./k8s-sources
_OUTPUTDIR=./k8s
_VALUE=service-account
envsubst <./${_WORKDIR}/${_VALUE}.yml >./${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}.yml
envsubst <./${_WORKDIR}/${_VALUE}-token.yml >./${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-token.yml
envsubst <./${_WORKDIR}/${_VALUE}-role.yml >./${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-role.yml
envsubst <./${_WORKDIR}/${_VALUE}-role-binding.yml >./${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-role-binding.yml

# apply manifests
kubectl apply -f ${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}.yml
kubectl apply -f ${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-token.yml
kubectl apply -f ${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-role.yml
kubectl apply -f ${_OUTPUTDIR}/${_SERVICE_ACCOUNT}-${_VALUE}-role-binding.yml
