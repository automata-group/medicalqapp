import { useEffect, useState } from 'react';
import { getTopics, createTopic, deleteTopic, getSpecialties } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Topics() {
    const [topics, setTopics] = useState([]);
    const [specialties, setSpecialties] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [isCreating, setIsCreating] = useState(false);
    const [newTopic, setNewTopic] = useState({ name: '', specialtyId: '', isPremium: false });

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
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = async () => {
        if (!newTopic.name || !newTopic.specialtyId) return alert('Name and Category (Specialty) are required');
        try {
            await createTopic(newTopic);
            setIsCreating(false);
            setNewTopic({ name: '', specialtyId: '', isPremium: false });
            loadData();
        } catch (error) {
            console.error(error);
            alert('Failed to create topic');
        }
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this topic?')) return;
        try {
            await deleteTopic(id);
            loadData();
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || 'Failed to delete topic');
        }
    };

    const filtered = topics.filter(t => t.name.toLowerCase().includes(search.toLowerCase()) || (t.specialty?.name && t.specialty.name.toLowerCase().includes(search.toLowerCase())));

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h2 className={styles.pageTitle}>📂 Topics</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => setIsCreating(!isCreating)}>
                    {isCreating ? 'Cancel' : '+ New Topic'}
                </button>
            </div>

            {isCreating && (
                <div style={{ background: '#1e293b', padding: 20, borderRadius: 8, marginBottom: 20 }}>
                    <h3 style={{ marginTop: 0, color: '#f8fafc' }}>Create New Topic</h3>
                    <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
                        <select className={pageStyles.search} value={newTopic.specialtyId} onChange={e => setNewTopic({ ...newTopic, specialtyId: e.target.value })} style={{ cursor: 'pointer' }}>
                            <option value="">Select Category...</option>
                            {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                        </select>
                        <input className={pageStyles.search} placeholder="Name" value={newTopic.name} onChange={e => setNewTopic({ ...newTopic, name: e.target.value })} />
                        <label style={{ color: '#cbd5e1', display: 'flex', alignItems: 'center', gap: '5px', cursor: 'pointer' }}>
                            <input type="checkbox" checked={newTopic.isPremium} onChange={e => setNewTopic({ ...newTopic, isPremium: e.target.checked })} />
                            Premium Content
                        </label>
                        <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleCreate}>Save</button>
                    </div>
                </div>
            )}

            <div className={pageStyles.toolbar}>
                <input className={pageStyles.search} placeholder="Search topics or categories..." value={search} onChange={(e) => setSearch(e.target.value)} />
                <span className={pageStyles.count}>{filtered.length} topics</span>
            </div>

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Topic</th>
                            <th>Questions</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading...</td></tr> : filtered.length === 0 ? <tr><td colSpan="5" style={{ textAlign: 'center' }}>No topics found</td></tr> : (
                            filtered.map(t => (
                                <tr key={t.id}>
                                    <td><span className={pageStyles.badge} style={{ background: '#1e3a5f', color: '#60a5fa' }}>{t.specialty?.name || t.specialtyId}</span></td>
                                    <td>{t.name}</td>
                                    <td>
                                        <span className={pageStyles.badge} style={{ background: '#334155', color: '#e2e8f0' }}>
                                            {t.questionCount || 0} Questions
                                        </span>
                                    </td>
                                    <td>
                                        {t.isPremium ? (
                                            <span className={pageStyles.badge} style={{ background: '#4c1d95', color: '#ddd6fe' }}>Premium</span>
                                        ) : (
                                            <span className={pageStyles.badge} style={{ background: '#14532d', color: '#4ade80' }}>Free</span>
                                        )}
                                    </td>
                                    <td>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={() => handleDelete(t.id)}>Delete</button>
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
