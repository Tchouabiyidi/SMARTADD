const sequelize = require('../config/database');
const User = require('./user.model');
const Billboard = require('./billboard.model');
const Advertisement = require('./advertisement.model');
const Booking = require('./booking.model');
const Payment = require('./payment.model');
const Schedule = require('./schedule.model');
const QRCode = require('./qr_code.model');
const ESP32Device = require('./esp32.model');
const PlaybackLog = require('./playback.model');

// User <-> Billboard
User.hasMany(Billboard, { foreignKey: 'owner_id', as: 'billboards' });
Billboard.belongsTo(User, { foreignKey: 'owner_id', as: 'owner' });

// User <-> Advertisement
User.hasMany(Advertisement, { foreignKey: 'advertiser_id', as: 'advertisements' });
Advertisement.belongsTo(User, { foreignKey: 'advertiser_id', as: 'advertiser' });

// User <-> Booking
User.hasMany(Booking, { foreignKey: 'advertiser_id', as: 'bookings' });
Booking.belongsTo(User, { foreignKey: 'advertiser_id', as: 'advertiser' });

// Billboard <-> Booking
Billboard.hasMany(Booking, { foreignKey: 'billboard_id', as: 'bookings' });
Booking.belongsTo(Billboard, { foreignKey: 'billboard_id', as: 'billboard' });

// Advertisement <-> Booking
Advertisement.hasMany(Booking, { foreignKey: 'advertisement_id', as: 'bookings' });
Booking.belongsTo(Advertisement, { foreignKey: 'advertisement_id', as: 'advertisement' });

// Booking <-> Payment
Booking.hasOne(Payment, { foreignKey: 'booking_id', as: 'payment' });
Payment.belongsTo(Booking, { foreignKey: 'booking_id', as: 'booking' });

// Billboard <-> QRCode
Billboard.hasOne(QRCode, { foreignKey: 'billboard_id', as: 'qrCode' });
QRCode.belongsTo(Billboard, { foreignKey: 'billboard_id', as: 'billboard' });

// Billboard <-> ESP32Device
Billboard.hasOne(ESP32Device, { foreignKey: 'billboard_id', as: 'esp32Device' });
ESP32Device.belongsTo(Billboard, { foreignKey: 'billboard_id', as: 'billboard' });

module.exports = {
  sequelize,
  User,
  Billboard,
  Advertisement,
  Booking,
  Payment,
  Schedule,
  QRCode,
  ESP32Device,
  PlaybackLog,
};
