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





