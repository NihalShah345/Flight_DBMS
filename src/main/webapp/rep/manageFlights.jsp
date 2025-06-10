<%@ page import="java.sql.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>

<%
    String userType = (String) session.getAttribute("user_type");
    if (userType == null || !"rep".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    String message = "";

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        String action = request.getParameter("action");
        if (action != null && (action.equals("add") || action.equals("edit"))) {
            // Process selected days
            String[] daysSelected = request.getParameterValues("days");
            String daysOfWeek = "";
            if (daysSelected != null) {
                daysOfWeek = String.join(",", daysSelected);
            }

            if ("add".equals(action)) {
                String sql = "INSERT INTO flights (flight_number, departure_airport, arrival_airport, departure_time, arrival_time, aircraft_id, days_of_week) VALUES (?, ?, ?, ?, ?, ?, ?)";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, request.getParameter("flightNumber"));
                stmt.setString(2, request.getParameter("departureAirport"));
                stmt.setString(3, request.getParameter("arrivalAirport"));
                stmt.setString(4, request.getParameter("departureTime"));
                stmt.setString(5, request.getParameter("arrivalTime"));
                stmt.setString(6, request.getParameter("aircraftId"));
                stmt.setString(7, daysOfWeek);
                stmt.executeUpdate();
                message = "Flight added successfully!";
            }

            if ("edit".equals(action)) {
                String sql = "UPDATE flights SET departure_airport = ?, arrival_airport = ?, departure_time = ?, arrival_time = ?, aircraft_id = ?, days_of_week = ? WHERE flight_id = ?";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, request.getParameter("departureAirport"));
                stmt.setString(2, request.getParameter("arrivalAirport"));
                stmt.setString(3, request.getParameter("departureTime"));
                stmt.setString(4, request.getParameter("arrivalTime"));
                stmt.setString(5, request.getParameter("aircraftId"));
                stmt.setString(6, daysOfWeek);
                stmt.setInt(7, Integer.parseInt(request.getParameter("flightId")));
                stmt.executeUpdate();
                message = "Flight updated successfully!";
            }
        }

        if ("delete".equals(action)) {
            String sql = "DELETE FROM flights WHERE flight_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(request.getParameter("flightId")));
            stmt.executeUpdate();
            message = "Flight deleted successfully!";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (stmt != null) try { stmt.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Flights</title>
</head>
<body>
    <h2>Manage Flights</h2>
    <form action="repDashboard.jsp" method="get">
<button type="submit">Back to Dashboard</button>
</form>
    

    <% if (!message.isEmpty()) { %>
        <p><b><%= message %></b></p>
    <% } %>

    <!-- Add Flight Form -->
    <form method="post">
        <input type="hidden" name="action" value="add" />
        <h3>Add Flight</h3>
        Flight Number: <input type="text" name="flightNumber" required/><br/>
        Departure Airport: <input type="text" name="departureAirport" required/><br/>
        Arrival Airport: <input type="text" name="arrivalAirport" required/><br/>
        Departure Time: <input type="datetime-local" name="departureTime" required/><br/>
        Arrival Time: <input type="datetime-local" name="arrivalTime" required/><br/>
        Aircraft ID: <input type="text" name="aircraftId" required/><br/>
        Days of Operation:<br/>
        <input type="checkbox" name="days" value="Mon">Mon
        <input type="checkbox" name="days" value="Tue">Tue
        <input type="checkbox" name="days" value="Wed">Wed
        <input type="checkbox" name="days" value="Thu">Thu
        <input type="checkbox" name="days" value="Fri">Fri
        <input type="checkbox" name="days" value="Sat">Sat
        <input type="checkbox" name="days" value="Sun">Sun
        <br/>
        <input type="submit" value="Add Flight"/>
    </form>

    <!-- Edit Flight Form -->
    <form method="post">
        <input type="hidden" name="action" value="edit" />
        <h3>Edit Flight</h3>
        Flight ID: <input type="text" name="flightId" required/><br/>
        Departure Airport: <input type="text" name="departureAirport" required/><br/>
        Arrival Airport: <input type="text" name="arrivalAirport" required/><br/>
        Departure Time: <input type="datetime-local" name="departureTime" required/><br/>
        Arrival Time: <input type="datetime-local" name="arrivalTime" required/><br/>
        Aircraft ID: <input type="text" name="aircraftId" required/><br/>
        Days of Operation:<br/>
        <input type="checkbox" name="days" value="Mon">Mon
        <input type="checkbox" name="days" value="Tue">Tue
        <input type="checkbox" name="days" value="Wed">Wed
        <input type="checkbox" name="days" value="Thu">Thu
        <input type="checkbox" name="days" value="Fri">Fri
        <input type="checkbox" name="days" value="Sat">Sat
        <input type="checkbox" name="days" value="Sun">Sun
        <br/>
        <input type="submit" value="Update Flight"/>
    </form>

    <!-- Delete Flight Form -->
    <form method="post">
        <input type="hidden" name="action" value="delete" />
        <h3>Delete Flight</h3>
        Flight ID: <input type="text" name="flightId" required/><br/>
        <input type="submit" value="Delete Flight"/>
    </form>
</body>
</html>
