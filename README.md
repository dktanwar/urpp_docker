# Build image locally
docker build . -t dmr_docker

# Pull built image from Docker Hub
docker pull dktanwar/dmr_docker

# Run R from Docker
docker run --rm -ti dktanwar/dmr_docker R

# Enter into container: 
docker run --rm -it --entrypoint /bin/bash dktanwar/dmr_docker

# Running Rstudio server
docker run --rm -p 8780:8787 -e PASSWORD=pass dktanwar/dmr_docker

# Also, mouning a directory
docker run --rm -p 8780:8787 -e PASSWORD=pass -v /mnt/:/home/rstudio dktanwar/dmr_docker

# Running in background
docker run --rm -d -p 8780:8787 -e PASSWORD=pass -v /mnt/:/home/rstudio dktanwar/dmr_docker

# Running shiny server
docker run -p 3838:3838 --rm dktanwar/dmr_docker /usr/bin/shiny-server
