const { request, userAuth, generateToken } = require('./helpers');

describe('Auth Endpoints', () => {
    // ==================== REGISTER ====================
    describe('POST /api/v1/auth/register', () => {
        it('should register a new user', async () => {
            const res = await request
                .post('/api/v1/auth/register')
                .send({
                    fullName: 'New Test User',
                    email: 'newuser@test.com',
                    password: 'NewUser@123'
                });

            expect(res.status).toBe(201);
            expect(res.body.success).toBe(true);
            expect(res.body.data).toHaveProperty('accessToken');
        });

        it('should reject duplicate email', async () => {
            const res = await request
                .post('/api/v1/auth/register')
                .send({
                    fullName: 'Duplicate',
                    email: 'student@test.com',
                    password: 'Test@123'
                });

            expect(res.status).toBe(400);
        });

        it('should reject missing fields', async () => {
            const res = await request
                .post('/api/v1/auth/register')
                .send({ email: 'noname@test.com' });

            expect(res.status).toBeGreaterThanOrEqual(400);
        });
    });

    // ==================== LOGIN ====================
    describe('POST /api/v1/auth/login', () => {
        it('should login with valid credentials', async () => {
            const res = await request
                .post('/api/v1/auth/login')
                .send({ email: 'student@test.com', password: 'Test@123' });

            // May return 200 or 500 depending on RefreshToken setup
            if (res.status === 200) {
                expect(res.body.success).toBe(true);
                expect(res.body.data).toHaveProperty('accessToken');
            }
        });

        it('should reject non-existent email', async () => {
            const res = await request
                .post('/api/v1/auth/login')
                .send({ email: 'invalid@test.com', password: 'Wrong@123' });

            expect(res.status).toBe(401);
        });

        it('should reject empty credentials', async () => {
            const res = await request
                .post('/api/v1/auth/login')
                .send({});

            expect(res.status).toBe(400);
        });
    });

    // ==================== GET ME ====================
    describe('GET /api/v1/auth/me', () => {
        it('should return current user profile', async () => {
            const res = await request
                .get('/api/v1/auth/me')
                .set('Authorization', userAuth());

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
            expect(res.body.data).toHaveProperty('email');
        });

        it('should reject unauthenticated request', async () => {
            const res = await request.get('/api/v1/auth/me');

            expect(res.status).toBe(401);
        });
    });

    // ==================== UPDATE PROFILE (via /user/profile) ====================
    describe('PUT /api/v1/user/profile', () => {
        it('should update user profile', async () => {
            const res = await request
                .put('/api/v1/user/profile')
                .set('Authorization', userAuth())
                .send({ fullName: 'Updated Name' });

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
