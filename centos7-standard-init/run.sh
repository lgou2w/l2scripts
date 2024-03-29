#!/usr/bin/env bash

# Check root
[[ $EUID != 0 ]] && echo "Can't get root permission. Are you root/sudo before you using this?" && exit 1

# Check wget component
wget=$(yum list installed | grep wget)
if [[ ${wget} == '' ]]; then
    yum -y install wget
fi

# Setup Aliyun repository source

norepo=$1

if [[ $norepo != '--no-repo' ]]; then
    echo
    echo ':Setup Aliyun repository source'
    echo
    REPOS=/etc/yum.repos.d
    if [[ ! -e "${REPOS}/CentOS-Base.repo" ]] || [[ $(grep aliyun ${REPOS}/CentOS-Base.repo) == '' ]]; then
        wget -O CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
        if [[ -e "${REPOS}/CentOS-Base.repo" ]]; then
            cp ${REPOS}/CentOS-Base.repo ${REPOS}/CentOS-Base.repo.bak
        fi
        mv -f CentOS-Base.repo ${REPOS}
        # Update yum
        echo
        echo ':Update yum'
        echo
        yum clean all
        yum makecache
        yum -y update
        yum -y install epel-release
    fi
fi

# Install standard components
# Openjdk8, Git, Maven, Nodejs, Yarn, Docker, Docker Compose
echo
echo ':Install standard components'
echo

# Openjdk8
echo
echo ':Install Openjdk8'
echo
if ! command -v javac >/dev/null; then # javac need jdk
    yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
fi

# Git : Yum repository
echo
echo ':Install Git'
echo
if ! command -v git >/dev/null; then
    yum -y install git
fi

# Maven : Current 3.6.2
echo
echo ':Install Maven 3.6.2'
echo
if ! command -v mvn >/dev/null; then
    wget -O apache-maven-3.6.2.tar.gz http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
    tar -zxvf apache-maven-3.6.2.tar.gz && rm -f apache-maven-3.6.2.tar.gz
    mkdir /usr/local/maven
    mv apache-maven-3.6.2/* /usr/local/maven
    rm -rf apache-maven-3.6.2
    echo 'export MAVEN_HOME=/usr/local/maven' >> /etc/profile
    echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> /etc/profile
fi

# Nodejs : Current LTS 12.13.0
echo
echo ':Install Nodejs LTS 12.13.0'
echo
if ! command -v node >/dev/null; then
    wget -O node-v12.13.0-linux-x64.tar.xz https://nodejs.org/dist/v12.13.0/node-v12.13.0-linux-x64.tar.xz
    tar -xvf node-v12.13.0-linux-x64.tar.xz && rm -f node-v12.13.0-linux-x64.tar.xz
    mkdir /usr/local/node
    mv node-v12.13.0-linux-x64/* /usr/local/node
    rm -rf node-v12.13.0-linux-x64
    echo 'export NODE_HOME=/usr/local/node' >> /etc/profile
    echo 'export PATH=$NODE_HOME/bin:$PATH' >> /etc/profile
fi

# Yarn : Current 1.19.1
echo
echo ':Install Yarn 1.19.1'
echo
if ! command -v yarn >/dev/null; then
    wget -O yarn-v1.19.1.tar.gz https://github.com/yarnpkg/yarn/releases/download/v1.19.1/yarn-v1.19.1.tar.gz
    tar -zxvf yarn-v1.19.1.tar.gz && rm -f yarn-v1.19.1.tar.gz
    mkdir /usr/local/yarn
    mv yarn-v1.19.1/* /usr/local/yarn
    rm -rf yarn-v1.19.1
    echo 'export PATH=/usr/local/yarn/bin:$PATH' >> /etc/profile
fi

# Docker  : Yum repository
echo
echo ':Install Docker'
echo
if ! command -v docker >/dev/null; then
    yum install -y yum-utils
    yum-config-manager add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    groupadd docker
    usermod -aG docker $USER
fi

# Docker Compose : Github : Current 1.24.1
echo
echo ':Install Docker Compose'
echo
if ! command -v docker-compose >/dev/null; then
  wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.24.1/docker-compose-Linux-x86_64
  chmod +x /usr/local/bin/docker-compose
fi

# Nano & Screen
# Installing extra tools for further mantance
echo
echo ':Install Nano & Screen'
echo
if ! command -v nano >/dev/null; then
    yum -y install nano
fi
if ! command -v screen >/dev/null; then
    yum -y install screen
fi

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
docker --version && echo
docker-compose --version && echo
