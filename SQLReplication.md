### Установка на обоих серверах:

```
sudo apt update && sudo apt upgrade -y && sudo apt-get install -y mysql-server
...
sudo mysql_secure_installation
n
y
y
y
y
```

```
sudo systemctl status mysql
sudo systemctl enable mysql
```



### Настройка авторизации на обоих серверах:

```
sudo mysql
mysql>ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'Otus321$';
```

```
sudo mysql_config_editor set --login-path=client --host=localhost --user=root --password
```



### Настройка Репликации:

#### **MASTER**

1. Указываем ip который будем слушать

   ```
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   	bind-address            = 192.168.250.172  
   ```

   ```
   sudo service mysql restart
   ```

2. Создаем пользователя с правами для репликации всех баз

   ```
   mysql>create user repl@'%' IDENTIFIED WITH caching_sha2_password BY 'oTUSlave#2020';
   mysql>GRANT REPLICATION SLAVE ON *.* TO repl@'%';
   mysql>FLUSH PRIVILEGES;
   ```

3. Смотрим позицию бинлога

   ```
   mysql> SHOW MASTER STATUS;
   +---------------+----------+--------------+------------------+-------------------+
   | File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
   +---------------+----------+--------------+------------------+-------------------+
   | binlog.000004 |      856 |              |                  |                   |
   +---------------+----------+--------------+------------------+-------------------+
   1 row in set (0,00 sec)
   
   ```

   Позиция - 856

   

#### **SLAVE**

1. Изменяем id сервера

   ```
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   	server_id = 2
   ```

   ```
   sudo service mysql restart
   ```

2. Включаем репликацию с указание позиции бинлога

   ```
   mysql>STOP SLAVE;
   mysql>CHANGE MASTER TO MASTER_HOST='192.168.250.172', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000004', MASTER_LOG_POS=856, GET_MASTER_PUBLIC_KEY = 1;
   mysql>START SLAVE;
   ```

3. Включаем режим "только для чтения"

   ```
   mysql>set global innodb_read_only = ON
   ```

4. Проверяем статус репликации

   ```
   mysql> show slave status\G
   *************************** 1. row ***************************
                  Slave_IO_State: Waiting for source to send event
                     Master_Host: 192.168.250.172
                     Master_User: repl
                     Master_Port: 3306
                   Connect_Retry: 60
                 Master_Log_File: binlog.000004
             Read_Master_Log_Pos: 1044
                  Relay_Log_File: two-relay-bin.000002
                   Relay_Log_Pos: 509
           Relay_Master_Log_File: binlog.000004
                Slave_IO_Running: Yes
               Slave_SQL_Running: Yes
                 Replicate_Do_DB:
             Replicate_Ignore_DB:
              Replicate_Do_Table:
          Replicate_Ignore_Table:
         Replicate_Wild_Do_Table:
     Replicate_Wild_Ignore_Table:
                      Last_Errno: 0
                      Last_Error:
                    Skip_Counter: 0
             Exec_Master_Log_Pos: 1044
                 Relay_Log_Space: 716
                 Until_Condition: None
                  Until_Log_File:
                   Until_Log_Pos: 0
              Master_SSL_Allowed: No
              Master_SSL_CA_File:
              Master_SSL_CA_Path:
                 Master_SSL_Cert:
               Master_SSL_Cipher:
                  Master_SSL_Key:
           Seconds_Behind_Master: 0
   Master_SSL_Verify_Server_Cert: No
                   Last_IO_Errno: 0
                   Last_IO_Error:
                  Last_SQL_Errno: 0
                  Last_SQL_Error:
     Replicate_Ignore_Server_Ids:
                Master_Server_Id: 1
                     Master_UUID: daca1ec6-539d-11ec-9470-00155dc7cc05
                Master_Info_File: mysql.slave_master_info
                       SQL_Delay: 0
             SQL_Remaining_Delay: NULL
         Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
              Master_Retry_Count: 86400
                     Master_Bind:
         Last_IO_Error_Timestamp:
        Last_SQL_Error_Timestamp:
                  Master_SSL_Crl:
              Master_SSL_Crlpath:
              Retrieved_Gtid_Set:
               Executed_Gtid_Set:
                   Auto_Position: 0
            Replicate_Rewrite_DB:
                    Channel_Name:
              Master_TLS_Version:
          Master_public_key_path:
           Get_master_public_key: 1
               Network_Namespace:
   1 row in set, 1 warning (0,01 sec)
   ```

   **Репликация настроена!**