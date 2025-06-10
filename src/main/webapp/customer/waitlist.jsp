<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>

<%
    String mode = request.getParameter("mode");
    boolean isRoundTrip = "roundtrip".equalsIgnoreCase(mode);

    String flightId = request.getParameter("flight_id");
    String flightDate = request.getParameter("flight_date");

    String flightId1 = request.getParameter("flight_id1");
    String flightDate1 = request.getParameter("flight_date1");
    String flightId2 = request.getParameter("flight_id2");
    String flightDate2 = request.getParameter("flight_date2");

    int userId = (Integer) session.getAttribute("user_id");
    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String insert = "INSERT INTO WaitingList (user_id, flight_id, flight_date) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(insert);

            if (isRoundTrip) {
                ps.setInt(1, userId);
                ps.setInt(2, Integer.parseInt(flightId1));
                ps.setString(3, flightDate1);
                ps.executeUpdate();

                ps.setInt(1, userId);
                ps.setInt(2, Integer.parseInt(flightId2));
                ps.setString(3, flightDate2);
                ps.executeUpdate();
            } else {
                ps.setInt(1, userId);
                ps.setInt(2, Integer.parseInt(flightId));
                ps.setString(3, flightDate);
                ps.executeUpdate();
            }

            ps.close();
            conn.close();
            message = "You have been added to the waitlist. You'll be notified if a spot becomes available.";
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head><title>Join Waitlist</title></head>
<body>
<h2>Flight Full</h2>

<% if (message != null) { %>
    <p><strong><%= message %></strong></p>
    <form action="dashboard.jsp" method="get"><button type="submit">Back to Dashboard</button></form>
<% } else { %>
    <p>This flight is currently full. Would you like to join the waitlist?</p>
    <form method="post" action="waitlist.jsp">
        <input type="hidden" name="mode" value="<%= mode %>">
<% if (isRoundTrip) { %>
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
<% } %>
</body>
</html>
