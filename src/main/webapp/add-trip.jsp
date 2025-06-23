<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    
    // Check if user is logged in and is an admin
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String errorMessage = (String) request.getAttribute("errorMessage");
    String successMessage = (String) request.getAttribute("successMessage");
%>
<html>
<head>
    <title>Add New Trip - Admin Panel</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .add-trip-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .form-header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
            background: linear-gradient(135deg, #007bff, #0056b3);
            color: white;
            border-radius: 12px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        
        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        
        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: #007bff;
        }
        
        .form-textarea {
            resize: vertical;
            height: 100px;
        }
        
        .btn-submit {
            background: #007bff;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s;
            width: 100%;
        }
        
        .btn-submit:hover {
            background: #0056b3;
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            display: inline-block;
            margin-right: 10px;
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
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            align-items: center;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .form-row {
                flex-direction: column;
                align-items: stretch;
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

<div class="add-trip-container">
    <div class="form-header">
        <h1>🌍 Add New Trip</h1>
        <p>Create a new travel package for customers</p>
    </div>
    
    <% if (errorMessage != null) { %>
        <div class="alert alert-error">
            <%= errorMessage %>
        </div>
    <% } %>
    
    <% if (successMessage != null) { %>
        <div class="alert alert-success">
            <%= successMessage %>
        </div>
    <% } %>
    
    <form action="AddTripServlet" method="post">
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label" for="tripName">Trip Name *</label>
                <input type="text" id="tripName" name="tripName" class="form-input" required
                       placeholder="e.g., Paris Adventure Tour">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="destinationId">Destination ID *</label>
                <input type="number" id="destinationId" name="destinationId" class="form-input" required
                       placeholder="e.g., 1" min="1">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="durationDays">Duration (Days) *</label>
                <input type="number" id="durationDays" name="durationDays" class="form-input" required
                       placeholder="e.g., 7" min="1" max="365">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="price">Price (USD) *</label>
                <input type="number" id="price" name="price" class="form-input" required
                       placeholder="e.g., 1999.99" step="0.01" min="0">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="activityType">Activity Type *</label>
                <select id="activityType" name="activityType" class="form-select" required>
                    <option value="">Select Activity Type</option>
                    <option value="ADVENTURE">Adventure</option>
                    <option value="CULTURAL">Cultural</option>
                    <option value="RELAXATION">Relaxation</option>
                    <option value="BUSINESS">Business</option>
                    <option value="FAMILY">Family</option>
                    <option value="ROMANTIC">Romantic</option>
                    <option value="WILDLIFE">Wildlife</option>
                    <option value="SPORTS">Sports</option>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="maxParticipants">Max Participants *</label>
                <input type="number" id="maxParticipants" name="maxParticipants" class="form-input" required
                       placeholder="e.g., 20" min="1" max="1000">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="startDate">Start Date *</label>
                <input type="date" id="startDate" name="startDate" class="form-input" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="endDate">End Date *</label>
                <input type="date" id="endDate" name="endDate" class="form-input" required>
            </div>
            
            <div class="form-group full-width">
                <label class="form-label" for="description">Description</label>
                <textarea id="description" name="description" class="form-textarea"
                          placeholder="Describe the trip, activities, highlights, and what's included..."></textarea>
            </div>
            
            <div class="form-group full-width">
                <label class="form-label" for="imageUrl">Image URL</label>
                <input type="url" id="imageUrl" name="imageUrl" class="form-input"
                       placeholder="https://example.com/trip-image.jpg">
            </div>
        </div>
        
        <div class="form-row">
            <a href="admin-dashboard.jsp" class="btn-secondary">← Back to Dashboard</a>
            <button type="submit" class="btn-submit">✅ Create Trip</button>
        </div>
    </form>
</div>

<script>
    // Set minimum date to today
    document.getElementById('startDate').min = new Date().toISOString().split('T')[0];
    
    // Update end date minimum when start date changes
    document.getElementById('startDate').addEventListener('change', function() {
        document.getElementById('endDate').min = this.value;
    });
    
    // Form validation
    document.querySelector('form').addEventListener('submit', function(e) {
        const startDate = new Date(document.getElementById('startDate').value);
        const endDate = new Date(document.getElementById('endDate').value);
        
        if (endDate <= startDate) {
            e.preventDefault();
            alert('End date must be after start date.');
            return false;
        }
        
        const price = parseFloat(document.getElementById('price').value);
        if (price <= 0) {
            e.preventDefault();
            alert('Price must be greater than 0.');
            return false;
        }
        
        return true;
    });
</script>
</body>
</html>
