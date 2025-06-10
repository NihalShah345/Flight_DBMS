<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>

<%
    String mode = request.getParameter("mode");
    boolean isRoundTrip = "roundtrip".equalsIgnoreCase(mode);

    String flightId = request.getParameter("flight_id");
    String flightDate = request.getParameter("flight_date");
    String priceStr = request.getParameter("price");

    String flightId1 = request.getParameter("flight_id1");
    String flightDate1 = request.getParameter("flight_date1");
    String priceStr1 = request.getParameter("price1");

    String flightId2 = request.getParameter("flight_id2");
    String flightDate2 = request.getParameter("flight_date2");
    String priceStr2 = request.getParameter("price2");

    int userId = (Integer) session.getAttribute("user_id");
    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("passenger_name") != null) {
        String passengerName = request.getParameter("passenger_name");
        String passengerId = request.getParameter("passenger_id");
        String ticketClass = request.getParameter("ticket_class");

        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();
            boolean flightFull = false;

            PreparedStatement capCheck;
            ResultSet rs;

            String capacitySQL = "SELECT a.total_seats, (SELECT COUNT(*) FROM TicketFlights tf WHERE tf.flight_id = f.flight_id AND tf.flight_date = ?) AS booked";
                capacitySQL += " FROM Flights f JOIN Aircrafts a ON f.aircraft_id = a.aircraft_id";
                capacitySQL += " WHERE f.flight_id = ?";

            if (isRoundTrip) {
                capCheck = conn.prepareStatement(capacitySQL);
                capCheck.setString(1, flightDate1);
                capCheck.setInt(2, Integer.parseInt(flightId1));
                rs = capCheck.executeQuery();
                if (rs.next() && rs.getInt("booked") >= rs.getInt("total_seats")) flightFull = true;
                rs.close();
                capCheck.close();

                capCheck = conn.prepareStatement(capacitySQL);
                capCheck.setString(1, flightDate2);
                capCheck.setInt(2, Integer.parseInt(flightId2));
                rs = capCheck.executeQuery();
                if (rs.next() && rs.getInt("booked") >= rs.getInt("total_seats")) flightFull = true;
                rs.close();
                capCheck.close();
            } else {
                capCheck = conn.prepareStatement(capacitySQL);
                capCheck.setString(1, flightDate);
                capCheck.setInt(2, Integer.parseInt(flightId));
                rs = capCheck.executeQuery();
                if (rs.next() && rs.getInt("booked") >= rs.getInt("total_seats")) flightFull = true;
                rs.close();
                capCheck.close();
            }

            if (flightFull) {
%>
<script>
    alert("Flight is full. You will be redirected to the waitlist page.");
    window.location.href = "waitlistPrompt.jsp?<%= 
        isRoundTrip ?
        "mode=roundtrip&flight_id1=" + flightId1 + "&flight_date1=" + flightDate1 +
        "&flight_id2=" + flightId2 + "&flight_date2=" + flightDate2 :
        "mode=oneway&flight_id=" + flightId + "&flight_date=" + flightDate 
    %>";
</script>
<%
                return;
            }

            // Proceed with booking
            BigDecimal totalFare;
            BigDecimal bookingFee = new BigDecimal("10.00");

            if (isRoundTrip) {
                BigDecimal price1 = new BigDecimal(priceStr1);
                BigDecimal price2 = new BigDecimal(priceStr2);
                totalFare = price1.add(price2).add(bookingFee);
            } else {
                BigDecimal price = new BigDecimal(priceStr);
                totalFare = price.add(bookingFee);
            }

            String[] names = passengerName.split(" ", 2);
            String first = names[0];
            String last = names.length > 1 ? names[1] : "";

            String insertTicket = "INSERT INTO Tickets (user_id, total_fare, booking_fee, class, passenger_first_name, passenger_last_name, passenger_id_number) VALUES (?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(insertTicket, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userId);
            ps.setBigDecimal(2, totalFare);
            ps.setBigDecimal(3, bookingFee);
            ps.setString(4, ticketClass);
            ps.setString(5, first);
            ps.setString(6, last);
            ps.setString(7, passengerId);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            int ticketId = -1;
            if (keys.next()) ticketId = keys.getInt(1);
            ps.close();

            String insertFlight = "INSERT INTO TicketFlights (ticket_id, flight_id, seat_number, flight_date) VALUES (?, ?, ?, ?)";
            PreparedStatement ps2 = conn.prepareStatement(insertFlight);

            if (isRoundTrip) {
                ps2.setInt(1, ticketId);
                ps2.setInt(2, Integer.parseInt(flightId1));
                ps2.setString(3, "AUTO");
                ps2.setString(4, flightDate1);
                ps2.executeUpdate();

                ps2.setInt(1, ticketId);
                ps2.setInt(2, Integer.parseInt(flightId2));
                ps2.setString(3, "AUTO");
                ps2.setString(4, flightDate2);
                ps2.executeUpdate();
            } else {
                ps2.setInt(1, ticketId);
                ps2.setInt(2, Integer.parseInt(flightId));
                ps2.setString(3, "AUTO");
                ps2.setString(4, flightDate);
                ps2.executeUpdate();
            }

            ps2.close();
            conn.close();

            message = "Booking successful! Your ticket ID is " + ticketId + ".";
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head><title>Book Ticket</title></head>
<body>
<h2>Book Your Ticket</h2>

<% if (message != null) { %>
    <p><strong><%= message %></strong></p>
    <form action="dashboard.jsp" method="get"><button type="submit">Back to Dashboard</button></form>
<% } else { %>
<form method="post" action="bookTicket.jsp">
    <input type="hidden" name="mode" value="<%= mode %>">
<% if (isRoundTrip) { %>
    <input type="hidden" name="flight_id1" value="<%= flightId1 %>">
    <input type="hidden" name="flight_date1" value="<%= flightDate1 %>">
    <input type="hidden" name="price1" value="<%= priceStr1 %>">
    <input type="hidden" name="flight_id2" value="<%= flightId2 %>">
    <input type="hidden" name="flight_date2" value="<%= flightDate2 %>">
    <input type="hidden" name="price2" value="<%= priceStr2 %>">
<% } else { %>
    <input type="hidden" name="flight_id" value="<%= flightId %>">
    <input type="hidden" name="flight_date" value="<%= flightDate %>">
    <input type="hidden" name="price" value="<%= priceStr %>">
<% } %>

    Passenger Name: <input type="text" name="passenger_name" required><br>
    ID Number: <input type="text" name="passenger_id" required><br>

    Ticket Class:
    <select name="ticket_class">
        <option value="economy">Economy</option>
        <option value="business">Business</option>
        <option value="first">First Class</option>
    </select><br><br>

    <input type="submit" value="Confirm Booking">
</form>
<% } %>
</body>
</html>
