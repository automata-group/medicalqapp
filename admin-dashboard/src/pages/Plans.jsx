import { useEffect, useState } from 'react';
import { getPlans, updatePlan, createPlan, deletePlan } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Plans() {
    const [plans, setPlans] = useState([]);
    const [loading, setLoading] = useState(true);
    const [editing, setEditing] = useState(null);
    const [creating, setCreating] = useState(false);
    const [newPlan, setNewPlan] = useState({
        name: '',
        slug: '',
        price: 0,
        durationInDays: 30,
        discountPercentage: 0,
        isPopular: false,
        isActive: true
    });

    const fetchPlans = () => {
        setLoading(true);
        getPlans()
            .then((r) => {
                const list = r.data?.data || r.data || [];
                // Sort by price ascending
                list.sort((a, b) => Number(a.price) - Number(b.price));
                setPlans(list);
            })
            .catch((err) => console.error('Error fetching plans:', err))
            .finally(() => setLoading(false));
    };

    useEffect(() => {
        fetchPlans();
    }, []);

    async function saveEdit() {
        try {
            await updatePlan(editing._id || editing.id, editing);
            setPlans((p) => p.map((pl) => ((pl._id || pl.id) === (editing._id || editing.id) ? editing : pl)));
            setEditing(null);
        } catch (err) {
            alert('Failed to save changes: ' + (err.response?.data?.message || err.message));
        }
    }

    async function handleCreate() {
        if (!newPlan.name || !newPlan.price || !newPlan.durationInDays) {
            return alert('Name, Price and Duration are required');
        }
        try {
            const slugStr = newPlan.slug || newPlan.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
            const res = await createPlan({ ...newPlan, slug: slugStr });
            setPlans([...plans, res.data?.data || res.data]);
            setCreating(false);
            setNewPlan({
                name: '',
                slug: '',
                price: 0,
                durationInDays: 30,
                discountPercentage: 0,
                isPopular: false,
                isActive: true
            });
        } catch (err) {
            alert('Failed to create plan: ' + (err.response?.data?.message || err.message));
        }
    }

    async function handleDelete(id) {
        if (!window.confirm('هل أنت متأكد من رغبتك في حذف هذه الخطة؟')) return;
        try {
            await deletePlan(id);
            setPlans((p) => p.filter((pl) => (pl._id || pl.id) !== id));
        } catch (err) {
            alert('Failed to delete plan: ' + (err.response?.data?.message || err.message));
        }
    }

    // Duration label helper
    const getDurationLabel = (days) => {
        if (days === 30) return 'شهر واحد (1 Month)';
        if (days === 90) return '3 أشهر (3 Months)';
        if (days === 180) return '6 أشهر (6 Months)';
        if (days === 365) return 'سنة كاملة (12 شهر)';
        return `${days} يوم`;
    };

    return (
        <div style={{ paddingBottom: 40 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
                <div>
                    <h2 className={styles.pageTitle} style={{ margin: 0 }}>💳 خطط الاشتراك (Subscription Plans)</h2>
                    <p style={{ margin: '4px 0 0 0', color: '#94a3b8', fontSize: '13px' }}>
                        إدارة باقات وأسعار الاشتراك في التطبيق والتحكم في مدة وتفاصيل كل خطة.
                    </p>
                </div>
                <button
                    className={`${pageStyles.btn} ${pageStyles.btnPrimary}`}
                    onClick={() => setCreating(true)}
                    style={{ padding: '10px 20px', fontSize: '14px', borderRadius: '10px' }}
                >
                    + إضافة خطة جديدة
                </button>
            </div>

            <div style={{
                background: 'linear-gradient(90deg, #1e3a5f 0%, #0f172a 100%)',
                border: '1px solid #3b82f644',
                borderRadius: 12,
                padding: '14px 20px',
                marginBottom: 24,
                color: '#93c5fd',
                fontSize: 14,
                display: 'flex',
                alignItems: 'center',
                gap: 12
            }}>
                <span style={{ fontSize: 20 }}>ℹ️</span>
                <span>
                    جميع الخطط تمنح المشتركين وصولاً كاملاً لجميع بنوك الأسئلة ومزايا الذكاء الاصطناعي — الفرق فقط في <strong>السعر والمدة الزمنية</strong>.
                </span>
            </div>

            {loading ? (
                <div style={{ textAlign: 'center', padding: '60px', color: '#64748b' }}>
                    جاري تحميل الخطط...
                </div>
            ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(270px, 1fr))', gap: 20 }}>
                    {/* Create Modal / Card */}
                    {creating && (
                        <div style={{
                            background: '#161b27',
                            border: '2px solid #3b82f6',
                            borderRadius: 16,
                            padding: 24,
                            boxShadow: '0 10px 25px -5px rgba(59, 130, 246, 0.2)'
                        }}>
                            <h3 style={{ color: '#f8fafc', marginTop: 0, marginBottom: 16, fontSize: 18 }}>
                                ✨ إضافة باقة جديدة
                            </h3>
                            <label className={pageStyles.label}>اسم الباقة (Plan Name)</label>
                            <input
                                className={pageStyles.input}
                                value={newPlan.name}
                                onChange={(e) => setNewPlan({ ...newPlan, name: e.target.value })}
                                style={{ marginBottom: 12 }}
                                placeholder="مثال: شهر واحد / 3 أشهر"
                            />
                            <label className={pageStyles.label}>معرّف الرابط (Slug ID)</label>
                            <input
                                className={pageStyles.input}
                                value={newPlan.slug}
                                onChange={(e) => setNewPlan({ ...newPlan, slug: e.target.value })}
                                style={{ marginBottom: 12 }}
                                placeholder="مثال: 1-month"
                            />
                            <label className={pageStyles.label}>السعر بالريال (Price in SAR)</label>
                            <input
                                className={pageStyles.input}
                                type="number"
                                value={newPlan.price}
                                onChange={(e) => setNewPlan({ ...newPlan, price: Number(e.target.value) })}
                                style={{ marginBottom: 12 }}
                            />
                            <label className={pageStyles.label}>المدة بالأيام (Duration in Days)</label>
                            <input
                                className={pageStyles.input}
                                type="number"
                                value={newPlan.durationInDays}
                                onChange={(e) => setNewPlan({ ...newPlan, durationInDays: Number(e.target.value) })}
                                style={{ marginBottom: 12 }}
                                placeholder="مثال: 30 للشهر، 365 للسنة"
                            />
                            <label className={pageStyles.label}>نسبة الخصم الموضحة (%)</label>
                            <input
                                className={pageStyles.input}
                                type="number"
                                value={newPlan.discountPercentage}
                                onChange={(e) => setNewPlan({ ...newPlan, discountPercentage: Number(e.target.value) })}
                                style={{ marginBottom: 12 }}
                            />
                            <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
                                <label style={{ display: 'flex', alignItems: 'center', gap: 6, color: '#e2e8f0', fontSize: 13, cursor: 'pointer' }}>
                                    <input
                                        type="checkbox"
                                        checked={newPlan.isPopular}
                                        onChange={(e) => setNewPlan({ ...newPlan, isPopular: e.target.checked })}
                                    />
                                    🔥 تمييز كالأكثر طلباً
                                </label>
                                <label style={{ display: 'flex', alignItems: 'center', gap: 6, color: '#e2e8f0', fontSize: 13, cursor: 'pointer' }}>
                                    <input
                                        type="checkbox"
                                        checked={newPlan.isActive}
                                        onChange={(e) => setNewPlan({ ...newPlan, isActive: e.target.checked })}
                                    />
                                    ✅ نشطة
                                </label>
                            </div>
                            <div style={{ display: 'flex', gap: 10 }}>
                                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleCreate} style={{ flex: 1 }}>
                                    حفظ وإنشاء
                                </button>
                                <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => setCreating(false)} style={{ flex: 1 }}>
                                    إلغاء
                                </button>
                            </div>
                        </div>
                    )}

                    {/* Plan Cards */}
                    {plans.map((plan) => {
                        const isThisPopular = plan.isPopular || plan.slug === '3-months';
                        const isEditingThis = editing && (editing._id || editing.id) === (plan._id || plan.id);

                        return (
                            <div
                                key={plan._id || plan.id}
                                style={{
                                    background: '#161b27',
                                    border: isThisPopular ? '2px solid #6366f1' : '1px solid #1e293b',
                                    borderRadius: 16,
                                    padding: 24,
                                    position: 'relative',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    justifyContent: 'space-between',
                                    transition: 'transform 0.2s ease, box-shadow 0.2s ease',
                                    boxShadow: isThisPopular ? '0 10px 25px -5px rgba(99, 102, 241, 0.2)' : 'none'
                                }}
                            >
                                {isThisPopular && (
                                    <div style={{
                                        position: 'absolute',
                                        top: -12,
                                        right: 20,
                                        background: 'linear-gradient(90deg, #6366f1, #8b5cf6)',
                                        color: '#ffffff',
                                        fontSize: '11px',
                                        fontWeight: 700,
                                        padding: '4px 12px',
                                        borderRadius: '20px',
                                        boxShadow: '0 4px 10px rgba(99, 102, 241, 0.4)'
                                    }}>
                                        🔥 الأكثر طلباً (Popular)
                                    </div>
                                )}

                                {isEditingThis ? (
                                    <div>
                                        <h4 style={{ margin: '0 0 12px 0', color: '#f8fafc' }}>تعديل الباقة</h4>
                                        <label className={pageStyles.label}>اسم الباقة</label>
                                        <input
                                            className={pageStyles.input}
                                            value={editing.name}
                                            onChange={(e) => setEditing({ ...editing, name: e.target.value })}
                                            style={{ marginBottom: 10 }}
                                        />
                                        <label className={pageStyles.label}>السعر (SAR)</label>
                                        <input
                                            className={pageStyles.input}
                                            type="number"
                                            value={editing.price}
                                            onChange={(e) => setEditing({ ...editing, price: Number(e.target.value) })}
                                            style={{ marginBottom: 10 }}
                                        />
                                        <label className={pageStyles.label}>المدة بالأيام</label>
                                        <input
                                            className={pageStyles.input}
                                            type="number"
                                            value={editing.durationInDays || ''}
                                            onChange={(e) => setEditing({ ...editing, durationInDays: Number(e.target.value) })}
                                            style={{ marginBottom: 10 }}
                                        />
                                        <label className={pageStyles.label}>نسبة الخصم (%)</label>
                                        <input
                                            className={pageStyles.input}
                                            type="number"
                                            value={editing.discountPercentage || 0}
                                            onChange={(e) => setEditing({ ...editing, discountPercentage: Number(e.target.value) })}
                                            style={{ marginBottom: 10 }}
                                        />
                                        <div style={{ display: 'flex', gap: 12, marginBottom: 12 }}>
                                            <label style={{ display: 'flex', alignItems: 'center', gap: 6, color: '#e2e8f0', fontSize: 12, cursor: 'pointer' }}>
                                                <input
                                                    type="checkbox"
                                                    checked={editing.isPopular || false}
                                                    onChange={(e) => setEditing({ ...editing, isPopular: e.target.checked })}
                                                />
                                                الأكثر طلباً
                                            </label>
                                            <label style={{ display: 'flex', alignItems: 'center', gap: 6, color: '#e2e8f0', fontSize: 12, cursor: 'pointer' }}>
                                                <input
                                                    type="checkbox"
                                                    checked={editing.isActive !== false}
                                                    onChange={(e) => setEditing({ ...editing, isActive: e.target.checked })}
                                                />
                                                نشطة
                                            </label>
                                        </div>
                                        <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={saveEdit} style={{ flex: 1 }}>
                                                حفظ
                                            </button>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => setEditing(null)} style={{ flex: 1 }}>
                                                إلغاء
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    <div>
                                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                                            <div style={{ color: '#f8fafc', fontSize: 20, fontWeight: 800 }}>
                                                {plan.name}
                                            </div>
                                            <span style={{
                                                fontSize: '11px',
                                                padding: '3px 8px',
                                                borderRadius: '6px',
                                                background: plan.isActive ? '#10b98122' : '#ef444422',
                                                color: plan.isActive ? '#34d399' : '#f87171',
                                                fontWeight: 600
                                            }}>
                                                {plan.isActive ? 'مفعلة' : 'معطلة'}
                                            </span>
                                        </div>

                                        <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginBottom: 8 }}>
                                            <span style={{ color: '#34d399', fontSize: 34, fontWeight: 900, lineHeight: 1 }}>
                                                {plan.price}
                                            </span>
                                            <span style={{ color: '#94a3b8', fontSize: 14, fontWeight: 600 }}>
                                                ريال سعودي
                                            </span>
                                        </div>

                                        <div style={{
                                            background: '#1e293b',
                                            borderRadius: 8,
                                            padding: '8px 12px',
                                            marginBottom: 16,
                                            color: '#cbd5e1',
                                            fontSize: 13,
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: 8
                                        }}>
                                            <span>⏳</span>
                                            <span>{getDurationLabel(plan.durationInDays)}</span>
                                            {plan.discountPercentage > 0 && (
                                                <span style={{
                                                    marginLeft: 'auto',
                                                    background: '#f59e0b22',
                                                    color: '#fbbf24',
                                                    padding: '2px 6px',
                                                    borderRadius: 4,
                                                    fontSize: 11,
                                                    fontWeight: 700
                                                }}>
                                                    وفر {plan.discountPercentage}%
                                                </span>
                                            )}
                                        </div>

                                        <div style={{ display: 'flex', gap: 8, marginTop: 16, borderTop: '1px solid #1e293b', paddingTop: 14 }}>
                                            <button
                                                className={`${pageStyles.btn} ${pageStyles.btnGhost}`}
                                                onClick={() => setEditing(plan)}
                                                style={{ flex: 1, background: '#1e293b', color: '#e2e8f0' }}
                                            >
                                                ✏️ تعديل
                                            </button>
                                            <button
                                                className={`${pageStyles.btn} ${pageStyles.btnGhost}`}
                                                onClick={() => handleDelete(plan._id || plan.id)}
                                                style={{ flex: 1, background: '#ef444415', color: '#f87171' }}
                                            >
                                                🗑️ حذف
                                            </button>
                                        </div>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
}
