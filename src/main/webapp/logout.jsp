<%@ page session="true" %>
<%
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
