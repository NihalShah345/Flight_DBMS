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
            String sql = "INSERT INTO Airports (airport_id, airport_name, city, country) VALUES (?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("airport_id"));
            stmt.setString(2, request.getParameter("name"));
            stmt.setString(3, request.getParameter("city"));
            stmt.setString(4, request.getParameter("country"));
            stmt.executeUpdate();
            message = "Airport added!";
        } else if ("edit".equals(action)) {
            String sql = "UPDATE Airports SET airport_name = ?, city = ?, country = ? WHERE airport_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("name"));
            stmt.setString(2, request.getParameter("city"));
            stmt.setString(3, request.getParameter("country"));
            stmt.setString(4, request.getParameter("airport_id"));
            stmt.executeUpdate();
            message = "Airport updated!";
        } else if ("delete".equals(action)) {
            String sql = "DELETE FROM Airports WHERE airport_id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, request.getParameter("airport_id"));
            stmt.executeUpdate();
            message = "Airport deleted!";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<html>
<head><title>Manage Airports</title></head>
<body>
<h2>Manage Airports</h2>
<form action="repDashboard.jsp" method="get">
<button type="submit">Back to Dashboard</button>
</form>

<% if (!message.isEmpty()) { %><p><b><%= message %></b></p><% } %>

<h3>Add Airport</h3>
<form method="post">
    <input type="hidden" name="action" value="add">
    Airport Code (3 letters): <input type="text" name="airport_id" maxlength="3" required><br>
    Name: <input type="text" name="name" required><br>
    City: <input type="text" name="city" required><br>
    Country: <input type="text" name="country" required><br>
    <input type="submit" value="Add Airport">
</form>

<h3>Edit Airport</h3>
<form method="post">
    <input type="hidden" name="action" value="edit">
    Airport Code: <input type="text" name="airport_id" maxlength="3" required><br>
    New Name: <input type="text" name="name"><br>
    City: <input type="text" name="city"><br>
    Country: <input type="text" name="country"><br>
    <input type="submit" value="Update Airport">
</form>

<h3>Delete Airport</h3>
<form method="post">
    <input type="hidden" name="action" value="delete">
    Airport Code: <input type="text" name="airport_id" maxlength="3" required><br>
    <input type="submit" value="Delete Airport">
</form>
</body>
</html>
