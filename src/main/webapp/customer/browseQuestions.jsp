<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.cs336_Group6.pkg.ApplicationDB" %>

<%
    String keyword = request.getParameter("keyword");
    String newQuestion = request.getParameter("question_text");
    Integer userId = (Integer) session.getAttribute("user_id"); 
    String message = null;

    // Insert new question
    if ("POST".equalsIgnoreCase(request.getMethod()) && newQuestion != null && !newQuestion.trim().isEmpty() && userId != null) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();

            String insert = "INSERT INTO Questions (user_id, question_text) VALUES (?, ?)";
            PreparedStatement insertStmt = conn.prepareStatement(insert);
            insertStmt.setInt(1, userId);
            insertStmt.setString(2, newQuestion.trim());
            insertStmt.executeUpdate();

            message = "Your question has been submitted!";
            insertStmt.close();
            conn.close();
        } catch (Exception e) {
            message = "Error submitting question: " + e.getMessage();
        }
    }

    // Fetch all Q&A
    ArrayList<HashMap<String, String>> qnaList = new ArrayList<HashMap<String, String>>();
    try {
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();

        String sql = "SELECT q.question_id, q.question_text, q.asked_on, u.first_name AS user_fname, u.last_name AS user_lname, " +
                     "a.answer_text, a.answered_on, r.first_name AS rep_fname, r.last_name AS rep_lname " +
                     "FROM Questions q " +
                     "JOIN Users u ON q.user_id = u.user_id " +
                     "LEFT JOIN Answers a ON q.question_id = a.question_id " +
                     "LEFT JOIN Users r ON a.rep_id = r.user_id ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "WHERE q.question_text LIKE ? OR a.answer_text LIKE ?";
        }

        sql += "ORDER BY q.asked_on DESC";

        PreparedStatement ps = conn.prepareStatement(sql);
        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            HashMap<String, String> row = new HashMap<String, String>();
            row.put("question", rs.getString("question_text"));
            row.put("asked_by", rs.getString("user_fname") + " " + rs.getString("user_lname"));
            row.put("asked_on", rs.getString("asked_on"));

            String answer = rs.getString("answer_text");
            if (answer != null) {
                row.put("answer", answer);
                row.put("answered_on", rs.getString("answered_on"));
                row.put("rep", rs.getString("rep_fname") + " " + rs.getString("rep_lname"));
            } else {
                row.put("answer", "Awaiting response...");
                row.put("answered_on", "N/A");
                row.put("rep", "N/A");
            }

            qnaList.add(row);
        }

        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p>Error loading questions: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head><title>Browse & Ask Questions</title></head>
<body>
<h2>Customer Q&A</h2>
<form action="dashboard.jsp" method="get">
    <button type="submit">Back to Dashboard</button>
</form>

<!-- Show messages -->
<% if (message != null) { %>
    <p style="color:green;"><b><%= message %></b></p>
<% } %>

<!-- Search Form -->
<form method="get" action="browseQuestions.jsp">
    Search Keyword: <input type="text" name="keyword" value="<%= keyword != null ? keyword : "" %>">
    <input type="submit" value="Search">
</form>

<!-- Ask a Question Form -->
<% if (userId != null) { %>
    <form method="post" action="browseQuestions.jsp">
        <h3>Ask a Question</h3>
        <textarea name="question_text" rows="4" cols="50" placeholder="Type your question here..." required></textarea><br>
        <input type="submit" value="Submit Question">
    </form>
<% } else { %>
    <p><i>Login required to submit a question.</i></p>
<% } %>

<br>

<!-- Display Q&A Table -->
<table border="1">
    <tr>
        <th>Question</th>
        <th>Asked By</th>
        <th>Asked On</th>
        <th>Answer</th>
        <th>Answered By</th>
        <th>Answered On</th>
    </tr>
<% for (int i = 0; i < qnaList.size(); i++) {
       HashMap<String, String> q = qnaList.get(i); %>
    <tr>
        <td><%= q.get("question") %></td>
        <td><%= q.get("asked_by") %></td>
        <td><%= q.get("asked_on") %></td>
        <td><%= q.get("answer") %></td>
        <td><%= q.get("rep") %></td>
        <td><%= q.get("answered_on") %></td>
    </tr>
<% } %>
</table>
</body>
</html>
