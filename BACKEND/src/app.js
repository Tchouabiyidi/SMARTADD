const path = require('path');
const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middlewares/error.middleware');

// Import Module Routers
const authRoutes = require('./modules/auth/auth.routes');
const userRoutes = require('./modules/users/user.routes');
const billboardRoutes = require('./modules/billboards/billboard.routes');
const advertisementRoutes = require('./modules/advertisements/advertisement.routes');
const bookingRoutes = require('./modules/bookings/booking.routes');
const paymentRoutes = require('./modules/payments/payment.routes');
const scheduleRoutes = require('./modules/scheduling/schedule.routes');
const qrCodeRoutes = require('./modules/qr_codes/qr_code.routes');
const esp32Routes = require('./modules/esp32/esp32.routes');
const playbackRoutes = require('./modules/playback/playback.routes');

const app = express();

// Global Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve Local Video Uploads Statically
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// System Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    system: 'SMARTADD Smart Billboard REST API',
    timestamp: new Date().toISOString(),
  });
});

// REST API Route Mounts
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/billboards', billboardRoutes);
app.use('/api/advertisements', advertisementRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/scheduling', scheduleRoutes);
app.use('/api/qr-codes', qrCodeRoutes);
app.use('/api/esp32', esp32Routes);
app.use('/api/playback', playbackRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route '${req.originalUrl}' not found on server.`,
  });
});

// Global Error Handler
app.use(errorHandler);

module.exports = app;
