TestConnectionSource
====================
Test PlugableDBConnection  
There are 4 tests.  
 - MongoDBConnectionSource_TestDBNoauthenticate  
      + Test Mongodb Connection with non authenticate database
 - MongoDBConnectionSource_TestDBAuthenticate  
      + Test Mongodb Connection with authenticated database
 - EncryptedDBConnectionSource_Test01  
      + Test a common connection with MySQL server
 - EncryptedDBConnectionSource_Test02    
      + Test a common connection with postgress server

You should check the resource/default.params first for configuration as well as each Testcase in src/test  
Usage:  
  - mvn -Dtest=*Test* test

There is a test_plugable_connection.sh.  
Running this script will bring you to the real environment with wiperdog and some dummy jobs.  
Try it out.

