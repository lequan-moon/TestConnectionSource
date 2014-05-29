self="$0"
while [ -h "$self" ]; do
        res=`ls -ld "$self"`
        ref=`expr "$res" : '.*-> \(.*\)$'`
        if expr "$ref" : '/.*' > /dev/null; then
                self="$ref"
        else
                self="`dirname \"$self\"`/$ref"
        fi
done

dir=`dirname "$self"`
CUR_DIR=`cd "$dir/" && pwd`

if [ "$#" -ne 2 ]; then
	echo "  ********WARNING********"
    echo "  Usage: ./test_plugable_connection.sh <mongo_host> <dbtype>"
    echo "  PLease make sure that in the host, there is a mongo instance started at port 27017,"
    echo "  and a <dbtype> instance for testing common DBConnection."
    echo "  <dbtype> should be MYSQL/MSSQL/PGSQL"
    echo "  Please feel free to change config information in <wiperdog directory>/etc/default.params if needed"
else
	command -v git >/dev/null 2>&1 || { echo "git not installed. Please install it before continue." >&2; exit 1;}	
	command -v mvn >/dev/null 2>&1 || { echo "maven not installed. Please install it before continue." >&2; exit 1;}	
	command -v java >/dev/null 2>&1 || { echo "java not installed. Please install it before continue." >&2; exit 1;}
	if [ ! -f wiperdog-0.2.5-SNAPSHOT-unix.jar ]; then
		if [ ! -d wiperdog ]; then
			#~ Get wiperdog installer from git
			git clone https://github.com/leminhquan-luvina/wiperdog.git
			#~ Install it to get wiperdog's installer and install wiperdog
			cd wiperdog
			mvn install
			cd $CUR_DIR
			cp $CUR_DIR/wiperdog/target/wiperdog-0.2.5-SNAPSHOT-unix.jar $CUR_DIR
		fi
	fi
	if [ ! -d wiperdog-test ]; then
		java -jar wiperdog-0.2.5-SNAPSHOT-unix.jar -d $CUR_DIR/wiperdog-test -j 13111 -m localhost -p 27017 -n wiperdog -mp "" -s no -jd $CUR_DIR/wiperdog-test/var/job -td $CUR_DIR/wiperdog-test/var/job/ -cd $CUR_DIR/wiperdog-test/var/job/ -id $CUR_DIR/wiperdog-test/var/job/
	fi
	
	echo "Writing into " $CUR_DIR/wiperdog-test/var/conf/default.params
	cat > $CUR_DIR/wiperdog-test/var/conf/default.params <<eof
	[ 
  dbinfo: [
   "@MYSQL": [dbconnstr: "jdbc:mysql://$1:3306/information_schema", user: "root", dbHostId: "localhost", dbSid: "information_schema"],
   "localhost-@MYSQL-information_schema": [dbconnstr: "jdbc:mysql://$1:3306/information_schema", user: "root", dbHostId: "localhost", dbSid: "information_schema"],
   "@PGSQL": [dbconnstr: "jdbc:postgresql://$1:5432/postgres", user: "postgres", dbHostId: "localhost", dbSid: "postgres"],
   "localhost-@PGSQL-postgres": [dbconnstr: "jdbc:postgresql://$1:5432/postgres", user: "postgres", dbHostId: "localhost", dbSid: "postgres"],
   "@MSSQL-MSSQLSERVER2008": [dbconnstr: "jdbc:sqlserver://$1:1433", user: "sa", dbHostId:"localhost", dbSid: "MSSQLSERVER2008" ],
   "@MSSQL": [dbconnstr: "jdbc:sqlserver://$1:1433", user: "sa", dbHostId:"localhost", dbSid: "MSSQLSERVER2008" ],
   "@MONGO": [dbconnstr: "$1:27017", user: "", dbHostId:"localhost", dbSid: "wiperdog" ]
  ],
  dest: [ [ file: "stdout" ] ],
   datadirectory: [				
    ORACLE: [default:"",getData:[sql:"",append:""]],				
    SQLS: [default:"",getData:[sql:"",append:""]],	
    MYSQL: [default:"C:/MySQL/data",getData:[sql:"SELECT @@datadir",append:""]],				
    POSTGRES:[default:"",getData:[sql:"SELECT setting FROM pg_settings WHERE name = 'data_directory'",append:""]],
    MONGO:[default:"",getData:[sql:"",append:""]]				
  ],				
  programdirectory: [				
    ORACLE: [default:"",getData:[sql:"",append:""]],				
    SQLS: [default:"",getData:[sql:"" ,append:""]],		
    MYSQL: [default:"" ,getData:[sql:"SELECT @@basedir",append:"usr/bin"]],
    POSTGRES:[default:"",getData:[sql:"SELECT setting FROM pg_settings WHERE name = 'data_directory'",append:"bin"]],
    MONGO:[default:"",getData:[sql:"",append:""]] 
  ],
  dbmsversion: [
    ORACLE: [default:"",getData:[sql:"",append:""]],
    SQLS: [default:"",getData:[sql:"select @@version",append:""]],
    MYSQL: [default:"",getData:[sql:"select @@VERSION",append:""]],
    POSTGRES:[default:"",getData:[sql:"SELECT version()",append:""]],
    MONGO:[default:"",getData:[sql:"",append:""]]
  ],
  dblogdir:[
	ORACLE: [default:"",getData:[sql:"",append:""]],
    SQLS: [default:"",getData:[sql:"",append:""]],
    MYSQL: [default:"",getData:[sql:"SELECT @@general_log_file;",append:""]],															
    POSTGRES:[default:"",getData:[sql:"SELECT setting FROM pg_settings WHERE name = 'log_directory'",append:""]],
	MONGO:[default:"",getData:[sql:"",append:""]]
  ]
]
eof


	#~ Delete unused jobs
	echo "Removing unused jobs..."
	rm -rvf $CUR_DIR/wiperdog-test/var/job/*

	#~ Create some dummy job and trigger them
	echo "Create jobs..."
	echo " - Create job1"
	cat > $CUR_DIR/wiperdog-test/var/job/job1.job<<eof
JOB = [name: "job1"]
FETCHACTION = {
	println gmongo
	println gmongo.datadirectory
	println gmongo.dbmsversion
	println gmongo.programdirectory
	println gmongo.logdirectory
	return gmongo.getDB('admin').command("listDatabases")
	
}
DBTYPE = "@MONGO"
MONITORINGTYPE = "@DB"
DEST = [[file:"$CUR_DIR/wiperdog-test/tmp/job1.out"]]
eof
	echo " - Create job2"
	cat > $CUR_DIR/wiperdog-test/var/job/job2.job<<eof
JOB = [name: "job2"]
FETCHACTION = {
	return "job - sql:" + sql
}
MONITORINGTYPE = "@DB"
DBTYPE = "@$2"
DEST = [[file:"$CUR_DIR/wiperdog-test/tmp/job2.out"]]
eof

	echo " - Create job3"
	cat > $CUR_DIR/wiperdog-test/var/job/job3.job<<eof
JOB = [name: "job3"]
FETCHACTION = {
	return "job - sql:" + sql
}
MONITORINGTYPE = "@DB"
DBTYPE = "@$2"
DEST = [[file:"$CUR_DIR/wiperdog-test/tmp/job3.out"]]
eof

	echo " - Create job4"
	cat > $CUR_DIR/wiperdog-test/var/job/job4.job<<eof
JOB = [name: "job4"]

FETCHACTION = {
	def resultData = sql.rows('''
	SELECT
	 	CurrentSessionsCnt,
	 	InactiveSessionsCnt,
	 	WaitSessionsCnt
	FROM
		( SELECT count(session_id) AS CurrentSessionsCnt 
		 FROM sys.dm_exec_sessions 
		 WHERE is_user_process  = 1 AND status IN ('Running', 'Sleeping')) AS CurrentSessionsCnt,
		( SELECT count(session_id) AS InactiveSessionsCnt 
		  FROM sys.dm_exec_sessions 
		  WHERE is_user_process  = 1 AND status <> 'Running') AS InactiveSessionsCnt,
		( SELECT count(session_id) AS WaitSessionsCnt
		  FROM sys.dm_exec_sessions ds 
		  INNER JOIN 
		  sys.dm_tran_locks dt 
		  ON 
		  ds.session_id = dt.request_session_id       
	 WHERE is_user_process  = 1 and status IN ('Running', 'Sleeping')) AS WaitSessionsCnt
	'''
	)
	return resultData
}
MONITORINGTYPE = "@DB"
DBTYPE = "@$2"
DEST = [[file:"$CUR_DIR/wiperdog-test/tmp/job4.out"]]
eof

	echo " - Create trigger.trg"
	cat > $CUR_DIR/wiperdog-test/var/job/trigger.trg<<eof
job:"job1", schedule:"1"
job:"job2", schedule:"1"
job:"job3", schedule:"1"
job:"job4", schedule:"1"
eof
	echo "============================================="
	echo "Done. Now start Wiperdog to see what happen"
	echo "============================================="
	./wiperdog-test/bin/startWiperdog.sh &
	echo "Now wait for job to be executed"
	sleep 150
	#~ PID=$!
	#~ PID2=$$
	#~ echo "$PID --- $PID2"
	#~ kill -9 $PID
	pkill -f java
	
	echo "Checking MongoDB Plugin..."
	echo "The result of job1 at tmp/job1.out should not be empty"
	result1=`cat $CUR_DIR/wiperdog-test/tmp/job1.out | grep data`
	if [ "$result1" != "" -a "$result1" != "\"data\" : []" ]; then
		echo -e "\033[32m Mongo plugin running OK \033[0m"
	else
		echo -e "\033[31m Mongo plugin is not functioning \033[0m"
	fi

	echo "Checking Common DBPlugin managing the connections..."
	echo "job2 and job3 are the same database's job so it should use only one connection"
	result2=`cat $CUR_DIR/wiperdog-test/tmp/job2.out | grep "job - sql"`
	result3=`cat $CUR_DIR/wiperdog-test/tmp/job3.out | grep "job - sql"`
	echo "Connection of job2 :$result2"
	echo "Connection of job3 :$result3"
	if [ "$result2" != "" -a "$result3" != "" -a "$result2" == "$result3" ]; then
		echo -e "\033[32m Common DBPlugin running OK \033[0m"
	else
		echo -e "\033[31m Common DBPlugin is not functioning. Sql instances of job2 and job3 is not the same \033[0m"
	fi

fi
