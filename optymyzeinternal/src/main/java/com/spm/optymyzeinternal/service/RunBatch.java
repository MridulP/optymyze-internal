package com.spm.optymyzeinternal.service;

import java.io.File;
import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


@Service
public class RunBatch {


public void runScript() throws InterruptedException{
		
	System.out.println("before batch execution");
		
	
	/*ProcessBuilder pb = new ProcessBuilder(Arrays.asList(new String[] {"cmd.exe", "/C", "Start", "C:\\Perl\\test.bat"}));
	pb.redirectErrorStream(true);
	try {
	    Process proc = pb.start();
	   // proc.waitFor();
	  
	    proc.destroy();
	    
	} catch (Exception e) {
	    e.printStackTrace(); */
		
	
	try {
			String  [] command = { "cmd.exe", "/C", "Start", "C:\\Perl\\test.bat" };
			Runtime r = Runtime.getRuntime();
            Process p = r.exec(command);
            p.waitFor();
            p.destroy();
           
            Thread.sleep(10000);
            
            } catch (Exception e) 
            {
            System.out.println("Execution error");
            } 
		    System.out.println("after batch execution");
		    System.gc();
					
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
