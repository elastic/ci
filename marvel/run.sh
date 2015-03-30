#!/bin/bash
es_port=`expr 9240 + $EXECUTOR_NUMBER`
echo "Shutting down existing running cluster $es_port"
curl -s -XPOST 'http://localhost:'$es_port'/_shutdown'

function quiet {
    OUT=$($* 2>&1)
    if [[ "$?" -gt 0 ]]; then
        echo $OUT
    fi
}

# extract the zip file into tmp
rm -r -f $WORKSPACE/tmp/es*
tmpdir=$WORKSPACE/tmp/es-$$
mkdir -p $tmpdir
zipfile=$WORKSPACE/es/target/releases/*.zip
ls -l $WORKSPACE/es/target/releases/
quiet unzip $zipfile -d $tmpdir
cd $tmpdir/elasticsearch-*

# install plugin
plugin_file=`ls $WORKSPACE/build/packages/*.zip`
echo "plugin file "$plugin_file
bin/plugin -i marvel -u file:$plugin_file
# fire up elasticsearch in the background
echo "Starting up elasticsearch"
bin/elasticsearch -d -Des.cluster.name=esmarvelcore$EXECUTOR_NUMBER -Des.http.port=$es_port -Des.discovery.zen.ping.multicast.enabled=false -Des.marvel.agent.exporter.es.hosts=localhost:$es_port

# wait for elasticsearch to start
sleep 60
