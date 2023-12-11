set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

pushd powertop_startup

cp startup_script.sh /usr/bin/
cp powertop_startup.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable powertop_startup

popd
