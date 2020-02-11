# NEXTEPC-Docker
<b> This is an impementation of NEXTEPC in docker container. It consist of two parts MongoDB docker and the NEXTEPC docker. </b>

tested with srslte enb and srsue and COTS UEs

## per-request
* install docker  
```bash
sudo apt-get update 
sudo apt install docker-ce docker-ce-cli containerd.io
```
## MongoDB docker
* create a mongodb docker and run it:
```bash
mkdir ~/data
docker run -d -v ~/data:/data/db --name nextepcdb --network host mongo 
```
* get dump from one mongodb into another first get the dump:
```bash
mongodump -o nexepcdb -d nextepc
```
* load the dump to the new nextepcdb:
```bash
mongorestore -d nextepc nexepcdb/nextepc/
```

## NEXTEPC docker build
* get the docker file and go to the cloned directory:
```bash
cd nextepc-docker 
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
sudo sh -c "cat << EOF > /etc/systemd/network/99-nextepc.netdev \
     [NetDev]  \
	 Name=pgwtun \
	 Kind=tun EOF"  
```
```bash
$ sudo sh -c "cat << EOF > /etc/systemd/network/99-nextepc.network \
        [Match] \
		Name=pgwtun \
		[Network] \
		Address=45.45.0.1/16 \
		Address=cafe::1/64  \
		EOF"
```
```bash
sudo systemctl enable systemd-networkd 
```
```bash
sudo systemctl restart systemd-networkd
```
## Define a NAT for getting internet access on the UE:
```bash
sudo iptables -A FORWARD -i $ifname -o pgwtun -m state --state RELATED,ESTABLISHED -j ACCEPT 
sudo iptables -A FORWARD -o $ifname -i pgwtun -j ACCEPT 
sudo iptables -t nat -A POSTROUTING -o $ifname -j MASQUERADE 
sudo iptables -A FORWARD -i pgwtun -j ACCEPT 
sudo iptables -t nat -A POSTROUTING -o pgwtun -j MASQUERADE 
```
## Run the script for runing the nextepc from outside docker:
```bash
./script/run.sh
```
Configuration file can be found in .config and shuld be change accourding to the network setup 

<b> to do: add the nextepc webgui to the docker and configure the NAT tables correctly </b>
