const bcrypt = require('bcryptjs');
const { User, sequelize } = require('../models');
const dotenv = require('dotenv');

dotenv.config();

async function createKellyAdmin() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    const email = 'kelly@gmail.com';
    const password = 'A5555555';
    const name = 'Kelly Admin';

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const existingUser = await User.findOne({ where: { email } });

    if (existingUser) {
      await existingUser.update({
        name,
        password: hashedPassword,
        role: 'ADMIN',
      });
      console.log(`✅ Existing user '${email}' updated to ADMIN with password '${password}'.`);
    } else {
      const newUser = await User.create({
        name,
        email,
        phone: '+237 670 000 000',
        password: hashedPassword,
        role: 'ADMIN',
      });
      console.log(`✅ Admin user '${email}' created successfully with ID: ${newUser.id}.`);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating Admin user:', error.message);
    process.exit(1);
  }
}

createKellyAdmin();
