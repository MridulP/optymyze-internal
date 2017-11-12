package com.spm.optymyzeinternal.service;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.ThreadFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.task.*;
import org.springframework.stereotype.Service;


@Service
public class RunBatch {

@Autowired
public void runScript() throws InterruptedException{
		
	System.out.println("before batch execution");
		
		try {
			String  [] command = { "cmd.exe", "/C", "Start", "C:\\perl\\test1.bat" };
			Runtime r = Runtime.getRuntime();
            Process p = r.exec(command);
            p.waitFor();

            } catch (Exception e) 
            {

            System.out.println("Execution error");} 
		    System.out.println("after batch execution");
					
	}

@Autowired
public void createScript() throws FileNotFoundException{
	
	File file = new File ("\\c:\\perl\\test1.bat");
	FileOutputStream fos  = new FileOutputStream(file);
	DataOutputStream dos = new DataOutputStream(fos);
	try {
		String s ="perl\n";
		dos.writeBytes("cd c:\\");
		dos.writeBytes(s +"\n");
		
		dos.writeBytes(" ReportUserSessionsOZ.pl");
		dos.writeBytes(" d34401-b0ca.ca-aws.optymyze.net");
		dos.writeBytes(" RO_12E84BAA");
		dos.writeBytes(" S5HTUew33owH");
		dos.writeBytes(" -n");
		dos.writeBytes(" DESJARDINS_SND2_SPM");
		dos.writeBytes(" pqr");
		dos.writeBytes(" -s");
		dos.writeBytes(" 10/01/2017");
		dos.writeBytes(" -e");
		dos.writeBytes(" 10/05/2017");
		
} catch (IOException e) {
	// TODO Auto-generated catch block
	e.printStackTrace();
}
}



}


	

		
/*
@Override
public void run() {
	
	SimpleAsyncTaskExecutor taskExecuter=new SimpleAsyncTaskExecutor("Thread1");
	taskExecuter.execute(this);					
	
}
}
*/

/*
public static void  runBatchScript() {
    try {
    	System.out.println("process started");       	
    	String path = "c:/perl/test.bat";
 
    	
		
    	System.out.println("process running");       	
		
    } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
    }
}
*/
