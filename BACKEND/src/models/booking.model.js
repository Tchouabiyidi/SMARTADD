const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Booking = sequelize.define(
  'Booking',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    billboard_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'billboards',
        key: 'id',
      },
    },
    advertiser_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
    },
    advertisement_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'advertisements',
        key: 'id',
      },
    },
    booking_date: {
      type: DataTypes.DATEONLY,
      allowNull: false,
    },
    start_time: {
      type: DataTypes.STRING(20),
      allowNull: false,
    },
    end_time: {
      type: DataTypes.STRING(20),
      allowNull: false,
    },
    total_price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    payment_status: {
      type: DataTypes.ENUM('PENDING', 'PAID', 'FAILED'),
      defaultValue: 'PENDING',
    },
    booking_status: {
      type: DataTypes.ENUM('PENDING', 'CONFIRMED', 'CANCELLED'),
      defaultValue: 'PENDING',
    },
    playback_status: {
      type: DataTypes.ENUM('SCHEDULED', 'PLAYING', 'COMPLETED'),
      defaultValue: 'SCHEDULED',
    },
  },
  {
    tableName: 'bookings',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = Booking;
