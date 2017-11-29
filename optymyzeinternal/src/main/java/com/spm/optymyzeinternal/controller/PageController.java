package com.spm.optymyzeinternal.controller;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spm.optymyzeinternal.service.CallBatch;
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
	
	@RequestMapping(value= {"/tab1"})
	public ModelAndView tabone() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Tab1");
		mv.addObject("userClicktab1",true);
		return mv;
	}
	
	@RequestMapping(value= {"/tab2"})
	public ModelAndView tabtwo(){
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Tab2");
		mv.addObject("userClicktab2",true);
		
		
		return mv; 
	}
	
	@RequestMapping(value= {"/tab3"})
	public ModelAndView tabthree() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Tab3");
		mv.addObject("userClicktab3",true);
		return mv;
	}
	
	
	@RequestMapping(value= {"/createBatch"}, method= RequestMethod.POST)
	public  void actionRun (@RequestParam("projInput") String projInput,
																		@RequestParam("dbInput") String dbInput,
																		@RequestParam("userid") String userid,
																		@RequestParam("password") String password,
																		@RequestParam("startDate_picker") String startDate_picker,
																		@RequestParam("endDate_picker") String endDate_picker,
																		Map<String,Object> map) {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","runBatch");
		mv.addObject("button3",true);
		
	//Call method to create batch file
		CreateBatch run= new CreateBatch();
		try {
			run.createScript(projInput,dbInput,userid,password,startDate_picker,endDate_picker);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	
	// Call method to run batch file	
		RunBatch run2= new RunBatch();
		try {
			run2.runScript();
		} catch (RuntimeException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		
			
		} 
		 
	}	

	@RequestMapping(value= {"/runBatch"}, method= RequestMethod.POST)
	public void actionCreate () {
		
		ModelAndView mv = new ModelAndView("page");
				mv.addObject("title","runBatch");
				mv.addObject("button7",true);
		
		RunBatch r2= new RunBatch();
		try {
			r2.runScript();
		} catch (RuntimeException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		
			
		} 
		
	}	

		
		
	}
	

