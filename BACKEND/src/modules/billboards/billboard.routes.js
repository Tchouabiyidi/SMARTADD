const express = require('express');
const BillboardController = require('./billboard.controller');
const { authenticateJWT } = require('../../middlewares/auth.middleware');
const { authorizeRoles } = require('../../middlewares/role.middleware');

const router = express.Router();

// Specific routes MUST come before parametric '/:id' routes

// 1. Billboard Owner specific route
router.get(
  '/my/billboards',
  authenticateJWT,
  authorizeRoles('BILLBOARD_OWNER', 'ADMIN'),
  BillboardController.getMyBillboards
);

// 2. Public / Advertiser / Admin browse & search route
router.get('/', BillboardController.getAll);

// 3. QR Code payload route (returns /billboards/{billboardId}/book)
router.get('/:id/qr', BillboardController.getQRCode);

// 4. Detail lookup by ID or billboard_id
router.get('/:id', BillboardController.getById);

// 5. Billboard Owner & Admin creation
router.post(
  '/',
  authenticateJWT,
  authorizeRoles('BILLBOARD_OWNER', 'ADMIN'),
  BillboardController.create
);

// 6. Billboard Owner & Admin update
router.put(
  '/:id',
  authenticateJWT,
  authorizeRoles('BILLBOARD_OWNER', 'ADMIN'),
  BillboardController.update
);

// 7. Admin & Owner deletion
router.delete(
  '/:id',
  authenticateJWT,
  authorizeRoles('BILLBOARD_OWNER', 'ADMIN'),
  BillboardController.delete
);

module.exports = router;
