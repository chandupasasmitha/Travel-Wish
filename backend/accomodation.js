const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Mock data for accommodations
let accommodations = [
    { id: 1, name: 'Hotel Sunshine', location: 'New York', price: 120 },
    { id: 2, name: 'Ocean View Resort', location: 'California', price: 200 },
    { id: 3, name: 'Mountain Retreat', location: 'Colorado', price: 150 },
];

// Get all accommodations
app.get('/api/accommodations', (req, res) => {
    res.json(accommodations);
});

// Get accommodation by ID
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
    };
    accommodations.push(newAccommodation);
    res.status(201).json(newAccommodation);
});

// Update an accommodation
app.put('/api/accommodations/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const accommodation = accommodations.find(acc => acc.id === id);
    if (accommodation) {
        accommodation.name = req.body.name || accommodation.name;
        accommodation.location = req.body.location || accommodation.location;
        accommodation.price = req.body.price || accommodation.price;
        res.json(accommodation);
    } else {
        res.status(404).json({ message: 'Accommodation not found' });
    }
});

// Delete an accommodation
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
const PORT = 5000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});