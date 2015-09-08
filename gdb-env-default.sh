s script will be modified during installation
# and be constantly used afterwards
# make sure this script is at the top level of GDB deploy directory

## check
base=`dirname $0`
cd $base
#directories
### for now, use the currently working directory as GDB_HOME
export GDB_HOME=`pwd`/test
export HADOOP_HOME=$GDB_HOME/hadoop-1.2.1
export HBASE_HOME=$GDB_HOME/hbase-0.94.5
export TOMCAT_HOME=$GDB_HOME/apache-tomcat-7.0.64
export SEARCH_HOME=$GDB_HOME/search
export GDB_ADMIN=$GDB_HOME/gdb-admin
export GDB_CLIENT=$GDB_HOME/gdb-client
## $SEARCH_HOME/master online search search-mq redis

## variables
#hadoop/hbase/zk
export HDFS_ADDR_DEF=10.100.1.12:9100
export SLAVES_DEF=10.100.1.12,10.100.1.20
export ZK_QUORUM_DEF=10.100.1.20:2181

#dtsearch
export DTMASTER_ADDR_DEF=10.100.1.12:7000
export DTONLINE_ADDR_DEF=10.100.1.20:7005
export DTSEARCH_ADDR_DEF=10.100.1.12:7010
export REDIS_ADDR_DEF=10.100.1.20:6379
#tomcat
export REST_ADDR_DEF=10.100.1.20:8080

## data directory
export HDFS_TMP_DIR=$GDB_HOME/data/tmp
export HDFS_NAME_DIR=$GDB_HOME/data/hdfs/name
export HDFS_DATA_DIR=$GDB_HOME/data/hdfs/data
export HBASE_ZKDATA_DIR=$GDB_HOME/data/zkdata

