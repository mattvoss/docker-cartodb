echo 'yes' | add-apt-repository ppa:ubuntugis/ubuntugis-unstable
echo 'yes' | add-apt-repository ppa:mapnik/nightly-2.1
echo 'yes' | add-apt-repository ppa:ubuntugis/ppa

# Install GDAL, GEOS, PROJ, JSON-C, and PostGIS
apt-get update

apt-get install -y g++ make checkinstall build-essential htop git unp zip gdal-bin \
libgdal1-dev libjson0 python-simplejson libjson0-dev proj-bin proj-data libproj-dev \
postgresql-client-9.3 postgis python-gdal python-setuptools python-dev mapnik-utils python-mapnik \
curl redis-server python-pip python-dev python-gdal libmapnik libmapnik-dev \
python-mapnik2 mapnik-utils libxslt-dev libgeos-c1 libgeos-dev pgbouncer varnish git unp

cd /home/cartodb/cartodb
git checkout master
git submodule update
git submodule foreach git checkout master
chown -R cartodb .

# Install python dependencies
easy_install pip
## ENTER 'y'  -- maybe hit 'n'?
pip install -r python_requirements.txt
pip install -e git+https://github.com/RealGeeks/python-varnish.git@0971d6024fbb2614350853a5e0f8736ba3fb1f0d#egg=python-varnish
## ENTER 's'
cd ~

cd /home/cartodb
sudo -u cartodb -H curl https://raw.github.com/creationix/nvm/master/install.sh | sh
sudo -u cartodb -H .nvm/nvm.sh && sudo -u cartodb -H nvm install 0.8 && sudo -u cartodb -H nvm use 0.8
sudo -u cartodb -H echo ". .nvm/nvm.sh && nvm use 0.8" >> /.bashrc

cd /home/cartodb/cartodb-sql-api
git checkout master
npm install
cd ..

cd /usr/include/sigc++-2.0
ln -s /usr/lib/x86_64-linux-gnu/sigc++-2.0/include/sigc++config.h .

cd /home/cartodb/windshaft-cartodb
git checkout master
npm install

cd /home/cartodb/cartodb
bundle install --binstubs

cp config/app_config.yml.sample config/app_config.yml
#pico config/app_config.yml

cp config/database.yml.sample config/database.yml
#pico config/database.yml



## This inits the postgres–CartoDB connection & DBs
#sed -i 's,some_secret,3b7de655b4a0064e0e08a7dc4a3eb156,g' ~/cartodb20/config/app_config.yml


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

