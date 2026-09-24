const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Advertisement = sequelize.define(
  'Advertisement',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    advertiser_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
    },
    title: {
      type: DataTypes.STRING(200),
      allowNull: false,
    },
    video_url: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    video_name: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    duration_seconds: {
      type: DataTypes.INTEGER,
      defaultValue: 15,
    },
    verification_status: {
      type: DataTypes.ENUM('PENDING', 'APPROVED', 'REJECTED', 'SCHEDULED', 'PLAYING', 'COMPLETED'),
      defaultValue: 'PENDING',
    },
    rejection_reason: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    tableName: 'advertisements',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = Advertisement;
