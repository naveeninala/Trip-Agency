package model;

public class Booking {
    private int bookingId;
    private int userId;
    private int tripId;
    private java.sql.Timestamp bookingDate;
    private java.sql.Date travelDate;
    private int numberOfParticipants;
    private double totalAmount;
    private String bookingStatus;
    private String travellerDetails;
    private String specialRequests;

    // Getters and setters
    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getTripId() {
        return tripId;
    }

    public void setTripId(int tripId) {
        this.tripId = tripId;
    }

    public java.sql.Timestamp getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(java.sql.Timestamp bookingDate) {
        this.bookingDate = bookingDate;
    }

    public java.sql.Date getTravelDate() {
        return travelDate;
    }

    public void setTravelDate(java.sql.Date travelDate) {
        this.travelDate = travelDate;
    }

    public int getNumberOfParticipants() {
        return numberOfParticipants;
    }

    public void setNumberOfParticipants(int numberOfParticipants) {
        this.numberOfParticipants = numberOfParticipants;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public String getTravellerDetails() {
        return travellerDetails;
    }

    public void setTravellerDetails(String travellerDetails) {
        this.travellerDetails = travellerDetails;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }
}
