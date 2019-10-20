@echo off
call config.bat
set WP=call wp.bat

REM ============================================================================
REM export local database prior to cleanup

%WP% db export --skip-extended-insert /sql/db-local-backup.sql

REM ============================================================================
REM cleanup local database

REM ===== delete transients
%WP% transient delete-all

REM ===== empty trash
REM wp post delete $(wp post list --post_status=trash --format=ids)

REM ===== remove revisions
REM wp post delete $(wp post list --post_type='revision' --format=ids) --force
%WP% post list --post_type='revision' --format=ids > ids.txt
set IDS=
set /p IDS=< ids.txt
del ids.txt
for %%i in (%IDS%) do %WP% post delete %%i --force

REM ===== optimize
%WP% db optimize

REM ============================================================================
REM export local database

%WP% db export --skip-extended-insert /sql/db-local.sql

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