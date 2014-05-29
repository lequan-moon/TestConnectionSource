package org.wiperdog.testmongodbconnectionsource
import static org.junit.Assert.*;

import java.util.Map;

import org.junit.After;
import org.junit.Test;
import org.wiperdog.testmongodbconnectionsource.MONGODBConnectionSource;

import com.gmongo.GMongo;
import com.mongodb.DB;


class MongoDBConnectionSource_TestDBAuthenticate {
	MONGODBConnectionSource obj = new MONGODBConnectionSource();
	def dbInfo = [dbconnstr:"10.0.1.189:27017", user:"root", dbHostId:"", dbSid:"", strDbType:'@MONGO', dbconnstr:"10.0.1.189:27017"]
	def datadir_params = [MONGO:[default:"", getData:[sql:"", append:""]]]
	def dbversion_params = [MONGO:[default:"", getData:[sql:"", append:""]]]
	def programdir_params = [MONGO:[default:"", getData:[sql:"", append:""]]]
	def logdir_params = [MONGO:[default:"", getData:[sql:"", append:""]]]

	@Test
	public void test01(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertTrue(binding.gmongo instanceof GMongo);
	}
	
	/*
	 * dbinfo != null, all other = null
	 * still ok 
	 */
	@Test
	public void test02(){
		datadir_params = null
		dbversion_params = null
		programdir_params = null
		logdir_params = null
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertTrue(binding.gmongo instanceof GMongo);
	}
	
	/*
	 * With all parameters provided, db information will never be null but be default value
	 */
	@Test
	public void test03(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertTrue(binding.gmongo instanceof GMongo);
		assertNotNull(binding.gmongo.datadirectory)
		assertNotNull(binding.gmongo.programdirectory)
		assertNotNull(binding.gmongo.dbmsversion)
		assertNotNull(binding.gmongo.logdirectory)
		assertNotNull(binding.mongoUser)
		assertTrue(binding.mongoUser == "root")
		assertTrue(binding.mongoPassword == "insight")
	}
	
	/*
	 * Test getting some data from mongodb using the connection
	 */
	@Test
	public void test04(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params)
		Object binding = obj.getBinding();
		println binding
		GMongo connection = binding.gmongo
		assertTrue(connection instanceof GMongo)
		println "Getting sample data from Mongodb wiperdog"
		DB db = connection.getDB("wiperdog")
		db.authenticate(binding.mongoUser, binding.mongoPassword.toCharArray())
		def setCollection = db.getCollectionNames()
		assertTrue(setCollection.size() > 0)
	}

	@After
	public void after(){
		obj.closeConnection();
	}
}
