##### To Run it
docker container run -it badak-jenkins-slave
##### To Buld Image locally
docker build -t badak-jenkins-slave ./
##### To Build Image for kubernetes usage (install buildx plugin first)
docker-buildx build --platform linux/amd64 -t image_name:tag .
