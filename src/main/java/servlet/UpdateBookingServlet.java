package servlet;

import dao.BookingDAO;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/UpdateBookingServlet")
public class UpdateBookingServlet extends HttpServlet {
    
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
        
        String bookingIdStr = request.getParameter("id");
        String newStatus = request.getParameter("status");
        
        if (bookingIdStr == null || newStatus == null) {
            session.setAttribute("message", "Invalid booking update request.");
            response.sendRedirect("manage-bookings.jsp");
            return;
        }
        
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            
            // Validate status
            if (!newStatus.equals("CONFIRMED") && !newStatus.equals("CANCELLED") && !newStatus.equals("PENDING")) {
                session.setAttribute("message", "Invalid booking status.");
                response.sendRedirect("manage-bookings.jsp");
                return;
            }
            
            BookingDAO bookingDAO = new BookingDAO();
            boolean success = bookingDAO.updateBookingStatus(bookingId, newStatus);
            
            if (success) {
                String statusMessage = "";
                switch (newStatus) {
                    case "CONFIRMED":
                        statusMessage = "Booking #" + bookingId + " has been confirmed successfully.";
                        break;
                    case "CANCELLED":
                        statusMessage = "Booking #" + bookingId + " has been cancelled.";
                        break;
                    case "PENDING":
                        statusMessage = "Booking #" + bookingId + " status set to pending.";
                        break;
                }
                session.setAttribute("message", statusMessage);
            } else {
                session.setAttribute("message", "Failed to update booking status. Booking may not exist.");
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("message", "Invalid booking ID format.");
        } catch (SQLException e) {
            session.setAttribute("message", "Database error: " + e.getMessage());
        } catch (Exception e) {
            session.setAttribute("message", "An unexpected error occurred: " + e.getMessage());
        }
        
        response.sendRedirect("manage-bookings.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
