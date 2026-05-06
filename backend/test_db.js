const { QuestionAttempt } = require('./src/models');
const checkDB = async () => {
    try {
        const desc = await QuestionAttempt.describe();
        console.log(Object.keys(desc));
        process.exit();
    } catch (e) {
        console.error(e);
    }
}
checkDB();
