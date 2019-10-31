#!/bin/bash

#===============================================================================
# settings

REPO=~/GIT-REPO
WP_SRC=$REPO/wp
WP_DST=~/www

#===============================================================================
# get latest version from git

cd $REPO
git pull

#===============================================================================
# copy files as needed

for d in \
    wp-content/uploads
do
    dd=$(dirname $WP_DST/$d)
    echo "copying $dd"
    mkdir -p $dd
    cp -r $WP_SRC/$d $dd
done

#===============================================================================
# update core, plugins & themes

cd $WP_DST
wp core update
wp plugin update --all
wp theme update --all

#===============================================================================
# backup & replace database

mkdir $REPO/backup
cd $WP_DST
wp db export $REPO/backup/backup-`date +%F_%H-%M-%S`.sql
wp db reset --yes
wp db import $REPO/sql/db.sql

#===============================================================================
# end of file
