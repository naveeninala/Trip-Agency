<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="model.*" %>
<%
    User currentUser = (User) session.getAttribute("user");
    
    // Check if user is logged in and is an admin
    if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
    Map<String, Object> predictionResults = (Map<String, Object>) request.getAttribute("predictionResults");
    
    DecimalFormat currencyFormat = new DecimalFormat("#,##0.00");
    DecimalFormat percentFormat = new DecimalFormat("#0.00");
%>

<html>
<head>
    <title>Revenue Prediction - Trip Agency</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .prediction-container {
            max-width: 1400px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .prediction-header {
            text-align: center;
            margin-bottom: 40px;
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 30px;
            border-radius: 15px;
        }
        
        .upload-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .upload-form {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
          .file-input-wrapper {
            position: relative;
            display: inline-block;
            cursor: pointer;
            background: #f8f9fa;
            border: 2px dashed #007bff;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            transition: all 0.3s ease;
            width: 100%;
            box-sizing: border-box;
        }
        
        .file-input-wrapper:hover {
            background: #e9ecef;
            border-color: #0056b3;
        }
        
        .file-input-wrapper input[type="file"] {
            position: absolute;
            left: -9999px;
        }
        
        .upload-icon {
            font-size: 3em;
            color: #007bff;
            margin-bottom: 15px;
        }
        
        .upload-text {
            font-size: 1.2em;
            color: #333;
            margin-bottom: 10px;
        }
        
        .upload-hint {
            color: #666;
            font-size: 0.9em;
        }
        
        .btn-predict {
            background: #28a745;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s;
            align-self: flex-start;
        }
        
        .btn-predict:hover {
            background: #218838;
        }
        
        .btn-predict:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }
        
        .results-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .section-title {
            font-size: 1.4em;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
            border-bottom: 2px solid #28a745;
            padding-bottom: 10px;
        }
        
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .metric-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #28a745;
        }
        
        .metric-value {
            font-size: 1.8em;
            font-weight: bold;
            color: #28a745;
            margin-bottom: 5px;
        }
        
        .metric-label {
            color: #666;
            font-size: 0.9em;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .data-table th,
        .data-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        
        .data-table th {
            background: #f8f9fa;
            font-weight: bold;
            color: #333;
        }
        
        .data-table tr:hover {
            background: #f5f5f5;
        }
        
        .accuracy-high {
            color: #28a745;
            font-weight: bold;
        }
        
        .accuracy-medium {
            color: #ffc107;
            font-weight: bold;
        }
        
        .accuracy-low {
            color: #dc3545;
            font-weight: bold;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .sample-format {
            background: #e9ecef;
            padding: 15px;
            border-radius: 8px;
            margin-top: 10px;
            font-family: monospace;
            font-size: 0.9em;
        }
        
        .future-predictions {
            background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-top: 20px;
        }
          .chart-placeholder {
            background: #f8f9fa;
            border: 1px dashed #dee2e6;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            color: #6c757d;
            margin: 20px 0;
        }
        
        .file-status {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background: #f8f9fa;
            border-radius: 6px;
        }
    </style>
</head>
<body>
<!-- Navigation -->
<div class="navbar">
    <h2>Trip Agency - Revenue Prediction</h2>
    <div class="nav-links">
        <a href="index.jsp">Home</a>
        <a href="admin-dashboard.jsp">Admin Dashboard</a>
        <a href="reports.jsp">Reports</a>
        <a href="revenue-prediction" class="active">Revenue Prediction</a>
        <span>Welcome, <%= currentUser.getFullName() %></span>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="prediction-container">
    <!-- Header -->
    <div class="prediction-header">
        <h1>🤖 AI Revenue Prediction System</h1>
        <p>Upload your historical revenue data and get intelligent predictions using machine learning</p>
    </div>
    
    <!-- Alerts -->
    <% if (error != null) { %>
        <div class="alert alert-error">
            <strong>Error:</strong> <%= error %>
        </div>
    <% } %>
    
    <% if (success != null) { %>
        <div class="alert alert-success">
            <strong>Success:</strong> <%= success %>
        </div>
    <% } %>
    
    <!-- Upload Section -->
    <div class="upload-section">
        <div class="section-title">📊 Upload Revenue Data</div>
        <p>Upload a CSV file containing your historical revenue data for AI-powered predictions.</p>
        
        <form action="revenue-prediction" method="post" enctype="multipart/form-data" class="upload-form">
            <label for="csvFile" class="file-input-wrapper">
                <div class="upload-icon">📁</div>
                <div class="upload-text">Click to select CSV file</div>
                <div class="upload-hint">Maximum file size: 5MB</div>
                <input type="file" id="csvFile" name="csvFile" accept=".csv" required>
            </label>
            
            <button type="submit" class="btn-predict">🎯 Generate Predictions</button>
        </form>
        
        <div style="margin-top: 20px;">
            <strong>Expected CSV Format:</strong>
            <div class="sample-format">
Year,Month,Advertising Cost,Revenue<br>
2023,Jan,1000,5000<br>
2023,Feb,1200,5500<br>
2023,Mar,1300,6000<br>
2023,Apr,1100,5800<br>
...
            </div>
            <p style="margin-top: 10px; color: #666; font-size: 0.9em;">
                <strong>Note:</strong> Ensure your CSV has exactly these 4 columns. Month can be abbreviated (Jan, Feb) or full names (January, February) or numbers (1, 2).
            </p>
        </div>
    </div>
    
    <!-- Results Section -->
    <% if (predictionResults != null) { %>
        <div class="results-section">
            <div class="section-title">📈 Prediction Results</div>
            
            <!-- Model Performance Metrics -->
            <h3>Model Performance</h3>
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-value">
                        <%= String.format("%.1f%%", (Double) predictionResults.get("modelAccuracy")) %>
                    </div>
                    <div class="metric-label">Model Accuracy</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        <%= String.format("%.3f", (Double) predictionResults.get("correlationCoefficient")) %>
                    </div>
                    <div class="metric-label">Correlation Coefficient</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        $<%= currencyFormat.format((Double) predictionResults.get("meanAbsoluteError")) %>
                    </div>
                    <div class="metric-label">Mean Absolute Error</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        <%= predictionResults.get("totalDataPoints") %>
                    </div>
                    <div class="metric-label">Total Data Points</div>
                </div>
            </div>
            
            <!-- Historical Predictions vs Actual -->
            <h3>Historical Data Validation</h3>
            <p>Comparison of predicted vs actual revenue on test data:</p>
            
            <% 
            List<Map<String, Object>> predictions = (List<Map<String, Object>>) predictionResults.get("predictions");
            if (predictions != null && !predictions.isEmpty()) {
            %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Year</th>
                            <th>Month</th>
                            <th>Advertising Cost</th>
                            <th>Actual Revenue</th>
                            <th>Predicted Revenue</th>
                            <th>Error</th>
                            <th>Error %</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> pred : predictions) { 
                            double errorPercentage = (Double) pred.get("errorPercentage");
                            String errorClass = errorPercentage < 5 ? "accuracy-high" : 
                                               errorPercentage < 15 ? "accuracy-medium" : "accuracy-low";
                        %>
                            <tr>
                                <td><%= pred.get("year") %></td>
                                <td><%= pred.get("month") %></td>
                                <td>$<%= currencyFormat.format((Double) pred.get("advertisingCost")) %></td>
                                <td>$<%= currencyFormat.format((Double) pred.get("actualRevenue")) %></td>
                                <td>$<%= currencyFormat.format((Double) pred.get("predictedRevenue")) %></td>
                                <td>$<%= currencyFormat.format((Double) pred.get("error")) %></td>
                                <td><span class="<%= errorClass %>"><%= percentFormat.format(errorPercentage) %>%</span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p>No test data available for validation. Consider uploading more historical data.</p>
            <% } %>
            
            <!-- Future Predictions -->
            <div class="future-predictions">
                <h3 style="color: white; margin-top: 0;">🔮 Future Revenue Predictions (Next 6 Months)</h3>
                <p style="margin-bottom: 20px;">Based on historical trends and projected advertising spend:</p>
                
                <% 
                List<Map<String, Object>> futurePredictions = (List<Map<String, Object>>) predictionResults.get("futurePredictions");
                if (futurePredictions != null && !futurePredictions.isEmpty()) {
                %>
                    <table class="data-table" style="background: white; color: #333;">
                        <thead>
                            <tr>
                                <th>Year</th>
                                <th>Month</th>
                                <th>Projected Advertising Cost</th>
                                <th>Predicted Revenue</th>
                                <th>Revenue Growth</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            double previousRevenue = 0;
                            for (int i = 0; i < futurePredictions.size(); i++) {
                                Map<String, Object> futPred = futurePredictions.get(i);
                                double currentRevenue = (Double) futPred.get("predictedRevenue");
                                double growth = i > 0 ? ((currentRevenue - previousRevenue) / previousRevenue) * 100 : 0;
                                previousRevenue = currentRevenue;
                                
                                String growthClass = growth > 0 ? "accuracy-high" : growth < 0 ? "accuracy-low" : "";
                            %>
                                <tr>
                                    <td><%= futPred.get("year") %></td>
                                    <td><%= futPred.get("month") %></td>
                                    <td>$<%= currencyFormat.format((Double) futPred.get("advertisingCost")) %></td>
                                    <td>$<%= currencyFormat.format(currentRevenue) %></td>
                                    <td>
                                        <% if (i > 0) { %>
                                            <span class="<%= growthClass %>">
                                                <%= growth > 0 ? "+" : "" %><%= percentFormat.format(growth) %>%
                                            </span>
                                        <% } else { %>
                                            <span style="color: #666;">Baseline</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
            
            <!-- Model Information -->
            <div style="margin-top: 30px;">
                <h3>🧠 Machine Learning Model Details</h3>
                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; font-family: monospace; font-size: 0.85em; max-height: 200px; overflow-y: auto;">
                    <%= predictionResults.get("modelEquation").toString().replace("\n", "<br>") %>
                </div>
                <p style="margin-top: 10px; color: #666; font-size: 0.9em;">
                    <strong>Algorithm:</strong> Linear Regression with Weka ML Library<br>
                    <strong>Training Data:</strong> <%= predictionResults.get("trainingDataPoints") %> data points<br>
                    <strong>Test Data:</strong> <%= predictionResults.get("testDataPoints") %> data points
                </p>
            </div>
        </div>
    <% } %>
    
    <!-- Instructions -->
    <div class="upload-section">
        <div class="section-title">📋 How It Works</div>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px;">
            <div>
                <h4>1. Data Upload</h4>
                <p>Upload your historical revenue data in CSV format with Year, Month, Advertising Cost, and Revenue columns.</p>
            </div>
            <div>
                <h4>2. AI Analysis</h4>
                <p>Our machine learning algorithm analyzes patterns and relationships in your historical data using linear regression.</p>
            </div>
            <div>
                <h4>3. Future Predictions</h4>
                <p>Get intelligent predictions for the next 6 months based on projected advertising spending and historical trends.</p>
            </div>
            <div>
                <h4>4. Performance Metrics</h4>
                <p>View model accuracy, correlation coefficients, and error rates to understand prediction reliability.</p>
            </div>
        </div>
    </div>
    
    <!-- Back to Dashboard -->
    <div style="text-align: center; margin: 30px 0;">
        <a href="admin-dashboard.jsp" class="btn-predict">🏠 Back to Admin Dashboard</a>
        <a href="reports.jsp" class="btn-predict" style="margin-left: 15px; background: #17a2b8;">📊 View Reports</a>
    </div>
</div>

<script>
// File input styling and feedback
document.addEventListener('DOMContentLoaded', function() {
    const fileInput = document.getElementById('csvFile');
    const wrapper = document.querySelector('.file-input-wrapper');
    const submitBtn = document.querySelector('.btn-predict');
    
    // Create a status display element
    const statusDisplay = document.createElement('div');
    statusDisplay.className = 'file-status';
    statusDisplay.style.display = 'none';
    wrapper.appendChild(statusDisplay);
    
    fileInput.addEventListener('change', function() {
        if (this.files && this.files[0]) {
            const fileName = this.files[0].name;
            const fileSize = (this.files[0].size / 1024 / 1024).toFixed(2);
            
            // Hide the original content and show status
            wrapper.querySelector('.upload-icon').style.display = 'none';
            wrapper.querySelector('.upload-text').style.display = 'none';
            wrapper.querySelector('.upload-hint').style.display = 'none';
            
            // Show file selected status
            statusDisplay.innerHTML = `
                <div class="upload-icon" style="color: #28a745;">✅</div>
                <div class="upload-text">File Selected: ${fileName}</div>
                <div class="upload-hint">Size: ${fileSize} MB</div>
            `;
            statusDisplay.style.display = 'block';
            
            submitBtn.disabled = false;
        } else {
            // Reset to original state
            wrapper.querySelector('.upload-icon').style.display = 'block';
            wrapper.querySelector('.upload-text').style.display = 'block';
            wrapper.querySelector('.upload-hint').style.display = 'block';
            statusDisplay.style.display = 'none';
            submitBtn.disabled = true;
        }
    });
    
    // Make wrapper clickable to trigger file input
    wrapper.addEventListener('click', function(e) {
        if (e.target !== fileInput) {
            fileInput.click();
        }
    });
    
    // Initially disable submit button
    submitBtn.disabled = true;
});
</script>
</body>
</html>
