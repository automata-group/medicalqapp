import { useEffect, useState } from 'react';
import { getAdminMockExams, createMockExam, updateMockExam, deleteMockExam, getSpecialties, getAdminAchievements, aiGenerateMockQuestions } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function MockExams() {
    const [exams, setExams] = useState([]);
    const [specialties, setSpecialties] = useState([]);
    const [achievements, setAchievements] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isCreating, setIsCreating] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [editId, setEditId] = useState(null);
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        totalQuestions: 0,
        duration: 60,
        isPremium: true,
        specialtyId: '',
        achievementId: ''
    });

    const [aiLoading, setAiLoading] = useState(false);
    const [aiTopic, setAiTopic] = useState('');

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setLoading(true);
        try {
            const [examRes, specRes, achRes] = await Promise.all([
                getAdminMockExams(),
                getSpecialties(),
                getAdminAchievements()
            ]);
            setExams(examRes.data.data);
            setSpecialties(specRes.data.data);
            setAchievements(achRes.data.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        try {
            if (isEditing) {
                await updateMockExam(editId, formData);
            } else {
                await createMockExam(formData);
            }
            resetForm();
            loadData();
        } catch (error) {
            console.error(error);
            alert('Failed to save exam');
        }
    };

    const handleAIGenerate = async () => {
        if (!editId) return alert('Please save the exam first before generating AI questions.');
        if (!confirm(`Generate ${formData.totalQuestions} questions using AI? This may take a minute.`)) return;
        
        setAiLoading(true);
        try {
            const res = await aiGenerateMockQuestions(editId, { 
                count: formData.totalQuestions,
                topic: aiTopic || undefined
            });
            alert(res.data.message);
            loadData();
        } catch (error) {
            console.error(error);
            alert('AI Generation failed: ' + (error.response?.data?.message || error.message));
        } finally {
            setAiLoading(false);
        }
    };

    const resetForm = () => {
        setIsCreating(false);
        setIsEditing(false);
        setEditId(null);
        setAiTopic('');
        setFormData({
            title: '',
            description: '',
            totalQuestions: 0,
            duration: 60,
            isPremium: true,
            specialtyId: '',
            achievementId: ''
        });
    };

    const handleEdit = (exam) => {
        setEditId(exam.id);
        setFormData({
            title: exam.title,
            description: exam.description || '',
            totalQuestions: exam.totalQuestions,
            duration: exam.duration,
            isPremium: exam.isPremium,
            specialtyId: exam.specialtyId || '',
            achievementId: exam.achievementId || ''
        });
        setIsEditing(true);
        setIsCreating(true);
    };

    const handleDelete = async (id) => {
        if (!confirm('Delete this exam?')) return;
        await deleteMockExam(id);
        loadData();
    };

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2 className={styles.pageTitle}>📝 Mock Exams Management</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => isCreating ? resetForm() : setIsCreating(true)}>
                    {isCreating ? 'Cancel' : '+ Create New Mock Exam'}
                </button>
            </div>

            {isCreating && (
                <div style={{ background: '#1e293b', padding: '25px', borderRadius: '12px', marginBottom: '30px', border: '1px solid #334155' }}>
                    <h3 style={{ marginTop: 0, color: '#f8fafc', marginBottom: '20px' }}>{isEditing ? '🔧 Edit Exam Details' : '✨ Create New Exam'}</h3>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
                        <div className={pageStyles.formGroup}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Exam Title</label>
                            <input className={pageStyles.search} placeholder="e.g. Final Cardiology Mock 2026" value={formData.title} onChange={e => setFormData({ ...formData, title: e.target.value })} />
                        </div>

                        <div className={pageStyles.formGroup}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Medical Specialty</label>
                            <select className={pageStyles.search} value={formData.specialtyId} onChange={e => setFormData({ ...formData, specialtyId: e.target.value })}>
                                <option value="">Select Specialty</option>
                                {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                            </select>
                        </div>

                        <div className={pageStyles.formGroup}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Total Questions (Number of questions in this exam)</label>
                            <input className={pageStyles.search} type="number" placeholder="Total Questions" value={formData.totalQuestions} onChange={e => setFormData({ ...formData, totalQuestions: e.target.value })} />
                        </div>

                        <div className={pageStyles.formGroup}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Exam Duration (Time allowed in minutes)</label>
                            <input className={pageStyles.search} type="number" placeholder="Duration (min)" value={formData.duration} onChange={e => setFormData({ ...formData, duration: e.target.value })} />
                        </div>

                        <div className={pageStyles.formGroup}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Success Reward (Achievement to grant upon passing)</label>
                            <select className={pageStyles.search} value={formData.achievementId} onChange={e => setFormData({ ...formData, achievementId: e.target.value })}>
                                <option value="">Select Achievement (Reward)</option>
                                {achievements.map(a => <option key={a.id} value={a.id}>{a.name}</option>)}
                            </select>
                        </div>

                        <div className={pageStyles.formGroup} style={{ display: 'flex', alignItems: 'center', paddingTop: '25px' }}>
                            <label style={{ color: '#cbd5e1', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
                                <input type="checkbox" checked={formData.isPremium} onChange={e => setFormData({ ...formData, isPremium: e.target.checked })} />
                                <span style={{ fontWeight: 600 }}>Premium Exam (Requires Subscription)</span>
                            </label>
                        </div>

                        <div className={pageStyles.formGroup} style={{ gridColumn: 'span 2' }}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Description (Visible to students before starting)</label>
                            <textarea className={pageStyles.search} rows="3" placeholder="Describe what this exam covers..." value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })} />
                        </div>
                    </div>

                    <div style={{ marginTop: '20px', display: 'flex', gap: '15px', borderTop: '1px solid #334155', paddingTop: '20px' }}>
                        <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleSave} style={{ minWidth: '120px' }}>
                            {isEditing ? 'Update Exam' : 'Create Exam'}
                        </button>
                        
                        {isEditing && (
                            <div style={{ flex: 1, display: 'flex', gap: '10px', alignItems: 'center', marginLeft: '20px', padding: '15px', background: 'rgba(99, 102, 241, 0.1)', borderRadius: '8px', border: '1px dashed #6366f1' }}>
                                <div style={{ flex: 1 }}>
                                    <label style={{ color: '#818cf8', fontSize: '11px', fontWeight: 700, textTransform: 'uppercase', marginBottom: '5px', display: 'block' }}>🤖 AI Question Generation</label>
                                    <input 
                                        className={pageStyles.search} 
                                        style={{ height: '35px', fontSize: '13px' }}
                                        placeholder="Specific topic (optional)" 
                                        value={aiTopic} 
                                        onChange={e => setAiTopic(e.target.value)} 
                                    />
                                </div>
                                <button 
                                    className={pageStyles.btn} 
                                    style={{ background: '#6366f1', height: '35px', marginTop: '18px' }}
                                    onClick={handleAIGenerate}
                                    disabled={aiLoading}
                                >
                                    {aiLoading ? 'Generating...' : '🚀 Generate Questions'}
                                </button>
                            </div>
                        )}
                    </div>
                </div>
            )}

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th style={{ width: '60px' }}>ID</th>
                            <th>Title</th>
                            <th>Specialty</th>
                            <th style={{ textAlign: 'center' }}>Questions</th>
                            <th style={{ textAlign: 'center' }}>Duration</th>
                            <th>Status</th>
                            <th>Reward</th>
                            <th style={{ textAlign: 'right' }}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="8" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>Loading exams...</td></tr>
                        ) : exams.length === 0 ? (
                            <tr><td colSpan="8" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>No mock exams found. Create one to get started.</td></tr>
                        ) : (
                            exams.map(e => (
                                <tr key={e.id}>
                                    <td style={{ color: '#64748b' }}>#{e.id}</td>
                                    <td style={{ fontWeight: 600, color: '#f1f5f9' }}>{e.title}</td>
                                    <td><span className={pageStyles.badge} style={{ background: '#1e3a8a', color: '#bfdbfe' }}>{e.specialty?.name || 'N/A'}</span></td>
                                    <td style={{ textAlign: 'center' }}>{e.totalQuestions}</td>
                                    <td style={{ textAlign: 'center' }}>{e.duration}m</td>
                                    <td>
                                        {e.isPremium ? (
                                            <span className={pageStyles.badge} style={{ background: '#4c1d95', color: '#ede9fe' }}>Premium</span>
                                        ) : (
                                            <span className={pageStyles.badge} style={{ background: '#064e3b', color: '#d1fae5' }}>Free</span>
                                        )}
                                    </td>
                                    <td style={{ color: '#94a3b8', fontSize: '13px' }}>{e.achievement?.name || '—'}</td>
                                    <td style={{ textAlign: 'right' }}>
                                        <button className={pageStyles.btn} style={{ background: '#334155', color: '#e2e8f0', marginRight: '8px', fontSize: '12px', padding: '6px 12px' }} onClick={() => handleEdit(e)}>Edit</button>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} style={{ fontSize: '12px', padding: '6px 12px' }} onClick={() => handleDelete(e.id)}>Delete</button>
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
