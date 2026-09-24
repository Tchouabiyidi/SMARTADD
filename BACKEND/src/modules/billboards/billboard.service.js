const { Op } = require('sequelize');
const { Billboard, User } = require('../../models');

class BillboardService {
  /**
   * Get all billboards with search and filtering capabilities for Advertisers & Admin
   */
  static async getAllBillboards({ search, availability, status, minPrice, maxPrice } = {}) {
    const whereClause = {};

    if (search) {
      whereClause[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { location: { [Op.like]: `%${search}%` } },
        { billboard_id: { [Op.like]: `%${search}%` } },
      ];
    }

    if (availability !== undefined && availability !== null && availability !== '') {
      whereClause.availability = String(availability) === 'true' || availability === true;
    }

    if (status) {
      whereClause.status = status.toUpperCase();
    }

    if (minPrice || maxPrice) {
      whereClause.price = {};
      if (minPrice) whereClause.price[Op.gte] = parseFloat(minPrice);
      if (maxPrice) whereClause.price[Op.lte] = parseFloat(maxPrice);
    }

    return Billboard.findAll({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'owner',
          attributes: ['id', 'name', 'email', 'phone'],
        },
      ],
      order: [['created_at', 'DESC']],
    });
  }

  /**
   * Find billboard by primary key ID or unique billboard_id string (e.g. BILL-001)
   */
  static async getBillboardById(identifier) {
    const isNumeric = !isNaN(identifier) && !isNaN(parseInt(identifier));
    const whereClause = isNumeric ? { id: parseInt(identifier) } : { billboard_id: identifier };

    return Billboard.findOne({
      where: whereClause,
      include: [
        {
          model: User,
          as: 'owner',
          attributes: ['id', 'name', 'email', 'phone'],
        },
      ],
    });
  }

  /**
   * Get billboards owned by a specific user
   */
  static async getBillboardsByOwner(ownerId) {
    return Billboard.findAll({
      where: { owner_id: ownerId },
      include: [
        {
          model: User,
          as: 'owner',
          attributes: ['id', 'name', 'email', 'phone'],
        },
      ],
      order: [['created_at', 'DESC']],
    });
  }

  /**
   * Create a new billboard with auto-generated billboard_id if omitted
   */
  static async createBillboard(billboardData) {
    // Generate unique billboard_id if not provided
    if (!billboardData.billboard_id) {
      const count = await Billboard.count();
      const num = String(count + 1).padStart(3, '0');
      billboardData.billboard_id = `BILL-${num}`;
    }

    const existing = await Billboard.findOne({
      where: { billboard_id: billboardData.billboard_id },
    });

    if (existing) {
      const error = new Error(`Billboard with ID '${billboardData.billboard_id}' already exists.`);
      error.statusCode = 400;
      throw error;
    }

    return Billboard.create(billboardData);
  }

  /**
   * Update billboard details, price, location, status, availability
   */
  static async updateBillboard(identifier, updateData) {
    const billboard = await this.getBillboardById(identifier);
    if (!billboard) {
      const error = new Error('Billboard not found.');
      error.statusCode = 404;
      throw error;
    }

    await billboard.update(updateData);
    return billboard;
  }

  /**
   * Delete billboard by identifier
   */
  static async deleteBillboard(identifier) {
    const billboard = await this.getBillboardById(identifier);
    if (!billboard) {
      const error = new Error('Billboard not found.');
      error.statusCode = 404;
      throw error;
    }

    await billboard.destroy();
    return true;
  }

  /**
   * Generate QR Code payload containing booking URL: /billboards/{billboardId}/book
   */
  static async getQRCodePayload(identifier, originHost = '') {
    const billboard = await this.getBillboardById(identifier);
    if (!billboard) {
      const error = new Error('Billboard not found.');
      error.statusCode = 404;
      throw error;
    }

    const bookingPath = `/billboards/${billboard.billboard_id}/book`;
    const fullBookingUrl = originHost ? `${originHost}${bookingPath}` : bookingPath;

    return {
      billboard_id: billboard.billboard_id,
      name: billboard.name,
      booking_path: bookingPath,
      booking_url: fullBookingUrl,
      qr_payload: JSON.stringify({
        type: 'SMARTADD_BILLBOARD_BOOKING',
        billboard_id: billboard.billboard_id,
        name: billboard.name,
        location: billboard.location,
        price: billboard.price,
        booking_url: bookingPath,
      }),
    };
  }
}

module.exports = BillboardService;
