FROM composer/satis:latest

COPY docker-entrypoint.sh /kingscode/docker-entrypoint.sh
RUN chmod +x /kingscode/docker-entrypoint.sh

ENTRYPOINT "/kingscode/docker-entrypoint.sh"