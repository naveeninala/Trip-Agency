package servlet;

import dao.TripDAO;
import model.Trip;
import model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet("/AddTripServlet")
public class AddTripServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        try {
            // Get form parameters
            String tripName = request.getParameter("tripName");
            String destinationIdStr = request.getParameter("destinationId");
            String durationDaysStr = request.getParameter("durationDays");
            String priceStr = request.getParameter("price");
            String activityType = request.getParameter("activityType");
            String description = request.getParameter("description");
            String maxParticipantsStr = request.getParameter("maxParticipants");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String imageUrl = request.getParameter("imageUrl");
            
            // Validate required fields
            if (tripName == null || tripName.trim().isEmpty() ||
                destinationIdStr == null || destinationIdStr.trim().isEmpty() ||
                durationDaysStr == null || durationDaysStr.trim().isEmpty() ||
                priceStr == null || priceStr.trim().isEmpty() ||
                activityType == null || activityType.trim().isEmpty() ||
                maxParticipantsStr == null || maxParticipantsStr.trim().isEmpty() ||
                startDateStr == null || startDateStr.trim().isEmpty() ||
                endDateStr == null || endDateStr.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "All required fields must be filled.");
                request.getRequestDispatcher("add-trip.jsp").forward(request, response);
                return;
            }
            
            // Parse numeric values
            int destinationId = Integer.parseInt(destinationIdStr);
            int durationDays = Integer.parseInt(durationDaysStr);
            double price = Double.parseDouble(priceStr);
            int maxParticipants = Integer.parseInt(maxParticipantsStr);
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);
            
            // Validate business rules
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                request.getRequestDispatcher("add-trip.jsp").forward(request, response);
                return;
            }
            
            if (maxParticipants <= 0) {
                request.setAttribute("errorMessage", "Maximum participants must be greater than 0.");
                request.getRequestDispatcher("add-trip.jsp").forward(request, response);
                return;
            }
            
            if (endDate.before(startDate) || endDate.equals(startDate)) {
                request.setAttribute("errorMessage", "End date must be after start date.");
                request.getRequestDispatcher("add-trip.jsp").forward(request, response);
                return;
            }
            
            // Create Trip object
            Trip trip = new Trip();
            trip.setTripName(tripName.trim());
            trip.setDestinationId(destinationId);
            trip.setDurationDays(durationDays);
            trip.setPrice(price);
            trip.setActivityType(activityType);
            trip.setDescription(description != null ? description.trim() : "");
            trip.setMaxParticipants(maxParticipants);
            trip.setAvailableSlots(maxParticipants); // Initially all slots are available
            trip.setStartDate(startDate);
            trip.setEndDate(endDate);
            trip.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
            trip.setActive(true);
            
            // Save trip to database
            TripDAO tripDAO = new TripDAO();
            boolean success = tripDAO.addTrip(trip);
            
            if (success) {
                session.setAttribute("message", "Trip '" + tripName + "' has been added successfully!");
                response.sendRedirect("admin-dashboard.jsp");
            } else {
                request.setAttribute("errorMessage", "Failed to add trip. Please try again.");
                request.getRequestDispatcher("add-trip.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format in one of the fields.");
            request.getRequestDispatcher("add-trip.jsp").forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Invalid date format. Please use YYYY-MM-DD format.");
            request.getRequestDispatcher("add-trip.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("add-trip.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("add-trip.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to the add trip form
        response.sendRedirect("add-trip.jsp");
    }
}
