package com.spm.optymyzeinternal.service;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


@Service
public class CreateBatch {
	
	public static String projInput1;
	
	public void createScript(String projName,String projInput, String dbInput, String userid, String password,String startDate_picker, String endDate_picker) throws FileNotFoundException{
	
		projInput1=projName;
			
		File file = new File ("\\c:\\Perl\\test.bat");
		FileOutputStream fos  = new FileOutputStream(file);
		DataOutputStream dos = new DataOutputStream(fos);
		try {
			dos.writeBytes("perl c:\\Perl\\");
			dos.writeBytes("ReportUserSessionsOZ.pl");
			dos.writeBytes(" "+ dbInput);
			dos.writeBytes(" "+userid);
			dos.writeBytes(" "+password);
			dos.writeBytes(" -n");
			dos.writeBytes(" "+projInput);					
			dos.writeBytes(" "+projName);	
			dos.writeBytes(" -s");
			dos.writeBytes(" "+startDate_picker);
			dos.writeBytes(" -e");
			dos.writeBytes(" "+endDate_picker);
			dos.writeBytes(" -c");
			dos.writeBytes(" "+projName);
			
			
			dos.close();
			fos.close();
			
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	}
	
	public void fileTransfer(){
	
		 int version=1;
	     String fileName = projInput1;
	     System.out.println("Value of project during move"+projInput1);
	     Date date = new Date();
	  	     
	        //File f = new File("C:\\eclipse\\"+projInput1); 
	     	File f = new File("c:\\Tomcat_OptymyzeInternal-Support\\" + projInput1); 
	     
	            while(f.exists()) {     

	               f.renameTo(new File("e:\\Concurrent_user_session\\"+fileName + "_"+version+".html"));
	              // f.renameTo(new File("c:\\perl\\"+fileName + "_"+version+".html"));
	               version++;	                
	            }
	            System.out.println("File moved and version incremented sucessfully"); 
	            
	            
	            CreateBatch delAction = new CreateBatch();
	            delAction.delete(7,".html");
	            
	        }
	
	
	public void delete(long days, String fileExtension){
		
		//String dirPath = "c:\\perl";
		String dirPath = "e:\\Concurrent_user_session";
		
		File folder = new File(dirPath);
		
		if (folder.exists()) {
			 
            File[] listFiles = folder.listFiles();
 
            long eligibleForDeletion = System.currentTimeMillis() - (days * 24 * 60 * 60 * 1000L);
 
            for (File listFile: listFiles) {
 
                if (listFile.getName().endsWith(fileExtension) &&
                    listFile.lastModified() < eligibleForDeletion) {
 
                    if (!listFile.delete()) {
 
                        System.out.println("Sorry Unable to Delete Files..");
 
                    }
                }
            }
        }
    }
		
	
	
	
		
	public void createBatch2(String name){
		
		System.out.println("File Name is:"+name);
		
		try {
		File file2 = new File ("\\c:\\Perl\\CharDetect.bat");
		FileOutputStream fos2  = new FileOutputStream(file2);
		DataOutputStream dos2 = new DataOutputStream(fos2);
		
			dos2.writeBytes("perl c:\\Perl\\");
			dos2.writeBytes("DetectCharSet.pl");
			dos2.writeBytes(" c:\\Perl\\upload\\"+name);
			dos2.writeBytes(" > ");
			//dos2.writeBytes("c:\\Perl\\tmpFiles\\Output_report.txt");
			dos2.writeBytes("e:\\Detect_Character_Encoding\\Output_report.txt");
			
			dos2.close();
			fos2.close();
			
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
		
	}
	
	
		

	
	
	}
	

	