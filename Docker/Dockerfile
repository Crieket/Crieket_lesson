FROM alpine:latest
LABEL maint=OTUS 
RUN apk update && apk add nginx
RUN echo "Контейнер почти ГОТОВ"
COPY index.html /var/www/otus/index.html
COPY default.conf /etc/nginx/http.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
