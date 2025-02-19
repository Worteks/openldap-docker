# openldap-docker
Docker image for OpenLDAP LTB

## Build the image locally
```
docker buildx build -t openldap-ltb .
```

## Deploy the container
```
docker compose up -d
```

## Check the container status and logs
```
docker ps -a
docker logs -f openldap-ltb
```

## Community images
https://hub.docker.com/u/ltbproject/openldap-ltb
