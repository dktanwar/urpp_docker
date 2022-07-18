# Installing R

FROM rocker/verse:3.6.3

MAINTAINER Deepak Tanwar (dktanwar@hotmail.com)

RUN apt-get update

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV RENV_VERSION 0.10.0
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"
RUN R -e "remotes::install_github('anthonynorth/rscodeio')"


WORKDIR /project

COPY .bashrc /root/.bashrc
COPY renv.lock renv.lock

RUN R -e "renv::restore()"

RUN curl -o simla.zip https://ndownloader.figshare.com/articles/8424956/versions/2 && \
	unzip simla.zip && \
	R CMD INSTALL pWGBSSimla_0.1.0.tar.gz


# Installing shiny server

## Thanks: rocker-org/shiny

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget


RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
#    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    sudo chown shiny:shiny /var/lib/shiny-server

#RUN mkdir /home/rstudio/ShinyApps/

COPY shiny-server.sh /usr/bin/shiny-server.sh


# Installing Conda

## Thanks: ContinuumIO/docker-images

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

COPY env.yml .

# Make sure the environment is activated:
##RUN echo "Make sure flask is installed:"
##RUN python -c "import flask"

#RUN conda env create -f environment.yml
RUN conda env update --name base --file env.yml
#ENV PATH /opt/conda/envs/env/bin:$PATH


# Installing Tini

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

# Installing CGmaptools
RUN mkdir /software

RUN apt-get update && apt-get install -y build-essential zlib1g-dev libncurses5-dev

RUN wget --quiet https://github.com/guoweilong/cgmaptools/archive/v0.1.2.tar.gz && \
    tar -xzvf v0.1.2.tar.gz && \
    cd cgmaptools-0.1.2 && \
    /bin/bash install.sh  && \
    cd .. && \
    rm v0.1.2.tar.gz && \
    mv cgmaptools-0.1.2 /software/ && \
    echo "PATH=$PATH:/software/cgmaptools-0.1.2" >> ~/.bashrc

## automatically link a shared volume for kitematic users
VOLUME /home/rstudio/kitematic

SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]

CMD [ "/bin/bash" ]
CMD [ "R" ]
CMD ["/init"]
#CMD ["/usr/bin/shiny-server"]

EXPOSE 8787 3838
