const AdvertisementService = require('./advertisement.service');

class AdvertisementController {
  /**
   * Upload video advertisement file and record database entry
   */
  static async upload(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No video file provided. Please attach a video file.',
        });
      }

      const { title, duration_seconds } = req.body;
      if (!title) {
        return res.status(400).json({
          success: false,
          message: 'Advertisement title is required.',
        });
      }

      const host = `${req.protocol}://${req.get('host')}`;
      const advertiser_id = req.user.id;

      const ad = await AdvertisementService.createAdvertisement({
        title,
        duration_seconds,
        filename: req.file.filename,
        advertiser_id,
        host,
      });

      res.status(201).json({
        success: true,
        message: 'Advertisement video uploaded successfully. Pending admin review.',
        data: ad,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user's uploaded advertisements
   */
  static async getMyAds(req, res, next) {
    try {
      const host = `${req.protocol}://${req.get('host')}`;
      const ads = await AdvertisementService.getAdvertisementsByAdvertiser(req.user.id, host);

      res.status(200).json({
        success: true,
        count: ads.length,
        data: ads,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get all advertisements (Admin view)
   */
  static async getAll(req, res, next) {
    try {
      const host = `${req.protocol}://${req.get('host')}`;
      const ads = await AdvertisementService.getAllAdvertisements(host);

      res.status(200).json({
        success: true,
        count: ads.length,
        data: ads,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get pending advertisements for Admin review
   */
  static async getPending(req, res, next) {
    try {
      const host = `${req.protocol}://${req.get('host')}`;
      const ads = await AdvertisementService.getPendingAdvertisements(host);

      res.status(200).json({
        success: true,
        count: ads.length,
        data: ads,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Approve advertisement (Admin only)
   */
  static async approve(req, res, next) {
    try {
      const host = `${req.protocol}://${req.get('host')}`;
      const ad = await AdvertisementService.approveAdvertisement(req.params.id, host);

      res.status(200).json({
        success: true,
        message: 'Advertisement approved successfully.',
        data: ad,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Reject advertisement (Admin only)
   */
  static async reject(req, res, next) {
    try {
      const { reason } = req.body;
      const ad = await AdvertisementService.rejectAdvertisement(req.params.id, reason);

      res.status(200).json({
        success: true,
        message: 'Advertisement rejected.',
        data: ad,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdvertisementController;
