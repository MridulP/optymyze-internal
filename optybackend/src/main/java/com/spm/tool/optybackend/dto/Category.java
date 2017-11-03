package com.spm.tool.optybackend.dto;

public class Category {


	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getProjectName() {
		return projectName;
	}
	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}
	public String getDbName() {
		return dbName;
	}
	public void setDbName(String dbName) {
		this.dbName = dbName;
	}
	public String getParam1() {
		return Param1;
	}
	public void setParam1(String param1) {
		Param1 = param1;
	}
	public String getParam2() {
		return Param2;
	}
	public void setParam2(String param2) {
		Param2 = param2;
	}
	public String getParam3() {
		return Param3;
	}
	public void setParam3(String param3) {
		Param3 = param3;
	}
	public boolean isActive() {
		return active;
	}
	public void setActive(boolean active) {
		this.active = active;
	}
	
	
	
	/*
	 * Private fields
	 */

	private int id;
	private String projectName;
	private String dbName;
	private String Param1;
	private String Param2;
	private String Param3;
	private boolean active = true;

}
