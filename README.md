
##### To Buld Image locally
docker build -t badak-jenkins-slave ./

##### To Run it
docker container run -it badak-jenkins-slave


##### Maven repository is located in this 
/home/jenkins/maven-repositories/

You Need to make that folder mounted to your real repository , so it is no need to redownload if there already exist
