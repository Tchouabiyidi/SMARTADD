const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const ESP32Device = sequelize.define(
  'ESP32Device',
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
    device_mac: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
    },
    power_state: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    connection_status: {
      type: DataTypes.ENUM('ONLINE', 'OFFLINE'),
      defaultValue: 'ONLINE',
    },
    ip_address: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    last_ping: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    tableName: 'esp32_devices',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = ESP32Device;
