#!/bin/bash
#
# Скрипт в бесконечном цикле пингует удалённый хост в инете с интервалом 5 сек
# при первой удачной или неудачной попытке пинга пишется соответствующее сообщение в лог и на экран
# следующая запись в лог делается только при изменении состояния связи

# Узелы опроса
ip_arbitr="192.168.200.131"
ip_replic="192.168.200.134"
# Кол-во пингов
count=3
# инициализация переменной результата, по умолчанию считается, что связь уже есть
status=connected
# Файл логов
logfile=./ping.log

echo `date +%Y.%m.%d__%H:%M:%S`' Скрипт проверки связи запущен' >> ${logfile}
# бесконечный цикл
while [ true ]; do
    # пинг с последующей проверкой на ошибки
    result_arbitr=$(ping -c ${count} ${ip_arbitr} 2<&1| grep -icE 'unknown|expired|unreachable|time out')
    result_replic=$(ping -c ${count} ${ip_replic} 2<&1| grep -icE 'unknown|expired|unreachable|time out')
    # если ни один не прошел, то
    if [ "$status" = connected -a "$result_arbitr" != 0 -a "$result_replic" != 0 ]; then
	# Меняем статус, чтоб сообщение не повторялось до смены переменной result
	status=disconnected
	# Записываем в лог результат
	echo `date +%Y.%m.%d__%H:%M:%S`' Соединение с арбитром и репликой отсутствует' >> ${logfile}
	# Вывод результата на экран
	echo `date +%Y.%m.%d__%H:%M:%S`' Соединение с арбитром и репликой отсутствует'
	echo 'Закрываю порт' >> ${logfile}
	echo 'Закрываю порт'
	sudo iptables -A INPUT -p tcp --dport 5432 -j DROP
	sudo iptables -A INPUT -p tcp --sport 5432 -j DROP
	sudo iptables -A OUTPUT -p tcp --sport 5432 -j DROP
	sudo iptables -A OUTPUT -p tcp --dport 5432 -j DROP
    fi
    # если все пинги прошли, то
    if [ "$status" = disconnected -a "$result_arbitr" -eq 0 -a "$result_replic" -eq 0 ]; then
	# Меняем статус, чтоб сообщение не повторялось до смены переменной result
	status=connected
	# Пишем в лог время установки соединения
	echo `date +%Y.%m.%d__%H:%M:%S`' Связь есть' >> ${logfile}
	# Вывод результата на экран
	echo `date +%Y.%m.%d__%H:%M:%S`' Связь есть'
	iptables -D INPUT 1
	iptables -D INPUT 1
	iptables -D OUTPUT 1
	iptables -D OUTPUT 1
	sudo iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
	sudo iptables -A INPUT -p tcp --sport 5432 -j ACCEPT
        sudo iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
        sudo iptables -A OUTPUT -p tcp --dport 5432 -j ACCEPT
    fi
    # 5 сек задержка
    sleep 5
done
