package com.spm.optymyzeinternal.service;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CreateBatch {

	
	public String projInput;
	public void createScript(String projInput, String dbInput, String userid, String password, String startDate_picker, String endDate_picker) throws FileNotFoundException{
	
		
		
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
			dos.writeBytes(" " +projInput+"_report");
					
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
	
	
	
}
