<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
    	ApplicationDB db = new ApplicationDB();	
		conn = db.getConnection();

        String sql = "SELECT user_id, user_type FROM Users WHERE email = ? AND password = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        ps.setString(2, password);
        rs = ps.executeQuery();

        if (rs.next()) {
            int userId = rs.getInt("user_id");
            String userType = rs.getString("user_type");

            session.setAttribute("user_id", userId);
            session.setAttribute("user_type", userType);

            if ("admin".equals(userType)) {
                response.sendRedirect("admin/adminDashboard.jsp");
            } else if ("rep".equals(userType)) {
                response.sendRedirect("rep/repDashboard.jsp");
            } else {
                response.sendRedirect("customer/dashboard.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=true");
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
%>
