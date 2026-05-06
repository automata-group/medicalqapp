const { request, adminAuth } = require('./helpers');

describe('Admin Specialty Endpoints', () => {
    describe('GET /api/v1/admin/specialties', () => {
        it('should list all specialties', async () => {
            const res = await request
                .get('/api/v1/admin/specialties')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('POST /api/v1/admin/specialties', () => {
        it('should create a specialty', async () => {
            const res = await request
                .post('/api/v1/admin/specialties')
                .set('Authorization', adminAuth())
                .send({
                    name: 'Dermatology',
                    nameAr: 'الجلدية',
                    icon: '🧴',
                    sortOrder: 7,
                    isActive: true
                });

            // May return 201 or 200 depending on controller
            expect([200, 201]).toContain(res.status);
            expect(res.body.success).toBe(true);
        });
    });

    describe('PUT /api/v1/admin/specialties/:id', () => {
        it('should update a specialty', async () => {
            const res = await request
                .put('/api/v1/admin/specialties/1')
                .set('Authorization', adminAuth())
                .send({ name: 'Internal Medicine Updated' });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('GET /api/v1/admin/specialties/:id', () => {
        it('should get specialty details', async () => {
            const res = await request
                .get('/api/v1/admin/specialties/1')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
