#!/bin/bash

DIR=`pwd`
export PATH=$DIR/bin:$PATH
export KUBECONFIG=$DIR/config/config
export COHERENCE_HOME=$DIR/coherence
helm version
kubectl version

