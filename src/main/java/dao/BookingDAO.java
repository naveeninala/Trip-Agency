package dao;

import model.Booking;
import model.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {
    public boolean insertBooking(Booking booking) throws SQLException {
        String sql = "INSERT INTO bookings (user_id, trip_id, travel_date, number_of_participants, total_amount, booking_status, traveller_details, special_requests) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, booking.getUserId());
            stmt.setInt(2, booking.getTripId());
            stmt.setDate(3, booking.getTravelDate());
            stmt.setInt(4, booking.getNumberOfParticipants());
            stmt.setDouble(5, booking.getTotalAmount());
            stmt.setString(6, booking.getBookingStatus());
            stmt.setString(7, booking.getTravellerDetails());
            stmt.setString(8, booking.getSpecialRequests());
            int rows = stmt.executeUpdate();
            return rows > 0;
        }
    }

    public List<Booking> getBookingsByUserId(int userId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setTripId(rs.getInt("trip_id"));
                booking.setBookingDate(rs.getTimestamp("booking_date"));
                booking.setTravelDate(rs.getDate("travel_date"));
                booking.setNumberOfParticipants(rs.getInt("number_of_participants"));
                booking.setTotalAmount(rs.getDouble("total_amount"));
                booking.setBookingStatus(rs.getString("booking_status"));
                booking.setTravellerDetails(rs.getString("traveller_details"));
                booking.setSpecialRequests(rs.getString("special_requests"));
                bookings.add(booking);
            }
        }
        return bookings;
    }
    
    public boolean createBooking(Booking booking) throws SQLException {
        String sql = "INSERT INTO bookings (user_id, trip_id, booking_date, travel_date, number_of_participants, total_amount, booking_status, traveller_details, special_requests) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, booking.getUserId());
            stmt.setInt(2, booking.getTripId());
            stmt.setTimestamp(3, booking.getBookingDate());
            stmt.setDate(4, booking.getTravelDate());
            stmt.setInt(5, booking.getNumberOfParticipants());
            stmt.setDouble(6, booking.getTotalAmount());
            stmt.setString(7, booking.getBookingStatus());
            stmt.setString(8, booking.getTravellerDetails());
            stmt.setString(9, booking.getSpecialRequests());
            return stmt.executeUpdate() > 0;
        }
    }
    
    public List<Booking> getAllBookings() throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM bookings ORDER BY booking_date DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Booking booking = new Booking();
                booking.setBookingId(rs.getInt("booking_id"));
                booking.setUserId(rs.getInt("user_id"));
                booking.setTripId(rs.getInt("trip_id"));
                booking.setBookingDate(rs.getTimestamp("booking_date"));
                booking.setTravelDate(rs.getDate("travel_date"));
                booking.setNumberOfParticipants(rs.getInt("number_of_participants"));
                booking.setTotalAmount(rs.getDouble("total_amount"));
                booking.setBookingStatus(rs.getString("booking_status"));
                booking.setTravellerDetails(rs.getString("traveller_details"));
                booking.setSpecialRequests(rs.getString("special_requests"));
                bookings.add(booking);
            }
        }
        return bookings;
    }
    
    public boolean updateBookingStatus(int bookingId, String status) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = ? WHERE booking_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, bookingId);
            return stmt.executeUpdate() > 0;
        }
    }
}
