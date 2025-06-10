<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>

<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"rep".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String flightNumber = request.getParameter("flight_number");
    String flightDate = request.getParameter("flight_date");

    List<Map<String, String>> waitlistResults = new ArrayList<Map<String, String>>();
    String error = null;

    if (flightNumber != null && flightDate != null) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String getFlightIdSql = "SELECT flight_id FROM Flights WHERE flight_number = ?";
            PreparedStatement ps1 = conn.prepareStatement(getFlightIdSql);
            ps1.setString(1, flightNumber);
            ResultSet rs1 = ps1.executeQuery();

            int flightId = -1;
            if (rs1.next()) {
                flightId = rs1.getInt("flight_id");
            }
            rs1.close();
            ps1.close();

            if (flightId != -1) {
                String waitSql = "SELECT wl.user_id, u.first_name, u.last_name, wl.flight_date, wl.request_time, wl.notified " +
                                 "FROM WaitingList wl JOIN Users u ON wl.user_id = u.user_id " +
                                 "WHERE wl.flight_id = ? AND wl.flight_date = ?";
                PreparedStatement ps2 = conn.prepareStatement(waitSql);
                ps2.setInt(1, flightId);
                ps2.setString(2, flightDate);
                ResultSet rs2 = ps2.executeQuery();

                while (rs2.next()) {
                    Map<String, String> row = new HashMap<String, String>();
                    row.put("user_id", rs2.getString("user_id"));
                    row.put("name", rs2.getString("first_name") + " " + rs2.getString("last_name"));
                    row.put("flight_date", rs2.getString("flight_date"));
                    row.put("request_time", rs2.getString("request_time"));
                    row.put("notified", rs2.getBoolean("notified") ? "Yes" : "No");
                    waitlistResults.add(row);
                }

                rs2.close();
                ps2.close();
            } else {
                error = "Flight number not found.";
            }

            conn.close();
        } catch (Exception e) {
            error = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head><title>View Waitlist</title></head>
<body>
<h2>View Waitlist for Flight</h2>
<form action="repDashboard.jsp"><button type="submit">Back to Dashboard</button></form>

<form method="get">
    Flight Number: <input type="text" name="flight_number" required value="<%= flightNumber != null ? flightNumber : "" %>">
    Flight Date (YYYY-MM-DD): <input type="date" name="flight_date" required value="<%= flightDate != null ? flightDate : "" %>">
    <input type="submit" value="Search">
</form>

<% if (error != null) { %>
    <p style="color:red;"><%= error %></p>
<% } %>

<% if (!waitlistResults.isEmpty()) { %>
    <h3>Waitlisted Users</h3>
    <table border="1">
        <tr><th>User ID</th><th>Name</th><th>Date</th><th>Requested On</th><th>Notified</th></tr>
    <% for (int i = 0; i < waitlistResults.size(); i++) {
           Map<String, String> r = waitlistResults.get(i); %>
        <tr>
            <td><%= r.get("user_id") %></td>
            <td><%= r.get("name") %></td>
            <td><%= r.get("flight_date") %></td>
            <td><%= r.get("request_time") %></td>
            <td><%= r.get("notified") %></td>
        </tr>
    <% } %>
    </table>
<% } else if (flightNumber != null && flightDate != null && error == null) { %>
    <p>No users are currently on the waitlist for this flight.</p>
<% } %>
</body>
</html>
