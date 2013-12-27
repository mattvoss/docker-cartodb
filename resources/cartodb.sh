cd /home/cartodb

## This inits the postgres–CartoDB connection & DBs
sed -i 's/some_secret/3b7de655b4a0064e0e08a7dc4a3eb156/g' /home/cartodb/cartodb/config/app_config.yml

#export SUBDOMAIN=yoursubdomain
#echo "127.0.0.1 ${SUBDOMAIN}.localhost.lan" | sudo tee -a /etc/hosts
#sh script/create_dev_user ${SUBDOMAIN}
#exit

# touch ~/cartodb/config/redis.conf # Needed for CDB 2.0?
#rails server -p 3000 ## Don't need this if starting with foreman as below

# EXPERIMENTAL
## make sure to rvmsudo any rails command that needs sudoing
## Also, be sure to make sure POSTGRES and REDIS aren't launching on boot if using foreman.
## (Could also change PROCFILE to restart these services rather than just starting them)
## also make sure postgres default port is 5432 and not 5433.

#rvmsudo bundle exec foreman start -p 80

## OR add it add a startup item (can control via start cartodb, stop cartodb, restart cartodb)
#rvmsudo foreman export upstart /etc/init --start-on-boot --user eric --port 80 --app cartodb

db_initialize () {
  echo "Initializing database..."
  sudo -u git -H force=yes bundle exec rake gitlab:setup RAILS_ENV=production
}

db_migrate () {
  echo "Migrating database..."
  sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production
  sudo -u git -H bundle exec rake assets:clean RAILS_ENV=production
  sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production
  sudo -u git -H bundle exec rake cache:clear RAILS_ENV=production
}

cartodb_start () {
  echo "Starting gitlab server..."
  # reset the database if the --db-init switch was given.
  if [ "$DB_INIT" == "yes" ]; then
          db_initialize
  fi

  # start the gitlab application
  sudo -u cartodb -H rails server -p 3000 ## Don't need this if starting with foreman as below
  #/etc/init.d/gitlab start

  # create satellite directories
  #sudo -u git -H bundle exec rake gitlab:satellites:create RAILS_ENV=production
  #sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production

  # kickstart the rails application
  wget "http://localhost" -O /dev/null

  # watch the access logs
  tail -F /var/log/nginx/cartodb_access.log
}

cartodb_backup () {
  echo "Backing up gitlab..."
  sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
}

cartodb_help () {
  echo "Available options:"
  echo " app:start          - Starts the cartodb server (default)"
  echo " app:backup         - Backup the cartodb data"
  echo " app:db:initialize  - Initialize the database."
  echo " app:db:migrate     - Migrate the database."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

case "$1" in
  app:start)
    cartodb_start
    ;;
  app:backup)
    cartodb_backup
    ;;
  app:db:initialize)
    db_initialize
    ;;
  app:db:migrate)
    db_migrate
    ;;
  app:help)
    cartodb_help
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "${prog}" ] ; then
        shift 1
        $prog $@
      else
        cartodb_help
      fi
    fi
    ;;
esac

exit 0
