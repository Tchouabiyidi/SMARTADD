const bcrypt = require('bcryptjs');
const { User, sequelize } = require('../models');
const dotenv = require('dotenv');

dotenv.config();

async function setOwnerPassword() {
  try {
    await sequelize.authenticate();
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('A5555555', salt);

    const owner = await User.findOne({ where: { email: 'owner@gmail.com' } });
    if (owner) {
      await owner.update({
        password: hashedPassword,
        role: 'BILLBOARD_OWNER',
      });
      console.log('✅ Successfully updated owner@gmail.com password to A5555555 and role to BILLBOARD_OWNER.');
    } else {
      await User.create({
        name: 'Billboard Owner',
        email: 'owner@gmail.com',
        phone: '+237 670 000 000',
        password: hashedPassword,
        role: 'BILLBOARD_OWNER',
      });
      console.log('✅ Created owner@gmail.com with role BILLBOARD_OWNER and password A5555555.');
    }

    process.exit(0);
  } catch (error) {
    console.error('Error updating owner password:', error.message);
    process.exit(1);
  }
}

setOwnerPassword();
