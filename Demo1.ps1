Wait-Debugger
docker pull jlesage/firefox
docker run -d --name=firefox -p 5800:5800 -v /docker/appdata/firefox:/config:rw jlesage/firefox
# http://127.0.0.1:5800
