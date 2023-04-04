FROM nginx:latest

RUN apt-get update && apt-get install -y nginx-module-http-proxy-connect

COPY nginx.conf /etc/nginx/nginx.conf
