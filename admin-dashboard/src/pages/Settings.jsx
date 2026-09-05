import { useState, useEffect } from 'react';
import { getSystemSettings, updateSystemSettings } from '../api/api';

export default function Settings() {
    const [settings, setSettings] = useState({
        appName: 'SDLE',
        maintenanceMode: false,
        allowRegistration: true,
        defaultLanguage: 'ar',
        showQuestionCount: false,
    });
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState({ type: '', text: '' });

    useEffect(() => {
        loadSettings();
    }, []);

    async function loadSettings() {
        setLoading(true);
        try {
            const res = await getSystemSettings();
            if (res.data?.success && res.data?.data) {
                setSettings((prev) => ({ ...prev, ...res.data.data }));
            }
        } catch (err) {
            console.error('Failed to load system settings:', err);
            setMessage({ type: 'error', text: 'فشل تحميل إعدادات النظام' });
        } finally {
            setLoading(false);
        }
    }

    async function handleSave(e) {
        if (e) e.preventDefault();
        setSaving(true);
        setMessage({ type: '', text: '' });
        try {
            const res = await updateSystemSettings(settings);
            if (res.data?.success) {
                setMessage({ type: 'success', text: '✅ تم حفظ الإعدادات بنجاح!' });
                if (res.data?.data) {
                    setSettings((prev) => ({ ...prev, ...res.data.data }));
                }
            } else {
                setMessage({ type: 'error', text: res.data?.message || 'حدث خطأ أثناء الحفظ' });
            }
        } catch (err) {
            console.error('Error saving settings:', err);
            setMessage({ type: 'error', text: 'فشل الاتصال بالخادم لحفظ الإعدادات' });
        } finally {
            setSaving(false);
            setTimeout(() => {
                setMessage({ type: '', text: '' });
            }, 4000);
        }
    }

    const cardStyle = {
        background: '#161b27',
        border: '1px solid #1e293b',
        borderRadius: '16px',
        padding: '24px',
        marginBottom: '20px',
    };

    const toggleWrapperStyle = {
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '16px 0',
        borderBottom: '1px solid #1e293b',
    };

    const switchStyle = (active) => ({
        position: 'relative',
        width: '52px',
        height: '28px',
        borderRadius: '14px',
        background: active ? '#22c55e' : '#334155',
        cursor: 'pointer',
        transition: 'background 0.2s ease',
        border: 'none',
        padding: '2px',
        display: 'inline-flex',
        alignItems: 'center',
    });

    const knobStyle = (active) => ({
        width: '24px',
        height: '24px',
        borderRadius: '50%',
        background: '#ffffff',
        transform: active ? 'translateX(24px)' : 'translateX(0)',
        transition: 'transform 0.2s ease',
        boxShadow: '0 2px 4px rgba(0,0,0,0.3)',
    });

    if (loading) {
        return (
            <div style={{ color: '#94a3b8', padding: '40px', textAlign: 'center' }}>
                جاري تحميل الإعدادات...
            </div>
        );
    }

    return (
        <div style={{ maxWidth: '900px', margin: '0 auto', paddingBottom: '60px' }}>
            {/* Header */}
            <div style={{ marginBottom: '24px' }}>
                <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#f8fafc', margin: '0 0 8px 0' }}>
                    ⚙️ إعدادات النظام والتطبيق (System Settings)
                </h1>
                <p style={{ color: '#94a3b8', fontSize: '14px', margin: 0 }}>
                    التحكم في خيارات العرض العامة، عدد الأسئلة، وسلوك التطبيق للمستخدمين.
                </p>
            </div>

            {/* Notification message */}
            {message.text && (
                <div
                    style={{
                        padding: '12px 20px',
                        borderRadius: '10px',
                        marginBottom: '20px',
                        fontSize: '14px',
                        fontWeight: '500',
                        background: message.type === 'success' ? '#052e16' : '#450a0a',
                        color: message.type === 'success' ? '#4ade80' : '#f87171',
                        border: `1px solid ${message.type === 'success' ? '#166534' : '#991b1b'}`,
                    }}
                >
                    {message.text}
                </div>
            )}

            {/* Section 1: Question Count Display (The requested feature) */}
            <div style={cardStyle}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
                    <span style={{ fontSize: '20px' }}>📊</span>
                    <h2 style={{ fontSize: '18px', fontWeight: '600', color: '#f8fafc', margin: 0 }}>
                        عرض عدد الأسئلة في التطبيق (Question Counts Visibility)
                    </h2>
                </div>

                <div style={toggleWrapperStyle}>
                    <div style={{ maxWidth: '75%' }}>
                        <div style={{ color: '#f8fafc', fontWeight: '600', fontSize: '15px', marginBottom: '4px' }}>
                            إظهار عدد الأسئلة للمستخدمين (Show Question Counts)
                        </div>
                        <div style={{ color: '#94a3b8', fontSize: '13px', lineHeight: '1.5' }}>
                            عند إيقاف هذا الخيار، سيتم إخفاء أعداد الأسئلة في الشاشة الرئيسية وقائمة التخصصات والمكتبة وشاشة الاختبار.
                            (يُنصح بإيقافه أثناء فترة الانطلاق التجريبية وتفعيله عند رفع كميات أسئلة كبيرة).
                        </div>
                    </div>
                    <button
                        type="button"
                        style={switchStyle(settings.showQuestionCount)}
                        onClick={() =>
                            setSettings((prev) => ({
                                ...prev,
                                showQuestionCount: !prev.showQuestionCount,
                            }))
                        }
                    >
                        <div style={knobStyle(settings.showQuestionCount)} />
                    </button>
                </div>

                <div style={{ marginTop: '16px', padding: '12px 16px', background: '#0f172a', borderRadius: '10px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span style={{ fontSize: '16px' }}>💡</span>
                    <span style={{ color: '#cbd5e1', fontSize: '13px' }}>
                        الحالة الحالية: <strong>{settings.showQuestionCount ? '🟢 أعداد الأسئلة ظاهرة في التطبيق' : '🔒 أعداد الأسئلة مخفية للمستخدمين'}</strong>
                    </span>
                </div>
            </div>

            {/* Section 2: General Application Settings */}
            <div style={cardStyle}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
                    <span style={{ fontSize: '20px' }}>📱</span>
                    <h2 style={{ fontSize: '18px', fontWeight: '600', color: '#f8fafc', margin: 0 }}>
                        إعدادات عامة للتطبيق (General App Settings)
                    </h2>
                </div>

                <div style={toggleWrapperStyle}>
                    <div>
                        <div style={{ color: '#f8fafc', fontWeight: '600', fontSize: '15px', marginBottom: '4px' }}>
                            السماح بالتسجيل الجديد (Allow Registration)
                        </div>
                        <div style={{ color: '#94a3b8', fontSize: '13px' }}>
                            تمكين أو تعطيل إنشاء حسابات جديدة للمستخدمين.
                        </div>
                    </div>
                    <button
                        type="button"
                        style={switchStyle(settings.allowRegistration)}
                        onClick={() =>
                            setSettings((prev) => ({
                                ...prev,
                                allowRegistration: !prev.allowRegistration,
                            }))
                        }
                    >
                        <div style={knobStyle(settings.allowRegistration)} />
                    </button>
                </div>

                <div style={{ ...toggleWrapperStyle, borderBottom: 'none' }}>
                    <div>
                        <div style={{ color: '#f8fafc', fontWeight: '600', fontSize: '15px', marginBottom: '4px' }}>
                            وضع الصيانة (Maintenance Mode)
                        </div>
                        <div style={{ color: '#94a3b8', fontSize: '13px' }}>
                            إظهار شاشة الصيانة للمستخدمين عند إجراء تحديثات على النظام.
                        </div>
                    </div>
                    <button
                        type="button"
                        style={switchStyle(settings.maintenanceMode)}
                        onClick={() =>
                            setSettings((prev) => ({
                                ...prev,
                                maintenanceMode: !prev.maintenanceMode,
                            }))
                        }
                    >
                        <div style={knobStyle(settings.maintenanceMode)} />
                    </button>
                </div>
            </div>

            {/* Save Button */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '24px' }}>
                <button
                    onClick={handleSave}
                    disabled={saving}
                    style={{
                        padding: '12px 32px',
                        background: '#2563eb',
                        color: '#ffffff',
                        border: 'none',
                        borderRadius: '12px',
                        fontSize: '15px',
                        fontWeight: '600',
                        cursor: saving ? 'not-allowed' : 'pointer',
                        opacity: saving ? 0.7 : 1,
                        boxShadow: '0 4px 12px rgba(37, 99, 235, 0.3)',
                        transition: 'all 0.2s',
                    }}
                >
                    {saving ? 'جاري الحفظ...' : '💾 حفظ التغييرات'}
                </button>
            </div>
        </div>
    );
}
