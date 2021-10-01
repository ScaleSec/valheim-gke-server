# Backup

This CF will perform a daily backup and optionally copy it to a secondary bucket.

## Env Vars

* BACKUP_FILE_NAME - The basename of the backup file. Assumes zip. Don't include file extension.
* BUCKET_NAME - the destination backup bucket
* BUCKET_NAME_DR - secondary bucket to write to for DR. The valheim SA should not have access to this