## Deploy Containers With Kubernetes

This tutorial assumes you've already installed and setup docker.
It also assumes you've set up your system to use minikube.

### 启动minikube本地集群环境

鉴于国内的网络环境，需要注意的是最好选择合适的容器仓库来下载镜像，这里我采用了阿里云的`google_containers`镜像仓库，另外为了后续
实验的方便，设置了docker的代理。

```bash
# 最好在之前设置no_proxy，防止后面因为代理的原因而出不去
# 另一种，也可以直接在minikube start之后添加no_proxy
export no_proxy=$no_proxy,$(minikube ip)
export NO_PROXY=$no_proxy,$(minikube ip)
minikube start --image-repository registry.aliyuncs.com/google_containers ----docker-env HTTP_PROXY=http://YOURPROXY:PORT  --docker-env HTTPS_PROXY=https://YOURPROXY:PORT
```

切换到当前minikube上下文环境中。

```bash
kubectl config use-context minikube
```

获取node和pod信息 

```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```



### 使用kubectl来部署容器

使用kubectl来部署应用
```bash
kubectl create deployment first-deployment --image=katacoda/docker-http-server
```

以NodePort的形式来暴露服务，也可以选择其他的方式比如`ClusterIP`,`ExternalIP`,`NodeBalancer`等等

```bash
kubectl expose deployment first-deployment --port=80 --type=NodePort
```

测试应用是否正常运行并正常访问
```bash
export ip=$(minikube ip)
export port=$(kubectl get svc first-deployment -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')
curl $ip:$port
```

### 使用yaml的方式来部署应用

#### 部署Deployment

`Deployment`对象是Kubernetes最常见的资源对象之一。`Deployment`对象定义了所需的容器规范，
以及Kubernetes其他组件用来发现并连接到应用程序的名称和标签。

```bash
cat << EOF >> deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp1
  template:
    metadata:
      labels:
        app: webapp1
    spec:
      containers:
      - name: webapp1
        image: katacoda/docker-http-server:latest
        ports:
        - containerPort: 80
EOF
```

使用如下命令将其部署到集群中

```bash
kubectl create -f deployment.yaml
```

由于它是一个Deployment对象，因此可以通过如下命令获取所有已部署对象的列表。

```bash
kubectl get deploy #deploy是deploymenr的缩写
```

可以使如下命令输出指定Deployment的详细信息，例如打印上面定义的名称为webapp1的Deployment的详细信息。

```bash
kubectl describe deployment webapp1 #deploy是deploymenr的缩写
```

#### 创建Deployment对应的Service

Service定义了应用的访问接口，在kubernetes集群中，有如下几种访问方式：

- ClusterIP 默认的方式
- NodePort 将nodePort暴露到应用部署的node节点上
- LoadBalancer 一般是云服务商提供的，例如ELB等
- Ingress 七层nginx负载均衡，


例如下面定义的Service是一个典型的NodePort Service，在只有单个主机的集群中，nodeIP就是MasterIP，如果
是多个主机的情况下，需要找到这个svc或者deployment所在的nodeIP，

另外部署多个副本或实例（往往由Deployment中`replicas`所定义）时，将基于标签选择器的label自动进行负载均衡。


```bash
cat << EOF >> service.yaml
apiVersion: apps/v1
kind: Service
metadata:
  name: webapp1
  labels:
    app: webapp1
spec:
  type: nodePort
  ports:
  - port: 80
    nodePort: 30080
  selector:
    app: webapp1
EOF
```
使用下面的命令来部署服务

```bash
kubectl create -f service.yaml
```

使用下面的命令获取所有的Service对象
```bash
kubectl get svc # svc是service的缩写
```

使用下面的命令获取指定svc的描述信息。
```bash
kubectl describe svc webapp1-svc # svc是service的缩写
```



