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
