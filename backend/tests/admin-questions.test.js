const { request, adminAuth, userAuth } = require('./helpers');

describe('Admin Question Endpoints', () => {
    // ==================== LIST ====================
    describe('GET /api/v1/admin/questions', () => {
        it('should list all questions (admin)', async () => {
            const res = await request
                .get('/api/v1/admin/questions')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });

        it('should reject non-admin', async () => {
            const res = await request
                .get('/api/v1/admin/questions')
                .set('Authorization', userAuth());

            expect(res.status).toBe(403);
        });

        it('should reject unauthenticated', async () => {
            const res = await request.get('/api/v1/admin/questions');
            expect(res.status).toBe(401);
        });
    });

    // ==================== GET BY ID ====================
    describe('GET /api/v1/admin/questions/:id', () => {
        it('should return question details', async () => {
            const res = await request
                .get('/api/v1/admin/questions/1')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== CREATE ====================
    describe('POST /api/v1/admin/questions', () => {
        it('should create a new question', async () => {
            const res = await request
                .post('/api/v1/admin/questions')
                .set('Authorization', adminAuth())
                .send({
                    text: 'Test question from admin?',
                    specialtyId: 1,
                    difficulty: 'easy',
                    options: [
                        { text: 'Option A', isCorrect: true },
                        { text: 'Option B', isCorrect: false },
                        { text: 'Option C', isCorrect: false },
                        { text: 'Option D', isCorrect: false }
                    ]
                });

            expect(res.status).toBe(201);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== UPDATE ====================
    describe('PUT /api/v1/admin/questions/:id', () => {
        it('should update a question', async () => {
            const res = await request
                .put('/api/v1/admin/questions/1')
                .set('Authorization', adminAuth())
                .send({ text: 'Updated question text' });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== DELETE ====================
    describe('DELETE /api/v1/admin/questions/:id', () => {
        it('should delete a question', async () => {
            // Create one to delete
            const createRes = await request
                .post('/api/v1/admin/questions')
                .set('Authorization', adminAuth())
                .send({
                    text: 'Question to delete',
                    specialtyId: 1,
                    difficulty: 'easy',
                    options: [
                        { text: 'A', isCorrect: true },
                        { text: 'B', isCorrect: false },
                        { text: 'C', isCorrect: false },
                        { text: 'D', isCorrect: false }
                    ]
                });

            const id = createRes.body.data?.id || createRes.body.data?.question?.id;
            if (id) {
                const res = await request
                    .delete(`/api/v1/admin/questions/${id}`)
                    .set('Authorization', adminAuth());

                expect(res.status).toBe(200);
            }
        });
    });
});
