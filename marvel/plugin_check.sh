#!/bin/bash
# shutdown cluster, wait, remove directory
es_port=`expr 9240 + $EXECUTOR_NUMBER`
#echo `curl "http://localhost:$es_port/_nodes?plugin=true&pretty"`
# check for each plugin
echo "Checking for marvel plugin in nodes info"
curl "http://localhost:$es_port/_nodes?plugin=true&pretty" | grep -n marvel
result1=$?
echo "Shutting down cluster and removing install directory"
curl -XPOST -s 'http://localhost:'$es_port'/_shutdown'
tmpdir=$WORKSPACE/tmp/es-*
cd $tmpdir/elasticsearch-*
cd logs
! grep ERROR.*marvel *.log
result2=$?
gzip *
cd ..
rm -r -f $WORKSPACE/logs
mv logs $WORKSPACE
exit $(($result1 | $result2))