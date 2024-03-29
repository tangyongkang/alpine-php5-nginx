#ANPSC Docker - 快速构建ANPSC容器环境

快速构建开发、测试、生产Docker + Alpine + PHP7 + Nginx + Composer + Supervisor + Crontab + Laravel 的Docker 容器应用环境


移除旧的版本：

    sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

安装一些必要的系统工具：

    sudo yum install -y yum-utils device-mapper-persistent-data lvm2


添加软件源信息：

    sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo



更新 yum 缓存：

    sudo yum makecache fast
    


安装 Docker-ce：

    sudo yum -y install docker-ce


启动 Docker 后台服务

    sudo systemctl start docker


测试运行 hello-world

    docker run hello-world






镜像加速       

    curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
    

##主要特性

+ 基于[Alpine Linux](https://alpinelinux.org/) 最小化Linux环境加速构建镜像。 
+ 支持Nginx虚拟站点、SSL证书服务。配置参考Nginx中`cert`与`conf.d`目录文件。

所有的容器基于Alpine Linux,默认使用`sh` shell，进入容器时使用该命令：

```bash
$ docker exec -it container_name sh
```

## 构建镜像
    git clone https://github.com/tcyfree/anpsc.git
    docker build --no-cache -t anpsc:v1 .
    
## 启动镜像
    docker run -d -p 8096:80 --name=anpsc-v2 -v /www/wwwroot/PMS1:/usr/share/nginx/html/public anpsc:v2
 
    
## 进入镜像容器内
    docker exec -it anpsc-v1 sh

        

## 推送镜像
    docker login # 先登录
    
    docker tag anpsc:v1 tcyfree/anpsc:v1
    
    docker push tcyfree/anpsc:v1

    sudo cp -r /www/wwwroot/alpine-nginx-php/php7 /root/