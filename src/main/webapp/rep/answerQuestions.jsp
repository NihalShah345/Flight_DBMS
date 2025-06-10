<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.cs336_Group6.pkg.ApplicationDB" %>
<%@ page session="true" %>
<%
    String userType = (String) session.getAttribute("user_type");
    Integer repId = (Integer) session.getAttribute("user_id");
    if (userType == null || !"rep".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String answerText = request.getParameter("answer_text");
    String questionIdStr = request.getParameter("question_id");
    String message = null;

    if ("POST".equalsIgnoreCase(request.getMethod()) && answerText != null && repId != null && questionIdStr != null) {
        try {
            int questionId = Integer.parseInt(questionIdStr);
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String insert = "INSERT INTO Answers (question_id, rep_id, answer_text) VALUES (?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(insert);
            ps.setInt(1, questionId);
            ps.setInt(2, repId);
            ps.setString(3, answerText.trim());
            ps.executeUpdate();

            message = "Answer submitted successfully.";

            ps.close();
            conn.close();
        } catch (Exception e) {
            message = "Error submitting answer: " + e.getMessage();
        }
    }

    // Load unanswered questions
    ArrayList<HashMap<String, String>> unanswered = new ArrayList<HashMap<String, String>>();
    try {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        String sql = "SELECT q.question_id, q.question_text, u.first_name, u.last_name, q.asked_on " +
                     "FROM Questions q JOIN Users u ON q.user_id = u.user_id " +
                     "LEFT JOIN Answers a ON q.question_id = a.question_id " +
                     "WHERE a.question_id IS NULL ORDER BY q.asked_on DESC";

        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            HashMap<String, String> row = new HashMap<String, String>();
            row.put("id", rs.getString("question_id"));
            row.put("text", rs.getString("question_text"));
            row.put("user", rs.getString("first_name") + " " + rs.getString("last_name"));
            row.put("asked_on", rs.getString("asked_on"));
            unanswered.add(row);
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p>Error loading unanswered questions: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head><title>Answer Customer Questions</title></head>
<body>
<h2>Unanswered Questions</h2>
<form action="repDashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<% if (message != null) { %>
    <p style="color:green;"><b><%= message %></b></p>
<% } %>

<% for (int i = 0; i < unanswered.size(); i++) {
       HashMap<String, String> q = unanswered.get(i); %>
    <div style="border:1px solid #ccc; padding:10px; margin-bottom:15px;">
        <p><strong>Question:</strong> <%= q.get("text") %></p>
        <p><strong>Asked By:</strong> <%= q.get("user") %> | <strong>Date:</strong> <%= q.get("asked_on") %></p>
        <form method="post" action="answerQuestions.jsp">
            <input type="hidden" name="question_id" value="<%= q.get("id") %>">
            <textarea name="answer_text" rows="3" cols="60" placeholder="Type your answer here..." required></textarea><br>
            <input type="submit" value="Submit Answer">
        </form>
    </div>
<% } %>

<% if (unanswered.isEmpty()) { %>
    <p>There are no unanswered questions at the moment.</p>
<% } %>
</body>
</html>
