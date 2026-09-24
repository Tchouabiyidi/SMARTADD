const bcrypt = require('bcryptjs');
const { User, sequelize } = require('../models');
const dotenv = require('dotenv');

dotenv.config();

async function fixUsers() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    const salt = await bcrypt.genSalt(10);
    const passA = await bcrypt.hash('A5555555', salt);
    const passDefault = await bcrypt.hash('12345678', salt);

    // 1. Ensure kelly@gmail.com is ADMIN
    const kelly = await User.findOne({ where: { email: 'kelly@gmail.com' } });
    if (kelly) {
      await kelly.update({ role: 'ADMIN', password: passA });
      console.log('✅ Updated kelly@gmail.com -> role: ADMIN, password: A5555555');
    } else {
      await User.create({
        name: 'Kelly Admin',
        email: 'kelly@gmail.com',
        phone: '+237 670 000 000',
        password: passA,
        role: 'ADMIN',
      });
      console.log('✅ Created kelly@gmail.com -> role: ADMIN, password: A5555555');
    }

    // 2. Ensure owner@gmail.com is BILLBOARD_OWNER
    const owner = await User.findOne({ where: { email: 'owner@gmail.com' } });
    if (owner) {
      await owner.update({ role: 'BILLBOARD_OWNER', password: passDefault });
      console.log('✅ Updated owner@gmail.com -> role: BILLBOARD_OWNER, password: 12345678');
    } else {
      await User.create({
        name: 'Billboard Owner',
        email: 'owner@gmail.com',
        phone: '+237 680 000 000',
        password: passDefault,
        role: 'BILLBOARD_OWNER',
      });
      console.log('✅ Created owner@gmail.com -> role: BILLBOARD_OWNER, password: 12345678');
    }

    // 3. Print all existing users in DB for verification
    const allUsers = await User.findAll({ attributes: ['id', 'name', 'email', 'role'] });
    console.log('\n--- CURRENT DATABASE USERS ---');
    allUsers.forEach(u => {
      console.log(`- ID: ${u.id} | Email: ${u.email} | Name: ${u.name} | Role: ${u.role}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('Error fixing users:', error.message);
    process.exit(1);
  }
}

fixUsers();
