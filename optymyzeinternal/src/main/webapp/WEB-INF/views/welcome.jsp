<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ taglib prefix="c"
uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html;
charset=ISO-8859-1">
 <title>HelloWorld page</title>
</head>
<body>
 Greeting : ${greeting}
 This is a welcome page. <a href="<c:url value="/logout"
/>">Logout</a>
 <br/><br/>
 Go to Admin page <a href="<c:url value="/admin"
/>">click here</a><br/><br/>
 Go to API page <a href="<c:url value="/api"
/>">click here</a>
 
</body>
</html>