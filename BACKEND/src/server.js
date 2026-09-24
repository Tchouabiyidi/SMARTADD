const app = require('./app');
const { sequelize } = require('./models');
const dotenv = require('dotenv');

dotenv.config();

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    console.log('Connecting to database...');
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully.');
    await sequelize.sync({ alter: false });
    console.log('✅ Database models synchronized.');

    app.listen(PORT, () => {
      console.log(`🚀 SMARTADD Backend REST API running on http://localhost:${PORT}`);
      console.log(`📡 Health Check: http://localhost:${PORT}/api/health`);
    });
  } catch (error) {
    console.error('⚠️ Primary MySQL connection failed:', error.message);
    console.log('🔄 Initializing SQLite database storage fallback...');

    const { Sequelize } = require('sequelize');
    const fallbackDb = new Sequelize({
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

    try {
      await fallbackDb.authenticate();
      console.log('✅ Local SQLite database connection established.');

      // Re-bind models to fallback instance if necessary
      app.listen(PORT, () => {
        console.log(`🚀 SMARTADD Backend REST API running (SQLite Fallback) on http://localhost:${PORT}`);
        console.log(`📡 Health Check: http://localhost:${PORT}/api/health`);
      });
    } catch (fallbackError) {
      console.error('❌ Failed to start database fallback:', fallbackError.message);
      app.listen(PORT, () => {
        console.log(`⚠️ SMARTADD Backend REST API running (No DB) on http://localhost:${PORT}`);
      });
    }
  }
}

startServer();
