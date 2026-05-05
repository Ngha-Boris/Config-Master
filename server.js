const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 8080;
const APP_ENV = process.env.APP_ENV || 'staging';

// Determine color based on environment
function getEnvironmentColor(env) {
  switch (env) {
    case 'production':
      return '#dc3545'; // Red
    case 'staging':
    default:
      return '#0d6efd'; // Blue
  }
}

// Determine environment name for display
function getEnvironmentName(env) {
  switch (env) {
    case 'production':
      return 'Production';
    case 'staging':
    default:
      return 'Staging';
  }
}

// Read and process HTML template
function renderTemplate(templatePath, variables) {
  let template = fs.readFileSync(templatePath, 'utf8');
  
  // Replace all placeholders {{variableName}} with actual values
  Object.keys(variables).forEach(key => {
    const placeholder = new RegExp(`{{${key}}}`, 'g');
    template = template.replace(placeholder, variables[key]);
  });
  
  return template;
}

app.get('/', (req, res) => {
  const color = getEnvironmentColor(APP_ENV);
  const envName = getEnvironmentName(APP_ENV);
  
  const templatePath = path.join(__dirname, 'views', 'index.html');
  const html = renderTemplate(templatePath, {
    color: color,
    envName: envName,
    APP_ENV: APP_ENV,
    PORT: PORT
  });
  
  res.send(html);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    environment: APP_ENV,
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌍 Environment: ${APP_ENV}`);
  console.log(`🎨 Color: ${getEnvironmentColor(APP_ENV)} (${getEnvironmentName(APP_ENV)})`);
});
