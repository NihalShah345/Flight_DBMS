<!DOCTYPE html>
<html>
<head>
    <title>Login Form</title>
</head>
<body>
    <form action="checkLoginDetails.jsp" method="POST">
        Email: <input type="text" name="email" /><br/>
  		Password: <input type="password" name="password" /><br/>
  		<input type="submit" value="Login" />
	</form>
	<% if ("true".equals(request.getParameter("error"))) { %>
  <p style="color:red;">Invalid login. Please try again.</p>
<% } %>
</body>
</html>