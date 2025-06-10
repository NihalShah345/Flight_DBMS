<%@ page import="java.sql.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>Flights By Airport</title>
</head>
<body>

<h2>Find All Flights for an Airport</h2>

<form method="post">
    Enter Airport Code: <input type="text" name="airportCode" required />
    <input type="submit" value="Search Flights" />
</form>

<form action="repDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String airportCode = request.getParameter("airportCode").trim().toUpperCase();
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        try {
            String sql = "SELECT * FROM Flights WHERE departure_airport = ? OR arrival_airport = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, airportCode);
            ps.setString(2, airportCode);
            ResultSet rs = ps.executeQuery();

            boolean hasResults = false;
            out.println("<h3>All Flights Involving Airport: " + airportCode + "</h3>");
            out.println("<table border='1'>");
            out.println("<tr><th>Flight No</th><th>Airline</th><th>Aircraft ID</th><th>From</th><th>To</th><th>Depart</th><th>Arrive</th><th>Days</th><th>Domestic</th><th>Price</th><th>Stops</th></tr>");

            while (rs.next()) {
                hasResults = true;
                out.println("<tr>");
                out.println("<td>" + rs.getString("flight_number") + "</td>");
                out.println("<td>" + rs.getString("airline_id") + "</td>");
                out.println("<td>" + rs.getInt("aircraft_id") + "</td>");
                out.println("<td>" + rs.getString("departure_airport") + "</td>");
                out.println("<td>" + rs.getString("arrival_airport") + "</td>");
                out.println("<td>" + rs.getString("departure_time") + "</td>");
                out.println("<td>" + rs.getString("arrival_time") + "</td>");
                out.println("<td>" + rs.getString("days_of_week") + "</td>");
                out.println("<td>" + (rs.getBoolean("domestic") ? "Yes" : "No") + "</td>");
                out.println("<td>$" + rs.getDouble("price") + "</td>");
                out.println("<td>" + rs.getInt("num_stops") + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");
            if (!hasResults) {
                out.println("<p>No flights found for airport code: <b>" + airportCode + "</b></p>");
            }

            rs.close();
            ps.close();
        } catch (SQLException e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        } finally {
            db.closeConnection(conn);
        }
    }
%>

</body>
</html>
