#!/usr/bin/env bash

INSTALL_FOLDER="/home/polux/Softwares"
LINUX="debian10"
SITE=$(wget -qO- https://www.mongodb.com/try/download/enterprise | tr -d '\n')
COMPASS_VERSIONS=$(curl -sH "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mongodb-js/compass/releases)

CURRENT_MDB_COMPASS=$(dpkg -l | grep "mongodb-compass " | tr -s ' ' '\t' | cut -f3)
CURRENT_MDB_COMPASS_BETA=$(dpkg -l | grep "mongodb-compass-beta " | tr -s ' ' '\t' | cut -f3 | sed 's/~/-/')
CURRENT_MONGOSH=$(mongosh --version)
CURRENT_MONGODB=$(readlink $INSTALL_FOLDER/mongodb-linux-current | grep -oP '\d+\.\d+\.\d+')
CURRENT_TOOLS=$(readlink $INSTALL_FOLDER/mongodb-tools-current | grep -oP '\d+\.\d+\.\d+')

CURRENT_MDB_COMPASS=${CURRENT_MDB_COMPASS:-'0.0.0'}
CURRENT_MDB_COMPASS_BETA=${CURRENT_MDB_COMPASS_BETA:-'0.0.0'}
CURRENT_MONGOSH=${CURRENT_MONGOSH:-'0.0.0'}
CURRENT_MONGODB=${CURRENT_MONGODB:-'0.0.0'}
CURRENT_TOOLS=${CURRENT_TOOLS:-'0.0.0'}

COMPASS_URL_PROD=$(echo "$COMPASS_VERSIONS" | grep "browser_download_url.*_amd64\.deb" | cut -d'"' -f4 | grep -v "isolated\|readonly\|community\|beta" | head -1)
COMPASS_URL_BETA=$(echo "$COMPASS_VERSIONS" | grep "browser_download_url.*_amd64\.deb" | cut -d'"' -f4 | grep -v "isolated\|readonly\|community" | grep beta | head -1)

COMPASS_PROD_DEB=$(echo "$COMPASS_URL_PROD" | xargs basename)
COMPASS_BETA_DEB=$(echo "$COMPASS_URL_BETA" | xargs basename)

ONLINE_COMPASS_PROD=$(echo "$COMPASS_URL_PROD" | grep -oP '\d+\.\d+\.\d+' | head -1)
ONLINE_COMPASS_BETA=$(echo "$COMPASS_URL_BETA" | grep -oP '\d+\.\d+\.\d+-beta\.\d+' | head -1)
ONLINE_MONGOSH=$(echo "$SITE" | grep -oP '<div id="mongodb-shell".*?</mdb-input>' | grep -oP 'value="[^"]*"' | grep -oP '\d+\.\d+\.\d+')
ONLINE_MONGODB=$(echo "$SITE" | grep -oP '<div id="mongodb-enterprise-server".*?</mdb-input>' | grep -oP 'value="[^"]*"' | grep -oP '\d+\.\d+\.\d+')
ONLINE_TOOLS=$(echo "$SITE" | grep -oP '<div id="mongodb-database-tools".*?</mdb-input>' | grep -oP 'value="[^"]*"' | grep -oP '\d+\.\d+\.\d+')

BOOL_UPDATE_MDB_COMPASS=$([ "$CURRENT_MDB_COMPASS" == "$ONLINE_COMPASS_PROD" ] && echo "No" || echo "Yes")
BOOL_UPDATE_MDB_COMPASS_BETA=$([ "$CURRENT_MDB_COMPASS_BETA" == "$ONLINE_COMPASS_BETA" ] && echo "No" || echo "Yes")
BOOL_UPDATE_MONGOSH=$([ "$CURRENT_MONGOSH" == "$ONLINE_MONGOSH" ] && echo "No" || echo "Yes")
BOOL_UPDATE_MONGODB=$([ "$CURRENT_MONGODB" == "$ONLINE_MONGODB" ] && echo "No" || echo "Yes")
BOOL_UPDATE_TOOLS=$([ "$CURRENT_TOOLS" == "$ONLINE_TOOLS" ] && echo "No" || echo "Yes")

ARRAY=$(
  cat <<-EOF
|,Product,|,Local versions,|,Online versions,|,Need update?,|
|,____________,|,______________,|,_______________,|,____________,|
|,Compass,|,$CURRENT_MDB_COMPASS,|,$ONLINE_COMPASS_PROD,|,$BOOL_UPDATE_MDB_COMPASS,|
|,Compass Beta,|,$CURRENT_MDB_COMPASS_BETA,|,$ONLINE_COMPASS_BETA,|,$BOOL_UPDATE_MDB_COMPASS_BETA,|
|,Mongosh,|,$CURRENT_MONGOSH,|,$ONLINE_MONGOSH,|,$BOOL_UPDATE_MONGOSH,|
|,MongoDB,|,$CURRENT_MONGODB,|,$ONLINE_MONGODB,|,$BOOL_UPDATE_MONGODB,|
|,Tools,|,$CURRENT_TOOLS,|,$ONLINE_TOOLS,|,$BOOL_UPDATE_TOOLS,|
EOF
)

echo "$ARRAY" | column -s ',' -t

if [ "$BOOL_UPDATE_MDB_COMPASS" == "No" ] &&
  [ "$BOOL_UPDATE_MDB_COMPASS_BETA" == "No" ] &&
  [ "$BOOL_UPDATE_MONGOSH" == "No" ] &&
  [ "$BOOL_UPDATE_MONGODB" == "No" ] &&
  [ "$BOOL_UPDATE_TOOLS" == "No" ]; then
  exit 0
fi

echo
read -p "Do updates [y/n]? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if [ "$BOOL_UPDATE_MDB_COMPASS" == "Yes" ]; then
    echo "Downloading Compass Prod version: $COMPASS_URL_PROD"
    wget -q "$COMPASS_URL_PROD"
    sudo dpkg -i "$COMPASS_PROD_DEB"
    rm ./*.deb
  fi
  if [ "$BOOL_UPDATE_MDB_COMPASS_BETA" == "Yes" ]; then
    echo "Downloading Compass Beta version: $COMPASS_URL_BETA"
    wget -q "$COMPASS_URL_BETA"
    sudo dpkg -i "$COMPASS_BETA_DEB"
    rm ./*.deb
  fi
  if [ "$BOOL_UPDATE_MONGOSH" == "Yes" ]; then
    wget -qO- "https://downloads.mongodb.com/compass/mongosh-${ONLINE_MONGOSH}-linux-x64.tgz" |
      tar -xvz -C $INSTALL_FOLDER/bin/ --strip 2 --wildcards */bin/*
  fi
  if [ "$BOOL_UPDATE_MONGODB" == "Yes" ]; then
    wget -qO- "https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-${LINUX}-${ONLINE_MONGODB}.tgz" |
      tar -xvz -C $INSTALL_FOLDER
  fi
  if [ "$BOOL_UPDATE_TOOLS" == "Yes" ]; then
    wget -qO- "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-${LINUX}-x86_64-${ONLINE_TOOLS}.tgz" |
      tar -xvz -C $INSTALL_FOLDER
  fi
else
  echo "Okay bye :'( !"
fi
