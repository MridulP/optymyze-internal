package com.spm.optymyzeinternal.service;

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
		
		//ResourceLoader resourceLoader;
		//resourceLoader.getResource("classpath:/batch/test.bat");
	
	System.out.println("before batch execution");
		
		Process process;
		try {
			String path="classpath";
			System.out.println(path);
			process = Runtime.getRuntime().exec("cmd /c start c:\\perl\\test.bat <file:///c:/perl/test.bat>");
			process.waitFor();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
				
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
