const bcrypt = require('bcryptjs');
const { User, sequelize } = require('../models');
const dotenv = require('dotenv');

dotenv.config();

async function seedAdmin() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    const adminEmail = process.env.ADMIN_EMAIL || 'admin@smartadd.com';
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123456';
    const adminName = process.env.ADMIN_NAME || 'System Administrator';

    const existingAdmin = await User.findOne({ where: { email: adminEmail } });
    if (existingAdmin) {
      console.log(`ℹ️ Admin account '${adminEmail}' already exists.`);
      process.exit(0);
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(adminPassword, salt);

    const adminUser = await User.create({
      name: adminName,
      email: adminEmail,
      phone: '+237 655 778 899',
      password: hashedPassword,
      role: 'ADMIN',
    });

    console.log(`✅ Default Admin user created successfully:`);
    console.log(`   ID: ${adminUser.id}`);
    console.log(`   Email: ${adminEmail}`);
    console.log(`   Role: ${adminUser.role}`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding admin user:', error);
    process.exit(1);
  }
}

seedAdmin();
