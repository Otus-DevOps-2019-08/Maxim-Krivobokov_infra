# Maxim-Krivobokov_infra
## Google Cloud Bastion host

Панель управления VPN доступна по адресу https://35.240.16.5
```
bastion_IP = 35.240.16.5
someinternalhost_IP = 10.132.0.3
```

### Доступ по ssh во внутреннюю сеть через bastion хост
* Соединение по SSH к хосту someinternalhost одной командой:
```
ssh -i ~/.ssh/<закрытый ключ> -A <username>@35.240.16.5 -tt 10.132.0.3
```
Для создания alias необходимо отредактировать файл `~/.ssh/config` и внести туда следующие настройки:
```
Host someinternalhost
	HostName 10.132.0.3
	User <username>
	IdentityFile ~/.ssh/<закрытый ключ>
	ProxyCommand ssh -A 35.240.16.5 nc %h %p
```

Теперь команда `ssh someinternalhost` будет создавать подключение к машине someinternalhost внутри приватной сети через бастион. 





