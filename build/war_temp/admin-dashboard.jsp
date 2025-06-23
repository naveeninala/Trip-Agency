<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    
    // Check if user is logged in and is an admin
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Get statistics for dashboard
    TripDAO tripDAO = new TripDAO();
    BookingDAO bookingDAO = new BookingDAO();
    UserDAO userDAO = new UserDAO();
    
    List<Trip> allTrips = tripDAO.getAllTrips();
    List<Booking> allBookings = bookingDAO.getAllBookings();
    
    // Calculate statistics
    int totalTrips = allTrips.size();
    int totalBookings = allBookings.size();
    int confirmedBookings = 0;
    int pendingBookings = 0;
    double totalRevenue = 0;
    
    for (Booking booking : allBookings) {
        if ("CONFIRMED".equals(booking.getBookingStatus())) {
            confirmedBookings++;
            totalRevenue += booking.getTotalAmount();
        } else if ("PENDING".equals(booking.getBookingStatus())) {
            pendingBookings++;
        }
    }
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
%>
<html>
<head>
    <title>Admin Dashboard - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .admin-dashboard {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .admin-header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            border-radius: 12px;
        }
        
        .admin-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #007bff;
        }
        
        .stat-number {
            font-size: 2.5em;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 10px;
        }
        
        .stat-label {
            color: #666;
            font-size: 1.1em;
        }
          .admin-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .action-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
        }
        
        .action-icon {
            font-size: 3em;
            margin-bottom: 15px;
        }
        
        .action-title {
            font-size: 1.3em;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        
        .action-desc {
            color: #666;
            margin-bottom: 20px;
        }
        
        .btn-admin {
            background: #007bff;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
            transition: background 0.3s;
        }
        
        .btn-admin:hover {
            background: #0056b3;
        }
        
        .btn-danger {
            background: #dc3545;
        }
        
        .btn-danger:hover {
            background: #c82333;
        }
        
        .recent-section {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .section-title {
            font-size: 1.5em;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .data-table th,
        .data-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .data-table th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: bold;
        }
        
        .status-confirmed {
            background: #d4edda;
            color: #155724;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
<!-- Navigation -->
<div class="navbar">
    <h2>Trip Agency - Admin Panel</h2>
    <div class="nav-links">
        <a href="index.jsp">Home</a>
        <a href="admin-dashboard.jsp" class="active">Admin Dashboard</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="admin-dashboard">
    <% if (message != null) { %>
        <div class="alert alert-success">
            <%= message %>
        </div>
    <% } %>
    
    <!-- Admin Header -->
    <div class="admin-header">
        <h1>🛡️ Admin Dashboard</h1>
        <p>Manage trips, bookings, and system operations</p>
    </div>
    
    <!-- Statistics Cards -->
    <div class="admin-stats">
        <div class="stat-card">
            <div class="stat-number"><%= totalTrips %></div>
            <div class="stat-label">Total Trips</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= totalBookings %></div>
            <div class="stat-label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= confirmedBookings %></div>
            <div class="stat-label">Confirmed Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">$<%= String.format("%.2f", totalRevenue) %></div>
            <div class="stat-label">Total Revenue</div>
        </div>
    </div>
    
    <!-- Admin Actions -->
    <div class="admin-actions">
        <div class="action-card">
            <div class="action-icon">🌍</div>
            <div class="action-title">Trip Management</div>
            <div class="action-desc">Add new trips, edit existing ones, or manage availability</div>
            <a href="add-trip.jsp" class="btn-admin">Add New Trip</a>
            <a href="manage-trips.jsp" class="btn-admin" style="margin-left: 10px;">Manage Trips</a>
        </div>
        
        <div class="action-card">
            <div class="action-icon">📋</div>
            <div class="action-title">Booking Management</div>
            <div class="action-desc">View all bookings, update status, and manage reservations</div>
            <a href="manage-bookings.jsp" class="btn-admin">Manage Bookings</a>
        </div>
        
        <div class="action-card">
            <div class="action-icon">👥</div>
            <div class="action-title">User Management</div>
            <div class="action-desc">View user accounts and manage user access</div>
            <a href="manage-users.jsp" class="btn-admin">Manage Users</a>
        </div>
          <div class="action-card">
            <div class="action-icon">📊</div>
            <div class="action-title">Reports & Analytics</div>
            <div class="action-desc">Generate reports and view system analytics</div>
            <a href="reports.jsp" class="btn-admin">View Reports</a>
        </div>
        
        <div class="action-card">
            <div class="action-icon">🤖</div>
            <div class="action-title">Revenue Prediction</div>
            <div class="action-desc">Use AI to predict future revenue based on historical data</div>
            <a href="revenue-prediction" class="btn-admin">Predict Revenue</a>
        </div>
    </div>
    
    <!-- Recent Activity -->
    <div class="recent-section">
        <h2 class="section-title">📈 Recent Bookings</h2>
        <% if (allBookings.isEmpty()) { %>
            <p>No bookings found.</p>
        <% } else { 
            // Show last 5 bookings
            int maxDisplay = Math.min(5, allBookings.size());
        %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>User ID</th>
                        <th>Trip ID</th>
                        <th>Travel Date</th>
                        <th>Participants</th>
                        <th>Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (int i = 0; i < maxDisplay; i++) { 
                        Booking booking = allBookings.get(i);
                    %>
                        <tr>
                            <td>#<%= booking.getBookingId() %></td>                            <td><%= booking.getUserId() %></td>
                            <td><%= booking.getTripId() %></td>
                            <td><%= booking.getTravelDate() %></td>
                            <td><%= booking.getNumberOfParticipants() %></td>
                            <td>$<%= String.format("%.2f", booking.getTotalAmount()) %></td>
                            <td>
                                <span class="status-badge status-<%= booking.getBookingStatus().toLowerCase() %>">
                                    <%= booking.getBookingStatus() %>
                                </span>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
            <% if (allBookings.size() > 5) { %>
                <p style="text-align: center; margin-top: 15px;">
                    <a href="manage-bookings.jsp" class="btn-admin">View All Bookings</a>
                </p>
            <% } %>
        <% } %>
    </div>
</div>
</body>
</html>
