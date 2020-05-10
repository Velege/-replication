#!/bin/bash
#
# Скрипт в бесконечном цикле пингует удалённый хост в инете с интервалом 5 сек
# при первой удачной или неудачной попытке пинга пишется соответствующее сообщение в лог и на экран
# следующая запись в лог делается только при изменении состояния связи

# Узел опроса
ip="192.168.200.133"
# Имя пользователя для ssh
name="admindb"
# Узел для подключения по ssh
ip_ssh="192.168.200.134"
# Кол-во пингов
count=3
# инициализация переменной результата, по умолчанию считается, что связь уже есть
status=connected
# Файл логов
logfile=./ping.log
rm -rf /tmp/test/*
mkdir -p /tmp/test/
chmod 777 /tmp/test/

echo `date +%Y.%m.%d__%H:%M:%S`' Скрипт проверки связи запущен' >> ${logfile}
# бесконечный цикл
while [ true ]; do
    # пинг с последующей проверкой на ошибки
    result=$(ping -c ${count} ${ip} 2<&1| grep -icE 'unknown|expired|unreachable|time out')

    # если ни один не прошел, то
    if [ "$status" = connected -a "$result" != 0 -a -e /tmp/test/1 ]; then
	# Меняем статус, чтоб сообщение не повторялось до смены переменной result
	status=disconnected
	# Записываем в лог результат
	echo `date +%Y.%m.%d__%H:%M:%S`' Соединение с master отсутствует' >> ${logfile}
	# Вывод результата на экран
	echo `date +%Y.%m.%d__%H:%M:%S`' Соединение с master отсутствует'
	echo 'Replica become a master' >> ${logfile}
	echo 'Replica become a master'
	ssh ${name}@${ip_ssh} 'sudo -u postgres /usr/lib/postgresql/9.6/bin/pg_ctl promote -D /var/lib/postgresql/9.6/main/'
	rm -rf /tmp/test/*
    fi
    # если все пинги прошли, то
    if [ "$status" = disconnected -a "$result" -eq 0 ]; then
	# Меняем статус, чтоб сообщение не повторялось до смены переменной result
	status=connected
	# Пишем в лог время установки соединения
	echo `date +%Y.%m.%d__%H:%M:%S`' Связь есть' >> ${logfile}
	# Вывод результата на экран
	echo `date +%Y.%m.%d__%H:%M:%S`' Связь есть'
    fi
    # 5 сек задержка
    sleep 5
done
