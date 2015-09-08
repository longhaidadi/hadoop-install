#!/bin/bash

function usage (){
        echo "Usage startup.sh <command_1> <command_2>"
        echo "where command_1 can be : hadoop,hbase,dt-search,tomcat,all"
        echo "where command_2 can be : format (only used in hadoop ),start ,stop,uninstall"
}
function kill_process(){
        if [ $# != 1 ] ; then
            echo "Usage <processname>"
            exit 0
        fi
        for pid in $(ps aux |grep $1 |grep -v grep|awk '{print $2}'); do
            kill -9 $pid
            sleep 1
        done
}


function format_hadoop(){
	echo "[Info]: Format hadoop cluster"
	ssh  $HADOOP_NAMENODE "
		echo 'Y' | $HADOOP_HOME/bin/hadoop namenode -format 
		exit
	"
}

function start_hadoop(){
	echo "[Info]:start hadoop ..."
	
	ssh $HADOOP_NAMENODE "
		$HADOOP_HOME/bin/start-all.sh
		exit
	"
}


function start_hbase(){
	echo "[Info]:start hbase ..."
	ssh $HBASE_MASTER "
		$HBASE_HOME/bin/start-hbase.sh
		exit
	"
}


function start_tomcat(){
	echo "[Info]:start tomcat ..." 
	ssh $TOMCAT_HOST  "
		$TOMCAT_HOME/bin/startup.sh
		exit
	"
}

function start_redis(){
	echo "[Info] : start redis ..."
	ssh $REDIS_ADDR_HOST "
		cd $REDIS_ADDR_HOME
		nohup $SEARCH_HOME/redis-3.0.3/bin/redis-server $REDIS_ADDR_PORT 1>>redis.log 2>>redis.err &
		exit
	"
}

function start_dt-search() {
	echo "[Info]: start dt-search"
	if [ $# != 1 ] ; then
		echo "Usage: <chanenl>"
		exit
	fi

	ssh $DTMASTER_ADDR_HOST "
		$GDB_ADMIN/start.sh $1
		exit
	"
}



function stop_hadoop(){
	echo "stop hadoop ..."
	ssh $HADOOP_NAMENODE "
		$HADOOP_HOME/bin/stop-all.sh
		exit
	"
}
function stop_hbase(){
	echo "stop hbase"
	ssh $HBASE_MASTER "
		$HBASE_HOME/bin/stop-hbase.sh
		exit
	"
}
function stop_tomcat(){
	echo "[Info]: stop tomcat ..."
	ssh  $TOMCAT_HOST "
		$TOMCAT_HOME/bin/shutdown.sh
		exit
	"
}
function stop_redis(){
	echo "[Info] : stop redis"
	ssh $REDIS_ADDR_HOST "
		$SEARCH_HOME/redis-3.0.3/bin/redis-cli -h $REDIS_ADDR_HOST -p $REDIS_ADDR_PORT shutdown
		exit
	"
}
function stop_dt-search(){
	echo "stop dt-search ..."
	if [ $# != 1 ] ; then
		echo "Usage: <chanenl>"
		exit
	fi
	
	ssh $DTMASTER_ADDR_HOST "
		$GDB_ADMIN/stop.sh $1
		exit
	"
}
function uninstall_hadoop(){
	cluster_nodes="$HADOOP_NAMENODE $HADOOP_SLAVES"
	for node in $cluster_nodes ; do 
		ssh $node "
			$HADOOP_HOME/bin/stop-all.sh
			rm -rf $HADOOP_HOME
			exit
		"
	done
	echo "uninstall hadoop"
}
function uninstall_hbase(){
	
	cluster_nodes="$HADOOP_NAMENODE $HADOOP_SLAVES"
    for node in $cluster_nodes ; do
        ssh $node "
		$HBASE_HOME/bin/stop-hbase.sh
                rm -rf $HBASE_HOME     
		exit
            "
        done

	echo "uninstall habse"
}

function uninstall_tomcat() {
	ssh $TOMCAT_HOST "
		$TOMCAT_HOME/bin/shutdown.sh
		rm -rf $/TOMCAT_HOME
		exit
	"
}

function uninstall_redis() {
	ssh $REDIS_ADDR_HOST "
		$SEARCH_HOME/redis-3.0.3/bin/redis-cli -h $REDIS_ADDR_HOST -p $REDIS_ADDR_PORT shutdown
		rm -rf $SEARCH_HOME/reids-3.0.3
		exit
	"
}

function uninstall_dt-search(){
	echo "uninstall dt-search ..."
	if [ $# != 1 ] ; then
		echo "Usage: <chanenl>"
		exit
	fi
	
	ssh $DTMASTER_ADDR_HOST "
		$GDB_ADMIN/stop.sh $1
		rm -rf GDB_ADMIN/
		exit
	"
}

function start_all(){
#	format_hadoop
	echo "If you start the first time [Y|N]"
	read START_TIMES
	if [ "$START_TIMES" == "Y" ] ; then	
		format_hadoop
	fi
		
	start_hadoop
	start_hbase
	start_tomcat
	start_redis
}

function stop_all() {
	stop_hbase
	stop_hadoop
	stop_tomcat
	stop_redis
}

function uninstall_all() {
	uninstall_hbase
	uninstall_hadoop
	uninstall_tomcat
	uninstall_redis
}
#function is defined upside
##############################################################
# bash is run downside


base=`dirname $0`
cd $base
ARGS="$@"
# check usage 
if [ $# -lt 2 ] ; then
        usage
        exit
fi


# check Java API , if java api can not work , the installer will exit
`java -version` >/dev/null 2>&1
if [ $? = 0 ]; then
        echo "java is installed"
else
        echo "java is not installed "
        exit -1
fi


#load gdb-env.sh 
echo "[Info] : load "
.  ./gdb-env.sh

echo "$HADOOP_HOME"
if [ "$1" == "hadoop" ] ; then
	if [ "$2" == "format" ]; then
		format_hadoop
	elif [ "$2" == "start" ]; then
		start_hadoop
	elif [ "$2" == "stop" ]; then
		stop_hadoop
	elif [ "$2" == "uninstall" ]; then
		uninstall_hadoop
	else
		echo "$2 is not correct "
		usage
	fi
elif [ "$1" == "hbase" ]; then
	 if [ "$2" == "start" ]; then
                start_hbase
        elif [ "$2" == "stop" ]; then
                stop_hbase
        elif [ "$2" == "uninstall" ]; then
                uninstall_hbase
        else
                echo "$2 is not correct "
                usage
        fi
elif [ "$1" == "dt-search" ]; then
         if [ "$2" == "start" ]; then
                start_hbase 
        elif [ "$2" == "stop" ]; then
                stop_hbase
        elif [ "$2" == "uninstall" ]; then
                uninstall_hbase
        else
                echo "$2 is not correct "
                usage
        fi
elif [ "$1" == "redis" ]; then
	if [ "$2" == "start" ] ; then
		start_redis
	elif [ "$2" == "stop" ] ; then
		stop_redis
	elif [ "$2" == "uninstall" ] ; then
		uninstall_redis
	else 
		echo "$2 is not correct"
			usage
	fi
elif [ "$1" == "tomcat" ]; then
         if [ "$2" == "start" ]; then
                start_tomcat
        elif [ "$2" == "stop" ]; then
                stop_tomcat
        elif [ "$2" == "uninstall" ]; then
                uninstall_tomcat
        else
                echo "$2 is not correct "
                usage
		exit
        fi
elif [ "$1" == "all" ]; then
         if [ "$2" == "start" ]; then
                start_all
        elif [ "$2" == "stop" ]; then
                stop_all
        elif [ "$2" == "uninstall" ]; then
                uninstall_all
        else
                echo "$2 is not correct "
                usage
		exit
        fi
else
	echo "$1 is not correct"
	usage
	exit
fi


