const { Billboard, User, sequelize } = require('../models');
const dotenv = require('dotenv');

dotenv.config();

async function seedBillboards() {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Ensure owner user exists
    let owner = await User.findOne({ where: { role: 'BILLBOARD_OWNER' } });
    if (!owner) {
      owner = await User.findOne({ where: { role: 'ADMIN' } });
    }

    if (!owner) {
      console.error('No owner or admin user found to associate billboards.');
      process.exit(1);
    }

    const sampleBillboards = [
      {
        billboard_id: 'BILL-001',
        name: 'Akwa Central Digital Billboard',
        owner_id: owner.id,
        location: 'Douala - Akwa (Boulevard de la Liberté)',
        latitude: 4.0511,
        longitude: 9.7085,
        price: 15000.00,
        availability: true,
        status: 'ACTIVE',
      },
      {
        billboard_id: 'BILL-002',
        name: 'Bonanjo Highway Display',
        owner_id: owner.id,
        location: 'Douala - Bonanjo (Avenue du Général de Gaulle)',
        latitude: 4.0435,
        longitude: 9.6892,
        price: 20000.00,
        availability: true,
        status: 'ACTIVE',
      },
      {
        billboard_id: 'BILL-003',
        name: 'Bastos Express Billboard',
        owner_id: owner.id,
        location: 'Yaoundé - Bastos (Rue de Bastos)',
        latitude: 3.8860,
        longitude: 11.5150,
        price: 25000.00,
        availability: false,
        status: 'ACTIVE',
      },
    ];

    for (const bData of sampleBillboards) {
      const [b, created] = await Billboard.findOrCreate({
        where: { billboard_id: bData.billboard_id },
        defaults: bData,
      });

      if (created) {
        console.log(`✅ Created Billboard: ${b.billboard_id} (${b.name})`);
      } else {
        await b.update(bData);
        console.log(`✅ Updated Billboard: ${b.billboard_id} (${b.name})`);
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('Error seeding billboards:', error.message);
    process.exit(1);
  }
}

seedBillboards();
