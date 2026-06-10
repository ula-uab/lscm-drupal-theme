# LSCM Web

New LSCM landing page made with Drupal 11.

## Development installation

1. **Install ddev**
- Install instructions: https://docs.ddev.com/en/stable/users/install/ddev-installation/

```shell
ddev start
ddev import-db --file=backups/[BACKUP_FILE].sql.gz
```

- Database related operations
> https://docs.ddev.com/en/stable/users/usage/database-management/

2. **Run composer install**

```shell
ddev composer install
```

3. **Compile theme**

```shell
cd web/themes/custom/lscm_radix
npm run dev
```

4. **Visit**

> https://lscm-web.ddev.site

---

## Backup

```shell
# Clear cache tables
echo "SHOW TABLES LIKE 'cache%';" > tempfile && ddev $(ddev drush sql-connect -y) < tempfile | tail -n +2 | xargs -I% echo "TRUNCATE TABLE %;" > tempfile && ddev $(ddev drush sql-connect -y) < tempfile && rm tempfile

ddev export-db --file=backups/[BACKUP_FILE].sql.gz
```

## Update Version

```shell
ddev composer update
ddev drush cr
```
