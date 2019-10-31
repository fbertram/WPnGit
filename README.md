# WordPress & Git

This little project provides a method to:

* develop with WordPress locally
* revision-control the site, including files and database entries
* deploy the local site to the host

Coming from a software background, we really wanted to use git to revision-control our site. There are solutions out there to do so, `VersionPress` being one of them. However, we felt that these solutions had severe shortcomings, most importantly only partial support of WordPress plugins, and the missing ability to do proper merges.

Using plain vanilla git, plus a few scripts we have create a solution that fit our bill a little better. We actually use this approach to manage five of our own websites.

## Prerequisites

The project has the following prerequisites:

* Windows 10
* Docker
* Git

## First Time Setup

To use this project, start with cloning your site to localhost. Here are the steps:

* Setup your WordPress site. Nothing special required here, just keep doing whatever you have done before.
* Backup your site. We like to use the free `Duplicator` plugin to do so. Download both the installer, and the archive.
* Fork this project, and clone to your local machine.
* Launch your local WordPress installation by double-clicking `UP.bat`. This will create three new folders: `db`, `wp`, and `sql`.
* Allow a couple of minutes for WordPress to install. Open http://www.localhost in your browser, or double-click the `wwwLocalhost.url` shortcut to do the same. Once the site is responding, probably showing a dialog to select the WordPress language, you are done. There is no need to finish the WordPress installation, as we will restore the site from the backup we made above.
* Delete everything inside the `wp` folder. Copy the installer and archive created with `Duplicator` here.
* Open http://www.localhost/installer.php in your browser. This will launch a wizard to install your site locally. In Step 2, the installer will ask for the database setup. For the host, use `db`. For the database, use `exampledb`. The user is `exampleuser`, and the password is `examplepass`. There is no strong need to choose any better usernames and passwords here, as this is only for the local install, and completely independent from the accounts at the host. If you really want to change them you can, but make sure whatever you choose matches `config.bat`. In Step 3, make sure the URL is http://www.localhost.
* One the installer has finished, you should be able to browser your site on http://www.localhost
* Open http://www.localhost:8080 to open `phpMyAdmin` in your browser, or double-click `phpMyAdmin.url` to do the same.
* Have a look at the various tables, e.g. `wp_commentmeta`, or `wp_comments` and determine the common prefix of these tables. The default is `wp_`, but your hosting provider might have set it to something different.
* Edit `config.bat`. Make sure `DB_PREFIX` matches the prefix from the previous step, and `WP_HOST` matches the public domain name of your site. Do this now, before you forget! Without DB_PREFIX set properly, the `DB_TO_SQL.bat` script won't work properly.
* While your site now runs locally, you won't be able to log in with the same account you had on the hosted site, as your localhost installation will most likely use different salts. To fix that, open a command prompt and create a new account like this:
  `wp user create bob bob@email.com --user_pass=password --role=administrator`
* If you like to, you can now disable or remove the `Duplicator` plugin. You'll probably never need it again. A simple way to do so, is use the following command from a command prompt: `wp plugin delete duplicator`.

## Revision Control with Git

For files, e.g. all your uploaded images, this is very simple. Any files you add, delete or edit, will be recognized by git, and you can commit these to your repository. In general, we recommend putting everything into git. There is no good reason not to also revision-control your WordPress installation, the themes and the plugins. However, there are some files you should _not_ put into git, which is why the default `.gitignore` has them excluded:

* everything in the `db` folder. That's the binary database. The whole point of this project is to have a better method of archiving your database.
* `wp/wp-config.php`. On the host, this file contains sensitive information about your database. Locally, it's just the default usernames and passwords, but nonetheless.

For putting the database into git we need to be a little more creative. The method we have chosen, is to dump the database as sql commands, which gives us a plain text file. We can easily revision-control that file with git.

To export the database, double-click `DB_TO_SQL.bat`. This will do the following:

* create a backup of the database at `sql/db-local-backup.sql`. This file is really just your safety net in case something goes wrong. That's why we excluded it from the repository with `.gitignore`.
* cleanup your database. Specifically, we delete all transients, empty the trash, and remove all post revisions. Further, we optimize the database tables, if possible.
* export the local database to `sql/db-local.sql`. This file is what we will use later on to restore the site on localhost.
* use search-and-replace to map all URLs pointing to localhost back to your public domain name.
* export the database to `sql/db.sql`. This file is the one we will use later on to restore the site at the hosting provider.
* re-install WordPress locally, reset the database, and import `sql/db-local.sql`. Your localhost site should now be operational again, only difference being some new car smell, removed transients, removed revisions, and an empty trash.

Once we finished running `DB_TO_SQL.bat`, it is probably a good time to commit the two sql files, `db.sql` and `db-local.sql` to git. Because of the cleanup performed, these files should be rather small. A virgin WordPress install is less than 50kB, and a site for a small business might be around 1.5MB. Nothing scary for git.

## Deploying your Site

To deploy the site, we need SSH access to the hosting provider. Here is how to make this work:

* edit `config.bat` and make sure that `SSH_USER` matches the account you use for ssh to your hosting provider.
* further, make sure that `HOST_REPO` is pointing to the location at the hosting provider, where your git repository will live. Note that on the host, the git repository should not overlap with the actual WordPress installation. As an example, our hosting provider has WordPress in /home/username/www, while we put the git repository in /home/username/GIT-REPO.

## Command Line Stuff

You can use run WP-CLI commands from the Windows command prompt, thanks to `wp.bat`. The batch will just pass on any parameters, so typing `wp --info` from a command prompt should do exactly what you expect it to do. Check out the `DB_TO_SQL.bat` batch, which is using wp-cli extensively.

Also, you can open a bash shell inside the local WordPress server. Just double-click `BASH.bat`. Please note that wp-cli is unfortunately not available inside that bash shell.