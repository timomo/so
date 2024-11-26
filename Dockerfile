FROM perl:5.36.0 AS mojobase
LABEL maintainer "takaya030"

WORKDIR /tmp

RUN apt-get update -y && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists/*

# install carton
RUN cpanm Carton

# create appuser
RUN groupadd -g 1000 appuser && \
	useradd -d /home/appuser -m -s /bin/bash -u 1000 -g 1000 appuser

USER 1000

RUN mkdir -p /home/appuser/app
WORKDIR /home/appuser/app

CMD ["true"]


FROM mojobase AS mojoapp
LABEL maintainer "takaya030"

COPY ./app /home/appuser/app

EXPOSE 8080

CMD ["carton","exec","plackup","-p","8080","app.psgi"]