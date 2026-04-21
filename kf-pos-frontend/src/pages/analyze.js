const fs = require('fs');
const path = require('path');

const filePath = path.resolve('Menu.jsx');
const content = fs.readFileSync(filePath, 'utf8');
const lines = content.split('\n');

// Find lines with useEffect
lines.forEach((line, index) => {
  if (line.includes('useEffect')) {
    console.log(`Line ${index + 1}: ${line.substring(0, 100)}`);
  }
});

// Look for const API_BASE
lines.forEach((line, index) => {
  if (line.includes('const API_BASE')) {
    console.log(`API_BASE at line ${index + 1}: ${line}`);
  }
});
