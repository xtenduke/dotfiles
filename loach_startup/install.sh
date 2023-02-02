set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cp startup_script.sh /usr/bin/
cp loach_startup.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable loach_startup

