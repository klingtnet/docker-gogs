FROM golang:latest

# install non-go dependencies
RUN apt-get update &&\
    apt-get -y install\
        openssh-server\
        git\
        sqlite3\
        unzip &&\
    rm -rf /var/lib/apt/lists/*

# create gogs user
#
# note: the gogs user must have a login shell, setting it to /usr/bin/nologin or /bin/false will make you unable to push over ssh!
RUN useradd --create-home --comment 'Gogs' --shell /bin/sh gogs

# get the latest linux build (sqlite is not supported in the `go get` version)
# note that `unzip` can't extract zip content from a pipe
ENV GOGS_ZIP /tmp/gogs-latest.zip
ENV GOGS_HOME /home/gogs

RUN curl -L "https://github.com/$(curl -Ls 'https://github.com/gogits/gogs/releases/latest' | \
    sed --silent 's/.*href="\(.*linux_amd64.zip[^"]*\).*/\1/p')" --output ${GOGS_ZIP} &&\
    unzip ${GOGS_ZIP} -d /tmp &&\
    rm ${GOGS_ZIP} &&\
    mv /tmp/gogs ${GOGS_HOME}/bin &&\
    chown -R gogs:gogs ${GOGS_HOME}/bin

ADD sshd_config /etc/ssh/
RUN su -s /bin/bash -c "mkdir -p ~/share/db &&\
    mkdir ~/share/repos &&\
    mkdir ~/share/conf &&\
    mkdir ~/share/ssh  &&\
    mkdir ~/share/logs &&\
    ln -s ~/share/db ~/db &&\
    ln -s ~/share/repos ~/gogs-repositories &&\
    mkdir ~/bin/custom && ln -s ~/share/conf ~/bin/custom/conf &&\
    ln -s ~/share/ssh ~/.ssh &&\
    ln -s ~/share/logs ~/logs" gogs &&\
    invoke-rc.d ssh restart

ADD start.sh ${GOGS_HOME}/

VOLUME ${GOGS_HOME}/share
EXPOSE 22 3000

ENV USER gogs

WORKDIR ${GOGS_HOME}
