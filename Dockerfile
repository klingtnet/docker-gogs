FROM golang

# install non-go dependencies
RUN apt-get update &&\
    apt-get -y install openssh-server git sqlite3 unzip

# create gogs user
#
# note: the gogs user must have a login shell, setting it to /usr/bin/nologin or /bin/false will make you unable to push over ssh!
RUN useradd --create-home --comment 'Gogs' --shell /usr/sh gogs

# get the latest linux build (sqlite is not supported in the `go get` version)
# note that `unzip` can't extract zip content from a pipe
RUN curl -L "https://github.com/$(curl -Ls 'https://github.com/gogits/gogs/releases/latest' | \
    sed --silent 's/.*href="\(.*linux_amd64.zip[^"]*\).*/\1/p')" --output /tmp/gogs-latest.zip &&\
    unzip /tmp/gogs-latest.zip -d /tmp &&\
    mv /tmp/gogs /home/gogs/bin &&\
    chown -R gogs:gogs /home/gogs/bin

ADD sshd_config /etc/ssh/
RUN su -s /bin/bash -c "mkdir -p ~/share/db &&\
    mkdir ~/share/repos &&\
    mkdir ~/share/conf &&\
    mkdir ~/share/ssh  &&\
    ln -s ~/share/db ~/db &&\
    ln -s ~/share/repos ~/gogs-repositories &&\
    mkdir ~/bin/custom && ln -s ~/share/conf ~/bin/custom/conf &&\
    ln -s ~/share/ssh ~/.ssh" gogs &&\
    invoke-rc.d ssh restart

ADD start.sh /home/gogs/

VOLUME /home/gogs/share
EXPOSE 22 3000

ENV USER gogs
ENV HOME /home/gogs

WORKDIR /home/gogs
