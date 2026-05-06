const { Specialty, sequelize } = require('../models');

const updateEmojis = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ DB Connected');

        const updates = [
            { name: 'Orthodontics', icon: '😬' },
            { name: 'Endodontics', icon: '⚡' },
            { name: 'Prosthodontics', icon: '👑' },
            { name: 'Periodontics', icon: '👄' },
            { name: 'Pediatric Dentistry', icon: '👶' },
            { name: 'Restorative', icon: '🛠️' },
            { name: 'Dental Surgery', icon: '💉' },
            { name: 'Oral Medicine & Pathology', icon: '🔬' },
            { name: 'Dental Ethics', icon: '⚖️' },
        ];

        for (const update of updates) {
            await Specialty.update(
                { icon: update.icon },
                { where: { name: update.name } }
            );
            console.log(`Updated ${update.name} -> ${update.icon}`);
        }

        console.log('🎉 Emojis updated successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Update failed:', error);
        process.exit(1);
    }
};

updateEmojis();
