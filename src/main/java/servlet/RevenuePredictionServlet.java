package servlet;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import model.User;

@WebServlet("/revenue-prediction")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5) // 5MB max file size
public class RevenuePredictionServlet extends HttpServlet {
    
    // Simple data structure for revenue data
    private static class RevenueData {
        public int year;
        public int month;
        public double advertisingCost;
        public double revenue;
        
        public RevenueData(int year, int month, double advertisingCost, double revenue) {
            this.year = year;
            this.month = month;
            this.advertisingCost = advertisingCost;
            this.revenue = revenue;
        }
    }
    
    // Simple linear regression implementation
    private static class SimpleLinearRegression {
        private double slope;
        private double intercept;
        private double correlation;
        private double meanAbsoluteError;
        private int dataPoints;
        
        public void train(List<RevenueData> data) {
            if (data.size() < 2) {
                throw new IllegalArgumentException("Need at least 2 data points for regression");
            }
            
            this.dataPoints = data.size();
            
            // Calculate means
            double meanX = 0, meanY = 0;
            for (RevenueData point : data) {
                meanX += point.advertisingCost;
                meanY += point.revenue;
            }
            meanX /= data.size();
            meanY /= data.size();
            
            // Calculate slope and intercept
            double numerator = 0, denominator = 0;
            for (RevenueData point : data) {
                double xDiff = point.advertisingCost - meanX;
                double yDiff = point.revenue - meanY;
                numerator += xDiff * yDiff;
                denominator += xDiff * xDiff;
            }
            
            if (denominator == 0) {
                slope = 0;
                intercept = meanY;
            } else {
                slope = numerator / denominator;
                intercept = meanY - slope * meanX;
            }
            
            // Calculate correlation coefficient
            double sumXY = 0, sumX2 = 0, sumY2 = 0;
            for (RevenueData point : data) {
                double xDiff = point.advertisingCost - meanX;
                double yDiff = point.revenue - meanY;
                sumXY += xDiff * yDiff;
                sumX2 += xDiff * xDiff;
                sumY2 += yDiff * yDiff;
            }
            
            if (sumX2 > 0 && sumY2 > 0) {
                correlation = sumXY / Math.sqrt(sumX2 * sumY2);
            } else {
                correlation = 0;
            }
            
            // Calculate mean absolute error
            double totalError = 0;
            for (RevenueData point : data) {
                double predicted = predict(point.advertisingCost);
                totalError += Math.abs(point.revenue - predicted);
            }
            meanAbsoluteError = totalError / data.size();
        }
        
        public double predict(double advertisingCost) {
            return slope * advertisingCost + intercept;
        }
        
        public double getSlope() { return slope; }
        public double getIntercept() { return intercept; }
        public double getCorrelation() { return correlation; }
        public double getMeanAbsoluteError() { return meanAbsoluteError; }
        public int getDataPoints() { return dataPoints; }
        public double getAccuracy() {
            // Convert correlation to accuracy percentage
            return Math.abs(correlation) * 100;
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User currentUser = (User) request.getSession().getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        // Forward to the prediction form page
        RequestDispatcher dispatcher = request.getRequestDispatcher("revenue-prediction.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        User currentUser = (User) request.getSession().getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        try {
            // Get the uploaded CSV file
            Part filePart = request.getPart("csvFile");
            
            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Please select a valid CSV file.");
                RequestDispatcher dispatcher = request.getRequestDispatcher("revenue-prediction.jsp");
                dispatcher.forward(request, response);
                return;
            }
            
            // Parse CSV and generate predictions
            Map<String, Object> results = processCSVAndPredict(filePart.getInputStream());
            
            if (results.containsKey("error")) {
                request.setAttribute("error", results.get("error"));
            } else {
                request.setAttribute("success", "Revenue prediction analysis completed successfully!");
                request.setAttribute("predictionResults", results);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error processing file: " + e.getMessage());
        }
        
        // Forward back to the form
        RequestDispatcher dispatcher = request.getRequestDispatcher("revenue-prediction.jsp");
        dispatcher.forward(request, response);
    }
    
    private Map<String, Object> processCSVAndPredict(InputStream csvInputStream) throws IOException {
        Map<String, Object> results = new HashMap<>();
        List<RevenueData> allData = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(csvInputStream))) {
            String line;
            boolean isFirstLine = true;
            
            while ((line = reader.readLine()) != null) {
                if (isFirstLine) {
                    isFirstLine = false;
                    // Skip header line
                    continue;
                }
                
                String[] values = line.split(",");
                if (values.length < 4) {
                    continue; // Skip incomplete rows
                }
                
                try {
                    int year = Integer.parseInt(values[0].trim());
                    int month = parseMonth(values[1].trim());
                    double advertisingCost = Double.parseDouble(values[2].trim());
                    double revenue = Double.parseDouble(values[3].trim());
                    
                    allData.add(new RevenueData(year, month, advertisingCost, revenue));
                } catch (NumberFormatException e) {
                    // Skip rows with invalid numbers
                    continue;
                }
            }
        }
        
        if (allData.size() < 3) {
            results.put("error", "Need at least 3 data points for meaningful predictions. Found: " + allData.size());
            return results;
        }
        
        // Split data: 80% training, 20% testing
        int trainSize = (int) (allData.size() * 0.8);
        List<RevenueData> trainData = allData.subList(0, trainSize);
        List<RevenueData> testData = allData.subList(trainSize, allData.size());
        
        // Train the model
        SimpleLinearRegression model = new SimpleLinearRegression();
        model.train(trainData);
        
        // Test the model and create predictions
        List<Map<String, Object>> predictions = new ArrayList<>();
        for (RevenueData testPoint : testData) {
            double predicted = model.predict(testPoint.advertisingCost);
            double error = Math.abs(testPoint.revenue - predicted);
            double errorPercentage = testPoint.revenue > 0 ? (error / testPoint.revenue) * 100 : 0;
            
            Map<String, Object> pred = new HashMap<>();
            pred.put("year", testPoint.year);
            pred.put("month", getMonthName(testPoint.month));
            pred.put("advertisingCost", testPoint.advertisingCost);
            pred.put("actualRevenue", testPoint.revenue);
            pred.put("predictedRevenue", predicted);
            pred.put("error", error);
            pred.put("errorPercentage", errorPercentage);
            
            predictions.add(pred);
        }
        
        // Generate future predictions (next 6 months)
        List<Map<String, Object>> futurePredictions = generateFuturePredictions(model, allData);
        
        // Prepare results
        results.put("modelAccuracy", model.getAccuracy());
        results.put("correlationCoefficient", model.getCorrelation());
        results.put("meanAbsoluteError", model.getMeanAbsoluteError());
        results.put("totalDataPoints", allData.size());
        results.put("trainingDataPoints", trainData.size());
        results.put("testDataPoints", testData.size());
        results.put("predictions", predictions);
        results.put("futurePredictions", futurePredictions);
        results.put("modelEquation", String.format("Revenue = %.2f × Advertising Cost + %.2f\\nCorrelation: %.3f\\nR-squared: %.3f", 
                    model.getSlope(), model.getIntercept(), model.getCorrelation(), model.getCorrelation() * model.getCorrelation()));
        
        return results;
    }
    
    private List<Map<String, Object>> generateFuturePredictions(SimpleLinearRegression model, List<RevenueData> historicalData) {
        List<Map<String, Object>> futurePredictions = new ArrayList<>();
        
        // Calculate average advertising cost for projections
        double avgAdvertising = historicalData.stream()
                .mapToDouble(d -> d.advertisingCost)
                .average()
                .orElse(1000.0);
        
        // Get the last data point for date calculation
        RevenueData lastData = historicalData.get(historicalData.size() - 1);
        int currentYear = lastData.year;
        int currentMonth = lastData.month;
        
        // Generate 6 months of future predictions
        for (int i = 1; i <= 6; i++) {
            currentMonth++;
            if (currentMonth > 12) {
                currentMonth = 1;
                currentYear++;
            }
            
            // Project advertising cost with slight increase
            double projectedAdvertising = avgAdvertising * (1 + 0.02 * i); // 2% monthly increase
            double predictedRevenue = model.predict(projectedAdvertising);
            
            Map<String, Object> prediction = new HashMap<>();
            prediction.put("year", currentYear);
            prediction.put("month", getMonthName(currentMonth));
            prediction.put("advertisingCost", projectedAdvertising);
            prediction.put("predictedRevenue", predictedRevenue);
            
            futurePredictions.add(prediction);
        }
        
        return futurePredictions;
    }
    
    private int parseMonth(String monthStr) {
        monthStr = monthStr.toLowerCase().trim();
        
        // Try to parse as number first
        try {
            int month = Integer.parseInt(monthStr);
            if (month >= 1 && month <= 12) {
                return month;
            }
        } catch (NumberFormatException e) {
            // Continue to string parsing
        }
        
        // Parse month names/abbreviations
        switch (monthStr) {
            case "jan": case "january": return 1;
            case "feb": case "february": return 2;
            case "mar": case "march": return 3;
            case "apr": case "april": return 4;
            case "may": return 5;
            case "jun": case "june": return 6;
            case "jul": case "july": return 7;
            case "aug": case "august": return 8;
            case "sep": case "september": return 9;
            case "oct": case "october": return 10;
            case "nov": case "november": return 11;
            case "dec": case "december": return 12;
            default: return 1; // Default to January if can't parse
        }
    }
    
    private String getMonthName(int month) {
        String[] months = {"", "January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"};
        return (month >= 1 && month <= 12) ? months[month] : "January";
    }
}
