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
	
	public void createScript(String projInput, String dbInput, String userid, String password,String startDate_picker, String endDate_picker) throws FileNotFoundException{
	
		projInput1=projInput;
		
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
			dos.writeBytes(" "+projInput1);	
			dos.writeBytes(" -s");
			dos.writeBytes(" "+startDate_picker);
			dos.writeBytes(" -e");
			dos.writeBytes(" "+endDate_picker);
			
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
	  //Format formatter = new SimpleDateFormat("MM/DD/YYYY hh:mm:ss");
	     
	     File f = new File("C:\\eclipse\\"+projInput1); 

	            while(f.exists()) {     

	            //  f.renameTo(new File("c:\\perl\\"+fileName + "_"+formatter.format(date)+".html"));
	               f.renameTo(new File("c:\\perl\\"+fileName + "_"+version+".html"));
	               version++;
	                
	            }
	            System.out.println("File moved and version incremented sucessfully"); 
	        }
		

		

	
	
	}
	

	