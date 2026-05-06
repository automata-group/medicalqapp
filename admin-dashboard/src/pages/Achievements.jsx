import { useEffect, useState } from 'react';
import { getAdminAchievements, createAchievement, updateAchievement, deleteAchievement } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Achievements() {
    const [achievements, setAchievements] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isCreating, setIsCreating] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [editId, setEditId] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        slug: '',
        description: '',
        criteriaType: 'mock_score',
        criteriaValue: 50,
        xpReward: 100
    });

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const res = await getAdminAchievements();
            setAchievements(res.data.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        try {
            if (isEditing) {
                await updateAchievement(editId, formData);
            } else {
                await createAchievement(formData);
            }
            resetForm();
            loadData();
        } catch (error) {
            console.error(error);
            alert('Failed to save achievement');
        }
    };

    const resetForm = () => {
        setIsCreating(false);
        setIsEditing(false);
        setEditId(null);
        setFormData({
            name: '',
            slug: '',
            description: '',
            criteriaType: 'mock_score',
            criteriaValue: 50,
            xpReward: 100
        });
    };

    const handleEdit = (ach) => {
        setEditId(ach.id);
        setFormData({
            name: ach.name,
            slug: ach.slug,
            description: ach.description,
            criteriaType: ach.criteriaType,
            criteriaValue: ach.criteriaValue,
            xpReward: ach.xpReward
        });
        setIsEditing(true);
        setIsCreating(true);
    };

    const handleDelete = async (id) => {
        if (!confirm('Delete this achievement?')) return;
        await deleteAchievement(id);
        loadData();
    };

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h2 className={styles.pageTitle}>🏆 Achievements & Rewards</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => isCreating ? resetForm() : setIsCreating(true)}>
                    {isCreating ? 'Cancel' : '+ New Achievement'}
                </button>
            </div>

            {isCreating && (
                <div style={{ background: '#1e293b', padding: 20, borderRadius: 8, marginBottom: 20 }}>
                    <h3 style={{ marginTop: 0, color: '#f8fafc' }}>{isEditing ? 'Edit Achievement' : 'Create New Achievement'}</h3>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 15 }}>
                        <input className={pageStyles.search} placeholder="Name (e.g. Master Surgeon)" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} />
                        <input className={pageStyles.search} placeholder="Slug (e.g. master_surgeon)" value={formData.slug} onChange={e => setFormData({ ...formData, slug: e.target.value })} />
                        <select className={pageStyles.search} value={formData.criteriaType} onChange={e => setFormData({ ...formData, criteriaType: e.target.value })}>
                            <option value="mock_score">Exam Score</option>
                            <option value="questions_solved">Questions Solved</option>
                            <option value="streak_days">Streak Days</option>
                        </select>
                        <input className={pageStyles.search} type="number" placeholder="Criteria Value (e.g. 100)" value={formData.criteriaValue} onChange={e => setFormData({ ...formData, criteriaValue: e.target.value })} />
                        <input className={pageStyles.search} type="number" placeholder="XP Reward" value={formData.xpReward} onChange={e => setFormData({ ...formData, xpReward: e.target.value })} />
                        <textarea className={pageStyles.search} style={{ gridColumn: 'span 2' }} placeholder="Description" value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })} />
                    </div>
                    <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleSave} style={{ marginTop: 15 }}>
                        {isEditing ? 'Update' : 'Save'}
                    </button>
                </div>
            )}

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Criteria</th>
                            <th>XP</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? <tr><td colSpan="5">Loading...</td></tr> : achievements.map(ach => (
                            <tr key={ach.id}>
                                <td>{ach.id}</td>
                                <td>{ach.name}</td>
                                <td>{ach.criteriaType} ({ach.criteriaValue})</td>
                                <td>{ach.xpReward} XP</td>
                                <td>
                                    <button className={pageStyles.btn} style={{ background: '#0ea5e9', marginRight: 5 }} onClick={() => handleEdit(ach)}>Edit</button>
                                    <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={() => handleDelete(ach.id)}>Delete</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
