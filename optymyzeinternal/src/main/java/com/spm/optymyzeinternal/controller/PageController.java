package com.spm.optymyzeinternal.controller;



import java.io.IOException;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

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
	public void actionRun () {
			
		//if (request.getParameter("button") !=null){
		RunBatch run= new RunBatch();
		try {
			run.runScript();
		} catch (RuntimeException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	  
	}	

	@RequestMapping(value= {"/createBatch"}, method= RequestMethod.GET)
	public void actionCreate () {
			
		//if (request.getParameter("button") !=null){
		RunBatch run= new RunBatch();
		try {
			run.createScript();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	  
	}	

	
	
}
