package servlet;

import dao.UserDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        
        UserDAO userDAO = new UserDAO();
        
        try {
            // Validation
            if (username == null || username.trim().isEmpty()) {
                request.setAttribute("error", "Username is required");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            if (password == null || password.length() < 6) {
                request.setAttribute("error", "Password must be at least 6 characters long");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Passwords do not match");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            if (email == null || email.trim().isEmpty() || !email.contains("@")) {
                request.setAttribute("error", "Valid email is required");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("error", "Full name is required");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check if username already exists
            if (userDAO.isUsernameExists(username)) {
                request.setAttribute("error", "Username already exists");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists
            if (userDAO.isEmailExists(email)) {
                request.setAttribute("error", "Email already registered");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Create new user
            User newUser = new User();
            newUser.setUsername(username.trim());
            newUser.setPassword(password); // In production, hash the password
            newUser.setEmail(email.trim());
            newUser.setFullName(fullName.trim());
            newUser.setPhone(phone != null ? phone.trim() : "");
            newUser.setRole("USER");
            
            // Register the user
            boolean success = userDAO.registerUser(newUser);
            
            if (success) {
                // Auto-login after successful registration
                User registeredUser = userDAO.login(username, password);
                if (registeredUser != null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("user", registeredUser);
                    session.setAttribute("message", "Registration successful! Welcome to Trip Agency!");
                    response.sendRedirect("index.jsp");
                } else {
                    request.setAttribute("success", "Registration successful! Please login.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
