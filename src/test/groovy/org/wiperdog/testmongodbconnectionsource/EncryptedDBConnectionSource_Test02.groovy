package org.wiperdog.testmongodbconnectionsource;

import static org.junit.Assert.*;

import groovy.sql.Sql
import org.junit.Test;

class EncryptedDBConnectionSource_Test02 {
	EncryptedDBConnectionSourceImpl obj = new EncryptedDBConnectionSourceImpl()
	def dbInfo = [dbconnstr:"jdbc:mysql://localhost:3306/information_schema", user:"root", dbHostId:"", dbSid:"", strDbType:'@MYSQL', strDbTypeDriver:'com.mysql.jdbc.Driver']
	def datadir_params = [MYSQL:[default:"C:/MySQL/data",getData:[sql:"SELECT @@datadir",append:""]]]
	def dbversion_params = [MYSQL:[default:"",getData:[sql:"select @@VERSION",append:""]]]
	def programdir_params = [MYSQL:[default:"" ,getData:[sql:"SELECT @@basedir",append:"usr/bin"]]]
	def logdir_params = [MYSQL:[default:"",getData:[sql:"SELECT @@general_log_file;",append:""]]]
	
	@Test
	public void test01(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertTrue(binding.sql instanceof Sql);
	}
	
	/**
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
		assertTrue(binding.sql instanceof Sql);
	}
	
	/**
	 * With all parameters provided, db information will never be null but be default value
	 */
	@Test
	public void test03(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertTrue(binding.sql instanceof Sql);
		assertNotNull(binding.sql.datadirectory)
		assertNotNull(binding.sql.programdirectory)
		assertNotNull(binding.sql.dbmsversion)
		assertNotNull(binding.sql.logdirectory)
	}
	
	/**
	 * Check if the Plugin manages connections
	 * Get existed connection instead of create new
	 */
	@Test
	public void test04(){
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		def binding1 = obj.getBinding();
		def sql1 = binding1.sql
		
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		def binding2 = obj.getBinding();
		def sql2 = binding2.sql
		assertEquals(sql1, sql2)
	}
	
	/**
	 * Check if there are no password found for the current user
	 */
	@Test
	public void test05(){
		dbInfo.user = "root123"
		obj.newSqlInstance(dbInfo, datadir_params, dbversion_params, programdir_params, logdir_params);
		Object binding = obj.getBinding();
		assertNull(binding.sql);
	}
}
