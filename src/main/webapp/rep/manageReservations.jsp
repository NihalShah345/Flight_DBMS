<%@ page import="java.sql.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>Manage Flight Reservations</title>
</head>
<body>

<h2>Make or Edit a Flight Reservation</h2>

<h3>Make a Reservation</h3>
<form action="repDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<form method="post">
    User First Name: <input type="text" name="user_first_name" required><br>
    User Last Name:<input type="text" name="user_last_name" required><br>
    Flight Number: <input type="text" name="flight_number" required><br>
    Flight Date (YYYY-MM-DD): <input type="text" name="flight_date" required><br>
    Class:
    <select name="flight_class">
        <option value="economy">Economy</option>
        <option value="business">Business</option>
        <option value="first">First</option>
    </select><br>
    <input type="submit" name="make" value="Reserve Flight">
</form>

<h3>Edit an Existing Reservation</h3>
<form method="post">
    Ticket ID: <input type="text" name="ticket_id" required><br>
    New Flight Class:
    <select name="new_class">
        <option value="economy">Economy</option>
        <option value="business">Business</option>
        <option value="first">First</option>
    </select><br>
    <input type="submit" name="edit" value="Update Ticket">
</form>

<%
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    if (request.getParameter("make") != null) {
        String first_name = request.getParameter("user_first_name");
        String last_name = request.getParameter("user_last_name");
        String flightNumber = request.getParameter("flight_number");
        String flightClass = request.getParameter("flight_class");
        String flightDate = request.getParameter("flight_date");

        try {
            String userSQL = "SELECT user_id FROM Users WHERE users.first_name = ? AND users.last_name =? AND user_type = 'customer'";
            PreparedStatement userStmt = conn.prepareStatement(userSQL);
            userStmt.setString(1, first_name);
            userStmt.setString(2, last_name);
            ResultSet userRs = userStmt.executeQuery();

            if (userRs.next()) {
                int userId = userRs.getInt("user_id");

                String flightSQL = "SELECT flight_id, price FROM Flights WHERE flight_number = ?";
                PreparedStatement flightStmt = conn.prepareStatement(flightSQL);
                flightStmt.setString(1, flightNumber);
                ResultSet flightRs = flightStmt.executeQuery();

                if (flightRs.next()) {
                    int flightId = flightRs.getInt("flight_id");
                    double fare = flightRs.getDouble("price");
                    double bookingFee = 20.00;

                    String ticketSQL = "INSERT INTO Tickets (user_id, total_fare, booking_fee, class) VALUES (?, ?, ?, ?)";
                    PreparedStatement ticketStmt = conn.prepareStatement(ticketSQL, Statement.RETURN_GENERATED_KEYS);
                    ticketStmt.setInt(1, userId);
                    ticketStmt.setDouble(2, fare + bookingFee);
                    ticketStmt.setDouble(3, bookingFee);
                    ticketStmt.setString(4, flightClass);
                    ticketStmt.executeUpdate();

                    ResultSet ticketKeys = ticketStmt.getGeneratedKeys();
                    int ticketId = -1;
                    if (ticketKeys.next()) ticketId = ticketKeys.getInt(1);
                    ticketKeys.close();
                    ticketStmt.close();

                    // Add to TicketFlights
                    String tfSQL = "INSERT INTO TicketFlights (ticket_id, flight_id, seat_number, flight_date) VALUES (?, ?, ?, ?)";
                    PreparedStatement tfStmt = conn.prepareStatement(tfSQL);
                    tfStmt.setInt(1, ticketId);
                    tfStmt.setInt(2, flightId);
                    tfStmt.setString(3, "AUTO");
                    tfStmt.setString(4, flightDate);
                    tfStmt.executeUpdate();
                    tfStmt.close();

                    out.println("<p>Reservation made successfully! Ticket ID: " + ticketId + "</p>");
                } else {
                    out.println("<p>Flight not found.</p>");
                }
                flightRs.close();
                flightStmt.close();
            } else {
                out.println("<p>User not found or not a customer.</p>");
            }

            userRs.close();
            userStmt.close();
        } catch (SQLException e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        }
    }

    if (request.getParameter("edit") != null) {
        String ticketId = request.getParameter("ticket_id");
        String newClass = request.getParameter("new_class");
        try {
            String sql = "UPDATE Tickets SET class = ? WHERE ticket_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newClass);
            ps.setString(2, ticketId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                out.println("<p>Ticket updated successfully.</p>");
            } else {
                out.println("<p>No ticket found with that ID.</p>");
            }
            ps.close();
        } catch (SQLException e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        }
    }

    db.closeConnection(conn);
%>

</body>
</html>
