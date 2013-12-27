FROM ubuntu:12.04
MAINTAINER voss.matthew@gmail.com

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get clean # 20130925

RUN apt-get install -y wget curl unzip build-essential checkinstall zlib1g-dev libyaml-dev libssl-dev \
    libgdbm-dev libreadline-dev libncurses5-dev libffi-dev && \
    apt-get clean

RUN apt-get install -y python-software-properties && \
    add-apt-repository -y ppa:git-core/ppa && \
    apt-get update && apt-get install -y libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev libmysqlclient-dev \
    sudo nginx git git-core openssh-server python2.7 python-docutils postfix logrotate supervisor vim && \
    apt-get clean

RUN wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz -O - | tar -zxf - -C /tmp/ && \
    cd /tmp/ruby-2.0.0-p353/ && \
    ./configure --disable-install-rdoc --enable-pthread --prefix=/usr && \
    make && make install && \
    cd /tmp && rm -rf /tmp/ruby-2.0.0-p353 && \
    gem install --no-ri --no-rdoc bundler

ADD resources/ /cartodb/

RUN chmod ugo+rw /dev/null

RUN useradd -m -c Cartodb,,,, cartodb

RUN chmod 755 /cartodb/cartodb && cd /home/cartodb

RUN git clone https://github.com/CartoDB/cartodb.git /home/cartodb/cartodb && \
    git clone https://github.com/CartoDB/Windshaft-cartodb.git /home/cartodb/windshaft-cartodb && \
    git clone https://github.com/CartoDB/CartoDB-SQL-API.git /home/cartodb/cartodb-sql-api && \
    chown -R cartodb /home/cartodb


RUN chmod 755 /cartodb/setup/install.sh && /cartodb/setup/install.sh

EXPOSE 80

ENTRYPOINT ["/cartodb/cartodb.sh"]
CMD ["app:start"]
