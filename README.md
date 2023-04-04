# Nginx Forward Proxy Deployment
This project provides a Kubernetes deployment for an Nginx forward proxy.

Installation
Before you begin, make sure you have the following tools installed:

Docker
Kubernetes
You can install Kubernetes using the official documentation.

Dockerfile
Here is the Dockerfile used to create the Nginx forward proxy:


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
