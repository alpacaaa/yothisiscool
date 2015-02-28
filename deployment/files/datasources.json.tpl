{
  "db": {
    "name": "db",
    "connector": "mysql",
    "host": "localhost",
    "port": 3306,
    "database": "{{ dude.mysql_db }}",
    "username": "{{ dude.mysql_user }}",
    "password": "{{ dude.mysql_user_pass }}"
  }
}
