import { useEffect, useState } from 'react';
import {
    getQuestions,
    deleteQuestion,
    getSpecialties,
    getTopics,
    createQuestion,
    updateQuestion,
    getQuestion,
    aiGenerateExplanation,
    aiGenerateQuestion
} from '../api/api';
import { useCallback } from 'react';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Questions() {
    const [questions, setQuestions] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [selectedIds, setSelectedIds] = useState([]);

    // Filters
    const [specialties, setSpecialties] = useState([]);
    const [topics, setTopics] = useState([]);
    const [selectedSpecialty, setSelectedSpecialty] = useState('');
    const [selectedTopic, setSelectedTopic] = useState('');

    // Modal State
    const [showModal, setShowModal] = useState(false);
    const [editingId, setEditingId] = useState(null);
    const [aiLoading, setAiLoading] = useState(false);
    const [aiResult, setAiResult] = useState(null);

    // DOCX Modal State
    const [showDocxModal, setShowDocxModal] = useState(false);
    const [docxLoading, setDocxLoading] = useState(false);
    const [docxData, setDocxData] = useState({
        specialtyId: 'auto',
        topicId: 'auto',
        file: null
    });
    const [docxTopics, setDocxTopics] = useState([]);
    const [streamProgressPercent, setStreamProgressPercent] = useState(null);
    const [streamProgressMessage, setStreamProgressMessage] = useState('');
    const [formData, setFormData] = useState({
        text: '',
        specialtyId: '',
        topicId: '',
        difficulty: 'medium',
        options: [
            { text: '', isCorrect: true },
            { text: '', isCorrect: false },
            { text: '', isCorrect: false },
            { text: '', isCorrect: false }
        ],
        explanation: { text: '', references: '' },
        isPremium: false
    });

    const [formTopics, setFormTopics] = useState([]);

    const loadQuestions = useCallback(async () => {
        setLoading(true);
        try {
            const params = {};
            if (selectedSpecialty) params.specialtyId = selectedSpecialty;
            if (selectedTopic) params.topicId = selectedTopic;

            const res = await getQuestions(params);
            setQuestions(res.data?.data || []);
        } catch (error) {
            console.error('Failed to load questions', error);
        } finally {
            setLoading(false);
        }
    }, [selectedSpecialty, selectedTopic]);

    const loadInitialData = useCallback(async () => {
        try {
            const specRes = await getSpecialties();
            setSpecialties(specRes.data?.data || []);
            loadQuestions();
        } catch (error) {
            console.error('Failed to load specialties', error);
        }
    }, [loadQuestions]);

    useEffect(() => {
        loadInitialData();
    }, [loadInitialData]);

    useEffect(() => {
        loadQuestions();
    }, [loadQuestions, selectedSpecialty, selectedTopic]);

    // Load topics for filter
    useEffect(() => {
        if (selectedSpecialty) {
            getTopics(selectedSpecialty).then(r => setTopics(r.data?.data || []));
            setSelectedTopic('');
        } else {
            setTopics([]);
            setSelectedTopic('');
        }
    }, [selectedSpecialty]);

    // Load topics for form
    useEffect(() => {
        if (formData.specialtyId) {
            getTopics(formData.specialtyId).then(r => setFormTopics(r.data?.data || []));
        } else {
            setFormTopics([]);
        }
    }, [formData.specialtyId]);

    // Load topics for DOCX form
    useEffect(() => {
        if (docxData.specialtyId) {
            getTopics(docxData.specialtyId).then(r => setDocxTopics(r.data?.data || []));
        } else {
            setDocxTopics([]);
        }
    }, [docxData.specialtyId]);

    const openCreateModal = () => {
        setEditingId(null);
        setAiResult(null);
        setFormData({
            text: '',
            specialtyId: '',
            topicId: '',
            difficulty: 'medium',
            options: [
                { text: '', isCorrect: true },
                { text: '', isCorrect: false },
                { text: '', isCorrect: false },
                { text: '', isCorrect: false }
            ],
            explanation: { text: '', references: '' },
            isPremium: false
        });
        setShowModal(true);
    };

    const openEditModal = async (id) => {
        try {
            const res = await getQuestion(id);
            const q = res.data?.data;
            if (q) {
                setEditingId(id);
                setAiResult(null);
                setFormData({
                    text: q.text,
                    specialtyId: q.specialtyId || '',
                    topicId: q.topicId || '',
                    difficulty: q.difficulty || 'medium',
                    options: q.options?.length > 0 ? q.options.map(o => ({ text: o.text, isCorrect: o.isCorrect })) : [
                        { text: '', isCorrect: true },
                        { text: '', isCorrect: false }
                    ],
                    explanation: {
                        text: q.explanation?.text || '',
                        references: q.explanation?.references || ''
                    },
                    isPremium: q.isPremium || false
                });
                setShowModal(true);
            }
        } catch (error) {
            console.error(error);
            alert('Failed to load question details');
        }
    };

    const handleDocxSubmit = async (e) => {
        e.preventDefault();
        if (!docxData.file || !docxData.specialtyId || !docxData.topicId) {
            return alert('Please select a specialty, a topic, and a DOCX file.');
        }
        setDocxLoading(true);
        setStreamProgressPercent(0);
        setStreamProgressMessage('Initializing streaming pipeline...');

        const mdData = new FormData();
        mdData.append('file', docxData.file);
        mdData.append('specialtyId', docxData.specialtyId);
        mdData.append('topicId', docxData.topicId);

        try {
            const token = localStorage.getItem('adminToken');
            const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

            const response = await fetch(`${apiUrl}/admin/questions/bulk-import-docx`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                },
                body: mdData
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.message || 'Failed to import DOCX');
            }

            const reader = response.body.getReader();
            const decoder = new TextDecoder('utf-8');
            let isComplete = false;

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                const chunkMessage = decoder.decode(value, { stream: true });
                const lines = chunkMessage.split('\n');

                for (let line of lines) {
                    if (line.startsWith('data: ')) {
                        const dataStr = line.replace('data: ', '');
                        if (dataStr.trim() === '') continue;

                        try {
                            const parsed = JSON.parse(dataStr);
                            if (parsed.type === 'start') {
                                setStreamProgressPercent(5);
                                setStreamProgressMessage(`Pipeline open. Processing ${parsed.totalChunks} text blocks...`);
                            } else if (parsed.type === 'progress') {
                                setStreamProgressPercent(parsed.percent);
                                setStreamProgressMessage(parsed.message);
                            } else if (parsed.type === 'complete') {
                                isComplete = true;
                                setStreamProgressPercent(100);
                                setStreamProgressMessage(parsed.message);
                                setTimeout(() => {
                                    alert(parsed.message);
                                    setShowDocxModal(false);
                                    setDocxData({ specialtyId: 'auto', topicId: 'auto', file: null });
                                    setStreamProgressPercent(null);
                                    loadQuestions();
                                }, 500);
                            }
                        } catch {
                            // Ignored broken JSON chunks or trailing strings
                        }
                    }
                }
            }

            if (!isComplete) {
                // If stream died abruptly
                loadQuestions();
                alert('Stream ended prematurely. Partial questions might have been imported.');
                setShowDocxModal(false);
            }

        } catch (error) {
            alert(error.message || 'Failed to connect to the streaming API');
        } finally {
            setDocxLoading(false);
        }
    };

    const handleAIGenerate = async () => {
        if (!editingId) {
            alert('Please save the question first before generating AI explanation.');
            return;
        }
        setAiLoading(true);
        setAiResult(null);
        try {
            const res = await aiGenerateExplanation(editingId);
            const data = res.data?.data;
            if (data) {
                setAiResult(data);
                setFormData(prev => ({
                    ...prev,
                    difficulty: data.difficulty || prev.difficulty,
                    isPremium: (data.points && data.points >= 3) ? true : prev.isPremium,
                    explanation: {
                        text: data.formattedText || data.explanation || prev.explanation.text,
                        references: data.references || prev.explanation.references
                    }
                }));
            }
        } catch (error) {
            alert(error.response?.data?.message || 'AI generation failed');
        } finally {
            setAiLoading(false);
        }
    };

    const handleAIGenerateNew = async () => {
        if (!formData.specialtyId || !formData.topicId) {
            alert('Select a Specialty and Topic first.');
            return;
        }
        setAiLoading(true);
        setAiResult(null);
        try {
            const res = await aiGenerateQuestion({
                specialtyId: formData.specialtyId,
                topicId: formData.topicId
            });
            const data = res.data?.data;
            if (data) {
                setAiResult(data);
                setFormData(prev => ({
                    ...prev,
                    text: data.text || prev.text,
                    difficulty: data.difficulty || prev.difficulty,
                    isPremium: (data.points && data.points >= 3) ? true : prev.isPremium,
                    options: (data.options && data.options.length > 0)
                        ? data.options.map(o => ({ text: o.text, isCorrect: o.isCorrect }))
                        : prev.options,
                    explanation: {
                        text: data.explanation || prev.explanation.text,
                        references: data.references || prev.explanation.references
                    }
                }));
                // Switch to edit mode with the new question ID
                if (data.questionId) {
                    setEditingId(data.questionId);
                }
            }
        } catch (error) {
            alert(error.response?.data?.message || 'AI question generation failed');
        } finally {
            setAiLoading(false);
        }
    };

    const handleFormChange = (field, value) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    const handleOptionChange = (index, value) => {
        const newOptions = [...formData.options];
        newOptions[index].text = value;
        setFormData(prev => ({ ...prev, options: newOptions }));
    };

    const setCorrectOption = (index) => {
        const newOptions = formData.options.map((opt, i) => ({
            ...opt,
            isCorrect: i === index
        }));
        setFormData(prev => ({ ...prev, options: newOptions }));
    };

    const addOption = () => {
        setFormData(prev => ({
            ...prev,
            options: [...prev.options, { text: '', isCorrect: false }]
        }));
    };

    const removeOption = (index) => {
        if (formData.options.length <= 2) return;
        setFormData(prev => ({
            ...prev,
            options: prev.options.filter((_, i) => i !== index)
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editingId) {
                await updateQuestion(editingId, formData);
            } else {
                await createQuestion(formData);
            }
            setShowModal(false);
            loadQuestions();
        } catch (error) {
            alert(error.response?.data?.message || 'Failed to save question');
        }
    };

    const remove = async (id) => {
        if (!confirm('Delete this question?')) return;
        await deleteQuestion(id);
        setQuestions((prev) => prev.filter((q) => q.id !== id));
        setSelectedIds((prev) => prev.filter(selectedId => selectedId !== id));
    };

    const filteredQuestions = questions.filter((q) =>
        (q.text || '').toLowerCase().includes(search.toLowerCase())
    );

    const toggleSelectAll = (e) => {
        if (e.target.checked) {
            setSelectedIds(filteredQuestions.map(q => q.id));
        } else {
            setSelectedIds([]);
        }
    };

    const toggleSelect = (id) => {
        setSelectedIds(prev =>
            prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
        );
    };

    const handleDeleteSelected = async () => {
        if (!selectedIds.length) return;
        if (!confirm(`Are you sure you want to delete ${selectedIds.length} question(s)?`)) return;
        
        try {
            await Promise.all(selectedIds.map(id => deleteQuestion(id)));
            setQuestions(prev => prev.filter(q => !selectedIds.includes(q.id)));
            setSelectedIds([]);
            alert('Selected questions deleted successfully.');
        } catch (error) {
            console.error(error);
            alert('Failed to delete some questions. They might be in use.');
            loadQuestions(); // Reload to sync state
        }
    };

    return (
        <div className={pageStyles.pageContainer}>
            <div className={pageStyles.header}>
                <h2 className={styles.pageTitle}>📚 Questions Management</h2>
                <div style={{ display: 'flex', gap: '10px' }}>
                    <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => setShowDocxModal(true)} style={{ background: '#6366f1' }}>
                        📥 Import DOCX
                    </button>
                    <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={openCreateModal}>
                        + Add New Question
                    </button>
                </div>
            </div>

            <div className={pageStyles.toolbar}>
                <div className={pageStyles.filters}>
                    <input
                        className={pageStyles.search}
                        placeholder="Search text…"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                    />
                    <select
                        className={pageStyles.select}
                        value={selectedSpecialty}
                        onChange={(e) => setSelectedSpecialty(e.target.value)}
                    >
                        <option value="">All Specialties</option>
                        {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                    </select>
                    <select
                        className={pageStyles.select}
                        value={selectedTopic}
                        onChange={(e) => setSelectedTopic(e.target.value)}
                        disabled={!selectedSpecialty}
                    >
                        <option value="">All Topics</option>
                        {topics.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                    </select>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                    {selectedIds.length > 0 && (
                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={handleDeleteSelected}>
                            🗑️ Delete Selected ({selectedIds.length})
                        </button>
                    )}
                    <span className={pageStyles.count}>{filteredQuestions.length} questions found</span>
                </div>
            </div>

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th style={{ width: '40px', textAlign: 'center' }}>
                                <input 
                                    type="checkbox" 
                                    checked={filteredQuestions.length > 0 && selectedIds.length === filteredQuestions.length}
                                    onChange={toggleSelectAll}
                                />
                            </th>
                            <th>Question</th>
                            <th>Specialty</th>
                            <th>Topic</th>
                            <th>Status</th>
                            <th>Difficulty</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', color: '#64748b' }}>Loading…</td></tr>
                        ) : filteredQuestions.length === 0 ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', color: '#64748b' }}>No questions found</td></tr>
                        ) : (
                            filteredQuestions.map((q) => (
                                <tr key={q.id} style={{ backgroundColor: selectedIds.includes(q.id) ? '#334155' : 'transparent' }}>
                                    <td style={{ textAlign: 'center' }}>
                                        <input 
                                            type="checkbox" 
                                            checked={selectedIds.includes(q.id)}
                                            onChange={() => toggleSelect(q.id)}
                                        />
                                    </td>
                                    <td title={q.text} style={{ maxWidth: 350, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                                        {q.text}
                                    </td>
                                    <td><span className={pageStyles.badge} style={{ background: '#1e3a5f', color: '#60a5fa' }}>
                                        {q.specialty?.name || '—'}
                                    </span></td>
                                    <td style={{ color: '#94a3b8' }}>
                                        {q.topic?.name || '—'}
                                    </td>
                                    <td>
                                        {q.isPremium ? (
                                            <span className={pageStyles.badge} style={{ background: '#4c1d95', color: '#ddd6fe' }}>Premium</span>
                                        ) : (
                                            <span className={pageStyles.badge} style={{ background: '#14532d', color: '#4ade80' }}>Free</span>
                                        )}
                                    </td>
                                    <td>
                                        <span className={pageStyles.badge} style={{
                                            background: q.difficulty === 'hard' ? '#7f1d1d' : q.difficulty === 'medium' ? '#451a03' : '#14532d',
                                            color: q.difficulty === 'hard' ? '#fca5a5' : q.difficulty === 'medium' ? '#fbbf24' : '#4ade80'
                                        }}>
                                            {q.difficulty}
                                        </span>
                                    </td>
                                    <td className={pageStyles.actions}>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnSmall}`} onClick={() => openEditModal(q.id)}>
                                            Edit
                                        </button>
                                        <button className={`${pageStyles.btn} ${pageStyles.btnDanger} ${pageStyles.btnSmall}`} onClick={() => remove(q.id)}>
                                            Delete
                                        </button>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {/* Modal */}
            {showModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ maxWidth: '800px', width: '90%' }}>
                        <div className={pageStyles.modalHeader}>
                            <h3>{editingId ? 'Edit Question' : 'Create New Question'}</h3>
                            <button className={pageStyles.closeBtn} onClick={() => setShowModal(false)}>&times;</button>
                        </div>
                        <form onSubmit={handleSubmit} className={pageStyles.form}>
                            <div className={pageStyles.formRow}>
                                <div className={pageStyles.formGroup} style={{ flex: 1 }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Question Text (Scenario or clinical question)</label>
                                    <textarea
                                        required
                                        rows="3"
                                        value={formData.text}
                                        onChange={(e) => handleFormChange('text', e.target.value)}
                                        placeholder="e.g. A 45-year-old male presents with sudden chest pain..."
                                    />
                                </div>
                            </div>

                            <div className={pageStyles.formRow}>
                                <div className={pageStyles.formGroup}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Main Specialty</label>
                                    <select
                                        required
                                        value={formData.specialtyId}
                                        onChange={(e) => handleFormChange('specialtyId', e.target.value)}
                                    >
                                        <option value="">Select Specialty</option>
                                        {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Specific Topic</label>
                                    <select
                                        required
                                        value={formData.topicId}
                                        onChange={(e) => handleFormChange('topicId', e.target.value)}
                                        disabled={!formData.specialtyId}
                                    >
                                        <option value="">Select Topic</option>
                                        {formTopics.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Difficulty Level</label>
                                    <select
                                        value={formData.difficulty}
                                        onChange={(e) => handleFormChange('difficulty', e.target.value)}
                                    >
                                        <option value="easy">Easy (1 Point)</option>
                                        <option value="medium">Medium (2 Points)</option>
                                        <option value="hard">Hard (3 Points)</option>
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', paddingTop: '25px' }}>
                                    <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', color: '#cbd5e1' }}>
                                        <input
                                            type="checkbox"
                                            checked={formData.isPremium}
                                            onChange={(e) => handleFormChange('isPremium', e.target.checked)}
                                        />
                                        <span style={{ fontWeight: 600 }}>Premium Content</span>
                                    </label>
                                </div>
                            </div>

                            <div className={pageStyles.formSection}>
                                <div className={pageStyles.sectionHeader}>
                                    <label>Options</label>
                                    <button type="button" className={pageStyles.btnAddSmall} onClick={addOption}>+ Add Option</button>
                                    {!editingId && formData.specialtyId && formData.topicId && (
                                        <button
                                            type="button"
                                            onClick={handleAIGenerateNew}
                                            disabled={aiLoading}
                                            style={{
                                                background: aiLoading ? '#334155' : 'linear-gradient(135deg, #059669, #10b981)',
                                                color: '#fff',
                                                border: 'none',
                                                padding: '6px 14px',
                                                borderRadius: '6px',
                                                cursor: aiLoading ? 'wait' : 'pointer',
                                                fontSize: '11px',
                                                fontWeight: 700,
                                                transition: 'all 0.2s'
                                            }}
                                        >
                                            {aiLoading ? 'Generating...' : 'AI Generate Question'}
                                        </button>
                                    )}
                                </div>
                                {formData.options.map((opt, idx) => (
                                    <div key={idx} className={pageStyles.optionRow}>
                                        <input
                                            type="radio"
                                            name="correctOption"
                                            checked={opt.isCorrect}
                                            onChange={() => setCorrectOption(idx)}
                                        />
                                        <input
                                            type="text"
                                            required
                                            placeholder={`Option ${idx + 1}`}
                                            value={opt.text}
                                            onChange={(e) => handleOptionChange(idx, e.target.value)}
                                            style={{ flex: 1 }}
                                        />
                                        <button
                                            type="button"
                                            className={pageStyles.btnRemove}
                                            onClick={() => removeOption(idx)}
                                            disabled={formData.options.length <= 2}
                                        >
                                            &times;
                                        </button>
                                    </div>
                                ))}
                            </div>

                            <div className={pageStyles.formGroup}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                    <label>Explanation</label>
                                    {editingId && (
                                        <button
                                            type="button"
                                            onClick={handleAIGenerate}
                                            disabled={aiLoading}
                                            style={{
                                                background: aiLoading ? '#334155' : 'linear-gradient(135deg, #6366f1, #8b5cf6)',
                                                color: '#fff',
                                                border: 'none',
                                                padding: '8px 20px',
                                                borderRadius: '8px',
                                                cursor: aiLoading ? 'wait' : 'pointer',
                                                fontSize: '12px',
                                                fontWeight: 700,
                                                letterSpacing: '0.5px',
                                                opacity: aiLoading ? 0.7 : 1,
                                                transition: 'all 0.2s'
                                            }}
                                        >
                                            {aiLoading ? 'Generating...' : 'AI Generate'}
                                        </button>
                                    )}
                                </div>
                                <textarea
                                    placeholder="Explanation will be auto-filled by AI..."
                                    rows="6"
                                    value={formData.explanation.text}
                                    onChange={(e) => setFormData(prev => ({
                                        ...prev,
                                        explanation: { ...prev.explanation, text: e.target.value }
                                    }))}
                                    style={{ fontFamily: 'monospace', fontSize: '12px', lineHeight: '1.6' }}
                                />
                            </div>

                            <div className={pageStyles.formGroup}>
                                <label>References</label>
                                <input
                                    type="text"
                                    placeholder="Medical references (auto-filled by AI)"
                                    value={formData.explanation.references}
                                    onChange={(e) => setFormData(prev => ({
                                        ...prev,
                                        explanation: { ...prev.explanation, references: e.target.value }
                                    }))}
                                />
                            </div>

                            {aiResult && (
                                <div style={{
                                    marginTop: '8px',
                                    background: '#0f172a',
                                    borderRadius: '10px',
                                    padding: '16px',
                                    border: '1px solid #1e293b'
                                }}>
                                    <div style={{ fontSize: '13px', fontWeight: 700, color: '#94a3b8', marginBottom: '12px', textTransform: 'uppercase', letterSpacing: '1px' }}>AI Analysis</div>

                                    {aiResult.summary && (
                                        <div style={{ marginBottom: '12px', padding: '10px', background: '#1e293b', borderRadius: '8px' }}>
                                            <div style={{ fontSize: '10px', color: '#64748b', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '4px' }}>Summary</div>
                                            <div style={{ fontSize: '13px', color: '#e2e8f0', lineHeight: '1.5' }}>{aiResult.summary}</div>
                                        </div>
                                    )}

                                    {aiResult.keyPoints && aiResult.keyPoints.length > 0 && (
                                        <div style={{ marginBottom: '12px', padding: '10px', background: '#1e293b', borderRadius: '8px' }}>
                                            <div style={{ fontSize: '10px', color: '#64748b', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '6px' }}>Key Points</div>
                                            {aiResult.keyPoints.map((kp, i) => (
                                                <div key={i} style={{ fontSize: '12px', color: '#cbd5e1', marginBottom: '4px', paddingLeft: '12px', borderLeft: '2px solid #334155' }}>
                                                    {i + 1}. {kp}
                                                </div>
                                            ))}
                                        </div>
                                    )}

                                    {aiResult.whyWrong && Object.keys(aiResult.whyWrong).length > 0 && (
                                        <div style={{ marginBottom: '12px', padding: '10px', background: '#1e293b', borderRadius: '8px' }}>
                                            <div style={{ fontSize: '10px', color: '#64748b', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: '6px' }}>Why Other Options Are Wrong</div>
                                            {Object.entries(aiResult.whyWrong).map(([key, reason]) => (
                                                <div key={key} style={{ fontSize: '12px', color: '#f1f5f9', marginBottom: '6px', paddingLeft: '12px', borderLeft: '2px solid #ef4444' }}>
                                                    <span style={{ fontWeight: 700, color: '#f87171' }}>{key}:</span> {reason}
                                                </div>
                                            ))}
                                        </div>
                                    )}

                                    <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                                        {aiResult.difficulty && (
                                            <div style={{ padding: '6px 12px', background: '#1e293b', borderRadius: '6px', fontSize: '11px' }}>
                                                <span style={{ color: '#64748b' }}>Difficulty: </span>
                                                <span style={{ color: aiResult.difficulty === 'hard' ? '#f87171' : aiResult.difficulty === 'medium' ? '#fbbf24' : '#4ade80', fontWeight: 700 }}>{aiResult.difficulty}</span>
                                            </div>
                                        )}
                                        {aiResult.points && (
                                            <div style={{ padding: '6px 12px', background: '#1e293b', borderRadius: '6px', fontSize: '11px' }}>
                                                <span style={{ color: '#64748b' }}>Points: </span>
                                                <span style={{ color: '#e2e8f0', fontWeight: 700 }}>{aiResult.points}</span>
                                            </div>
                                        )}
                                        {aiResult.timeEstimate && (
                                            <div style={{ padding: '6px 12px', background: '#1e293b', borderRadius: '6px', fontSize: '11px' }}>
                                                <span style={{ color: '#64748b' }}>Time: </span>
                                                <span style={{ color: '#e2e8f0', fontWeight: 700 }}>{aiResult.timeEstimate}s</span>
                                            </div>
                                        )}
                                    </div>

                                    {aiResult.references && (
                                        <div style={{ marginTop: '10px', fontSize: '11px', color: '#64748b' }}>
                                            Refs: <span style={{ color: '#94a3b8' }}>{aiResult.references}</span>
                                        </div>
                                    )}
                                </div>
                            )}

                            <div className={pageStyles.modalFooter}>
                                <button type="button" className={pageStyles.btnSecondary} onClick={() => setShowModal(false)}>Cancel</button>
                                <button type="submit" className={pageStyles.btnPrimary}>Save Question</button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* DOCX Modal */}
            {showDocxModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ maxWidth: '450px', width: '90%' }}>
                        <div className={pageStyles.modalHeader}>
                            <h3>Import Questions from DOCX</h3>
                            <button className={pageStyles.closeBtn} onClick={() => setShowDocxModal(false)}>&times;</button>
                        </div>
                        <form onSubmit={handleDocxSubmit} className={pageStyles.form} style={{ marginTop: '15px' }}>
                            <div className={pageStyles.formGroup}>
                                <label>Specialty</label>
                                <select
                                    required
                                    value={docxData.specialtyId}
                                    onChange={(e) => {
                                        const val = e.target.value;
                                        setDocxData(prev => ({ ...prev, specialtyId: val, topicId: val === 'auto' ? 'auto' : '' }))
                                    }}
                                >
                                    <option value="auto">🌟 Auto-Detect via AI</option>
                                    {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                </select>
                            </div>
                            <div className={pageStyles.formGroup}>
                                <label>Topic</label>
                                <select
                                    required
                                    value={docxData.topicId}
                                    onChange={(e) => setDocxData(prev => ({ ...prev, topicId: e.target.value }))}
                                    disabled={docxData.specialtyId === 'auto'}
                                >
                                    {docxData.specialtyId === 'auto' ? (
                                        <option value="auto">🌟 Auto-Detect via AI</option>
                                    ) : (
                                        <>
                                            <option value="">Select Topic</option>
                                            <option value="auto">🌟 Auto-Detect via AI</option>
                                            {docxTopics.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                                        </>
                                    )}
                                </select>
                            </div>
                            <div className={pageStyles.formGroup}>
                                <label>Upload .docx File</label>
                                <input
                                    type="file"
                                    accept=".docx"
                                    required
                                    onChange={(e) => setDocxData(prev => ({ ...prev, file: e.target.files[0] }))}
                                    style={{ padding: '8px', background: '#0f172a', borderRadius: '8px', border: '1px solid #1e293b', color: '#fff', width: '100%' }}
                                />
                            </div>

                            {streamProgressPercent !== null && (
                                <div style={{ marginTop: '20px', padding: '15px', background: '#0f172a', borderRadius: '8px', border: '1px solid #1e293b' }}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                        <span style={{ fontSize: '13px', color: '#94a3b8', fontWeight: 600 }}>Streaming Pipeline...</span>
                                        <span style={{ fontSize: '13px', color: '#38bdf8', fontWeight: 700 }}>{streamProgressPercent}%</span>
                                    </div>
                                    <div style={{ width: '100%', height: '8px', background: '#1e293b', borderRadius: '4px', overflow: 'hidden' }}>
                                        <div style={{ width: `${streamProgressPercent}%`, height: '100%', background: 'linear-gradient(90deg, #0ea5e9, #38bdf8)', transition: 'width 0.3s ease' }}></div>
                                    </div>
                                    <div style={{ marginTop: '10px', fontSize: '12px', color: '#cbd5e1', lineHeight: '1.4' }}>
                                        {streamProgressMessage}
                                    </div>
                                </div>
                            )}

                            <div className={pageStyles.modalFooter} style={{ marginTop: '20px' }}>
                                <button type="button" className={pageStyles.btnSecondary} onClick={() => { setShowDocxModal(false); setStreamProgressPercent(null); }}>Cancel</button>
                                <button type="submit" className={pageStyles.btnPrimary} disabled={docxLoading}>
                                    {docxLoading ? 'AI is Parsing...' : 'Import Questions'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
