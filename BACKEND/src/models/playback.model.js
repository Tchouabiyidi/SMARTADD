const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const PlaybackLog = sequelize.define(
  'PlaybackLog',
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    booking_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'bookings',
        key: 'id',
      },
    },
    billboard_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'billboards',
        key: 'id',
      },
    },
    played_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    duration_played: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
  },
  {
    tableName: 'playback_logs',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = PlaybackLog;
