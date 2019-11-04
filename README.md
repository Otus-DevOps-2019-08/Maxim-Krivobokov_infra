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
```
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

####  запускаем инстанс из образа reddit-base
```
$ gcloud compute instances create reddit-app \
	--image-family reddit-base\
	--tags puma-server\
	--restart-on-failure
```
#### создаем правило firewall
```
$ gcloud compute firewall-rules create default-puma-server2 \
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

## Домашнее задание к уроку №9 - Принципы организации структурного кода и работа над инфраструктурой в команде на примере Terraform

Что сделано:
* создал ветку terraform-2, работаем в ней, скопировав все материалы из прошлой работы
* добавил в main.tf ресурс "firewall-ssh"
* импортировал правило файервола в структуру Terraform, используя команду terraform import
```
 terraform import google_compute_firewall.firewall_ssh default-allow-ssh
 terraform apply
```
* прописал IP адрес, как внешний ресурс, добавил в main.tf
``` 
 resource "google_compute_address" "app_ip" {
 name = "reddit-app-ip" }
```
* добавил ссылку на атрибуты  ресурса IP внутри конфигурации ресурса VM
```
 network_interface {
  network = "default"
  access_config = {
    nat_ip = google_compute_address.app_ip.address }
```
##### используем структуризацию ресурсов #####
* провел структуризацию ресурсов - вынес БД MongoDB на отдельную ВМ, и Ruby на другую ВМ
* для этого созданы packer - шаблоны app.json и db.json
* app.json создает образ с именем reddit-rubyapp, db.json => reddit.db
* создал два конфиг файла - app.tf db.tf, в них описаны параметры для настройки двух ВМ
* правило файервола ssh вынес в отдельный файл vpc.tf
```
resource "google_compute_firewall" "firewall_ssh" {
  name    = "default-allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [0.0.0.0/0]
}
```
* в файле main.tf остались лишь записи о версии провайдера google

##### использованиек модулей 

* создал директории modules/db и modules/app в рабочей папке terraform
* в них создал конфиг. файлы  для каждого модуля: variables.tf , outputs.tf , main.tf
* определил переменные в variables.tf
* удалил из основной директории app.tf db.tf
* в ./main.tf прописал секции вызова модулей
```
module "app" {
  source          = "../modules/app"
  public_key_path = var.public_key_path
  zone            = var.zone
  app_disk_image  = var.app_disk_image
}

module "db" {
  source          = "../modules/db"
  public_key_path = var.public_key_path
  zone            = var.zone
  db_disk_image   = var.db_disk_image
}
```
* загрузил модули командой terraform get
* для устранения ошибки, переопределим выходную переменную в ./outputs.tf
```
output "app_external_ip" {
  value = module.app.app_external_ip
}
```
* создал модуль VPC , расположен ./modules/vpc, прописал конфиг. файл
* прописал его вызов в ./main.tf , удалил ./vpc.tf в основной директории
* проверил работоспособность
```
terraform get
terraform plan
terraform apply
```
##### параметризация модулей с использованием input переменных  #####
* в файле конфигурации фаервола ssh : ./modules/vpc/main.tf укажем диапазон адресов в виде переменной
````
 source_ranges = var.source.ranges
````
* определил переменную в variables.tf данного модуля, указал значение по умолчанию
* определил значение переменной в вызове модуля из основного файла main.tf
* указал IP адрес своей локальной машины - доступ по SSH к ВМ есть
* указал иной адрес- в результате ВМ недоступна
* вернул значение 0.0.0.0/0

##### переиспользование модулей  #####
* создал инфраструктуру для двух окружений (stage и prod)
* в двух директориях ./stage и ./prod находятся конфиг. файлы из основной папки
* для обоих директорий в main.tf исправлены ссылки на модули app , db, vpc
* различия окружений - для stage  прописано правило доступа по SSH для всех адресов, для prod - только один
* из основной директории за ненадобностью удалены все .tf файлы

##### использование стороннего модуля storage-bucket #####
* прописан вызов модуля в отдельном файле storage-bucket.tf
* в нем прописана output переменная 
````
output storage-bucket_url {
  value = module.storage-bucket.url
}
````
* пропишем значения проекта и региона в variables.tf и terraform.tfvars

Результат - при применении изменений создается бакет с указанным именем (storage-bucket-i253210)



## Домашняя работа к уроку №10 - знакомство с Ansible

Что проделано: 
* создали ветку репозитория ansible-1, и директорию ansible
* установили Ansible в одноименную папку через  пакетный менеджер pip
* создали  файл inventory ,  в нем прописали, какими хостами будет управлять Ansible (appserver и dbserver из предыдущих работ),параметры ssh подключения

* проверили подкелючение черезь модуль ping
````
ansible appserver -i ./inventory -m ping
````
* прописали параметры по умолчанию в ansible.cfg (ссылку на файл inventory, remote-user, путь к ключу для ssh, и пр.). Удалили лишнее из inventory

* прописали инвентори файл в формате yml - inventory.yml
#### Использование модулей в Ansible

* используем модуль command для запуска произвольной команды (вывод времени работы системы) на удаленном хосте
````
ansible dbserver -m command -a uptime
````
* прописали группы хостов в инвентори файле: [app] и [db], теперь можно вызывать модуль для группы

* проверяем наличие нужного ПО на VM с использованием модулей command и shell:
````
ansible app -m command -a 'ruby -v; bundler -v'
ansible app -m shell -a 'ruby -v bundler -v'
````
* различие модулей - shell подходит для выполнения более сложных скриптов, состоящих из нескольких командр и с использованием переменных окружения
* модуль command подходит для выполнения одной команды
* используем модуль systemd, service или shell для проверки статуса MongoDB
````
ansible db -m systemd -a name=mongod
ansible service -a name=mongod
ansible db -m shell -a 'systemctl status mongod'
````

* используем модуль git для клонирования репозитория с приложением reddit
````
ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'
````
* проверяем идемпотентность этой команды в сравнении с выполнением той же операции через модуль command или shell. Последние выдают ошибку при повторном запуске


#### создание простого плейбука
* создали файл clone.yml , который копирует репозиторий через git
````
---
- name: Clone
  hosts: app
  tasks:
    - name: Clone repo
      git:
        repo: https://github.com/express42/reddit.git
        dest: /home/appuser/reddit

````
* проверяем его работу с помощью команды ansible-playbook , смотрим на различия в выводе при первичном / повторном запуске


#### дополнительное задание - в процессе.


### Домашнее задание к уроку 11 - Ansible №2

Что проделано:  
* создана ветка ansible-2
* создали плейбук ansible/reddit_app.yml который содержит сценарии для управления конфигурацией обоих хостов

* сценарий содержит различные задания - таски (у каждого таска свой тег, чтоб было проще их запускать)
* по мере заполнения плейбука, проверяем его  на корректность командой
````
ansible-playbook reddit-app.yml --check
````

####  таски
- копирование локального конфиг файла mongod.conf.j2 ,  тег db-tag, задана переменнаая mongo_bind_ip
- добавление unit файла на инстанс app, тег app-tag, хендлер reload puma

- добавление конфига для подключения инстанса app к db-серверу (копирование шаблона db_config.j2)

- копирование дистрибутива приложения с помощью модуля git, тег deploy-tag 

- запуск bundler-а в директории с приложением (deploy-tag)

#### хендлеры
- restart mongod перезапускает сервис MongoDB (выполняется после таска с копированием конфига mongodb)

- restart puma перезапускает демона puma server


#### плейбук с несколькими сценариями

* создали reddit_app2.yml, в нем отдельный сценарий для группы хостов db, и отдельный для app
* изменено описание сценариев, запуск от root (become: true) прописано в настройках сценария, а не в каждом таске
* теги app-tag, db-tag, deploy-tag прописаны в описании каждого сценария, а не для каждого таска
* результат: запускать плейбук можно, не указывая явно параметр --limit app/db

#### использование нескольких плейбуков

* созданы файлы в директории ansible :  app.yml , db.yml , deploy.yml 
* предыдущие плейбуки переименованы в reddit_app_one_play.yml & reddit_app_multiple_plays.yml

* в новые файлы скопирован код из соответствующих сценариев multiple_plays.yml

* запуск плейбуков теперь не трубует указания тега

* создали site.yml , в нем подгружаются (командой import_playbook) все плейбуки - сценарии

* в итоге вся инфраструкткра настраивается запуском одного плейбука

* как проверили - перейдя по адресу app-server-а по порту 9292 работает приложение

#### изменение провижинера в packer
* создали packer_app.yml & packer_db.yml - плейбуки, устанавливающие Руби с Бундлером и МонгоДБ соотвественно

* в директории packer изменили код в файлах образа app.json & db.json
````
"provisioners": [
{
"type": "ansible",
"playbook_file": "ansible/packer_app/db.yml"
}
]
````
* запустили инфраструктуру на базе новых образов, прогнали плейбук - все работает. 

#### дополнительное задание - dynamic inventory - в процессе 

## Домашнее задание №11 - Ansible 3

ЧТо сделано: 

* создана ветка ansible-3
* создали структуру роли, в директории ansible/roles

```` 
ansible-galaxy init app
ansible-galaxy init db
````

* в итоге созданы роли db (настройка сервера mongoDB) и app (настройка сервера приложения)
* перенесли секции tasks из плейбуков db.yml, app.yml в roles/<rolename>/tasks/main.yml

* перенесли соотвествующие шаблоны  из  ansible/templates в ansible/roles/<rolename>/templates

* определили используемые хендлеры в ansible/roles/<rolename>/handlers/main.yml

* определили переменные (db_host , mongo_port, mongo_bind_ip) в ansible/roles/<rolename>/defaults/main.yml

* перенесли из папки ansible/files файл puma.service в ansible/roles/app/files

* в плейбуках ansible/app.yml и ansible/db.yml оставим только вызовы ролей, таски и хендлеры удалили. 

* проверили работу плейбуков, все работает, реддит на app-server-е запускается
````
ansible-playbook site.yml (--check)
````
* создали директории окружений - environments/stage и environments/prod

* создали инвентори файлы для каждого окружения, в корневой папке invbentory удалили

* прописали в ansible.cfg окружение по умолчанию - stage

* создали директорию group_vars  в обоих окружениях, для определения переменных групп хостов

* в папках group_vars создадим файлы app и db, в них определим переменные db_host, mongo_bind_ip, эти переменнные из плейбуков ansible/app.yml и db.yml  удалены

* в group_vars окружения stage и prod создал файл all - переменные для всех хостов, указанных в инвентори. Пропишем в нем окружение:
````
env: stage  # prod в папке prod
````

* для вывода информации об окружении прописали переменную env в файлах ansible/roles/<rolename>/defaults/main.yml
````
env: local
````

* добавили таск  в роли app и db: ansible/roles/<rolename>/tasks/main.yml
````
- name: Show info about the env this host belongs to
debug:
msg: "This host is in {{ env }} environment."
````

* привел в порядок корневую папку ansible - плейбуки перенес в /playbooks, все остальное из предыдущих д/з в /old. В папке остались ansible.cfg & requirements.txt

* добавили  в ansible.cfg вывод изменений, и прописали папку ролей
````
[defaults]
...
roles_path = ./roles
[diff]
always = True
context = 5
````

* запустили плейбук site.yml в stage и prod окружении, все работает

#### Community роли

* скачал роль jdauphant.nginx (j.n.) с помощью ansible-galaxy

* создал для этого файлы environments/<env_name>/requirements.yml
````
-src jdauphant.nginx
version v2.21.1
````
* добавил файлы этой роли в .gitignore

* добавил необходимые переменные в <env_name>/group_vars/app
````
 nginx_sites:
   default:
     - listen 80
     - server_name "reddit"
     - location / {
         proxy_pass http://127.0.0.1:9292;
       }
````

* прописал вызов роли j.n. в плейбук app.yml

* прописал в терраформ новое правило файервола - открытый порт 80 для тега reddit-app. Любопытно,что по умолчанию в GCP общее правило открытого порта 80 для всего диапазона адресов было, но с ним reddit на этом порту не работал. А после добавления правила через terraform - все заработало. Дело в теге? 

* применил плейбук site.yml, проверил доступность реддита на 80 порту

# использование ansible vault

* изучил работу с приватными данными

* создал файлм vault.key (прописан в .gitignore) с произвольной строкой

* добавил в ansible.cfg опцию
````
[defaults]
...
vault_password_file = vault.key
````
* создал плейбук playbooks/users.yml - создает пользователей, работает для всех хостов

* создал файлы ansible/environments/<env_name>/credentials.yml для обоих окружений

* в них прописал имена пользователей (admin, qauser) и тестовые пароли, очень взломостойкие (qWeRtY123)

* зашифровал файлы credentials с использованием vault.key
````
ansible-vault encrypt environments/prod/credentials.yml
ansible-vault encrypt environments/stage/credentials.yml
````

* добавил вызов плейбука users.yml в site.yml, проверил и запустил его

* заходим по ssh на серверы, проверяем командой su admin / su qauser - пользователи с заданными паролями имеются

* провалив много раз подряд тесты TravisCI, утсановил ansible-lint

* с помощью ansible-lint нашел каждый trailing whitespace в каждом файле, устранил. Тест прошел) 

### Динамическое инвентори - в процессе

### Настройка Travis CI - в процессе


## Домашнее задание № 12 - Ansible 4

Ветка: ansible-4. Использовал: vagrant +  virtualbox, molecule, testinfra

* описал локальную инфраструктуру с помощью Vagrant
  * инициализировал вагрант (создал vagrantfile) в папке ansible репозитория
  * добавил в .gitignore строки для игнорирования папки ,vagrant, файлов .log, .pyc , .molecule , .cache .pytest_cache

  * описал в vagrantfile сценарий создания двух ВМ - appserver & dbserver, c 512MB памяти у каждой, с указанием IP адресов внутреннего интерфейса
  ````
  Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
    v.memory = 512 #ram memory for vm
  end
  config.vm.define "dbserver" do |db|
    db.vm.box = "ubuntu/xenial64"
    db.vm.hostname = "dbserver"  #name of VM
    db.vm.network :private_network, ip: "10.10.10.15"

    end
  end  
  config.vm.define "appserver" do |app|
    app.vm.box = "ubuntu/xenial64"  # box name - image of VM
    app.vm.hostname = "appserver"
    app.vm.network :private_network, ip: "10.10.10.25" # IP of internal interface
  ````
* запуск инфраструктуры (образ ubuntu/xenial64 качается с vagrant cloud)
````
vagrant up
...
vagrant status

````
* подключился к ВМ по ssh к машине appserver, проверил сетевую доступность  dbserver
````
vagrant ssh appserver

ping -c 3 10.10.10.15
````
#### использование провижинеров (Ansible) с Vagrant

* Добавление провижинера в определение хоста dbserver (Vagrantfile)
  * определяем провижинер, указываем плейбук, определяем группу хостов и переменных

````
db.vm.provision "ansible" do |ansible|
ansible.playbook = "playbooks/site.yml"
ansible.groups = {
"db" => ["dbserver"],
"db:vars" => {"mongo_bind_ip" => "0.0.0.0"}
````
* запуск провижинера
  ````
  vagrant provision dbserver
  ````
  * видим ошибку - не хватает python нужной версии
  * способ исправления - создать плейбук base.yml , описывающий установку python; добавим его в site.yml
  ````
  -import_playbook: base.yml
  # -import_playbook: users.yml # этот можно удалитьь
   ````
* создание плейбука base.yml . Используем модуль  raw - оне позволяет запускать команды по SSH , не требует питона на управляемом хосте. 
   * параметр gather_facts отключен, т.к он требует наличия питона
   ````
   ---
    - name: Check && install python
    hosts: all
    become: true
    gather_facts: False
    tasks:
    - name: Install python for Ansible
    raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)
    changed_when: False
   ````

   * повторный запуск провижинера заканчивается ошибкой - не найден сервис mongoDB
      * решение - добавить в роль db таски из packer_db.yml
      * создан файл db/tasks/install_mongo.yml
      * замечение - в файле из gist не полностью прописан id ключа для apt, что вызывает ошибку при установке
      ````
      - name: Add APT key
       apt_key:
       id: "D68FA50FEA312927"  # изначальный ключ был  EA312927
       keyserver: keyserver.ubuntu.com
       tags: install

      - name: Add APT repository
       apt_repository:
       repo: deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
       state: present
       tags: install

       - name: Install mongodb package
       apt:
        name: mongodb-org
       state: present
       tags: install

       - name: Configure service supervisor
         systemd:
         name: mongod
         enabled: yes
         state: started
         tags: install
      ````
      * заодно вынес задачи (tasks) для настройки mongodb в отдельный файл - config_mongo.yml
      ````
      ---
      - name: Change mongo config file
        template:
        src: templates/mongod.conf.j2
        dest: /etc/mongod.conf
        mode: 0644
        notify: restart mongod
      ````
      * в файле db/roles/main.yml остались вызовы ролей из вышеуказанныхъ файлов (import_roles) и таск по отображению окружения

* третий запуск провижининга закончился успешно
  * проверка доступности порта MongoDB (27017) - заходим на VM appserver по SSH и выполняем команду
   ````
    telnet 10.10.10.15 27017
   ```` 
   * подключение удалось, все хорошо

* доработал роль app, добавив в нее tasks из плейбука packer-app.yml
  * созданы файлы app/tasks/ruby.yml и -=-/puma.yml
    * первый устанавливает все необходимые руби-компоненты

    ````
    ---
    - name: Install ruby and rubygems and required packages
    apt: "name={{ item }} state=present"
    with_items:
    - ruby-full
    - ruby-bundler
    - build-essential
    tags: ruby
    ````
    * puma.yml копирует system unit файл для автозапуска демона пумы. 
      *  изменения: теперь используется модуль template (вместо copy), передается шаблон puma.service.j2, это сделано для параметризации пути копирования 
    ````
    - name: Add unit file for Puma
     template:
     src: puma.service.j2
     dest: /etc/systemd/system/puma.service
     notify: reload puma

     - name: Add config for DB connection
     template:
     src: db_config.j2
     dest: "/home/{{ deploy_user }}/db_config"
     owner: "{{ deploy_user }}"
     group: "{{ deploy_user }}"

    - name: enable puma
     systemd: name=puma enabled=yes
    ````
      * шаблон /roles/app/templates/puma.service.j2 , параметризует директорию,  куда копируется и запускается файл.
    
````
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
EnvironmentFile=/home/{{ deploy_user }}/db_config  # параметризованный путь
User={{ deploy_user }}
WorkingDirectory=/home/{{ deploy_user }}/reddit
ExecStart=/bin/bash -lc 'puma'
Restart=always

[Install]
WantedBy=multi-user.target

````
 * также изменился файл ansible/playbooks/deploy.yml. Изменились таски - теперь репозиторий копируется и бундлер запускается по параметризованному пути
````
tasks:
  - name: Fetch the latest version of application code
    git:
       repo: 'https://github.com/express42/reddit.git'
       dest: "/home/{{ deploy_user }}/reddit"
       version: monolith
    notify: reload puma

  - name: Bundle install
    bundler:
      state: present
      chdir: "/home/{{ deploy_user }}/reddit"

````

 * переменная deploy_user определена в /roles/app/defaults/main.yml  (значение по умолчанию appuser)
 * в roles/app/taska/main.yml вызываем таски в правильном порядке
 ````
- import_tasks: ruby.yml
  tags:
    - app-ruby

- import_tasks: puma.yml
  tags:
    - app_puma
 ````  
* В vagrantfile нужно добавить определение провижинера для хоста appserver
````
app.vm.provision "ansible" do |ansible|
ansible.playbook = "site.yml"
ansible.groups = {
"app" => ["appserver"],
"app:vars" => { "db_host" => "10.10.10.10"}
}
end
````
* Необходимо прописать значение по умолчанию (ubuntu) для переменной deploy_user. Это делается через указание переменных extra_vars (высокий приоритет) в блоке провижинера в vagrantfile
````
ansible/vagrantfile
ansible.extra_vars = {
       "deploy_user" => "ubuntu"
````

* проверка работы приложения - по адресу 10.10.10.25:9292 приложение работает
 * конфигурация nginx - в процессе..

### Тестирование роли
Нужно установить Molecule, Testinfra, через pip и вирт среду virtualenv

* установил virtualenv, зупустил виртуальную рабочуб среду (python 3)
````
python3 -m venv venv2 #вызываем virtualenv как модуль python3; создалась папка venv2 в корне директория, не закоммичена
source venv2/bin/activate # запуск среды через выполнение файла activate
````

* прописал файл ansible/requirements.txt
```
ansible>=2.4
molecule>=2.6
testinfra>1.10
python-vagrant>=0.5.15
```
* установил вышеперечисленные компоненты через pip
````
pip install -r requirements.txt #запущено из директории ansible
````

  * спустя много времени и нервных клеток было выяснено: для правильной установки molecule требуются:
    * обновить python3-pip, иначе он сваливается в core dumped
    * обновить python3-wheel, но это не точно
    * обновление производил через apt

* Создана заготовка тестов, в папке ansible/roles/db, создаст директорию ./molecule
````
molecule init scenario --scenario-name default -r db -d vagrant 
#vagrant является драйвером для создания тестовой VM
````
* для добавления/изменения тестов правим файл db/molecule/default/tests/test_default.py
````
# check if MongoDB is enabled and running
def test_mongo_running_and_enabled(host):
mongo = host.service("mongod")
assert mongo.is_running
assert mongo.is_enabled
# check if configuration file contains the required line
def test_config_file(File):
config_file = host.file('/etc/mongod.conf')
assert config_file.contains('bindIp: 0.0.0.0')
assert config_file.is_file
````
* правим <b> описание тестовой машины </b> db/molecule/default/molecule.yml
````
...
driver:
name: vagrant
provider:
name: virtualbox
lint:
name: yamllint
platforms:
- name: instance
box: ubuntu/xenial64
provisioner:
name: ansible
lint:
name: ansible-lint 
````
* теперь нужно запустить ВМ для проверки роли. В директории ansible/roles/db нужно выполнить команду
````
molecule create

molecule list # просмотр списка созданных инстансов
````

* подключение в ВМ по SSH
````
molecule login -h <instance_name> 
````
* после запуска команды molecule init создался плейбук db/molecule/default/playbook.yml
  * добавим в него параметр become: true, иначе без рут прав не все сработает, и зададим переменную mongo_bind_ip
````
- name: Converge
  become: true
  hosts: all
  vars:
   mongo_bind_ip: 0.0.0.0
  roles:
    - role: db
````

* применение плейбука. эта команда применит роль ансибла db для тестового хоста (выполнятся все таски и хендлеры этой роли)
````
molecule converge
````
* прогон тестов. Эта команда запустит набор тестов из db/molecule/default/tests/test_default.py. Будет проверено наличие файла /etc/mongod.conf и в нем переменной mongo_bind_ip, а также наличие запущенного и установленного в автозапуск сервиса mongod
````
molecule verify
````

### самостоятельное задание
* написать тест к роли db, проверяющий, что БД слушает по порту 27017
   * добавим тест в файл db/molecule/default/tests/test_default.py. Используется модуль testinfra - socket
   ````
    def test_mongo_socket(host): # название теста
    socket = host.socket("tcp://0.0.0.0:27017") # определение переменной , как сокет в формате ipv4
    assert socket.is_listening # проверка на свойство "сокет слушается"

   ````
   * прогон теста - molecule verify - успешно.
* Изменить плейбуки packer_db.yml и packer_app.yml, оставив на них вызовы ролей db и app

  * схема работы - запускаем packer build app/db.json, они вызывают провижинера ansible, плейбуки ansible/playbooks/packer_X.yml
  * в плейбуках перечислены таски, заменим их  на ссылку на роли: ansible/roles/<role_name>
  ````
  #packer_db.yml
  roles:
      - app
   
   # packer_app.yml
    roles:
      - db    

  ````
  * теперь обратимся к файлам ansible/roles/<rolename>/tasks/main.yml
    * роль app/tasks/main.yml импортирует таски ruby.yml и puma.yml. Второй нам не нужен для пакера, поэтому различим их тегами
````
    - name: Show info about the env this host belongs to
      debug:
      msg: "This host is in {{ env }} environment."
    - import_tasks: ruby.yml
      tags:
        - app-ruby

     - import_tasks: puma.yml
       tags:
         - app_puma

```` 
  * роль db/tasks/main.yml импортирует таски install_mongo и config_mongo. Для пакера нужен только первый. Используем теги
````
 - import_tasks: install_mongo.yml
   tags:
     - db_install_mongodb

 - include: config_mongo.yml
   tags:
     - db_configure_mongodb

````
  * теперь нужно изменить packer/app.json. Добавим 
````
"type": "ansible",
            "playbook_file": "ansible/playbooks/packer_app.yml", # это было
            "ansible_env_vars": [                      # отсюда добавили секцию - переменные окружения
                "ANSIBLE_ROLES_PATH=./ansible/roles"   # указываем на директорию с ролями, чтобы пакер не ругался
            ],
            "extra_arguments": [                       # секция extra_arguments содержит указания на теги, которые нужно выполнить 
                "--tags",
                "app-ruby"
            ]
            
````
  * файл packer/db.json меняем схожим образом, указав тег db_install_mongodb

