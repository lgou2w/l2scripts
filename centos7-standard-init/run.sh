#!/usr/bin/env bash

# Check wget component
wget=`yum list installed | grep wget`
if [[ ${wget} == '' ]]; then
    yum install wget
fi

# Setup Aliyun repository source
echo
echo ':Setup Aliyun repository source'
echo
wget -O Centos-7.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# Backup and replace
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
mv -f Centos-7.repo /etc/yum.repos.d

# Update yum
echo
echo ':Update yum'
echo
yum clean all
yum makecache
yum -y update

# Install standard components
echo
echo ':Install standard components'
echo
# Openjdk8, Git, Maven, Nodejs, Yarn
# Openjdk8
echo
echo ':Install Openjdk8'
echo
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
# Git : Current 2.22.0
echo
echo ':Install Git 2.22.0'
echo
#wget -O git-2.22.0.tar.gz https://github.com/git/git/archive/v2.22.0.tar.gz
#tar -zxvf git-2.22.0.tar.gz && rm -f git-2.22.0.tar.gz
#mv git-2.22.0 /usr/local/git
#export PATH="/usr/local/git/bin:$PATH"
yum -y install git
# Maven : Current 3.6.1
echo
echo ':Install Maven 3.6.1'
echo
wget -O apache-maven-3.6.1.tar.gz http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
tar -zxvf apache-maven-3.6.1.tar.gz && rm -f apache-maven-3.6.1.tar.gz
mv apache-maven-3.6.1 /usr/local/maven
export MAVEN_HOME="/usr/local/maven"
export PATH="$MAVEN_HOME/bin:$PATH"
# Nodejs : Current LTS 10.16.0
echo
echo ':Install Nodejs LTS 10.16.0'
echo
wget -O node-v10.16.0-linux-x64.tar.xz https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-x64.tar.xz
tar -xvf node-v10.16.0-linux-x64.tar.xz && rm -f node-v10.16.0-linux-x64.tar.xz
mv node-v10.16.0-linux-x64 /usr/local/node
export NODE_HOME="/usr/local/node"
export PATH="$NODE_HOME/bin:$PATH"
# Yarn : Current 1.16.0
echo
echo ':Install Yarn 1.16.0'
echo
wget -O yarn-v1.16.0.tar.gz https://github.com/yarnpkg/yarn/releases/download/v1.16.0/yarn-v1.16.0.tar.gz
tar -zxvf yarn-v1.16.0.tar.gz && rm -f yarn-v1.16.0.tar.gz
mv yarn-v1.16.0 /usr/local/yarn
export PATH="/usr/local/yarn/bin:$PATH"

# Update profile
source /etc/profile

# Echo versions
echo
echo ':Echo versions'
echo
java -version && javac -version && echo
git --version && echo
mvn --version && echo
echo 'Nodejs' && node --version && echo
echo 'NPM' && npm --version && echo
echo 'Yarn' && yarn --version && echo
