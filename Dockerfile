FROM alpine:3.4

ENV ENTRYKIT_VERSION 0.4.0


WORKDIR /

RUN apk --update --no-cache add ca-certificates openssl \
  && wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink
  
RUN apk --no-cache add apache2-utils squid

COPY squid.conf.tmpl /etc/squid/squid.conf.tmpl
  
EXPOSE 3128
VOLUME /var/log/squid

CMD [\
 "render", "/etc/squid/squid.conf", "--", \
 "prehook", "htpasswd -bc /usr/lib/squid/passwd ${SQUID_USERNAME} ${SQUID_PASSWORD}", "--", \
 "squid", "-N" \
 ]
