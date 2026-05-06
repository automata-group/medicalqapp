import { useEffect, useState } from 'react';
import { getAIFeedbacks, deleteAIFeedback, cleanupExpiredFeedback } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function AIInsights() {
    const [feedbacks, setFeedbacks] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadFeedbacks();
    }, []);

    const loadFeedbacks = async () => {
        setLoading(true);
        try {
            const res = await getAIFeedbacks();
            setFeedbacks(res.data?.data || []);
        } catch (err) {
            console.error('Failed to load AI feedbacks', err);
        } finally {
            setLoading(false);
        }
    };

    const remove = async (id) => {
        if (!confirm('Delete this AI insight?')) return;
        try {
            await deleteAIFeedback(id);
            setFeedbacks(prev => prev.filter(f => f.id !== id));
        } catch (error) {
            console.error(error);
            alert('Failed to delete');
        }
    };

    const cleanup = async () => {
        if (!confirm('Cleanup all expired feedbacks?')) return;
        try {
            const res = await cleanupExpiredFeedback();
            alert(res.data?.message || 'Done');
            loadFeedbacks();
        } catch (error) {
            console.error(error);
            alert('Failed to cleanup');
        }
    };

    return (
        <div className={pageStyles.pageContainer}>
            <div className={pageStyles.header}>
                <h2 className={styles.pageTitle}>🤖 AI User Insights</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={cleanup}>
                    🧹 Cleanup Expired
                </button>
            </div>

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Analysis Type</th>
                            <th>Content Snippet</th>
                            <th>Expires</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading...</td></tr>
                        ) : feedbacks.length === 0 ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center' }}>No active AI insights found.</td></tr>
                        ) : (
                            feedbacks.map(f => (
                                <tr key={f.id}>
                                    <td>
                                        <div style={{ fontWeight: 600 }}>{f.user?.fullName}</div>
                                        <div style={{ fontSize: '11px', color: '#64748b' }}>{f.user?.email}</div>
                                    </td>
                                    <td>
                                        <span className={pageStyles.badge} style={{ background: '#1e293b', color: '#94a3b8' }}>
                                            {f.analysisType}
                                        </span>
                                    </td>
                                    <td style={{ maxWidth: '300px' }}>
                                        <div style={{
                                            fontSize: '13px',
                                            color: '#cbd5e1',
                                            overflow: 'hidden',
                                            textOverflow: 'ellipsis',
                                            display: '-webkit-box',
                                            WebkitLineClamp: 2,
                                            WebkitBoxOrient: 'vertical'
                                        }}>
                                            {f.content}
                                        </div>
                                    </td>
                                    <td style={{ fontSize: '12px' }}>
                                        {new Date(f.expiresAt).toLocaleDateString()}
                                    </td>
                                    <td>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger} ${pageStyles.btnSmall}`} onClick={() => remove(f.id)}>
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
