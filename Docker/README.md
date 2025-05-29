Описание домашнего задания

Установите Docker на хост машину

kas@Home:~/Рабочий стол/Crieket_lesson/Docker$ vagrant status
Current machine states:
Host машина на Vagrant ubuntu 22
docker                    running (virtualbox)

root@docker:/vagrant# docker -v
Docker version 28.1.1, build 4eba377

Установите Docker Compose - как плагин, или как отдельное приложение

Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)

root@docker:/vagrant# docker buildx build -t cont_nginx .
[+] Building 9.6s (10/10) FINISHED                                                                                                   docker:default
 => [internal] load build definition from Dockerfile                                                                                           0.0s
 => => transferring dockerfile: 294B                                                                                                           0.0s
 => [internal] load metadata for docker.io/library/alpine:latest                                                                               9.6s
 => [internal] load .dockerignore                                                                                                              0.0s
 => => transferring context: 2B                                                                                                                0.0s
 => [1/5] FROM docker.io/library/alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c                         0.0s
 => [internal] load build context                                                                                                              0.0s
 => => transferring context: 404B                                                                                                              0.0s
 => CACHED [2/5] RUN apk update && apk add nginx                                                                                               0.0s
 => CACHED [3/5] RUN echo "Контейнер почти ГОТОВ"                                                                                              0.0s
 => CACHED [4/5] COPY index.html /var/www/otus/index.html                                                                                      0.0s
 => [5/5] COPY default.conf /etc/nginx/http.d/default.conf                                                                                     0.0s
 => exporting to image                                                                                                                         0.0s
 => => exporting layers                                                                                                                        0.0s
 => => writing image sha256:633def05035e543c346c0fedc504f7fc7989f727e2c4df8ce47bc841fe3eb2dc                                                   0.0s
 => => naming to docker.io/library/cont_nginx      

root@docker:/vagrant# docker run -d -p 8080:80 cont_nginx:latest 
0a4b0bbf802e5d7e9c9e1f59f6b25f51f2c48a0d5024240c3fba320c58254d37
root@docker:/vagrant# docker ps -a
CONTAINER ID   IMAGE               COMMAND                  CREATED          STATUS          PORTS                                     NAMES
0a4b0bbf802e   cont_nginx:latest   "nginx -g 'daemon of…"   12 seconds ago   Up 11 seconds   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   agitated_hypatia


Определите разницу между контейнером и образом

Docker-container - приложение созданое/построенное на основе образа
root@docker:/vagrant# docker ps -a
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS                     PORTS     NAMES
a332eaca9e0e   cont_nx:latest   "nginx -g 'daemon of…"   5 minutes ago   Exited (1) 5 minutes ago             admiring_hawking

Docker-image - образ на основе которого мы создаем приложение в контейнере со всеми зависимостями
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
cont_nx      latest    c5d83e456491   9 minutes ago   11.8MB


root@docker:/vagrant# curl localhost:8080
<!DOCTYPE html>
<html>
    <head>
        <title>MY DOCKER!!</title>
    </head>

    <body>
        <h1>My HELLO WORLD </h1>
        <p>Custom OTUS page</p>
    </body>

</html>
root@docker:/vagrant# 


Ответьте на вопрос: Можно ли в контейнере собрать ядро?

Собрать ядро - можно? но нужно ли ?=) 
Работать не будет так как не ОС


