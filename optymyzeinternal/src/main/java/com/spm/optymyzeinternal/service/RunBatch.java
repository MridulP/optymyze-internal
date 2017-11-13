package com.spm.optymyzeinternal.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


@Service
public class RunBatch {

@Autowired
public void runScript() throws InterruptedException{
		
	System.out.println("before batch execution");
		
		try {
			String  [] command = { "cmd.exe", "/C", "Start", "C:\\perl\\test.bat" };
			Runtime r = Runtime.getRuntime();
            Process p = r.exec(command);
            p.waitFor();

            } catch (Exception e) 
            {

            System.out.println("Execution error");} 
		    System.out.println("after batch execution");
					
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
