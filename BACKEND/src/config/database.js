const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

dotenv.config();

const dbHost = (process.env.DB_HOST || 'localhost').trim();
const dbPort = parseInt((process.env.DB_PORT || '3306').trim(), 10);
const dbName = (process.env.DB_NAME || 'SMARTADDD').trim();
const dbUser = (process.env.DB_USER || 'smartadd_user').trim();
const dbPassword = (process.env.DB_PASSWORD || '12345678').trim();
const dbDialect = (process.env.DB_DIALECT || 'mysql').trim();

let sequelize;

if (process.env.USE_SQLITE === 'true') {
  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './smartadd.sqlite',
    logging: false,
    define: {
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at',
      underscored: true,
    },
  });
} else {
  sequelize = new Sequelize(dbName, dbUser, dbPassword, {
    host: dbHost,
    port: dbPort,
    dialect: dbDialect,
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    pool: {
      max: 10,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
    define: {
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at',
      underscored: true,
    },
  });
}

module.exports = sequelize;
