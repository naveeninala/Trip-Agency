<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<html>
<head>
    <title>Trip Agency - Home</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<% 
    User currentUser = (User) session.getAttribute("user");
    TripDAO tripDAO = new TripDAO();
    
    // Handle search parameters
    String searchTerm = request.getParameter("search");
    String activityFilter = request.getParameter("activity");
    String minPriceParam = request.getParameter("minPrice");
    String maxPriceParam = request.getParameter("maxPrice");
    
    Double minPrice = null;
    Double maxPrice = null;
    try {
        if (minPriceParam != null && !minPriceParam.trim().isEmpty()) {
            minPrice = Double.parseDouble(minPriceParam);
        }
        if (maxPriceParam != null && !maxPriceParam.trim().isEmpty()) {
            maxPrice = Double.parseDouble(maxPriceParam);
        }
    } catch (NumberFormatException e) {
        // Ignore invalid price formats
    }
    
    List<Trip> trips;
    if (searchTerm != null || activityFilter != null || minPrice != null || maxPrice != null) {
        trips = tripDAO.searchTrips(searchTerm, activityFilter, minPrice, maxPrice);
    } else {
        trips = tripDAO.getAllTrips();
    }
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
%>

<div class="navbar">
    <h2>Trip Agency</h2>
    <div class="nav-links">
        <a href="index.jsp" class="active">Home</a>        <% if (currentUser != null) { %>
            <a href="dashboard.jsp">My Dashboard</a>
            <span>Welcome, <%= currentUser.getFullName() %></span>
            <% if ("ADMIN".equals(currentUser.getRole())) { %>
                <a href="admin-dashboard.jsp">Admin Panel</a>
            <% } %>
            <a href="logout">Logout</a>
        <% } else { %>
            <a href="login.jsp">Login</a>
            <a href="register.jsp">Register</a>
        <% } %>
    </div>
</div>

<div class="homepage-container">
    <% if (message != null) { %>
        <div style="background: #d4edda; color: #155724; padding: 15px; border-radius: 8px; margin-bottom: 20px; text-align: center;">
            <%= message %>
        </div>
    <% } %>
    
    <div class="search-bar">
        <form action="index.jsp" method="get">
            <input type="text" name="search" placeholder="Search destinations or trip names..." 
                   value="<%= searchTerm != null ? searchTerm : "" %>">
            <select name="activity">
                <option value="">All Activities</option>
                <option value="ADVENTURE" <%= "ADVENTURE".equals(activityFilter) ? "selected" : "" %>>Adventure</option>
                <option value="CULTURAL" <%= "CULTURAL".equals(activityFilter) ? "selected" : "" %>>Cultural</option>
                <option value="RELAXATION" <%= "RELAXATION".equals(activityFilter) ? "selected" : "" %>>Relaxation</option>
                <option value="WILDLIFE" <%= "WILDLIFE".equals(activityFilter) ? "selected" : "" %>>Wildlife</option>
                <option value="BUSINESS" <%= "BUSINESS".equals(activityFilter) ? "selected" : "" %>>Business</option>
            </select>
            <input type="number" name="minPrice" placeholder="Min Price" 
                   value="<%= minPriceParam != null ? minPriceParam : "" %>" style="width: 120px;">
            <input type="number" name="maxPrice" placeholder="Max Price" 
                   value="<%= maxPriceParam != null ? maxPriceParam : "" %>" style="width: 120px;">
            <button type="submit">Search</button>
            <% if (searchTerm != null || activityFilter != null || minPrice != null || maxPrice != null) { %>
                <a href="index.jsp" style="background: #6c757d; color: white; padding: 10px 15px; text-decoration: none; border-radius: 4px; margin-left: 10px;">Clear</a>
            <% } %>
        </form>
    </div>
    
    <h1>
        <% if (searchTerm != null || activityFilter != null || minPrice != null || maxPrice != null) { %>
            Search Results (<%= trips.size() %> trips found)
        <% } else { %>
            Popular Destinations
        <% } %>
    </h1>
    <p>Explore our handpicked collection of amazing adventures</p>
    
    <div class="trip-listing">
        <% if (trips.isEmpty()) { %>
            <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                <h3>No trips found</h3>
                <p>Try adjusting your search criteria or <a href="index.jsp">browse all trips</a>.</p>
            </div>
        <% } else { %>            <% for (Trip trip : trips) { %>                <div class="trip-card">
                    <div class="trip-image">
                        <img src="https://plus.unsplash.com/premium_photo-1661919210043-fd847a58522d?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" alt="<%= trip.getTripName() %>" />
                    </div>
                    <div class="trip-info">
                        <h3><%= trip.getTripName() %></h3>
                        <div class="trip-details">
                            <p><strong>Price:</strong> $<%= String.format("%.2f", trip.getPrice()) %></p>
                            <p><strong>Duration:</strong> <%= trip.getDurationDays() %> days</p>
                            <p><strong>Activity Type:</strong> <%= trip.getActivityType() %></p>
                            <% if (trip.getDescription() != null && !trip.getDescription().isEmpty()) { %>
                                <p><strong>Description:</strong> 
                                   <%= trip.getDescription().length() > 100 ? 
                                       trip.getDescription().substring(0, 100) + "..." : 
                                       trip.getDescription() %>
                                </p>
                            <% } %>
                            <% if (trip.getStartDate() != null && trip.getEndDate() != null) { %>
                                <p><strong>Tour Dates:</strong> <%= trip.getStartDate() %> to <%= trip.getEndDate() %></p>
                            <% } %>
                            <% if (trip.getAvailableSlots() > 0) { %>
                                <p><strong>Available Slots:</strong> <%= trip.getAvailableSlots() %></p>
                            <% } else { %>
                                <p class="sold-out">SOLD OUT</p>
                            <% } %>
                        </div>
                        <div class="trip-actions">
                            <a href="trip-details.jsp?id=<%= trip.getTripId() %>" class="btn">View Details</a>
                            <% if (currentUser != null && trip.getAvailableSlots() > 0) { %>
                                <a href="booking.jsp?tripId=<%= trip.getTripId() %>" class="btn book-btn">Book Now</a>
                            <% } else if (currentUser == null) { %>
                                <a href="login.jsp" class="btn book-btn">Login to Book</a>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
</div>

<footer>
    <p>&copy; 2025 Trip Agency Management System. All rights reserved.</p>
</footer>
</body>
</html>
