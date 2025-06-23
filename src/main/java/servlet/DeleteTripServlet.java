package servlet;

import dao.TripDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/DeleteTripServlet")
public class DeleteTripServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String tripIdStr = request.getParameter("id");
        
        if (tripIdStr == null) {
            session.setAttribute("message", "Invalid trip deletion request.");
            response.sendRedirect("manage-trips.jsp");
            return;
        }
        
        try {
            int tripId = Integer.parseInt(tripIdStr);
            
            TripDAO tripDAO = new TripDAO();
            boolean success = tripDAO.deleteTrip(tripId);
            
            if (success) {
                session.setAttribute("message", "Trip #" + tripId + " has been deactivated successfully.");
            } else {
                session.setAttribute("message", "Failed to deactivate trip. Trip may not exist.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("message", "Invalid trip ID format.");
        } catch (SQLException e) {
            session.setAttribute("message", "Database error: " + e.getMessage());
        } catch (Exception e) {
            session.setAttribute("message", "An unexpected error occurred: " + e.getMessage());
        }
        
        response.sendRedirect("manage-trips.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
