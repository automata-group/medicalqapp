import { useEffect, useState, useMemo, useCallback } from 'react';
import { getUsers, manageSubscription, deleteUser, bulkDeleteUsers } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Users() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [roleFilter, setRoleFilter] = useState('all');
    const [subFilter, setSubFilter] = useState('all');
    const [selectedIds, setSelectedIds] = useState([]);
    const [page, setPage] = useState(1);
    const pageSize = 15;

    // Delete Modal States
    const [userToDelete, setUserToDelete] = useState(null);
    const [showBulkDeleteModal, setShowBulkDeleteModal] = useState(false);
    const [deleteLoading, setDeleteLoading] = useState(false);
    const [actionMessage, setActionMessage] = useState(null);

    const showMessage = useCallback((msg, type = 'success') => {
        setActionMessage({ text: msg, type });
        setTimeout(() => setActionMessage(null), 4000);
    }, []);

    const loadUsers = useCallback(async () => {
        setLoading(true);
        try {
            const res = await getUsers({ limit: 1000 });
            const list = res.data?.data || res.data || [];
            setUsers(Array.isArray(list) ? list : []);
        } catch (err) {
            console.error('Failed to load users', err);
            showMessage('فشل تحميل قائمة المستخدمين', 'error');
        } finally {
            setLoading(false);
        }
    }, [showMessage]);

    useEffect(() => {
        loadUsers();
    }, [loadUsers]);

    async function togglePro(user) {
        const userId = user.id || user._id;
        const newStatus = !user.isPremium;
        try {
            await manageSubscription(userId, { isPremium: newStatus });
            setUsers((prev) =>
                prev.map((u) =>
                    (u.id || u._id) === userId
                        ? { ...u, isPremium: newStatus }
                        : u
                )
            );
            showMessage(newStatus ? 'تم تفعيل باقة PRO للمستخدم بنجاح' : 'تم إلغاء باقة PRO للمستخدم');
        } catch (err) {
            console.error('Failed to update subscription', err);
            showMessage('فشل تحديث اشتراك المستخدم', 'error');
        }
    }

    const handleDeleteClick = (user) => {
        setUserToDelete(user);
    };

    const confirmDeleteUser = async () => {
        if (!userToDelete) return;
        const userId = userToDelete.id || userToDelete._id;
        setDeleteLoading(true);
        try {
            await deleteUser(userId);
            setUsers((prev) => prev.filter((u) => (u.id || u._id) !== userId));
            setSelectedIds((prev) => prev.filter((id) => id !== userId));
            showMessage('تم حذف المستخدم وجميع بياناته بنجاح');
            setUserToDelete(null);
        } catch (err) {
            console.error('Failed to delete user', err);
            showMessage(err.response?.data?.message || 'فشل حذف المستخدم', 'error');
        } finally {
            setDeleteLoading(false);
        }
    };

    const confirmBulkDelete = async () => {
        if (selectedIds.length === 0) return;
        setDeleteLoading(true);
        try {
            await bulkDeleteUsers(selectedIds);
            setUsers((prev) => prev.filter((u) => !selectedIds.includes(u.id || u._id)));
            showMessage(`تم حذف ${selectedIds.length} مستخدم بنجاح`);
            setSelectedIds([]);
            setShowBulkDeleteModal(false);
        } catch (err) {
            console.error('Failed to bulk delete users', err);
            showMessage(err.response?.data?.message || 'فشل حذف المستخدمين المحددين', 'error');
        } finally {
            setDeleteLoading(false);
        }
    };

    // Filter users
    const filteredUsers = useMemo(() => {
        return users.filter((u) => {
            const name = (u.fullName || u.name || '').toLowerCase();
            const email = (u.email || '').toLowerCase();
            const q = search.toLowerCase().trim();
            const matchesSearch = !q || name.includes(q) || email.includes(q);

            const matchesRole =
                roleFilter === 'all' ||
                (roleFilter === 'admin' && u.role === 'admin') ||
                (roleFilter === 'user' && u.role !== 'admin');

            const matchesSub =
                subFilter === 'all' ||
                (subFilter === 'pro' && u.isPremium) ||
                (subFilter === 'free' && !u.isPremium);

            return matchesSearch && matchesRole && matchesSub;
        });
    }, [users, search, roleFilter, subFilter]);

    // Reset pagination on filter changes
    useEffect(() => {
        setPage(1);
    }, [search, roleFilter, subFilter]);

    const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize));
    const paginatedUsers = useMemo(() => {
        const start = (page - 1) * pageSize;
        return filteredUsers.slice(start, start + pageSize);
    }, [filteredUsers, page, pageSize]);

    // Checkbox selection handlers
    const allPaginatedSelected =
        paginatedUsers.length > 0 &&
        paginatedUsers.every((u) => selectedIds.includes(u.id || u._id));

    const toggleSelectAll = () => {
        const pageUserIds = paginatedUsers.map((u) => u.id || u._id);
        if (allPaginatedSelected) {
            setSelectedIds((prev) => prev.filter((id) => !pageUserIds.includes(id)));
        } else {
            setSelectedIds((prev) => Array.from(new Set([...prev, ...pageUserIds])));
        }
    };

    const toggleSelect = (id) => {
        setSelectedIds((prev) =>
            prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]
        );
    };

    // Metrics counts
    const totalCount = users.length;
    const proCount = users.filter((u) => u.isPremium).length;
    const adminCount = users.filter((u) => u.role === 'admin').length;

    return (
        <div>
            {/* Notification Toast */}
            {actionMessage && (
                <div
                    style={{
                        position: 'fixed',
                        top: '20px',
                        right: '20px',
                        zIndex: 9999,
                        padding: '12px 20px',
                        borderRadius: '10px',
                        background: actionMessage.type === 'error' ? '#ef4444' : '#10b981',
                        color: '#ffffff',
                        fontWeight: 600,
                        boxShadow: '0 10px 25px rgba(0,0,0,0.4)',
                        animation: 'fadeIn 0.2s ease',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                    }}
                >
                    <span>{actionMessage.type === 'error' ? '⚠️' : '✅'}</span>
                    <span>{actionMessage.text}</span>
                </div>
            )}

            {/* Header with Title and Metrics */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px', marginBottom: '24px' }}>
                <div>
                    <h2 className={styles.pageTitle} style={{ margin: 0 }}>👥 إدارة المستخدمين (User Management)</h2>
                    <p style={{ color: '#64748b', margin: '6px 0 0 0', fontSize: '14px' }}>
                        إدارة حسابات الأعضاء والمسؤولين والاشتراكات وحذف الحسابات غير المرغوبة
                    </p>
                </div>

                {/* Quick Stats Badges */}
                <div style={{ display: 'flex', gap: '12px' }}>
                    <div style={{
                        padding: '8px 16px',
                        background: '#1e293b',
                        borderRadius: '10px',
                        border: '1px solid #334155',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px'
                    }}>
                        <span style={{ fontSize: '13px', color: '#94a3b8' }}>إجمالي المستخدمين:</span>
                        <strong style={{ color: '#f8fafc', fontSize: '15px' }}>{totalCount}</strong>
                    </div>

                    <div style={{
                        padding: '8px 16px',
                        background: '#05966918',
                        borderRadius: '10px',
                        border: '1px solid #05966944',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px'
                    }}>
                        <span style={{ fontSize: '13px', color: '#34d399' }}>مشتركي PRO:</span>
                        <strong style={{ color: '#10b981', fontSize: '15px' }}>{proCount}</strong>
                    </div>

                    <div style={{
                        padding: '8px 16px',
                        background: '#7c3aed18',
                        borderRadius: '10px',
                        border: '1px solid #7c3aed44',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px'
                    }}>
                        <span style={{ fontSize: '13px', color: '#c084fc' }}>مسؤولين:</span>
                        <strong style={{ color: '#a78bfa', fontSize: '15px' }}>{adminCount}</strong>
                    </div>
                </div>
            </div>

            {/* Toolbar: Search, Filters & Bulk Actions */}
            <div className={pageStyles.toolbar} style={{ flexWrap: 'wrap', gap: '12px', marginBottom: '16px' }}>
                <input
                    className={pageStyles.search}
                    placeholder="🔍 ابحث بالاسم أو البريد الإلكتروني..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    style={{ minWidth: '260px', flex: 1 }}
                />

                {/* Role Filter */}
                <select
                    value={roleFilter}
                    onChange={(e) => setRoleFilter(e.target.value)}
                    style={{
                        padding: '8px 14px',
                        background: '#161b27',
                        border: '1px solid #1e293b',
                        borderRadius: '10px',
                        color: '#cbd5e1',
                        outline: 'none',
                        cursor: 'pointer'
                    }}
                >
                    <option value="all">جميع الأدوار (All Roles)</option>
                    <option value="admin">مسؤولين (Admins)</option>
                    <option value="user">مستخدمين عاديين (Users)</option>
                </select>

                {/* Subscription Filter */}
                <select
                    value={subFilter}
                    onChange={(e) => setSubFilter(e.target.value)}
                    style={{
                        padding: '8px 14px',
                        background: '#161b27',
                        border: '1px solid #1e293b',
                        borderRadius: '10px',
                        color: '#cbd5e1',
                        outline: 'none',
                        cursor: 'pointer'
                    }}
                >
                    <option value="all">جميع الاشتراكات (All)</option>
                    <option value="pro">⭐ PRO مشتركين</option>
                    <option value="free">مجاني Free</option>
                </select>

                {/* Clear filters button if active */}
                {(search || roleFilter !== 'all' || subFilter !== 'all') && (
                    <button
                        className={pageStyles.btnSecondary}
                        onClick={() => {
                            setSearch('');
                            setRoleFilter('all');
                            setSubFilter('all');
                        }}
                        style={{ padding: '8px 14px', fontSize: '13px' }}
                    >
                        ✕ مسح الفلاتر
                    </button>
                )}

                {/* Bulk Delete Button if selected */}
                {selectedIds.length > 0 && (
                    <button
                        className={`${pageStyles.btn} ${pageStyles.btnDanger}`}
                        onClick={() => setShowBulkDeleteModal(true)}
                        style={{
                            background: '#dc2626',
                            color: '#ffffff',
                            fontWeight: 600,
                            boxShadow: '0 4px 12px rgba(220, 38, 38, 0.3)',
                            padding: '8px 16px',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '6px'
                        }}
                    >
                        <span>🗑️</span>
                        <span>حذف المحدد ({selectedIds.length})</span>
                    </button>
                )}

                <span className={pageStyles.count} style={{ marginLeft: 'auto' }}>
                    {filteredUsers.length} مستخدم
                </span>
            </div>

            {/* Users Table */}
            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th style={{ width: '40px', textAlign: 'center' }}>
                                <input
                                    type="checkbox"
                                    checked={allPaginatedSelected}
                                    onChange={toggleSelectAll}
                                    style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                                    title="تحديد كل المعروضين"
                                />
                            </th>
                            <th>المستخدم (User)</th>
                            <th>الدور (Role)</th>
                            <th>الاشتراك (Plan)</th>
                            <th>تاريخ الانضمام (Joined)</th>
                            <th style={{ textAlign: 'center' }}>الإجراءات (Actions)</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr>
                                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
                                    <div style={{ display: 'inline-block', animation: 'spin 1s linear infinite' }}>⏳</div> جاري تحميل المستخدمين...
                                </td>
                            </tr>
                        ) : paginatedUsers.length === 0 ? (
                            <tr>
                                <td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
                                    لا يوجد مستخدمين مطابقين لخيارات البحث
                                </td>
                            </tr>
                        ) : (
                            paginatedUsers.map((u) => {
                                const userId = u.id || u._id;
                                const isSelected = selectedIds.includes(userId);
                                const displayName = u.fullName || u.name || 'بدون اسم';
                                const initial = displayName.trim()[0]?.toUpperCase() || '?';

                                return (
                                    <tr 
                                        key={userId}
                                        style={{ 
                                            background: isSelected ? 'rgba(59, 130, 246, 0.05)' : 'transparent',
                                            transition: 'background 0.15s'
                                        }}
                                    >
                                        <td style={{ textAlign: 'center' }}>
                                            <input
                                                type="checkbox"
                                                checked={isSelected}
                                                onChange={() => toggleSelect(userId)}
                                                style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                                            />
                                        </td>
                                        <td>
                                            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                                <div style={{
                                                    width: '36px',
                                                    height: '36px',
                                                    borderRadius: '50%',
                                                    background: u.role === 'admin' 
                                                        ? 'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)' 
                                                        : 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    fontWeight: '700',
                                                    color: '#ffffff',
                                                    fontSize: '14px',
                                                    flexShrink: 0
                                                }}>
                                                    {initial}
                                                </div>
                                                <div>
                                                    <div style={{ fontWeight: '600', color: '#f8fafc', fontSize: '14px' }}>
                                                        {displayName}
                                                    </div>
                                                    <div style={{ color: '#94a3b8', fontSize: '12px', marginTop: '2px' }}>
                                                        {u.email}
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span
                                                className={pageStyles.badge}
                                                style={{
                                                    background: u.role === 'admin' ? '#7c3aed22' : '#1e293b',
                                                    color: u.role === 'admin' ? '#c084fc' : '#94a3b8',
                                                    border: u.role === 'admin' ? '1px solid #7c3aed44' : '1px solid #334155'
                                                }}
                                            >
                                                {u.role === 'admin' ? '👑 Admin' : '👤 User'}
                                            </span>
                                        </td>
                                        <td>
                                            <span
                                                className={pageStyles.badge}
                                                style={{
                                                    background: u.isPremium ? '#05966922' : '#1e293b',
                                                    color: u.isPremium ? '#34d399' : '#64748b',
                                                    border: u.isPremium ? '1px solid #05966944' : '1px solid #334155'
                                                }}
                                            >
                                                {u.isPremium ? '⭐ PRO' : 'Free'}
                                            </span>
                                        </td>
                                        <td style={{ color: '#64748b', fontSize: '13px' }}>
                                            {u.createdAt ? new Date(u.createdAt).toLocaleDateString() : '—'}
                                        </td>
                                        <td>
                                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
                                                {/* Toggle PRO Status */}
                                                <button
                                                    className={`${pageStyles.btn} ${u.isPremium ? pageStyles.btnSecondary : pageStyles.btnPrimary}`}
                                                    onClick={() => togglePro(u)}
                                                    style={{ fontSize: '12px', padding: '6px 12px' }}
                                                    title={u.isPremium ? 'إلغاء اشتراك PRO' : 'ترقية إلى PRO'}
                                                >
                                                    {u.isPremium ? 'Revoke PRO' : 'Grant PRO'}
                                                </button>

                                                {/* Delete User Button */}
                                                <button
                                                    className={`${pageStyles.btn} ${pageStyles.btnDanger}`}
                                                    onClick={() => handleDeleteClick(u)}
                                                    style={{
                                                        fontSize: '12px',
                                                        padding: '6px 12px',
                                                        display: 'flex',
                                                        alignItems: 'center',
                                                        gap: '4px'
                                                    }}
                                                    title="حذف المستخدم نهائياً"
                                                >
                                                    <span>🗑️</span>
                                                    <span>Delete</span>
                                                </button>
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
                <div
                    style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                        marginTop: '20px',
                        padding: '12px 16px',
                        background: '#0f172a',
                        borderRadius: '12px',
                        border: '1px solid #1e293b',
                    }}
                >
                    <button
                        className={pageStyles.btn}
                        disabled={page === 1}
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                        style={{
                            opacity: page === 1 ? 0.4 : 1,
                            cursor: page === 1 ? 'not-allowed' : 'pointer',
                            background: '#1e293b',
                            color: '#cbd5e1',
                        }}
                    >
                        ← السابق (Previous)
                    </button>
                    <span style={{ color: '#94a3b8', fontSize: '14px' }}>
                        صفحة <strong style={{ color: '#f8fafc' }}>{page}</strong> من{' '}
                        <strong style={{ color: '#f8fafc' }}>{totalPages}</strong> (إجمالي {filteredUsers.length} مستخدم)
                    </span>
                    <button
                        className={pageStyles.btn}
                        disabled={page === totalPages}
                        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                        style={{
                            opacity: page === totalPages ? 0.4 : 1,
                            cursor: page === totalPages ? 'not-allowed' : 'pointer',
                            background: '#1e293b',
                            color: '#cbd5e1',
                        }}
                    >
                        التالي (Next) →
                    </button>
                </div>
            )}

            {/* Single User Delete Confirmation Modal */}
            {userToDelete && (
                <div className={pageStyles.modalOverlay} onClick={() => !deleteLoading && setUserToDelete(null)}>
                    <div
                        className={pageStyles.modal}
                        onClick={(e) => e.stopPropagation()}
                        style={{ maxWidth: '460px', border: '1px solid #ef444455' }}
                    >
                        <div className={pageStyles.modalHeader} style={{ borderBottom: '1px solid #ef444422' }}>
                            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#fca5a5' }}>
                                <span>⚠️</span>
                                <span>تأكيد حذف المستخدم</span>
                            </h3>
                            <button
                                className={pageStyles.closeBtn}
                                onClick={() => !deleteLoading && setUserToDelete(null)}
                            >
                                ×
                            </button>
                        </div>
                        <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            <div
                                style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '12px',
                                    padding: '12px 16px',
                                    background: '#1e293b88',
                                    borderRadius: '10px',
                                    border: '1px solid #334155',
                                }}
                            >
                                <div
                                    style={{
                                        width: '42px',
                                        height: '42px',
                                        borderRadius: '50%',
                                        background: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        fontWeight: 'bold',
                                        color: '#fff',
                                        fontSize: '16px',
                                    }}
                                >
                                    {(userToDelete.fullName || userToDelete.email || '?')[0].toUpperCase()}
                                </div>
                                <div>
                                    <div style={{ fontWeight: '600', color: '#f8fafc', fontSize: '15px' }}>
                                        {userToDelete.fullName || userToDelete.name || 'بدون اسم'}
                                    </div>
                                    <div style={{ color: '#94a3b8', fontSize: '13px' }}>
                                        {userToDelete.email}
                                    </div>
                                </div>
                            </div>

                            <div
                                style={{
                                    padding: '14px',
                                    background: '#ef444415',
                                    borderRadius: '8px',
                                    border: '1px solid #ef444433',
                                    color: '#fca5a5',
                                    fontSize: '13px',
                                    lineHeight: '1.6',
                                }}
                            >
                                ⚠️ <strong>تحذير أمان:</strong> سيتم حذف حساب هذا المستخدم نهائياً بما يشمل كافة المحاولات والنتائج، الاشتراكات، الإحصائيات، والإشارات المرجعية. لا يمكن استعادة هذه البيانات بعد الحذف.
                            </div>
                        </div>
                        <div className={pageStyles.modalFooter}>
                            <button
                                className={pageStyles.btnSecondary}
                                onClick={() => setUserToDelete(null)}
                                disabled={deleteLoading}
                            >
                                إلغاء
                            </button>
                            <button
                                className={`${pageStyles.btn} ${pageStyles.btnDanger}`}
                                onClick={confirmDeleteUser}
                                disabled={deleteLoading}
                                style={{
                                    background: '#dc2626',
                                    color: '#ffffff',
                                    padding: '8px 20px',
                                    fontWeight: 600,
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '6px',
                                }}
                            >
                                {deleteLoading ? 'جاري الحذف...' : '🗑️ نعم، احذف المستخدم'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Bulk Delete Modal */}
            {showBulkDeleteModal && (
                <div className={pageStyles.modalOverlay} onClick={() => !deleteLoading && setShowBulkDeleteModal(false)}>
                    <div
                        className={pageStyles.modal}
                        onClick={(e) => e.stopPropagation()}
                        style={{ maxWidth: '460px', border: '1px solid #ef444455' }}
                    >
                        <div className={pageStyles.modalHeader} style={{ borderBottom: '1px solid #ef444422' }}>
                            <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#fca5a5' }}>
                                <span>⚠️</span>
                                <span>حذف جماعي للمستخدمين</span>
                            </h3>
                            <button
                                className={pageStyles.closeBtn}
                                onClick={() => !deleteLoading && setShowBulkDeleteModal(false)}
                            >
                                ×
                            </button>
                        </div>
                        <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
                            <div
                                style={{
                                    padding: '14px',
                                    background: '#ef444415',
                                    borderRadius: '8px',
                                    border: '1px solid #ef444433',
                                    color: '#fca5a5',
                                    fontSize: '13px',
                                    lineHeight: '1.6',
                                }}
                            >
                                هل أنت متأكد من حذف <strong>{selectedIds.length}</strong> مستخدم تم تحديدهم؟ سيتم إزالة جميع حساباتهم وبياناتهم وسجلاتهم نهائياً من قاعدة البيانات.
                            </div>
                        </div>
                        <div className={pageStyles.modalFooter}>
                            <button
                                className={pageStyles.btnSecondary}
                                onClick={() => setShowBulkDeleteModal(false)}
                                disabled={deleteLoading}
                            >
                                إلغاء
                            </button>
                            <button
                                className={`${pageStyles.btn} ${pageStyles.btnDanger}`}
                                onClick={confirmBulkDelete}
                                disabled={deleteLoading}
                                style={{
                                    background: '#dc2626',
                                    color: '#ffffff',
                                    padding: '8px 20px',
                                    fontWeight: 600,
                                }}
                            >
                                {deleteLoading ? 'جاري الحذف...' : `🗑️ تأكيد حذف (${selectedIds.length})`}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
