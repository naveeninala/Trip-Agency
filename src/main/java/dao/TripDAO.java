package dao;

import model.Trip;
import model.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TripDAO {
    public List<Trip> getAllTrips() throws SQLException {
        List<Trip> trips = new ArrayList<>();
        String sql = "SELECT * FROM trips WHERE is_active = TRUE ORDER BY created_at DESC";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Trip trip = new Trip();
                // Set trip fields from result set
                trip.setTripId(rs.getInt("trip_id"));
                trip.setTripName(rs.getString("trip_name"));
                trip.setDestinationId(rs.getInt("destination_id"));
                trip.setDurationDays(rs.getInt("duration_days"));
                trip.setPrice(rs.getDouble("price"));
                trip.setActivityType(rs.getString("activity_type"));
                trip.setDescription(rs.getString("description"));
                trip.setMaxParticipants(rs.getInt("max_participants"));
                trip.setAvailableSlots(rs.getInt("available_slots"));
                trip.setStartDate(rs.getDate("start_date"));
                trip.setEndDate(rs.getDate("end_date"));
                trip.setImageUrl(rs.getString("image_url"));
                trip.setActive(rs.getBoolean("is_active"));
                trip.setCreatedAt(rs.getTimestamp("created_at"));
                trips.add(trip);
            }
        }
        return trips;
    }
    
    public Trip getTripById(int tripId) throws SQLException {
        String sql = "SELECT * FROM trips WHERE trip_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, tripId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Trip trip = new Trip();
                trip.setTripId(rs.getInt("trip_id"));
                trip.setTripName(rs.getString("trip_name"));
                trip.setDestinationId(rs.getInt("destination_id"));
                trip.setDurationDays(rs.getInt("duration_days"));
                trip.setPrice(rs.getDouble("price"));
                trip.setActivityType(rs.getString("activity_type"));
                trip.setDescription(rs.getString("description"));
                trip.setMaxParticipants(rs.getInt("max_participants"));
                trip.setAvailableSlots(rs.getInt("available_slots"));
                trip.setStartDate(rs.getDate("start_date"));
                trip.setEndDate(rs.getDate("end_date"));
                trip.setImageUrl(rs.getString("image_url"));
                trip.setActive(rs.getBoolean("is_active"));
                trip.setCreatedAt(rs.getTimestamp("created_at"));
                return trip;
            }
        }
        return null;
    }
    
    public List<Trip> searchTrips(String searchTerm, String activityType, Double minPrice, Double maxPrice) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM trips WHERE is_active = TRUE");
        List<Object> parameters = new ArrayList<>();
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (trip_name LIKE ? OR description LIKE ?)");
            String searchPattern = "%" + searchTerm.trim() + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        if (activityType != null && !activityType.trim().isEmpty()) {
            sql.append(" AND activity_type = ?");
            parameters.add(activityType);
        }
        
        if (minPrice != null) {
            sql.append(" AND price >= ?");
            parameters.add(minPrice);
        }
        
        if (maxPrice != null) {
            sql.append(" AND price <= ?");
            parameters.add(maxPrice);
        }
        
        sql.append(" ORDER BY created_at DESC");
        
        List<Trip> trips = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Trip trip = new Trip();
                trip.setTripId(rs.getInt("trip_id"));
                trip.setTripName(rs.getString("trip_name"));
                trip.setDestinationId(rs.getInt("destination_id"));
                trip.setDurationDays(rs.getInt("duration_days"));
                trip.setPrice(rs.getDouble("price"));
                trip.setActivityType(rs.getString("activity_type"));
                trip.setDescription(rs.getString("description"));
                trip.setMaxParticipants(rs.getInt("max_participants"));
                trip.setAvailableSlots(rs.getInt("available_slots"));
                trip.setStartDate(rs.getDate("start_date"));
                trip.setEndDate(rs.getDate("end_date"));
                trip.setImageUrl(rs.getString("image_url"));
                trip.setActive(rs.getBoolean("is_active"));
                trip.setCreatedAt(rs.getTimestamp("created_at"));
                trips.add(trip);
            }
        }
        return trips;
    }
    
    public boolean updateAvailableSlots(int tripId, int newAvailableSlots) throws SQLException {
        String sql = "UPDATE trips SET available_slots = ? WHERE trip_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, newAvailableSlots);
            stmt.setInt(2, tripId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean addTrip(Trip trip) throws SQLException {
        String sql = "INSERT INTO trips (trip_name, destination_id, duration_days, price, activity_type, description, max_participants, available_slots, start_date, end_date, image_url, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, trip.getTripName());
            stmt.setInt(2, trip.getDestinationId());
            stmt.setInt(3, trip.getDurationDays());
            stmt.setDouble(4, trip.getPrice());
            stmt.setString(5, trip.getActivityType());
            stmt.setString(6, trip.getDescription());
            stmt.setInt(7, trip.getMaxParticipants());
            stmt.setInt(8, trip.getAvailableSlots());
            stmt.setDate(9, trip.getStartDate());
            stmt.setDate(10, trip.getEndDate());
            stmt.setString(11, trip.getImageUrl());
            stmt.setBoolean(12, trip.isActive());
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean updateTrip(Trip trip) throws SQLException {
        String sql = "UPDATE trips SET trip_name = ?, destination_id = ?, duration_days = ?, price = ?, activity_type = ?, description = ?, max_participants = ?, available_slots = ?, start_date = ?, end_date = ?, image_url = ?, is_active = ? WHERE trip_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, trip.getTripName());
            stmt.setInt(2, trip.getDestinationId());
            stmt.setInt(3, trip.getDurationDays());
            stmt.setDouble(4, trip.getPrice());
            stmt.setString(5, trip.getActivityType());
            stmt.setString(6, trip.getDescription());
            stmt.setInt(7, trip.getMaxParticipants());
            stmt.setInt(8, trip.getAvailableSlots());
            stmt.setDate(9, trip.getStartDate());
            stmt.setDate(10, trip.getEndDate());
            stmt.setString(11, trip.getImageUrl());
            stmt.setBoolean(12, trip.isActive());
            stmt.setInt(13, trip.getTripId());
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean deleteTrip(int tripId) throws SQLException {
        String sql = "UPDATE trips SET is_active = FALSE WHERE trip_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, tripId);
            return stmt.executeUpdate() > 0;
        }
    }
}
