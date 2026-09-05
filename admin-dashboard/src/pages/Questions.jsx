import { useEffect, useState } from 'react';
import {
    getQuestions,
    deleteQuestion,
    getSpecialties,
    getTopics,
    createQuestion,
    updateQuestion,
    moveQuestion,
    bulkMoveQuestions,
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
    const [debouncedSearch, setDebouncedSearch] = useState('');
    const [selectedIds, setSelectedIds] = useState([]);

    // Pagination
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [totalCount, setTotalCount] = useState(0);

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

    // Move Modal State
    const [showMoveModal, setShowMoveModal] = useState(false);
    const [moveTarget, setMoveTarget] = useState(null); // { type: 'single', question } or { type: 'bulk', count }
    const [targetSpecialtyId, setTargetSpecialtyId] = useState('');
    const [targetTopicId, setTargetTopicId] = useState('');
    const [moveTopics, setMoveTopics] = useState([]);
    const [moveLoading, setMoveLoading] = useState(false);

    const loadQuestions = useCallback(async () => {
        setLoading(true);
        try {
            const params = { page, limit: 20 };
            if (selectedSpecialty) params.specialtyId = selectedSpecialty;
            if (selectedTopic) params.topicId = selectedTopic;
            if (debouncedSearch.trim()) params.search = debouncedSearch.trim();

            const res = await getQuestions(params);
            setQuestions(res.data?.data || []);
            setTotalPages(res.data?.totalPages || 1);
            setTotalCount(res.data?.count || 0);
        } catch (error) {
            console.error('Failed to load questions', error);
        } finally {
            setLoading(false);
        }
    }, [selectedSpecialty, selectedTopic, page, debouncedSearch]);

    // Debounce search input to query server across all pages
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedSearch(search);
            setPage(1);
        }, 350);
        return () => clearTimeout(timer);
    }, [search]);

    useEffect(() => {
        getSpecialties()
            .then(res => setSpecialties(res.data?.data || []))
            .catch(err => console.error('Failed to load specialties', err));
    }, []);

    useEffect(() => {
        setPage(1);
    }, [selectedSpecialty, selectedTopic]);

    useEffect(() => {
        loadQuestions();
    }, [loadQuestions]);

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

    // Load topics for Move Modal
    useEffect(() => {
        if (targetSpecialtyId) {
            getTopics(targetSpecialtyId).then(r => setMoveTopics(r.data?.data || []));
            setTargetTopicId('');
        } else {
            setMoveTopics([]);
            setTargetTopicId('');
        }
    }, [targetSpecialtyId]);

    const openSingleMoveModal = (question) => {
        setMoveTarget({ type: 'single', question });
        setTargetSpecialtyId(question.specialtyId || question.specialty?.id || '');
        setTargetTopicId(question.topicId || question.topic?.id || '');
        setShowMoveModal(true);
    };

    const openBulkMoveModal = () => {
        if (!selectedIds.length) return;
        setMoveTarget({ type: 'bulk', count: selectedIds.length });
        setTargetSpecialtyId('');
        setTargetTopicId('');
        setShowMoveModal(true);
    };

    const handleConfirmMove = async (e) => {
        e.preventDefault();
        if (!targetSpecialtyId) {
            alert('Please select a target specialty.');
            return;
        }
        setMoveLoading(true);
        try {
            if (moveTarget?.type === 'single') {
                await moveQuestion(moveTarget.question.id, {
                    specialtyId: targetSpecialtyId,
                    topicId: targetTopicId || null
                });
            } else {
                await bulkMoveQuestions({
                    questionIds: selectedIds,
                    specialtyId: targetSpecialtyId,
                    topicId: targetTopicId || null
                });
                setSelectedIds([]);
            }
            setShowMoveModal(false);
            await loadQuestions();
        } catch (error) {
            console.error('Failed to move question', error);
            alert(error.response?.data?.message || 'Failed to move question(s)');
        } finally {
            setMoveLoading(false);
        }
    };

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
                    options: q.options?.length > 0 ? q.options.map(o => ({ text: o.text || '', isCorrect: Boolean(o.isCorrect) })) : [
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
            const apiUrl = import.meta.env.VITE_API_URL || '/api/v1';
            const API_STATIC_URL = (import.meta.env.VITE_API_URL || '').replace('/api/v1', '');

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

    const filteredQuestions = questions;

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
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    {selectedIds.length > 0 && (
                        <div style={{ display: 'flex', gap: '8px' }}>
                            <button
                                style={{
                                    background: 'linear-gradient(135deg, #0284c7 0%, #0369a1 100%)',
                                    color: '#ffffff',
                                    border: 'none',
                                    padding: '8px 16px',
                                    borderRadius: '8px',
                                    fontWeight: 600,
                                    fontSize: '13px',
                                    boxShadow: '0 4px 12px rgba(2, 132, 199, 0.35)',
                                    display: 'inline-flex',
                                    alignItems: 'center',
                                    gap: '6px',
                                    cursor: 'pointer',
                                    transition: 'all 0.15s ease'
                                }}
                                onClick={openBulkMoveModal}
                            >
                                <span>🔄</span>
                                <span>Move Selected ({selectedIds.length})</span>
                            </button>
                            <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={handleDeleteSelected}>
                                🗑️ Delete Selected ({selectedIds.length})
                            </button>
                        </div>
                    )}
                    <span className={pageStyles.count}>Page {page} of {totalPages} ({totalCount} total questions)</span>
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
                                        <button
                                            style={{
                                                background: 'rgba(14, 165, 233, 0.12)',
                                                color: '#38bdf8',
                                                border: '1px solid rgba(14, 165, 233, 0.3)',
                                                borderRadius: '7px',
                                                padding: '5px 11px',
                                                fontSize: '12px',
                                                fontWeight: 600,
                                                cursor: 'pointer',
                                                display: 'inline-flex',
                                                alignItems: 'center',
                                                gap: '4px',
                                                transition: 'all 0.15s ease'
                                            }}
                                            onClick={() => openSingleMoveModal(q)}
                                            title="نقل السؤال لتخصص آخر"
                                        >
                                            <span>🔄</span>
                                            <span>Move</span>
                                        </button>
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

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '15px' }}>
                <button
                    className={pageStyles.btn}
                    disabled={page === 1}
                    onClick={() => setPage(p => Math.max(1, p - 1))}
                    style={{ opacity: page === 1 ? 0.5 : 1, cursor: page === 1 ? 'not-allowed' : 'pointer' }}
                >
                    Previous
                </button>
                <span style={{ color: '#94a3b8', fontSize: '14px' }}>Page {page} of {totalPages}</span>
                <button
                    className={pageStyles.btn}
                    disabled={page === totalPages || totalPages === 0}
                    onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                    style={{ opacity: page === totalPages || totalPages === 0 ? 0.5 : 1, cursor: page === totalPages || totalPages === 0 ? 'not-allowed' : 'pointer' }}
                >
                    Next
                </button>
            </div>

            {/* Modal */}
            {showModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ maxWidth: '860px', width: '94%', maxHeight: '90vh', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
                        <div className={pageStyles.modalHeader} style={{ flexShrink: 0 }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                <div style={{
                                    width: '36px',
                                    height: '36px',
                                    borderRadius: '10px',
                                    background: editingId ? 'rgba(59, 130, 246, 0.15)' : 'rgba(16, 185, 129, 0.15)',
                                    border: editingId ? '1px solid rgba(59, 130, 246, 0.3)' : '1px solid rgba(16, 185, 129, 0.3)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    fontSize: '18px'
                                }}>
                                    {editingId ? '✏️' : '✨'}
                                </div>
                                <div>
                                    <h3 style={{ margin: 0, fontSize: '18px', fontWeight: 700, color: '#f8fafc' }}>
                                        {editingId ? 'Edit Question' : 'Create New Question'}
                                    </h3>
                                    <span style={{ fontSize: '12px', color: '#64748b' }}>
                                        {editingId ? `Editing Question #${editingId}` : 'Add a new question to the bank'}
                                    </span>
                                </div>
                            </div>
                            <button className={pageStyles.closeBtn} onClick={() => setShowModal(false)}>&times;</button>
                        </div>
                        <form onSubmit={handleSubmit} className={pageStyles.modalForm} style={{ display: 'flex', flexDirection: 'column', gap: '20px', overflowY: 'auto', overflowX: 'hidden', padding: '20px 24px', flex: '1 1 auto', minHeight: 0, width: '100%', boxSizing: 'border-box' }}>
                            <div className={pageStyles.formRow} style={{ flexShrink: 0, width: '100%' }}>
                                <div className={pageStyles.formGroup} style={{ flex: 1, minWidth: 0, width: '100%' }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                        <span>📝</span> Question Text (Scenario or clinical question) <span style={{ color: '#ef4444' }}>*</span>
                                    </label>
                                    <textarea
                                        required
                                        rows="3"
                                        value={formData.text}
                                        onChange={(e) => handleFormChange('text', e.target.value)}
                                        placeholder="e.g. A 45-year-old male presents with sudden chest pain..."
                                        style={{ width: '100%', minWidth: 0, boxSizing: 'border-box', lineHeight: '1.5' }}
                                    />
                                </div>
                            </div>

                            {/* Row 1: Specialty & Topic */}
                            <div className={pageStyles.formRow} style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px', width: '100%', flexShrink: 0 }}>
                                <div className={pageStyles.formGroup} style={{ minWidth: 0 }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                        <span>🩺</span> Main Specialty <span style={{ color: '#ef4444' }}>*</span>
                                    </label>
                                    <select
                                        required
                                        value={formData.specialtyId}
                                        onChange={(e) => handleFormChange('specialtyId', e.target.value)}
                                        style={{ width: '100%', minWidth: 0, boxSizing: 'border-box' }}
                                    >
                                        <option value="">Select Specialty</option>
                                        {specialties.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup} style={{ minWidth: 0 }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                        <span>🏷️</span> Specific Topic <span style={{ fontSize: '11px', color: '#64748b' }}>(Optional)</span>
                                    </label>
                                    <select
                                        value={formData.topicId}
                                        onChange={(e) => handleFormChange('topicId', e.target.value)}
                                        disabled={!formData.specialtyId}
                                        style={{ width: '100%', minWidth: 0, boxSizing: 'border-box' }}
                                    >
                                        <option value="">None / General</option>
                                        {formTopics.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                                    </select>
                                </div>
                            </div>

                            {/* Row 2: Difficulty & Premium Access */}
                            <div className={pageStyles.formRow} style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px', width: '100%', flexShrink: 0 }}>
                                <div className={pageStyles.formGroup} style={{ minWidth: 0 }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                        <span>⚡</span> Difficulty Level
                                    </label>
                                    <select
                                        value={formData.difficulty}
                                        onChange={(e) => handleFormChange('difficulty', e.target.value)}
                                        style={{ width: '100%', minWidth: 0, boxSizing: 'border-box' }}
                                    >
                                        <option value="easy">🟢 Easy (1 Point)</option>
                                        <option value="medium">🟡 Medium (2 Points)</option>
                                        <option value="hard">🔴 Hard (3 Points)</option>
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup} style={{ minWidth: 0 }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                                        <span>🔒</span> Access Tier
                                    </label>
                                    <div
                                        onClick={() => handleFormChange('isPremium', !formData.isPremium)}
                                        style={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'space-between',
                                            padding: '8px 14px',
                                            background: formData.isPremium ? 'rgba(245, 158, 11, 0.12)' : '#1e293b',
                                            border: formData.isPremium ? '1px solid rgba(245, 158, 11, 0.4)' : '1px solid #334155',
                                            borderRadius: '10px',
                                            cursor: 'pointer',
                                            userSelect: 'none',
                                            transition: 'all 0.2s ease',
                                            height: '42px',
                                            boxSizing: 'border-box'
                                        }}
                                    >
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                            <span style={{ fontSize: '16px' }}>{formData.isPremium ? '👑' : '🔓'}</span>
                                            <span style={{ fontSize: '13px', fontWeight: 600, color: formData.isPremium ? '#f59e0b' : '#cbd5e1' }}>
                                                {formData.isPremium ? 'Premium Question' : 'Free / Standard Question'}
                                            </span>
                                        </div>
                                        <input
                                            type="checkbox"
                                            checked={formData.isPremium}
                                            onChange={(e) => handleFormChange('isPremium', e.target.checked)}
                                            onClick={(e) => e.stopPropagation()}
                                            style={{
                                                width: '18px',
                                                height: '18px',
                                                accentColor: '#f59e0b',
                                                cursor: 'pointer'
                                            }}
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className={pageStyles.formSection} style={{ width: '100%', maxWidth: '100%', boxSizing: 'border-box', flexShrink: 0 }}>
                                <div className={pageStyles.sectionHeader} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <label style={{ margin: 0, fontWeight: 700, color: '#f8fafc', fontSize: '14px' }}>📋 Answer Options</label>
                                        <span style={{ fontSize: '11px', color: '#94a3b8', background: '#1e293b', padding: '2px 8px', borderRadius: '12px', border: '1px solid #334155' }}>
                                            Select the correct answer
                                        </span>
                                    </div>
                                    <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
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
                                                {aiLoading ? 'Generating...' : '✨ AI Generate Question'}
                                            </button>
                                        )}
                                    </div>
                                </div>
                                {formData.options.map((opt, idx) => (
                                    <div
                                        key={idx}
                                        style={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: '10px',
                                            padding: '10px 12px',
                                            borderRadius: '12px',
                                            background: opt.isCorrect ? '#064e3b25' : '#0f172a',
                                            border: opt.isCorrect ? '1.5px solid #10b981' : '1px solid #334155',
                                            transition: 'all 0.2s ease',
                                            marginBottom: '10px',
                                            boxShadow: opt.isCorrect ? '0 0 14px rgba(16, 185, 129, 0.15)' : 'none',
                                            width: '100%',
                                            maxWidth: '100%',
                                            boxSizing: 'border-box',
                                            minWidth: 0,
                                            flexShrink: 0
                                        }}
                                    >
                                        {/* Option Letter Badge (A, B, C, D) */}
                                        <div
                                            style={{
                                                width: '32px',
                                                height: '32px',
                                                borderRadius: '50%',
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                fontWeight: 800,
                                                fontSize: '13px',
                                                background: opt.isCorrect ? '#10b981' : '#334155',
                                                color: '#fff',
                                                flexShrink: 0,
                                                boxShadow: opt.isCorrect ? '0 2px 8px rgba(16, 185, 129, 0.4)' : 'none'
                                            }}
                                        >
                                            {String.fromCharCode(65 + idx)}
                                        </div>

                                        {/* Option Text Input */}
                                        <input
                                            type="text"
                                            required
                                            placeholder={`Option ${String.fromCharCode(65 + idx)} text...`}
                                            value={opt.text}
                                            onChange={(e) => handleOptionChange(idx, e.target.value)}
                                            style={{
                                                flex: 1,
                                                minWidth: 0,
                                                width: '100%',
                                                boxSizing: 'border-box',
                                                background: '#1e293b',
                                                border: '1px solid #334155',
                                                borderRadius: '8px',
                                                color: '#f8fafc',
                                                padding: '10px 14px',
                                                fontSize: '14px',
                                                outline: 'none',
                                                transition: 'border-color 0.2s'
                                            }}
                                            onFocus={(e) => e.target.style.borderColor = opt.isCorrect ? '#10b981' : '#6366f1'}
                                            onBlur={(e) => e.target.style.borderColor = '#334155'}
                                        />

                                        {/* Correct Toggle Pill */}
                                        <button
                                            type="button"
                                            onClick={() => setCorrectOption(idx)}
                                            style={{
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: '6px',
                                                padding: '7px 14px',
                                                borderRadius: '20px',
                                                border: opt.isCorrect ? '1.5px solid #10b981' : '1px solid #475569',
                                                background: opt.isCorrect ? 'linear-gradient(135deg, #059669, #10b981)' : '#1e293b',
                                                color: opt.isCorrect ? '#ffffff' : '#94a3b8',
                                                fontSize: '12px',
                                                fontWeight: 700,
                                                cursor: 'pointer',
                                                flexShrink: 0,
                                                transition: 'all 0.2s'
                                            }}
                                            title="Click to set as correct answer"
                                        >
                                            {opt.isCorrect ? '✓ Correct' : '○ Select'}
                                        </button>

                                        {/* Remove Option Button */}
                                        <button
                                            type="button"
                                            onClick={() => removeOption(idx)}
                                            disabled={formData.options.length <= 2}
                                            style={{
                                                width: '32px',
                                                height: '32px',
                                                borderRadius: '8px',
                                                border: '1px solid #ef444433',
                                                background: '#ef444415',
                                                color: '#f87171',
                                                cursor: formData.options.length <= 2 ? 'not-allowed' : 'pointer',
                                                opacity: formData.options.length <= 2 ? 0.3 : 1,
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                fontSize: '14px',
                                                flexShrink: 0,
                                                transition: 'all 0.15s'
                                            }}
                                            title="Delete this option"
                                        >
                                            🗑️
                                        </button>
                                    </div>
                                ))}
                            </div>

                            <div className={pageStyles.formGroup} style={{ width: '100%', minWidth: 0, boxSizing: 'border-box', flexShrink: 0 }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                                    <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, margin: 0 }}>💡 Explanation</label>
                                    {editingId && (
                                        <button
                                            type="button"
                                            onClick={handleAIGenerate}
                                            disabled={aiLoading}
                                            style={{
                                                background: aiLoading ? '#334155' : 'linear-gradient(135deg, #6366f1, #8b5cf6)',
                                                color: '#fff',
                                                border: 'none',
                                                padding: '7px 16px',
                                                borderRadius: '8px',
                                                cursor: aiLoading ? 'wait' : 'pointer',
                                                fontSize: '11px',
                                                fontWeight: 700,
                                                letterSpacing: '0.5px',
                                                opacity: aiLoading ? 0.7 : 1,
                                                transition: 'all 0.2s'
                                            }}
                                        >
                                            {aiLoading ? 'Generating...' : '✨ AI Generate'}
                                        </button>
                                    )}
                                </div>
                                <textarea
                                    placeholder="Explanation will be auto-filled by AI..."
                                    rows="5"
                                    value={formData.explanation.text}
                                    onChange={(e) => setFormData(prev => ({
                                        ...prev,
                                        explanation: { ...prev.explanation, text: e.target.value }
                                    }))}
                                    style={{ fontFamily: 'monospace', fontSize: '12px', lineHeight: '1.6', width: '100%', minWidth: 0, boxSizing: 'border-box' }}
                                />
                            </div>

                            <div className={pageStyles.formGroup} style={{ width: '100%', minWidth: 0, boxSizing: 'border-box', flexShrink: 0 }}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600, marginBottom: '6px' }}>📚 References</label>
                                <input
                                    type="text"
                                    placeholder="Medical references (auto-filled by AI)"
                                    value={formData.explanation.references}
                                    onChange={(e) => setFormData(prev => ({
                                        ...prev,
                                        explanation: { ...prev.explanation, references: e.target.value }
                                    }))}
                                    style={{ width: '100%', minWidth: 0, boxSizing: 'border-box' }}
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

                            <div className={pageStyles.modalFooter} style={{ borderTop: '1px solid #1e293b', paddingTop: '16px', marginTop: '16px' }}>
                                <button type="button" className={`${pageStyles.btn} ${pageStyles.btnSecondary}`} onClick={() => setShowModal(false)}>Cancel</button>
                                <button
                                    type="submit"
                                    className={`${pageStyles.btn}`}
                                    style={{
                                        background: 'linear-gradient(135deg, #10b981, #059669)',
                                        color: '#fff',
                                        padding: '9px 24px',
                                        borderRadius: '8px',
                                        fontWeight: 700,
                                        boxShadow: '0 4px 12px rgba(16, 185, 129, 0.35)'
                                    }}
                                >
                                    💾 Save Question
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* DOCX Modal */}
            {showDocxModal && (
                <div className={pageStyles.modalOverlay}>
                    <div className={pageStyles.modalCard} style={{ maxWidth: '480px', width: '90%' }}>
                        <div className={pageStyles.modalHeader}>
                            <h3>📥 Import Questions from DOCX</h3>
                            <button className={pageStyles.closeBtn} onClick={() => setShowDocxModal(false)}>&times;</button>
                        </div>
                        <form onSubmit={handleDocxSubmit} className={pageStyles.form} style={{ marginTop: '15px' }}>
                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600 }}>Specialty</label>
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
                                <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600 }}>Topic</label>
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
                                <label style={{ color: '#94a3b8', fontSize: '13px', fontWeight: 600 }}>Word Document (.docx)</label>
                                <div
                                    onClick={() => document.getElementById('docx-file-input').click()}
                                    style={{
                                        border: '2px dashed #6366f166',
                                        borderRadius: '12px',
                                        padding: '24px 16px',
                                        background: '#0f172a',
                                        textAlign: 'center',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s',
                                        position: 'relative'
                                    }}
                                >
                                    <input
                                        id="docx-file-input"
                                        type="file"
                                        accept=".docx"
                                        required
                                        onChange={(e) => setDocxData(prev => ({ ...prev, file: e.target.files[0] }))}
                                        style={{ display: 'none' }}
                                    />
                                    <div style={{ fontSize: '32px', marginBottom: '8px' }}>
                                        {docxData.file ? '📄' : '📤'}
                                    </div>
                                    {docxData.file ? (
                                        <div>
                                            <div style={{ color: '#38bdf8', fontWeight: 700, fontSize: '14px', wordBreak: 'break-all' }}>
                                                {docxData.file.name}
                                            </div>
                                            <div style={{ color: '#94a3b8', fontSize: '12px', marginTop: '4px' }}>
                                                {(docxData.file.size / 1024).toFixed(1)} KB • Click to change file
                                            </div>
                                        </div>
                                    ) : (
                                        <div>
                                            <div style={{ color: '#f8fafc', fontWeight: 600, fontSize: '14px' }}>
                                                Click to upload or drag .docx file here
                                            </div>
                                            <div style={{ color: '#64748b', fontSize: '12px', marginTop: '4px' }}>
                                                Supports multiple-choice questions with answers
                                            </div>
                                        </div>
                                    )}
                                </div>
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

                            <div className={pageStyles.modalFooter} style={{ marginTop: '24px', paddingTop: '16px', borderTop: '1px solid #1e293b' }}>
                                <button
                                    type="button"
                                    className={`${pageStyles.btn} ${pageStyles.btnSecondary}`}
                                    onClick={() => { setShowDocxModal(false); setStreamProgressPercent(null); }}
                                    disabled={docxLoading}
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className={`${pageStyles.btn}`}
                                    style={{
                                        background: docxLoading || !docxData.file
                                            ? '#475569'
                                            : 'linear-gradient(135deg, #6366f1, #4f46e5)',
                                        color: '#ffffff',
                                        padding: '10px 24px',
                                        borderRadius: '10px',
                                        fontWeight: 700,
                                        boxShadow: docxLoading || !docxData.file ? 'none' : '0 4px 14px rgba(99, 102, 241, 0.4)',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '8px',
                                        cursor: docxLoading || !docxData.file ? 'not-allowed' : 'pointer',
                                        transition: 'all 0.2s'
                                    }}
                                    disabled={docxLoading || !docxData.file}
                                >
                                    {docxLoading ? '⏳ AI is Parsing...' : '🚀 Import Questions'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
            {/* Move to Specialty Modal */}
            {showMoveModal && (
                <div className={pageStyles.modalOverlay} onClick={() => !moveLoading && setShowMoveModal(false)}>
                    <div 
                        className={pageStyles.modalCard} 
                        style={{ 
                            maxWidth: '540px', 
                            width: '90%',
                            background: '#0f172a',
                            border: '1px solid rgba(14, 165, 233, 0.3)',
                            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.7), 0 0 25px rgba(14, 165, 233, 0.15)',
                            borderRadius: '16px',
                            overflow: 'hidden'
                        }} 
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className={pageStyles.modalHeader} style={{ borderBottom: '1px solid #1e293b', padding: '18px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                <div style={{
                                    width: '38px',
                                    height: '38px',
                                    borderRadius: '10px',
                                    background: 'rgba(14, 165, 233, 0.15)',
                                    border: '1px solid rgba(14, 165, 233, 0.3)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    fontSize: '18px'
                                }}>
                                    🔄
                                </div>
                                <div>
                                    <h3 style={{ margin: 0, fontSize: '17px', color: '#f8fafc', fontWeight: 700 }}>
                                        {moveTarget?.type === 'single'
                                            ? 'نقل السؤال لتخصص آخر'
                                            : `نقل (${moveTarget?.count || selectedIds.length}) أسئلة لتخصص آخر`}
                                    </h3>
                                    <span style={{ fontSize: '12px', color: '#64748b' }}>
                                        Move Question to Another Specialty
                                    </span>
                                </div>
                            </div>
                            <button
                                className={pageStyles.closeBtn}
                                onClick={() => !moveLoading && setShowMoveModal(false)}
                                style={{ color: '#64748b', fontSize: '24px', cursor: 'pointer', background: 'none', border: 'none' }}
                            >
                                &times;
                            </button>
                        </div>
                        <form onSubmit={handleConfirmMove} className={pageStyles.form} style={{ padding: '24px', gap: '20px' }}>
                            {moveTarget?.type === 'single' && moveTarget?.question && (
                                <div style={{
                                    padding: '14px 16px',
                                    background: '#161b27',
                                    borderRadius: '10px',
                                    border: '1px solid #1e293b'
                                }}>
                                    <div style={{ fontSize: '12px', color: '#94a3b8', marginBottom: '6px' }}>
                                        Current Specialty: <strong style={{ color: '#38bdf8' }}>{moveTarget.question.specialty?.name || 'None'}</strong>
                                    </div>
                                    <div style={{
                                        fontSize: '13px',
                                        color: '#e2e8f0',
                                        lineHeight: '1.5',
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        display: '-webkit-box',
                                        WebkitLineClamp: 3,
                                        WebkitBoxOrient: 'vertical'
                                    }}>
                                        {moveTarget.question.text}
                                    </div>
                                </div>
                            )}

                            {moveTarget?.type === 'bulk' && (
                                <div style={{
                                    padding: '14px 16px',
                                    background: 'rgba(14, 165, 233, 0.1)',
                                    borderRadius: '10px',
                                    border: '1px solid rgba(14, 165, 233, 0.3)'
                                }}>
                                    <div style={{ fontSize: '14px', color: '#38bdf8', fontWeight: 600 }}>
                                        أنت على وشك نقل <strong>{moveTarget.count}</strong> أسئلة محددة إلى تخصص جديد.
                                    </div>
                                </div>
                            )}

                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#cbd5e1', fontSize: '13px', fontWeight: 600, marginBottom: '6px' }}>
                                    Target Specialty (التخصص الجديد المطلوب) *
                                </label>
                                <select
                                    required
                                    value={targetSpecialtyId}
                                    onChange={(e) => setTargetSpecialtyId(e.target.value)}
                                    style={{
                                        padding: '12px 14px',
                                        background: '#161b27',
                                        border: '1px solid #334155',
                                        borderRadius: '10px',
                                        color: '#f8fafc',
                                        fontSize: '14px',
                                        outline: 'none',
                                        cursor: 'pointer'
                                    }}
                                >
                                    <option value="">-- Choose Target Specialty --</option>
                                    {specialties.map(s => (
                                        <option key={s.id} value={s.id}>{s.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#cbd5e1', fontSize: '13px', fontWeight: 600, marginBottom: '6px' }}>
                                    Target Topic (التوبيك التابع له - اختياري)
                                </label>
                                <select
                                    value={targetTopicId}
                                    onChange={(e) => setTargetTopicId(e.target.value)}
                                    disabled={!targetSpecialtyId}
                                    style={{
                                        padding: '12px 14px',
                                        background: '#161b27',
                                        border: '1px solid #334155',
                                        borderRadius: '10px',
                                        color: '#f8fafc',
                                        fontSize: '14px',
                                        outline: 'none',
                                        cursor: targetSpecialtyId ? 'pointer' : 'not-allowed',
                                        opacity: targetSpecialtyId ? 1 : 0.6
                                    }}
                                >
                                    <option value="">
                                        {moveTopics.length === 0 && targetSpecialtyId ? 'No topics available (General)' : '-- None / General (Optional) --'}
                                    </option>
                                    {moveTopics.map(t => (
                                        <option key={t.id} value={t.id}>{t.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className={pageStyles.modalFooter} style={{ borderTop: '1px solid #1e293b', paddingTop: '20px', marginTop: '10px', display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                                <button
                                    type="button"
                                    disabled={moveLoading}
                                    onClick={() => setShowMoveModal(false)}
                                    style={{
                                        background: '#1e293b',
                                        color: '#94a3b8',
                                        border: '1px solid #334155',
                                        padding: '10px 20px',
                                        borderRadius: '10px',
                                        fontWeight: 600,
                                        fontSize: '14px',
                                        cursor: moveLoading ? 'not-allowed' : 'pointer',
                                        transition: 'all 0.15s ease'
                                    }}
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={moveLoading || !targetSpecialtyId}
                                    style={{
                                        background: moveLoading || !targetSpecialtyId
                                            ? '#334155'
                                            : 'linear-gradient(135deg, #0284c7 0%, #0369a1 100%)',
                                        color: '#ffffff',
                                        border: 'none',
                                        padding: '10px 24px',
                                        borderRadius: '10px',
                                        fontWeight: 700,
                                        fontSize: '14px',
                                        boxShadow: moveLoading || !targetSpecialtyId
                                            ? 'none'
                                            : '0 4px 14px rgba(2, 132, 199, 0.4)',
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '8px',
                                        cursor: moveLoading || !targetSpecialtyId ? 'not-allowed' : 'pointer',
                                        transition: 'all 0.2s ease'
                                    }}
                                >
                                    <span>{moveLoading ? '⏳' : '🔄'}</span>
                                    <span>{moveLoading ? 'Moving...' : 'Confirm Move'}</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
