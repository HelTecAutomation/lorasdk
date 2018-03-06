#!/bin/bash
dir=`cd $(dirname "$0") & pwd`
dir_change=$(echo $dir | sed 's/\//\\\//g')
dir_p=${dir%/*}
dir_p_change=$(echo $dir_p | sed 's/\//\\\//g')
#lrgateway.service
sudo cp -f ${dir}/lrgateway.service ${dir}/lrgateway.service.tmp
sudo cp -f ${dir}/lrgateway.service /lib/systemd/system
sudo cp -f ${dir}/lrgateway.service /etc/systemd/system
chmod +x reset_pkt_fwd.sh
sudo sh ./reset_pkt_fwd.sh start local_conf.json
sudo cp -f ${dir}/reset_pkt_fwd.sh /home/pi/lora/packet_forwarder
sudo cp -f ${dir}/reset_pkt_fwd.sh /home/pi/lora/packet_forwarder/lora_pkt_fwd
sudo cp -f ${dir}/local_conf.json /home/pi/lora/packet_forwarder/lora_pkt_fwd

sed -i "s/^WorkingDirectory=packet_forwarder\/lora_pkt_fwd/WorkingDirectory=${dir_p_change}\/packet_forwarder\/lora_pkt_fwd/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStartPre=packet_forwarder\/reset_pkt_fwd.sh start packet_forwarder\/lora_pkt_fwd\/local_conf.json/\
ExecStartPre=${dir_p_change}\/packet_forwarder\/reset_pkt_fwd.sh start ${dir_p_change}\/packet_forwarder\/lora_pkt_fwd\/local_conf.json/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStart=packet_forwarder\/lora_pkt_fwd\/lora_pkt_fwd/ExecStart=${dir_p_change}\/packet_forwarder\/lora_pkt_fwd\/lora_pkt_fwd/" ${dir}/lrgateway.service.tmp
sed -i "s/^ExecStopPost=packet_forwarder\/reset_pkt_fwd.sh stop/ExecStopPost=${dir_p_change}\/packet_forwarder\/reset_pkt_fwd.sh stop/" ${dir}/lrgateway.service.tmp

sudo systemctl daemon-reload
sudo systemctl restart systemd-journald

sudo systemctl enable lrgateway
sudo systemctl restart lrgateway

