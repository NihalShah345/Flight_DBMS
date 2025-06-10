<%@ page import="java.sql.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>Most Active Customers</title>
</head>
<body>
<h2>Top 10 Most Active Customers (By Number of Reservations)</h2>

<form action="adminDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        String sql = "SELECT u.user_id, u.first_name, u.last_name, u.email, " +
                     "COUNT(t.ticket_id) AS total_tickets " +
                     "FROM Users u " +
                     "JOIN Tickets t ON u.user_id = t.user_id " +
                     "WHERE u.user_type = 'customer' " +
                     "GROUP BY u.user_id " +
                     "ORDER BY total_tickets DESC " +
                     "LIMIT 10";

        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
%>

<table border="1">
    <tr><th>User ID</th><th>Name</th><th>Email</th><th>Total Tickets</th></tr>
<% 
    while (rs.next()) { 
%>
    <tr>
        <td><%= rs.getInt("user_id") %></td>
        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getInt("total_tickets") %></td>
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
