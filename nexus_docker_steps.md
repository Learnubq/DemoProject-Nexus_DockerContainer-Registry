## Demo Project - Deploy Nexus as a Docker Container/Create Docker Repository on Nexus and Push to It

This demo shows the process of creating a Docker repository on Nexus and pushing a Docker Image to it.

## Steps to Create a Docker Repository on Nexus and Push to It

1. **I installed Nexus Repository Manager as a Docker container on a new DigitalOcean droplet. Before this I configured the firewall for the droplet and opened port 22 so I could access it via CLI on host machine:**

```bash
cd ~/
ssh root@<IPaddress of droplet>
```

2. **I then installed Docker on the droplet server after checking there is none on the system:**

```bash
docker
apt update
snap install docker
docker
```

<img width="782" height="59" alt="dockernexus1" src="https://github.com/user-attachments/assets/0c8318f1-be16-4202-a4ef-3ff8507362d5" />

3.**I then visited Docker Hub website to find the nexus official Image to pull. I searched for sonatype/nexus3. Because I wanted to persist the nexus repository data on the droplet server, I need to configure a mounted named volume for it:**

```bash
docker volume create --name nexus-data
docker run -d \
  -p 8081:8081 \
  -p 8083:8083 \
  --name nexus \
  -v nexus-data:/nexus-data \
  sonatype/nexus3

```

<img width="964" height="271" alt="dockernexus2" src="https://github.com/user-attachments/assets/ced2a045-c7be-4c61-9488-b8abed6bca64" />

4. **I then executed the following command to confirm whether the port for nexus, 8081, was open:**

```bash
netstat -lnpt
```

file:///home/ubuntuq/Pictures/Screenshots/dockernexus3.png

**Here I could see that port 8081 was open on the server, so I could send requests to that port**

5. **I then execute the following command to see if my docker container was running and on what port:**

```bash
docker ps
```

<img width="1701" height="57" alt="dockernexus4" src="https://github.com/user-attachments/assets/4687e459-1d70-4f70-b46d-995412232432" />

6. **I then took the IP address of the droplet server and port 8081 and searched for that in browser - to access Nexus Repository UI. So here I had deployed Nexus as a Docker Image on the droplet server**

7. **I had to confirm that I was running Docker on the droplet server as a non-root user - best practice in order to protect root user permissions:**

```bash
docker exec -it <container ID> /bin/bash
whoami
exit
```

<img width="129" height="33" alt="dockernexus5" src="https://github.com/user-attachments/assets/063a732f-66e1-43e0-983c-ca07c74dcdf7" />

<img width="206" height="61" alt="dockernexus6" src="https://github.com/user-attachments/assets/c9c6c6a6-4f4f-4a87-9129-910c7b87beae" />

**The dollar sign shows it is a non-root user. The "whoami" statement return shows it is the nexus user running inside the Docker container. So the user creation and the starting of Nexus with a Nexus user was also completed out of the box, so inside the Nexus Image we didn't have to configure any of those**

**It is good practice to run Docker Images or Docker containers with their own service user, not root user**

**As I mounted a Docker volume inside the Docker container for the nexus service, even if we remove the container and recreate it, the Data for the nexus repository won't be lost as it will have been persisted**

8. **To see the actual location of where the persisted data is stored on the server's file system I ran the following command:**

```bash
docker volume ls
```

<img width="264" height="56" alt="dockernexus7" src="https://github.com/user-attachments/assets/afe5b3c9-6e37-4faa-bec1-bf298510073d" />

**This shows all the Docker volumes I have configured on the droplet server**

9. **I executed the following command to get some more information about the volume:**

```bash
docker inspect nexus-data
```

<img width="1083" height="302" alt="dockernexus8" src="https://github.com/user-attachments/assets/e155c02b-f05c-4b65-95a0-e89fdd60069c" />

**When I looked inside the mountpoint with ls, I saw all the Nexus data stored there:**

```bash
ls /var/snap/docker/common/var-lib-docker/volumes/nexus-data/_data
```

<img width="1355" height="31" alt="dockernexus9" src="https://github.com/user-attachments/assets/e683306d-93ae-414e-900b-882339d30b96" />

**This is the sonatype work volume mount - I will need this location to do backups as well as look up a password or some other information for debugging**

**Alternatively, I could like inside the Docker container file system as all of these files are mounted into the Docker container:**

```bash
docker exec -it <container ID> /bin/bash
cd /
ls
ls /nexus-data/
```

<img width="1355" height="197" alt="dockernexus10" src="https://github.com/user-attachments/assets/c149d667-9f89-4e64-a0f6-eb96852c83c4" />

**This is a replication of the data found through docker inspect command. So you can check this information either in the container itself or on a server like this**

10. **I then created a User Role for the Docker repository on Nexus**

<img width="1302" height="360" alt="dockernexus11" src="https://github.com/user-attachments/assets/b8deeca0-9ec1-42af-85ba-afb37dbb30ae" />

11. **I then configured the Repository Connector (port 8083) in the docker-hosted repository settings**

<img width="1617" height="527" alt="dockernexus14" src="https://github.com/user-attachments/assets/14a8e7e9-2594-4505-a218-1221b01ef584" />

12. **I then configured the firewall rule to open port 8083 on the DigitalOcean droplet server**

13. **I then configured token issuing on Nexus (Realm - activated Docker Bearer Token Realm)**

**logged in as admin to Nexus Repository Manager on port 8083**

**I then navigated to security --> Realms**

**In the available list I found "Docker Bearer Token Realm" and clicked the arrow to move it to the "Active" list. I then made sure it was below "Nexus Authenticating Realm" and above "Nexus Authorizing Realm"

<img width="660" height="414" alt="dockernexus15" src="https://github.com/user-attachments/assets/8de8a72f-baed-4dfc-b9f0-2bb0c2134148" />

**I then configured Docker to allow insecure registry:**

```bash
sudo mkdir -p /var/snap/docker/current/config
sudo vim /var/snap/docker/current/config/daemon.json
sudo snap restart docker
```

**I then had to log in as admin in Nexus UI and add a custom repo for Docker**

**I then logged in to Nexus Docker Repo using Docker login:**

```bash
docker login <ip address of nexus>:8083
```

<img width="1169" height="351" alt="dockernexus16" src="https://github.com/user-attachments/assets/3648d335-cc8c-4ba6-be69-a544d5593b8c" />

**Command to restart Docker Nexus container:**

```bash
docker restart nexus
```

14. I then built and pushed a Docker Image from my local machine to the Nexus Repo**

```bash
cd ~/js-app/nexus_docker
docker build -t myapp:1.0 .
```

**I then tagged the Image for the Nexus registry**

```bash
docker tag myapp:1.0 134.209.245.237:8083/myapp:1.0
```

<img width="683" height="495" alt="dockernexus17b" src="https://github.com/user-attachments/assets/3b7388d9-2eb6-422f-934d-00b41b7f4b9d" />

**I then logged in to the Nexus Docker registry**

```bash
docker login 134.209.245.237:8083
```

**I then configured the insecure registry on my local machine so it could connect to the docker-hosted repository via HTTP**

```bash
sudo vim /etc/docker/daemon.json
```

**I then pushed the Image to the Nexus registry docker-hosted repository**

```bash
docker push 134.209.245.237:8083/myapp:1.0
```

<img width="1191" height="300" alt="dockernexus18" src="https://github.com/user-attachments/assets/55b9d235-ecf0-42f5-8d83-da03bee7a19e" />

<img width="1223" height="796" alt="dockernexus19" src="https://github.com/user-attachments/assets/918153dd-0f10-4344-8694-93daf11871bb" />

15. **I then pulled the Docker Image from the Nexus docker-hosted registry:**

```bash
docker pull 134.209.245.237:8083/myapp:1.0
docker images
```

<img width="958" height="108" alt="dockernexus20" src="https://github.com/user-attachments/assets/c39de8b4-d402-4ee3-918e-87ac9febf856" />

<img width="1249" height="88" alt="dockernexus20b" src="https://github.com/user-attachments/assets/9c45881a-d640-451a-a42c-a248d23a7c28" />

