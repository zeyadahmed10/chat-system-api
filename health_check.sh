rm -f /rails/tmp/pids/server.pid
printf "Checking over mysql health\n"

# Wait for MySQL to be ready
until mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e 'SELECT 1'; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done
printf "mysql healthy\n"
printf "migrate db\n"

./bin/rails db:prepare

printf "Checking over elasticsearch health\n"
# Wait for Elasticsearch to be ready
# until curl -s http://"$ES_HOST":9200/_cluster/health | grep -q '"status":"green"'; do
#   >&2 echo "Elasticsearch is unavailable - sleeping"
#   sleep 1
# done
HOST="$1"
until $(curl --output /dev/null --silent --head --fail $HOST); do
    printf "Waiting for $1 to be up\n"
    sleep 1
done
printf "elasticsearch healthy\n"


