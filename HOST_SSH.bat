@echo off
call config.bat
ssh %SSH_USER%@www.%WP_HOST%
