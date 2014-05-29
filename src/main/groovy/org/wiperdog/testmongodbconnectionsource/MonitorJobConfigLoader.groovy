package org.wiperdog.testmongodbconnectionsource

class MonitorJobConfigLoader {
	/*
	 * alshdlashdklasj
	 */
	def static getProperties(){
		def newProperties = new Hashtable()
		newProperties.put(ResourceConstants.DBPASSWORD_FILE_DIRECTORY, "resources")
		newProperties.put(ResourceConstants.MESSAGE_FILE_DIRECTORY, "resources")
		return newProperties
	}
}
