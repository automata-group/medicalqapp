const { request, userAuth } = require('./helpers');

describe('Subscription Endpoints', () => {
    describe('GET /api/v1/subscriptions/plans', () => {
        it('should list available plans', async () => {
            const res = await request
                .get('/api/v1/subscriptions/plans');

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.data.length).toBeGreaterThanOrEqual(3);
        });
    });

    describe('GET /api/v1/subscriptions/user/subscription', () => {
        it('should return user current subscription', async () => {
            const res = await request
                .get('/api/v1/subscriptions/user/subscription')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('Bookmarks', () => {
        it('should list bookmarks', async () => {
            const res = await request
                .get('/api/v1/bookmarks')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });

    describe('Search', () => {
        it('should search questions', async () => {
            const res = await request
                .get('/api/v1/search/questions?q=pneumonia')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
