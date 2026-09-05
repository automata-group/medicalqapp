import { useEffect, useState, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { getReports, getReport, updateReportStatus } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Reports() {
    const navigate = useNavigate();

    const [reports, setReports] = useState([]);
    const [stats, setStats] = useState({ total: 0, pending: 0, reviewing: 0, resolved: 0, dismissed: 0 });
    const [loading, setLoading] = useState(true);

    // Filters & Pagination
    const [statusFilter, setStatusFilter] = useState('all');
    const [reasonFilter, setReasonFilter] = useState('all');
    const [search, setSearch] = useState('');
    const [debouncedSearch, setDebouncedSearch] = useState('');
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);

    // Inspect / Review Modal
    const [activeReport, setActiveReport] = useState(null);
    const [inspectModalOpen, setInspectModalOpen] = useState(false);
    const [inspectLoading, setInspectLoading] = useState(false);
    const [adminNotesInput, setAdminNotesInput] = useState('');
    const [savingStatus, setSavingStatus] = useState(false);

    // Debounce search
    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedSearch(search);
            setPage(1);
        }, 400);
        return () => clearTimeout(timer);
    }, [search]);

    // Fetch reports
    const fetchReports = useCallback(async () => {
        setLoading(true);
        try {
            const params = {
                page,
                limit: 15
            };
            if (statusFilter !== 'all') params.status = statusFilter;
            if (reasonFilter !== 'all') params.reason = reasonFilter;
            if (debouncedSearch.trim()) params.search = debouncedSearch.trim();

            const res = await getReports(params);
            if (res.data?.success) {
                setReports(res.data.data || []);
                setTotalPages(res.data.totalPages || 1);
                if (res.data.stats) {
                    setStats(res.data.stats);
                }
            } else {
                setReports(res.data?.data || res.data || []);
            }
        } catch (error) {
            console.error('Error fetching reports:', error);
        } finally {
            setLoading(false);
        }
    }, [page, statusFilter, reasonFilter, debouncedSearch]);

    useEffect(() => {
        fetchReports();
    }, [fetchReports]);

    // Open Inspect Modal
    const handleInspect = async (item) => {
        setActiveReport(item);
        setAdminNotesInput(item.adminNotes || '');
        setInspectModalOpen(true);
        setInspectLoading(true);

        try {
            const res = await getReport(item.id);
            if (res.data?.success && res.data.data) {
                setActiveReport(res.data.data);
                setAdminNotesInput(res.data.data.adminNotes || '');
            }
        } catch (err) {
            console.error('Error fetching single report details:', err);
        } finally {
            setInspectLoading(false);
        }
    };

    // Update report status
    const handleStatusUpdate = async (id, newStatus) => {
        setSavingStatus(true);
        try {
            const res = await updateReportStatus(id, newStatus, adminNotesInput);
            if (res.data?.success) {
                const updated = res.data.data;
                setReports((prev) =>
                    prev.map((r) => (r.id === id ? { ...r, ...updated, status: newStatus, adminNotes: adminNotesInput } : r))
                );
                if (activeReport && activeReport.id === id) {
                    setActiveReport((prev) => ({ ...prev, ...updated, status: newStatus, adminNotes: adminNotesInput }));
                }

                // Update stats counter locally
                setStats((prev) => {
                    const oldStatus = activeReport?.status || 'pending';
                    if (oldStatus === newStatus) return prev;
                    return {
                        ...prev,
                        [oldStatus]: Math.max(0, (prev[oldStatus] || 1) - 1),
                        [newStatus]: (prev[newStatus] || 0) + 1
                    };
                });
            }
        } catch (error) {
            alert('Error updating report: ' + (error.response?.data?.message || error.message));
        } finally {
            setSavingStatus(false);
        }
    };

    // Reason Badge config
    const getReasonBadge = (reason) => {
        switch (reason) {
            case 'scientific_error':
                return { label: '🔬 Scientific / Medical Error', bg: '#0284c722', color: '#38bdf8', title: 'خطأ علمي أو طبي' };
            case 'wrong_answer':
                return { label: '❌ Incorrect Answer Key', bg: '#dc262622', color: '#f87171', title: 'الإجابة الصحيحة غير دقيقة' };
            case 'typo':
                return { label: '✍️ Typo / Formatting', bg: '#d9770622', color: '#fbbf24', title: 'خطأ لغوي أو إملائي' };
            case 'confusing':
                return { label: '❓ Confusing / Incomplete', bg: '#7c3aed22', color: '#c084fc', title: 'سؤال غامض أو غير مكتمل' };
            case 'other':
                return { label: '💬 Other Reason', bg: '#64748b22', color: '#94a3b8', title: 'سبب آخر' };
            default:
                return { label: `🚩 ${reason || 'Reported'}`, bg: '#334155', color: '#cbd5e1', title: reason };
        }
    };

    // Status Badge config
    const getStatusBadge = (status) => {
        switch (status) {
            case 'pending':
                return { label: '🟠 Pending Review', bg: '#f59e0b22', color: '#fbbf24' };
            case 'reviewing':
                return { label: '🔵 Under Review', bg: '#3b82f622', color: '#60a5fa' };
            case 'resolved':
                return { label: '🟢 Resolved & Fixed', bg: '#10b98122', color: '#34d399' };
            case 'dismissed':
                return { label: '⚪ Dismissed', bg: '#64748b22', color: '#94a3b8' };
            default:
                return { label: status, bg: '#334155', color: '#cbd5e1' };
        }
    };

    // Date formatter
    const formatDate = (dateString) => {
        if (!dateString) return '—';
        try {
            const d = new Date(dateString);
            return d.toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch {
            return dateString;
        }
    };

    return (
        <div style={{ paddingBottom: '60px' }}>
            {/* Page Header */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                <div>
                    <h2 className={styles.pageTitle} style={{ margin: 0 }}>🚩 User Reports & Issue Triage</h2>
                    <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '13px' }}>
                        Review student problem reports, investigate question errors, inspect answer keys, and update question bank accuracy.
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
                <div
                    onClick={() => { setStatusFilter('all'); setPage(1); }}
                    style={{
                        background: '#161b27',
                        border: statusFilter === 'all' ? '2px solid #3b82f6' : '1px solid #1e293b',
                        borderRadius: '12px',
                        padding: '16px',
                        cursor: 'pointer',
                        transition: 'transform 0.15s, border-color 0.15s'
                    }}
                >
                    <div style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 500 }}>Total Reports</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#f8fafc', marginTop: '6px' }}>{stats.total}</div>
                </div>

                <div
                    onClick={() => { setStatusFilter('pending'); setPage(1); }}
                    style={{
                        background: '#161b27',
                        border: statusFilter === 'pending' ? '2px solid #fbbf24' : '1px solid #f59e0b44',
                        borderRadius: '12px',
                        padding: '16px',
                        cursor: 'pointer',
                        transition: 'transform 0.15s, border-color 0.15s'
                    }}
                >
                    <div style={{ color: '#fbbf24', fontSize: '12px', fontWeight: 500 }}>🟠 Pending Triage</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#fbbf24', marginTop: '6px' }}>{stats.pending}</div>
                </div>

                <div
                    onClick={() => { setStatusFilter('reviewing'); setPage(1); }}
                    style={{
                        background: '#161b27',
                        border: statusFilter === 'reviewing' ? '2px solid #60a5fa' : '1px solid #3b82f644',
                        borderRadius: '12px',
                        padding: '16px',
                        cursor: 'pointer',
                        transition: 'transform 0.15s, border-color 0.15s'
                    }}
                >
                    <div style={{ color: '#60a5fa', fontSize: '12px', fontWeight: 500 }}>🔵 Under Review</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#60a5fa', marginTop: '6px' }}>{stats.reviewing}</div>
                </div>

                <div
                    onClick={() => { setStatusFilter('resolved'); setPage(1); }}
                    style={{
                        background: '#161b27',
                        border: statusFilter === 'resolved' ? '2px solid #34d399' : '1px solid #10b98144',
                        borderRadius: '12px',
                        padding: '16px',
                        cursor: 'pointer',
                        transition: 'transform 0.15s, border-color 0.15s'
                    }}
                >
                    <div style={{ color: '#34d399', fontSize: '12px', fontWeight: 500 }}>🟢 Resolved</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#34d399', marginTop: '6px' }}>{stats.resolved}</div>
                </div>

                <div
                    onClick={() => { setStatusFilter('dismissed'); setPage(1); }}
                    style={{
                        background: '#161b27',
                        border: statusFilter === 'dismissed' ? '2px solid #94a3b8' : '1px solid #64748b44',
                        borderRadius: '12px',
                        padding: '16px',
                        cursor: 'pointer',
                        transition: 'transform 0.15s, border-color 0.15s'
                    }}
                >
                    <div style={{ color: '#94a3b8', fontSize: '12px', fontWeight: 500 }}>⚪ Dismissed</div>
                    <div style={{ fontSize: '24px', fontWeight: 700, color: '#94a3b8', marginTop: '6px' }}>{stats.dismissed}</div>
                </div>
            </div>

            {/* Filter & Toolbar */}
            <div className={pageStyles.toolbar} style={{ background: '#161b27', padding: '16px', borderRadius: '12px', border: '1px solid #1e293b' }}>
                <input
                    type="text"
                    className={pageStyles.search}
                    placeholder="Search in question, user name, or feedback..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    style={{ minWidth: '280px' }}
                />

                {/* Status Filter */}
                <select
                    value={statusFilter}
                    onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
                    style={{ background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155', padding: '8px 12px', borderRadius: '8px', fontSize: '13px' }}
                >
                    <option value="all">All Statuses</option>
                    <option value="pending">🟠 Pending</option>
                    <option value="reviewing">🔵 Under Review</option>
                    <option value="resolved">🟢 Resolved</option>
                    <option value="dismissed">⚪ Dismissed</option>
                </select>

                {/* Reason Filter */}
                <select
                    value={reasonFilter}
                    onChange={(e) => { setReasonFilter(e.target.value); setPage(1); }}
                    style={{ background: '#1e293b', color: '#e2e8f0', border: '1px solid #334155', padding: '8px 12px', borderRadius: '8px', fontSize: '13px' }}
                >
                    <option value="all">All Issue Types</option>
                    <option value="scientific_error">🔬 Scientific / Medical Error</option>
                    <option value="wrong_answer">❌ Incorrect Answer Key</option>
                    <option value="typo">✍️ Typo / Formatting</option>
                    <option value="confusing">❓ Confusing / Incomplete</option>
                    <option value="other">💬 Other Reason</option>
                </select>

                <button
                    onClick={fetchReports}
                    style={{
                        background: '#1e293b',
                        color: '#94a3b8',
                        border: '1px solid #334155',
                        padding: '8px 14px',
                        borderRadius: '8px',
                        fontSize: '13px',
                        cursor: 'pointer',
                        marginLeft: 'auto'
                    }}
                >
                    🔄 Refresh
                </button>
            </div>

            {/* Reports Table */}
            <div className={styles.tableWrap} style={{ marginTop: '16px' }}>
                <table>
                    <thead>
                        <tr>
                            <th style={{ width: '100px' }}>#ID & Date</th>
                            <th style={{ minWidth: '280px' }}>Question Details</th>
                            <th style={{ width: '180px' }}>Reported By</th>
                            <th style={{ width: '190px' }}>Issue Type</th>
                            <th style={{ minWidth: '240px' }}>Student Feedback (Details)</th>
                            <th style={{ width: '130px' }}>Status</th>
                            <th style={{ width: '140px', textAlign: 'center' }}>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: '#94a3b8' }}>
                                    Loading reports...
                                </td>
                            </tr>
                        ) : reports.length === 0 ? (
                            <tr>
                                <td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
                                    No reports found matching criteria.
                                </td>
                            </tr>
                        ) : (
                            reports.map((r) => {
                                const reasonCfg = getReasonBadge(r.reason);
                                const statusCfg = getStatusBadge(r.status);
                                const studentComment = r.description || r.details;

                                return (
                                    <tr key={r.id || r._id} style={{ borderBottom: '1px solid #1e293b' }}>
                                        {/* ID & Date */}
                                        <td>
                                            <div style={{ fontWeight: 700, color: '#f8fafc', fontSize: '13px' }}>
                                                #{r.id}
                                            </div>
                                            <div style={{ fontSize: '11px', color: '#64748b', marginTop: '3px', whiteSpace: 'nowrap' }}>
                                                {formatDate(r.createdAt)}
                                            </div>
                                        </td>

                                        {/* Question Details */}
                                        <td>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                                                <span style={{
                                                    background: '#3b82f622',
                                                    color: '#60a5fa',
                                                    fontSize: '11px',
                                                    fontWeight: 600,
                                                    padding: '2px 6px',
                                                    borderRadius: '4px',
                                                    fontFamily: 'monospace'
                                                }}>
                                                    Q#{r.questionId}
                                                </span>
                                                {r.question?.specialty?.name && (
                                                    <span style={{
                                                        background: '#1e293b',
                                                        color: '#94a3b8',
                                                        fontSize: '11px',
                                                        padding: '2px 6px',
                                                        borderRadius: '4px'
                                                    }}>
                                                        {r.question.specialty.name}
                                                    </span>
                                                )}
                                                {r.question?.topic?.name && (
                                                    <span style={{
                                                        background: '#1e293b',
                                                        color: '#64748b',
                                                        fontSize: '11px',
                                                        padding: '2px 6px',
                                                        borderRadius: '4px'
                                                    }}>
                                                        {r.question.topic.name}
                                                    </span>
                                                )}
                                            </div>
                                            <div style={{
                                                fontSize: '13px',
                                                color: '#e2e8f0',
                                                lineHeight: 1.4,
                                                display: '-webkit-box',
                                                WebkitLineClamp: 2,
                                                WebkitBoxOrient: 'vertical',
                                                overflow: 'hidden'
                                            }}>
                                                {r.question?.text || `Question #${r.questionId}`}
                                            </div>
                                        </td>

                                        {/* Reported By */}
                                        <td>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                                <div style={{
                                                    width: '32px',
                                                    height: '32px',
                                                    borderRadius: '50%',
                                                    background: '#334155',
                                                    color: '#38bdf8',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    fontWeight: 700,
                                                    fontSize: '13px'
                                                }}>
                                                    {(r.user?.fullName || r.user?.name || 'S')?.[0]?.toUpperCase()}
                                                </div>
                                                <div style={{ overflow: 'hidden' }}>
                                                    <div style={{
                                                        fontSize: '13px',
                                                        fontWeight: 600,
                                                        color: '#f8fafc',
                                                        whiteSpace: 'nowrap',
                                                        overflow: 'hidden',
                                                        textOverflow: 'ellipsis'
                                                    }}>
                                                        {r.user?.fullName || r.user?.name || `Student #${r.userId}`}
                                                    </div>
                                                    <div style={{
                                                        fontSize: '11px',
                                                        color: '#64748b',
                                                        whiteSpace: 'nowrap',
                                                        overflow: 'hidden',
                                                        textOverflow: 'ellipsis'
                                                    }}>
                                                        {r.user?.email || `ID: ${r.userId}`}
                                                    </div>
                                                </div>
                                            </div>
                                        </td>

                                        {/* Issue Type */}
                                        <td>
                                            <span style={{
                                                display: 'inline-block',
                                                background: reasonCfg.bg,
                                                color: reasonCfg.color,
                                                padding: '4px 10px',
                                                borderRadius: '6px',
                                                fontSize: '12px',
                                                fontWeight: 600
                                            }}>
                                                {reasonCfg.label}
                                            </span>
                                        </td>

                                        {/* Student Feedback */}
                                        <td>
                                            {studentComment ? (
                                                <div style={{
                                                    background: '#161b27',
                                                    border: '1px solid #334155',
                                                    borderLeft: '3px solid #38bdf8',
                                                    padding: '8px 12px',
                                                    borderRadius: '6px',
                                                    fontSize: '12px',
                                                    color: '#f1f5f9',
                                                    lineHeight: 1.4,
                                                    fontStyle: 'normal'
                                                }}>
                                                    "{studentComment}"
                                                </div>
                                            ) : (
                                                <span style={{ color: '#64748b', fontSize: '12px', fontStyle: 'italic' }}>
                                                    No additional details provided
                                                </span>
                                            )}
                                        </td>

                                        {/* Status */}
                                        <td>
                                            <span style={{
                                                display: 'inline-block',
                                                background: statusCfg.bg,
                                                color: statusCfg.color,
                                                padding: '4px 10px',
                                                borderRadius: '6px',
                                                fontSize: '12px',
                                                fontWeight: 600
                                            }}>
                                                {statusCfg.label}
                                            </span>
                                            {r.adminNotes && (
                                                <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }} title={r.adminNotes}>
                                                    💬 Note attached
                                                </div>
                                            )}
                                        </td>

                                        {/* Actions */}
                                        <td style={{ textAlign: 'center' }}>
                                            <div style={{ display: 'flex', gap: '6px', justifyContent: 'center' }}>
                                                <button
                                                    onClick={() => handleInspect(r)}
                                                    style={{
                                                        background: '#3b82f6',
                                                        color: '#ffffff',
                                                        border: 'none',
                                                        padding: '6px 12px',
                                                        borderRadius: '6px',
                                                        fontSize: '12px',
                                                        fontWeight: 600,
                                                        cursor: 'pointer'
                                                    }}
                                                >
                                                    Inspect
                                                </button>

                                                {r.status !== 'resolved' && (
                                                    <button
                                                        onClick={() => handleStatusUpdate(r.id, 'resolved')}
                                                        title="Quick Resolve"
                                                        style={{
                                                            background: '#10b98122',
                                                            color: '#34d399',
                                                            border: '1px solid #10b98144',
                                                            padding: '6px 10px',
                                                            borderRadius: '6px',
                                                            fontSize: '12px',
                                                            fontWeight: 600,
                                                            cursor: 'pointer'
                                                        }}
                                                    >
                                                        ✓
                                                    </button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                );
                            })
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination Controls */}
            {totalPages > 1 && (
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '12px', marginTop: '20px' }}>
                    <button
                        disabled={page <= 1}
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                        style={{
                            background: '#161b27',
                            color: page <= 1 ? '#475569' : '#e2e8f0',
                            border: '1px solid #1e293b',
                            padding: '6px 14px',
                            borderRadius: '8px',
                            cursor: page <= 1 ? 'not-allowed' : 'pointer'
                        }}
                    >
                        Previous
                    </button>
                    <span style={{ color: '#94a3b8', fontSize: '13px' }}>
                        Page {page} of {totalPages}
                    </span>
                    <button
                        disabled={page >= totalPages}
                        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                        style={{
                            background: '#161b27',
                            color: page >= totalPages ? '#475569' : '#e2e8f0',
                            border: '1px solid #1e293b',
                            padding: '6px 14px',
                            borderRadius: '8px',
                            cursor: page >= totalPages ? 'not-allowed' : 'pointer'
                        }}
                    >
                        Next
                    </button>
                </div>
            )}

            {/* ═══════════ DETAILED REPORT & QUESTION INSPECT MODAL ═══════════ */}
            {inspectModalOpen && activeReport && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    background: 'rgba(0, 0, 0, 0.75)',
                    backdropFilter: 'blur(4px)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    zIndex: 1000,
                    padding: '20px'
                }}>
                    <div style={{
                        background: '#161b27',
                        border: '1px solid #1e293b',
                        borderRadius: '16px',
                        width: '100%',
                        maxWidth: '850px',
                        maxHeight: '90vh',
                        display: 'flex',
                        flexDirection: 'column',
                        overflow: 'hidden',
                        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)'
                    }}>
                        {/* Modal Header */}
                        <div style={{
                            padding: '20px 24px',
                            borderBottom: '1px solid #1e293b',
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            background: '#0d1117'
                        }}>
                            <div>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                    <h3 style={{ margin: 0, color: '#f8fafc', fontSize: '18px', fontWeight: 700 }}>
                                        Report Details #{activeReport.id}
                                    </h3>
                                    <span style={{
                                        background: getStatusBadge(activeReport.status).bg,
                                        color: getStatusBadge(activeReport.status).color,
                                        padding: '2px 8px',
                                        borderRadius: '6px',
                                        fontSize: '11px',
                                        fontWeight: 700
                                    }}>
                                        {getStatusBadge(activeReport.status).label}
                                    </span>
                                </div>
                                <div style={{ color: '#64748b', fontSize: '12px', marginTop: '4px' }}>
                                    Submitted on {formatDate(activeReport.createdAt)}
                                </div>
                            </div>
                            <button
                                onClick={() => setInspectModalOpen(false)}
                                style={{
                                    background: 'transparent',
                                    border: 'none',
                                    color: '#94a3b8',
                                    fontSize: '20px',
                                    cursor: 'pointer'
                                }}
                            >
                                ✕
                            </button>
                        </div>

                        {/* Modal Body */}
                        <div style={{ padding: '24px', overflowY: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: '20px' }}>
                            {inspectLoading ? (
                                <div style={{ textAlign: 'center', padding: '40px', color: '#94a3b8' }}>
                                    Loading full question context...
                                </div>
                            ) : (
                                <>
                                    {/* 1. Student Report Info Section */}
                                    <div style={{ background: '#0d1117', border: '1px solid #1e293b', borderRadius: '12px', padding: '16px' }}>
                                        <div style={{ color: '#38bdf8', fontSize: '13px', fontWeight: 700, marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                            <span>👤</span> Student Feedback & Report Reason
                                        </div>

                                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '14px' }}>
                                            <div>
                                                <div style={{ fontSize: '11px', color: '#64748b' }}>Reporter</div>
                                                <div style={{ color: '#f8fafc', fontWeight: 600, fontSize: '13px' }}>
                                                    {activeReport.user?.fullName || activeReport.user?.name || `Student #${activeReport.userId}`}
                                                </div>
                                                <div style={{ color: '#94a3b8', fontSize: '11px' }}>
                                                    {activeReport.user?.email || '—'}
                                                </div>
                                            </div>

                                            <div>
                                                <div style={{ fontSize: '11px', color: '#64748b' }}>Issue Type</div>
                                                <div style={{ marginTop: '2px' }}>
                                                    <span style={{
                                                        display: 'inline-block',
                                                        background: getReasonBadge(activeReport.reason).bg,
                                                        color: getReasonBadge(activeReport.reason).color,
                                                        padding: '3px 8px',
                                                        borderRadius: '6px',
                                                        fontSize: '12px',
                                                        fontWeight: 600
                                                    }}>
                                                        {getReasonBadge(activeReport.reason).label}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>

                                        {/* Student feedback box */}
                                        <div style={{ fontSize: '11px', color: '#64748b', marginBottom: '4px' }}>
                                            Student's Written Feedback / Comments:
                                        </div>
                                        <div style={{
                                            background: '#161b27',
                                            border: '1px solid #334155',
                                            borderLeft: '4px solid #38bdf8',
                                            padding: '12px 16px',
                                            borderRadius: '8px',
                                            color: '#f8fafc',
                                            fontSize: '14px',
                                            lineHeight: 1.5
                                        }}>
                                            {activeReport.description || activeReport.details || (
                                                <span style={{ color: '#64748b', fontStyle: 'italic' }}>No additional comments provided by student.</span>
                                            )}
                                        </div>
                                    </div>

                                    {/* 2. Full Question Preview Section */}
                                    <div style={{ background: '#0d1117', border: '1px solid #1e293b', borderRadius: '12px', padding: '16px' }}>
                                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                                            <div style={{ color: '#a78bfa', fontSize: '13px', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '8px' }}>
                                                <span>📚</span> Reported Question Context (Q#{activeReport.questionId})
                                            </div>
                                            <button
                                                onClick={() => {
                                                    navigate(`/questions?search=${activeReport.questionId}`);
                                                }}
                                                style={{
                                                    background: '#3b82f622',
                                                    color: '#60a5fa',
                                                    border: '1px solid #3b82f644',
                                                    borderRadius: '6px',
                                                    padding: '4px 10px',
                                                    fontSize: '11px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                ✏️ Open in Questions Bank
                                            </button>
                                        </div>

                                        {/* Question Metadata Tags */}
                                        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '10px' }}>
                                            {activeReport.question?.specialty?.name && (
                                                <span style={{ background: '#1e293b', color: '#38bdf8', fontSize: '11px', padding: '2px 8px', borderRadius: '4px' }}>
                                                    Specialty: {activeReport.question.specialty.name}
                                                </span>
                                            )}
                                            {activeReport.question?.topic?.name && (
                                                <span style={{ background: '#1e293b', color: '#c084fc', fontSize: '11px', padding: '2px 8px', borderRadius: '4px' }}>
                                                    Topic: {activeReport.question.topic.name}
                                                </span>
                                            )}
                                            {activeReport.question?.difficulty && (
                                                <span style={{ background: '#1e293b', color: '#94a3b8', fontSize: '11px', padding: '2px 8px', borderRadius: '4px' }}>
                                                    Difficulty: {activeReport.question.difficulty}
                                                </span>
                                            )}
                                        </div>

                                        {/* Question Text */}
                                        <div style={{
                                            fontSize: '14px',
                                            fontWeight: 600,
                                            color: '#f8fafc',
                                            lineHeight: 1.6,
                                            marginBottom: '16px',
                                            padding: '12px',
                                            background: '#161b27',
                                            borderRadius: '8px',
                                            border: '1px solid #1e293b'
                                        }}>
                                            {activeReport.question?.text || `Question #${activeReport.questionId}`}
                                        </div>

                                        {/* Options with Correct Answer Highlighted */}
                                        {activeReport.question?.options && activeReport.question.options.length > 0 && (
                                            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '16px' }}>
                                                <div style={{ fontSize: '12px', color: '#94a3b8', fontWeight: 600 }}>
                                                    Choices / Answer Options:
                                                </div>
                                                {activeReport.question.options.map((opt) => (
                                                    <div
                                                        key={opt.id || opt.order}
                                                        style={{
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            gap: '12px',
                                                            padding: '10px 14px',
                                                            borderRadius: '8px',
                                                            background: opt.isCorrect ? '#10b98118' : '#161b27',
                                                            border: opt.isCorrect ? '1px solid #10b98166' : '1px solid #1e293b'
                                                        }}
                                                    >
                                                        <span style={{
                                                            width: '24px',
                                                            height: '24px',
                                                            borderRadius: '50%',
                                                            background: opt.isCorrect ? '#10b981' : '#334155',
                                                            color: opt.isCorrect ? '#ffffff' : '#cbd5e1',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            justifyContent: 'center',
                                                            fontSize: '12px',
                                                            fontWeight: 700
                                                        }}>
                                                            {opt.order || '•'}
                                                        </span>
                                                        <span style={{
                                                            color: opt.isCorrect ? '#34d399' : '#e2e8f0',
                                                            fontSize: '13px',
                                                            fontWeight: opt.isCorrect ? 600 : 400,
                                                            flex: 1
                                                        }}>
                                                            {opt.text}
                                                        </span>
                                                        {opt.isCorrect && (
                                                            <span style={{
                                                                background: '#10b98133',
                                                                color: '#34d399',
                                                                fontSize: '11px',
                                                                fontWeight: 700,
                                                                padding: '2px 8px',
                                                                borderRadius: '4px'
                                                            }}>
                                                                ✓ Marked Correct Answer
                                                            </span>
                                                        )}
                                                    </div>
                                                ))}
                                            </div>
                                        )}

                                        {/* Explanation Preview */}
                                        {activeReport.question?.explanation?.text && (
                                            <div style={{
                                                background: '#161b27',
                                                border: '1px solid #1e293b',
                                                borderRadius: '8px',
                                                padding: '12px 14px'
                                            }}>
                                                <div style={{ color: '#38bdf8', fontSize: '12px', fontWeight: 600, marginBottom: '4px' }}>
                                                    💡 Current Explanation:
                                                </div>
                                                <div style={{ color: '#cbd5e1', fontSize: '13px', lineHeight: 1.5 }}>
                                                    {activeReport.question.explanation.text}
                                                </div>
                                                {activeReport.question.explanation.references && (
                                                    <div style={{ color: '#64748b', fontSize: '11px', marginTop: '6px' }}>
                                                        Ref: {activeReport.question.explanation.references}
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>

                                    {/* 3. Admin Action & Notes Panel */}
                                    <div style={{ background: '#0d1117', border: '1px solid #1e293b', borderRadius: '12px', padding: '16px' }}>
                                        <div style={{ color: '#fbbf24', fontSize: '13px', fontWeight: 700, marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                            <span>⚡</span> Update Report Status & Admin Notes
                                        </div>

                                        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginBottom: '14px' }}>
                                            <button
                                                disabled={savingStatus}
                                                onClick={() => handleStatusUpdate(activeReport.id, 'pending')}
                                                style={{
                                                    background: activeReport.status === 'pending' ? '#f59e0b' : '#161b27',
                                                    color: activeReport.status === 'pending' ? '#000' : '#fbbf24',
                                                    border: '1px solid #f59e0b66',
                                                    borderRadius: '8px',
                                                    padding: '8px 14px',
                                                    fontSize: '12px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                🟠 Mark as Pending
                                            </button>

                                            <button
                                                disabled={savingStatus}
                                                onClick={() => handleStatusUpdate(activeReport.id, 'reviewing')}
                                                style={{
                                                    background: activeReport.status === 'reviewing' ? '#3b82f6' : '#161b27',
                                                    color: activeReport.status === 'reviewing' ? '#fff' : '#60a5fa',
                                                    border: '1px solid #3b82f666',
                                                    borderRadius: '8px',
                                                    padding: '8px 14px',
                                                    fontSize: '12px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                🔵 Mark Under Review
                                            </button>

                                            <button
                                                disabled={savingStatus}
                                                onClick={() => handleStatusUpdate(activeReport.id, 'resolved')}
                                                style={{
                                                    background: activeReport.status === 'resolved' ? '#10b981' : '#161b27',
                                                    color: activeReport.status === 'resolved' ? '#fff' : '#34d399',
                                                    border: '1px solid #10b98166',
                                                    borderRadius: '8px',
                                                    padding: '8px 14px',
                                                    fontSize: '12px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                🟢 Mark Resolved (Fixed)
                                            </button>

                                            <button
                                                disabled={savingStatus}
                                                onClick={() => handleStatusUpdate(activeReport.id, 'dismissed')}
                                                style={{
                                                    background: activeReport.status === 'dismissed' ? '#64748b' : '#161b27',
                                                    color: activeReport.status === 'dismissed' ? '#fff' : '#94a3b8',
                                                    border: '1px solid #64748b66',
                                                    borderRadius: '8px',
                                                    padding: '8px 14px',
                                                    fontSize: '12px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                ⚪ Dismiss Report
                                            </button>
                                        </div>

                                        {/* Admin Internal Notes Textarea */}
                                        <div style={{ fontSize: '11px', color: '#64748b', marginBottom: '6px' }}>
                                            Internal Admin Notes & Resolution Comment:
                                        </div>
                                        <textarea
                                            value={adminNotesInput}
                                            onChange={(e) => setAdminNotesInput(e.target.value)}
                                            placeholder="Write internal notes about what action was taken (e.g., 'Corrected answer from B to A', 'Typo fixed in stem')..."
                                            rows={3}
                                            style={{
                                                width: '100%',
                                                background: '#161b27',
                                                border: '1px solid #334155',
                                                borderRadius: '8px',
                                                color: '#f8fafc',
                                                padding: '10px 12px',
                                                fontSize: '13px',
                                                resize: 'vertical',
                                                boxSizing: 'border-box',
                                                outline: 'none'
                                            }}
                                        />

                                        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '10px' }}>
                                            <button
                                                disabled={savingStatus}
                                                onClick={() => handleStatusUpdate(activeReport.id, activeReport.status)}
                                                style={{
                                                    background: '#3b82f6',
                                                    color: '#fff',
                                                    border: 'none',
                                                    padding: '8px 16px',
                                                    borderRadius: '8px',
                                                    fontSize: '12px',
                                                    fontWeight: 600,
                                                    cursor: 'pointer'
                                                }}
                                            >
                                                {savingStatus ? 'Saving...' : '💾 Save Admin Notes'}
                                            </button>
                                        </div>
                                    </div>
                                </>
                            )}
                        </div>

                        {/* Modal Footer */}
                        <div style={{
                            padding: '16px 24px',
                            borderTop: '1px solid #1e293b',
                            display: 'flex',
                            justifyContent: 'flex-end',
                            background: '#0d1117'
                        }}>
                            <button
                                onClick={() => setInspectModalOpen(false)}
                                style={{
                                    background: '#1e293b',
                                    color: '#e2e8f0',
                                    border: '1px solid #334155',
                                    padding: '8px 18px',
                                    borderRadius: '8px',
                                    fontSize: '13px',
                                    cursor: 'pointer'
                                }}
                            >
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
