package com.spm.optymyzeinternal.controller;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Map;
import java.util.logging.FileHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

	@RequestMapping(value = { "/notification" })
	public ModelAndView tabthree() {

		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "Notification");
		mv.addObject("userClicktab3", true);
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
	public ModelAndView actionRun(@RequestParam("projInput") String projInput, 
																	  @RequestParam("dbInput") String dbInput,
																	  @RequestParam("userid") String userid, 
																	  @RequestParam("password") String password,
																	  @RequestParam("startDate_picker") String startDate_picker,
																	  @RequestParam("endDate_picker") String endDate_picker, Map<String, Object> map)
																	  throws FileNotFoundException, InterruptedException {

		
		projInput2=projInput;
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "runBatch");
		mv.addObject("button3", true);

		// Call method to create batch file

		CreateBatch obj = new CreateBatch();
		obj.createScript(projInput, dbInput, userid, password, startDate_picker, endDate_picker);

		// Call method to run batch file

		 //RunBatch obj2=new RunBatch();
		// obj2.runScript();

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

		File file = new File("c:\\eclipse\\" + projInput2);
		// String filePath = "C:\\Tomcat_OptymyzeInternal-Support\\";

		response.setContentType("text/html");
		response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getName() + ".html" + "\"");
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

		CreateBatch obj3 = new CreateBatch();
		obj3.fileTransfer();

	}

	public static String terminalOutput ="";

	public void  runBatch() {

		try {
			// String [] command = { "cmd.exe", "/C", "Start",
			// "C:\\Perl\\test.bat" };
			String[] command = {"cmd.exe","/c","C:\\Perl\\test.bat"};
			String result = "Completed succesfully";
		//	String terminalOutput = new String ();
			
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

			//Thread.sleep(10000);		
			
		} catch (Exception e) {
			System.out.println("Execution error");
		}
		System.out.println("after batch execution");
		System.gc();
		
		
		/*
		if (terminalOutput.equals("Completed sucessfully")){
			
			System.out.println("inside if completed statement");
			
			return "redirect:runBatch";
			
		} else {
			
			System.out.println("inside if failed statement");
			return "redirect:failBatch";
		} */
		
		
	}

	public static String Filename;
	@RequestMapping(value = {"/uploadSuccess"}, method = RequestMethod.POST)
	public @ResponseBody ModelAndView uploadFileHandler( RedirectAttributes redirectAttributes,
																								   @RequestParam("name") String name,
																								   @RequestParam("file") MultipartFile file, Map<String, Object> map) {
		Filename=name;

		System.out.println("Name of uploaded file is:"+Filename);
		
		//redirectAttributes.addAttribute("namekey", "name");
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "uploadSuccess");
		mv.addObject("userClickupload", true);
		
		FileUpload handler = new FileUpload();
		handler.uploadHandler(name,file);	

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
		
		RunBatch callperl=new RunBatch();
		callperl.runScript2();

		return mv;
		
	}
	
	
	@RequestMapping(value = {"/failBatch"})
	public ModelAndView failBatchHandle(){
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title", "failBatch");
		mv.addObject("failedCondition", true);
		
		return mv;
		
		
	}
	
	
	
}
