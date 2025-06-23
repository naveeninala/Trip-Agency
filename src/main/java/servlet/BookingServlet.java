package servlet;

import dao.BookingDAO;
import dao.TripDAO;
import model.Booking;
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
import java.sql.Timestamp;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Get form parameters
            int tripId = Integer.parseInt(request.getParameter("tripId"));
            int userId = currentUser.getUserId();
            Date travelDate = Date.valueOf(request.getParameter("travelDate"));
            int numberOfParticipants = Integer.parseInt(request.getParameter("participants"));
            String travellerDetails = request.getParameter("travellerDetails");
            String specialRequests = request.getParameter("specialRequests");
            
            // Validate trip availability
            TripDAO tripDAO = new TripDAO();
            Trip trip = tripDAO.getTripById(tripId);
            
            if (trip == null) {
                session.setAttribute("error", "Trip not found.");
                response.sendRedirect("index.jsp");
                return;
            }
            
            if (trip.getAvailableSlots() < numberOfParticipants) {
                session.setAttribute("error", "Not enough available slots for this trip.");
                response.sendRedirect("trip-details.jsp?id=" + tripId);
                return;
            }
            
            // Calculate total amount
            double totalAmount = trip.getPrice() * numberOfParticipants;
            
            // Create booking object
            Booking booking = new Booking();
            booking.setUserId(userId);
            booking.setTripId(tripId);
            booking.setBookingDate(new Timestamp(System.currentTimeMillis()));
            booking.setTravelDate(travelDate);
            booking.setNumberOfParticipants(numberOfParticipants);
            booking.setTotalAmount(totalAmount);
            booking.setBookingStatus("PENDING");
            booking.setTravellerDetails(travellerDetails);
            booking.setSpecialRequests(specialRequests);
            
            // Save booking to database
            BookingDAO bookingDAO = new BookingDAO();
            boolean success = bookingDAO.createBooking(booking);
            
            if (success) {
                // Update available slots for the trip
                int newAvailableSlots = trip.getAvailableSlots() - numberOfParticipants;
                tripDAO.updateAvailableSlots(tripId, newAvailableSlots);
                
                session.setAttribute("message", "Booking submitted successfully! Your booking is now pending confirmation.");
                response.sendRedirect("dashboard.jsp");
            } else {
                session.setAttribute("error", "Failed to create booking. Please try again.");
                response.sendRedirect("booking.jsp?tripId=" + tripId);
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid input data. Please check your information.");
            response.sendRedirect("booking.jsp?tripId=" + request.getParameter("tripId"));
        } catch (Exception e) {
            session.setAttribute("error", "An error occurred while processing your booking: " + e.getMessage());
            response.sendRedirect("booking.jsp?tripId=" + request.getParameter("tripId"));
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect GET requests to booking page
        String tripId = request.getParameter("tripId");
        if (tripId != null) {
            response.sendRedirect("booking.jsp?tripId=" + tripId);
        } else {
            response.sendRedirect("index.jsp");
        }
    }
}
