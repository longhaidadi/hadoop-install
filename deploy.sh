#I/bin/bash
## deploy gdb
# the deployer will go into the base-dir,and then deploy gdb
base=`dirname $0`
cd $base
echo $base


#load default, including directory
. ./gdb-env-default.sh



echo "----------------------------------------------------------------------------"


echo "Please allocate your machines ahead, and start this configuration..........."
echo "Please input hadoop namenode as host:port, empty for $HDFS_ADDR_DEF"
read HDFS_ADDR
if [ "$HDFS_ADDR" == "" ]; then
   HDFS_ADDR=$HDFS_ADDR_DEF
fi


#extract hostname
HADOOP_NAMENODE=$(./tool get-host $HDFS_ADDR)
MR_ADDR_DEF=$HADOOP_NAMENODE:9101
echo "Please input hadoop jobtracker as host:port, empty for $MR_ADDR_DEF"
# 1 
read MR_ADDR
if [ "$MR_ADDR" == "" ]; then
  MR_ADDR=$MR_ADDR_DEF
fi

#extract hostname
HADOOP_JOBTRACKER=$(./tool get-host $MR_ADDR)

echo "Please input hadoop datanodes/tasktracker/hbase-regionserver as host1,host2,... empty for $SLAVES_DEF"
# 2
read HADOOP_SLAVES
if [ "$HADOOP_SLAVES" == "" ]; then
  HADOOP_SLAVES=$SLAVES_DEF
fi

echo "Please input hbase quorum as host1:port1,host2:port2,... empty for $ZK_QUORUM_DEF"
# 3
read ZK_QUORUM
if [ "$ZK_QUORUM" == "" ]; then
  ZK_QUORUM=$ZK_QUORUM_DEF
fi

ZK_QUORUM_HOST=$(./tool get-host $ZK_QUORUM)
ZK_QUORUM_PORT=$(./tool get-port $ZK_QUORUM)

HBASE_MASTER_DEF=$HADOOP_NAMENODE
echo "Please input hbase master as host, empty for $HBASE_MASTER_DEF (same with hadoop namenode)"
# 4
read HBASE_MASTER
if [ "$HBASE_MASTER" == "" ]; then
  HBASE_MASTER=$HBASE_MASTER_DEF
fi

echo "Please input dtsearch master as host:port, empty for $DTMASTER_ADDR_DEF"
#5
read DTMASTER_ADDR
if [ "$DTMASTER_ADDR" == "" ]; then
  DTMASTER_ADDR=$DTMASTER_ADDR_DEF
fi



echo "Please input dtsearch online as host:port, empty for $DTONLINE_ADDR_DEF"
#6
read DTONLINE_ADDR
if [ "$DTONLINE_ADDR" == "" ]; then
  DTONLINE_ADDR=$DTONLINE_ADDR_DEF
fi


echo "Please input dtsearch search as host:port, empty for $DTSEARCH_ADDR_DEF"
#7
read DTSEARCH_ADDR
if [ "$DTSEARCH_ADDR" == "" ]; then
  DTSEARCH_ADDR=$DTSEARCH_ADDR_DEF
fi
DTMASTER_ADDR_HOST=$(./tool get-host $DTMASTER_ADDR)
DTONLINE_ADDR_HOST=$(./tool get-host $DTONLINE_ADDR)
DTSEARCH_ADDR_HOST=$(./tool get-host $DTSEARCH_ADDR)

echo "Please input redis as host:port, empty for $REDIS_ADDR_DEF"
#8
read REDIS_ADDR
if [ "$REDIS_ADDR" == "" ]; then
  REDIS_ADDR=$REDIS_ADDR_DEF
fi
REDIS_ADDR_HOST=$(./tool get-host $REDIS_ADDR)
REDIS_ADDR_PORT=$(./tool get-port $REDIS_ADDR)
echo "Please input REST as host:port, empty for $REST_ADDR_DEF"
#9
read REST_ADDR
if [ "$REST_ADDR" == "" ]; then
  REST_ADDR=$REST_ADDR_DEF
fi

TOMCAT_HOST=$( ./tool get-host $REST_ADDR )

# record the environment setted by the deployer in gdb-env.sh
cat /dev/null > gdb-env.sh
echo '#!/bin/bash' >>gdb-env.sh
echo "export GDB_HOME=$GDB_HOME"  >> gdb-env.sh
echo "export HADOOP_HOME=$HADOOP_HOME" >>gdb-env.sh
echo "export HBASE_HOME=$HBASE_HOME" >>gdb-env.sh
echo "export TOMCAT_HOME=$TOMCAT_HOME" >>gdb-env.sh
echo "export SEARCH_HOME=$SEARCH_HOME" >> gdb-env.sh
echo "export GDB_ADMIN=$GDB_ADMIN" >>gdb-env.sh
echo "export GDB_CLIENT=$GDB_CLIENT" >>gdb-env.sh
echo "export HDFS_TMP_DIR=$HDFS_TMP_DIR" >>gdb-env.sh
echo "export HDFS_NAME_DIR=$HDFS_NAME_DIR" >>gdb-env.sh
echo "export HDFS_DATA_DIR=$HDFS_DATA_DIR" >>gdb-env.sh

echo "export HDFS_ADDR=$HDFS_ADDR"   >> gdb-env.sh 
echo "export HADOOP_NAMENODE=$HADOOP_NAMENODE" >> gdb-env.sh
echo "export MR_ADDR=$MR_ADDR" >> gdb-env.sh
echo "export HADOOP_JOBTRACKER=$HADOOP_JOBTRACKER" >> gdb-env.sh
echo "export ZK_QUORUM=$ZK_QUORUM" >> gdb-env.sh
echo "export ZK_QUORUM_HOST=$ZK_QUORUM_HOST" >> gdb-env.sh
echo "export ZK_QUORUM_PORT=$ZK_QUORUM_PORT" >> gdb-env.sh
echo "export HBASE_MASTER=$HBASE_MASTER" >>gdb-env.sh
echo "export DTMASTER_ADDR_HOST=$DTMASTER_ADDR_HOST" >>gdb-env.sh
echo "export DTONLINE_ADDR_HOST=$DTONLINE_ADDR_HOST" >>gdb-env.sh 
echo "export DTSEARCH_ADDR_HOST=$DTSEARCH_ADDR_HOST" >>gdb-env.sh
echo "export TOMCAT_HOST=$TOMCAT_HOST" >>gdb-env.sh
echo "export REDIS_ADDR_HOST=$REDIS_ADDR_HOST" >>gdb-env.sh
echo "export REDIS_ADDR_PORT=$REDIS_ADDR_PORT" >>gdb-env.sh
chmod +x gdb-env.sh


echo "----------------------------------------------------------------------------"
echo "You have done the configuration, I will commit these changes, please wait..."
echo "----------------------------------------------------------------------------"

#split by comma
HADOOP_SLAVES=${HADOOP_SLAVES//,/ }
HBASE_REGIONS=$HADOOP_SLAVES

#replace hadoop/conf/core-site.xml
  echo "HDFS_ADDR"
  echo "$HADOOP_HOME/conf/core-site.xml"
  sed -i "s|HDFS_ADDR|$HDFS_ADDR|g" "$HADOOP_HOME/conf/core-site.xml"
  sed -i "s|HDFS_TMP_DIR|$HDFS_TMP_DIR|g" "$HADOOP_HOME/conf/core-site.xml"
  
#replace hadoop/conf/mapred-site.xml
  echo "MR_ADDR"
  echo "$HADOOP_HOME/conf/mapred-site.xml"
  sed -i "s|MR_ADDR|$MR_ADDR|g" "$HADOOP_HOME/conf/mapred-site.xml"
  
#replace hadoop/conf/hdfs-site.xml
  echo "DATA(NAME)_PATH"
  echo "$HADOOP_HOME/conf/hdfs-site.xml"
  sed -i "s|HDFS_NAME_DIR|$HDFS_NAME_DIR|g" "$HADOOP_HOME/conf/hdfs-site.xml"
  sed -i "s|HDFS_DATA_DIR|$HDFS_DATA_DIR|g" "$HADOOP_HOME/conf/hdfs-site.xml"

#make hadoop/conf/slaves & hbase/conf/regionservers
cat /dev/null  > $HADOOP_HOME/conf/slaves
cat /dev/null  > $HADOOP_HOME/conf/masters
cat /dev/null  > $HBASE_HOME/conf/regionservers

for host in $HADOOP_SLAVES ; do
  echo $host >> $HADOOP_HOME/conf/slaves
  echo $host >> $HBASE_HOME/conf/regionservers
done
for host in $HADOOP_NAMENODE ; do
   echo $host >> $HADOOP_HOME/conf/masters
done

#replace hbase/conf/hbase-site.xml
  echo "ZK_QUORUM"
  echo "$HBASE_HOME/conf/hbase-site.xml"
  sed -i "s|ZK_QUORUM_HOST|$ZK_QUORUM_HOST|g" "$HBASE_HOME/conf/hbase-site.xml"
  sed -i "s|ZK_QUORUM_PORT|$ZK_QUORUM_PORT|g" "$HBASE_HOME/conf/hbase-site.xml"
  sed -i "s|HDFS_ADDR|$HDFS_ADDR|g" "$HBASE_HOME/conf/hbase-site.xml"
#replace dt master,online,search/dtsearch2.xml
  echo "DTMASTER_ADDR"
  echo "DTONLINE_ADDR"
  echo "DTSEARCH_ADDR"
  echo "$SEARCH_HOME/master/dtsearch2.xml"
  echo "$SEARCH_HOME/online/dtsearch2.xml"
  echo "$SEARCH_HOME/search/dtsearch2.xml"
  sed -i "s|DTMASTER_ADDR|$DTMASTER_ADDR|g" "$SEARCH_HOME/master/dtsearch2.xml"
  sed -i "s|DTONLINE_ADDR|$DTONLINE_ADDR|g" "$SEARCH_HOME/online/dtsearch2.xml"
  sed -i "s|DTSEARCH_ADDR|$DTSEARCH_ADDR|g" "$SEARCH_HOME/search/dtsearch2.xml"
#replace redis start.sh
  echo "REDIS_ADDR"
  echo "$SEARCH_HOME/redis/start.sh"
  echo "$SEARCH_HOME/search-mq/mq.properties"
  sed -i "s|REDIS_ADDR|$REDIS_ADDR|g" "$SEARCH_HOME/redis/start.sh"
  sed -i "s|REDIS_ADDR|$REDIS_ADDR|g" "$SEARCH_HOME/search-mq/mq.properties"
  sed -i "s|REDIS_ADDR_PORT|$REDIS_ADDR_PORT|g" "$SEARCH_HOME/redis-3.0.3/redis.conf"
#replace tomcat server.xml
  echo "REST_ADDR"
  #extract port from $REST_ADDR
  TOMCAT_PORT=$(./tool get-port $REST_ADDR)
  echo "$TOMCAT_HOME/conf/server.xml"
  if [ $TOMCAT_PORT == 8080 ]; then
	TOMCAT_PORT=8080
  fi
  sed -i "s|TOMCAT_PORT|$TOMCAT_PORT|g" "$TOMCAT_HOME/conf/server.xml"
#### then write the variables to gdb-env.sh  #####

#### then begin to distribute the files
#### for high speed, compress the files first
cluster_nodes="$HADOOP_NAMENODE $HADOOP_SLAVES"
tar zcf hadoop.dist.tgz -C $(dirname $HADOOP_HOME) $(basename $HADOOP_HOME)
tar zcf hbase.dist.tgz -C $(dirname $HBASE_HOME) $(basename $HBASE_HOME)
tar zcf admin.dist.tgz -C $(dirname $GDB_ADMIN) $(basename $GDB_ADMIN)
tar zcf client.dist.tgz -C $(dirname $GDB_CLIENT) $(basename $GDB_CLIENT)


for host in $cluster_nodes ; do
 #if [ $host != "localhost" ]; then
   ssh $host "
        if [ ! -d "$GDB_HOME" ] ; then
                mkdir -p $GDB_HOME      
        fi
		exit
        "
   echo "distribute to $host:$GDB_HOME"
   scp hadoop.dist.tgz hbase.dist.tgz $host:$GDB_HOME
   ssh $host "cd $GDB_HOME; tar zxf hadoop.dist.tgz ; tar zxf hbase.dist.tgz; rm -rf *.dist.tgz ;exit"
 #fi
done

#extract host
search_host=$(./tool get-host $DTMASTER_ADDR $DTONLINE_ADDR $DTSEARCH_ADDR $REDIS_ADDR)
dist=search.dist.tgz
tar zcf $dist -C $(dirname $SEARCH_HOME) $(basename $SEARCH_HOME)
for host in $search_host ; do
 #if [ $host != "localhost" ]; then
   echo "distribute $SEARCH_HOME"
   ssh $host "
		if [ ! -d "$GDB_HOME" ] ; then
			mkdir -p $GDB_HOME
		fi
	"
   scp $dist $host:$GDB_HOME
   ssh $host "cd $GDB_HOME; tar zxf $dist; rm -rf $dist "
# fi
done

TOMCAT_HOST=$(./tool get-host $REST_ADDR)
#if [ "$TOMCAT_HOST" != "localhost" ]; then
dist=tomcat.dist.tgz
  tar zcf $dist -C $(dirname $TOMCAT_HOME) $(basename $TOMCAT_HOME)
  ssh $TOMCAT_HOST "
	if [ ! -d "$GDB_HOME" ] ; then
		mkdir -p $GDB_HOME	
	fi
        "

  scp $dist $TOMCAT_HOST:$GDB_HOME
  ssh $TOMCAT_HOST "cd $GDB_HOME; tar zxf $dist; rm -rf $dist"
#fi


### clean up
rm -rf *.dist.tgz

echo "[Info]: Config the remote gdb server..."
for server in $cluster_nodes ; do
	echo "[Info]: Init hadoop hbase&data dictionary on $server ..."
        ssh $server "
                rm -rf $HDFS_NAME_DIR && mkdir -p $HDFS_NAME_DIR &&  chmod -R 755 $HDFS_NAME_DIR
		rm -rf $HDFS_DATA_DIR && mkdir -p $HDFS_DATA_DIR &&  chmod -R 755 $HDFS_DATA_DIR
		rm -rf $HDFS_TMP_DIR && mkdir -p $HDFS_TMP_DIR &&  chmod -R 755 $HDFS_TMP_DIR	
                exit
	"
done

echo "[Info]: after 5s  will start the cluster"



