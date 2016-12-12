FROM progrium/busybox

MAINTAINER mciz

# Java config
ENV DRUID_VERSION   0.8.3
ENV JAVA_HOME       /opt/jre1.8.0_40
ENV PATH            $PATH:/opt/jre1.8.0_40/bin

# Druid env variable
ENV DRUID_XMX           '-'
ENV DRUID_XMS           '-'
ENV DRUID_NEWSIZE       '-'
ENV DRUID_MAXNEWSIZE    '-'
ENV DRUID_HOSTNAME      '-'
ENV DRUID_LOGLEVEL      '-'

RUN opkg-install wget tar bash \
    && mkdir /tmp/druid

RUN wget -q --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O - \
    http://download.oracle.com/otn-pub/java/jdk/8u40-b26/jre-8u40-linux-x64.tar.gz | tar -xzf - -C /opt 

RUN wget -q --no-check-certificate --no-cookies -O - \ 
    http://static.druid.io/artifacts/releases/druid-$DRUID_VERSION-bin.tar.gz | tar -xzf - -C /opt \
    && mv /opt/druid-"$DRUID_VERSION" /opt/druid 

# 2181 is zookeeper, 9092 is kafka, 8084 is realtime druid
EXPOSE 2181 9092 8084


COPY infispectorDruid.spec /opt/druid/config


CMD	["java", "-Xmx512m", "-Duser.timezone=UTC", "-Dfile.encoding=UTF-8", "-Ddruid.realtime.specFile=/opt/druid/config/infispectorDruid.spec", "-classpath", '"config/_common:config/realtime:lib/*"', "io.druid.cli.Main server", "realtime"]