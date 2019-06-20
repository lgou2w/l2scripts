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
        read -p "你正在删除 $del_image 是否确认? [y/N]" choice
        if [[ ${choice} == "y" ]]; then
            docker image rm ${del_image}
        else
            echo "取消删除"
        fi
        docker_image_management
        ;;
    pr)
        docker image prune
        docker_image_management
        ;;
    *)
        echo "你在选什么选项啊555 正在返回到主菜单"
        main_menu
        ;;
    esac
}
control_docker() {
    docker container ls
    local ${docker_name}
    local ${method}
    local ${exec_method}
    read -n4 -p "请输入你想进入的Docker (id前4位) " docker_name
    echo
    read -n1 -p "输入1执行一行命令/2开启终端 " method
    case "${method}" in
    1)
        exec_method="-i"
        echo
        read -p "请输入执行的指令(单行" command
        ;;
    2)
        exec_method="-i -t"
        command="bash"
        ;;
    *)
        echo
        echo " ...你确定输入了正确的选项？ 正在返回至主菜单"
        main_menu
        ;;
    esac
    docker exec ${exec_method} ${docker_name} ${command}
}
docker_run() {
    local ${image}
    local ${method}
    local ${command}
    local ${launch_opition}
    local ${container_name}
    local ${remove}
    local ${port}
    launch_opition="-ti -d"
    expose_port="-p "
    container_name="--name "
    docker image list
    echo "请输入你打算启动的容器/如果不存在会自动pull"
    read image
    echo "简单启动ez/复杂启动nez(默认ez)"
    read method
    if [[ -z ${method} ]]; then
            method="ez"
    fi
    case "${method}" in
    ez)
        echo "请输入你打算执行的指令(默认bash)"
        read command
        if [[ -z ${command} ]]; then
            command="/bin/bash"
        fi
        read -p "请输入你打算的container名字/不输入由daemon自动分配" name
        if [[ -z ${name} ]]; then
            container_name=""
        else
            container_name="$container_name$name"
        fi
        echo
        read -p "请输入你打算从容器内暴露的端口 格式xxx:xxx(容器内/服务器)" port
        if [[ -z ${port} ]]; then
            expose_port=""
        else
            expose_port="$expose_port$port"
        fi
        read -p "你打算在容器退出后清理文件吗(true/false)|默认true" remove
        if [[ -z ${rm} ]]; then
            remove="true"
        fi
        echo "正在用你设定的方法启动容器"
        docker run ${launch_opition} ${expose_port} ${container_name} ${image} ${command}
        docker ps
        ;;
        nez)
        echo TODO
        ;;
        *)
        echo TODO
        ;;
    esac
}
docker_run
