// Push Notification Service using Firebase Admin SDK
// Install: npm install firebase-admin

let admin = null;
let isInitialized = false;

/**
 * Initialize Firebase Admin SDK
 * Requires GOOGLE_APPLICATION_CREDENTIALS env var pointing to service account JSON
 * OR FIREBASE_SERVICE_ACCOUNT env var with the JSON content
 */
function initFirebase() {
    if (isInitialized) return;

    try {
        const firebaseAdmin = require('firebase-admin');

        if (process.env.FIREBASE_SERVICE_ACCOUNT) {
            // Parse service account from env variable
            const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
            firebaseAdmin.initializeApp({
                credential: firebaseAdmin.credential.cert(serviceAccount)
            });
        } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
            // Use file path from env
            firebaseAdmin.initializeApp({
                credential: firebaseAdmin.credential.applicationDefault()
            });
        } else {
            console.warn('[FCM] Firebase not configured. Set FIREBASE_SERVICE_ACCOUNT or GOOGLE_APPLICATION_CREDENTIALS');
            return;
        }

        admin = firebaseAdmin;
        isInitialized = true;
        console.log('[FCM] Firebase Admin SDK initialized successfully');
    } catch (error) {
        console.warn('[FCM] Firebase init failed:', error.message);
    }
}

// Try to initialize on load
initFirebase();

/**
 * Send push notification to a single device
 */
exports.sendPushNotification = async (token, title, body, data = {}) => {
    if (!admin) {
        console.log(`[FCM Mock] → ${token}: ${title} - ${body}`);
        return { success: true, messageId: `mock_${Date.now()}` };
    }

    try {
        const message = {
            token,
            notification: { title, body },
            data: Object.fromEntries(
                Object.entries(data).map(([k, v]) => [k, String(v)])
            ),
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'medical_q_push'
                }
            },
            apns: {
                payload: {
                    aps: { sound: 'default', badge: 1 }
                }
            }
        };

        const response = await admin.messaging().send(message);
        return { success: true, messageId: response };
    } catch (error) {
        console.error('[FCM] Send failed:', error.message);
        return { success: false, error: error.message };
    }
};

/**
 * Send push notification to multiple devices
 */
exports.sendMulticastNotification = async (tokens, title, body, data = {}) => {
    if (!admin || tokens.length === 0) {
        console.log(`[FCM Mock] → ${tokens.length} devices: ${title}`);
        return { success: true, successCount: tokens.length, failureCount: 0 };
    }

    try {
        const message = {
            notification: { title, body },
            data: Object.fromEntries(
                Object.entries(data).map(([k, v]) => [k, String(v)])
            ),
            tokens,
            android: {
                priority: 'high',
                notification: { sound: 'default', channelId: 'medical_q_push' }
            },
            apns: {
                payload: { aps: { sound: 'default', badge: 1 } }
            }
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        return {
            success: true,
            successCount: response.successCount,
            failureCount: response.failureCount
        };
    } catch (error) {
        console.error('[FCM] Multicast failed:', error.message);
        return { success: false, error: error.message };
    }
};

/**
 * Send push notification to a topic (e.g., 'all_users')
 */
exports.sendTopicNotification = async (topic, title, body, data = {}) => {
    if (!admin) {
        console.log(`[FCM Mock] → topic '${topic}': ${title}`);
        return { success: true, messageId: `mock_topic_${Date.now()}` };
    }

    try {
        const message = {
            topic,
            notification: { title, body },
            data: Object.fromEntries(
                Object.entries(data).map(([k, v]) => [k, String(v)])
            ),
            android: {
                priority: 'high',
                notification: { sound: 'default', channelId: 'medical_q_push' }
            },
            apns: {
                payload: { aps: { sound: 'default', badge: 1 } }
            }
        };

        const response = await admin.messaging().send(message);
        return { success: true, messageId: response };
    } catch (error) {
        console.error('[FCM] Topic send failed:', error.message);
        return { success: false, error: error.message };
    }
};

/**
 * Subscribe a token to a topic
 */
exports.subscribeToTopic = async (token, topic) => {
    if (!admin) {
        console.log(`[FCM Mock] Subscribe ${token} to topic '${topic}'`);
        return { success: true };
    }

    try {
        await admin.messaging().subscribeToTopic([token], topic);
        return { success: true };
    } catch (error) {
        console.error('[FCM] Subscribe failed:', error.message);
        return { success: false, error: error.message };
    }
};

/**
 * Unsubscribe a token from a topic
 */
exports.unsubscribeFromTopic = async (token, topic) => {
    if (!admin) {
        console.log(`[FCM Mock] Unsubscribe ${token} from topic '${topic}'`);
        return { success: true };
    }

    try {
        await admin.messaging().unsubscribeFromTopic([token], topic);
        return { success: true };
    } catch (error) {
        console.error('[FCM] Unsubscribe failed:', error.message);
        return { success: false, error: error.message };
    }
};
