package com.spm.optymyzeinternal.controller;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Map;
import java.util.logging.FileHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartResolver;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spm.optymyzeinternal.service.CreateBatch;
import com.spm.optymyzeinternal.service.FileUpload;
import com.spm.optymyzeinternal.service.RunBatch;

@Controller
public class PageController {

	private static final Logger logger = LoggerFactory.getLogger(PageController.class);

	@RequestMapping(value = { "/", "/home", "/index" })
	public ModelAndView index() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "home");

		logger.info("Inside PageController index method - INFO");
		logger.debug("Inside PageController index method - DEBUG");

		mv.addObject("userClickHome", true);
		return mv;
	}

	@RequestMapping(value = { "/perlrun" })
	public ModelAndView tabone() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "Perlrun");
		mv.addObject("userClicktab1", true);
		return mv;
	}

	@RequestMapping(value = { "/reporting" })
	public ModelAndView tabtwo() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "Reporting");
		mv.addObject("userClicktab2", true);

		return mv;
	}

	@RequestMapping(value = { "/pdfcontent" })
	public ModelAndView tabthree() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "Pdfcontent");
		mv.addObject("userClickpdf", true);
		return mv;
	}

	@RequestMapping(value = { "/charDetect" })
	public ModelAndView tabfour() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "charDetect");
		mv.addObject("userClicktab4", true);
		return mv;
	}

	
	public static String projInput2;
	@RequestMapping(value = { "/runBatch" }, method = RequestMethod.POST)
	public ModelAndView actionRun(@RequestParam("projName") String projName, 
																	  @RequestParam("projInput") String projInput, 
																	  @RequestParam("dbInput") String dbInput,
																	  @RequestParam("userid") String userid, 
																	  @RequestParam("password") String password,
																	  @RequestParam("startDate_picker") String startDate_picker,
																	  @RequestParam("endDate_picker") String endDate_picker, Map<String, Object> map)
																	  throws FileNotFoundException, InterruptedException, ParseException {

		
		projInput2=projName;
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "runBatch");
		mv.addObject("button3", true);

		
		SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd-HH:mm");
		
		Date date = new SimpleDateFormat("MM/dd/yyyy HH:mm").parse(startDate_picker);
		Date date1 = new SimpleDateFormat("MM/dd/yyyy HH:mm").parse(endDate_picker);
	
		String targetStart = outputFormat.format(date);
		String endStart = outputFormat.format(date1);
		
		// Call method to create batch file

		CreateBatch obj = new CreateBatch();
		obj.createScript(projName,projInput, dbInput, userid, password, targetStart, endStart);

		// Call method to run batch file

		PageController action = new PageController();
		action.runBatch();
	
			if (terminalOutput .equals("Completed sucessfully.") ){
			
			System.out.println("inside if completed statement");
			
			return mv;
			
		} else {
			System.out.println("Staticoutput " + terminalOutput);
			return failBatchHandle();
		}
		

	}

	@RequestMapping(value = { "/download" })
	public void downloadResource(HttpServletRequest request, HttpServletResponse response) throws IOException {

		//File file = new File("c:\\eclipse\\" + projInput2);
		File file = new File("c:\\Tomcat_OptymyzeInternal-Support\\" + projInput2);
		
		// String filePath = "C:\\Tomcat_OptymyzeInternal-Support\\";

		response.setContentType("text/html");
		response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + ".html" + "\"");
		
		PrintWriter out = response.getWriter();
		FileInputStream fileInputStream = new FileInputStream(file);
		try {
			int i;
			while ((i = fileInputStream.read()) != -1) {
				out.write(i);
			}
			fileInputStream.close();
			out.close();
		} catch (IOException ex) {
			ex.printStackTrace();
		}

		CreateBatch obj3 = new CreateBatch();
		obj3.fileTransfer();

	}
	
	@RequestMapping(value = { "/download2" })
	  public void downloadResource2(HttpServletRequest request, HttpServletResponse response) throws IOException {

		//File file = new File("c:\\perl\\tmpFiles\\Output_report.txt");
	    File file = new File("e:\\Detect_Character_Encoding\\Output_report.txt");
	    

	    response.setContentType("text/html");
	    response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName()  + "\"");
	    // "\""
	    PrintWriter out = response.getWriter();
	    FileInputStream fileInputStream = new FileInputStream(file);
	    try {
	      int i;
	      while ((i = fileInputStream.read()) != -1) {
	        out.write(i);
	      }
	      fileInputStream.close();
	      out.close();
	    } catch (IOException ex) {
	      ex.printStackTrace();
	    }

	  }
	
		

	public static String terminalOutput ="";

	public void  runBatch() {

		try {
			
			String[] command = {"cmd.exe","/c","C:\\Perl\\test.bat"};
			String result = "Completed succesfully";
			
			Runtime r = Runtime.getRuntime();
			Process p = r.exec(command);
			
			BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line;
			String cmdOut;

			while ((line = stdInput.readLine()) != null) {

				cmdOut = line;
				System.out.println(cmdOut);
				terminalOutput = cmdOut;
			}
			
			stdInput.close();

			p.waitFor();
			p.destroy();
			
			Process p4 = Runtime.getRuntime().exec("taskkill /f /im cmd.exe");
			System.out.println("Inside Killing CMD Concurrent session"); 
			p4.waitFor(); 
			p4.destroy();
			

			//Thread.sleep(10000);		
			
		} catch (Exception e) {
			System.out.println("Execution error");
		}
		System.out.println("after batch execution");
		System.gc();
		
		
		
		
	}

	public static String Filename;
	@RequestMapping(value = {"/uploadSuccess"}, method = RequestMethod.POST)
	public @ResponseBody ModelAndView uploadFileHandler( RedirectAttributes redirectAttributes,
																								   						@RequestParam("file") MultipartFile file, Map<String, Object> map) {
		
		String name = file.getOriginalFilename();
		Filename=name;
		
		//System.out.println("Name of uploaded file is:"+Filename);
		
		//redirectAttributes.addAttribute("namekey", "name");
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "uploadSuccess");
		mv.addObject("userClickupload", true);
		
		FileUpload handler = new FileUpload();
		handler.uploadHandler(file);	

		return mv;
	}
	
	
	public ModelAndView scriptSuccess() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "runScript");
		mv.addObject("userClickrun", true);
		return mv;
	}
	
	public ModelAndView scriptFailed() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "failScript");
		mv.addObject("userClickfail", true);
		return mv;
	}
	
	
	
	@RequestMapping(value = {"/runScript"})
	public @ResponseBody ModelAndView actionScript() {
		
		//@RequestParam("name") 
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "uploadSuccess");
		mv.addObject("userClickupload", true);
		
		System.out.println("Name of uploaded file is:"+Filename);
		
		CreateBatch obj2=new CreateBatch();
		obj2.createBatch2(Filename);
		
		PageController callperl=new PageController();
		callperl.runScript2();
		
		System.out.println("Static output outside method: "+terminalOutput2); 
	
		if (terminalOutput2 .equals("No such file or directory") ){
			
			System.out.println("inside if failed statement");
			
			return scriptFailed();
			
		} else {
			
			System.out.println("inside if completed statement");
			System.out.println("Staticoutput else " + terminalOutput2);
			
			return scriptSuccess();
		}
	}
	
	
	@RequestMapping(value = {"/failBatch"})
	public ModelAndView failBatchHandle(){
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "failBatch");
		mv.addObject("failedCondition", true);
		
		return mv;
		
		
	}
	
	public static String terminalOutput2 ="";
	public void runScript2() {
		
		
		try {
		String  [] command = { "cmd.exe", "/C", "Start", "C:\\Perl\\CharDetect.bat"};
		Runtime r1 = Runtime.getRuntime();
        Process p1 = r1.exec(command);
        p1.waitFor(); 
        Thread.sleep(30000);
		p1.destroy();
    /*	
		try {
        ProcessBuilder pb = new ProcessBuilder(Arrays.asList(new String[] {"cmd.exe", "/C", "Start", "C:\\Perl\\CharDetect.bat"}));
    	pb.redirectErrorStream(true);
    	
    	Process proc = pb.start(); */
       
    	String outputFile = "e:\\Detect_Character_Encoding\\Output_report.txt";
		String line2;
		
        BufferedReader stdInput2 = new BufferedReader(new FileReader(outputFile));
		
        while ((line2 = stdInput2.readLine()) != null) {
		
			System.out.println("Loop File output"+line2);
			terminalOutput2 = line2;
			
		}
		
		System.out.println("Static output inside method: "+terminalOutput2); 
		
		stdInput2.close();
		
		Process p3 = Runtime.getRuntime().exec("taskkill /f /im cmd.exe");
		System.out.println("Inside Killing CMD"); 
		p3.waitFor(); 
		p3.destroy();
		
		File file = new File ("C:\\perl\\upload\\");
		System.out.println("Proceeding to delete uploaded file during processing"); 
		
		FileUtils.cleanDirectory(file); 
		
		
		
		
		}	catch (Exception e) {
		    e.printStackTrace();		    
		}
        
        
	
	
}
}
