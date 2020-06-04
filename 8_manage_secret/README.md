## 使用kubernetes来管理Secret

Kubernetes允许通过使用环境变量或存储卷挂载到Pod上。因此本文主要介绍如何使用kubernetes管理应用的Secret。

### 创建密钥

Kubernetes要求将密钥编码为Base64字符串。
通过使用命令行工具可以创建Base64字符串并将其存储为变量以在yaml文件中使用。如下面命令所示，生成了一个Base64编码的密钥。

```bash
username=$(echo -n "admin" | base64)
password=$(echo -n "chjkk@#hjkk" | base64)
```

Secret对象是使用yaml定义的。
下我们将使用上面定义的变量，并为它们提供友好的标签，
供我们的应用程序使用。这将创建可以通过名称（在本例中为test-secret）访问的键/值密钥对的集合。
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

使用kubectl创建我们的秘密。

```bash
kubectl create -f secret.yaml
```

以下命令允许您查看定义的所有秘密集合。
```
kubectl get secrets
```

我们将通过Pod使用这些机密。
