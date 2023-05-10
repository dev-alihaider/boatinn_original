# README
BOATINN

Technology stack

* Ruby 2.3.4
* Ruby on Rails 5.1.1
* PostgreSQL 9.6
* Redis
* Sidekiq

Requirements

* Ruby. Version 2.3.4 is currently used and we don't guarantee everything works with other versions. If you need multiple versions of Ruby, RVM or rbenv is recommended.
* RubyGems
* Bundler: gem install bundler
* Git
* A database. PostgreSQL 9.6
  You can install PostgreSQL Server:

Ubuntu 17.04-17.10:

<pre>
sudo apt-get install postgresql-9.6
</pre>

Ubuntu 14.04, 16.04:

<pre>
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-9.6
</pre>

Centos 7:

<pre>
yum install  https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm -y
yum install postgresql96 postgresql96-server postgresql96-contrib postgresql96-libs -y
</pre>

* Redis

Ubuntu:
<pre>
sudo apt-get update
sudo apt-get install build-essential tcl
cd /tmp
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
make
make test
sudo make install
sudo mkdir /etc/redis
sudo cp /tmp/redis-stable/redis.conf /etc/redis
</pre>

Edit /etc/redis/redis.conf:

<pre>
supervised systemd
</pre>

and

<pre>
dir /var/lib/redis
</pre>

Create file:
<pre>
cat << EOF >> /etc/systemd/system/redis.service
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
EOF
</pre>

Add user:

<pre>
sudo adduser --system --group --no-create-home redis
</pre>

<pre>
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis
sudo systemctl start redis
systemctl enable redis
</pre>

Centos 7:

<pre>
yum install epel-release
yum update
yum install redis
systemctl start redis
systemctl enable redis
</pre>

Installation development environment

<pre>
git clone ...
cd boatinn
bundle install
</pre>

Create and add your database configuration details to config/datebase.yml file

<pre>
cp config/database.sample.yml config/database.yml
</pre>

<pre>
bin/rails db:migrate
bin/rails db:seed
</pre>

Create application.yml file by copying the example configuration file:

<pre>
cp config/application.sample.yml config/application.yml
</pre>

Run sidekiq:

<pre>
sidekiq
</pre>

Run rails to new tab:

<pre>
rails s
</pre>

Deploy to production server:

Run command from project dir on developer PC:

<pre>
cap production deploy
</pre>

Branch "master" is deploing default

To deploy other branch to server run next command:

<pre>
BRANCH=your_branch_name cap production deploy
</pre>

Restart services puma and sidekiq:

Go to server to user "deploy" with ssh

<pre>
ssh deploy@boatinn.net -p 9922
</pre>

and run command:

<pre>
sudo service puma restart
</pre>

or use Monit admin panel.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
