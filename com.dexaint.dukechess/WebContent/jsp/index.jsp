<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page language="java" import="com.dexaint.dukechess.web.PageBuilder" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<script src="js/jquery-1.11.3.min.js"></script>
<script src="js/dukechess.js"></script>
<link rel="stylesheet" type="text/css" href="css/style.css"/>
<title>Index</title>
</head>

<body>
	<%=PageBuilder.getBuilder().initPage(6, 6) %>
	<div id="msgbar"></div>
	
	<div class="menu"></div>
</body>
	
</html>