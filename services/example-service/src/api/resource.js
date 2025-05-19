const express = require('express');
const router = express.Router();

// GET all resources
router.get('/', (req, res) => {
  // TODO: Implement database retrieval logic
  res.json({ 
    data: [
      { id: 1, name: 'Resource 1' },
      { id: 2, name: 'Resource 2' }
    ] 
  });
});

// GET specific resource
router.get('/:id', (req, res) => {
  const { id } = req.params;
  // TODO: Implement database retrieval logic for specific resource
  res.json({ id, name: `Resource ${id}` });
});

// POST create new resource
router.post('/', (req, res) => {
  // TODO: Implement validation
  // TODO: Implement database creation logic
  res.status(201).json({ 
    id: Math.floor(Math.random() * 1000),
    ...req.body
  });
});

// PUT update resource
router.put('/:id', (req, res) => {
  const { id } = req.params;
  // TODO: Implement validation
  // TODO: Implement database update logic
  res.json({ 
    id: parseInt(id), 
    ...req.body,
    updated: true 
  });
});

// DELETE resource
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  // TODO: Implement database deletion logic
  res.json({ deleted: id });
});

module.exports = router;