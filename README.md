# timoschenkoaa_platform
timoschenkoaa Platform repository

HW №1 (Знакомство с K8S, основные понятия и архитектура)

В процессе сделано:

- Настроено локальное окружение.
- Написан Dockerfile и собран контейнер с веб серевером nginx. Контейнер помещен в docker hub.
- Собран контейнер с фронтендом Hipster Shop. Контейнер помещен в docker hub

Задание 1

Разберитесь почему все pod в namespace kube-system восстановились после удаления.

Ответ: Поды kube-apiserver, etcd, kube-controller-manager, kube-scheduler - являются статическими. Kubelet демон управляет ими напрямую, без участия API сервера. kubelet мониторит каждый статический модуль и перезапускает если он упал. Для coredns указано количество реплик - 1, поэтому он запускается после старта статических подов. Т.е. всегда должен быть активен один экземпляр pod-а coredns.

Был создан Dockerfile, который: -- запускает web-сервер на порту 8000; -- отдает содержимое директории /app внутри контейнера; -- работающий с UID 1001;
Из Dockerfile был собран образ контейнера и помещен в публичный Container Registry - Docker Hub;

Был написан манифест web-pod.yaml для создания pod web, с использованием ранее собранного образа с Docker Hub.

Задание 2

Знакомство с микросервисным приложением Hipster Shop:

Был склонирован требуемый репозиторий, замет создан образ контейнера frontedn и помещен на Docker Hub.
Создан манифест frontend-pod-healthy.yaml с фиксом ошибки запуска.
Ошибка была в отсутствие описания environment variable в конфигурации манифеста.


HW №2 Механика запуска и взаимодействия контейнеров в K8S

Задание 1

- запустили кластер kind из config файла;
- создали рабочий манифест для ReplicaSet микросервиса frontend и разобрался с принципами работы контроллера ReplicaSet;
- Из Dockerfile был собран образ контейнера paymentService и помещен в публичный Container Registry - Docker Hub;
- созданы валидные манифесты  paymentservice-replicaset.yaml и paymentservice-deployment.yaml с тремя репликами, разворачивающими из образа версии v0.0.1 и v0.0.2;

Вопрос: Руководствуясь материалами лекции опишите произошедшую ситуацию, почему обновление ReplicaSet не повлекло обновление запущенных pod?
Ответ: ReplicaSet контроллер следит за количеством запущеных pod, описанных в манифест файле. Для обновления pod необходимо использовать Deployment контроллер

Задание со ⭐ С использованием параметров maxSurge и maxUnavailable самостоятельно реализуйте два следующих сценария развертывания:
Аналог blue-green:
1. Развертывание трех новых pod
2. Удаление трех старых pod

Решение описано в манифесте paymentservice-deployment-bg.yaml

Reverse Rolling Update:
1. Удаление одного старого pod
2. Создание одного нового pod

Решение описано в манифесте paymentservice-deployment-reverse.yaml

DaemonSet | Задание со ⭐ и ⭐⭐

1. Создан манифест node-exporter-serviceaccount.yaml для развертывания ServiceAccount Node Exporter
2. Создан манифест node-exporter-daemonset.yaml для развертывания DaemonSet с Node Exporter