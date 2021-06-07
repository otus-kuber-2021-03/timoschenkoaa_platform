  
FROM nginx:alpine

ARG USERID=1001

RUN rm /etc/nginx/conf.d/default.conf && chown ${USERID} /var/cache/nginx && chmod 775 /var/run

COPY nginx.conf /etc/nginx/conf.d

USER ${USERID}

EXPOSE 8000

ENTRYPOINT ["nginx", "-g", "daemon off;"]