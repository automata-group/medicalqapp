import { useState } from 'react';
import { broadcastNotification } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Notify() {
    const [form, setForm] = useState({ title: '', message: '' });
    const [status, setStatus] = useState('');
    const [loading, setLoading] = useState(false);

    async function handleSend(e) {
        e.preventDefault();
        setLoading(true);
        setStatus('');
        try {
            await broadcastNotification(form);
            setStatus('success');
            setForm({ title: '', message: '' });
        } catch {
            setStatus('error');
        } finally {
            setLoading(false);
        }
    }

    return (
        <div>
            <h2 className={styles.pageTitle}>🔔 Broadcast Notification</h2>

            {status === 'success' && (
                <div style={{ background: '#05966922', border: '1px solid #059669', borderRadius: 10, padding: '12px 16px', color: '#34d399', marginBottom: 20 }}>
                    ✅ Notification sent successfully to all users!
                </div>
            )}
            {status === 'error' && (
                <div style={{ background: '#ef444422', border: '1px solid #ef4444', borderRadius: 10, padding: '12px 16px', color: '#fca5a5', marginBottom: 20 }}>
                    ❌ Failed to send notification. Check if Firebase is configured.
                </div>
            )}

            <div style={{ background: '#161b27', border: '1px solid #1e293b', borderRadius: 14, padding: 24, maxWidth: 520 }}>
                <form className={pageStyles.form} onSubmit={handleSend}>
                    <div>
                        <label className={pageStyles.label}>Notification Title</label>
                        <input className={pageStyles.input} placeholder="New feature available!" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} required />
                    </div>
                    <div>
                        <label className={pageStyles.label}>Message Body</label>
                        <textarea className={`${pageStyles.input} ${pageStyles.textarea}`} placeholder="Tell your users something important…" value={form.message} onChange={(e) => setForm({ ...form, message: e.target.value })} required />
                    </div>

                    {/* Preview card */}
                    {(form.title || form.message) && (
                        <div style={{ background: '#0f172a', borderRadius: 12, padding: 16, border: '1px solid #1e293b' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                                <span style={{ fontSize: 14 }}>🔔</span>
                                <span style={{ color: '#64748b', fontSize: 12 }}>Medical Q · Preview</span>
                            </div>
                            <div style={{ color: '#f1f5f9', fontWeight: 600, fontSize: 15 }}>{form.title || '…'}</div>
                            <div style={{ color: '#94a3b8', fontSize: 14, marginTop: 4 }}>{form.message || '…'}</div>
                        </div>
                    )}

                    <button type="submit" className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} disabled={loading} style={{ width: '100%', padding: 12 }}>
                        {loading ? 'Sending…' : '🚀 Broadcast to All Users'}
                    </button>
                </form>
            </div>
        </div>
    );
}
