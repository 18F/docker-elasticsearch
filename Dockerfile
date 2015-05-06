FROM ubuntu:trusty

FROM ubuntu:trusty

RUN \
    apt-get update \
        --quiet \
    && apt-get install \
        --yes \
        --no-install-recommends \
        --no-install-suggests \
    software-properties-common \
    python-software-properties \

# Clean up packages.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV ES_PKG_NAME elasticsearch-1.5.0
ENV HTTP_BASIC_URL https://github.com/Asquera/elasticsearch-http-basic/releases/download/v1.4.0/elasticsearch-http-basic-1.4.0.jar
ENV PLUGIN_DEST /elasticsearch/plugins/http-basic/

# Install Elasticsearch.
RUN \
  cd / && \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
  tar xvzf $ES_PKG_NAME.tar.gz && \
  rm -f $ES_PKG_NAME.tar.gz && \
  mv /$ES_PKG_NAME /elasticsearch

RUN mkdir -p $PLUGIN_DEST

ADD $HTTP_BASIC_URL $PLUGIN_DEST

ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml

WORKDIR /data

ENTRYPOINT ["scripts/start.sh"]
CMD [""]

EXPOSE 9200 9300

VOLUME ["/data"]
