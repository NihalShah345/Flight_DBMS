<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.*, java.util.*, java.math.BigDecimal" %>
<%@ page import="com.cs336_Group6.pkg.ApplicationDB" %>

<%

String mode = request.getParameter("mode");
String from = request.getParameter("from");
String to = request.getParameter("to");
String depDate = request.getParameter("date");
String retDate = request.getParameter("return_date");
String sort = request.getParameter("sort");

String minPrice = request.getParameter("minPrice") != null ? request.getParameter("minPrice") : "";
String maxPrice = request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : "";
String stops = request.getParameter("stops") != null ? request.getParameter("stops") : "";
String airline = request.getParameter("airline") != null ? request.getParameter("airline") : "";

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat dayFormat = new SimpleDateFormat("EEE", Locale.US);

String sortClause = "";
if ("price_asc".equals(sort)) sortClause = " ORDER BY price ASC";
else if ("price_desc".equals(sort)) sortClause = " ORDER BY price DESC";
else if ("depart_asc".equals(sort)) sortClause = " ORDER BY departure_time ASC";
else if ("depart_desc".equals(sort)) sortClause = " ORDER BY departure_time DESC";
else if ("arrival_asc".equals(sort)) sortClause = " ORDER BY arrival_time ASC";
else if ("arrival_desc".equals(sort)) sortClause = " ORDER BY arrival_time DESC";

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
<title>Search Flights</title>
<script>
    function toggleMode(value) {
        document.getElementById('roundtrip-fields').style.display = (value === 'roundtrip') ? 'block' : 'none';
    }
</script>
</head>
<body>
<h2>Search for Flights</h2>
<form action="dashboard.jsp" method="get">
<button type="submit">Back to Dashboard</button>
</form>

<form method="get" action="searchFlights.jsp">
<label><input type="radio" name="mode" value="oneway" onclick="toggleMode('oneway')" <%= "oneway".equals(mode) ? "checked" : "" %>> One-Way</label>
<label><input type="radio" name="mode" value="roundtrip" onclick="toggleMode('roundtrip')" <%= "roundtrip".equals(mode) ? "checked" : "" %>> Round-Trip</label><br><br>

From: <input type="text" name="from" required value="<%= from != null ? from : "" %>"><br>
To: <input type="text" name="to" required value="<%= to != null ? to : "" %>"><br>
Departure Date: <input type="date" name="date" required value="<%= depDate != null ? depDate : "" %>"><br>

<div id="roundtrip-fields" style="display:<%= "roundtrip".equals(mode) ? "block" : "none" %>">
    Return Date: <input type="date" name="return_date" value="<%= retDate != null ? retDate : "" %>"><br>
</div>

Sort by:
<select name="sort">
    <option value="">-- None --</option>
    <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Price (Low to High)</option>
    <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Price (High to Low)</option>
    <option value="depart_asc" <%= "depart_asc".equals(sort) ? "selected" : "" %>>Departure Time (Earliest)</option>
    <option value="depart_desc" <%= "depart_desc".equals(sort) ? "selected" : "" %>>Departure Time (Latest)</option>
    <option value="arrival_asc" <%= "arrival_asc".equals(sort) ? "selected" : "" %>>Arrival Time (Earliest)</option>
    <option value="arrival_desc" <%= "arrival_desc".equals(sort) ? "selected" : "" %>>Arrival Time (Latest)</option>
</select><br>

<!-- Price Filter -->
Min Price: <input type="number" name="minPrice" step="0.01" value="<%= minPrice %>">
Max Price: <input type="number" name="maxPrice" step="0.01" value="<%= maxPrice %>"><br>

<!-- Stops Filter -->
Stops:
<select name="stops">
    <option value="">Any</option>
    <option value="0" <%= "0".equals(stops) ? "selected" : "" %>>Non-stop</option>
    <option value="1" <%= "1".equals(stops) ? "selected" : "" %>>1 Stop</option>
    <option value="2" <%= "2".equals(stops) ? "selected" : "" %>>2+ Stops</option>
</select><br>

<!-- Airline Filter -->
Airline:
<select name="airline">
    <option value="">Any</option>
    <option value="AA" <%= "AA".equals(airline) ? "selected" : "" %>>American Airlines</option>
    <option value="UA" <%= "UA".equals(airline) ? "selected" : "" %>>United</option>
    <option value="DL" <%= "DL".equals(airline) ? "selected" : "" %>>Delta</option>
    <option value="SW" <%= "SW".equals(airline) ? "selected" : "" %>>Southwest</option>
</select><br>

<br><input type="submit" value="Search">    
</form>


<%
if ("oneway".equals(mode) && depDate != null && !depDate.trim().equals("")) {
    try {
    	ApplicationDB db = new ApplicationDB();	
		conn = db.getConnection();
		java.util.Date baseDate = sdf.parse(depDate);
        Calendar cal = Calendar.getInstance();
        Statement stmt = conn.createStatement();
        stmt.executeUpdate("CREATE TEMPORARY TABLE TempFlights (" +
                "flight_id INT, flight_number VARCHAR(10), airline_id CHAR(2), departure_airport CHAR(3), " +
                "arrival_airport CHAR(3), departure_time DATETIME, arrival_time DATETIME, " +
                "days_of_week SET('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'), " +
                "domestic BOOLEAN, price DECIMAL(10,2), num_stops INT, flight_date DATE)");
		for (int i = -3; i <= 3; i++) {
    		cal.setTime(baseDate);
    		cal.add(Calendar.DATE, i);
    		java.util.Date currentDate = cal.getTime();
    		String dateStr = sdf.format(currentDate);
    		String dayName = dayFormat.format(currentDate);

    		String insertSQL = "INSERT INTO TempFlights " +
    	            "SELECT flight_id, flight_number, airline_id, departure_airport, arrival_airport, departure_time, arrival_time, " +
    	            "days_of_week, domestic, price, num_stops, ? AS flight_date " +
    	            "FROM Flights WHERE departure_airport = ? AND arrival_airport = ? AND FIND_IN_SET(?, days_of_week)";
    		
    		if (!minPrice.isEmpty()) insertSQL += " AND price >= " + minPrice;
            if (!maxPrice.isEmpty()) insertSQL += " AND price <= " + maxPrice;
            if (!stops.isEmpty()) {
                if ("2".equals(stops)) insertSQL += " AND num_stops >= 2";
                else insertSQL += " AND num_stops = " + stops;
            }
            if (!airline.isEmpty()) insertSQL += " AND airline_id = '" + airline + "'";
            PreparedStatement psInsert = conn.prepareStatement(insertSQL);
            psInsert.setString(1, dateStr);
            psInsert.setString(2, from);
            psInsert.setString(3, to);
            psInsert.setString(4, dayName);
            psInsert.executeUpdate();
            psInsert.close();
        }
		String selectSQL = "SELECT * FROM TempFlights" + sortClause;
		ps = conn.prepareStatement(selectSQL);
		rs = ps.executeQuery();
		%>
		<h3>One-Way Flights (+/- 3 days)</h3>
		<table border="1">
		<tr>
		<th>Date</th>
		<th>Flight</th>
		<th>Route</th>
		<th>Time</th>
		<th>Fare</th>
		<th>Book</th>
		</tr>
		<%
		while (rs.next()) {
		%>
		<tr>
		<td><%= rs.getDate("flight_date") %></td>
		<td><%= rs.getString("flight_number") %> - <%= rs.getString("airline_id") %></td>
		<td><%= rs.getString("departure_airport") %> → <%= rs.getString("arrival_airport") %></td>
		<td><%= rs.getTimestamp("departure_time") %> → <%= rs.getTimestamp("arrival_time") %></td>
		<td>$<%= rs.getBigDecimal("price") %></td>
		<td>
		<form method="post" action="bookTicket.jsp">
		<input type="hidden" name="mode" value="oneway">
		<input type="hidden" name="flight_id" value="<%= rs.getInt("flight_id") %>">
		<input type="hidden" name="flight_date" value="<%= rs.getDate("flight_date") %>">
		<input type="hidden" name="price" value="<%= rs.getBigDecimal("price") %>">
		<input type="submit" value="Book">
		</form>
		</td>
		</tr>
		<%
		}
		} catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}

if ("roundtrip".equals(mode) && depDate != null && retDate != null &&
!depDate.trim().equals("") && !retDate.trim().equals("")) {
try {
    ApplicationDB db = new ApplicationDB();
    conn = db.getConnection();

    java.util.Date depBase = sdf.parse(depDate);
    java.util.Date retBase = sdf.parse(retDate);
    java.util.Date retLimit = sdf.parse(retDate);
    Calendar cal = Calendar.getInstance();

    Statement stmt = conn.createStatement();
    stmt.executeUpdate("CREATE TEMPORARY TABLE TempFlights (" +
        "flight_id INT, flight_number VARCHAR(10), airline_id CHAR(2), " +
        "departure_airport CHAR(3), arrival_airport CHAR(3), " +
        "departure_time DATETIME, arrival_time DATETIME, " +
        "days_of_week SET('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'), " +
        "domestic BOOLEAN, price DECIMAL(10,2), num_stops INT, flight_date DATE)");

    // Insert departing flights into TempFlights
    for (int i = -3; i <= 3; i++) {
        cal.setTime(depBase);
        cal.add(Calendar.DATE, i);
        java.util.Date currentDate = cal.getTime();
        if (!currentDate.before(retLimit)) continue;

        String dateStr = sdf.format(currentDate);
        String dayName = dayFormat.format(currentDate);

        String ins = "INSERT INTO TempFlights SELECT flight_id, flight_number, airline_id, departure_airport, arrival_airport, departure_time, arrival_time, days_of_week, domestic, price, num_stops, ? " +
                     "FROM Flights WHERE departure_airport = ? AND arrival_airport = ? AND FIND_IN_SET(?, days_of_week)";

        if (minPrice != null && !minPrice.isEmpty()) ins += " AND price >= " + minPrice;
        if (maxPrice != null && !maxPrice.isEmpty()) ins += " AND price <= " + maxPrice;
        if (stops != null && !stops.isEmpty()) {
            if ("2".equals(stops)) ins += " AND num_stops >= 2";
            else ins += " AND num_stops = " + stops;
        }
        if (airline != null && !airline.isEmpty()) ins += " AND airline_id = '" + airline + "'";

        PreparedStatement psInsert = conn.prepareStatement(ins);
        psInsert.setString(1, dateStr);
        psInsert.setString(2, from);
        psInsert.setString(3, to);
        psInsert.setString(4, dayName);
        psInsert.executeUpdate();
        psInsert.close();
    }

    // Now query departing flights globally sorted
    String fetchDep = "SELECT * FROM TempFlights" + sortClause;
    ps = conn.prepareStatement(fetchDep);
    rs = ps.executeQuery();

    ArrayList<HashMap<String, Object>> depFlightsList = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> row = new HashMap<String, Object>();
        row.put("flight_id", rs.getInt("flight_id"));
        row.put("flight_number", rs.getString("flight_number"));
        row.put("airline_id", rs.getString("airline_id"));
        row.put("departure_airport", rs.getString("departure_airport"));
        row.put("arrival_airport", rs.getString("arrival_airport"));
        row.put("departure_time", rs.getTimestamp("departure_time"));
        row.put("arrival_time", rs.getTimestamp("arrival_time"));
        row.put("price", rs.getBigDecimal("price"));
        row.put("date", rs.getDate("flight_date").toString());
        depFlightsList.add(row);
    }
    rs.close();
    ps.close();

    // Clean and recreate TempFlights for return flights
    stmt.executeUpdate("DROP TEMPORARY TABLE IF EXISTS TempFlights");
    stmt.executeUpdate("CREATE TEMPORARY TABLE TempFlights (" +
        "flight_id INT, flight_number VARCHAR(10), airline_id CHAR(2), " +
        "departure_airport CHAR(3), arrival_airport CHAR(3), " +
        "departure_time DATETIME, arrival_time DATETIME, " +
        "days_of_week SET('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'), " +
        "domestic BOOLEAN, price DECIMAL(10,2), num_stops INT, flight_date DATE)");

    for (int i = -3; i <= 3; i++) {
        cal.setTime(retBase);
        cal.add(Calendar.DATE, i);
        java.util.Date currentDate = cal.getTime();
        String dateStr = sdf.format(currentDate);
        String dayName = dayFormat.format(currentDate);

        String ins = "INSERT INTO TempFlights SELECT flight_id, flight_number, airline_id, departure_airport, arrival_airport, departure_time, arrival_time, days_of_week, domestic, price, num_stops, ? " +
                     "FROM Flights WHERE departure_airport = ? AND arrival_airport = ? AND FIND_IN_SET(?, days_of_week)";

        if (minPrice != null && !minPrice.isEmpty()) ins += " AND price >= " + minPrice;
        if (maxPrice != null && !maxPrice.isEmpty()) ins += " AND price <= " + maxPrice;
        if (stops != null && !stops.isEmpty()) {
            if ("2".equals(stops)) ins += " AND num_stops >= 2";
            else ins += " AND num_stops = " + stops;
        }
        if (airline != null && !airline.isEmpty()) ins += " AND airline_id = '" + airline + "'";

        PreparedStatement psInsert = conn.prepareStatement(ins);
        psInsert.setString(1, dateStr);
        psInsert.setString(2, to);
        psInsert.setString(3, from);
        psInsert.setString(4, dayName);
        psInsert.executeUpdate();
        psInsert.close();
    }

    String fetchRet = "SELECT * FROM TempFlights" + sortClause;
    ps = conn.prepareStatement(fetchRet);
    rs = ps.executeQuery();

    ArrayList<HashMap<String, Object>> retFlightsList = new ArrayList<HashMap<String, Object>>();
    while (rs.next()) {
        HashMap<String, Object> row = new HashMap<String, Object>();
        row.put("flight_id", rs.getInt("flight_id"));
        row.put("flight_number", rs.getString("flight_number"));
        row.put("airline_id", rs.getString("airline_id"));
        row.put("departure_airport", rs.getString("departure_airport"));
        row.put("arrival_airport", rs.getString("arrival_airport"));
        row.put("departure_time", rs.getTimestamp("departure_time"));
        row.put("arrival_time", rs.getTimestamp("arrival_time"));
        row.put("price", rs.getBigDecimal("price"));
        row.put("date", rs.getDate("flight_date").toString());
        java.sql.Date sqlDate = rs.getDate("flight_date");
        row.put("date", sqlDate.toString());
        row.put("java_date", new java.util.Date(sqlDate.getTime()));

        retFlightsList.add(row);
    }

    rs.close();
    ps.close();
    stmt.executeUpdate("DROP TEMPORARY TABLE IF EXISTS TempFlights");

    // The printing of combinations can follow from here...
%>
    <h3>Round-Trip Combinations</h3>
    <table border="1">
        <tr>
            <th>Depart Flight</th>
            <th>Return Flight</th>
            <th>Depart Info</th>
            <th>Return Info</th>
            <th>Total Price</th>
        </tr>
<%
        for (int i = 0; i < depFlightsList.size(); i++) {
            HashMap<String, Object> d = depFlightsList.get(i);
            java.util.Date dDate = sdf.parse((String) d.get("date"));

            for (int j = 0; j < retFlightsList.size(); j++) {
                HashMap<String, Object> r = retFlightsList.get(j);
                java.util.Date rDate = (java.util.Date) r.get("java_date");

                if (rDate.after(dDate)) {
                    BigDecimal total = ((BigDecimal) d.get("price")).add((BigDecimal) r.get("price"));
%>
        <tr>
            <td><%= d.get("flight_number") %> - <%= d.get("airline_id") %></td>
            <td><%= r.get("flight_number") %> - <%= r.get("airline_id") %></td>
            <td>
                <%= d.get("departure_airport") %> → <%= d.get("arrival_airport") %><br/>
                <%= d.get("date") %> @ <%= d.get("departure_time") %> → <%= d.get("arrival_time") %>
            </td>
            <td>
                <%= r.get("departure_airport") %> → <%= r.get("arrival_airport") %><br/>
                <%= r.get("date") %> @ <%= r.get("departure_time") %> → <%= r.get("arrival_time") %>
            </td>
            <td>$<%= total %></td>
            <td>
    			<form method="post" action="bookTicket.jsp">
    				<input type="hidden" name="mode" value="roundtrip">
    				<input type="hidden" name="flight_id1" value="<%= d.get("flight_id") %>">
    				<input type="hidden" name="flight_date1" value="<%= d.get("date") %>">
    				<input type="hidden" name="price1" value="<%= d.get("price") %>">

    				<input type="hidden" name="flight_id2" value="<%= r.get("flight_id") %>">
    				<input type="hidden" name="flight_date2" value="<%= r.get("date") %>">
    				<input type="hidden" name="price2" value="<%= r.get("price") %>">
    				<input type="submit" value="Book">
				</form>
			</td>
            
        </tr>
<%
                }
            }
        }
%>
    </table>
<%
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}
%>
</body>
</html>

