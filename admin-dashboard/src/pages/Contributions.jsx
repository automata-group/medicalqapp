import { useEffect, useState, useCallback } from 'react';
import {
    getContributions,
    getContribution,
    updateContributionStatus,
    convertContributionToQuestion,
    getSpecialties
} from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Contributions() {
    const [contributions, setContributions] = useState([]);
    const [specialties, setSpecialties] = useState([]);
    const [stats, setStats] = useState({ total: 0, pending: 0, reviewing: 0, approved: 0, clusters: 0 });
    const [loading, setLoading] = useState(true);

    // Filters & Pagination
    const [statusFilter, setStatusFilter] = useState('all');
    const [specialtyFilter, setSpecialtyFilter] = useState('all');
    const [sortBy, setSortBy] = useState('newest');
    const [search, setSearch] = useState('');
    const [debouncedSearch, setDebouncedSearch] = useState('');
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [clusterOnly, setClusterOnly] = useState(false);

    // Modals
    const [activeContribution, setActiveContribution] = useState(null);
    const [inspectModalOpen, setInspectModalOpen] = useState(false);
    const [convertModalOpen, setConvertModalOpen] = useState(false);
    const [converting, setConverting] = useState(false);
    const [statusUpdating, setStatusUpdating] = useState(false);

    // Convert Form State
    const [convertData, setConvertData] = useState({
        text: '',
        specialtyId: '',
        topicId: '',
        subTopic: 'Exam Recall',
        difficulty: 'medium',
        options: [
            { key: 'A', text: '', isCorrect: false },
            { key: 'B', text: '', isCorrect: false },
            { key: 'C', text: '', isCorrect: false },
            { key: 'D', text: '', isCorrect: false }
        ],
        correctOptionOrder: 'A',
        generateAiExplanation: true,
        approveClusterSiblings: true
    });

    // Fetch Specialties
    useEffect(() => {
        getSpecialties()
            .then((res) => {
                const list = res.data?.data || res.data || [];
                setSpecialties(list);
            })
            .catch((err) => console.error('Error fetching specialties:', err));
    }, []);

    // Handle Search debounce
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedSearch(search);
            setPage(1);
        }, 400);
        return () => clearTimeout(timer);
    }, [search]);

    // Fetch Contributions
    const fetchData = useCallback(async () => {
        setLoading(true);
        try {
            const params = {
                page,
                limit: 15,
                sortBy,
                clusterOnly: clusterOnly ? 'true' : 'false'
            };
            if (statusFilter !== 'all') params.status = statusFilter;
            if (specialtyFilter !== 'all') params.specialtyId = specialtyFilter;
            if (debouncedSearch.trim()) params.search = debouncedSearch.trim();

            const res = await getContributions(params);
            if (res.data?.success) {
                setContributions(res.data.data || []);
                setTotalPages(res.data.totalPages || 1);
                if (res.data.stats) {
                    setStats(res.data.stats);
                }
            }
        } catch (error) {
            console.error('Error fetching contributions:', error);
        } finally {
            setLoading(false);
        }
    }, [page, statusFilter, specialtyFilter, sortBy, clusterOnly, debouncedSearch]);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    // Open Inspect Modal with full cluster siblings
    const handleInspect = async (item) => {
        try {
            const res = await getContribution(item.id);
            if (res.data?.success) {
                setActiveContribution(res.data.data);
            } else {
                setActiveContribution(item);
            }
        } catch {
            setActiveContribution(item);
        }
        setInspectModalOpen(true);
    };

    // Open Convert Modal
    const handleOpenConvert = (item) => {
        const opts = (item.options && item.options.length === 4)
            ? item.options.map((o, idx) => ({
                key: o.key || String.fromCharCode(65 + idx),
                text: o.text || '',
                isCorrect: (o.key || String.fromCharCode(65 + idx)) === item.userAnswer
            }))
            : [
                { key: 'A', text: item.options?.[0]?.text || '', isCorrect: item.userAnswer === 'A' },
                { key: 'B', text: item.options?.[1]?.text || '', isCorrect: item.userAnswer === 'B' },
                { key: 'C', text: item.options?.[2]?.text || '', isCorrect: item.userAnswer === 'C' },
                { key: 'D', text: item.options?.[3]?.text || '', isCorrect: item.userAnswer === 'D' }
            ];

        const detectedCorrect = item.userAnswer && ['A', 'B', 'C', 'D'].includes(item.userAnswer)
            ? item.userAnswer
            : 'A';

        setConvertData({
            text: item.questionText || '',
            specialtyId: item.specialtyId || (specialties[0]?.id || ''),
            topicId: item.topicId || '',
            subTopic: 'Exam Recall',
            difficulty: 'medium',
            options: opts,
            correctOptionOrder: detectedCorrect,
            generateAiExplanation: true,
            approveClusterSiblings: Boolean(item.clusterId)
        });

        setActiveContribution(item);
        setConvertModalOpen(true);
    };

    // Quick Status Update
    const handleStatusUpdate = async (id, newStatus) => {
        setStatusUpdating(true);
        try {
            await updateContributionStatus(id, { status: newStatus });
            setContributions((prev) =>
                prev.map((c) => (c.id === id ? { ...c, status: newStatus } : c))
            );
            if (activeContribution && activeContribution.id === id) {
                setActiveContribution((prev) => ({ ...prev, status: newStatus }));
            }
        } catch (error) {
            alert('Failed to update status: ' + (error.response?.data?.message || error.message));
        } finally {
            setStatusUpdating(false);
        }
    };

    // Submit Conversion to Official Question
    const handleConvertSubmit = async (e) => {
        e.preventDefault();
        if (!convertData.text.trim()) {
            alert('Question text cannot be empty');
            return;
        }

        setConverting(true);
        try {
            const payload = {
                text: convertData.text,
                specialtyId: convertData.specialtyId,
                topicId: convertData.topicId || null,
                subTopic: convertData.subTopic,
                difficulty: convertData.difficulty,
                options: convertData.options,
                correctOptionOrder: convertData.correctOptionOrder,
                generateAiExplanation: convertData.generateAiExplanation,
                approveClusterSiblings: convertData.approveClusterSiblings
            };

            const res = await convertContributionToQuestion(activeContribution.id, payload);
            if (res.data?.success) {
                alert('🎉 Question successfully added to Question Bank!');
                setConvertModalOpen(false);
                fetchData();
            }
        } catch (error) {
            alert('Error converting question: ' + (error.response?.data?.message || error.message));
        } finally {
            setConverting(false);
        }
    };

    // Status Badges config matching screenshots
    const getStatusBadge = (status) => {
        switch (status) {
            case 'pending':
                return { label: '🟠 Pending', bg: '#f59e0b22', color: '#fbbf24' };
            case 'reviewing':
                return { label: '🔵 Reviewing', bg: '#3b82f622', color: '#60a5fa' };
            case 'needs_info':
                return { label: '🟣 Needs Info', bg: '#a855f722', color: '#c084fc' };
            case 'approved':
                return { label: '🟢 Approved', bg: '#10b98122', color: '#34d399' };
            case 'rejected':
                return { label: '🔴 Rejected', bg: '#ef444422', color: '#f87171' };
            case 'duplicate':
                return { label: '⚫ Duplicate', bg: '#64748b22', color: '#94a3b8' };
            default:
                return { label: status, bg: '#334155', color: '#cbd5e1' };
        }
    };

    // Confidence Badges
    const getConfidenceBadge = (level) => {
        switch (level) {
            case 'high':
                return <span style={{ color: '#34d399', fontWeight: 600 }}>🟢 High (أتذكره جيداً)</span>;
            case 'medium':
                return <span style={{ color: '#fbbf24', fontWeight: 600 }}>🟡 Medium (أتذكر معظمه)</span>;
            case 'low':
                return <span style={{ color: '#f87171', fontWeight: 600 }}>🔴 Low (الفكرة فقط)</span>;
            default:
                return <span>{level}</span>;
        }
    };

    return (
        <div style={{ paddingBottom: '50px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div>
                    <h2 className={styles.pageTitle} style={{ margin: 0 }}>📥 Question Contributions (Exam Recalls)</h2>
                    <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '13px' }}>
                        Manage crowdsourced exam questions submitted by students, detect duplicates, and convert into official QBank questions.
                    </p>
                </div>
            </div>

            {/* KPI Summary Cards */}
            <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
                gap: '16px',
                marginBottom: '24px'
            }}>
                <div style={{ background: '#161b27', border: '1px solid #1e293b', borderRadius: '12px', padding: '16px' }}>
                    <div style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 500 }}>Total Submissions</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#f8fafc', marginTop: '6px' }}>{stats.total}</div>
                </div>
                <div style={{ background: '#161b27', border: '1px solid #f59e0b44', borderRadius: '12px', padding: '16px' }}>
                    <div style={{ color: '#fbbf24', fontSize: '12px', fontWeight: 500 }}>🟠 Pending Triage</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#fbbf24', marginTop: '6px' }}>{stats.pending}</div>
                </div>
                <div style={{ background: '#161b27', border: '1px solid #3b82f644', borderRadius: '12px', padding: '16px' }}>
                    <div style={{ color: '#60a5fa', fontSize: '12px', fontWeight: 500 }}>🔵 Under Review</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#60a5fa', marginTop: '6px' }}>{stats.reviewing}</div>
                </div>
                <div style={{ background: '#161b27', border: '1px solid #10b98144', borderRadius: '12px', padding: '16px' }}>
                    <div style={{ color: '#34d399', fontSize: '12px', fontWeight: 500 }}>🟢 Converted to Bank</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#34d399', marginTop: '6px' }}>{stats.approved}</div>
                </div>
                <div style={{ background: '#161b27', border: '1px solid #f43f5e44', borderRadius: '12px', padding: '16px' }}>
                    <div style={{ color: '#fb7185', fontSize: '12px', fontWeight: 500 }}>🔥 Clustered Duplicates</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#fb7185', marginTop: '6px' }}>{stats.clusters}</div>
                </div>
            </div>

            {/* Filter & Toolbar */}
            <div className={pageStyles.toolbar} style={{ background: '#161b27', padding: '16px', borderRadius: '12px', border: '1px solid #1e293b' }}>
                <input
                    type="text"
                    className={pageStyles.search}
                    placeholder="Search by keywords, symptoms, terms..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    style={{ minWidth: '260px' }}
                />

                {/* Status Filter */}
                <select
                    value={statusFilter}
                    onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
                    style={{ background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155', padding: '8px 12px', borderRadius: '8px', fontSize: '13px' }}
                >
                    <option value="all">All Statuses</option>
                    <option value="pending">🟠 Pending</option>
                    <option value="reviewing">🔵 Reviewing</option>
                    <option value="needs_info">🟣 Needs Info</option>
                    <option value="approved">🟢 Approved</option>
                    <option value="rejected">🔴 Rejected</option>
                    <option value="duplicate">⚫ Duplicate</option>
                </select>

                {/* Specialty Filter */}
                <select
                    value={specialtyFilter}
                    onChange={(e) => { setSpecialtyFilter(e.target.value); setPage(1); }}
                    style={{ background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155', padding: '8px 12px', borderRadius: '8px', fontSize: '13px' }}
                >
                    <option value="all">All Specialties</option>
                    {specialties.map((s) => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                    ))}
                </select>

                {/* Sort By */}
                <select
                    value={sortBy}
                    onChange={(e) => { setSortBy(e.target.value); setPage(1); }}
                    style={{ background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155', padding: '8px 12px', borderRadius: '8px', fontSize: '13px' }}
                >
                    <option value="newest">🕒 Sort: Newest First (الأحدث)</option>
                    <option value="most_repeated">🔥 Sort: Most Repeated (الأكثر تكراراً)</option>
                    <option value="exam_date">📅 Sort: Exam Date (تاريخ الاختبار)</option>
                    <option value="priority">⚡ Sort: Priority (الأولوية)</option>
                </select>

                {/* Cluster Filter Toggle */}
                <label style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#cbd5e1', fontSize: '13px', cursor: 'pointer', marginLeft: 'auto' }}>
                    <input
                        type="checkbox"
                        checked={clusterOnly}
                        onChange={(e) => { setClusterOnly(e.target.checked); setPage(1); }}
                    />
                    <span>🔥 Duplicates Only</span>
                </label>
            </div>

            {/* Content Table / Cards */}
            <div className={styles.tableWrap} style={{ marginTop: '16px' }}>
                <table>
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Specialty</th>
                            <th>Question Recall</th>
                            <th>Recall Accuracy</th>
                            <th>Exam Date</th>
                            <th>User Answer</th>
                            <th>Status</th>
                            <th style={{ textAlign: 'right' }}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="8" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
                                    Loading contributions...
                                </td>
                            </tr>
                        ) : contributions.length === 0 ? (
                            <tr>
                                <td colSpan="8" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
                                    No contributions found matching your filters.
                                </td>
                            </tr>
                        ) : (
                            contributions.map((item) => {
                                const badge = getStatusBadge(item.status);
                                const isClustered = item.cluster && item.cluster.totalReports > 1;

                                return (
                                    <tr key={item.id} style={{ background: isClustered ? '#1e1b4b15' : 'transparent' }}>
                                        <td style={{ fontFamily: 'monospace', color: '#94a3b8', whiteSpace: 'nowrap' }}>
                                            #{item.id}
                                        </td>
                                        <td>
                                            <span style={{
                                                background: '#1e293b',
                                                color: '#38bdf8',
                                                padding: '3px 8px',
                                                borderRadius: '6px',
                                                fontSize: '12px',
                                                fontWeight: 500
                                            }}>
                                                {item.specialty?.name || 'General'}
                                            </span>
                                        </td>
                                        <td style={{ maxWidth: '340px' }}>
                                            {isClustered && (
                                                <div style={{
                                                    display: 'inline-flex',
                                                    alignItems: 'center',
                                                    gap: '4px',
                                                    background: '#e11d4822',
                                                    color: '#fb7185',
                                                    border: '1px solid #e11d4844',
                                                    padding: '2px 8px',
                                                    borderRadius: '4px',
                                                    fontSize: '11px',
                                                    fontWeight: 600,
                                                    marginBottom: '4px'
                                                }}>
                                                    🔥 Possible Duplicate — {item.cluster.totalReports} users reported similar
                                                </div>
                                            )}
                                            <div style={{
                                                color: '#f8fafc',
                                                fontSize: '13px',
                                                fontWeight: 500,
                                                lineHeight: 1.4,
                                                display: '-webkit-box',
                                                WebkitLineClamp: 2,
                                                WebkitBoxOrient: 'vertical',
                                                overflow: 'hidden'
                                            }}>
                                                {item.questionText}
                                            </div>
                                            <div style={{ fontSize: '11px', color: '#64748b', marginTop: '2px' }}>
                                                Submitted by: {item.user?.name || `User #${item.userId}`}
                                            </div>
                                        </td>
                                        <td style={{ fontSize: '12px' }}>
                                            {getConfidenceBadge(item.confidenceLevel)}
                                        </td>
                                        <td style={{ fontSize: '12px', color: '#94a3b8', whiteSpace: 'nowrap' }}>
                                            {item.examDate || '—'}
                                        </td>
                                        <td>
                                            <span style={{
                                                background: item.userAnswer && item.userAnswer !== 'unsure' ? '#10b98122' : '#334155',
                                                color: item.userAnswer && item.userAnswer !== 'unsure' ? '#34d399' : '#94a3b8',
                                                padding: '2px 8px',
                                                borderRadius: '4px',
                                                fontSize: '12px',
                                                fontWeight: 700
                                            }}>
                                                {item.userAnswer || 'Unsure'}
                                            </span>
                                        </td>
                                        <td>
                                            <span className={pageStyles.badge} style={{ background: badge.bg, color: badge.color }}>
                                                {badge.label}
                                            </span>
                                        </td>
                                        <td style={{ textAlign: 'right', whiteSpace: 'nowrap' }}>
                                            <button
                                                className={pageStyles.btn}
                                                style={{ background: '#334155', color: '#e2e8f0', marginRight: '6px' }}
                                                onClick={() => handleInspect(item)}
                                                title="View details and cluster comparison"
                                            >
                                                👁️ View
                                            </button>
                                            {item.status !== 'approved' && (
                                                <button
                                                    className={`${pageStyles.btn} ${pageStyles.btnPrimary}`}
                                                    onClick={() => handleOpenConvert(item)}
                                                    title="Convert into Question Bank"
                                                >
                                                    ✨ Convert to Bank
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                );
                            })
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
                <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginTop: '20px' }}>
                    <button
                        className={pageStyles.btnSecondary}
                        disabled={page === 1}
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                    >
                        Previous
                    </button>
                    <span style={{ color: '#94a3b8', padding: '8px 12px', fontSize: '13px' }}>
                        Page {page} of {totalPages}
                    </span>
                    <button
                        className={pageStyles.btnSecondary}
                        disabled={page === totalPages}
                        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    >
                        Next
                    </button>
                </div>
            )}

            {/* MODAL 1: Inspect & Compare Cluster Sibling Submissions */}
            {inspectModalOpen && activeContribution && (
                <div className={pageStyles.modalOverlay} onClick={() => setInspectModalOpen(false)}>
                    <div
                        className={pageStyles.modal}
                        style={{ maxWidth: '850px', width: '90%' }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className={pageStyles.modalHeader}>
                            <h3>Contribution #{activeContribution.id} Details</h3>
                            <button className={pageStyles.closeBtn} onClick={() => setInspectModalOpen(false)}>×</button>
                        </div>

                        <div className={pageStyles.modalForm}>
                            {/* Duplicate Cluster Alert Banner */}
                            {activeContribution.cluster && (
                                <div style={{
                                    background: '#881337',
                                    border: '1px solid #f43f5e',
                                    borderRadius: '8px',
                                    padding: '12px 16px',
                                    color: '#ffe4e6'
                                }}>
                                    <div style={{ fontWeight: 700, display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <span>🔥 Possible Duplicate Topic Detected!</span>
                                        <span style={{ background: '#ffffff33', padding: '2px 8px', borderRadius: '12px', fontSize: '12px' }}>
                                            {activeContribution.cluster.totalReports} total reports
                                        </span>
                                    </div>
                                    <div style={{ fontSize: '13px', marginTop: '4px', opacity: 0.9 }}>
                                        Cluster: <strong>{activeContribution.cluster.title}</strong>
                                    </div>
                                </div>
                            )}

                            {/* Meta Grid */}
                            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px', background: '#161b27', padding: '14px', borderRadius: '8px' }}>
                                <div>
                                    <div style={{ color: '#64748b', fontSize: '11px' }}>Specialty</div>
                                    <div style={{ color: '#38bdf8', fontWeight: 600 }}>{activeContribution.specialty?.name || 'General'}</div>
                                </div>
                                <div>
                                    <div style={{ color: '#64748b', fontSize: '11px' }}>Exam Date</div>
                                    <div style={{ color: '#e2e8f0', fontWeight: 600 }}>{activeContribution.examDate || 'Not specified'}</div>
                                </div>
                                <div>
                                    <div style={{ color: '#64748b', fontSize: '11px' }}>Confidence Level</div>
                                    <div>{getConfidenceBadge(activeContribution.confidenceLevel)}</div>
                                </div>
                                <div>
                                    <div style={{ color: '#64748b', fontSize: '11px' }}>Submitted By</div>
                                    <div style={{ color: '#e2e8f0' }}>{activeContribution.user?.name || `User #${activeContribution.userId}`}</div>
                                </div>
                            </div>

                            {/* Question Text */}
                            <div>
                                <label style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 600 }}>ما يتذكره الطالب من السؤال (Question Text):</label>
                                <div style={{
                                    background: '#1e293b',
                                    padding: '14px',
                                    borderRadius: '8px',
                                    color: '#f8fafc',
                                    fontSize: '14px',
                                    lineHeight: '1.6',
                                    marginTop: '6px'
                                }}>
                                    {activeContribution.questionText}
                                </div>
                            </div>

                            {/* Options */}
                            {activeContribution.options && activeContribution.options.length > 0 && (
                                <div>
                                    <label style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 600 }}>الخيارات المذكورة (Options):</label>
                                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginTop: '6px' }}>
                                        {activeContribution.options.map((opt, i) => {
                                            const key = opt.key || String.fromCharCode(65 + i);
                                            const isSelected = key === activeContribution.userAnswer;
                                            return (
                                                <div key={i} style={{
                                                    background: isSelected ? '#10b98122' : '#1e293b',
                                                    border: isSelected ? '1px solid #10b981' : '1px solid #334155',
                                                    padding: '8px 12px',
                                                    borderRadius: '6px',
                                                    color: '#f8fafc',
                                                    fontSize: '13px',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    gap: '8px'
                                                }}>
                                                    <strong style={{ color: isSelected ? '#34d399' : '#38bdf8' }}>{key}.</strong>
                                                    <span>{opt.text || <em style={{ color: '#64748b' }}>Empty</em>}</span>
                                                    {isSelected && <span style={{ marginLeft: 'auto', fontSize: '11px', color: '#34d399' }}>(Student Answer)</span>}
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            )}

                            {/* Student Note */}
                            {activeContribution.notes && (
                                <div>
                                    <label style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 600 }}>شرح أو ملاحظة من الطالب (Notes):</label>
                                    <div style={{ background: '#1e293b', padding: '10px 14px', borderRadius: '6px', color: '#cbd5e1', fontSize: '13px', marginTop: '4px' }}>
                                        {activeContribution.notes}
                                    </div>
                                </div>
                            )}

                            {/* Attached Image if any */}
                            {activeContribution.imageUrl && (
                                <div>
                                    <label style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 600 }}>مرفق مع المساهمة (Attachment):</label>
                                    <div style={{ marginTop: '6px' }}>
                                        <img
                                            src={activeContribution.imageUrl}
                                            alt="Contribution attachment"
                                            style={{ maxWidth: '100%', maxHeight: '250px', borderRadius: '8px', border: '1px solid #334155' }}
                                        />
                                    </div>
                                </div>
                            )}

                            {/* Cluster Sibling Reports: Compare other student formulations side-by-side! */}
                            {activeContribution.cluster?.contributions?.length > 0 && (
                                <div style={{ borderTop: '1px solid #334155', paddingTop: '16px', marginTop: '10px' }}>
                                    <h4 style={{ color: '#fb7185', margin: '0 0 10px 0', fontSize: '14px' }}>
                                        👥 Other Students' Variations for this Exact Question ({activeContribution.cluster.contributions.length} others):
                                    </h4>
                                    <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                        {activeContribution.cluster.contributions.map((sib) => (
                                            <div key={sib.id} style={{ background: '#131926', border: '1px solid #1e293b', padding: '10px 14px', borderRadius: '8px' }}>
                                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#64748b', marginBottom: '4px' }}>
                                                    <span>User #{sib.userId} ({sib.user?.name || 'Student'})</span>
                                                    <span>Exam Date: {sib.examDate || 'N/A'} • Confidence: {sib.confidenceLevel}</span>
                                                </div>
                                                <div style={{ color: '#e2e8f0', fontSize: '13px', fontStyle: 'italic' }}>
                                                    "{sib.questionText}"
                                                </div>
                                                {sib.userAnswer && (
                                                    <div style={{ fontSize: '11px', color: '#34d399', marginTop: '4px' }}>
                                                        Reported answer: Option {sib.userAnswer}
                                                    </div>
                                                )}
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}

                            {/* Status Change Buttons */}
                            <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginTop: '10px', paddingTop: '12px', borderTop: '1px solid #1e293b' }}>
                                <span style={{ color: '#94a3b8', fontSize: '12px', alignSelf: 'center' }}>Change Status:</span>
                                <button
                                    className={pageStyles.btn}
                                    style={{ background: '#f59e0b22', color: '#fbbf24', border: '1px solid #f59e0b44' }}
                                    onClick={() => handleStatusUpdate(activeContribution.id, 'pending')}
                                    disabled={statusUpdating}
                                >
                                    🟠 Pending
                                </button>
                                <button
                                    className={pageStyles.btn}
                                    style={{ background: '#3b82f622', color: '#60a5fa', border: '1px solid #3b82f644' }}
                                    onClick={() => handleStatusUpdate(activeContribution.id, 'reviewing')}
                                    disabled={statusUpdating}
                                >
                                    🔵 Reviewing
                                </button>
                                <button
                                    className={pageStyles.btn}
                                    style={{ background: '#a855f722', color: '#c084fc', border: '1px solid #a855f744' }}
                                    onClick={() => handleStatusUpdate(activeContribution.id, 'needs_info')}
                                    disabled={statusUpdating}
                                >
                                    🟣 Needs Info
                                </button>
                                <button
                                    className={pageStyles.btn}
                                    style={{ background: '#ef444422', color: '#f87171', border: '1px solid #ef444444' }}
                                    onClick={() => handleStatusUpdate(activeContribution.id, 'rejected')}
                                    disabled={statusUpdating}
                                >
                                    🔴 Reject
                                </button>
                                <button
                                    className={pageStyles.btn}
                                    style={{ background: '#64748b22', color: '#94a3b8', border: '1px solid #64748b44' }}
                                    onClick={() => handleStatusUpdate(activeContribution.id, 'duplicate')}
                                    disabled={statusUpdating}
                                >
                                    ⚫ Duplicate
                                </button>
                            </div>
                        </div>

                        <div className={pageStyles.modalFooter}>
                            <button className={pageStyles.btnSecondary} onClick={() => setInspectModalOpen(false)}>
                                Close
                            </button>
                            {activeContribution.status !== 'approved' && (
                                <button
                                    className={pageStyles.btnPrimary}
                                    onClick={() => {
                                        setInspectModalOpen(false);
                                        handleOpenConvert(activeContribution);
                                    }}
                                >
                                    ✨ Convert to Official Question
                                </button>
                            )}
                        </div>
                    </div>
                </div>
            )}

            {/* MODAL 2: 1-Click Convert to Official Question with AI Generation */}
            {convertModalOpen && activeContribution && (
                <div className={pageStyles.modalOverlay} onClick={() => setConvertModalOpen(false)}>
                    <div
                        className={pageStyles.modal}
                        style={{ maxWidth: '850px', width: '90%' }}
                        onClick={(e) => e.stopPropagation()}
                    >
                        <div className={pageStyles.modalHeader}>
                            <h3>✨ Add to Official Question Bank</h3>
                            <button className={pageStyles.closeBtn} onClick={() => setConvertModalOpen(false)}>×</button>
                        </div>

                        <form onSubmit={handleConvertSubmit} className={pageStyles.modalForm}>
                            <div className={pageStyles.formGroup}>
                                <label>Final Formulated Question Text (نص السؤال الرسمي):</label>
                                <textarea
                                    rows="4"
                                    value={convertData.text}
                                    onChange={(e) => setConvertData({ ...convertData, text: e.target.value })}
                                    required
                                />
                            </div>

                            <div className={pageStyles.formRow}>
                                <div className={pageStyles.formGroup}>
                                    <label>Specialty:</label>
                                    <select
                                        value={convertData.specialtyId}
                                        onChange={(e) => setConvertData({ ...convertData, specialtyId: e.target.value })}
                                        required
                                    >
                                        {specialties.map((s) => (
                                            <option key={s.id} value={s.id}>{s.name}</option>
                                        ))}
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup}>
                                    <label>Difficulty:</label>
                                    <select
                                        value={convertData.difficulty}
                                        onChange={(e) => setConvertData({ ...convertData, difficulty: e.target.value })}
                                    >
                                        <option value="easy">Easy</option>
                                        <option value="medium">Medium</option>
                                        <option value="hard">Hard</option>
                                    </select>
                                </div>
                                <div className={pageStyles.formGroup}>
                                    <label>Correct Answer:</label>
                                    <select
                                        value={convertData.correctOptionOrder}
                                        onChange={(e) => setConvertData({ ...convertData, correctOptionOrder: e.target.value })}
                                        style={{ borderColor: '#10b981', color: '#34d399', fontWeight: 700 }}
                                    >
                                        <option value="A">Option A</option>
                                        <option value="B">Option B</option>
                                        <option value="C">Option C</option>
                                        <option value="D">Option D</option>
                                    </select>
                                </div>
                            </div>

                            {/* Options Form */}
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                                {convertData.options.map((opt, i) => (
                                    <div key={opt.key} className={pageStyles.formGroup}>
                                        <label style={{ display: 'flex', justifyContent: 'space-between' }}>
                                            <span>Option {opt.key}:</span>
                                            {convertData.correctOptionOrder === opt.key && (
                                                <span style={{ color: '#34d399', fontWeight: 600 }}>✓ Correct</span>
                                            )}
                                        </label>
                                        <input
                                            type="text"
                                            value={opt.text}
                                            onChange={(e) => {
                                                const updated = [...convertData.options];
                                                updated[i].text = e.target.value;
                                                setConvertData({ ...convertData, options: updated });
                                            }}
                                            placeholder={`Enter option ${opt.key} text`}
                                            required
                                        />
                                    </div>
                                ))}
                            </div>

                            {/* AI Automation Checkboxes */}
                            <div style={{ background: '#1e1b4b33', border: '1px solid #6366f144', padding: '14px', borderRadius: '8px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                <label style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#c7d2fe', fontSize: '13px', cursor: 'pointer' }}>
                                    <input
                                        type="checkbox"
                                        checked={convertData.generateAiExplanation}
                                        onChange={(e) => setConvertData({ ...convertData, generateAiExplanation: e.target.checked })}
                                    />
                                    <span>
                                        🤖 <strong>Generate AI Clinical Explanation & References automatically</strong>
                                    </span>
                                </label>

                                {activeContribution.clusterId && (
                                    <label style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#fbcfe8', fontSize: '13px', cursor: 'pointer' }}>
                                        <input
                                            type="checkbox"
                                            checked={convertData.approveClusterSiblings}
                                            onChange={(e) => setConvertData({ ...convertData, approveClusterSiblings: e.target.checked })}
                                        />
                                        <span>
                                            👥 <strong>Mark all {activeContribution.cluster?.totalReports || 'sibling'} user submissions in this cluster as Approved & Resolved</strong>
                                        </span>
                                    </label>
                                )}
                            </div>

                            <div className={pageStyles.modalFooter} style={{ padding: '16px 0 0 0', border: 'none' }}>
                                <button
                                    type="button"
                                    className={pageStyles.btnSecondary}
                                    onClick={() => setConvertModalOpen(false)}
                                    disabled={converting}
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className={pageStyles.btnPrimary}
                                    disabled={converting}
                                    style={{ minWidth: '180px' }}
                                >
                                    {converting ? 'Processing with AI...' : 'Publish to Question Bank 🚀'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
