<%@ page import="java.sql.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>Most Active Flights</title>
</head>
<body>
<h2>Top 10 Most Active Flights (By Number of Reservations)</h2>

<form action="adminDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        String sql = "SELECT f.flight_number, f.departure_airport, f.arrival_airport, " +
                     "COUNT(tf.ticket_id) AS total_reservations " +
                     "FROM Flights f " +
                     "JOIN TicketFlights tf ON f.flight_id = tf.flight_id " +
                     "GROUP BY f.flight_id " +
                     "ORDER BY total_reservations DESC " +
                     "LIMIT 10";

        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
%>

<table border="1">
    <tr><th>Flight Number</th><th>From</th><th>To</th><th>Total Reservations</th></tr>
<% 
    while (rs.next()) { 
%>
    <tr>
        <td><%= rs.getString("flight_number") %></td>
        <td><%= rs.getString("departure_airport") %></td>
        <td><%= rs.getString("arrival_airport") %></td>
        <td><%= rs.getInt("total_reservations") %></td>
    </tr>
<% 
    } 
    rs.close();
    ps.close();
    conn.close();
%>
</table>

<%
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
