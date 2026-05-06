import { useEffect, useState } from 'react';
import { getUsers, manageSubscription } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Users() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');

    useEffect(() => {
        getUsers()
            .then((r) => setUsers(r.data?.data || r.data || []))
            .finally(() => setLoading(false));
    }, []);

    async function togglePro(user) {
        const newStatus = !user.isPremium;
        await manageSubscription(user._id || user.id, { isPremium: newStatus });
        setUsers((prev) =>
            prev.map((u) =>
                (u._id || u.id) === (user._id || user.id)
                    ? { ...u, isPremium: newStatus }
                    : u
            )
        );
    }

    const filtered = users.filter(
        (u) =>
            (u.name || u.fullName || '').toLowerCase().includes(search.toLowerCase()) ||
            (u.email || '').toLowerCase().includes(search.toLowerCase())
    );

    return (
        <div>
            <h2 className={styles.pageTitle}>👤 User Management</h2>
            <div className={pageStyles.toolbar}>
                <input
                    className={pageStyles.search}
                    placeholder="Search by name or email…"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                />
                <span className={pageStyles.count}>{filtered.length} users</span>
            </div>
            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Joined</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="6" style={{ textAlign: 'center', color: '#64748b' }}>Loading…</td></tr>
                        ) : filtered.length === 0 ? (
                            <tr><td colSpan="6" style={{ textAlign: 'center', color: '#64748b' }}>No users found</td></tr>
                        ) : (
                            filtered.map((u) => (
                                <tr key={u._id || u.id}>
                                    <td>{u.fullName || u.name}</td>
                                    <td style={{ color: '#94a3b8' }}>{u.email}</td>
                                    <td>
                                        <span className={pageStyles.badge} style={{ background: u.role === 'admin' ? '#7c3aed22' : '#1e293b', color: u.role === 'admin' ? '#a78bfa' : '#94a3b8' }}>
                                            {u.role || 'user'}
                                        </span>
                                    </td>
                                    <td>
                                        <span className={pageStyles.badge} style={{ background: u.isPremium ? '#059669' + '22' : '#1e293b', color: u.isPremium ? '#34d399' : '#64748b' }}>
                                            {u.isPremium ? '⭐ PRO' : 'Free'}
                                        </span>
                                    </td>
                                    <td style={{ color: '#64748b' }}>{u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '—'}</td>
                                    <td>
                                        <button className={`${pageStyles.btn} ${u.isPremium ? pageStyles.btnDanger : pageStyles.btnPrimary}`} onClick={() => togglePro(u)}>
                                            {u.isPremium ? 'Revoke PRO' : 'Grant PRO'}
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
