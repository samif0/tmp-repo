const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Health check endpoint for container monitoring
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Import and use API routes from separate files
app.use('/api/v1/resource', require('./api/resource'));

// Basic API endpoint example
app.get('/api/v1/example', (req, res) => {
  res.json({ 
    message: 'Example API response',
    timestamp: new Date().toISOString()
  });
});

// 404 handler for undefined routes
app.use((req, res, next) => {
  res.status(404).json({ 
    error: 'Not Found',
    path: req.path
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: err.message || 'Something went wrong!',
    timestamp: new Date().toISOString()
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Service running on port ${PORT}`);
});

// Implement graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  // Close database connections, etc.
  process.exit(0);
});