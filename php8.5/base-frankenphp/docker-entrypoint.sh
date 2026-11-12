#!/bin/sh
set -e

# Start FrankenPHP (HTTP :8080), or exec an override command
# (e.g. php artisan, queue workers). Accepts legacy Apache/nginx CMDs as aliases.
case "${1:-}" in
  apache2-foreground|nginx|frankenphp|"")
    exec frankenphp run --config /etc/frankenphp/Caddyfile --adapter caddyfile
    ;;
  *)
    exec "$@"
    ;;
esac
