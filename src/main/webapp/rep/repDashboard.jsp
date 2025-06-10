<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"rep".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Representative Dashboard</title>
</head>
<body>
    <h1>Welcome, Customer Representative!</h1>
    <ul>
        <li><a href="manageFlights.jsp">Manage Flights</a></li>
        <li><a href="manageAircrafts.jsp">Manage Aircrafts</a></li>
        <li><a href="manageAirports.jsp">Manage Airports</a></li>
        <li><a href="manageReservations.jsp">Manage Reservations</a><li>
        <li><a href="viewWaitlist.jsp">View Waiting Lists</a></li>
        <li><a href="flightsbyAirport.jsp">Flights by Airport</a></li>
        <li><a href="answerQuestions.jsp">Answer Customer Questions</a></li>
        <li><a href="../logout.jsp">Logout</a></li>
    </ul>
</body>
</html>
