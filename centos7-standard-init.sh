#!/usr/bin/env bash

# Check wget component
wget=`yum list installed | grep wget`
if [[ ${wget} == '' ]]; then
    yum install wget
fi

# Setup Aliyun repository source
wget https://mirrors.aliyun.com/repo/Centos-7.repo
# Backup and replace
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
mv Centos-7.repo /etc/yum.repo.d/CentOS-Base.repo

# Update yum
yum clean all
yum makecache
yum -y update

# Install standard components
# Openjdk8, Git, Maven, Nodejs, Yarn
# Openjdk8
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
# Git : Current 2.22.0
wget -O git-2.22.0.tar.gz https://github.com/git/git/archive/v2.22.0.tar.gz
tar -zxvf git-2.22.0.tar.gz && rm -f git-2.22.0.tar.gz
mv git-2.22.0 /usr/local/git
export PATH="/usr/local/git/bin:$PATH"
# Maven : Current 3.6.1
wget -O maven-3.6.1.tar.gz http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
tar -zxvf maven-3.6.1.tar.gz && rm -f maven-3.6.1.tar.gz
mv maven-3.6.1 /usr/local/maven
export MAVEN_HOME="/usr/local/maven"
export PATH="$MAVEN_HOME/bin:$PATH"
# Nodejs : Current LTS 10.16.0
wget -O node-10.16.0.tar.xz https://nodejs.org/dist/v10.16.0/node-v10.16.0-linux-x64.tar.xz
tar -xvf node-10.16.0.tar.xz && rm -f node-10.16.0.tar.xz
mv node-10.16.0 /usr/local/node
export NODE_HOME="/usr/local/node"
export PATH="$NODE_HOME/bin:$PATH"
# Yarn : Current 1.16.0
wget -O yarn-1.16.0.tar.gz https://github.com/yarnpkg/yarn/releases/download/v1.16.0/yarn-v1.16.0.tar.gz
tar -zxvf yarn-1.16.0.tar.gz && rm -f yarn-1.16.0.tar.gz
mv yarn-1.16.0 /usr/local/yarn
export PATH="/usr/local/yarn/bin:$PATH"

# Update profile
source /etc/profile

# Echo version
java -version && javac -version && echo
git --version && echo
mvn --version && echo
node --version && npm --version && echo
yarn --version && echo
