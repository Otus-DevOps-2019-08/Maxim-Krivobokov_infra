# Maxim-Krivobokov_infra


##Learning Packer and  Google compute engine
Что сделано:
* создана ветка packer base 
* создана папка packer. файлы-скрипты с предыдущего д/з перенесены в другую папку и убраны в .gitignore
* создан packer template ubuntu16.json б который создает образ ubuntu16 с заданнымми параметрами (образ относится к моему проекту, регион west1b, тип машины, установлены ruby, bundler, и.т.д)
* в шаблоне в разделе builders прописаны параметры образа - 
* в секции variables определены переменные, определяющие ID проекта, семейство ОС, тип машины, описание образа, ID сети, параметры диска, и теги.
* в шаблоне в разделе provisioners прописаны ссылки на файлы-скрипты install_ruby.sh и install_mongodb.sh, расположенные  в папке packer/scripts
* в файле variables.json заданы значения параметров из ubuntu16.json, файл добавлен в .gitignore
* в файле variables.json.example значения параметров project_ID и network_ID  изменены на вымышленные
* шаблон ubuntu16.json проверен командами packer inspekt (на определенность переменных) и packer validate (на синтаксис)
* шаблон исполнен командой 
	```packer build -var-file variables.json ubuntu16.json
	```
* в разделе Google compute engine -> images появился образ ubuntu16_timestamp (кучу цифр лень переписывать)
* на основе этого образа создана VM reddit-app
### основная часть д/з
* () подключились к ней по ssh, скопировали репозиторий приложения реддит, запустили bundler, запустили сервер puma 
	``` git clone -b monolith https://github.com/express42/reddit.git
	    cd reddit && bundle install
	    puma -d
	```
* проверили процесс puma (ps aux | grep puma) заодно еще раз уточнили порт - 9292
* проверили правило файервола в GCP для порта 9292 (осталось с пред. занятия)
* зашли через браузер на VM : 35.189.192.207 : 9292. Приложение reddit работает. 

###дополнительная часть д/з 
* в процессе

##Google Cloud App Deploy
testapp_IP = 35.187.167.214
testapp_port = 9292

Что сделал в этом Д\З:
* установил и настроил Gcloud SDK на локальной машине
* создал виртуальную машину reddit-app, настроил ssh соединение с ней
* установил Ruby и Bundler
* установил Mongo-DB, запустил и добавил в автозапуск
* скопировал код приложения reddit с гитхаба
* установил зависимости с помощью bundle
* запустил сервер Puma
* добавил праивло в файерволе GCP для сервера Puma
* создал скрипты install_ruby.sh install_mongodb.sh deploy.sh для автоматизации вышеупомянутых действий
* проверил срипты на другом инстансе, работают корректно
* создал файл-срипт для gcloud, который запускает инстанс, и подцепляет скрипт из файлы или url. 
	* ОШИБКА - копирует репозиторий, а дальше выполнение под вопросом, сервер Puma не установлен. Требуется доработка




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





