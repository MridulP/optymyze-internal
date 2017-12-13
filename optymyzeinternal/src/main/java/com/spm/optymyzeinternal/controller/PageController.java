package com.spm.optymyzeinternal.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spm.optymyzeinternal.service.CreateBatch;
import com.spm.optymyzeinternal.service.RunBatch;

@Controller
public class PageController {
	
	

	@RequestMapping(value= {"/","/home","/index"})
	public ModelAndView index() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","home");
		mv.addObject("userClickHome",true);
		return mv;
	}
	
	@RequestMapping(value= {"/perlrun"})
	public ModelAndView tabone() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Perlrun");
		mv.addObject("userClicktab1",true);
		return mv;
	}
	
	@RequestMapping(value= {"/reporting"})
	public ModelAndView tabtwo(){
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Reporting");
		mv.addObject("userClicktab2",true);
		
		
		return mv; 
	}
	
	@RequestMapping(value= {"/notification"})
	public ModelAndView tabthree() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Notification");
		mv.addObject("userClicktab3",true);
		return mv;
	}
	
	@RequestMapping(value= {"/charDetect"})
	public ModelAndView tabfour() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","charDetect");
		mv.addObject("userClicktab4",true);
		return mv;
	}
	
	
	public static String projInput2;
	@RequestMapping(value= {"/runBatch"}, method= RequestMethod.POST)
	public  ModelAndView actionRun (@RequestParam("projInput") String projInput,
																		@RequestParam("dbInput") String dbInput,
																		@RequestParam("userid") String userid,
																		@RequestParam("password") String password,
																		@RequestParam("startDate_picker") String startDate_picker,
																		@RequestParam("endDate_picker") String endDate_picker,
																		Map<String,Object> map) throws FileNotFoundException, InterruptedException {
		
		projInput2 = projInput;
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","runBatch");
		mv.addObject("button3",true);
		
	//Call method to create batch file
		
		CreateBatch obj=new CreateBatch();
		obj.createScript(projInput, dbInput, userid, password, startDate_picker, endDate_picker);		
	
	// Call method to run batch file	
		RunBatch obj2=new RunBatch();
		
		obj2.runScript();	
		
		   
	
	// Move Batch File
	//	MoveBatch obj3=new MoveBatch();
	//	obj3.moveFile();			
		
		return mv;
		
	}	

	
	@RequestMapping(value= {"/download"})
	public void downloadResource (HttpServletRequest request, HttpServletResponse response) throws IOException {
		
		File file = new File("c:\\eclipse\\"+projInput2);
		//String filePath = "C:\\Tomcat_OptymyzeInternal-Support\\";
			
		String fileName = projInput2;
		
		response.setContentType("text/html");		
		response.setHeader("Content-Disposition", "attachment; filename=\""+file.getName()+ ".html"+"\""); 
		// "\""
		PrintWriter out = response.getWriter();
		FileInputStream fileInputStream = new FileInputStream(file);   
            try
            {
            	int i;
        		while ((i = fileInputStream.read()) != -1) {
        		out.write(i);
            }	fileInputStream.close();
    			out.close(); }
            catch (IOException ex) {
                ex.printStackTrace();
            }
  
            CreateBatch obj3=new CreateBatch();
            obj3.fileTransfer();
			
	}
	
 }
	

