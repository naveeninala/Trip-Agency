<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*" %>
<%@ page import="dao.*" %>
<html>
<head>
    <title>Book Trip - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .booking-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .booking-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #ecf0f1;
        }
        
        .booking-title {
            color: #2c3e50;
            font-size: 2.2em;
            margin-bottom: 10px;
        }
        
        .trip-summary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
        }
        
        .trip-summary h3 {
            margin-bottom: 15px;
            font-size: 1.5em;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .summary-item {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 8px;
        }
        
        .summary-label {
            font-size: 0.9em;
            opacity: 0.8;
            margin-bottom: 5px;
        }
        
        .summary-value {
            font-size: 1.2em;
            font-weight: 600;
        }
        
        .booking-form {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 12px;
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #2c3e50;
            font-size: 1.3em;
            margin-bottom: 20px;
            font-weight: 600;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 1em;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .price-calculation {
            background: white;
            padding: 25px;
            border-radius: 12px;
            border: 2px solid #27ae60;
            margin: 20px 0;
        }
        
        .price-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 8px 0;
        }
        
        .price-row.total {
            border-top: 2px solid #27ae60;
            margin-top: 15px;
            padding-top: 15px;
            font-weight: 700;
            font-size: 1.3em;
            color: #27ae60;
        }
        
        .booking-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn-booking {
            padding: 15px 30px;
            font-size: 1.1em;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .btn-book {
            background: #27ae60;
            color: white;
        }
        
        .btn-book:hover {
            background: #219a52;
            transform: translateY(-2px);
        }
        
        .btn-cancel {
            background: #95a5a6;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #7f8c8d;
        }
        
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
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
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .booking-actions {
                flex-direction: column;
                align-items: center;
            }
            
            .summary-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<%
    User currentUser = (User) session.getAttribute("user");
    
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String tripIdParam = request.getParameter("tripId");
    Trip trip = null;
    String errorMessage = null;
    
    if (tripIdParam != null) {
        try {
            int tripId = Integer.parseInt(tripIdParam);
            TripDAO tripDAO = new TripDAO();
            trip = tripDAO.getTripById(tripId);
            
            if (trip == null) {
                errorMessage = "Trip not found.";
            } else if (trip.getAvailableSlots() <= 0) {
                errorMessage = "This trip is sold out.";
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
        <a href="index.jsp">Home</a>        <a href="dashboard.jsp">My Dashboard</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <% if ("ADMIN".equals(currentUser.getRole())) { %>
            <a href="admin-dashboard.jsp">Admin Panel</a>
        <% } %>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="booking-container">
    <a href="javascript:history.back()" class="back-link">← Back</a>
    
    <div class="booking-header">
        <h1 class="booking-title">Book Your Trip</h1>
        <p>Complete your booking details below</p>
    </div>
    
    <% if (errorMessage != null) { %>
        <div class="error-message">
            <h3>Booking Not Available</h3>
            <p><%= errorMessage %></p>
            <a href="index.jsp" class="btn-booking btn-book" style="margin-top: 15px;">Browse All Trips</a>
        </div>
    <% } else { %>
        <div class="trip-summary">
            <h3><%= trip.getTripName() %></h3>
            <div class="summary-grid">
                <div class="summary-item">
                    <div class="summary-label">Price per Person</div>
                    <div class="summary-value">$<%= String.format("%.2f", trip.getPrice()) %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Duration</div>
                    <div class="summary-value"><%= trip.getDurationDays() %> Days</div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Activity Type</div>
                    <div class="summary-value"><%= trip.getActivityType() %></div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Available Spots</div>
                    <div class="summary-value"><%= trip.getAvailableSlots() %> Left</div>
                </div>
            </div>
        </div>
        
        <form action="BookingServlet" method="post" class="booking-form">
            <input type="hidden" name="tripId" value="<%= trip.getTripId() %>" />
            <input type="hidden" name="userId" value="<%= currentUser.getUserId() %>" />
            
            <div class="form-section">
                <h3 class="section-title">Booking Details</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="travelDate">Preferred Travel Date *</label>
                        <input type="date" id="travelDate" name="travelDate" required 
                               min="<%= java.time.LocalDate.now().plusDays(1) %>" />
                    </div>
                    
                    <div class="form-group">
                        <label for="participants">Number of Participants *</label>
                        <select id="participants" name="participants" required onchange="calculateTotal()">
                            <option value="">Select participants</option>
                            <% for (int i = 1; i <= Math.min(trip.getAvailableSlots(), trip.getMaxParticipants()); i++) { %>
                                <option value="<%= i %>"><%= i %> <%= i == 1 ? "Person" : "People" %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
            </div>
            
            <div class="form-section">
                <h3 class="section-title">Traveller Information</h3>
                <div class="form-group full-width">
                    <label for="travellerDetails">Traveller Details *</label>
                    <textarea id="travellerDetails" name="travellerDetails" required
                              placeholder="Please provide full names, ages, and any relevant information for all travellers..."></textarea>
                </div>
                
                <div class="form-group full-width">
                    <label for="specialRequests">Special Requests (Optional)</label>
                    <textarea id="specialRequests" name="specialRequests"
                              placeholder="Any dietary restrictions, accessibility needs, or special occasions..."></textarea>
                </div>
            </div>
            
            <div class="price-calculation">
                <h3 style="margin-bottom: 15px; color: #27ae60;">Price Breakdown</h3>
                <div class="price-row">
                    <span>Price per person:</span>
                    <span>$<%= String.format("%.2f", trip.getPrice()) %></span>
                </div>
                <div class="price-row">
                    <span>Number of participants:</span>
                    <span id="participantCount">0</span>
                </div>
                <div class="price-row total">
                    <span>Total Amount:</span>
                    <span id="totalAmount">$0.00</span>
                </div>
            </div>
            
            <div class="booking-actions">
                <button type="submit" class="btn-booking btn-book">
                    Confirm Booking
                </button>
                <a href="trip-details.jsp?id=<%= trip.getTripId() %>" class="btn-booking btn-cancel">
                    Cancel
                </a>
            </div>
        </form>
    <% } %>
</div>

<footer>
    <p>&copy; 2025 Trip Agency Management System. All rights reserved.</p>
</footer>

<script>
function calculateTotal() {
    const participants = document.getElementById('participants').value;
    const pricePerPerson = <%= trip.getPrice() %>;
    
    if (participants) {
        const total = participants * pricePerPerson;
        document.getElementById('participantCount').textContent = participants;
        document.getElementById('totalAmount').textContent = '$' + total.toFixed(2);
    } else {
        document.getElementById('participantCount').textContent = '0';
        document.getElementById('totalAmount').textContent = '$0.00';
    }
}
</script>
</body>
</html>
