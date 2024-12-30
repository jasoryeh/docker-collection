# jenkins-with-docker
Pretty much just an extension of the jenkins/jenkins image but with docker-cli installed, and a couple of tools that I felt needed updated.

> [!TIP]
> Running Docker containers may result in a permission denied error caused by mismatching `docker` group IDs.
> To resolve this you may assign `DOCKER_GID` environment to the group ID of your `docker` user (e.g. `cat /etc/group | grep docker | cut -d ":" -f 3`)

## Running checklist
1. Mount jenkins data directory (e.g. `-v ./jenkins:/var/jenkins_home:z`)
2. Mount Docker socket (e.g. `-v /var/run/docker.sock:/var/run/docker.sock`)
3. (ON HOST) symlink your jenkins directory to the same place as jenkins expects (e.g. if using the above jenkins data directory `sudo ln -s $PWD/jenkins /var/jenkins_home`)
  * This just keeps it simple, otherwise:
  * If not to /var/jenkins_home, you still need to symlink this data directory somewhere so your container builds know where to go and you need to keep this in mind when configuring your jobs
