package com.spm.optymyzeinternal.service;

public class RunBatch {


	public static void runBatchScript() {
        try {
        	Process p = Runtime.getRuntime().exec("cmd /c c:/perl/test.bat");
    		p.waitFor();
        } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
        }
  }
}
	 
	

