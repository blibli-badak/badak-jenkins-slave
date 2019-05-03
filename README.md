##### To Run it
docker container run -it badak-jenkins-slave
##### To Buld Image locally
docker build -t badak-jenkins-slave ./

##### Maven repository is located in this 
/home/jenkins/maven-repositories/

You Need to make that folder mounted to your real disk , so it is no need to redownload if there already exist

##### To Debug image
if you want to debug image , you can run bash from this command

docker container run -it badak-jenkins-slave /bin/bas
