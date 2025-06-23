<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<html>
<head>
    <title>Trip Details - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .trip-details-container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .trip-hero {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .trip-image-large {
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            height: 400px;
        }
        
        .trip-image-large img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .trip-main-info {
            padding: 20px 0;
        }
        
        .trip-title {
            font-size: 2.5em;
            color: #2c3e50;
            margin-bottom: 15px;
            font-weight: 700;
        }
        
        .trip-price {
            font-size: 2em;
            color: #e74c3c;
            font-weight: bold;
            margin-bottom: 20px;
        }
        
        .trip-specs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .spec-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #3498db;
        }
        
        .spec-label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .spec-value {
            font-size: 1.1em;
            color: #34495e;
            margin-top: 5px;
        }
        
        .trip-description {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 12px;
            margin: 30px 0;
            line-height: 1.8;
            font-size: 1.1em;
            color: #2c3e50;
        }
        
        .booking-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            margin-top: 30px;
        }
        
        .booking-section h3 {
            margin-bottom: 20px;
            font-size: 1.5em;
        }
        
        .booking-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn-large {
            padding: 15px 30px;
            font-size: 1.1em;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn-primary {
            background: #27ae60;
            color: white;
        }
        
        .btn-primary:hover {
            background: #219a52;
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 2px solid rgba(255,255,255,0.3);
        }
        
        .btn-secondary:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .availability-status {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9em;
        }
        
        .status-available {
            background: #d4edda;
            color: #155724;
        }
        
        .status-limited {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-sold-out {
            background: #f8d7da;
            color: #721c24;
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #3498db;
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link:hover {
            color: #2980b9;
        }
        
        @media (max-width: 768px) {
            .trip-hero {
                grid-template-columns: 1fr;
            }
            
            .trip-specs {
                grid-template-columns: 1fr;
            }
            
            .booking-actions {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
<%
    User currentUser = (User) session.getAttribute("user");
    
    String tripIdParam = request.getParameter("id");
    Trip trip = null;
    String errorMessage = null;
    
    if (tripIdParam != null) {
        try {
            int tripId = Integer.parseInt(tripIdParam);
            TripDAO tripDAO = new TripDAO();
            trip = tripDAO.getTripById(tripId);
            
            if (trip == null) {
                errorMessage = "Trip not found.";
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid trip ID.";
        } catch (Exception e) {
            errorMessage = "Error loading trip details: " + e.getMessage();
        }
    } else {
        errorMessage = "No trip ID provided.";
    }
%>

<div class="navbar">
    <h2>Trip Agency</h2>
    <div class="nav-links">
        <a href="index.jsp">Home</a>        <% if (currentUser != null) { %>
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

<div class="trip-details-container">
    <a href="index.jsp" class="back-link">← Back to Trip Listings</a>
    
    <% if (errorMessage != null) { %>
        <div style="background: #f8d7da; color: #721c24; padding: 20px; border-radius: 8px; text-align: center;">
            <h3>Error</h3>
            <p><%= errorMessage %></p>
            <a href="index.jsp" class="btn btn-primary" style="margin-top: 15px;">Browse All Trips</a>
        </div>
    <% } else { %>
        <div class="trip-hero">
            <div class="trip-image-large">
                <img src="https://plus.unsplash.com/premium_photo-1661919210043-fd847a58522d?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D" 
                     alt="<%= trip.getTripName() %>" />
            </div>
            
            <div class="trip-main-info">
                <h1 class="trip-title"><%= trip.getTripName() %></h1>
                <div class="trip-price">$<%= String.format("%.2f", trip.getPrice()) %></div>
                
                <div class="trip-specs">
                    <div class="spec-item">
                        <div class="spec-label">Duration</div>
                        <div class="spec-value"><%= trip.getDurationDays() %> Days</div>
                    </div>
                    
                    <div class="spec-item">
                        <div class="spec-label">Activity Type</div>
                        <div class="spec-value"><%= trip.getActivityType() %></div>
                    </div>
                    
                    <div class="spec-item">
                        <div class="spec-label">Max Participants</div>
                        <div class="spec-value"><%= trip.getMaxParticipants() %> People</div>
                    </div>
                    
                    <div class="spec-item">
                        <div class="spec-label">Availability</div>
                        <div class="spec-value">
                            <% if (trip.getAvailableSlots() > 5) { %>
                                <span class="availability-status status-available">
                                    <%= trip.getAvailableSlots() %> Spots Available
                                </span>
                            <% } else if (trip.getAvailableSlots() > 0) { %>
                                <span class="availability-status status-limited">
                                    Only <%= trip.getAvailableSlots() %> Spots Left!
                                </span>
                            <% } else { %>
                                <span class="availability-status status-sold-out">
                                    SOLD OUT
                                </span>
                            <% } %>
                        </div>
                    </div>
                </div>
                
                <% if (trip.getStartDate() != null && trip.getEndDate() != null) { %>
                    <div class="spec-item" style="grid-column: 1 / -1; margin-top: 15px;">
                        <div class="spec-label">Tour Dates</div>
                        <div class="spec-value">
                            <%= trip.getStartDate() %> to <%= trip.getEndDate() %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        
        <% if (trip.getDescription() != null && !trip.getDescription().isEmpty()) { %>
            <div class="trip-description">
                <h3 style="margin-bottom: 15px; color: #2c3e50;">About This Trip</h3>
                <p><%= trip.getDescription() %></p>
            </div>
        <% } %>
        
        <div class="booking-section">
            <h3>Ready to Book Your Adventure?</h3>
            <p style="margin-bottom: 25px; opacity: 0.9;">
                Join us for an unforgettable experience. Book now to secure your spot!
            </p>
            
            <div class="booking-actions">
                <% if (currentUser != null) { %>
                    <% if (trip.getAvailableSlots() > 0) { %>
                        <a href="booking.jsp?tripId=<%= trip.getTripId() %>" class="btn-large btn-primary">
                            Book This Trip Now
                        </a>
                    <% } else { %>
                        <button class="btn-large" style="background: #95a5a6; color: white; cursor: not-allowed;">
                            Sold Out
                        </button>
                    <% } %>
                    <a href="index.jsp" class="btn-large btn-secondary">Browse More Trips</a>
                <% } else { %>
                    <a href="login.jsp" class="btn-large btn-primary">Login to Book</a>
                    <a href="register.jsp" class="btn-large btn-secondary">Create Account</a>
                <% } %>
            </div>
        </div>
    <% } %>
</div>

<footer>
    <p>&copy; 2025 Trip Agency Management System. All rights reserved.</p>
</footer>
</body>
</html>
