const { request, userAuth } = require('./helpers');

describe('Notification Endpoints', () => {
    describe('GET /api/v1/notifications', () => {
        it('should list user notifications', async () => {
            const res = await request
                .get('/api/v1/notifications')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('GET /api/v1/notifications/unread-count', () => {
        it('should return unread count', async () => {
            const res = await request
                .get('/api/v1/notifications/unread-count')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            // Controller returns { success, count } at root level
            expect(res.body).toHaveProperty('count');
        });
    });

    describe('PUT /api/v1/notifications/:id/read', () => {
        it('should mark notification as read', async () => {
            const res = await request
                .put('/api/v1/notifications/1/read')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
