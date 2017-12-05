package com.spm.optymyzeinternal.service;

import java.io.File;

public class MoveBatch {

	public void moveFile(){
		
		File afile=new File ("C:\\eclipse\\Session_report");
		
		try {
		
		if(afile.renameTo(new File("C:\\perl\\" + afile.getName()))){
			System.out.println("File is moved successful!");
		   }else{
			System.out.println("File is failed to move!");
		   }

		}catch(Exception e){
			e.printStackTrace();
		}
		
		
	}
	
	
}
