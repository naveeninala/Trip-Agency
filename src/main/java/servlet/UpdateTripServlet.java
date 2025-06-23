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

@WebServlet("/UpdateTripServlet")
public class UpdateTripServlet extends HttpServlet {
    
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
            String tripIdStr = request.getParameter("tripId");
            String tripName = request.getParameter("tripName");
            String destinationIdStr = request.getParameter("destinationId");
            String durationDaysStr = request.getParameter("durationDays");
            String priceStr = request.getParameter("price");
            String activityType = request.getParameter("activityType");
            String description = request.getParameter("description");
            String maxParticipantsStr = request.getParameter("maxParticipants");
            String availableSlotsStr = request.getParameter("availableSlots");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String imageUrl = request.getParameter("imageUrl");
            String isActiveStr = request.getParameter("isActive");
            
            // Validate required fields
            if (tripIdStr == null || tripName == null || tripName.trim().isEmpty() ||
                destinationIdStr == null || durationDaysStr == null ||
                priceStr == null || activityType == null ||
                maxParticipantsStr == null || availableSlotsStr == null ||
                startDateStr == null || endDateStr == null || isActiveStr == null) {
                
                request.setAttribute("errorMessage", "All required fields must be filled.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
                return;
            }
            
            // Parse values
            int tripId = Integer.parseInt(tripIdStr);
            int destinationId = Integer.parseInt(destinationIdStr);
            int durationDays = Integer.parseInt(durationDaysStr);
            double price = Double.parseDouble(priceStr);
            int maxParticipants = Integer.parseInt(maxParticipantsStr);
            int availableSlots = Integer.parseInt(availableSlotsStr);
            Date startDate = Date.valueOf(startDateStr);
            Date endDate = Date.valueOf(endDateStr);
            boolean isActive = Boolean.parseBoolean(isActiveStr);
            
            // Validate business rules
            if (price <= 0) {
                request.setAttribute("errorMessage", "Price must be greater than 0.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
                return;
            }
            
            if (maxParticipants <= 0) {
                request.setAttribute("errorMessage", "Maximum participants must be greater than 0.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
                return;
            }
            
            if (availableSlots < 0 || availableSlots > maxParticipants) {
                request.setAttribute("errorMessage", "Available slots must be between 0 and maximum participants.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
                return;
            }
            
            if (endDate.before(startDate) || endDate.equals(startDate)) {
                request.setAttribute("errorMessage", "End date must be after start date.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
                return;
            }
            
            // Create Trip object
            Trip trip = new Trip();
            trip.setTripId(tripId);
            trip.setTripName(tripName.trim());
            trip.setDestinationId(destinationId);
            trip.setDurationDays(durationDays);
            trip.setPrice(price);
            trip.setActivityType(activityType);
            trip.setDescription(description != null ? description.trim() : "");
            trip.setMaxParticipants(maxParticipants);
            trip.setAvailableSlots(availableSlots);
            trip.setStartDate(startDate);
            trip.setEndDate(endDate);
            trip.setImageUrl(imageUrl != null ? imageUrl.trim() : "");
            trip.setActive(isActive);
            
            // Update trip in database
            TripDAO tripDAO = new TripDAO();
            boolean success = tripDAO.updateTrip(trip);
            
            if (success) {
                session.setAttribute("message", "Trip '" + tripName + "' has been updated successfully!");
                response.sendRedirect("manage-trips.jsp");
            } else {
                request.setAttribute("errorMessage", "Failed to update trip. Please try again.");
                request.getRequestDispatcher("edit-trip.jsp?id=" + tripIdStr).forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format in one of the fields.");
            String tripId = request.getParameter("tripId");
            request.getRequestDispatcher("edit-trip.jsp?id=" + tripId).forward(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", "Invalid date format. Please use YYYY-MM-DD format.");
            String tripId = request.getParameter("tripId");
            request.getRequestDispatcher("edit-trip.jsp?id=" + tripId).forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            String tripId = request.getParameter("tripId");
            request.getRequestDispatcher("edit-trip.jsp?id=" + tripId).forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            String tripId = request.getParameter("tripId");
            request.getRequestDispatcher("edit-trip.jsp?id=" + tripId).forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to manage trips
        response.sendRedirect("manage-trips.jsp");
    }
}
