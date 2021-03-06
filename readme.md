# NEXTEPC-Docker
<b> This is an impementation of NEXTEPC in docker container. It consist of two parts MongoDB docker and the NEXTEPC docker. </b>

tested with srslte enb and srsue and COTS UEs

## per-request
* install docker  
```bash
sudo apt-get update 
sudo apt install docker-ce docker-ce-cli containerd.io
```
## Software Defined Network for connecting MongoDB to the WebGUI:
```bash
docker network create my-mongo-node
```

## MongoDB docker
* create a mongodb in docker and run it:
```bash
mkdir ~/data
docker run -d -v ~/data:/data/db --name nextepcdb -p 27017:27017 --network my-mongo-node mongo 
```

## NEXTEPC docker build
* get the docker file and go to the cloned directory:
```bash
cd NEXTEPC-DOCKER 
```
* Build the docker image in the Dockerfile directory:
```bash
docker build -t test_image_nextepc:1.0 .
```
* Run the docker container:
```bash
docker run -d -t --cap-add=NET_ADMIN --device=/dev/net/tun --name epc --network host --privileged=true test_image_nextepc:1.0
```
## tun device on the host  
```bash
sudo sh -c "cat << EOF > /etc/systemd/network/99-nextepc.netdev 
     [NetDev]  
	 Name=pgwtun 
	 Kind=tun EOF"  
```
```bash
$ sudo sh -c "cat << EOF > /etc/systemd/network/99-nextepc.network 
        [Match] 
		Name=pgwtun 
		[Network] 
		Address=45.45.0.1/16 
		Address=cafe::1/64  
		EOF"
```
```bash
sudo systemctl enable systemd-networkd 
```
```bash
sudo systemctl restart systemd-networkd
```
## Run the script for runing the nextepc from outside docker:
```bash
./script/run.sh
```
Configuration file can be found in .config and shuld be change accourding to the network setup 

##  NextEPC Web GUI:
* build the NEXTEPC GUI interface:
```bash
cd webgui
docker build -t besherch/node-webui-nextepc .

docker run -p 49160:3000 --network my-mongo-node -e DB_URI=mongodb://nextepcdb:27017/nextepc -d besherch/node-webui-nextepc
```
The Web UI should be up and running on http://localhost:49160/


## Configuration file
Config file can be found in .config/nextepc.conf . Copy the file to the /home/.config/nextepc 
* if the EPC is accessed remotly set the following in nextepc.conf
```
    s1ap:
        dev: lo
```
* if the eNB is running on the same machine:
```
    s1ap:
        addr: 127.0.1.100
```


##  NAT for  internet access on the UE:
Only in case of remote access of the EPC

```bash
sudo iptables -A FORWARD -i $ifname -o pgwtun -m state --state RELATED,ESTABLISHED -j ACCEPT 
sudo iptables -A FORWARD -o $ifname -i pgwtun -j ACCEPT 
sudo iptables -t nat -A POSTROUTING -o $ifname -j MASQUERADE 
sudo iptables -A FORWARD -i pgwtun -j ACCEPT 
sudo iptables -t nat -A POSTROUTING -o pgwtun -j MASQUERADE 
```