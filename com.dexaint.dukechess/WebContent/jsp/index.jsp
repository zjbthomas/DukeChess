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
	<table>
		<tr>
			<td><%=PageBuilder.getBuilder().initPage(6, 6) %></td>
			<td><div class="back"></div></td>
		</tr>
	</table>
	
	<div id="msgbar"></div>
	
	<div class="menu"></div>
</body>
	
</html>