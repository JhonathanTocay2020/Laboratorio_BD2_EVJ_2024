# Clase 5

### Full Backup

```sh
mysqldump -u USUARIO -pCONTRASEÑA DB > Ruta\nombre_fullbackup.sql
```

### Incremental Backup

```sh
mysqldump -u USUARIO -pCONTRASEÑA DB TABLA > Ruta\incremental_backup_tabla.sql
```

### Restaurar

```sh
mysql -u USUARIO -pCONTRASEÑA db < Ruta\nombre_backup.sql
```

### Como ralizar Backup una Porcion de Datos

creamos un respaldo incremental que solo contiene los datos nuevos sin la estructura de la tabla.

```sh
mysqldump -u root -pmysql1234 DB TABLA --no-create-info --where="id > N" > Ruta\incremental2.sql
```


mysqldump -u root -pmysql1234 ht1_g0 > C:\Users\Jhonathan\Desktop\Ejemplo5\HT1\backup_completo1.sql
mysqldump -u root -pmysql1234 ht1_g0 personas > C:\Users\Jhonathan\Desktop\Ejemplo5\HT1\backup_incremental1.sql
