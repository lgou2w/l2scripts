#!/usr/bin/env bash
docker_list() {
    # checking docker
    docker image list
}
docker_image_management() {
    local ${method}
    local ${pull_image}
    local ${del_image}
    local ${choice}
    choice="N"
    echo "你正在管理Docker镜像 做出操作前请务必核对操作对象"
    read -p "(目前可用的操作 ls/pull/remove(rm)/prune(pr)) " method
    case "${method}" in
        ls)
        docker image list
        docker_image_management
        ;;
        pull)
        read -p "请输入镜像名 " pull_image
        docker image pull pull_image
        ;;
        rm)
        docker image list
        read -p "请输入要删除的镜像名 " del_image
        read -p "你正在删除 ${del_image} 是否确认? [y/N]" choice
        if [[ ${choice} == "y" ]]; then
            docker image rm ${del_image}
        else
            echo "取消删除"
        fi
        docker_image_management

    esac
}
control_docker() {
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
docker_image_management
