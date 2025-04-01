const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// In-memory storage for accommodations
let accommodations = [];

// Routes

// Get all accommodations
app.get('/api/accommodations', (req, res) => {
    res.json(accommodations);
});

// Get a specific accommodation by ID
app.get('/api/accommodations/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const accommodation = accommodations.find(acc => acc.id === id);
    if (accommodation) {
        res.json(accommodation);
    } else {
        res.status(404).json({ message: 'Accommodation not found' });
    }
});

// Add a new accommodation
app.post('/api/accommodations', (req, res) => {
    const newAccommodation = {
        id: accommodations.length + 1,
        name: req.body.name,
        location: req.body.location,
        price: req.body.price,
        description: req.body.description
    };
    accommodations.push(newAccommodation);
    res.status(201).json(newAccommodation);
});

// Update an accommodation by ID
app.put('/api/accommodations/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const accommodation = accommodations.find(acc => acc.id === id);
    if (accommodation) {
        accommodation.name = req.body.name || accommodation.name;
        accommodation.location = req.body.location || accommodation.location;
        accommodation.price = req.body.price || accommodation.price;
        accommodation.description = req.body.description || accommodation.description;
        res.json(accommodation);
    } else {
        res.status(404).json({ message: 'Accommodation not found' });
    }
});

// Delete an accommodation by ID
app.delete('/api/accommodations/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = accommodations.findIndex(acc => acc.id === id);
    if (index !== -1) {
        accommodations.splice(index, 1);
        res.json({ message: 'Accommodation deleted successfully' });
    } else {
        res.status(404).json({ message: 'Accommodation not found' });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});