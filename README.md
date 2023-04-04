# Nginx Forward Proxy Deployment using Ubuntu
This project provides step-by-step instructions for deploying an Nginx forward proxy in a Kubernetes cluster using Ubuntu.

# Introduction
An HTTP proxy is a server that acts as an intermediary between clients and servers, forwarding HTTP requests and responses. Nginx can act as an HTTP forward proxy in its default configuration, but it cannot handle HTTPS requests without additional configuration or modules. To enable Nginx to handle HTTPS requests as a forward proxy, we will use the ngx_http_proxy_connect_module, which adds support for the CONNECT method used by HTTPS requests.

# Prerequisites
Docker
kubectl

# Step 1: Create a Dockerfile
The first step is to create a Dockerfile for the Nginx forward proxy. Here's an example: [Dockerfile](./Dockerfile).
This Dockerfile installs the nginx-module-http-proxy-connect package, which provides the ngx_http_proxy_connect_module. It also copies the Nginx configuration file, nginx.conf, to the appropriate directory.




- Installing Docker Step.
- Creating Dockerfile to make custom nginx image with ngx_http_proxy_connect_module
-Here is the Dockerfile used to create the Nginx forward proxy:


# Use the official Nginx image as the base image
FROM nginx

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf
Deployment YAML
Here is the YAML file used to describe the deployment:

yaml
Copy code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-proxy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-proxy
  template:
    metadata:
      labels:
        app: nginx-proxy
    spec:
      containers:
      - name: nginx-proxy
        image: my-nginx-proxy:latest
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 15
Service YAML
Here is the YAML file used to describe the service:

yaml
Copy code
apiVersion: v1
kind: Service
metadata:
  name: nginx-proxy-service
spec:
  selector:
    app: nginx-proxy
  ports:
  - name: http
    port: 80
    targetPort: 80
  type: LoadBalancer
Readiness and Liveness Probes
In the deployment YAML file, the livenessProbe and readinessProbe fields are used to configure the probes for the container. The probes are set to check the container's root path (/) every 15 seconds with an initial delay of 30 seconds.

Deployment Strategy
The default deployment strategy is used, which is "RollingUpdate". This strategy updates the pods in a rolling fashion, one at a time, ensuring that the service remains available throughout the deployment process.

Deployment Scripts
Included in this repository are two scripts for deploying and managing the application:

build.sh: Builds the Docker image and tags it with the latest version.
deploy.sh: Deploys the Kubernetes deployment and service.
Screenshots
Load Balancer

Conclusion
In this project, we created a Kubernetes deployment for an Nginx forward proxy, including configuring probes, services, and deployment strategies. With these files and scripts, you can easily deploy and manage your Nginx forward proxy in a Kubernetes cluster.
