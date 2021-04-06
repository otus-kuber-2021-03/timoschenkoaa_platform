  
FROM nginx:latest

ARG nginx_uid=1001
COPY web.conf /etc/nginx/conf.d/
COPY /app /app
WORKDIR /app
RUN chown -R nginx /app
EXPOSE 8000
