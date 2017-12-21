package com.spm.optymyzeinternal.service;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;



public class FileUpload {

	
	private static final Logger logger = LoggerFactory.getLogger(FileUpload.class);
	
	
	public void uploadHandler(String name,MultipartFile file){
		
		if (!file.isEmpty()) {
			try {
				byte[] bytes = file.getBytes();

				// Creating the directory to store file

				// String rootPath = System.getProperty("catalina.home");
				String rootPath = "C:\\perl\\";
				File dir = new File(rootPath + File.separator + "tmpFiles");
				if (!dir.exists())
					dir.mkdirs();

				// Create the file on server
				File serverFile = new File(dir.getAbsolutePath() + File.separator + name);
				BufferedOutputStream stream = new BufferedOutputStream(new FileOutputStream(serverFile));
				stream.write(bytes);
				stream.close();

				logger.info("Server File Location=" + serverFile.getAbsolutePath());

				// return "You successfully uploaded file=" + name;

				} catch (Exception e) {
				logger.info("You failed to upload " + name + " => " + e.getMessage());
				}

				} else {
				logger.info("You failed to upload " + name + " because the file was empty.");
		}
	}
	
	
}
