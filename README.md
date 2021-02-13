Доступ к кластеру выслал отдельно

ВМ развернуты на AWS раскатываются с помощью Ansible
https://github.com/akatruk/test_task
ВМ раскатываются с помощью terraform 
https://github.com/akatruk/test_task_terraform

Кластер управляется через patronictl -c /etc/patroni/postgres.yml 

Список всех серверов и лаг репликации
patronictl -c /etc/patroni/postgres.yml list

Кол-во подключений и основные настройки менялись через
patronictl -c /etc/patroni/postgres.yml edit-config
patronictl -c /etc/patroni/postgres.yml reload demo_cluster

За кластером следит etcd, у него есть возможность выводить через какое-то время ноды, что-бы можно было поддерживать рабочий сервис с минимальным кворумом. То есть поочередный отказ 4 серверов оставит 1 сервер работоспособным. Если откажет например резервная площадка с 2-мя серверами, благодаря кворому останется 3 сервера на основной площадке. К сожалению из-за оссобенности виртуализации AWS на нем не работает виртуальные IP сделанные внутри EC2 инстанса, но если бы это был VMWARE или KVM то keepalived работал бы нормально.

Компоненты: 
postgreSQL 12
etcd
haproxy
keepalived
--------------------------------------------------------------------------------------------
Ротация логов за четыре дня. Если честно я не когда такого не делал и сейчас кроме RDS и Aurora под рукой ничего нет, где это можно было проверить, но чуть нагуглив могу сказать, что скорее всего это будет выглядить вот так:

alter system set log_directory = 'pg_log';
alter system set log_filename = 'postgresql-%d.log';
alter system set log_rotation_age = 4;
alter system set log_truncate_on_rotation = on;

--------------------------------------------------------------------------------------------
Очень понравилась задача с сбором в фаил долгих запросов:
Включаем pg_stat_statements
На сервере 13.36.37.180 по пользователем postgres добавлен cron который стартует каждый час

0 * * * * psql -h localhost -U postgres < query.sql > $(date +"%Y_%m_%d_%I_%M_%p").log

with CTE1 as
(select query, calls, (total_time/calls)::integer as avg_time_ms 
from pg_stat_statements
where calls > 10
order by avg_time_ms desc)
select * from CTE1 
where avg_time_ms > 1000;
select pg_stat_statements_reset();

-------------------------------------------------------------------------------------------
6-ое задание не понял как делать, не хватило времени :(