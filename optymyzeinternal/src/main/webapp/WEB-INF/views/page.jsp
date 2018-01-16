<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<spring:url var="css" value="/resources/css" />
<spring:url var="js" value="/resources/js" />
<spring:url var="images" value="/resources/images" />

<c:set var="contextRoot" value="${pageContext.request.contextPath}" />


<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="utf-8">
<meta http-quiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="">
<meta name="author" content="">

<title>Optymyze Internal - ${title}</title>

<script>
	window.menu = '${title}';
</script>

<!-- Bootstrap core CSS -->
<link href="${css}/bootstrap.css" rel="stylesheet">

<!-- Bootstrap Readable Theme -->
<link href="${css}/bootstrap-readable-theme.css" rel="stylesheet">

<!-- Custom CSS here -->
<link href="${css}/myapp.css" rel="stylesheet">
<link href="${css}/jquery-ui.css" rel="stylesheet">

</head>

<body>

	<div class="wrapper">

		<!-- Navigation Bar -->

		<%@include file="./shared/navbar.jsp"%>


		<!-- Page Content -->

		<div class="content">

			<!-- Loading the home content -->

			<c:if test="${userClickHome == true }">
				<%@include file="home.jsp"%>
			</c:if>
						

			<!-- Load only when user clicks about -->
			
			<c:if test="${userClicktab1 == true }">
				<%@include file="perlrun.jsp"%>
			</c:if>

			<c:if test="${userClicktab2 == true }">
				<%@include file="reporting.jsp"%>
			</c:if>

			<c:if test="${userClicktab3 == true }">
				<%@include file="notification.jsp"%>
			</c:if>
			
					<c:if test="${button3 == true }">
				<%@include file="runBatch.jsp"%>
			</c:if>
			
				<c:if test="${userClicktab4 == true }">
				<%@include file="charDetect.jsp"%>
			</c:if>
			
			<c:if test="${userClickupload == true }">
				<%@include file="uploadSuccess.jsp"%>
			</c:if>
			
			<c:if test="${failedCondition == true }">
				<%@include file="failBatch.jsp"%>
			</c:if>
			
			<c:if test="${userClickrun == true }">
				<%@include file="runScript.jsp"%>
			</c:if>
			
			<c:if test="${userClickfail == true }">
				<%@include file="failScript.jsp"%>
			</c:if>
			
		
		</div>

		<!-- Footer comes here -->

		<%@include file="./shared/footer.jsp"%>

		<!-- /.container -->

		<!-- JavaScript -->
		
		<script src="${js}/jquery.js"></script>
		<script src="${js}/bootstrap.js"></script>

		<!-- Self coded JavaScript -->
		<script src="${js}/myapp.js"></script>
	<script src="${js}/jquery-ui.js"></script>
	

	</div>

</body>

</html>
