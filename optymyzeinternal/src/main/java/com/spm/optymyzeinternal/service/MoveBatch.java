package com.spm.optymyzeinternal.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class MoveBatch {

	public void moveFile(){
		
		 File afile=new File ("C:\\eclipse\\Session_report.html");
		//File afile=new File ("C:\\Tomcat_OptymyzeInternal-Support\\Session_report");
		
/*		try {
						
			if(fileName.renameTo(new File("C:\\perl\\" + fileName.getName()))){
				System.out.println("File is moved successful!");
			   }else{
				System.out.println("File is failed to move!");
			   }

			}catch(Exception e){
				e.printStackTrace();
			}
		} */
		
		
		
	String fileName= "c:\\eclipse\\Session_report.html";
		String extension = "";
		String name = "";
		
		//String.valueOf(increase);
		int idxofdot = fileName.lastIndexOf('.');
		extension = fileName.substring(idxofdot + 1);
		name = fileName.substring(0,idxofdot);
		Path path = Paths.get(fileName);
		int counter = 1;
		File f = null;
		while(Files.exists(path))
				{
					fileName = name+"("+counter+")."+extension;
					path = Paths.get(fileName);
					counter++;
				}
		
	
		f = new File(fileName);
		System.out.println("Inside file increement");
		
	}
	
	
}
