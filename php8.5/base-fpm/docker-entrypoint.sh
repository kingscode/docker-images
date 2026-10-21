#!/bin/sh
set -e

# Start the HTTP stack (nginx :8080 → PHP-FPM), or exec an override command
# (e.g. php artisan, queue workers). Accepts the legacy Apache CMD as an alias.
case "${1:-}" in
  apache2-foreground|nginx|"")
    php-fpm -D
    exec nginx -g 'daemon off;'
    ;;
  *)
    exec "$@"
    ;;
esac
