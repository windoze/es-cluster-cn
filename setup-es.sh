#!/bin/sh

COUNT=$1
HOSTIP_IDX=$2

# Install JRE and ElasticSearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install -y bc python openjdk-8-jre-headless elasticsearch

# Install IK Analyzer
/usr/share/elasticsearch/bin/plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v1.10.1/elasticsearch-analysis-ik-1.10.1.zip

# Generate config
hosts=`python -c "print '['+','.join(['\"10.0.0.%d\"' % x for x in range(${HOSTIP_IDX},${HOSTIP_IDX}+${COUNT})])+']'"`
min_master=`echo "${COUNT}/2+1" | bc`
cat << EOF > /etc/elasticsearch/elasticsearch.yml
network.host: 10.0.0.${HOSTIP_IDX}
discovery.zen.ping.multicast.enabled: false
discovery.zen.ping.unicast.hosts: ${hosts}
discovery.zen.minimum_master_nodes: ${min_master}
EOF

# Restart ES
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

