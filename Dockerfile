FROM ubuntu:rolling
LABEL Description="Image for building gpg"

RUN apt update
RUN apt install -y libldap2-dev rng-tools libbz2-dev zlib1g-dev libsqlite3-dev libreadline-dev pcscd scdaemon
RUN apt install -y make wget file pinentry-tty ca-certificates lbzip2 bzip2 gcc

ARG GPG_VERSION=2.2.17
ENV GPG_VERSION "gnupg-$GPG_VERSION"

ADD ./download_and_compile.mk /app/
WORKDIR /app/

RUN make -f /app/download_and_compile.mk all

RUN gpg -K
ADD ./gpg-agent.conf ./scdaemon.conf /app/
COPY gpg-agent.conf /root/.gnupg/gpg-agent.conf
COPY scdaemon.conf /root/.gnupg/scdaemon.conf

RUN apt install -y psmisc python3 python3-pip python3-pyscard python3-cryptography
# avoid installing distro's gpgme by installing only bindings
RUN pip3 install python-gnupg

CMD ["/bin/bash", "/app/start-within-container.sh"]
