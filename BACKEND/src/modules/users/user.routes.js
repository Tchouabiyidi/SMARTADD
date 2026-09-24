const express = require('express');
const UserController = require('./user.controller');
const { authenticateJWT } = require('../../middlewares/auth.middleware');
const { authorizeRoles } = require('../../middlewares/role.middleware');

const router = express.Router();

router.use(authenticateJWT);

// Admin User Management Endpoints
router.post('/', authorizeRoles('ADMIN'), UserController.createUser);
router.get('/', authorizeRoles('ADMIN'), UserController.getAllUsers);
router.get('/:id', UserController.getUserById);
router.put('/:id', UserController.updateUser);
router.patch('/:id/role', authorizeRoles('ADMIN'), UserController.changeRole);
router.delete('/:id', authorizeRoles('ADMIN'), UserController.deleteUser);

module.exports = router;
