import { useEffect, useState } from 'react';
import { 
    getAdminMockExams, 
    createMockExam, 
    updateMockExam, 
    deleteMockExam, 
    getSpecialties, 
    getTopics,
    getAdminAchievements, 
    aiGenerateMockQuestions,
    getMockExamQuestions,
    addMockQuestionsFromBank,
    addCustomMockQuestion,
    deleteMockQuestion,
    getQuestions
} from '../api/api';
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

    // Attached Questions State
    const [examQuestions, setExamQuestions] = useState([]);
    const [loadingQuestions, setLoadingQuestions] = useState(false);

    // Question Bank Modal State
    const [showBankModal, setShowBankModal] = useState(false);
    const [bankQuestions, setBankQuestions] = useState([]);
    const [bankLoading, setBankLoading] = useState(false);
    const [bankSearch, setBankSearch] = useState('');
    const [bankSpecialtyId, setBankSpecialtyId] = useState('');
    const [bankTopicId, setBankTopicId] = useState('');
    const [bankTopics, setBankTopics] = useState([]);
    const [bankPage, setBankPage] = useState(1);
    const [bankTotalPages, setBankTotalPages] = useState(1);
    const [bankTotalCount, setBankTotalCount] = useState(0);
    const [selectedBankIds, setSelectedBankIds] = useState([]);
    const [importingBank, setImportingBank] = useState(false);

    // Custom Question Modal State
    const [showCustomModal, setShowCustomModal] = useState(false);
    const [savingCustom, setSavingCustom] = useState(false);
    const [customQuestion, setCustomQuestion] = useState({
        text: '',
        difficulty: 'medium',
        options: [
            { text: '', isCorrect: true },
            { text: '', isCorrect: false },
            { text: '', isCorrect: false },
            { text: '', isCorrect: false }
        ],
        explanation: { text: '', references: '' }
    });

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

    const loadExamQuestions = async (examId) => {
        setLoadingQuestions(true);
        try {
            const res = await getMockExamQuestions(examId);
            setExamQuestions(res.data.data || []);
            // Keep total questions aligned
            setFormData(prev => ({ ...prev, totalQuestions: res.data.count }));
        } catch (err) {
            console.error('Failed to load exam questions:', err);
        } finally {
            setLoadingQuestions(false);
        }
    };

    const handleSave = async () => {
        try {
            if (isEditing) {
                await updateMockExam(editId, formData);
            } else {
                const res = await createMockExam(formData);
                if (res.data?.data?.id) {
                    setEditId(res.data.data.id);
                    setIsEditing(true);
                    loadExamQuestions(res.data.data.id);
                }
            }
            loadData();
            if (!isEditing) {
                alert('Exam created successfully! You can now add questions to it below.');
            } else {
                alert('Exam updated successfully!');
            }
        } catch (error) {
            console.error(error);
            alert('Failed to save exam: ' + (error.response?.data?.message || error.message));
        }
    };

    const handleAIGenerate = async () => {
        if (!editId) return alert('Please save the exam first before generating AI questions.');
        const countToGen = parseInt(prompt('How many questions would you like AI to generate?', formData.totalQuestions || 5)) || 5;
        if (!confirm(`Generate ${countToGen} questions using AI? This may take a minute.`)) return;
        
        setAiLoading(true);
        try {
            const res = await aiGenerateMockQuestions(editId, { 
                count: countToGen,
                topic: aiTopic || undefined
            });
            alert(res.data.message);
            loadExamQuestions(editId);
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
        setExamQuestions([]);
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
        loadExamQuestions(exam.id);
    };

    const handleDelete = async (id) => {
        if (!confirm('Delete this exam? All attached mock questions will be removed.')) return;
        await deleteMockExam(id);
        if (editId === id) resetForm();
        loadData();
    };

    const handleRemoveQuestion = async (questionId) => {
        if (!confirm('Remove this question from the mock exam?')) return;
        try {
            const res = await deleteMockQuestion(editId, questionId);
            setExamQuestions(prev => prev.filter(q => q.id !== questionId));
            setFormData(prev => ({ ...prev, totalQuestions: res.data.totalQuestions }));
            loadData();
        } catch (err) {
            console.error(err);
            alert('Failed to remove question: ' + (err.response?.data?.message || err.message));
        }
    };

    // ─── Question Bank Modal Handlers ─────────────────────────
    const openBankModal = () => {
        setBankSpecialtyId(formData.specialtyId || '');
        setBankTopicId('');
        setBankSearch('');
        setBankPage(1);
        setSelectedBankIds([]);
        setShowBankModal(true);
        fetchBankTopics(formData.specialtyId || '');
        fetchBankQuestions({ 
            page: 1, 
            specialtyId: formData.specialtyId || '', 
            topicId: '', 
            search: '' 
        });
    };

    const fetchBankTopics = async (specId) => {
        if (!specId) {
            setBankTopics([]);
            return;
        }
        try {
            const res = await getTopics(specId);
            setBankTopics(res.data.data || []);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchBankQuestions = async ({ page = 1, specialtyId = bankSpecialtyId, topicId = bankTopicId, search = bankSearch }) => {
        setBankLoading(true);
        try {
            const params = {
                page,
                limit: 8,
                specialtyId: specialtyId || undefined,
                topicId: topicId || undefined,
                search: search ? search.trim() : undefined
            };
            const res = await getQuestions(params);
            setBankQuestions(res.data.data || []);
            setBankTotalPages(res.data.totalPages || 1);
            setBankTotalCount(res.data.count || 0);
            setBankPage(page);
        } catch (err) {
            console.error('Failed to load bank questions:', err);
        } finally {
            setBankLoading(false);
        }
    };

    const handleBankSearchSubmit = (e) => {
        e.preventDefault();
        fetchBankQuestions({ page: 1 });
    };

    const toggleBankSelect = (id) => {
        setSelectedBankIds(prev => 
            prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
        );
    };

    const toggleSelectAllOnPage = () => {
        const pageIds = bankQuestions.map(q => q.id);
        const allSelected = pageIds.every(id => selectedBankIds.includes(id));
        if (allSelected) {
            setSelectedBankIds(prev => prev.filter(id => !pageIds.includes(id)));
        } else {
            const newSet = new Set([...selectedBankIds, ...pageIds]);
            setSelectedBankIds(Array.from(newSet));
        }
    };

    const handleImportFromBank = async () => {
        if (selectedBankIds.length === 0) return alert('Please select at least one question to import.');
        setImportingBank(true);
        try {
            const res = await addMockQuestionsFromBank(editId, { questionIds: selectedBankIds });
            alert(res.data.message || `Imported ${res.data.count} questions!`);
            setShowBankModal(false);
            loadExamQuestions(editId);
            loadData();
        } catch (err) {
            console.error(err);
            alert('Failed to import questions: ' + (err.response?.data?.message || err.message));
        } finally {
            setImportingBank(false);
        }
    };

    // ─── Custom Question Modal Handlers ───────────────────────
    const openCustomModal = () => {
        setCustomQuestion({
            text: '',
            difficulty: 'medium',
            options: [
                { text: '', isCorrect: true },
                { text: '', isCorrect: false },
                { text: '', isCorrect: false },
                { text: '', isCorrect: false }
            ],
            explanation: { text: '', references: '' }
        });
        setShowCustomModal(true);
    };

    const handleCustomOptionChange = (index, field, value) => {
        setCustomQuestion(prev => {
            const newOpts = [...prev.options];
            if (field === 'isCorrect') {
                newOpts.forEach((opt, idx) => {
                    opt.isCorrect = idx === index;
                });
            } else {
                newOpts[index][field] = value;
            }
            return { ...prev, options: newOpts };
        });
    };

    const handleSaveCustomQuestion = async (e) => {
        e.preventDefault();
        if (!customQuestion.text.trim()) {
            return alert('Please enter question text.');
        }
        for (let i = 0; i < customQuestion.options.length; i++) {
            if (!customQuestion.options[i].text.trim()) {
                return alert(`Option ${String.fromCharCode(65 + i)} cannot be empty.`);
            }
        }
        if (!customQuestion.options.some(o => o.isCorrect)) {
            return alert('Please select which option is the correct answer.');
        }

        setSavingCustom(true);
        try {
            await addCustomMockQuestion(editId, {
                ...customQuestion,
                specialtyId: formData.specialtyId || undefined
            });
            setShowCustomModal(false);
            loadExamQuestions(editId);
            loadData();
        } catch (err) {
            console.error(err);
            alert('Failed to add question: ' + (err.response?.data?.message || err.message));
        } finally {
            setSavingCustom(false);
        }
    };

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <h2 className={styles.pageTitle}>📝 Mock Exams Management</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => isCreating ? resetForm() : setIsCreating(true)}>
                    {isCreating ? 'Cancel / Close Form' : '+ Create New Mock Exam'}
                </button>
            </div>

            {isCreating && (
                <div style={{ background: '#1e293b', padding: '25px', borderRadius: '12px', marginBottom: '30px', border: '1px solid #334155' }}>
                    <h3 style={{ marginTop: 0, color: '#f8fafc', marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                        {isEditing ? '🔧 Edit Exam Details & Manage Questions' : '✨ Create New Exam'}
                    </h3>
                    
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
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Total Questions (Calculated automatically when adding questions)</label>
                            <input className={pageStyles.search} type="number" placeholder="Total Questions" value={formData.totalQuestions} onChange={e => setFormData({ ...formData, totalQuestions: parseInt(e.target.value) || 0 })} />
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

                    <div style={{ marginTop: '20px', display: 'flex', gap: '15px', borderTop: '1px solid #334155', paddingTop: '20px', flexWrap: 'wrap', alignItems: 'center' }}>
                        <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleSave} style={{ minWidth: '130px' }}>
                            {isEditing ? 'Update Exam' : 'Create Exam'}
                        </button>
                        
                        {isEditing && (
                            <div style={{ flex: 1, minWidth: '320px', display: 'flex', gap: '10px', alignItems: 'center', padding: '12px 16px', background: 'rgba(99, 102, 241, 0.1)', borderRadius: '8px', border: '1px dashed #6366f1' }}>
                                <div style={{ flex: 1 }}>
                                    <label style={{ color: '#818cf8', fontSize: '11px', fontWeight: 700, textTransform: 'uppercase', marginBottom: '4px', display: 'block' }}>🤖 AI Question Generation</label>
                                    <input 
                                        className={pageStyles.search} 
                                        style={{ height: '34px', fontSize: '13px', width: '100%', maxWidth: 'none' }}
                                        placeholder="Specific topic (optional)" 
                                        value={aiTopic} 
                                        onChange={e => setAiTopic(e.target.value)} 
                                    />
                                </div>
                                <button 
                                    className={pageStyles.btn} 
                                    style={{ background: '#6366f1', color: '#fff', height: '34px', marginTop: '16px', whiteSpace: 'nowrap' }}
                                    onClick={handleAIGenerate}
                                    disabled={aiLoading}
                                >
                                    {aiLoading ? 'Generating...' : '🚀 Generate Questions'}
                                </button>
                            </div>
                        )}
                    </div>

                    {/* ─── Attached Questions Management ─────────────────── */}
                    {isEditing && (
                        <div style={{ marginTop: '30px', background: '#0f172a', padding: '20px', borderRadius: '12px', border: '1px solid #334155' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
                                <div>
                                    <h4 style={{ margin: 0, color: '#f8fafc', fontSize: '16px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                                        <span>📋 Questions in this Mock Exam</span>
                                        <span className={pageStyles.badge} style={{ background: '#3b82f622', color: '#60a5fa', border: '1px solid #3b82f644' }}>
                                            {examQuestions.length} Total
                                        </span>
                                    </h4>
                                    <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '12px' }}>
                                        Add questions from the question bank or enter your own custom questions for this mock exam.
                                    </p>
                                </div>
                                <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
                                    <button 
                                        type="button" 
                                        className={pageStyles.btn} 
                                        style={{ background: '#059669', color: '#fff', display: 'flex', alignItems: 'center', gap: '6px' }}
                                        onClick={openBankModal}
                                    >
                                        <span>📚</span> Add From Question Bank
                                    </button>
                                    <button 
                                        type="button" 
                                        className={pageStyles.btn} 
                                        style={{ background: '#2563eb', color: '#fff', display: 'flex', alignItems: 'center', gap: '6px' }}
                                        onClick={openCustomModal}
                                    >
                                        <span>✏️</span> Add Custom Question
                                    </button>
                                </div>
                            </div>

                            {loadingQuestions ? (
                                <div style={{ textAlign: 'center', padding: '40px', color: '#94a3b8' }}>Loading attached questions...</div>
                            ) : examQuestions.length === 0 ? (
                                <div style={{ textAlign: 'center', padding: '40px 20px', background: '#1e293b44', borderRadius: '8px', border: '1px dashed #334155' }}>
                                    <div style={{ fontSize: '32px', marginBottom: '10px' }}>📂</div>
                                    <h5 style={{ margin: '0 0 6px 0', color: '#e2e8f0', fontSize: '15px' }}>No questions attached yet</h5>
                                    <p style={{ margin: '0 0 16px 0', color: '#64748b', fontSize: '13px' }}>
                                        Click <strong>"Add From Question Bank"</strong> to choose from existing questions, or <strong>"Add Custom Question"</strong> to create new ones.
                                    </p>
                                </div>
                            ) : (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                    {examQuestions.map((q, idx) => (
                                        <div 
                                            key={q.id} 
                                            style={{ 
                                                background: '#1e293b', 
                                                border: '1px solid #334155', 
                                                borderRadius: '8px', 
                                                padding: '16px',
                                                display: 'flex',
                                                justifyContent: 'space-between',
                                                gap: '16px',
                                                alignItems: 'flex-start'
                                            }}
                                        >
                                            <div style={{ flex: 1 }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', flexWrap: 'wrap' }}>
                                                    <span style={{ fontWeight: 700, color: '#38bdf8', fontSize: '13px' }}>#{idx + 1}</span>
                                                    <span className={pageStyles.badge} style={{ 
                                                        background: q.difficulty === 'hard' ? '#ef444422' : q.difficulty === 'easy' ? '#10b98122' : '#f59e0b22',
                                                        color: q.difficulty === 'hard' ? '#fca5a5' : q.difficulty === 'easy' ? '#86efac' : '#fcd34d',
                                                        textTransform: 'capitalize'
                                                    }}>
                                                        {q.difficulty || 'medium'}
                                                    </span>
                                                    {q.source && (
                                                        <span style={{ fontSize: '11px', color: '#64748b', background: '#0f172a', padding: '2px 8px', borderRadius: '4px' }}>
                                                            {q.source}
                                                        </span>
                                                    )}
                                                </div>
                                                <p style={{ margin: '0 0 10px 0', color: '#f1f5f9', fontSize: '14px', lineHeight: '1.5' }}>
                                                    {q.text}
                                                </p>
                                                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '8px', fontSize: '12px' }}>
                                                    {q.options?.map((opt, oIdx) => (
                                                        <div 
                                                            key={opt.id || oIdx}
                                                            style={{ 
                                                                padding: '6px 10px',
                                                                borderRadius: '6px',
                                                                background: opt.isCorrect ? 'rgba(16, 185, 129, 0.15)' : '#0f172a',
                                                                border: opt.isCorrect ? '1px solid #10b981' : '1px solid #334155',
                                                                color: opt.isCorrect ? '#6ee7b7' : '#cbd5e1',
                                                                display: 'flex',
                                                                alignItems: 'center',
                                                                gap: '6px'
                                                            }}
                                                        >
                                                            <span style={{ fontWeight: 700, color: opt.isCorrect ? '#34d399' : '#64748b' }}>
                                                                {String.fromCharCode(65 + oIdx)}.
                                                            </span>
                                                            <span style={{ flex: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                                                                {opt.text}
                                                            </span>
                                                            {opt.isCorrect && <span style={{ fontSize: '11px', fontWeight: 700 }}>✓</span>}
                                                        </div>
                                                    ))}
                                                </div>
                                                {q.explanation?.text && (
                                                    <div style={{ marginTop: '10px', padding: '8px 12px', background: '#0f172a88', borderRadius: '6px', fontSize: '12px', color: '#94a3b8', borderLeft: '3px solid #6366f1' }}>
                                                        <strong style={{ color: '#818cf8' }}>Explanation: </strong> {q.explanation.text}
                                                    </div>
                                                )}
                                            </div>
                                            <button 
                                                type="button" 
                                                className={`${pageStyles.btn} ${pageStyles.btnDanger}`} 
                                                style={{ padding: '6px 12px', fontSize: '12px', flexShrink: 0 }}
                                                onClick={() => handleRemoveQuestion(q.id)}
                                            >
                                                Remove
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    )}
                </div>
            )}

            {/* ─── Mock Exams Table ───────────────────────────── */}
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
                                    <td style={{ textAlign: 'center' }}>
                                        <span className={pageStyles.badge} style={{ background: '#0f172a', color: '#38bdf8', border: '1px solid #1e293b' }}>
                                            {e.totalQuestions}
                                        </span>
                                    </td>
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
                                        <button className={pageStyles.btn} style={{ background: '#334155', color: '#e2e8f0', marginRight: '8px', fontSize: '12px', padding: '6px 12px' }} onClick={() => handleEdit(e)}>
                                            Manage / Edit
                                        </button>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} style={{ fontSize: '12px', padding: '6px 12px' }} onClick={() => handleDelete(e.id)}>
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* ─── Modal 1: Add Questions from Question Bank ──────── */}
            {showBankModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ width: '850px', maxWidth: '95vw' }}>
                        <div className={pageStyles.modalHeader}>
                            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <span>📚</span> Add Questions from Question Bank
                            </h3>
                            <button className={pageStyles.closeBtn} onClick={() => setShowBankModal(false)}>×</button>
                        </div>

                        {/* Search & Filter Toolbar */}
                        <div style={{ padding: '16px 24px', background: '#161b27', borderBottom: '1px solid #1e293b', display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
                            <form onSubmit={handleBankSearchSubmit} style={{ display: 'flex', gap: '8px', flex: 1, minWidth: '220px' }}>
                                <input 
                                    className={pageStyles.search}
                                    style={{ maxWidth: 'none' }}
                                    placeholder="Search question text..."
                                    value={bankSearch}
                                    onChange={e => setBankSearch(e.target.value)}
                                />
                                <button type="submit" className={pageStyles.btnPrimary} style={{ padding: '6px 14px' }}>
                                    Search
                                </button>
                            </form>

                            <select 
                                className={pageStyles.search} 
                                style={{ width: '200px' }}
                                value={bankSpecialtyId} 
                                onChange={e => {
                                    const val = e.target.value;
                                    setBankSpecialtyId(val);
                                    setBankTopicId('');
                                    fetchBankTopics(val);
                                    fetchBankQuestions({ page: 1, specialtyId: val, topicId: '' });
                                }}
                            >
                                <option value="">All Specialties</option>
                                {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                            </select>

                            <select 
                                className={pageStyles.search} 
                                style={{ width: '180px' }}
                                value={bankTopicId} 
                                onChange={e => {
                                    const val = e.target.value;
                                    setBankTopicId(val);
                                    fetchBankQuestions({ page: 1, topicId: val });
                                }}
                                disabled={!bankSpecialtyId || bankTopics.length === 0}
                            >
                                <option value="">All Topics</option>
                                {bankTopics.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                            </select>
                        </div>

                        {/* Question List with Checkboxes */}
                        <div style={{ padding: '16px 24px', overflowY: 'auto', maxHeight: '55vh', flex: 1 }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px', color: '#94a3b8', fontSize: '13px' }}>
                                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', color: '#cbd5e1' }}>
                                    <input 
                                        type="checkbox" 
                                        checked={bankQuestions.length > 0 && bankQuestions.every(q => selectedBankIds.includes(q.id))}
                                        onChange={toggleSelectAllOnPage}
                                    />
                                    <span>Select All on Page</span>
                                </label>
                                <span>{bankTotalCount} questions found • {selectedBankIds.length} selected</span>
                            </div>

                            {bankLoading ? (
                                <div style={{ textAlign: 'center', padding: '40px', color: '#94a3b8' }}>Loading question bank...</div>
                            ) : bankQuestions.length === 0 ? (
                                <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>No questions match the criteria.</div>
                            ) : (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                    {bankQuestions.map(q => {
                                        const isSelected = selectedBankIds.includes(q.id);
                                        return (
                                            <div 
                                                key={q.id}
                                                onClick={() => toggleBankSelect(q.id)}
                                                style={{ 
                                                    display: 'flex', 
                                                    alignItems: 'flex-start', 
                                                    gap: '12px', 
                                                    padding: '12px', 
                                                    borderRadius: '8px', 
                                                    background: isSelected ? 'rgba(59, 130, 246, 0.12)' : '#1e293b', 
                                                    border: isSelected ? '1px solid #3b82f6' : '1px solid #334155',
                                                    cursor: 'pointer',
                                                    transition: 'all 0.15s ease'
                                                }}
                                            >
                                                <input 
                                                    type="checkbox" 
                                                    checked={isSelected} 
                                                    onChange={() => {}} // handled by row click
                                                    style={{ marginTop: '4px', cursor: 'pointer' }}
                                                />
                                                <div style={{ flex: 1 }}>
                                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px', flexWrap: 'wrap' }}>
                                                        <span style={{ color: '#64748b', fontSize: '12px' }}>#{q.id}</span>
                                                        <span className={pageStyles.badge} style={{ background: '#1e3a8a', color: '#bfdbfe', fontSize: '11px', padding: '2px 8px' }}>
                                                            {q.specialty?.name || 'General'}
                                                        </span>
                                                        {q.topic?.name && (
                                                            <span className={pageStyles.badge} style={{ background: '#0f172a', color: '#94a3b8', fontSize: '11px', padding: '2px 8px' }}>
                                                                {q.topic.name}
                                                            </span>
                                                        )}
                                                        <span className={pageStyles.badge} style={{ 
                                                            background: q.difficulty === 'hard' ? '#ef444422' : q.difficulty === 'easy' ? '#10b98122' : '#f59e0b22',
                                                            color: q.difficulty === 'hard' ? '#fca5a5' : q.difficulty === 'easy' ? '#86efac' : '#fcd34d',
                                                            fontSize: '11px',
                                                            padding: '2px 8px'
                                                        }}>
                                                            {q.difficulty}
                                                        </span>
                                                    </div>
                                                    <p style={{ margin: 0, color: '#f1f5f9', fontSize: '13px', lineHeight: '1.4' }}>
                                                        {q.text}
                                                    </p>
                                                </div>
                                            </div>
                                        );
                                    })}
                                </div>
                            )}

                            {/* Pagination */}
                            {bankTotalPages > 1 && (
                                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px', marginTop: '16px' }}>
                                    <button 
                                        type="button" 
                                        className={pageStyles.btnSecondary} 
                                        style={{ padding: '4px 10px', fontSize: '12px' }}
                                        disabled={bankPage <= 1}
                                        onClick={() => fetchBankQuestions({ page: bankPage - 1 })}
                                    >
                                        ◀ Prev
                                    </button>
                                    <span style={{ color: '#94a3b8', fontSize: '12px' }}>
                                        Page {bankPage} of {bankTotalPages}
                                    </span>
                                    <button 
                                        type="button" 
                                        className={pageStyles.btnSecondary} 
                                        style={{ padding: '4px 10px', fontSize: '12px' }}
                                        disabled={bankPage >= bankTotalPages}
                                        onClick={() => fetchBankQuestions({ page: bankPage + 1 })}
                                    >
                                        Next ▶
                                    </button>
                                </div>
                            )}
                        </div>

                        <div className={pageStyles.modalFooter}>
                            <button type="button" className={pageStyles.btnSecondary} onClick={() => setShowBankModal(false)}>
                                Cancel
                            </button>
                            <button 
                                type="button" 
                                className={pageStyles.btnPrimary} 
                                style={{ background: '#059669', minWidth: '160px' }}
                                onClick={handleImportFromBank}
                                disabled={selectedBankIds.length === 0 || importingBank}
                            >
                                {importingBank ? 'Importing...' : `Import ${selectedBankIds.length} Selected`}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* ─── Modal 2: Add Custom Mock Question ──────────────── */}
            {showCustomModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ width: '750px', maxWidth: '95vw' }}>
                        <div className={pageStyles.modalHeader}>
                            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <span>✏️</span> Add Custom Question to Mock Exam
                            </h3>
                            <button className={pageStyles.closeBtn} onClick={() => setShowCustomModal(false)}>×</button>
                        </div>

                        <form onSubmit={handleSaveCustomQuestion} className={pageStyles.modalForm}>
                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '6px', display: 'block' }}>
                                    Question Text / Stem <span style={{ color: '#ef4444' }}>*</span>
                                </label>
                                <textarea 
                                    className={pageStyles.search} 
                                    style={{ width: '100%', maxWidth: 'none', resize: 'vertical' }}
                                    rows="3" 
                                    placeholder="Enter the question stem..." 
                                    value={customQuestion.text} 
                                    onChange={e => setCustomQuestion({ ...customQuestion, text: e.target.value })}
                                    required
                                />
                            </div>

                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '6px', display: 'block' }}>Difficulty</label>
                                <select 
                                    className={pageStyles.search} 
                                    style={{ width: '180px' }}
                                    value={customQuestion.difficulty} 
                                    onChange={e => setCustomQuestion({ ...customQuestion, difficulty: e.target.value })}
                                >
                                    <option value="easy">Easy</option>
                                    <option value="medium">Medium</option>
                                    <option value="hard">Hard</option>
                                </select>
                            </div>

                            <div style={{ marginTop: '10px' }}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '8px', display: 'block' }}>
                                    Options (Select the radio button for the correct answer) <span style={{ color: '#ef4444' }}>*</span>
                                </label>
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                    {customQuestion.options.map((opt, idx) => (
                                        <div key={idx} style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                            <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', minWidth: '95px' }}>
                                                <input 
                                                    type="radio" 
                                                    name="correctOption" 
                                                    checked={opt.isCorrect} 
                                                    onChange={() => handleCustomOptionChange(idx, 'isCorrect', true)}
                                                />
                                                <span style={{ fontWeight: 700, color: opt.isCorrect ? '#10b981' : '#cbd5e1', fontSize: '13px' }}>
                                                    Option {String.fromCharCode(65 + idx)}
                                                </span>
                                            </label>
                                            <input 
                                                className={pageStyles.search}
                                                style={{ flex: 1, maxWidth: 'none', borderColor: opt.isCorrect ? '#10b981' : undefined }}
                                                placeholder={`Option ${String.fromCharCode(65 + idx)} text`}
                                                value={opt.text}
                                                onChange={e => handleCustomOptionChange(idx, 'text', e.target.value)}
                                                required
                                            />
                                            {opt.isCorrect && (
                                                <span className={pageStyles.badge} style={{ background: '#10b98122', color: '#6ee7b7', fontSize: '11px', whiteSpace: 'nowrap' }}>
                                                    Correct Answer
                                                </span>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div style={{ marginTop: '10px', borderTop: '1px solid #1e293b', paddingTop: '15px' }}>
                                <div className={pageStyles.formGroup} style={{ marginBottom: '12px' }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '6px', display: 'block' }}>
                                        Explanation (Optional)
                                    </label>
                                    <textarea 
                                        className={pageStyles.search} 
                                        style={{ width: '100%', maxWidth: 'none', resize: 'vertical' }}
                                        rows="3" 
                                        placeholder="Explain why the correct option is right..." 
                                        value={customQuestion.explanation.text} 
                                        onChange={e => setCustomQuestion({ 
                                            ...customQuestion, 
                                            explanation: { ...customQuestion.explanation, text: e.target.value } 
                                        })}
                                    />
                                </div>

                                <div className={pageStyles.formGroup}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '6px', display: 'block' }}>
                                        References / Citation (Optional)
                                    </label>
                                    <input 
                                        className={pageStyles.search} 
                                        style={{ width: '100%', maxWidth: 'none' }}
                                        placeholder="e.g. Harrison's Internal Medicine 21st Edition" 
                                        value={customQuestion.explanation.references} 
                                        onChange={e => setCustomQuestion({ 
                                            ...customQuestion, 
                                            explanation: { ...customQuestion.explanation, references: e.target.value } 
                                        })}
                                    />
                                </div>
                            </div>

                            <div className={pageStyles.modalFooter} style={{ padding: '16px 0 0 0', marginTop: '15px' }}>
                                <button type="button" className={pageStyles.btnSecondary} onClick={() => setShowCustomModal(false)}>
                                    Cancel
                                </button>
                                <button 
                                    type="submit" 
                                    className={pageStyles.btnPrimary} 
                                    disabled={savingCustom}
                                    style={{ minWidth: '150px' }}
                                >
                                    {savingCustom ? 'Adding...' : '➕ Add Question to Exam'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
