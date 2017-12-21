package com.spm.optymyzeinternal.service;


import java.util.Arrays;
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


	public void runScript2() {
		try {
		String  [] command = { "cmd.exe", "/C", "Start", "C:\\Perl\\CharDetect.bat"};
		Runtime r1 = Runtime.getRuntime();
        Process p1 = r1.exec(command);
        p1.waitFor();
        p1.destroy();
		
		;
		
		/*ProcessBuilder pb = new ProcessBuilder(Arrays.asList(new String[] {"cmd.exe", "/C", "Start", "C:\\Perl\\CharDetect.bat"}));
		pb.redirectErrorStream(true);
		try {
		    Process proc = pb.start();
		    proc.waitFor();
		  
		    proc.destroy();*/
		    
		} catch (Exception e) {
		    e.printStackTrace();

}

	}
}






