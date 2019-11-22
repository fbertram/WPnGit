@echo off
call config.bat
set WP=call wp.bat

REM ============================================================================
REM export local database prior to cleanup
REM use this to restore the database, in case cleanup goes wrong

%WP% db export --skip-extended-insert /sql/db-local-backup.sql

REM ============================================================================
REM cleanup local database

REM ===== delete transients
%WP% transient delete-all

REM ===== empty trash, remove revisions
%WP% post list --post_type='post' --post_status=trash --format=ids > ids.txt
set /p IDS=< ids.txt
for %%i in (%IDS%) do %WP% post delete %%i --force
del ids.txt

%WP% post list --post_type='page' --post_status=trash --format=ids > ids.txt
set /p IDS=< ids.txt
for %%i in (%IDS%) do %WP% post delete %%i --force
del ids.txt

%WP% post list --post_type='revision' --format=ids > ids.txt
set /p IDS=< ids.txt
for %%i in (%IDS%) do %WP% post delete %%i --force
del ids.txt

REM ===== optimize
%WP% db optimize

REM ============================================================================
REM export local database

%WP% db export --skip-extended-insert /sql/db-local.sql

REM ============================================================================
REM update core, plugin, themes
REM we want to ensure compatibility, however only on the host side

%WP% core update
%WP% plugin update --all
%WP% theme update --all

REM ============================================================================
REM convert database for host & export

%WP% search-replace "http://www.%WP_LOCAL%" "https://www.%WP_HOST%"
%WP% search-replace "http://%WP_LOCAL%" "https://www.%WP_HOST%"
%WP% search-replace "www.%WP_LOCAL%" "https://www.%WP_HOST%"
%WP% search-replace "%WP_LOCAL%" "https://www.%WP_HOST%"
%WP% db export --skip-extended-insert /sql/db.sql

REM ============================================================================
REM reset wordpress & re-import local database

%WP% core config --dbhost=db --dbprefix=%DB_PREFIX% --dbname=%DB_NAME% --dbuser=%DB_USER% --dbpass=%DB_PASS% --force
%WP% db reset --yes
%WP% db import /sql/db-local.sql

pause
REM ============================================================================
REM end of file
