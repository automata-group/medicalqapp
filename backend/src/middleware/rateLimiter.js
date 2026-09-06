const Redis = require('ioredis');

let redisClient = null;
if (process.env.REDIS_HOST) {
    try {
        redisClient = new Redis({
            host: process.env.REDIS_HOST,
            port: process.env.REDIS_PORT || 6379,
            maxRetriesPerRequest: 1,
            enableOfflineQueue: false
        });
        redisClient.on('error', () => {
            // Silently fallback to in-memory store if Redis is unavailable
        });
    } catch (e) {
        redisClient = null;
    }
}

// In-memory fallback map: key -> { count, resetTime }
const memoryStore = new Map();

/**
 * Creates a rate limiting middleware with Redis support and in-memory fallback
 * @param {Object} options
 * @param {number} options.windowMs - Time window in milliseconds
 * @param {number} options.max - Max requests allowed within windowMs
 * @param {string} options.message - Error message when rate limit is exceeded
 * @param {Function} options.keyGenerator - Function generating a unique key
 */
function createRateLimiter({
    windowMs = 10 * 60 * 1000,
    max = 10,
    message = 'لقد تجاوزت الحد المسموح به من إرسال المساهمات. يرجى الانتظار قليلاً قبل المحاولة مرة أخرى.',
    prefix = 'general',
    keyGenerator = (req) => req.user?.id ? `user:${req.user.id}` : `ip:${req.ip || req.connection?.remoteAddress || 'unknown'}`
} = {}) {
    return async (req, res, next) => {
        const key = `ratelimit:${prefix}:${keyGenerator(req)}`;
        const now = Date.now();

        // 1. Try Redis if connected
        if (redisClient && redisClient.status === 'ready') {
            try {
                const current = await redisClient.incr(key);
                if (current === 1) {
                    await redisClient.pexpire(key, windowMs);
                }
                const ttl = await redisClient.pttl(key);

                res.setHeader('X-RateLimit-Limit', max);
                res.setHeader('X-RateLimit-Remaining', Math.max(0, max - current));
                res.setHeader('X-RateLimit-Reset', Math.ceil((now + ttl) / 1000));

                if (current > max) {
                    return res.status(429).json({
                        success: false,
                        message,
                        code: 'RATE_LIMIT_EXCEEDED',
                        retryAfterSeconds: Math.ceil(ttl / 1000)
                    });
                }
                return next();
            } catch (err) {
                // If Redis fails, fall through to memoryStore
            }
        }

        // 2. In-Memory fallback
        let record = memoryStore.get(key);
        if (!record || now > record.resetTime) {
            record = { count: 1, resetTime: now + windowMs };
            memoryStore.set(key, record);
        } else {
            record.count += 1;
        }

        // Clean up expired keys periodically to prevent memory leaks
        if (memoryStore.size > 2000) {
            for (const [k, val] of memoryStore.entries()) {
                if (now > val.resetTime) memoryStore.delete(k);
            }
        }

        const remaining = Math.max(0, max - record.count);
        res.setHeader('X-RateLimit-Limit', max);
        res.setHeader('X-RateLimit-Remaining', remaining);
        res.setHeader('X-RateLimit-Reset', Math.ceil(record.resetTime / 1000));

        if (record.count > max) {
            const retryAfter = Math.ceil((record.resetTime - now) / 1000);
            return res.status(429).json({
                success: false,
                message,
                code: 'RATE_LIMIT_EXCEEDED',
                retryAfterSeconds: retryAfter
            });
        }

        next();
    };
}

// Preconfigured limiter for question contributions: max 10 per 10 minutes per user
const contributionLimiter = createRateLimiter({
    windowMs: 10 * 60 * 1000, // 10 minutes
    max: 10, // max 10 submissions per 10 minutes
    prefix: 'contribution',
    message: 'لقد قمت بإرسال عدد كبير من الأسئلة في فترة قصيرة. حفاظاً على جودة المنصة، يرجى الانتظار بضع دقائق قبل إرسال المزيد.'
});

module.exports = {
    createRateLimiter,
    contributionLimiter
};
