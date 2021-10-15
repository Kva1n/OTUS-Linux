## Домашняя работа "Bash. Написание простых скриптов"

#### Цель: необходимо написать скрипт, который проверяет систему на предмет работы службы Selinux в CentOS

1. **Проверяет включена ли на данный момент selinux.**
2. **Активирована ли selinux в конфиге**
3. **Выдает собранную информацию в виде диалога:**

- **selinux работает/не работает, в конфиге активирована/не активирована**
- **включить/выключить selinux?**
- **активировать/дезактивировать selinux в конфиге**

4. **Предварительно скрипт проверяет возможность своей работы от  пользователя который его запустил и говорит что нужно сделать чтобы  скрипт работал**



## Скрипт

```
#!/bin/bash

if [[ $# -eq 1 ]]
then
echo ''
	if [[ "$1" == "--help" ]]
	then
	echo "Данная программа позволяет просматривать и изменять режим работы системы Selinux, а так же отключать её
Для изменения режима работы и отключения требуется root доступ"
	echo ''
	exit 0	
	elif [[ "$1" == "--version" ]]
	then
	echo "Версия 0.01"
	echo ''
	exit 0
	else
	echo 'Доступны аргументы:
	      --version - показать текущую версию программы
	      --help - показать краткую справку о программе'
	echo ''
	exit 0
	fi
elif [[ $# -gt 1 ]]	
then
echo ''
echo 'Доступно указание только одного аргумента!'	 
echo ''
exit 5
fi


if test -w /etc/selinux/config
then
#echo "У текущего пользователя есть права на редактирования selinux config"
TRYCONF=1
else
echo "У текущего пользователя нет прав на редактирование selinux config, для изменения параметров используйте  sudo"
TRYCONF=0
fi

CONFMODE=$(grep "^SELINUX=" /etc/selinux/config | awk 'BEGIN{FS="="} {print $2}')

CMDSTATUS=$(sestatus |  grep "^SELinux status" | awk '{print $3}')

CMDMODE=$(sestatus | grep "^Current mode" | awk '{print $3}')

echo ''
echo "Selinux $CMDSTATUS"
echo ''

if [ $CMDSTATUS != 'disabled' ]
then
	if [ "$CONFMODE" == "$CMDMODE" ]
	then
	echo "Режим $CONFMODE"
	else
	echo "Текущий режим $CMDMODE"
	echo ''
	echo "Режим после перезагрузки $CONFMODE"
	fi
fi


echo ''


if test $TRYCONF -eq 1
then
read -p 'Изменить режим в конфигурации?(Применение после перезагрузки) [y/n] : ' CHANGECONF 
	if [ "$CHANGECONF" == 'y' ]
	then
	read -p 'Введите режим для переключения [enforcing\permissive\disabled] : ' NEWMODE
		if [ "$NEWMODE" == "$CONFMODE" ]
		then
		echo 'Данный режим уже задан в конфигурации'
		elif [ "$NEWMODE" == 'disabled' ]
		then
		sed -i "s/SELINUX=$CONFMODE/SELINUX=disabled/" /etc/selinux/config
		echo "Режим изменен на $NEWMODE"
		elif [ "$NEWMODE" == 'enforcing' ]
		then
		sed -i "s/SELINUX=$CONFMODE/SELINUX=enforcing/" /etc/selinux/config
		echo "Режим изменен на $NEWMODE"
		elif [ "$NEWMODE" == 'permissive' ]
		then
		sed -i "s/SELINUX=$CONFMODE/SELINUX=permissive/" /etc/selinux/config
		echo "Режим изменен на $NEWMODE"
		else
		echo '!! Введен неизвестный режим'
		exit 2
		fi
	fi

read -p 'Изменить текущий режим? (до перезагрузки) [y/n] : ' CHANGEMODE
​	if [ "$CHANGEMODE" == 'y' ]
​	then
​	read -p 'Введите режим для переключения [enforcing\permissive] : ' SNEWMODE
​		if [ "$SNEWMODE" == "$CMDMODE" ]
​		then
​		echo 'Данный режим уже включен'
​		elif [ "$SNEWMODE" == 'enforcing']
​		then
​		echo "Смена режима на $SNEWMODE"
​		setenforce 1
​		elif [ "$SNEWMODE" == 'permissive' ]
​		then
​		echo "Смена режима на $SNEWMODE"
​		setenforce 0
​		else
​		echo '!! Введен неизвестный режим'
​		exit 2
​		fi
​	else
​	echo 'Выход...'
​	exit 0
​	fi

fi
```


