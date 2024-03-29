#!/bin/bash
# 
# Setup script for HOL
# Copright (c) 2019 Oracle

function check_result()
    {
    ret=$?
    if [ $ret -ne 0 ] ; then
       echo "Command [$1] failed"
       exit 1
    fi
    }

if [ -z "$COHERENCE_HOME" ]; then
   echo "Ensure you have run . ./setenv.sh"
   exit
fi

DIR=`pwd`
mkdir -p $DIR/logs
exec | tee  $DIR/logs/setup.log 2>&1

echo "Adding Helm Repositories"

helm repo add coherence https://oracle.github.io/coherence-operator/charts
helm repo update
helm repo list

echo "Cloning Coherence Operator"

cd ..
git clone https://github.com/oracle/coherence-operator.git
cd coherence-operator
git checkout gh-pages
cd ..

echo "Cloning Coherence-Demo"
git clone https://github.com/coherence-community/coherence-demo.git

cd $DIR
echo "Unzipping Coherence"
unzip -o $DIR/zip/coherence-java-12.2.1.3.3b74317.zip

if [ ! -d $DIR/coherence ] ; then
   echo "Coherence was not correctly unzipped"
   exit 1
fi

echo "Installing Coherence Maven JARS"

mvn install:install-file -Dfile=$COHERENCE_HOME/lib/coherence.jar      -DpomFile=$COHERENCE_HOME/plugins/maven/com/oracle/coherence/coherence/12.2.1/coherence.12.2.1.pom
mvn install:install-file -Dfile=$COHERENCE_HOME/lib/coherence-rest.jar -DpomFile=$COHERENCE_HOME/plugins/maven/com/oracle/coherence/coherence-rest/12.2.1/coherence-rest.12.2.1.pom

echo "Building Coherence Operator Samples"
cd $DIR/../coherence-operator/docs/samples
mvn clean install -DskipTests -Dcoherence.version=12.2.1-3-3
check_result "coherence-operator build"

