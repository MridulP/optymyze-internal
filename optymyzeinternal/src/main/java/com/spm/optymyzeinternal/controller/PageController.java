package com.spm.optymyzeinternal.controller;



import java.io.IOException;
import java.util.Map;

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
	
	@RequestMapping(value= {"/tab1"})
	public ModelAndView tabone() {
		
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","Tab1");
		mv.addObject("userClicktab1",true);
		return mv;
	}
	
	@RequestMapping(value= {"/tab2"})
	public ModelAndView tabtwo() {
		
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
	
	@RequestMapping(value= {"/runBatch"}, method= RequestMethod.GET)
	public  ModelAndView actionRun (@RequestParam("projInput") String projInput,
																		@RequestParam("dbInput") String dbInput,
																		@RequestParam("userid") String userid,
																		@RequestParam("password") String password,
																		@RequestParam("startDate") String startDate,
																		@RequestParam("endDate") String endDate,
																		Map<String,Object> map) {
		ModelAndView mv = new ModelAndView("page");
		mv.addObject("title","runBatch");
		mv.addObject("button3",true);
		
	// Call method to create batch file
		CreateBatch run= new CreateBatch();
		try {
			run.createScript(projInput,dbInput,userid,password,startDate,endDate);
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
		return mv;	
	}	
/*
	@RequestMapping(value= {"/createBatch"}, method= RequestMethod.GET)
	public void actionCreate () {
			
		//if (request.getParameter("button") !=null){
		CreateBatch run= new CreateBatch();
		try {
			run.createScript();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	  
	}	
*/
	
	
}
