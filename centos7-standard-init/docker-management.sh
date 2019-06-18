#!/usr/bin/env bash
docker_list(){
# checking docker
docker image list
}
control_docker(){
docker container ls
local ${docker_name}
local ${method}
local ${exec_method}
read -n4 -p "请输入你想进入的Docker " docker_name
echo
read -n1 -p "输入1执行一行命令/2开启终端 " method
case "${method}" in
    1)
    exec_method="-i"
    read -p "请输入执行的指令(单行" command
    ;;
    2)
    exec_method="-i -t"
    command="bash"
	;;
esac
docker exec ${exec_method} ${docker_name} ${command}
}
control_docker