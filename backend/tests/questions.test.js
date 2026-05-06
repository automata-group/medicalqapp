const { request, userAuth } = require('./helpers');

describe('Question Endpoints', () => {
    // ==================== PRACTICE ====================
    describe('GET /api/v1/questions/practice/next', () => {
        it('should return a random question', async () => {
            const res = await request
                .get('/api/v1/questions/practice/next')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            if (res.body.data) {
                expect(res.body.data).toHaveProperty('text');
                expect(res.body.data).toHaveProperty('options');
                // Should NOT expose isCorrect
                res.body.data.options.forEach(opt => {
                    expect(opt).not.toHaveProperty('isCorrect');
                });
            }
        });

        it('should filter by specialty', async () => {
            const res = await request
                .get('/api/v1/questions/practice/next?specialtyId=1')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
        });

        it('should filter by difficulty', async () => {
            const res = await request
                .get('/api/v1/questions/practice/next?difficulty=easy')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
        });
    });

    // ==================== ANSWER ====================
    describe('POST /api/v1/questions/:id/answer', () => {
        it('should submit answer and return result', async () => {
            const res = await request
                .post('/api/v1/questions/1/answer')
                .set('Authorization', userAuth())
                .send({ selectedOptionId: 1, timeTaken: 30 });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.data).toHaveProperty('isCorrect');
            expect(res.body.data).toHaveProperty('correctOptionId');
            expect(res.body.data).toHaveProperty('explanation');
        });

        it('should reject invalid option', async () => {
            const res = await request
                .post('/api/v1/questions/1/answer')
                .set('Authorization', userAuth())
                .send({ selectedOptionId: 9999 });

            expect(res.status).toBe(400);
        });
    });

    // ==================== BOOKMARK ====================
    describe('POST /api/v1/questions/:id/bookmark', () => {
        it('should bookmark a question', async () => {
            const res = await request
                .post('/api/v1/questions/2/bookmark')
                .set('Authorization', userAuth())
                .send({ note: 'Important surgery question' });

            expect(res.status).toBe(201);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== REPORT ====================
    describe('POST /api/v1/questions/:id/report', () => {
        it('should report a question', async () => {
            const res = await request
                .post('/api/v1/questions/1/report')
                .set('Authorization', userAuth())
                .send({
                    reason: 'incorrect_answer',
                    description: 'The correct answer seems wrong'
                });

            expect(res.status).toBe(201);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== FILTERS ====================
    describe('GET /api/v1/questions/practice/filters', () => {
        it('should return available filters', async () => {
            const res = await request
                .get('/api/v1/questions/practice/filters')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.data).toHaveProperty('specialties');
            expect(res.body.data).toHaveProperty('difficulties');
            expect(res.body.data).toHaveProperty('modes');
        });
    });
});
