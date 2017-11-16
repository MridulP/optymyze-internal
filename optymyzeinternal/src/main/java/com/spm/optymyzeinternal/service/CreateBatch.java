package com.spm.optymyzeinternal.service;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestParam;

public class CreateBatch {

	
	@Autowired
	public void createScript(String projInput, String dbInput, String userid, String password, String startDate, String endDate) throws FileNotFoundException{
	
		
		
		File file = new File ("\\c:\\perl\\test.bat");
		FileOutputStream fos  = new FileOutputStream(file);
		DataOutputStream dos = new DataOutputStream(fos);
		try {
			dos.writeBytes("perl c:\\perl\\");
			dos.writeBytes("ReportUserSessionsOZ.pl");
			dos.writeBytes(" "+ dbInput);
			dos.writeBytes(" "+userid);
			dos.writeBytes(" "+password);
			dos.writeBytes(" -n");
			dos.writeBytes(" "+projInput);
			dos.writeBytes(" pqr");
			dos.writeBytes(" -s");
			dos.writeBytes(" "+startDate);
			dos.writeBytes(" -e");
			dos.writeBytes(" "+endDate);
			dos.close();
			
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	}
	
	
	
}
