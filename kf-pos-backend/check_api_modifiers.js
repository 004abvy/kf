const axios = require('axios');

const API_BASE = process.env.VITE_API_URL || 'http://localhost:5000/api';

async function checkAPIModifiers() {
    try {
        const response = await axios.get(`${API_BASE}/modifiers`);
        console.log('API Response - Total modifiers:', response.data.length);
        console.log('\nModifiers from API:');
        response.data.forEach(m => {
            console.log(`  - ID: ${m.modifier_id}, Name: ${m.name}, Price: ${m.price}`);
        });
    } catch (error) {
        console.error('❌ Error fetching from API:', error.message);
        console.log('Make sure the backend server is running!');
    }
}

checkAPIModifiers();
