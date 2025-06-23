package servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;
import dao.UserDAO;

@WebServlet("/ManageUsersServlet")
public class ManageUsersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO = new UserDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        try {
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("manage-users.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("message", "Error loading users: " + e.getMessage());
            response.sendRedirect("admin-dashboard.jsp");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("updateRole".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                String newRole = request.getParameter("role");
                
                // Prevent admin from changing their own role
                if (userId == currentUser.getUserId()) {
                    session.setAttribute("message", "You cannot change your own role!");
                } else if (userDAO.updateUserRole(userId, newRole)) {
                    session.setAttribute("message", "User role updated successfully!");
                } else {
                    session.setAttribute("message", "Failed to update user role.");
                }
            } else if ("deleteUser".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                
                // Prevent admin from deleting themselves
                if (userId == currentUser.getUserId()) {
                    session.setAttribute("message", "You cannot delete your own account!");
                } else if (userDAO.deleteUser(userId)) {
                    session.setAttribute("message", "User deleted successfully!");
                } else {
                    session.setAttribute("message", "Failed to delete user.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("message", "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            session.setAttribute("message", "Invalid user ID.");
        }
        
        response.sendRedirect("ManageUsersServlet");
    }
}
