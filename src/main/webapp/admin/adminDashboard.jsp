<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"admin".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
</head>
<body>
    <h1>Welcome, Admin!</h1>
    <ul>
        <li><a href="manageUsers.jsp">Manage Users</a></li>
        <li><a href="salesReport.jsp">View Sales Reports</a></li>
        <li><a href="reservationsLookup.jsp">View Customer Reservations</a>
        <li><a href="mostActiveFlights.jsp">View Most Active Flights</a>
        <li><a href="mostActiveCustomers.jsp">View Most Active Customers</a>
        <li><a href="revenueSummary.jsp">View Revenue Summary By Each Entity</a>
        <li><a href="../logout.jsp">Logout</a></li>
    </ul>
</body>
</html>
