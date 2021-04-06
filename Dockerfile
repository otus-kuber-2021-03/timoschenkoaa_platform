  
FROM nginx:1.19.3-alpine
ARG nginx_uid=1001
COPY ./nginx.conf /etc/nginx/nginx.conf