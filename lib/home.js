const express = require('express');

const router = express.Router();

// Mock data for the home page
const destinations = [
    { id: 1, name: 'Paris', description: 'The city of lights', image: 'paris.jpg' },
    { id: 2, name: 'Tokyo', description: 'A bustling metropolis', image: 'tokyo.jpg' },
    { id: 3, name: 'New York', description: 'The city that never sleeps', image: 'newyork.jpg' },
];

// Route to get home page data
router.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Travel Wish!',
        featuredDestinations: destinations,
    });
});

module.exports = router;