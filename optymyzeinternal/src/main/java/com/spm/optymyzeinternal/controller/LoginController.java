package com.spm.optymyzeinternal.controller;

import java.util.Collection;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class LoginController {

	public class DemoController {
		 
		@RequestMapping("mathematician")
		public String geUserPage(ModelMap model) {
			// Get the user name if needed
			Authentication auth = SecurityContextHolder.getContext().getAuthentication();
			String username = auth.getName();
			
			// Get the roles if needed
			@SuppressWarnings("unchecked")
			Collection<SimpleGrantedAuthority> authorities = (Collection<SimpleGrantedAuthority>) auth.getAuthorities();
			
		    model.addAttribute("username", username);
			return "/mathematician";
		}
	 
		@RequestMapping("chemist")
		public String geAdminPage(ModelMap model) {
			// Get the user name if needed
			Authentication auth = SecurityContextHolder.getContext().getAuthentication();
			String username = auth.getName();
			
			// Get the roles if needed
			@SuppressWarnings("unchecked")
			Collection<SimpleGrantedAuthority> authorities = (Collection<SimpleGrantedAuthority>) auth.getAuthorities();
			
		    model.addAttribute("username", username);
			return "/chemist";
		}
	 
		@RequestMapping("403page")
		public String ge403denied() {
			return "redirect:login?denied";
		}
	}
	
}
