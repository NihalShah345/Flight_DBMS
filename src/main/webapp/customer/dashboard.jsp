<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"customer".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
</head>
<body>
    <h1>Welcome to Your Travel Portal!</h1>
    <ul>
        <li><a href="searchFlights.jsp">Search Flights</a></li>
        <li><a href="viewReservation.jsp">View Your Tickets</a></li>
        <li><a href="browseQuestions.jsp">Ask and Search Question</a></li>
        <li><a href="../logout.jsp">Logout</a></li>
    </ul>
</body>
<form action="../logout.jsp" method="post" style="margin-top: 20px;">
    <button type="submit">Logout</button>
</form>
</html>
