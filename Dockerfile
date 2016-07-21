FROM oraclelinux
MAINTAINER Toby Ferguson <toby@cloudera.com>
RUN  yum -y update; yum clean all
RUN yum -y install wget;yum clean all
RUN wget -nv --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.rpm
RUN yum -y install jdk-7u80-linux-x64.rpm; yum clean all
RUN wget -nv -O /etc/yum.repos.d/cloudera-director.repo http://archive.cloudera.com/director/redhat/7/x86_64/director/cloudera-director.repo
RUN yum -y install cloudera-director-client
ENTRYPOINT ["/usr/bin/cloudera-director", "bootstrap", "/aws/aws.conf"]
