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
        if ("add".equals(action)) {
            String sql = "INSERT INTO Aircrafts (model, total_seats) VALUES (?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("model"));
            stmt.setInt(2, Integer.parseInt(request.getParameter("total_seats")));
            stmt.executeUpdate();
            message = "Aircraft added successfully!";
        } else if ("edit".equals(action)) {
            String sql = "UPDATE Aircrafts SET model = ?, total_seats = ? WHERE aircraft_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("model"));
            stmt.setInt(2, Integer.parseInt(request.getParameter("total_seats")));
            stmt.setInt(3, Integer.parseInt(request.getParameter("aircraft_id")));
            stmt.executeUpdate();
            message = "Aircraft updated!";
        } else if ("delete".equals(action)) {
            String sql = "DELETE FROM Aircrafts WHERE aircraft_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, Integer.parseInt(request.getParameter("aircraft_id")));
            stmt.executeUpdate();
            message = "Aircraft deleted.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<html>
<head><title>Manage Aircrafts</title></head>
<body>
<h2>Manage Aircrafts</h2>
<form action="repDashboard.jsp" method="get">
<button type="submit">Back to Dashboard</button>
</form>

<% if (!message.isEmpty()) { %><p><b><%= message %></b></p><% } %>

<h3>Add Aircraft</h3>
<form method="post">
    <input type="hidden" name="action" value="add">
    Model: <input type="text" name="model" required><br>
    Total Seats: <input type="number" name="total_seats" required><br>
    <input type="submit" value="Add Aircraft">
</form>

<h3>Edit Aircraft</h3>
<form method="post">
    <input type="hidden" name="action" value="edit">
    Aircraft ID: <input type="number" name="aircraft_id" required><br>
    Model: <input type="text" name="model" required><br>
    Total Seats: <input type="number" name="total_seats" required><br>
    <input type="submit" value="Update Aircraft">
</form>

<h3>Delete Aircraft</h3>
<form method="post">
    <input type="hidden" name="action" value="delete">
    Aircraft ID: <input type="number" name="aircraft_id" required><br>
    <input type="submit" value="Delete Aircraft">
</form>
</body>
</html>
