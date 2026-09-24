const BillboardService = require('./billboard.service');

class BillboardController {
  static async getAll(req, res, next) {
    try {
      const { search, availability, status, minPrice, maxPrice } = req.query;
      const billboards = await BillboardService.getAllBillboards({
        search,
        availability,
        status,
        minPrice,
        maxPrice,
      });

      res.status(200).json({
        success: true,
        count: billboards.length,
        data: billboards,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getById(req, res, next) {
    try {
      const billboard = await BillboardService.getBillboardById(req.params.id);
      if (!billboard) {
        return res.status(404).json({
          success: false,
          message: 'Billboard not found.',
        });
      }
      res.status(200).json({
        success: true,
        data: billboard,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMyBillboards(req, res, next) {
    try {
      const ownerId = req.user.id;
      const billboards = await BillboardService.getBillboardsByOwner(ownerId);
      res.status(200).json({
        success: true,
        count: billboards.length,
        data: billboards,
      });
    } catch (error) {
      next(error);
    }
  }

  static async create(req, res, next) {
    try {
      const { billboard_id, name, location, latitude, longitude, price, availability, status } = req.body;

      if (!name || !location || latitude === undefined || longitude === undefined || price === undefined) {
        return res.status(400).json({
          success: false,
          message: 'name, location, latitude, longitude, and price are required.',
        });
      }

      const owner_id = req.user.role === 'ADMIN' && req.body.owner_id ? req.body.owner_id : req.user.id;

      const billboard = await BillboardService.createBillboard({
        billboard_id,
        name,
        owner_id,
        location,
        latitude,
        longitude,
        price,
        availability: availability !== undefined ? availability : true,
        status: status || 'ACTIVE',
      });

      res.status(201).json({
        success: true,
        message: 'Billboard created successfully.',
        data: billboard,
      });
    } catch (error) {
      next(error);
    }
  }

  static async update(req, res, next) {
    try {
      const billboard = await BillboardService.updateBillboard(req.params.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Billboard updated successfully.',
        data: billboard,
      });
    } catch (error) {
      next(error);
    }
  }

  static async delete(req, res, next) {
    try {
      await BillboardService.deleteBillboard(req.params.id);
      res.status(200).json({
        success: true,
        message: 'Billboard deleted successfully.',
      });
    } catch (error) {
      next(error);
    }
  }

  static async getQRCode(req, res, next) {
    try {
      const host = `${req.protocol}://${req.get('host')}`;
      const qrData = await BillboardService.getQRCodePayload(req.params.id, host);

      res.status(200).json({
        success: true,
        data: qrData,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = BillboardController;
