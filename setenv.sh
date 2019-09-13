#!/bin/bash

DIR=`pwd`
export PATH=$DIR/bin:$PATH
export KUBECONFIG=$DIR/config/config
export COHERENCE_HOME=$DIR/coherence
helm init --client-only
helm version
kubectl version

while :
do
   echo -n "What is your assigned user number?: "
   read n
   validate=`echo "$n" | grep -E ^\-?[0-9]+$`
   if [ -z "$validate" ] ; then
      echo "Please enter a number"
   elif [ -z "$n" -o $n -lt 0 -o $n -gt 99 ]  2>/dev/null ; then
      echo "Please enter a number from 1 to 99"
   else
      export NAMESPACE="ns-user-`echo $n | awk '{printf "%02d", $1}'`"
      echo "NAMESPACE environment variable set to $NAMESPACE"
      break
   fi
done
