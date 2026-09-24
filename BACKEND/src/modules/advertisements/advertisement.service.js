const { Advertisement, User } = require('../../models');

class AdvertisementService {
  /**
   * Format video URL using host (e.g. http://192.168.1.100:5000/uploads/videos/video-xxx.mp4)
   */
  static formatVideoUrl(filename, host) {
    if (!filename) return null;
    const cleanHost = host ? host.replace(/\/$/, '') : 'http://localhost:5000';
    return `${cleanHost}/uploads/videos/${filename}`;
  }

  /**
   * Create a new advertisement record
   */
  static async createAdvertisement({ title, duration_seconds, filename, advertiser_id, host }) {
    const video_url = this.formatVideoUrl(filename, host);

    const advertisement = await Advertisement.create({
      title,
      duration_seconds: duration_seconds ? parseInt(duration_seconds) : 15,
      video_name: filename,
      video_url,
      advertiser_id,
      verification_status: 'PENDING',
    });

    return advertisement;
  }

  /**
   * Fetch advertisements belonging to a specific advertiser
   */
  static async getAdvertisementsByAdvertiser(advertiserId, host) {
    const ads = await Advertisement.findAll({
      where: { advertiser_id: advertiserId },
      order: [['created_at', 'DESC']],
    });

    return ads.map((ad) => {
      const json = ad.toJSON();
      json.video_url = this.formatVideoUrl(json.video_name, host) || json.video_url;
      return json;
    });
  }

  /**
   * Fetch all advertisements (Admin view)
   */
  static async getAllAdvertisements(host) {
    const ads = await Advertisement.findAll({
      include: [
        {
          model: User,
          as: 'advertiser',
          attributes: ['id', 'name', 'email', 'phone'],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    return ads.map((ad) => {
      const json = ad.toJSON();
      json.video_url = this.formatVideoUrl(json.video_name, host) || json.video_url;
      return json;
    });
  }

  /**
   * Fetch pending advertisements for Admin review
   */
  static async getPendingAdvertisements(host) {
    const ads = await Advertisement.findAll({
      where: { verification_status: 'PENDING' },
      include: [
        {
          model: User,
          as: 'advertiser',
          attributes: ['id', 'name', 'email', 'phone'],
        },
      ],
      order: [['created_at', 'ASC']],
    });

    return ads.map((ad) => {
      const json = ad.toJSON();
      json.video_url = this.formatVideoUrl(json.video_name, host) || json.video_url;
      return json;
    });
  }

  /**
   * Approve advertisement
   */
  static async approveAdvertisement(id, host) {
    const ad = await Advertisement.findByPk(id);
    if (!ad) {
      const error = new Error('Advertisement not found.');
      error.statusCode = 404;
      throw error;
    }

    const video_url = this.formatVideoUrl(ad.video_name, host) || ad.video_url;

    await ad.update({
      verification_status: 'APPROVED',
      rejection_reason: null,
      video_url,
    });

    return ad;
  }

  /**
   * Reject advertisement with reason
   */
  static async rejectAdvertisement(id, reason) {
    const ad = await Advertisement.findByPk(id);
    if (!ad) {
      const error = new Error('Advertisement not found.');
      error.statusCode = 404;
      throw error;
    }

    await ad.update({
      verification_status: 'REJECTED',
      rejection_reason: reason || 'Video content did not meet platform guidelines.',
    });

    return ad;
  }
}

module.exports = AdvertisementService;
