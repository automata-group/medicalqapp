const { Question, Specialty, sequelize } = require('c:/Users/HP/Downloads/medical Q with AI/medical Q with AI/backend/src/models');

async function test() {
    try {
        const counts = await Question.findAll({
            attributes: ['specialtyId', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
            group: ['specialtyId']
        });
        console.log("Question counts by specialty:", JSON.stringify(counts, null, 2));

        const randOptions = await Question.findAll({
            attributes: ['id'],
            order: sequelize.random(),
            limit: 3
        });
        console.log("Random questions with sequelize.random():", JSON.stringify(randOptions, null, 2));

        const randOptions2 = await Question.findAll({
            attributes: ['id'],
            order: [sequelize.fn('RAND')],
            limit: 3
        });
        console.log("Random questions with Sequelize.fn('RAND'):", JSON.stringify(randOptions2, null, 2));

        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}
test();
