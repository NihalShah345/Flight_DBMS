<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<%
    String ticketIdStr = request.getParameter("ticket_id");
    String flightDateStr = request.getParameter("flight_date");
    String message = "";

    if (ticketIdStr != null && flightDateStr != null) {
        try {
            int ticketId = Integer.parseInt(ticketIdStr);
            java.sql.Date flightDate = java.sql.Date.valueOf(flightDateStr);

            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            // Check if class is business or first
            String checkClassSql = "SELECT class FROM Tickets WHERE ticket_id = ?";
            PreparedStatement ps = conn.prepareStatement(checkClassSql);
            ps.setInt(1, ticketId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String ticketClass = rs.getString("class");
                if ("business".equalsIgnoreCase(ticketClass) || "first".equalsIgnoreCase(ticketClass)) {

                    // Step 1: Get flight_id before deletion
                    String getFlightIdSql = "SELECT flight_id FROM TicketFlights WHERE ticket_id = ? AND flight_date = ?";
                    PreparedStatement psFlight = conn.prepareStatement(getFlightIdSql);
                    psFlight.setInt(1, ticketId);
                    psFlight.setDate(2, flightDate);
                    ResultSet rsFlight = psFlight.executeQuery();

                    int flightId = -1;
                    if (rsFlight.next()) {
                        flightId = rsFlight.getInt("flight_id");
                    }
                    rsFlight.close();
                    psFlight.close();

                    String deleteFlightSql = "DELETE FROM TicketFlights WHERE ticket_id = ? AND flight_date = ?";
                    ps = conn.prepareStatement(deleteFlightSql);
                    ps.setInt(1, ticketId);
                    ps.setDate(2, flightDate);
                    ps.executeUpdate();

                    String countSql = "SELECT COUNT(*) FROM TicketFlights WHERE ticket_id = ?";
                    ps = conn.prepareStatement(countSql);
                    ps.setInt(1, ticketId);
                    rs = ps.executeQuery();
                    if (rs.next() && rs.getInt(1) == 0) {
                        String deleteTicketSql = "DELETE FROM Tickets WHERE ticket_id = ?";
                        ps = conn.prepareStatement(deleteTicketSql);
                        ps.setInt(1, ticketId);
                        ps.executeUpdate();
                    }
                    rs.close();

                    message = "Reservation cancelled successfully.";

                    if (flightId != -1) {
                        String capSql = "SELECT a.total_seats FROM Flights f JOIN Aircrafts a ON f.aircraft_id = a.aircraft_id WHERE f.flight_id = ?";
                        ps = conn.prepareStatement(capSql);
                        ps.setInt(1, flightId);
                        rs = ps.executeQuery();

                        int capacity = 0;
                        if (rs.next()) {
                            capacity = rs.getInt("total_seats");
                        }
                        rs.close();
                        ps.close();

                        String bookedSql = "SELECT COUNT(*) FROM TicketFlights WHERE flight_id = ? AND flight_date = ?";
                        ps = conn.prepareStatement(bookedSql);
                        ps.setInt(1, flightId);
                        ps.setDate(2, flightDate);
                        rs = ps.executeQuery();

                        int booked = 0;
                        if (rs.next()) {
                            booked = rs.getInt(1);
                        }
                        rs.close();
                        ps.close();

                        if (booked < capacity) {
                            String notifySql = "UPDATE WaitingList SET notified = TRUE WHERE flight_id = ? AND flight_date = ? AND notified = FALSE ORDER BY request_time ASC LIMIT 1";
                            ps = conn.prepareStatement(notifySql);
                            ps.setInt(1, flightId);
                            ps.setDate(2, flightDate);
                            ps.executeUpdate();
                            ps.close();
                        }
                    }
                } else {
                    message = "Only Business or First class reservations can be cancelled.";
                }
            } else {
                message = "Ticket not found.";
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            message = "Error occurred: " + e.getMessage();
        }
    } else {
        message = "Missing ticket ID or flight date.";
    }
%>

<!DOCTYPE html>
<html>
<head><title>Cancel Reservation</title></head>
<body>
<h2><%= message %></h2>
<form action="viewReservation.jsp">
    <input type="submit" value="Back to Reservations">
</form>
</body>
</html>
