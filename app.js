const express = require('express');
const app = express();
const port = 3000;

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || 'v1.0.0'
  });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from GitOps Demo! 🚀',
    version: process.env.APP_VERSION || 'v1.0.0',
    environment: process.env.ENVIRONMENT || 'development',
    hostname: require('os').hostname()
  });
});

// Endpoint to test updates
app.get('/info', (req, res) => {
  res.json({
    app: 'GitOps Demo Application',
    description: 'Learning GitHub Actions + ArgoCD',
    author: 'Marwan - DevOps Team',
    deployed: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`✅ App running on port ${port}`);
  console.log(`Version: ${process.env.APP_VERSION || 'v1.0.0'}`);
});
