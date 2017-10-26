<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<spring:url var="css" value="/resources/css"/>
<spring:url var="js" value="/resources/js"/>
<spring:url var="images" value="/resources/images"/>

<c:set var="contextRoot" value="${pageContext.request.contextPath}"/>  


<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-quiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Optymyze Internal</title>

    <!-- Bootstrap core CSS -->
    <link href="${css}/bootstrap.css" rel="stylesheet">

    <!-- Add custom CSS here -->
    <link href="${css}/myapp.css" rel="stylesheet">

</head>

<body>

<!-- Navigation Bar -->

	<%@include file ="./shared/navbar.jsp"%>
	
	
	<!-- Page Content -->
	<!-- Loading the home content -->
	<%@include file="home.jsp" %>


	<!-- Footer comes here -->
	
	<%@include file ="./shared/footer.jsp"%>
  
    <!-- /.container -->

    <!-- JavaScript -->
    <script src="${js}/jquery-1.10.2.js"></script>
    <script src="${js}/bootstrap.js"></script>

</body>

</html>
