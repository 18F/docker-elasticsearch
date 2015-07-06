FROM ubuntu:trusty

MAINTAINER Ozzy Johnson <docker@ozzy.io>

RUN \
    apt-get update \
        --quiet \
    && apt-get install \
        --yes \
        --no-install-recommends \
        --no-install-suggests \
    curl \
    python-software-properties \
    software-properties-common \

# Clean up packages.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Borrow gosu setup code from the docker-library Elasticsearch image found here:
# https://github.com/docker-library/elasticsearch/blob/master/1.5/Dockerfile
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
        && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
        && gpg --verify /usr/local/bin/gosu.asc \
        && rm /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu

# Add Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# ES version.
ENV ES_PKG_NAME elasticsearch-1.5.0

# Install Elasticsearch.
RUN \
  cd / && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

# Set up default config.
ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

# http-basic plugin.
ENV HTTP_BASIC_URL https://github.com/Asquera/elasticsearch-http-basic/releases/download/v1.5.0/elasticsearch-http-basic-1.5.0.jar
#ENV PLUGIN_DEST /elasticsearch/plugins/http-basic/
#RUN mkdir -p $PLUGIN_DEST
#ADD $HTTP_BASIC_URL $PLUGIN_DEST
RUN /elasticsearch/bin/plugin --url $HTTP_BASIC_URL --install http-basic

# mapper-attachments plugin.
RUN /elasticsearch/bin/plugin install elasticsearch/elasticsearch-mapper-attachments/2.5.0

# elasticsearch-cloud-aws plugin.
RUN /elasticsearch/bin/plugin install elasticsearch/elasticsearch-cloud-aws/2.5.1

# Set up prep script location.
ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

# Create the Elasticsearch user.
RUN groupadd -r elasticsearch \
  && useradd -r -g elasticsearch elasticsearch

# Mount for persistent data.
WORKDIR /data

ENTRYPOINT ["/bin/bash", "/scripts/start.sh"]
CMD [""]

EXPOSE 9200 9300

VOLUME ["/data"]
