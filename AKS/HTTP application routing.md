
## Examples

Deploy an example app.
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: party-clippy
spec:
  template:
    metadata:
      labels:
        app: party-clippy
    spec:
      containers:
      - image: r.j3ss.co/party-clippy
        name: party-clippy
        tty: true
        command: ["party-clippy"]
        ports:
        - containerPort: 8080

```

Create a service.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: party-clippy
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: party-clippy
  type: ClusterIP

```

Get your DNS zone domain and replace in the file bellow.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: party-clippy
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
  - host: party-clippy.REPLACE-WITH-YOUR-DNS-DOMAIN.aksapp.io
    http:
      paths:
      - backend:
          serviceName: party-clippy
          servicePort: 80
        path: /

```

Then access in your browser.

[http://party-clippy.REPLACE-WITH-YOUR-DNS-DOMAIN.aksapp.io](http://party-clippy.replace-with-your-dns-domain.aksapp.io/)
