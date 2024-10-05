Write-Host 'This demo assumes you have Docker installed' -ForegroundColor Cyan
Wait-Debugger
docker pull jlesage/firefox
docker run -d --name=firefox -p 5800:5800 -v /docker/appdata/firefox:/config:rw jlesage/firefox
# http://127.0.0.1:5800
docker ps
docker ps -q --filter 'ancestor=jlesage/firefox' | ForEach-Object { docker stop $_ }
docker ps
docker ps -a
docker container prune
docker ps -a