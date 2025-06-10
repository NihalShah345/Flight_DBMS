<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<html>
<head>
    <title>Manage Users</title>
</head>
<body>
<h2>Admin - Manage Users (Admin)</h2>
<p><a href="adminDashboard.jsp">Back to Dashboard</a></p>

<!-- Add User Form -->
<form method="post" action="manageUsers.jsp">
    <h3>Add New User</h3>
    First Name: <input type="text" name="first_name" required />
    Last Name: <input type="text" name="last_name" required />
    Email: <input type="email" name="email" required />
    Password: <input type="password" name="password" required />
    User Type:
    <select name="user_type">
        <option value="admin">Admin</option>
        <option value="rep">Customer Rep</option>
        <option value="customer">Customer</option>
    </select>
    <input type="submit" name="action" value="Add User" />
</form>

<hr/>

<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // ADD USER
        if ("Add User".equals(request.getParameter("action"))) {
            String fn = request.getParameter("first_name");
            String ln = request.getParameter("last_name");
            String email = request.getParameter("email");
            String pass = request.getParameter("password");
            String role = request.getParameter("user_type");

            String insertSQL = "INSERT INTO users (first_name, last_name, email, password, user_type) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(insertSQL);
            ps.setString(1, fn);
            ps.setString(2, ln);
            ps.setString(3, email);
            ps.setString(4, pass);
            ps.setString(5, role);
            ps.executeUpdate();
            out.println("<p>User added successfully.</p>");
            ps.close();
        }

        // UPDATE USER
        if ("Update User".equals(request.getParameter("action"))) {
            int userId = Integer.parseInt(request.getParameter("user_id"));
            String fn = request.getParameter("first_name");
            String ln = request.getParameter("last_name");
            String email = request.getParameter("email");
            String role = request.getParameter("user_type");

            String updateSQL = "UPDATE users SET first_name=?, last_name=?, email=?, user_type=? WHERE user_id=?";
            ps = conn.prepareStatement(updateSQL);
            ps.setString(1, fn);
            ps.setString(2, ln);
            ps.setString(3, email);
            ps.setString(4, role);
            ps.setInt(5, userId);
            ps.executeUpdate();
            out.println("<p>User updated successfully.</p>");
            ps.close();
        }

        // DELETE USER
        if (request.getParameter("delete_id") != null) {
            String deleteSQL = "DELETE FROM users WHERE user_id=?";
            ps = conn.prepareStatement(deleteSQL);
            ps.setInt(1, Integer.parseInt(request.getParameter("delete_id")));
            ps.executeUpdate();
            out.println("<p>User deleted.</p>");
            ps.close();
        }

        // EDIT FORM DISPLAY
        if (request.getParameter("edit_id") != null) {
            int editId = Integer.parseInt(request.getParameter("edit_id"));
            String query = "SELECT * FROM users WHERE user_id = ?";
            ps = conn.prepareStatement(query);
            ps.setInt(1, editId);
            rs = ps.executeQuery();
            if (rs.next()) {
%>
    <h3>Edit User (ID: <%= editId %>)</h3>
    <form method="post" action="manageUsers.jsp">
        <input type="hidden" name="user_id" value="<%= editId %>" />
        First Name: <input type="text" name="first_name" value="<%= rs.getString("first_name") %>" required />
        Last Name: <input type="text" name="last_name" value="<%= rs.getString("last_name") %>" required />
        Email: <input type="email" name="email" value="<%= rs.getString("email") %>" required />
        User Type:
        <select name="user_type">
            <option value="admin" <%= "admin".equals(rs.getString("user_type")) ? "selected" : "" %>>Admin</option>
            <option value="rep" <%= "rep".equals(rs.getString("user_type")) ? "selected" : "" %>>Customer Rep</option>
            <option value="customer" <%= "customer".equals(rs.getString("user_type")) ? "selected" : "" %>>Customer</option>
        </select>
        <input type="submit" name="action" value="Update User" />
    </form>
<%
            }
            rs.close();
            ps.close();
        }

        // DISPLAY USERS BY ROLE
        String[] roles = {"admin", "rep", "customer"};
        for (String role : roles) {
            out.println("<h3>" + role.toUpperCase() + "s</h3>");
            String selectSQL = "SELECT * FROM users WHERE user_type=?";
            ps = conn.prepareStatement(selectSQL);
            ps.setString(1, role);
            rs = ps.executeQuery();

            out.println("<table border='1'><tr><th>ID</th><th>Name</th><th>Email</th><th>Actions</th></tr>");
            while (rs.next()) {
                int id = rs.getInt("user_id");
                out.println("<tr>");
                out.println("<td>" + id + "</td>");
                out.println("<td>" + rs.getString("first_name") + " " + rs.getString("last_name") + "</td>");
                out.println("<td>" + rs.getString("email") + "</td>");
                out.println("<td>");
                out.println("<a href='manageUsers.jsp?edit_id=" + id + "'>Edit</a> | ");
                out.println("<a href='manageUsers.jsp?delete_id=" + id + "' onclick='return confirm(\"Delete this user?\")'>Delete</a>");
                out.println("</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            rs.close();
            ps.close();
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>
</body>
</html>