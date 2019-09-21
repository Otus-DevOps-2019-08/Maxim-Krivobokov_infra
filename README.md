# Maxim-Krivobokov_infra
Maxim-Krivobokov Infra repository

bastion_IP = 35.240.16.5
someinternalhost_IP = 10.132.0.3

1) Создан аккаунт GCP
2) Созданы 2 виртуальные машины
3) Настроены параметры сети - ip адреса и правила Firewall, доступ по SSH
4) Настроен VPN сервер на базе Pritunl (создана организация, пользователь, создан и настроен сервер, прикреплен к организации)
5) В настройках сети GCP открыт порт для сервера Pritunl

Соединение по SSH к хосту someinternalhost одной командой:
 ssh -i ~/.ssh/Maxim -A Maxim@35.240.16.5 -tt 10.132.0.3
 
 Настроен файл .ssh config для создание alias
 .ssh/config
 Host someinternalhost
 HostName 10.132.0.3
 User Maxim
 IdentityFile ~/.ssh/Maxim
 ProxyCommand ssh -A 35.240.16.5 nc %h %p
 
 
 