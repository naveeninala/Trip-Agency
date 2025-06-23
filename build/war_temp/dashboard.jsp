<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> userBookings = bookingDAO.getBookingsByUserId(currentUser.getUserId());
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
%>
<html>
<head>
    <title>My Dashboard - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .dashboard-container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 20px;
        }
        
        .dashboard-header {
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .dashboard-header h1 {
            margin: 0 0 10px 0;
            font-size: 28px;
        }
        
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #666;
            font-size: 14px;
        }
        
        .section-title {
            font-size: 24px;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #007bff;
            padding-bottom: 10px;
        }
        
        .booking-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .booking-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .booking-id {
            font-weight: bold;
            color: #007bff;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-confirmed {
            background: #d4edda;
            color: #155724;
        }
        
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
        }
        
        .booking-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .detail-item {
            display: flex;
            flex-direction: column;
        }
        
        .detail-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        
        .detail-value {
            font-weight: 600;
            color: #333;
        }
        
        .no-bookings {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .quick-actions {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .action-btn {
            flex: 1;
            padding: 15px;
            background: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 8px;
            text-decoration: none;
            color: #333;
            text-align: center;
            transition: all 0.3s;
        }
        
        .action-btn:hover {
            background: #e9ecef;
            transform: translateY(-2px);
        }
        
        .action-btn.primary {
            background: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .action-btn.primary:hover {
            background: #0056b3;
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
    <h2>Trip Agency</h2>
    <div class="nav-links">        <a href="index.jsp">Home</a>
        <a href="dashboard.jsp" class="active">My Dashboard</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <% if ("ADMIN".equals(currentUser.getRole())) { %>
            <a href="admin-dashboard.jsp">Admin Panel</a>
        <% } %>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="dashboard-container">
    <% if (message != null) { %>
        <div class="alert alert-success">
            <%= message %>
        </div>
    <% } %>
    
    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <h1>Welcome back, <%= currentUser.getFullName() %>!</h1>
        <p>Manage your trips and explore new destinations</p>
    </div>
    
    <!-- Quick Actions -->
    <div class="quick-actions">
        <a href="index.jsp" class="action-btn primary">
            <strong>🌍 Browse Trips</strong><br>
            <small>Discover new destinations</small>
        </a>
        <a href="#" class="action-btn">
            <strong>📋 My Bookings</strong><br>
            <small>View your travel history</small>
        </a>
        <a href="#" class="action-btn">
            <strong>👤 Profile Settings</strong><br>
            <small>Update your information</small>
        </a>
    </div>
    
    <!-- Dashboard Stats -->
    <div class="dashboard-stats">
        <div class="stat-card">
            <div class="stat-number"><%= userBookings.size() %></div>
            <div class="stat-label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <%= userBookings.stream().mapToLong(b -> "CONFIRMED".equals(b.getBookingStatus()) ? 1 : 0).sum() %>
            </div>
            <div class="stat-label">Confirmed Trips</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">
                <%= userBookings.stream().mapToLong(b -> "PENDING".equals(b.getBookingStatus()) ? 1 : 0).sum() %>
            </div>
            <div class="stat-label">Pending Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">$<%= String.format("%.0f", userBookings.stream().mapToDouble(Booking::getTotalAmount).sum()) %></div>
            <div class="stat-label">Total Spent</div>
        </div>
    </div>
    
    <!-- My Bookings Section -->
    <h2 class="section-title">My Bookings</h2>
    
    <% if (userBookings.isEmpty()) { %>
        <div class="no-bookings">
            <h3>No bookings yet</h3>
            <p>Start planning your next adventure!</p>
            <a href="index.jsp" class="btn book-btn" style="display: inline-block; margin-top: 15px;">Browse Trips</a>
        </div>
    <% } else { %>
        <% for (Booking booking : userBookings) { 
            TripDAO tripDAO = new TripDAO();
            // Note: We'll need to add a getTripById method to TripDAO
            // For now, we'll display the trip ID
        %>
            <div class="booking-card">
                <div class="booking-header">
                    <span class="booking-id">Booking #<%= booking.getBookingId() %></span>
                    <span class="status-badge status-<%= booking.getBookingStatus().toLowerCase() %>">
                        <%= booking.getBookingStatus() %>
                    </span>
                </div>
                
                <div class="booking-details">
                    <div class="detail-item">
                        <span class="detail-label">Trip ID</span>
                        <span class="detail-value">#<%= booking.getTripId() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Travel Date</span>
                        <span class="detail-value"><%= booking.getTravelDate() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Participants</span>
                        <span class="detail-value"><%= booking.getNumberOfParticipants() %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Total Amount</span>
                        <span class="detail-value">$<%= String.format("%.2f", booking.getTotalAmount()) %></span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Booking Date</span>
                        <span class="detail-value"><%= booking.getBookingDate() %></span>
                    </div>
                </div>
                
                <% if (booking.getTravellerDetails() != null && !booking.getTravellerDetails().trim().isEmpty()) { %>
                    <div style="margin-top: 15px;">
                        <span class="detail-label">Traveller Details</span>
                        <p style="margin: 5px 0; color: #555;"><%= booking.getTravellerDetails() %></p>
                    </div>
                <% } %>
                
                <% if (booking.getSpecialRequests() != null && !booking.getSpecialRequests().trim().isEmpty()) { %>
                    <div style="margin-top: 10px;">
                        <span class="detail-label">Special Requests</span>
                        <p style="margin: 5px 0; color: #555;"><%= booking.getSpecialRequests() %></p>
                    </div>
                <% } %>
            </div>
        <% } %>
    <% } %>
</div>

<footer>
    <p>&copy; 2025 Trip Agency Management System. All rights reserved.</p>
</footer>
</body>
</html>
