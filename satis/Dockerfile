FROM composer/satis:latest

RUN mkdir -p /root/.ssh
RUN ssh-keyscan -H github.com > /root/.ssh/known_hosts

COPY docker-entrypoint.sh /kingscode/docker-entrypoint.sh
RUN chmod +x /kingscode/docker-entrypoint.sh

ENTRYPOINT "/kingscode/docker-entrypoint.sh"