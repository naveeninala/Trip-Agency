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
    
    BookingDAO bookingDAO = new BookingDAO();
    TripDAO tripDAO = new TripDAO();
    UserDAO userDAO = new UserDAO();
    
    List<Booking> allBookings = bookingDAO.getAllBookings();
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
%>
<html>
<head>
    <title>Manage Bookings - Admin Panel</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .manage-bookings-container {
            max-width: 1400px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            border-radius: 12px;
        }
        
        .stats-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #007bff;
        }
        
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
        
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding: 15px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .bookings-table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .bookings-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .bookings-table th,
        .bookings-table td {
            padding: 15px 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .bookings-table th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
            position: sticky;
            top: 0;
        }
        
        .bookings-table tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
            text-transform: uppercase;
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
        
        .btn-small {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            font-size: 0.85em;
            text-decoration: none;
            cursor: pointer;
            margin-right: 5px;
            transition: background 0.3s;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-success:hover {
            background: #218838;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #333;
        }
        
        .btn-warning:hover {
            background: #e0a800;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            transition: background 0.3s;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
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
        
        .no-bookings {
            text-align: center;
            padding: 60px;
            color: #666;
        }
        
        .booking-details {
            font-size: 0.9em;
            color: #666;
        }
        
        @media (max-width: 768px) {
            .bookings-table-container {
                overflow-x: auto;
            }
            
            .stats-bar {
                grid-template-columns: 1fr 1fr;
            }
            
            .action-bar {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
<!-- Navigation -->
<div class="navbar">
    <h2>Trip Agency - Admin Panel</h2>
    <div class="nav-links">
        <a href="index.jsp">Home</a>
        <a href="admin-dashboard.jsp">Admin Dashboard</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="manage-bookings-container">
    <div class="page-header">
        <h1>📋 Manage Bookings</h1>
        <p>View and manage all customer bookings</p>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <%= message %>
        </div>
    <% } %>
    
    <%
        // Calculate statistics
        int totalBookings = allBookings.size();
        int confirmedBookings = 0;
        int pendingBookings = 0;
        int cancelledBookings = 0;
        double totalRevenue = 0;
        
        for (Booking booking : allBookings) {
            String status = booking.getBookingStatus();
            if ("CONFIRMED".equals(status)) {
                confirmedBookings++;
                totalRevenue += booking.getTotalAmount();
            } else if ("PENDING".equals(status)) {
                pendingBookings++;
            } else if ("CANCELLED".equals(status)) {
                cancelledBookings++;
            }
        }
    %>
    
    <div class="stats-bar">
        <div class="stat-card">
            <div class="stat-number"><%= totalBookings %></div>
            <div class="stat-label">Total Bookings</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= confirmedBookings %></div>
            <div class="stat-label">Confirmed</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= pendingBookings %></div>
            <div class="stat-label">Pending</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= cancelledBookings %></div>
            <div class="stat-label">Cancelled</div>
        </div>
        <div class="stat-card">
            <div class="stat-number">$<%= String.format("%.0f", totalRevenue) %></div>
            <div class="stat-label">Total Revenue</div>
        </div>
    </div>
    
    <div class="action-bar">
        <div>
            <h3>All Bookings</h3>
        </div>
        <div>
            <a href="admin-dashboard.jsp" class="btn-secondary">← Back to Dashboard</a>
        </div>
    </div>
    
    <% if (allBookings.isEmpty()) { %>
        <div class="bookings-table-container">
            <div class="no-bookings">
                <h3>No bookings found</h3>
                <p>No customers have made any bookings yet.</p>
            </div>
        </div>
    <% } else { %>
        <div class="bookings-table-container">
            <table class="bookings-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Customer</th>
                        <th>Trip</th>
                        <th>Travel Date</th>
                        <th>Participants</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Booking Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Booking booking : allBookings) { 
                        // Get trip and user details
                        Trip trip = null;
                        User user = null;
                        try {
                            trip = tripDAO.getTripById(booking.getTripId());
                            user = userDAO.getUserById(booking.getUserId());
                        } catch (Exception e) {
                            // Handle silently
                        }
                    %>
                        <tr>
                            <td><strong>#<%= booking.getBookingId() %></strong></td>
                            <td>
                                <% if (user != null) { %>
                                    <%= user.getFullName() %><br>
                                    <small class="booking-details">ID: <%= user.getUserId() %></small>
                                <% } else { %>
                                    User ID: <%= booking.getUserId() %>
                                <% } %>
                            </td>
                            <td>
                                <% if (trip != null) { %>
                                    <%= trip.getTripName() %><br>
                                    <small class="booking-details">ID: <%= trip.getTripId() %></small>
                                <% } else { %>
                                    Trip ID: <%= booking.getTripId() %>
                                <% } %>
                            </td>
                            <td><%= booking.getTravelDate() %></td>
                            <td><%= booking.getNumberOfParticipants() %></td>
                            <td><strong>$<%= String.format("%.2f", booking.getTotalAmount()) %></strong></td>
                            <td>
                                <span class="status-badge status-<%= booking.getBookingStatus().toLowerCase() %>">
                                    <%= booking.getBookingStatus() %>
                                </span>
                            </td>
                            <td>
                                <%= booking.getBookingDate() != null ? 
                                    new java.text.SimpleDateFormat("MMM dd, yyyy").format(booking.getBookingDate()) : 
                                    "N/A" %>
                            </td>
                            <td>
                                <% if ("PENDING".equals(booking.getBookingStatus())) { %>
                                    <a href="UpdateBookingServlet?id=<%= booking.getBookingId() %>&status=CONFIRMED" 
                                       class="btn-small btn-success"
                                       onclick="return confirm('Confirm this booking?')">
                                        ✅ Confirm
                                    </a>
                                    <a href="UpdateBookingServlet?id=<%= booking.getBookingId() %>&status=CANCELLED" 
                                       class="btn-small btn-danger"
                                       onclick="return confirm('Cancel this booking?')">
                                        ❌ Cancel
                                    </a>
                                <% } else if ("CONFIRMED".equals(booking.getBookingStatus())) { %>
                                    <a href="UpdateBookingServlet?id=<%= booking.getBookingId() %>&status=CANCELLED" 
                                       class="btn-small btn-danger"
                                       onclick="return confirm('Cancel this confirmed booking?')">
                                        ❌ Cancel
                                    </a>
                                <% } else { %>
                                    <span class="booking-details">No actions</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</div>
</body>
</html>
