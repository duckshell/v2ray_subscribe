#!/bin/bash
url=$V2_SUBSCRIBE_URL
res=$(wget -qO- $url | base64 -d | sed -r 's/^vmess:\/\///g;s/\s//g')
is=1
echo "$res"| while read line;do
ll=$(echo "$line" | base64 -d| jq -r '.add+" "+.ps')
lla=($ll)
echo "$((is++)) ${lla[1]} $(ping -W1 -c1 $lla|grep -o 'time=.*$')" 
done
echo -n "select node to connect:"
read a
data=$(echo "$res" | sed -n  "${a}p" |  base64 -d )
address=$(echo "$data"| jq -r ".add")
port=$(echo "$data"| jq -r ".port")
id=$(echo "$data"| jq -r ".id")
alterId=$(echo "$data"| jq -r ".aid")
network=$(echo "$data"| jq -r ".net")
sudo mv /etc/v2ray/config.json /etc/v2ray/config.bak
sudo cat > ./config.json << EOF
{
  "dns": {
	"servers": [
	  "1.1.1.1"
	]
  },
  "inbounds": [
	{
	  "port": 1080,
	  "protocol": "socks",
	  "settings": {
		"auth": "noauth",
		"udp": true,
		"userLevel": 8
}
	},
{
  "port": 1081,
  "listen": "127.0.0.1",
  "protocol": "http",
  "settings": {
	"timeout": 0
  }
}
  ],
  "log": {
	"loglevel": "warning"
  },
  "outbounds": [
	{
	  "mux": {
		"enabled": false
},
	  "protocol": "vmess",
	  "settings": {
		"vnext": [
		  {
			"address": "$address",
			"port": $port,
			"users": [
			  {
				"alterId": $alterId,
				"id": "$id",
				"level": 8,
				"security": "auto"
		}
			]
	}
		]
},
	  "streamSettings": {
		"network": "$network",
		"security": "",
		"tlssettings": {
		  "allowInsecure": true,
		  "serverName": ""
  },
		"wssettings": {
		  "connectionReuse": true,
		  "headers": {
			"Host": ""
	},
		  "path": ""
  }
	  },
	  "tag": "proxy"
	}
  ]
  }
}
EOF
sudo mv ./config.json /etc/v2ray/config.json
sudo service v2ray restart
