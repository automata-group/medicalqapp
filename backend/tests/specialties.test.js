const { request, userAuth } = require('./helpers');

describe('Specialty Endpoints', () => {
    // ==================== LIST SPECIALTIES ====================
    describe('GET /api/v1/specialties', () => {
        it('should list all active specialties', async () => {
            const res = await request.get('/api/v1/specialties');

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.data.length).toBeGreaterThanOrEqual(6);
        });
    });

    // ==================== GET SPECIALTY ====================
    describe('GET /api/v1/specialties/:id', () => {
        it('should return specialty details', async () => {
            const res = await request.get('/api/v1/specialties/1');

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.data).toHaveProperty('name');
        });

        it('should return 404 for invalid ID', async () => {
            const res = await request.get('/api/v1/specialties/9999');
            expect(res.status).toBe(404);
        });
    });

    // ==================== USER SPECIALTIES ====================
    describe('POST /api/v1/user/specialties', () => {
        it('should set user specialties', async () => {
            const res = await request
                .post('/api/v1/user/specialties')
                .set('Authorization', userAuth())
                .send({ specialtyIds: [1, 2, 3] });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });

        it('should reject invalid specialty IDs', async () => {
            const res = await request
                .post('/api/v1/user/specialties')
                .set('Authorization', userAuth())
                .send({ specialtyIds: [999, 998] });

            expect(res.status).toBe(400);
        });
    });

    describe('GET /api/v1/user/specialties', () => {
        it('should return user selected specialties', async () => {
            const res = await request
                .get('/api/v1/user/specialties')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('DELETE /api/v1/user/specialties/:id', () => {
        it('should remove a specialty from user', async () => {
            // First set
            await request
                .post('/api/v1/user/specialties')
                .set('Authorization', userAuth())
                .send({ specialtyIds: [1, 2] });

            const res = await request
                .delete('/api/v1/user/specialties/1')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
        });
    });

    // ==================== STUDY SETTINGS ====================
    describe('PUT /api/v1/user/study-settings', () => {
        it('should update study settings', async () => {
            const res = await request
                .put('/api/v1/user/study-settings')
                .set('Authorization', userAuth())
                .send({
                    examDate: '2026-06-01',
                    dailyHours: 4,
                    targetScore: 80
                });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('GET /api/v1/user/study-settings', () => {
        it('should return study settings', async () => {
            const res = await request
                .get('/api/v1/user/study-settings')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
