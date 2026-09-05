import { useEffect, useState, useMemo } from 'react';
import { getTopics, createTopic, deleteTopic, getSpecialties } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Topics() {
    const [topics, setTopics] = useState([]);
    const [specialties, setSpecialties] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [selectedSpecialty, setSelectedSpecialty] = useState('');
    const [selectedStatus, setSelectedStatus] = useState('');
    const [isCreating, setIsCreating] = useState(false);
    const [newTopic, setNewTopic] = useState({ name: '', specialtyId: '', isPremium: false });

    // Pagination State
    const [page, setPage] = useState(1);
    const pageSize = 15;

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const [topicsRes, specRes] = await Promise.all([
                getTopics(),
                getSpecialties()
            ]);
            setTopics(topicsRes.data?.data || []);
            setSpecialties(specRes.data?.data || []);
        } catch (err) {
            console.error('Failed to load topics', err);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = async () => {
        if (!newTopic.name.trim() || !newTopic.specialtyId) {
            return alert('Name and Category (Specialty) are required');
        }
        try {
            await createTopic({
                name: newTopic.name.trim(),
                specialtyId: parseInt(newTopic.specialtyId),
                isPremium: Boolean(newTopic.isPremium)
            });
            setIsCreating(false);
            setNewTopic({ name: '', specialtyId: '', isPremium: false });
            loadData();
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || 'Failed to create topic');
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this topic? Ensure no questions are currently attached.')) return;
        try {
            await deleteTopic(id);
            loadData();
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || 'Failed to delete topic');
        }
    };

    // Filter topics globally across all fields
    const filteredTopics = useMemo(() => {
        return topics.filter(t => {
            const matchesCategory = !selectedSpecialty || 
                String(t.specialtyId) === String(selectedSpecialty) || 
                String(t.specialty?.id) === String(selectedSpecialty);
            
            const matchesStatus = !selectedStatus || 
                (selectedStatus === 'premium' && t.isPremium) || 
                (selectedStatus === 'free' && !t.isPremium);

            const q = search.trim().toLowerCase();
            const matchesSearch = !q || 
                t.name.toLowerCase().includes(q) || 
                (t.specialty?.name && t.specialty.name.toLowerCase().includes(q)) ||
                (t.isPremium ? 'premium' : 'free').includes(q);

            return matchesCategory && matchesStatus && matchesSearch;
        });
    }, [topics, selectedSpecialty, selectedStatus, search]);

    // Reset pagination to page 1 on filter changes
    useEffect(() => {
        setPage(1);
    }, [search, selectedSpecialty, selectedStatus]);

    const totalPages = Math.ceil(filteredTopics.length / pageSize) || 1;
    const pagedTopics = useMemo(() => {
        const start = (page - 1) * pageSize;
        return filteredTopics.slice(start, start + pageSize);
    }, [filteredTopics, page, pageSize]);

    return (
        <div className={pageStyles.pageContainer}>
            <div className={pageStyles.header}>
                <h2 className={styles.pageTitle}>📂 Topics Management</h2>
                <button
                    className={`${pageStyles.btn}`}
                    style={{
                        background: isCreating ? '#334155' : 'linear-gradient(135deg, #3b82f6, #2563eb)',
                        color: '#fff',
                        boxShadow: isCreating ? 'none' : '0 4px 12px rgba(59, 130, 246, 0.35)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px'
                    }}
                    onClick={() => setIsCreating(!isCreating)}
                >
                    {isCreating ? '✕ Cancel' : '+ New Topic'}
                </button>
            </div>

            {isCreating && (
                <div style={{
                    background: '#0f172a',
                    padding: '24px',
                    borderRadius: '16px',
                    marginBottom: '24px',
                    border: '1px solid #1e293b',
                    boxShadow: '0 10px 25px rgba(0,0,0,0.3)'
                }}>
                    <h3 style={{ marginTop: 0, marginBottom: '16px', color: '#f8fafc', fontSize: '16px' }}>Create New Topic</h3>
                    <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
                        <select
                            className={pageStyles.select}
                            value={newTopic.specialtyId}
                            onChange={e => setNewTopic({ ...newTopic, specialtyId: e.target.value })}
                            style={{ cursor: 'pointer', minWidth: '200px' }}
                        >
                            <option value="">Select Specialty / Category...</option>
                            {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                        </select>
                        <input
                            className={pageStyles.search}
                            placeholder="Topic Name (e.g. Frenum Management)"
                            value={newTopic.name}
                            onChange={e => setNewTopic({ ...newTopic, name: e.target.value })}
                            style={{ flex: 1, minWidth: '250px' }}
                        />
                        <label style={{
                            color: '#cbd5e1',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px',
                            cursor: 'pointer',
                            background: '#1e293b',
                            padding: '8px 14px',
                            borderRadius: '10px',
                            border: '1px solid #334155'
                        }}>
                            <input
                                type="checkbox"
                                checked={newTopic.isPremium}
                                onChange={e => setNewTopic({ ...newTopic, isPremium: e.target.checked })}
                            />
                            <span style={{ fontSize: '13px', fontWeight: 600 }}>Premium Content</span>
                        </label>
                        <button
                            className={`${pageStyles.btn}`}
                            style={{
                                background: 'linear-gradient(135deg, #10b981, #059669)',
                                color: '#fff',
                                padding: '9px 20px',
                                borderRadius: '10px',
                                fontWeight: 700
                            }}
                            onClick={handleCreate}
                        >
                            Save Topic
                        </button>
                    </div>
                </div>
            )}

            {/* Filter Toolbar */}
            <div className={pageStyles.toolbar}>
                <div className={pageStyles.filters} style={{ display: 'flex', gap: '12px', flex: 1, flexWrap: 'wrap' }}>
                    <input
                        className={pageStyles.search}
                        placeholder="🔍 Search topics or categories..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        style={{ minWidth: '260px' }}
                    />
                    <select
                        className={pageStyles.select}
                        value={selectedSpecialty}
                        onChange={(e) => setSelectedSpecialty(e.target.value)}
                    >
                        <option value="">All Categories ({specialties.length})</option>
                        {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                    </select>
                    <select
                        className={pageStyles.select}
                        value={selectedStatus}
                        onChange={(e) => setSelectedStatus(e.target.value)}
                    >
                        <option value="">All Statuses</option>
                        <option value="free">Free</option>
                        <option value="premium">Premium</option>
                    </select>
                    {(search || selectedSpecialty || selectedStatus) && (
                        <button
                            className={`${pageStyles.btn}`}
                            style={{ background: '#334155', color: '#94a3b8' }}
                            onClick={() => { setSearch(''); setSelectedSpecialty(''); setSelectedStatus(''); }}
                        >
                            ✕ Clear Filters
                        </button>
                    )}
                </div>
                <span className={pageStyles.count}>
                    Showing {pagedTopics.length} of {filteredTopics.length} topics (Total: {topics.length})
                </span>
            </div>

            {/* Topics Table */}
            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Topic</th>
                            <th style={{ textAlign: 'center' }}>Questions Attached</th>
                            <th style={{ textAlign: 'center' }}>Access Status</th>
                            <th style={{ textAlign: 'center' }}>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', color: '#64748b', padding: '30px' }}>Loading topics...</td></tr>
                        ) : pagedTopics.length === 0 ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', color: '#64748b', padding: '30px' }}>No topics match your search or filter</td></tr>
                        ) : (
                            pagedTopics.map(t => (
                                <tr key={t.id}>
                                    <td>
                                        <span className={pageStyles.badge} style={{ background: '#1e3a5f', color: '#60a5fa' }}>
                                            {t.specialty?.name || t.specialtyId}
                                        </span>
                                    </td>
                                    <td style={{ fontWeight: 600, color: '#f1f5f9' }}>{t.name}</td>
                                    <td style={{ textAlign: 'center' }}>
                                        <span className={pageStyles.badge} style={{
                                            background: (t.questionCount && t.questionCount > 0) ? '#064e3b' : '#334155',
                                            color: (t.questionCount && t.questionCount > 0) ? '#34d399' : '#94a3b8',
                                            fontWeight: 700
                                        }}>
                                            {t.questionCount || 0} Questions
                                        </span>
                                    </td>
                                    <td style={{ textAlign: 'center' }}>
                                        {t.isPremium ? (
                                            <span className={pageStyles.badge} style={{ background: '#4c1d95', color: '#ddd6fe' }}>Premium</span>
                                        ) : (
                                            <span className={pageStyles.badge} style={{ background: '#14532d', color: '#4ade80' }}>Free</span>
                                        )}
                                    </td>
                                    <td style={{ textAlign: 'center' }}>
                                        <button
                                            className={`${pageStyles.btn} ${pageStyles.btnDanger}`}
                                            onClick={() => handleDelete(t.id)}
                                            title="Delete topic"
                                        >
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination Controls */}
            {totalPages > 1 && (
                <div style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    marginTop: '20px',
                    padding: '12px 16px',
                    background: '#0f172a',
                    borderRadius: '12px',
                    border: '1px solid #1e293b'
                }}>
                    <button
                        className={pageStyles.btn}
                        disabled={page === 1}
                        onClick={() => setPage(p => Math.max(1, p - 1))}
                        style={{
                            opacity: page === 1 ? 0.4 : 1,
                            cursor: page === 1 ? 'not-allowed' : 'pointer',
                            background: '#1e293b',
                            color: '#cbd5e1'
                        }}
                    >
                        ← Previous
                    </button>
                    <span style={{ color: '#94a3b8', fontSize: '14px' }}>
                        Page <strong style={{ color: '#f8fafc' }}>{page}</strong> of <strong style={{ color: '#f8fafc' }}>{totalPages}</strong> ({filteredTopics.length} topics)
                    </span>
                    <button
                        className={pageStyles.btn}
                        disabled={page === totalPages}
                        onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                        style={{
                            opacity: page === totalPages ? 0.4 : 1,
                            cursor: page === totalPages ? 'not-allowed' : 'pointer',
                            background: '#1e293b',
                            color: '#cbd5e1'
                        }}
                    >
                        Next →
                    </button>
                </div>
            )}
        </div>
    );
}
