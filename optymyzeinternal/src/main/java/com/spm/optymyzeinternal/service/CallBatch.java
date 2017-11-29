package com.spm.optymyzeinternal.service;

public class CallBatch {
	
	public void callScript () throws InterruptedException{
		
		System.out.println("before batch execution");
			
			try {
				String  [] command2 = { "cmd.exe", "/C", "Start", "C:\\Perl64\\Invokeperl.bat" };
				Runtime r2 = Runtime.getRuntime();
	            Process p2 = r2.exec(command2);
	            p2.waitFor();
	            
	            

	            } catch (Exception e) 
	            {

	            
			    System.out.println("after batch execution");
						
		}
	}
}
