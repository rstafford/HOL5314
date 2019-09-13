#!/bin/bash

DIR=`pwd`
export PATH=$DIR/bin:$PATH
export KUBECONFIG=$DIR/config/config
helm version
kubectl version

