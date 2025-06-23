<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    
    // Check if user is logged in and is an admin
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Initialize DAOs
    TripDAO tripDAO = new TripDAO();
    BookingDAO bookingDAO = new BookingDAO();
    
    // Get all data
    List<Trip> allTrips = tripDAO.getAllTrips();
    List<Booking> allBookings = bookingDAO.getAllBookings();
    
    // Calculate statistics
    int totalTrips = allTrips.size();
    int totalBookings = allBookings.size();
    int confirmedBookings = 0;
    int pendingBookings = 0;
    int cancelledBookings = 0;
    double totalRevenue = 0;
    double pendingRevenue = 0;
    
    DecimalFormat currencyFormat = new DecimalFormat("#,##0.00");
    
    for (Booking booking : allBookings) {
        String status = booking.getBookingStatus();
        double amount = booking.getTotalAmount();
        
        if ("CONFIRMED".equals(status)) {
            confirmedBookings++;
            totalRevenue += amount;
        } else if ("PENDING".equals(status)) {
            pendingBookings++;
            pendingRevenue += amount;
        } else if ("CANCELLED".equals(status)) {
            cancelledBookings++;
        }
    }
    
    // Calculate conversion rate
    double conversionRate = totalBookings > 0 ? (double) confirmedBookings / totalBookings * 100 : 0;
%>

<html>
<head>
    <title>Reports & Analytics - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .reports-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .report-header {
            text-align: center;
            margin-bottom: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
        }
        
        .report-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .report-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            border-left: 5px solid #007bff;
        }
        
        .report-card.revenue {
            border-left-color: #28a745;
        }
        
        .report-card.bookings {
            border-left-color: #ffc107;
        }
        
        .report-card.conversion {
            border-left-color: #17a2b8;
        }
        
        .metric-number {
            font-size: 2.5em;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .metric-label {
            font-size: 1.1em;
            color: #666;
            margin-bottom: 15px;
        }
        
        .metric-detail {
            font-size: 0.9em;
            color: #888;
        }
        
        .chart-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .section-title {
            font-size: 1.4em;
            font-weight: bold;
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
        
        .data-table tr:hover {
            background: #f5f5f5;
        }
        
        .status-confirmed {
            background: #d4edda;
            color: #155724;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
        }
        
        .status-cancelled {
            background: #f8d7da;
            color: #721c24;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
        }
        
        .btn-export {
            background: #17a2b8;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            margin: 0 10px;
            display: inline-block;
            transition: background 0.3s;
        }
        
        .btn-export:hover {
            background: #138496;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .summary-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        
        .summary-value {
            font-size: 1.5em;
            font-weight: bold;
            color: #007bff;
        }
        
        .summary-label {
            color: #666;
            margin-top: 5px;
        }
    </style>
</head>
<body>
<!-- Navigation -->
<div class="navbar">
    <h2>Trip Agency - Reports & Analytics</h2>
    <div class="nav-links">
        <a href="index.jsp">Home</a>
        <a href="admin-dashboard.jsp">Admin Dashboard</a>
        <a href="reports.jsp" class="active">Reports</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="reports-container">
    <!-- Header -->
    <div class="report-header">
        <h1>📊 Reports & Analytics Dashboard</h1>
        <p>Comprehensive business insights and performance metrics</p>
        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-value"><%= totalTrips %></div>
                <div class="summary-label">Active Trips</div>
            </div>
            <div class="summary-item">
                <div class="summary-value"><%= totalBookings %></div>
                <div class="summary-label">Total Bookings</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">$<%= currencyFormat.format(totalRevenue) %></div>
                <div class="summary-label">Total Revenue</div>
            </div>
            <div class="summary-item">
                <div class="summary-value"><%= String.format("%.1f", conversionRate) %>%</div>
                <div class="summary-label">Conversion Rate</div>
            </div>
        </div>
    </div>
    
    <!-- Key Metrics -->
    <div class="report-grid">
        <div class="report-card revenue">
            <div class="metric-number">$<%= currencyFormat.format(totalRevenue) %></div>
            <div class="metric-label">💰 Total Revenue</div>
            <div class="metric-detail">
                Confirmed bookings: $<%= currencyFormat.format(totalRevenue) %><br>
                Pending revenue: $<%= currencyFormat.format(pendingRevenue) %>
            </div>
        </div>
        
        <div class="report-card bookings">
            <div class="metric-number"><%= confirmedBookings %></div>
            <div class="metric-label">✅ Confirmed Bookings</div>
            <div class="metric-detail">
                Pending: <%= pendingBookings %><br>
                Cancelled: <%= cancelledBookings %>
            </div>
        </div>
        
        <div class="report-card conversion">
            <div class="metric-number"><%= String.format("%.1f", conversionRate) %>%</div>
            <div class="metric-label">📈 Conversion Rate</div>
            <div class="metric-detail">
                <%= confirmedBookings %> of <%= totalBookings %> bookings confirmed
            </div>
        </div>
        
        <div class="report-card">
            <div class="metric-number">$<%= totalRevenue > 0 && confirmedBookings > 0 ? currencyFormat.format(totalRevenue / confirmedBookings) : "0.00" %></div>
            <div class="metric-label">💵 Average Booking Value</div>
            <div class="metric-detail">
                Based on <%= confirmedBookings %> confirmed bookings
            </div>
        </div>
    </div>
    
    <!-- Booking Status Overview -->
    <div class="chart-section">
        <div class="section-title">📋 Booking Status Overview</div>
        <div class="report-grid">
            <div class="report-card">
                <div class="metric-number"><%= confirmedBookings %></div>
                <div class="metric-label">✅ Confirmed</div>
                <div class="metric-detail">
                    <%= totalBookings > 0 ? String.format("%.1f", (double) confirmedBookings / totalBookings * 100) : "0" %>% of total
                </div>
            </div>
            
            <div class="report-card">
                <div class="metric-number"><%= pendingBookings %></div>
                <div class="metric-label">⏳ Pending</div>
                <div class="metric-detail">
                    <%= totalBookings > 0 ? String.format("%.1f", (double) pendingBookings / totalBookings * 100) : "0" %>% of total
                </div>
            </div>
            
            <div class="report-card">
                <div class="metric-number"><%= cancelledBookings %></div>
                <div class="metric-label">❌ Cancelled</div>
                <div class="metric-detail">
                    <%= totalBookings > 0 ? String.format("%.1f", (double) cancelledBookings / totalBookings * 100) : "0" %>% of total
                </div>
            </div>
        </div>
        
        <% if (!allBookings.isEmpty()) { %>
            <h3>Recent Bookings (Last 10)</h3>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Trip</th>
                        <th>Travel Date</th>
                        <th>Participants</th>
                        <th>Amount</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                    for (int i = 0; i < Math.min(10, allBookings.size()); i++) {
                        Booking booking = allBookings.get(i);
                        String statusClass = "status-" + booking.getBookingStatus().toLowerCase();
                        
                        // Find trip name
                        String tripName = "Trip #" + booking.getTripId();
                        for (Trip trip : allTrips) {
                            if (trip.getTripId() == booking.getTripId()) {
                                tripName = trip.getTripName();
                                break;
                            }
                        }
                    %>
                        <tr>
                            <td>#<%= booking.getBookingId() %></td>
                            <td><%= tripName %></td>
                            <td><%= booking.getTravelDate() %></td>
                            <td><%= booking.getNumberOfParticipants() %></td>
                            <td>$<%= currencyFormat.format(booking.getTotalAmount()) %></td>
                            <td><span class="<%= statusClass %>"><%= booking.getBookingStatus() %></span></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
    
    <!-- Trip Summary -->
    <div class="chart-section">
        <div class="section-title">🌍 Available Trips</div>
        <% if (!allTrips.isEmpty()) { %>
            <table class="data-table">
                <thead>                    <tr>
                        <th>Trip ID</th>
                        <th>Trip Name</th>
                        <th>Destination ID</th>
                        <th>Price</th>
                        <th>Duration</th>
                        <th>Available Slots</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Trip trip : allTrips) { %>
                        <tr>
                            <td>#<%= trip.getTripId() %></td>
                            <td><%= trip.getTripName() %></td>
                            <td>Destination #<%= trip.getDestinationId() %></td>
                            <td>$<%= currencyFormat.format(trip.getPrice()) %></td>
                            <td><%= trip.getDurationDays() %> days</td>
                            <td><%= trip.getAvailableSlots() %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p>No trips available.</p>
        <% } %>
    </div>
    
    <!-- Export Options -->
    <div style="text-align: center; margin: 30px 0;">
        <h3>Export Reports</h3>
        <a href="#" class="btn-export" onclick="window.print()">🖨️ Print Report</a>
        <a href="admin-dashboard.jsp" class="btn-export">🏠 Back to Dashboard</a>
    </div>
</div>
</body>
</html>
