@echo off
call config.bat
ssh %SSH_USER%@www.%WP_HOST% cd %SSH_REPO%;./deploy_to_host.sh

pause
