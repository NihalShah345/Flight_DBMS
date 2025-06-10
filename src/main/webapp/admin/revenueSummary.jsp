<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"admin".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String flightNumber = request.getParameter("flight_number");
    String airlineId = request.getParameter("airline_id");
    String customer_first_name = request.getParameter("customer_first_name");
    String customer_last_name = request.getParameter("customer_last_name");

    ArrayList<HashMap<String, String>> results = new ArrayList<HashMap<String, String>>();
    String context = null;
    double totalFare = 0.0;

    try {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        if (flightNumber != null && !flightNumber.trim().isEmpty()) {
            context = "flight";
            String sql = "SELECT t.total_fare, tf.flight_date, f.departure_airport, f.arrival_airport, u.first_name, u.last_name " +
                         "FROM Tickets t " +
                         "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                         "JOIN Flights f ON tf.flight_id = f.flight_id " +
                         "JOIN Users u ON t.user_id = u.user_id " +
                         "WHERE f.flight_number = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, flightNumber);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> row = new HashMap<String, String>();
                row.put("fare", rs.getString("total_fare"));
                row.put("date", rs.getString("flight_date"));
                row.put("from", rs.getString("departure_airport"));
                row.put("to", rs.getString("arrival_airport"));
                row.put("customer", rs.getString("first_name") + " " + rs.getString("last_name"));
                results.add(row);
                totalFare += rs.getDouble("total_fare");
            }
            rs.close();
            ps.close();
        } else if (airlineId != null && !airlineId.trim().isEmpty()) {
            context = "airline";
            String sql = "SELECT t.total_fare, tf.flight_date, f.flight_number, f.departure_airport, f.arrival_airport, u.first_name, u.last_name " +
                         "FROM Tickets t " +
                         "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                         "JOIN Flights f ON tf.flight_id = f.flight_id " +
                         "JOIN Users u ON t.user_id = u.user_id " +
                         "WHERE f.airline_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, airlineId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> row = new HashMap<String, String>();
                row.put("fare", rs.getString("total_fare"));
                row.put("date", rs.getString("flight_date"));
                row.put("flight", rs.getString("flight_number"));
                row.put("from", rs.getString("departure_airport"));
                row.put("to", rs.getString("arrival_airport"));
                row.put("customer", rs.getString("first_name") + " " + rs.getString("last_name"));
                results.add(row);
                totalFare += rs.getDouble("total_fare");
            }
            rs.close();
            ps.close();
        } else if (customer_first_name != null && customer_last_name != null) {
            context = "customer";
            String sql = "SELECT t.total_fare, tf.flight_date, f.flight_number, f.departure_airport, f.arrival_airport " +
                         "FROM Tickets t " +
                         "JOIN TicketFlights tf ON t.ticket_id = tf.ticket_id " +
                         "JOIN Flights f ON tf.flight_id = f.flight_id " +
                         "JOIN Users u ON t.user_id = u.user_id " +
                         "WHERE u.first_name = ? AND u.last_name = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, customer_first_name);
            ps.setString(2, customer_last_name);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                HashMap<String, String> row = new HashMap<String, String>();
                row.put("fare", rs.getString("total_fare"));
                row.put("date", rs.getString("flight_date"));
                row.put("flight", rs.getString("flight_number"));
                row.put("from", rs.getString("departure_airport"));
                row.put("to", rs.getString("arrival_airport"));
                results.add(row);
                totalFare += rs.getDouble("total_fare");
            }
            rs.close();
            ps.close();
        }


        conn.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head><title>Revenue Summary</title></head>
<body>
<h2>Revenue Summary</h2>
<form action="adminDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<h3>Search By Flight</h3>
<form method="get">
    Flight Number: <input type="text" name="flight_number">
    <input type="submit" value="Search">
</form>

<h3>Search By Airline</h3>
<form method="get">
    Airline ID: <input type="text" name="airline_id">
    <input type="submit" value="Search">
</form>

<h3>Search By Customer</h3>
<form method="get">
    Customer First Name: <input type="text" name="customer_first_name" required>
    Customer Last Name: <input type="text" name="customer_last_name" required>
    <input type="submit" value="Search">
</form>


<% if (context != null && !results.isEmpty()) { %>
    <h3>Results</h3>
    <table border="1">
        <tr>
            <th>Date</th>
            <% if (!"flight".equals(context)) { %><th>Flight</th><% } %>
            <th>From</th><th>To</th>
            <% if (!"customer".equals(context)) { %><th>Customer</th><% } %>
            <th>Fare</th>
        </tr>
        <% for (HashMap<String, String> row : results) { %>
        <tr>
            <td><%= row.get("date") %></td>
            <% if (!"flight".equals(context)) { %><td><%= row.get("flight") %></td><% } %>
            <td><%= row.get("from") %></td>
            <td><%= row.get("to") %></td>
            <% if (!"customer".equals(context)) { %><td><%= row.get("customer") %></td><% } %>
            <td>$<%= row.get("fare") %></td>
        </tr>
        <% } %>
        <tr>
            <td colspan="<%= context.equals("customer") ? 4 : 5 %>" style="text-align:right;"><strong>Total Revenue:</strong></td>
            <td><strong>$<%= String.format("%.2f", totalFare) %></strong></td>
        </tr>
    </table>
<% } else if (context != null) { %>
    <p>No matching results found.</p>
<% } %>
</body>
</html>
