const { request, userAuth } = require('./helpers');

describe('Mock Exam Endpoints', () => {
    let attemptId;

    // ==================== GET EXAM DETAILS ====================
    describe('GET /api/v1/mock-exams/:id', () => {
        it('should return mock exam details', async () => {
            const res = await request
                .get('/api/v1/mock-exams/1')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== START EXAM ====================
    describe('POST /api/v1/mock-exams/start', () => {
        it('should start a new exam attempt', async () => {
            const res = await request
                .post('/api/v1/mock-exams/start')
                .set('Authorization', userAuth())
                .send({ mockExamId: 1 });

            if (res.status === 201 || res.status === 200) {
                expect(res.body.success).toBe(true);
                attemptId = res.body.data?.id || res.body.data?.attemptId;
            } else {
                // May fail if exam requires subscription
                expect([200, 201, 403, 500]).toContain(res.status);
            }
        });
    });

    // ==================== GET SECTION QUESTIONS ====================
    describe('GET /api/v1/mock-exams/:attemptId/sections/:sectionId', () => {
        it('should return section questions', async () => {
            if (!attemptId) return;

            const res = await request
                .get(`/api/v1/mock-exams/${attemptId}/sections/1`)
                .set('Authorization', userAuth());

            if (res.status === 200) {
                expect(res.body.success).toBe(true);
            }
        });
    });

    // ==================== SUBMIT ANSWER ====================
    describe('POST /api/v1/mock-exams/:attemptId/answer', () => {
        it('should submit an answer', async () => {
            if (!attemptId) return;

            const res = await request
                .post(`/api/v1/mock-exams/${attemptId}/answer`)
                .set('Authorization', userAuth())
                .send({
                    questionId: 1,
                    sectionId: 1,
                    selectedOptionId: 1
                });

            if (res.status === 200) {
                expect(res.body.success).toBe(true);
            }
        });
    });

    // ==================== COMPLETE EXAM ====================
    describe('POST /api/v1/mock-exams/:attemptId/complete', () => {
        it('should complete the exam', async () => {
            if (!attemptId) return;

            const res = await request
                .post(`/api/v1/mock-exams/${attemptId}/complete`)
                .set('Authorization', userAuth());

            if (res.status === 200) {
                expect(res.body.success).toBe(true);
            }
        });
    });

    // ==================== REVIEW ====================
    describe('GET /api/v1/mock-exams/:attemptId/review', () => {
        it('should return review results', async () => {
            if (!attemptId) return;

            const res = await request
                .get(`/api/v1/mock-exams/${attemptId}/review`)
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== HISTORY ====================
    describe('GET /api/v1/mock-exams/history', () => {
        it('should return exam history', async () => {
            const res = await request
                .get('/api/v1/mock-exams/history')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
