<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<%
    String first = request.getParameter("first_name");
    String last = request.getParameter("last_name");

    ArrayList<HashMap<String, String>> past = new ArrayList<HashMap<String, String>>();
    ArrayList<HashMap<String, String>> upcoming = new ArrayList<HashMap<String, String>>();
    ArrayList<HashMap<String, String>> waitlist = new ArrayList<HashMap<String, String>>();

    if (first != null && last != null && !first.trim().isEmpty() && !last.trim().isEmpty()) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            // 1. Load reservations
            String sql = 
                "SELECT tf.flight_date, f.flight_number, f.departure_airport, f.arrival_airport, " +
                "f.departure_time, f.arrival_time, t.class, t.ticket_id " +
                "FROM Tickets t " +
                "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                "JOIN Flights f ON tf.flight_id = f.flight_id " +
                "WHERE t.passenger_first_name = ? AND t.passenger_last_name = ?";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, first);
            ps.setString(2, last);
            ResultSet rs = ps.executeQuery();

            java.util.Date today = new java.util.Date();

            while (rs.next()) {
                HashMap<String, String> row = new HashMap<String, String>();
                row.put("date", rs.getString("flight_date"));
                row.put("ticket", rs.getString("ticket_id"));
                row.put("flight", rs.getString("flight_number"));
                row.put("route", rs.getString("departure_airport") + " → " + rs.getString("arrival_airport"));
                row.put("time", rs.getString("departure_time") + " → " + rs.getString("arrival_time"));
                row.put("class", rs.getString("class"));

                java.util.Date flightDate = java.sql.Date.valueOf(rs.getString("flight_date"));
                if (flightDate.before(today)) {
                    past.add(row);
                } else {
                    upcoming.add(row);
                }
            }
            rs.close();
            ps.close();

            // 2. Load waitlist entries
            Integer userId = (Integer) session.getAttribute("user_id");
            if (userId != null) {
                String waitSql = 
                    "SELECT wl.flight_id, wl.flight_date, wl.request_time, wl.notified, f.flight_number, f.departure_airport, f.arrival_airport " +
                    "FROM WaitingList wl " +
                    "JOIN Flights f ON wl.flight_id = f.flight_id " +
                    "WHERE wl.user_id = ?";
                PreparedStatement psWait = conn.prepareStatement(waitSql);
                psWait.setInt(1, userId);
                ResultSet rsWait = psWait.executeQuery();

                while (rsWait.next()) {
                    HashMap<String, String> row = new HashMap<String, String>();
                    row.put("date", rsWait.getString("flight_date"));
                    row.put("flight", rsWait.getString("flight_number"));
                    row.put("flight_id", rsWait.getString("flight_id"));
                    row.put("route", rsWait.getString("departure_airport") + " → " + rsWait.getString("arrival_airport"));
                    row.put("requested", rsWait.getString("request_time"));
                    row.put("notified", rsWait.getBoolean("notified") ? "YES" : "NO");
                    waitlist.add(row);
                }
                rsWait.close();
                psWait.close();
            }

            conn.close();
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html>
<head><title>View Reservations</title></head>
<body>
<h2>Search for Flights</h2>
<form action="dashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<h3>Search Reservations</h3>
<form method="get">
    First Name: <input type="text" name="first_name" value="<%= first != null ? first : "" %>">
    Last Name: <input type="text" name="last_name" value="<%= last != null ? last : "" %>">
    <input type="submit" value="Search">
</form>

<% if (first != null && last != null) { %>

<h3>Upcoming Flights</h3>
<table border="1">
    <tr><th>Date</th><th>Flight</th><th>Route</th><th>Time</th><th>Class</th><th>Ticket ID</th><th>Action</th></tr>
<% for (int i = 0; i < upcoming.size(); i++) {
       HashMap<String, String> r = upcoming.get(i); %>
    <tr>
        <td><%= r.get("date") %></td>
        <td><%= r.get("flight") %></td>
        <td><%= r.get("route") %></td>
        <td><%= r.get("time") %></td>
        <td><%= r.get("class") %></td>
        <td><%= r.get("ticket") %></td>
        <td>
            <% if ("business".equalsIgnoreCase(r.get("class")) || "first".equalsIgnoreCase(r.get("class"))) { %>
                <form action="cancelReservation.jsp" method="post" onsubmit="return confirm('Are you sure you want to cancel this reservation?');">
                    <input type="hidden" name="ticket_id" value="<%= r.get("ticket") %>">
                    <input type="hidden" name="flight_date" value="<%= r.get("date") %>">
                    <input type="submit" value="Cancel">
                </form>
            <% } else { %>
                Not allowed
            <% } %>
        </td>
    </tr>
<% } %>
</table>

<h3>Past Flights</h3>
<table border="1">
    <tr><th>Date</th><th>Flight</th><th>Route</th><th>Time</th><th>Class</th><th>Ticket ID</th></tr>
<% for (int i = 0; i < past.size(); i++) {
       HashMap<String, String> r = past.get(i); %>
    <tr>
        <td><%= r.get("date") %></td>
        <td><%= r.get("flight") %></td>
        <td><%= r.get("route") %></td>
        <td><%= r.get("time") %></td>
        <td><%= r.get("class") %></td>
        <td><%= r.get("ticket") %></td>
    </tr>
<% } %>
</table>

<h3>Waiting List</h3>
<table border="1">
    <tr><th>Date</th><th>Flight</th><th>Route</th><th>Requested On</th><th>Status</th><th>Action</th></tr>
<% for (int i = 0; i < waitlist.size(); i++) {
       HashMap<String, String> r = waitlist.get(i); %>
    <tr>
        <td><%= r.get("date") %></td>
        <td><%= r.get("flight") %></td>
        <td><%= r.get("route") %></td>
        <td><%= r.get("requested") %></td>
        <td><%= r.get("notified") %></td>
        <td>
            <% if ("YES".equals(r.get("notified"))) { %>
                <form action="bookTicket.jsp" method="get">
                    <input type="hidden" name="flight_id" value="<%= r.get("flight_id") %>">
                    <input type="hidden" name="flight_date" value="<%= r.get("date") %>">
                    <input type="hidden" name="price" value="0.00">
                    <input type="hidden" name="mode" value="oneway">
                    <input type="submit" value="Book Now">
                </form>
            <% } else { %>
                Waiting
            <% } %>
        </td>
    </tr>
<% } %>
</table>

<% } %>
</body>
</html>
