<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<html>
<head>
    <title>Reservation Lookup</title>
</head>
<body>
<h2>Reservation Lookup (by Flight Number or Full Customer Name)</h2>

<p><a href="adminDashboard.jsp">Back to Dashboard</a></p>

<!-- Search Form -->
<form method="post" action="reservationsLookup.jsp">
    <label>Search by Flight Number:</label>
    <input type="text" name="flight_number" />
    <br><br>
    <label>Or by Customer Name:</label>
    <br>
    First Name: <input type="text" name="first_name" />
    Last Name: <input type="text" name="last_name" />
    <br><br>
    <input type="submit" value="Search Reservations" />
</form>

<hr/>

<%
    String flightNum = request.getParameter("flight_number");
    String firstName = request.getParameter("first_name");
    String lastName = request.getParameter("last_name");

    boolean hasFlight = flightNum != null && !flightNum.trim().isEmpty();
    boolean hasNames = firstName != null && lastName != null &&
                       !firstName.trim().isEmpty() && !lastName.trim().isEmpty();

    if (hasFlight || hasNames) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();

            StringBuilder query = new StringBuilder(
                "SELECT t.ticket_id, u.first_name, u.last_name, f.flight_number, " +
                "tf.flight_date, t.class, t.purchase_time " +
                "FROM Tickets t " +
                "JOIN Users u ON t.user_id = u.user_id " +
                "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                "JOIN Flights f ON tf.flight_id = f.flight_id "
            );

            if (hasFlight) {
                query.append("WHERE f.flight_number = ?");
                ps = conn.prepareStatement(query.toString());
                ps.setString(1, flightNum.trim());

            } else if (hasNames) {
                query.append("WHERE u.first_name LIKE ? AND u.last_name LIKE ?");
                ps = conn.prepareStatement(query.toString());
                ps.setString(1, "%" + firstName.trim() + "%");
                ps.setString(2, "%" + lastName.trim() + "%");
            }

            rs = ps.executeQuery();

            out.println("<table border='1'>");
            out.println("<tr><th>Ticket ID</th><th>Customer Name</th><th>Flight Number</th>" +
                        "<th>Flight Date</th><th>Class</th><th>Purchase Time</th></tr>");

            boolean found = false;
            while (rs.next()) {
                found = true;
                out.println("<tr>");
                out.println("<td>" + rs.getInt("ticket_id") + "</td>");
                out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                out.println("<td>" + rs.getString("flight_number") + "</td>");
                out.println("<td>" + rs.getDate("flight_date") + "</td>");
                out.println("<td>" + rs.getString("class") + "</td>");
                out.println("<td>" + rs.getTimestamp("purchase_time") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");

            if (!found) {
                out.println("<p>No reservations found matching your search.</p>");
            }

        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
%>
</body>
</html>
