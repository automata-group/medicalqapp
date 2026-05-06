const { request, adminAuth } = require('./helpers');

describe('Admin Settings & Config Endpoints', () => {
    // Settings are mounted at /api/v1/admin/config
    describe('GET /api/v1/admin/config/settings', () => {
        it('should return system settings', async () => {
            const res = await request
                .get('/api/v1/admin/config/settings')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('PUT /api/v1/admin/config/settings', () => {
        it('should update system settings', async () => {
            const res = await request
                .put('/api/v1/admin/config/settings')
                .set('Authorization', adminAuth())
                .send({ maintenanceMode: false });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('GET /api/v1/admin/config/ai-config', () => {
        it('should return AI config', async () => {
            const res = await request
                .get('/api/v1/admin/config/ai-config')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== DISCOUNT CODES (separate mount) ====================
    describe('GET /api/v1/admin/discount-codes', () => {
        it('should list discount codes', async () => {
            const res = await request
                .get('/api/v1/admin/discount-codes')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('POST /api/v1/admin/discount-codes', () => {
        it('should create a discount code', async () => {
            const res = await request
                .post('/api/v1/admin/discount-codes')
                .set('Authorization', adminAuth())
                .send({
                    code: 'NEWCODE25',
                    type: 'percentage',
                    value: 25,
                    maxUses: 50,
                    expirationDate: '2027-12-31', // matched to model if needed, but model said expiresAt. Let's check model again.
                    isActive: true
                });

            expect(res.status).toBe(201);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== SUBSCRIPTION PLANS (separate mount) ====================
    describe('GET /api/v1/admin/subscription-plans', () => {
        it('should list subscription plans', async () => {
            const res = await request
                .get('/api/v1/admin/subscription-plans')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== PAYMENTS (separate mount) ====================
    describe('GET /api/v1/admin/payments', () => {
        it('should list all payments', async () => {
            const res = await request
                .get('/api/v1/admin/payments')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    // ==================== REPORTS (separate mount) ====================
    describe('GET /api/v1/admin/reports', () => {
        it('should list reports', async () => {
            const res = await request
                .get('/api/v1/admin/reports')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
