const { 
    sequelize, 
    Question, 
    Topic, 
    Option, 
    Explanation, 
    QuestionStats, 
    QuestionAttempt, 
    Bookmark, 
    QuestionReport, 
    SectionQuestion, 
    UserMockExamAnswer, 
    UserProgress 
} = require('../models');

async function clearData() {
    console.log('--- 🛡️ Emergency Database Clear Operation Started ---');
    const transaction = await sequelize.transaction();
    try {
        console.log('1. Cleaning up User records associated with questions...');
        await UserProgress.destroy({ where: {}, transaction });
        await Bookmark.destroy({ where: {}, transaction });
        await QuestionReport.destroy({ where: {}, transaction });
        await QuestionAttempt.destroy({ where: {}, transaction });
        
        console.log('2. Cleaning up Mock Exam links...');
        await SectionQuestion.destroy({ where: {}, transaction });
        await UserMockExamAnswer.destroy({ where: {}, transaction });
        
        console.log('3. Deleting core Question data (Options, Explanations, Stats)...');
        await Option.destroy({ where: {}, transaction });
        await Explanation.destroy({ where: {}, transaction });
        await QuestionStats.destroy({ where: {}, transaction });
        await Question.destroy({ where: {}, transaction });

        console.log('4. Deleting all Topics...');
        await Topic.destroy({ where: {}, transaction });

        await transaction.commit();
        console.log('✅ DONE: Questions and Topics tables are now empty.');
    } catch (error) {
        if (transaction) await transaction.rollback();
        console.error('❌ CRITICAL ERROR during clear operation:', error);
        process.exit(1);
    }
    process.exit(0);
}

clearData();
