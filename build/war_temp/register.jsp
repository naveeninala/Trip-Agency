<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .register-container {
            max-width: 500px;
            margin: 50px auto;
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }
        
        .form-row {
            display: flex;
            gap: 15px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .success {
            color: #27ae60;
            text-align: center;
            margin-top: 15px;
            font-size: 14px;
        }
        
        .register-links {
            text-align: center;
            margin-top: 20px;
        }
        
        .register-links a {
            color: #007bff;
            text-decoration: none;
        }
        
        .register-links a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="register-container">
    <h2>Create Account</h2>
    <p style="text-align: center; color: #666; margin-bottom: 25px;">Join Trip Agency to explore amazing destinations</p>
    
    <form method="post" action="register">
        <div class="form-group">
            <label for="fullName">Full Name *</label>
            <input type="text" id="fullName" name="fullName" placeholder="Enter your full name" 
                   value="<%= request.getParameter("fullName") != null ? request.getParameter("fullName") : "" %>" required>
        </div>
        
        <div class="form-row">
            <div class="form-group">
                <label for="username">Username *</label>
                <input type="text" id="username" name="username" placeholder="Choose a username" 
                       value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" required>
            </div>
            <div class="form-group">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email" placeholder="your@email.com" 
                       value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required>
            </div>
        </div>
        
        <div class="form-group">
            <label for="phone">Phone Number</label>
            <input type="tel" id="phone" name="phone" placeholder="+1234567890" 
                   value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>">
        </div>
        
        <div class="form-row">
            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password" id="password" name="password" placeholder="Minimum 6 characters" required>
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password *</label>
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your password" required>
            </div>
        </div>
        
        <button type="submit">Create Account</button>
    </form>
    
    <div class="error">
        <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
    </div>
    
    <div class="success">
        <%= request.getAttribute("success") != null ? request.getAttribute("success") : "" %>
    </div>
    
    <div class="register-links">
        <p>Already have an account? <a href="login.jsp">Sign in here</a></p>
        <p><a href="index.jsp">← Back to Home</a></p>
    </div>
</div>

<script>
    // Simple client-side validation
    document.querySelector('form').addEventListener('submit', function(e) {
        var password = document.getElementById('password').value;
        var confirmPassword = document.getElementById('confirmPassword').value;
        
        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Passwords do not match!');
            return false;
        }
        
        if (password.length < 6) {
            e.preventDefault();
            alert('Password must be at least 6 characters long!');
            return false;
        }
    });
</script>
</body>
</html>
