FROM ubuntu:yakkety
LABEL maintainer="Yoan Blanc <yoan@dosimple.ch>"

ARG DEBIAN_FRONTEND="noninteractive"

ARG TINI_VERSION=0.13.2
ARG RUBY_VERSION=2.4
ARG NODEJS_VERSION=7.x

# Add Tini (reaping problem)
ADD https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

RUN set -xe \
 && apt-get update \
 && apt-get install -q -y \
        autoconf \
        apt-transport-https \
        build-essential \
        ca-certificates \
        libffi-dev \
        libtool-bin \
        libssl-dev \
        libzmq3-dev \
        libyaml-dev \
        make \
        python3-pip \
        software-properties-common \
        wget \
 && apt-add-repository ppa:brightbox/ruby-ng-experimental \
 && apt-get update \
 && apt-get install -q -y \
        ruby${RUBY_VERSION} \
        ruby${RUBY_VERSION}-dev \
        ruby-switch \
 && apt-get clean \
 && ruby-switch --set ruby$RUBY_VERSION \
 && rm -rf /var/lib/apt/lists/* /var/tmp/*

# NodeSource Apt Repository
# https://deb.nodesource.com/setup_7.x
RUN echo "deb https://deb.nodesource.com/node_${NODEJS_VERSION} yakkety main" \
  > /etc/apt/sources.list.d/nodesource.list
RUN wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
  | apt-key add -
RUN apt-get update \
 && apt-get install -q -y \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Application
RUN python3 -m pip install -U --no-cache-dir \
        pip jupyterhub jupyterlab notebook
RUN gem install \
        iruby ffi-rzmq pry pry-doc awesome_print activesupport erector \
 && iruby register --force \
 && jupyter serverextension enable --py jupyterlab --sys-prefix \
 && jupyter kernelspec install /root/.ipython/kernels/ruby
RUN npm install -g configurable-http-proxy

COPY jupyterhub_config.py root/jupyterhub_config.py
COPY boot.sh boot.sh
COPY students.tsv students.tsv
COPY hello-ruby.ipynb hello-ruby.ipynb
RUN sh boot.sh \
 && rm boot.sh students.tsv

EXPOSE 8000
WORKDIR /root
CMD [ "jupyterhub" ]
