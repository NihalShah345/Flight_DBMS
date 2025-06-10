<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<html>
<head>
    <title>Sales Report</title>
</head>
<body>
<h2>Month Sales Report</h2>
<p>Based on month of flight take-off date, not date of purchase</p>

<p><a href="adminDashboard.jsp">Back to Dashboard</a></p>

<form method="post" action="salesReport.jsp">
    <label for="month">Select a month (based on flight date):</label>
    <select name="month" required>
        <option value="">--Select--</option>
        <option value="01">January</option>
        <option value="02">February</option>
        <option value="03">March</option>
        <option value="04">April</option>
        <option value="05">May</option>
        <option value="06">June</option>
        <option value="07">July</option>
        <option value="08">August</option>
        <option value="09">September</option>
        <option value="10">October</option>
        <option value="11">November</option>
        <option value="12">December</option>
    </select>
    <input type="submit" value="Generate Report" />
</form>

<hr/>

<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String selectedMonth = request.getParameter("month");
    if (selectedMonth != null && !selectedMonth.isEmpty()) {
        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();

            int year = 2025; // Hardcoded year

            // Use flight_date for filtering instead of purchase_time
            String sql = "SELECT t.ticket_id, u.first_name, u.last_name, f.flight_number, tf.flight_date, " +
                         "t.purchase_time, t.total_fare, t.booking_fee " +
                         "FROM Tickets t " +
                         "JOIN Users u ON t.user_id = u.user_id " +
                         "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                         "JOIN Flights f ON tf.flight_id = f.flight_id " +
                         "WHERE MONTH(tf.flight_date) = ? AND YEAR(tf.flight_date) = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(selectedMonth));
            ps.setInt(2, year);
            rs = ps.executeQuery();

            out.println("<h3>Tickets for Flights in " + selectedMonth + "/2025</h3>");
            out.println("<table border='1'>");
            out.println("<tr><th>Ticket ID</th><th>Customer Name</th><th>Flight Number</th>" +
                        "<th>Flight Date</th><th>Purchase Time</th><th>Total Fare</th><th>Booking Fee</th></tr>");

            double totalBookingFees = 0.0;

            while (rs.next()) {
                double fare = rs.getDouble("total_fare");
                double fee = rs.getDouble("booking_fee");
                totalBookingFees += fee;

                out.println("<tr>");
                out.println("<td>" + rs.getInt("ticket_id") + "</td>");
                out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                out.println("<td>" + rs.getString("flight_number") + "</td>");
                out.println("<td>" + rs.getDate("flight_date") + "</td>");
                out.println("<td>" + rs.getTimestamp("purchase_time") + "</td>");
                out.println("<td>$" + String.format("%.2f", fare) + "</td>");
                out.println("<td>$" + String.format("%.2f", fee) + "</td>");
                out.println("</tr>");
            }

            out.println("<tr style='font-weight:bold; background:#f0f0f0;'>");
            out.println("<td colspan='6' style='text-align:right;'>Total Revenue from Booking Fees:</td>");
            out.println("<td>$" + String.format("%.2f", totalBookingFees) + "</td>");
            out.println("</tr>");
            out.println("</table>");

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
