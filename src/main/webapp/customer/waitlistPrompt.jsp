<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    String mode = request.getParameter("mode");
    String flightId = request.getParameter("flight_id");
    String flightDate = request.getParameter("flight_date");

    String flightId1 = request.getParameter("flight_id1");
    String flightDate1 = request.getParameter("flight_date1");
    String flightId2 = request.getParameter("flight_id2");
    String flightDate2 = request.getParameter("flight_date2");

    int userId = (Integer) session.getAttribute("user_id");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Flight Full - Waitlist Option</title>
</head>
<body>
<h2>The flight you selected is currently full.</h2>
<p>You can choose to join the waiting list. If a seat becomes available, you will be notified.</p>

<form action="waitlist.jsp" method="post">
    <input type="hidden" name="mode" value="<%= mode %>">
    <input type="hidden" name="user_id" value="<%= userId %>">
<% if ("roundtrip".equalsIgnoreCase(mode)) { %>
    <input type="hidden" name="flight_id1" value="<%= flightId1 %>">
    <input type="hidden" name="flight_date1" value="<%= flightDate1 %>">
    <input type="hidden" name="flight_id2" value="<%= flightId2 %>">
    <input type="hidden" name="flight_date2" value="<%= flightDate2 %>">
<% } else { %>
    <input type="hidden" name="flight_id" value="<%= flightId %>">
    <input type="hidden" name="flight_date" value="<%= flightDate %>">
<% } %>
    <input type="submit" value="Join Waitlist">
</form>

<form action="dashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>
</body>
</html>
