sudo apt-get install curl
sudo apt-get install -y git
sudo apt-get install make
sudo apt-get install -y vim


# install docker

#    ca-certificates \
#    gnupg \
#    lsb-release
sudo curl -fsSL https://get.docker.com -o ~/get_docker.sh && chmod u+o ~/get_docker.sh && ~/get_docker.sh;

# install docker-compose

sudo curl -SL https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose;
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose;
