package com.spm.optymyzeinternal.service;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;



public class FileUpload {

	
	private static final Logger logger = LoggerFactory.getLogger(FileUpload.class);
	
	
	public void uploadHandler(MultipartFile file){
		String UPLOADED_FOLDER = "C:\\perl\\";
		if (!file.isEmpty()) {
			try {
				
				// Get the file and save it somewhere
				byte[] bytes = file.getBytes();
				
				Path path = Paths.get(UPLOADED_FOLDER + file.getOriginalFilename());
				Files.write(path, bytes);

				
				
			/*	File dir = new File(rootPath + File.separator + "tmpFiles");
				
					if (!dir.exists())
					dir.mkdirs(); 

				// Create the file on server
				File serverFile = new File(dir.getAbsolutePath() + File.separator+name );
				BufferedOutputStream stream = new BufferedOutputStream(new FileOutputStream(serverFile));
				stream.write(bytes);
				stream.close(); */

			//	logger.info("Server File Location=" + serverFile.getAbsolutePath());

				// return "You successfully uploaded file=" + name;

				} catch (Exception e) {
				logger.info("You failed to upload "  + e.getMessage());
				}

				} else {
				logger.info("You failed to upload because the file was empty.");
		}
	}
	
	
}
