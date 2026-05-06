import { useEffect, useState } from 'react';
import { getReports, updateReportStatus } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Reports() {
    const [reports, setReports] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        getReports()
            .then((r) => setReports(r.data?.data || r.data || []))
            .finally(() => setLoading(false));
    }, []);

    async function resolve(id) {
        await updateReportStatus(id, 'resolved');
        setReports((prev) =>
            prev.map((r) => ((r._id || r.id) === id ? { ...r, status: 'resolved' } : r))
        );
    }

    return (
        <div>
            <h2 className={styles.pageTitle}>🚩 User Reports</h2>
            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>Question ID</th>
                            <th>User</th>
                            <th>Reason</th>
                            <th>Details</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="6" style={{ textAlign: 'center', color: '#64748b' }}>Loading…</td></tr>
                        ) : reports.length === 0 ? (
                            <tr><td colSpan="6" style={{ textAlign: 'center', color: '#64748b' }}>No reports found</td></tr>
                        ) : (
                            reports.map((r) => (
                                <tr key={r._id || r.id}>
                                    <td style={{ color: '#94a3b8', fontFamily: 'monospace' }}>{r.questionId?.toString().slice(-6) || '—'}</td>
                                    <td>{r.userId?.name || r.userId?.toString().slice(-6) || 'anon'}</td>
                                    <td>{r.reason || '—'}</td>
                                    <td style={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', color: '#94a3b8' }}>{r.details || '—'}</td>
                                    <td>
                                        <span className={pageStyles.badge} style={{
                                            background: r.status === 'resolved' ? '#05966922' : '#f59e0b22',
                                            color: r.status === 'resolved' ? '#34d399' : '#fbbf24'
                                        }}>
                                            {r.status || 'pending'}
                                        </span>
                                    </td>
                                    <td>
                                        {r.status !== 'resolved' ? (
                                            <button className={`${pageStyles.btn} ${pageStyles.btnSuccess}`} onClick={() => resolve(r._id || r.id)}>
                                                Resolve
                                            </button>
                                        ) : <span style={{ color: '#64748b' }}>Done</span>}
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
