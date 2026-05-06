const { request, adminAuth, userAuth } = require('./helpers');

describe('Admin User Endpoints', () => {
    describe('GET /api/v1/admin/users', () => {
        it('should list all users', async () => {
            const res = await request
                .get('/api/v1/admin/users')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });

        it('should reject non-admin', async () => {
            const res = await request
                .get('/api/v1/admin/users')
                .set('Authorization', userAuth());

            expect(res.status).toBe(403);
        });
    });

    describe('GET /api/v1/admin/users/:id', () => {
        it('should return user details', async () => {
            const res = await request
                .get('/api/v1/admin/users/2')
                .set('Authorization', adminAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('PUT /api/v1/admin/users/:id', () => {
        it('should update user info', async () => {
            const res = await request
                .put('/api/v1/admin/users/2')
                .set('Authorization', adminAuth())
                .send({ fullName: 'Admin Updated Name' });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
