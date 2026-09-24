const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const QRCode = sequelize.define(
  'QRCode',
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
    qr_data: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    target_url: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
  },
  {
    tableName: 'qr_codes',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = QRCode;
