<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Login - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="login-container">
    <h2>Login</h2>
    <form method="post" action="login">
        <input type="text" name="username" placeholder="Username" required><br>
        <input type="password" name="password" placeholder="Password" required><br>
        <button type="submit">Login</button>
    </form>    <div class="error">
        <%= request.getAttribute("error") != null ? request.getAttribute("error") : "" %>
    </div>
    
    <div class="success" style="color: #27ae60; text-align: center; margin-top: 15px; font-size: 14px;">
        <%= request.getAttribute("success") != null ? request.getAttribute("success") : "" %>
    </div>
    
    <div style="text-align: center; margin-top: 20px;">
        <p>Don't have an account? <a href="register.jsp" style="color: #007bff; text-decoration: none;">Register here</a></p>
        <p><a href="index.jsp" style="color: #007bff; text-decoration: none;">← Back to Home</a></p>
    </div>
</div>
</body>
</html>
