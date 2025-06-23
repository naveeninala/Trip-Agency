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
    
    TripDAO tripDAO = new TripDAO();
    List<Trip> allTrips = tripDAO.getAllTrips();
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
%>
<html>
<head>
    <title>Manage Trips - Admin Panel</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .manage-trips-container {
            max-width: 1200px;
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
        
        .btn-primary {
            background: #007bff;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            transition: background 0.3s;
        }
        
        .btn-primary:hover {
            background: #0056b3;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            margin-right: 5px;
            transition: background 0.3s;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-danger:hover {
            background: #c82333;
        }
        
        .trips-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
        }
        
        .trip-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.3s;
        }
        
        .trip-card:hover {
            transform: translateY(-5px);
        }
        
        .trip-image {
            width: 100%;
            height: 200px;
            background: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #666;
            font-size: 18px;
        }
        
        .trip-content {
            padding: 20px;
        }
        
        .trip-title {
            font-size: 1.3em;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        
        .trip-details {
            margin-bottom: 15px;
        }
        
        .trip-detail {
            margin-bottom: 8px;
            color: #666;
        }
        
        .trip-price {
            font-size: 1.5em;
            font-weight: bold;
            color: #007bff;
            margin-bottom: 15px;
        }
        
        .trip-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: bold;
        }
        
        .status-active {
            background: #d4edda;
            color: #155724;
        }
        
        .status-inactive {
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
        
        .no-trips {
            text-align: center;
            padding: 60px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .no-trips h3 {
            color: #666;
            margin-bottom: 15px;
        }
        
        @media (max-width: 768px) {
            .action-bar {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
            
            .trips-grid {
                grid-template-columns: 1fr;
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

<div class="manage-trips-container">
    <div class="page-header">
        <h1>🌍 Manage Trips</h1>
        <p>View, edit, and manage all travel packages</p>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <%= message %>
        </div>
    <% } %>
    
    <div class="action-bar">
        <div>
            <h3>Total Trips: <%= allTrips.size() %></h3>
        </div>
        <div>
            <a href="add-trip.jsp" class="btn-primary">+ Add New Trip</a>
            <a href="admin-dashboard.jsp" class="btn-secondary">← Back to Dashboard</a>
        </div>
    </div>
    
    <% if (allTrips.isEmpty()) { %>
        <div class="no-trips">
            <h3>No trips found</h3>
            <p>Start by adding your first trip package!</p>
            <a href="add-trip.jsp" class="btn-primary" style="margin-top: 20px;">Add First Trip</a>
        </div>
    <% } else { %>
        <div class="trips-grid">
            <% for (Trip trip : allTrips) { %>
                <div class="trip-card">
                    <div class="trip-image">
                        <% if (trip.getImageUrl() != null && !trip.getImageUrl().trim().isEmpty()) { %>
                            <img src="<%= trip.getImageUrl() %>" alt="<%= trip.getTripName() %>" 
                                 style="width: 100%; height: 100%; object-fit: cover;"
                                 onerror="this.style.display='none'; this.parentNode.innerHTML='📷 No Image';">
                        <% } else { %>
                            📷 No Image
                        <% } %>
                    </div>
                    
                    <div class="trip-content">
                        <div class="trip-title"><%= trip.getTripName() %></div>
                        
                        <div class="trip-details">
                            <div class="trip-detail">
                                <strong>ID:</strong> <%= trip.getTripId() %>
                                <span class="status-badge <%= trip.isActive() ? "status-active" : "status-inactive" %>">
                                    <%= trip.isActive() ? "Active" : "Inactive" %>
                                </span>
                            </div>
                            <div class="trip-detail"><strong>Destination ID:</strong> <%= trip.getDestinationId() %></div>
                            <div class="trip-detail"><strong>Duration:</strong> <%= trip.getDurationDays() %> days</div>
                            <div class="trip-detail"><strong>Activity:</strong> <%= trip.getActivityType() %></div>
                            <div class="trip-detail"><strong>Max Participants:</strong> <%= trip.getMaxParticipants() %></div>
                            <div class="trip-detail"><strong>Available Slots:</strong> <%= trip.getAvailableSlots() %></div>
                            <% if (trip.getStartDate() != null && trip.getEndDate() != null) { %>
                                <div class="trip-detail"><strong>Dates:</strong> <%= trip.getStartDate() %> to <%= trip.getEndDate() %></div>
                            <% } %>
                        </div>
                        
                        <div class="trip-price">$<%= String.format("%.2f", trip.getPrice()) %></div>
                        
                        <div class="trip-actions">
                            <a href="edit-trip.jsp?id=<%= trip.getTripId() %>" class="btn-secondary">✏️ Edit</a>
                            <a href="trip-details.jsp?id=<%= trip.getTripId() %>" class="btn-secondary">👁️ View</a>
                            <% if (trip.isActive()) { %>
                                <a href="DeleteTripServlet?id=<%= trip.getTripId() %>" class="btn-danger"
                                   onclick="return confirm('Are you sure you want to deactivate this trip?')">
                                    🗑️ Deactivate
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    <% } %>
</div>
</body>
</html>
