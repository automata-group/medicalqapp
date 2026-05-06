import axios from 'axios';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

const api = axios.create({
    baseURL: BASE_URL,
    headers: { 'Content-Type': 'application/json' },
});

// Attach token to every request
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('adminToken');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

// Redirect to login on 401
api.interceptors.response.use(
    (res) => res,
    (err) => {
        if (err.response?.status === 401) {
            localStorage.removeItem('adminToken');
            window.location.href = '/login';
        }
        return Promise.reject(err);
    }
);

// ─── Auth ──────────────────────────────────────────────────
export const login = (email, password) =>
    api.post('/auth/login', { email, password });

// ─── Users ─────────────────────────────────────────────────
export const getUsers = () => api.get('/admin/users');
export const getUserStats = () => api.get('/admin/users/statistics');
export const updateUserStatus = (id, status) =>
    api.put(`/admin/users/${id}/status`, { status });
export const manageSubscription = (id, data) =>
    api.put(`/admin/users/${id}/subscription`, data);

// ─── Questions ─────────────────────────────────────────────
export const getQuestions = (params) => api.get('/admin/questions', { params });
export const getQuestion = (id) => api.get(`/admin/questions/${id}`);
export const createQuestion = (data) => api.post('/admin/questions', data);
export const updateQuestion = (id, data) => api.put(`/admin/questions/${id}`, data);
export const deleteQuestion = (id) => api.delete(`/admin/questions/${id}`);
export const bulkImportQuestions = (formData) =>
    api.post('/admin/questions/bulk-import', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    });
export const bulkImportDocx = (formData) =>
    api.post('/admin/questions/bulk-import-docx', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    });
export const aiGenerateExplanation = (questionId) =>
    api.post(`/admin/questions/${questionId}/ai-explain`);
export const aiGenerateQuestion = (data) =>
    api.post('/admin/questions/ai-generate', data);

// ─── AI Feedback ──────────────────────────────────────────
export const getAIFeedbacks = () => api.get('/admin/ai/feedbacks');
export const deleteAIFeedback = (id) => api.delete(`/admin/ai/feedbacks/${id}`);
export const cleanupExpiredFeedback = () => api.post('/admin/ai/cleanup');

// ─── Reports ───────────────────────────────────────────────
export const getReports = () => api.get('/admin/reports');
export const updateReportStatus = (id, status) =>
    api.put(`/admin/reports/${id}`, { status });

// ─── Specialties & Topics ─────────────────────────────────────────
export const getSpecialties = () => api.get('/admin/specialties');
export const createSpecialty = (data) => api.post('/admin/specialties', data);
export const updateSpecialty = (id, data) => api.put(`/admin/specialties/${id}`, data);
export const deleteSpecialty = (id) => api.delete(`/admin/specialties/${id}`);
export const uploadSpecialtyImage = (formData) =>
    api.post('/admin/specialties/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    });

export const getTopics = (specialtyId) => {
    const params = specialtyId ? { specialtyId } : {};
    return api.get('/admin/topics', { params });
};
export const getTopic = (id) => api.get(`/admin/topics/${id}`);
export const createTopic = (data) => api.post('/admin/topics', data);
export const updateTopic = (id, data) => api.put(`/admin/topics/${id}`, data);
export const deleteTopic = (id) => api.delete(`/admin/topics/${id}`);

// ─── Analytics ─────────────────────────────────────────────
export const getAnalytics = () => api.get('/admin/analytics');
export const getBusinessAnalytics = () => api.get('/admin/analytics/business');

// ─── Discount Codes ────────────────────────────────────────
export const getDiscountCodes = () => api.get('/admin/discount-codes');
export const createDiscountCode = (data) => api.post('/admin/discount-codes', data);
export const deleteDiscountCode = (id) => api.delete(`/admin/discount-codes/${id}`);

// ─── Notifications ─────────────────────────────────────────
export const sendNotification = (data) => api.post('/admin/notifications/send', data);
export const broadcastNotification = (data) => api.post('/admin/notifications/broadcast', data);

// ─── Subscription Plans ────────────────────────────────────
export const getPlans = () => api.get('/admin/subscription-plans');
export const updatePlan = (id, data) => api.put(`/admin/subscription-plans/${id}`, data);
export const createPlan = (data) => api.post('/admin/subscription-plans', data);
export const deletePlan = (id) => api.delete(`/admin/subscription-plans/${id}`);

// ─── Mock Exams ──────────────────────────────────────────
export const getAdminMockExams = () => api.get('/admin/mock-exams');
export const createMockExam = (data) => api.post('/admin/mock-exams', data);
export const updateMockExam = (id, data) => api.put(`/admin/mock-exams/${id}`, data);
export const deleteMockExam = (id) => api.delete(`/admin/mock-exams/${id}`);
export const aiGenerateMockQuestions = (id, data) => api.post(`/admin/mock-exams/${id}/ai-generate`, data);

// ─── Achievements ─────────────────────────────────────────
export const getAdminAchievements = () => api.get('/admin/achievements');
export const createAchievement = (data) => api.post('/admin/achievements', data);
export const updateAchievement = (id, data) => api.put(`/admin/achievements/${id}`, data);
export const deleteAchievement = (id) => api.delete(`/admin/achievements/${id}`);

export default api;
