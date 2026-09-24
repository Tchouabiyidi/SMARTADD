const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Schedule = sequelize.define(
  'Schedule',
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
    booking_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'bookings',
        key: 'id',
      },
    },
    slot_time: {
      type: DataTypes.STRING(50),
      allowNull: false,
    },
    status: {
      type: DataTypes.ENUM('SCHEDULED', 'ACTIVE', 'COMPLETED'),
      defaultValue: 'SCHEDULED',
    },
  },
  {
    tableName: 'schedules',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  }
);

module.exports = Schedule;
