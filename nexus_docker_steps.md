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

4. **I then executed the following command to confirm whether the port for nexus, 8081, was open:**

```bash
netstat -lnpt
```

**Here I could see that port 8081 was open on the server, so I could send requests to that port**

5. **I then execute the following command to see if my docker container was running and on what port:**

```bash
docker ps
```

6. **I then took the IP address of the droplet server and port 8081 and searched for that in browser - to access Nexus Repository UI. So here I had deployed Nexus as a Docker Image on the droplet server**

7. **I had to confirm that I was running Docker on the droplet server as a non-root user - best practice in order to protect root user permissions:**

```bash
docker exec -it <container ID> /bin/bash
whoami
exit
```

**The dollar sign shows it is a non-root user. The "whoami" statement return shows it is the nexus user running inside the Docker container. So the user creation and the starting of Nexus with a Nexus user was also completed out of the box, so inside the Nexus Image we didn't have to configure any of those**

**It is good practice to run Docker Images or Docker containers with their own service user, not root user**

**As I mounted a Docker volume inside the Docker container for the nexus service, even if we remove the container and recreate it, the Data for the nexus repository won't be lost as it will have been persisted**

8. **To see the actual location of where the persisted data is stored on the server's file system I ran the following command:**

```bash
docker volume ls
```

**This shows all the Docker volumes I have configured on the droplet server**

9. **I executed the following command to get some more information about the volume:**

```bash
docker inspect nexus-data
```
**When I looked inside the mountpoint with ls, I saw all the Nexus data stored there:**

```bash
ls /var/snap/docker/common/var-lib-docker/volumes/nexus-data/_data
```

**This is the sonatype work volume mount - I will need this location to do backups as well as look up a password or some other information for debugging, etc**

**Alternatively, I could like inside the Docker container file system as all of these files are mounted into the Docker container:**

```bash
docker exec -it <container ID> /bin/bash
cd /
ls
ls /nexus-data/
```

**This is a replication of the data found through docker inspect command. So you can check this information either in the container itself or on a server like this**

10. **I then created a User Role for the Docker repository on Nexus**

11. **I then configured the Repository Connector (port 8083) in the docker-hosted repository settings**

12. **I then configured the firewall rule to open port 8083 on the DigitalOcean droplet server**

13. **I then configured token issuing on Nexus (Realm - activated Docker Bearer Token Realm)**

**logged in as admin to Nexus Repository Manager on port 8083**

**I then navigated to security --> Realms**

**In the available list I found "Docker Bearer Token Realm" and clicked the arrow to move it to the "Active" list. I then made sure it was below "Nexus Authenticating Realm" and above "Nexus Authorizing Realm"

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

15. **I then pulled the Docker Image from the Nexus docker-hosted registry:**

```bash
docker pull 134.209.245.237:8083/myapp:1.0
docker images
```


