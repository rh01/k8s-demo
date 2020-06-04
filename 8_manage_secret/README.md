## 使用kubernetes来管理Secret

Kubernetes允许通过使用环境变量或存储卷挂载到Pod上。因此本文主要介绍如何使用kubernetes管理应用的Secret。

### 创建密钥

Kubernetes要求将密钥编码为Base64字符串。
通过使用命令行工具可以创建Base64字符串并将其存储为变量以在yaml文件中使用。如下面命令所示，生成了一个Base64编码的密钥。

```bash
username=$(echo -n "admin" | base64)
password=$(echo -n "chjkk@#hjkk" | base64)
```

可以通过yaml文件来定义secret对象，并将`username`和`password` 作为数据存储在secret中。
```bash
cat  <<EOF >> secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
type: Opaque
data:
  username: $username
  password: $password
EOF
```

使用下面命令可以创建一个secret对象。

```bash
kubectl create -f secret.yaml
```

使用下面命令可以查看定义的所有secrets集合。
```
kubectl get secrets
```

### 通过环境变量来引用secret对象


### 将secret对象持久化到卷中并使用pod来引用

