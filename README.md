# Clone the repo locally
git clone git@github.com:dktanwar/urpp_docker.git

# Enter into directory
cd urpp_docker

# Build image locally
docker build . -t urpp

# Run R from Docker
docker run --rm -ti urpp R

# Enter into container: 
docker run --rm -it --entrypoint /bin/bash urpp

# Running Rstudio server
docker run --rm -p 8780:8787 -e PASSWORD=pass urpp

# Also, mouning a directory
docker run --rm -p 8780:8787 -e PASSWORD=pass -v /mnt/:/home/rstudio urpp

# Running in background
docker run --rm -d -p 8780:8787 -e PASSWORD=pass -v /mnt/:/home/rstudio urpp

# Running shiny server
docker run -p 3838:3838 --rm urpp /usr/bin/shiny-server
