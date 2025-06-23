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
    
    // Get users from request attribute (set by servlet)
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) {
        response.sendRedirect("ManageUsersServlet");
        return;
    }
    
    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
    
    // Check for edit mode
    String editUserIdParam = request.getParameter("editUserId");
    String editUsername = request.getParameter("editUsername");
    String editRole = request.getParameter("editRole");
    boolean isEditMode = editUserIdParam != null;
    int editUserId = 0;
    if (isEditMode) {
        try {
            editUserId = Integer.parseInt(editUserIdParam);
        } catch (NumberFormatException e) {
            isEditMode = false;
        }
    }
%>
<html>
<head>
    <title>Manage Users - Admin Panel</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .manage-users-container {
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
        
        .btn-secondary {
            background: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            transition: background 0.3s;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .users-table {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th {
            background: #f8f9fa;
            padding: 15px;
            text-align: left;
            font-weight: bold;
            border-bottom: 2px solid #e9ecef;
        }
        
        .table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e9ecef;
            vertical-align: middle;
        }
        
        .table tr:hover {
            background: #f8f9fa;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .role-admin {
            background: #dc3545;
            color: white;
        }
        
        .role-user {
            background: #28a745;
            color: white;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.3s;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #212529;
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
        
        .btn-primary {
            background: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: bold;
        }
        
        .btn-primary:hover {
            background: #0056b3;
        }
        
        .alert {
            padding: 12px 20px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        
        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        
        .alert-info {
            color: #0c5460;
            background-color: #d1ecf1;
            border-color: #bee5eb;
        }
        
        .statistics {
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
            font-size: 14px;
        }
        
        .edit-form {
            background: #f8f9fa;
            border: 2px solid #007bff;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
            max-width: 200px;
        }
    </style>
</head>
<body>
    <div class="manage-users-container">
        <div class="page-header">
            <h1>👥 User Management</h1>
            <p>Manage user accounts and roles</p>
        </div>
        
        <% if (message != null) { %>
            <div class="alert <%= message.contains("success") ? "alert-success" : message.contains("Error") || message.contains("Failed") ? "alert-danger" : "alert-info" %>">
                <%= message %>
            </div>
        <% } %>
        
        <!-- Edit Role Form (shown when edit is requested) -->
        <% if (isEditMode) { %>
            <div class="edit-form">
                <h3>Edit User Role</h3>
                <form method="post" action="ManageUsersServlet">
                    <input type="hidden" name="action" value="updateRole">
                    <input type="hidden" name="userId" value="<%= editUserId %>">
                    
                    <div class="form-group">
                        <label>Username:</label>
                        <strong><%= editUsername %></strong>
                    </div>
                    
                    <div class="form-group">
                        <label for="role">New Role:</label>
                        <select name="role" id="role" class="form-control" required>
                            <option value="USER" <%= "USER".equals(editRole) ? "selected" : "" %>>USER</option>
                            <option value="ADMIN" <%= "ADMIN".equals(editRole) ? "selected" : "" %>>ADMIN</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="btn-primary">Update Role</button>
                    <a href="ManageUsersServlet" class="btn-secondary" style="margin-left: 10px;">Cancel</a>
                </form>
            </div>
        <% } %>
        
        <!-- Statistics -->
        <div class="statistics">
            <div class="stat-card">
                <div class="stat-number"><%= users.size() %></div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">
                    <%
                    int adminCount = 0;
                    for (User u : users) {
                        if ("ADMIN".equals(u.getRole())) adminCount++;
                    }
                    %>
                    <%= adminCount %>
                </div>
                <div class="stat-label">Administrators</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">
                    <%
                    int userCount = 0;
                    for (User u : users) {
                        if ("USER".equals(u.getRole())) userCount++;
                    }
                    %>
                    <%= userCount %>
                </div>
                <div class="stat-label">Regular Users</div>
            </div>
        </div>
        
        <div class="action-bar">
            <h2>All Users</h2>
            <a href="admin-dashboard.jsp" class="btn-secondary">← Back to Dashboard</a>
        </div>
        
        <div class="users-table">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Role</th>
                        <th>Created At</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (users.isEmpty()) { %>
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 40px; color: #666;">
                                No users found in the system.
                            </td>
                        </tr>
                    <% } else { %>
                        <% for (User user : users) { %>
                            <tr>
                                <td><%= user.getUserId() %></td>
                                <td><strong><%= user.getUsername() %></strong></td>
                                <td><%= user.getFullName() != null ? user.getFullName() : "N/A" %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getPhone() != null ? user.getPhone() : "N/A" %></td>
                                <td>
                                    <span class="role-badge role-<%= user.getRole().toLowerCase() %>">
                                        <%= user.getRole() %>
                                    </span>
                                </td>
                                <td><%= user.getCreatedAt() != null ? user.getCreatedAt().toString().substring(0, 10) : "N/A" %></td>
                                <td>
                                    <div class="action-buttons">
                                        <% if (user.getUserId() != currentUser.getUserId()) { %>
                                            <a href="manage-users.jsp?editUserId=<%= user.getUserId() %>&editUsername=<%= user.getUsername() %>&editRole=<%= user.getRole() %>" class="btn-sm btn-warning">
                                                Edit Role
                                            </a>
                                            <form method="post" action="ManageUsersServlet" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete user <%= user.getUsername() %>? This action cannot be undone.')">
                                                <input type="hidden" name="action" value="deleteUser">
                                                <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                                <button type="submit" class="btn-sm btn-danger">Delete</button>
                                            </form>
                                        <% } else { %>
                                            <span style="color: #666; font-style: italic;">Current User</span>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Navigation Links -->
        <div style="margin-top: 30px; text-align: center;">
            <% if (currentUser != null && "ADMIN".equals(currentUser.getRole())) { %>
                <span style="background: linear-gradient(135deg, #007bff, #0056b3); color: white; padding: 10px 20px; border-radius: 25px; margin: 5px; display: inline-block;">
                    🏠 <a href="admin-dashboard.jsp" style="color: white; text-decoration: none;">Admin Panel</a>
                </span>
            <% } %>
            <span style="background: linear-gradient(135deg, #28a745, #1e7e34); color: white; padding: 10px 20px; border-radius: 25px; margin: 5px; display: inline-block;">
                🏠 <a href="dashboard.jsp" style="color: white; text-decoration: none;">Dashboard</a>
            </span>
            <span style="background: linear-gradient(135deg, #6c757d, #545b62); color: white; padding: 10px 20px; border-radius: 25px; margin: 5px; display: inline-block;">
                🚪 <a href="LogoutServlet" style="color: white; text-decoration: none;">Logout</a>
            </span>
        </div>
    </div>
</body>
</html>
