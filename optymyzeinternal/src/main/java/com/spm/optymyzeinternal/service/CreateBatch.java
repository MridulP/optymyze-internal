package com.spm.optymyzeinternal.service;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;

public class CreateBatch {

	@Autowired
	public void createScript() throws FileNotFoundException{
		
		File file = new File ("\\c:\\perl\\test.bat");
		FileOutputStream fos  = new FileOutputStream(file);
		DataOutputStream dos = new DataOutputStream(fos);
		try {
			dos.writeBytes("perl c:\\perl\\");
			dos.writeBytes("ReportUserSessionsOZ.pl");
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
			dos.close();
			
	} catch (IOException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	}
	
	
	
}
