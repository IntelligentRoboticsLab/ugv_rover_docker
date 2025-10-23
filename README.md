## Docker
---

### Install
```
sudo docker build -t custom-container .
```

### Run
```
docker compose up -d
```

### Use
From anywhere (jetson/client/laptop/etc) on the network
```
ssh -X -p 23 {ip}
```

## Ansible
---
The inventory describes the robots as clients. 

To initialize the WiFi of the robot run the init playbook:

```
ansible-playbook -i inventory playbooks/init.yml --limit initial -e "ssid=ROBOLAB_VAR psk=DNT_forever_2526" -K
```

To set the hostname to the hostname specified in the inventory run:
```
ansible-playbook -i inventory playbooks/set_hostname.yml --limit rovers -K
```

