<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ taglib prefix="c"
uri="http://java.sun.com/jsp/jstl/core"%>
<%@page session="true"%>
<html>
<head>
<title>Login Page</title>
<style>
.error {
 padding: 15px;
 margin-bottom: 20px;
 border: 1px solid transparent;
 border-radius: 4px;
 color: #a94442;
 background-color: #f2dede;
 border-color: #ebccd1;
}

.msg {
 padding: 15px;
 margin-bottom: 20px;
 border: 1px solid transparent;
 border-radius: 4px;
 color: #31708f;
 background-color: #d9edf7;
 border-color: #bce8f1;
}

#login-box {
 width: 400px;
 padding: 50px;
 margin: 150px auto;
 background: #e6f2ff;
 -webkit-border-radius: 1px;
 -moz-border-radius: 1px;
 border: 1px solid #cce6ff;
}

.navbar-brand {
    display: none;
 }
 
.navbar-form {
    display: none;
 }

</style>
</head>
<body onload='document.loginForm.username.focus();'>



 <div class="container">

<div id="login-box">

 <!-- <h2>Login with Username and Password</h2>  -->

 <c:if test="${not empty error}">
 <div class="error">${error}</div>
 </c:if>
 <c:if test="${not empty msg}">
 <div class="msg">${msg}</div>
 </c:if>



 <form name='loginForm' class="form-signin" action="<c:url value='/login' />" method='POST'>
 
<h3 class="text-center">Welcome to Optymyze Support Automation</h3>
<br> 

<input type='text' name='username' class="form-control" placeholder="Username"></td>
<br> 
 
<input type='password' name='password' class="form-control" placeholder="Password"/></td>
<br> 

<input name="submit" type="submit" value="Log in" button class="btn btn-primary btn-block"/></td>
<br>

 <label class="pull-left checkbox-inline">
    <input type="checkbox">Remember my login</label> <br>
    
<label class="pull-left"><h5>Not a member? To request an account, please contact administrator.</h5></label>
<br>

</div>  
    
</div>

 

 <input type="hidden" name="${_csrf.parameterName}"
 value="${_csrf.token}" /> 

 </form>


<!-- Bootstrap core CSS -->


<script src="${js}/jquery.js"></script>
        <script src="${js}/bootstrap.js"></script>
        
    <script src="${js}/jquery.min.js"></script>
    <script src="${js}/bootstrap.min.js"></script>

</body>
</html>