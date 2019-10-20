# WordPress & Git

This little project provides a method to:

* develop with WordPress locally
* revision-control the site, including files and database entries
* deploy the local site to the host

## Prerequisites

The project has the following prerequisites:

* Windows 10
* Docker
* Git

## First Time Setup

Here are some brief instructions how to use the project:

* Setup your WordPress site. Nothing special required here, just keep doing whatever you have done before.
* Backup your site. We like to use the free Duplicator plugin to do so. Download both the installer, and the archive.
* Fork this project, and clone to your local machine.
* Launch your local WordPress installation by double-clicking UP.bat. This will create three new folders: db, wp, and sql.
* Allow a couple of minutes for WordPress to install. Open http://www.localhost in your browser, or double-click the wwwLocalhost shortcut to do the same. Once the site is responding, probably showing a dialog to select the WordPress language, you are done.
* Delete everything inside the wp folder. Copy the installer and archive created with Duplicator here.
* Open http://www.localhost/installer.php in your browser. This will launch a wizard to install your site locally
* One the installer has finished, you should be able to browser your site on http://www.localhost
* Open http://www.localhost:8080 to open phpMyAdmin in your browser, or double-click phpMyAdmin to do the same.
* Have a look at the various tables, e.g. xx_commentmeta, or xx_comments and determine the common prefix of these tables. The default is 'wp_', but your hosting service probably set it to something else.
* Edit config.bat. Make sure DP_PREFIX matches the prefix from the previous step, and WP_HOST matches the public domain name of your site.

## Revision Control with Git

For files this is very simple. Any files you add, delete or edit, will be recognized by git, and you can commit these to your repository.

For the database we need to be a little more creative. The process we have chosen here, is to export the database to SQL, which is just a text file. We can easily revision-control those sql files with git.

To export the database, double-click DB_TO_SQL.bat. This will do the following:

* create a backup of the database at sql/db-local-backup.sql. This file is really just there in case something goes wrong, which is why it is ignored in git.
* cleanup your database. Specifically, we delete all transients, empty the trash, and remove all post revisions. Further, we optimize the database, if possible.
* export the local database to sql/db-local.sql. This file is what we will use later on to restore the site on localhost.
* use search-and-replace to map all URLs pointing to localhost back to your public domain name.
* export the database to sql/db.sql. This file is the one we will use later on to restore the site on the hosting server.
* re-install WordPress locally, reset the database, and import sql/db-local.sql. Your site should now be back on localhost, only difference being that the removed transients, revisions, and trash

Once we finished running DB_TO_SQL.bat, it is probably a good time to commit the .sql files to git.

## Restoring the Site

I'll describe this within the next few days...