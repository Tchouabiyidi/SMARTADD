const express = require('express');
const AuthController = require('./auth.controller');
const { authenticateJWT } = require('../../middlewares/auth.middleware');

const router = express.Router();

router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/logout', authenticateJWT, AuthController.logout);
router.get('/me', authenticateJWT, AuthController.getMe);

module.exports = router;
