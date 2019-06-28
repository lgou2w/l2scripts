#!/usr/bin/env bash
export counainer_count
counainer_count=(`docker container ls | awk '{print $1}' | wc -l`)
counainer_count=$(($counainer_count-1))
check_docker_daemon(){
    docker image list > /dev/null
#check exit code if = 0 in order to see docker daemon if reachable
    if [[ $? != 0 ]]; then
        echo "连接不上docker daemon..."
        echo "可能是权限不够/或者是没有进入docker组"
        echo "try sudo或者sudo groupadd docker && usermod -aG docker $USER"
        exit 1
    else
        echo "docker daemon连接成功!"
    fi
    
}
docker_list() {
    # checking docker
    docker image list
    docker container list
    main_menu
}
docker_image_management() {
    local ${method}
    local ${pull_image}
    local ${del_image}
    local ${choice}
    local ${count}
    # RE变量代表着 Regular Expression
    choice="N"
    echo "你正在管理Docker镜像 做出操作前请务必核对操作对象"
    read -p "(目前可用的操作 ls/pull/remove(rm)/rm_RE/prune(pr)) " method
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
    rm_RE)
        docker image list
        read -p "此选项用来以正则表达式删除镜像 请确认自己删除之前的镜像名" RE
        del_image=`docker image ls | grep -Eo "$RE" - | awk '{print $1}'`
        echo $del_image
        read -p "请确认想删除的镜像y/N" choice
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
    if [[ -z ${docker_name} ]]; then
        main_menu
    fi
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
    local ${method_RE}
    local ${array_image}
    launch_opition="-ti -d"
    expose_port="-p "
    container_name="--name "
    docker image list
    echo "其实可以选用RE来启动容器的y/N"
    read method_RE
    if [[ -z ${method_RE} ]]; then
            method_RE="N"
    fi
    if [[ ${method_RE} == "N" ]]; then
        echo "请输入你打算启动的容器/如果不存在会自动pull"
        read image
    elif [ ${method_RE} == "y" ]; then
        read -p "请输入你打算使用的正则表达式" RE
        image=`docker image ls | grep -Eo "$RE" - | awk '{print $1}'`
        count=`docker image ls | grep -Eo "$RE" - | awk '{print $1}' | wc -l`
        echo "这是你打算启动的镜像"
        echo ${image}
    fi

    echo "简单启动ez(默认ez)"
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
        echo "如果使用RE启动请不要设置任何名字!"
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
        if [[ ${method_RE} == "y" ]]; then
            array_image=( "${image//,/}" )
            for((;count>=0;))
                do
                    docker run ${launch_opition} ${expose_port} ${container_name} ${array_image[$count]} ${command}
                    count=$(($count-1))
                done
        fi
        echo ${array_image[*]}
        array_image=( "${image//,/}" )
        count=${#array_image[*]}
            for((;count>=0;))
                do
                    docker run ${launch_opition} ${expose_port} ${container_name} ${array_image[$count]} ${command}
                    count=$(($count-1))
                done
        docker ps
        ;;
        *)
        echo "你在选什么( 正在返回至主菜单"
        main_menu
        ;;
    esac
}
docker_network_management(){
    docker network list
    local ${method}
    local ${network_name}
    local ${container_name}
    echo "君欲何为?"
    echo "连接(co 创建(cre 断开连接(dco 详细信息(ins 列出(ls 删除(rm"
    read method
    case "${method}" in
    cre)
    read -p "你打算创建网络的名字" network_name
    docker network create --attachable true ${network_name}
    docker_network_management
    ;;
    co)
    docker container list
    read -p "要连接到网络的容器是" container_name
    read -p "网络是" network_name
    docker network connect ${network_name} ${container_name}
    ;;
    dco)
    docker network list
    read -p "网络是" network_name
    docker network inspect ${network_name}
    read -p "想要断开的容器是" container_name
    docker network disconnect ${network_name} ${container_name}
    docker_network_management
    ;;
    ins)
    read -p "你打算检查的网络是" network_name
    docker network inspect ${network_name}
    docker_network_management
    ;;
    ls)
    docker network ls
    docker_network_management
    ;;
    rm)
    docker network ls
    read -p "你打算删除的网络是(用空格分割" name
    docker network rm NETWORK ${name}
    ;;
    *)
    echo "正在返回至主菜单"
    main_menu
    ;;
esac
}
install_docker(){
    if ! command -v docker >/dev/null; then
        yum install -y yum-utils
        yum-config-manager add-repo https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
        yum install -y docker
        systemctl start docker
        systemctl enable docker
        groupadd docker
        usermod -aG docker $USER
    else
        echo "seem docker already install on this machine"
        echo "now checking daemon"
        check_docker_daemon
        main_menu
    fi
}
main_menu(){
    local ${choice}
    echo "docker manage script"
    echo "    1.镜像管理
    2.容器管理
    3.控制容器
    4.启动容器
    5.容器网络管理
    6.列出容器/镜像
    7.安装docker
    目前有${counainer_count}个容器在线"
    read -p "君欲何为?" choice
    case "${choice}" in
    1)
    docker_image_management
    ;;
    2)
    echo "TODO"
    ;;
    3)
    control_docker
    ;;
    4)
    docker_run
    ;;
    5)
    docker_network_management
    ;;
    6)
    docker_list
    ;;
    7)
    install_docker
    ;;
    *)
    echo "? 正在退出" && exit 1
    ;;
esac
}
check_docker_daemon
main_menu
