const express = require('express');
const AdvertisementController = require('./advertisement.controller');
const uploadVideo = require('../../middlewares/upload.middleware');
const { authenticateJWT } = require('../../middlewares/auth.middleware');
const { authorizeRoles } = require('../../middlewares/role.middleware');

const router = express.Router();

// 1. Upload Video Advertisement (Advertiser & Admin)
router.post(
  '/upload',
  authenticateJWT,
  authorizeRoles('ADVERTISER', 'ADMIN'),
  uploadVideo.single('video'),
  AdvertisementController.upload
);

// 2. Get Advertisements for Authenticated User (Advertiser view)
router.get(
  '/my/ads',
  authenticateJWT,
  authorizeRoles('ADVERTISER', 'ADMIN'),
  AdvertisementController.getMyAds
);

// 3. Get Pending Advertisements (Admin view)
router.get(
  '/pending',
  authenticateJWT,
  authorizeRoles('ADMIN'),
  AdvertisementController.getPending
);

// 4. Approve Advertisement (Admin view)
router.put(
  '/:id/approve',
  authenticateJWT,
  authorizeRoles('ADMIN'),
  AdvertisementController.approve
);

// 5. Reject Advertisement (Admin view)
router.put(
  '/:id/reject',
  authenticateJWT,
  authorizeRoles('ADMIN'),
  AdvertisementController.reject
);

// 6. Get All Advertisements (Admin & Advertiser general query)
router.get(
  '/',
  authenticateJWT,
  AdvertisementController.getAll
);

module.exports = router;
