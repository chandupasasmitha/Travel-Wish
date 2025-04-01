const express = require('express');

const router = express.Router();

// Sample route for the home page
router.get('/', (req, res) => {
    res.json({ message: 'Welcome to the Travel-Wish Home Page!' });
});

// Export the router
module.exports = router;