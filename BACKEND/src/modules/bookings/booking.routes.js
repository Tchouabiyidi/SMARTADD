const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Bookings module endpoint initialized.',
    data: [],
  });
});

module.exports = router;
