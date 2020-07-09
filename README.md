# MongoDB update script

MongoDB script that I use to update my MongoDB binaries.

## Prerequisites

The download URLs I use are currently for **Debian 10 (buster) x86_64**. If this is not your target, then go to [MongoDB's download](https://www.mongodb.com/try/download) page and update the URLs.

Update the `INSTALL_FOLDER` variable at the top.

I use symbolic links to locate my latest version of MongoDB Enterprise and Tools.

```shell script
mongodb-linux-current -> mongodb-linux-x86_64-enterprise-debian10-4.2.8/
mongodb-tools-current -> mongodb-database-tools-debian10-x86_64-100.0.2/
```

You will need to update your symbolic links or `$PATH` after this script to point to the newest versions.

## How to use

```shell script
./update-mdb.sh
```

## Warning

Read the script before executing it as it could potentially overwrite stuff on your computer or delete deb files.

Use at your own risk.