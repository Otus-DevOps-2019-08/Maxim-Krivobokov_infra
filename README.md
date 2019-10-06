# Maxim-Krivobokov_infra

## Домашнее задание к уроку №5 Google Cloud Bastion host

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

## Домашнее задание к уроку №6. Google Cloud App Deploy
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
* создал скрипты install_ruby.sh install_mongodb.sh deploy.sh для автоматизации вышеупомянутых действий (объединены в total.sh)
* проверил срипты на другом инстансе, работают корректно
* создал файл-срипт для gcloud, который запускает инстанс, и подцепляет скрипт из файлы или url. 
	




## Домашнее задание к уроку 7- Learning Packer and  Google compute engine
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

### дополнительная часть №1 домашней работы  (В ПРОЦЕССЕ)
* создадим шаблон immutable.json, запустив инстанс из которого, получим сразу VM с установленным и запущенным сервером Пума и реддитом
* immutable.json отличается от предыдущего шаблона параметром 
```
 "image_family": "reddit-full"
```
* также в новый шаблон добавили ссылку на скрипт в разделе provisioners
```
		"type": "shell",
		"script":  "files/deploy.sh",
		"execute_command": "sudo {{.Path}}" 
``
* копируем файл deploy.sh из прошлого д/з в папку packer/files/deploy.sh
* проверили packer validate, запустили packer build c параметрами из variables.json

* запускаем VM, видим, что создана папка /home/appuser/reddit, в ней поработал bundler, но сервер puma не запущен (можно запустить руками, и "реддит" заработает)

* изменим deploy.sh, добавив автозапуск приложения reddit-app через systemd unit
* для этого создадим файл reddit-app.service, пропишем в нем параметры
* переместим его в /etc/systemd/system
* перезапустим сервис с помощью systemctl
```
	cat <<EOF > reddit-app.service
	# In progress...

	mv $reddit-app.service /etc/systemd/system/
	
	systemctl daemon-reload
	systemctl enable reddit-app.service

```

### дополнительное задание №2 домашней работы про Packer
* создадим скрипт config-scripts/create-reddit-vm.sh 
* скрипт должен запускать ВМ из образа, (семейство reddit-base) подготовленного с помощью packer в этом д\з
* работает корректно, добавлен в коммит

#### запускаем инстанс из образа reddit-base
gcloud compute instances create reddit-app \
	--image-family reddit-base\
	--tags puma-server\
	--restart-on-failure

#### создаем правило firewall
gcloud compute firewall-rules create default-puma-server2 \
	--allow=tcp:9292 \
	--target-tags="puma-server"

echo "completed"
```
## Домашнее задание к уроку 8 - знакомство с Terraform
 Что сделано:
* создали ветку terraform-1
* создали main.tf прописали в нем провайдер google, лишие файлы (*.tfvars, *.tfstate, backup и папку .terraform) убрали в .gitignore
* загрузили провайдер и начали его использовать 
``` terraform init
```
* добавили ресурсы google_compute_instance и google_firewall и описали их в main.tf
* проверили правильность с помощью
```
	terraform plan
```
* Запустили нстанс ВМ с помощью terraform apply, посмотрели файл .tfstate с помощью terraform show

* создали ssh ключ для пользователя appuser (предварительно удалив из метаданных в консоли GCP)

* добавили в метаданные ресурса goocle_compute_instance путь до публичного ключа. Использовали встроенную функцию file. 

* изменили инстанс с помощью terraform apply. Подключились к нему по ssh

* создали outputs.tf прописали в нем вывод внешнего IP адреса ВМ
```
	output "app_external_ip" {
  value = google_compute_instance.app.network_interface[0].access_config[0].nat_ip
}
```
* Чтобы созданная переменная приняла значение, используем terraform refresh. Смотрим ее командой terraform output

* Описали ресурс - фаервол в main.tf, добавили тег reddit-app для ресурса g_c_i, применили изменения
* Добавили provisioners в main.tf - file (для загрузки файла на удаленную машину) и remote.exec (для удаленного запуска скриптов)
* создал unit d файл  - puma.service  директории files/puma.service 
```
	[Unit]
	Description=Puma HTTP Server
	After=network.target

	[Service]
	Type=simple
	User=appuser
	WorkingDirectory=/home/appuser/reddit
	ExecStart=/bin/bash -lc 'puma'
	Restart=always

	[Install]
	WantedBy=multi-user.target
```
* этот файл загрузится в удал. машину для автоматизации запуска сервера Puma
* создал скрипт deploy.sh для копирования репозитория и запуска приложения reddit-app на удал. машине
* прописал параметры подключения provisioners в main.tf
* проверил работу провижинера, перезапустив все ресурсы командой terraform taunt и terraform apply
* создал файл входных переменных variables.tf, где определяются:
```
variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable private_key_path {
  description = "Path to the private key for SSH for user appuser"
}
variable zone_d {
  description = "zone of VM dislocaton"
  #зададим значение по умолчанию
  default     = "europe-east1-a"
}

```
* изменил main.tf , прописав там переменные var.project var.zone_d и.т.д.
* прописал значения переменных в файле terraform.tfvars, который отправился в .gitignore
* создал файл terraform.tfvars.example для коммита. 
* отфторматировал все конфиг. файлы командой terraform fmt
* все работает, на созданном инстансе сразу работает приложение reddit-app на порту 9292


### задание со * - to be continued ...





