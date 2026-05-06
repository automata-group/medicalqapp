import { useEffect, useState } from 'react';
import { getPlans, updatePlan, createPlan, deletePlan } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Plans() {
    const [plans, setPlans] = useState([]);
    const [loading, setLoading] = useState(true);
    const [editing, setEditing] = useState(null);
    const [creating, setCreating] = useState(false);
    const [newPlan, setNewPlan] = useState({ name: '', slug: '', price: 0, durationInDays: 30, discountPercentage: 0, isActive: true });
    useEffect(() => {
        getPlans()
            .then((r) => setPlans(r.data?.data || r.data || []))
            .finally(() => setLoading(false));
    }, []);

    async function saveEdit() {
        await updatePlan(editing._id || editing.id, editing);
        setPlans((p) => p.map((pl) => ((pl._id || pl.id) === (editing._id || editing.id) ? editing : pl)));
        setEditing(null);
    }

    async function handleCreate() {
        if (!newPlan.name || !newPlan.price || !newPlan.durationInDays) return alert('Name, Price and Duration are required');
        const slugStr = newPlan.slug || newPlan.name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
        const res = await createPlan({ ...newPlan, slug: slugStr });
        setPlans([...plans, res.data?.data || res.data]);
        setCreating(false);
        setNewPlan({ name: '', slug: '', price: 0, durationInDays: 30, discountPercentage: 0, isActive: true });
    }

    async function handleDelete(id) {
        if (!window.confirm('Are you sure you want to delete this plan?')) return;
        await deletePlan(id);
        setPlans((p) => p.filter((pl) => (pl._id || pl.id) !== id));
    }

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h2 className={styles.pageTitle}>💳 Subscription Plans</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => setCreating(true)}>
                    + New Plan
                </button>
            </div>
            <div style={{ background: '#1e3a5f', border: '1px solid #3b82f6', borderRadius: 12, padding: '12px 16px', marginBottom: 20, color: '#93c5fd', fontSize: 14 }}>
                ℹ️ جميع الخطط تمنح المشتركين وصولاً كاملاً لجميع مزايا التطبيق — الفرق فقط في <strong>السعر والمدة</strong>.
            </div>

            {
                loading ? <p style={{ color: '#64748b' }}>Loading…</p> : (
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: 16 }}>
                        {creating && (
                            <div style={{ background: '#161b27', border: '1px solid #3b82f6', borderRadius: 14, padding: 24 }}>
                                <h3 style={{ color: '#f8fafc', marginTop: 0, marginBottom: 16 }}>Create Plan</h3>
                                <label className={pageStyles.label}>Plan Name</label>
                                <input className={pageStyles.input} value={newPlan.name} onChange={(e) => setNewPlan({ ...newPlan, name: e.target.value })} style={{ marginBottom: 10 }} placeholder="e.g. Pro Monthly" />
                                <label className={pageStyles.label}>Slug ID</label>
                                <input className={pageStyles.input} value={newPlan.slug} onChange={(e) => setNewPlan({ ...newPlan, slug: e.target.value })} style={{ marginBottom: 10 }} placeholder="e.g. pro-monthly" />
                                <label className={pageStyles.label}>Price (SAR)</label>
                                <input className={pageStyles.input} type="number" value={newPlan.price} onChange={(e) => setNewPlan({ ...newPlan, price: Number(e.target.value) })} style={{ marginBottom: 10 }} />
                                <label className={pageStyles.label}>Duration (Days)</label>
                                <input className={pageStyles.input} type="number" value={newPlan.durationInDays} onChange={(e) => setNewPlan({ ...newPlan, durationInDays: Number(e.target.value) })} style={{ marginBottom: 10 }} />
                                <label className={pageStyles.label}>Discount Percentage</label>
                                <input className={pageStyles.input} type="number" value={newPlan.discountPercentage} onChange={(e) => setNewPlan({ ...newPlan, discountPercentage: Number(e.target.value) })} style={{ marginBottom: 10 }} />
                                <label className={pageStyles.label}>Active Status</label>
                                <select className={pageStyles.input} value={newPlan.isActive ? 'true' : 'false'} onChange={(e) => setNewPlan({ ...newPlan, isActive: e.target.value === 'true' })} style={{ marginBottom: 10 }}>
                                    <option value="true">Active</option>
                                    <option value="false">Inactive</option>
                                </select>
                                <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
                                    <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleCreate}>Create</button>
                                    <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => setCreating(false)}>Cancel</button>
                                </div>
                            </div>
                        )}
                        {plans.map((plan) => (
                            <div key={plan._id || plan.id} style={{ background: '#161b27', border: '1px solid #1e293b', borderRadius: 14, padding: 24 }}>
                                {editing && (editing._id || editing.id) === (plan._id || plan.id) ? (
                                    <>
                                        <label className={pageStyles.label}>Plan Name</label>
                                        <input className={pageStyles.input} value={editing.name} onChange={(e) => setEditing({ ...editing, name: e.target.value })} style={{ marginBottom: 10 }} />
                                        <label className={pageStyles.label}>Price (SAR)</label>
                                        <input className={pageStyles.input} type="number" value={editing.price} onChange={(e) => setEditing({ ...editing, price: e.target.value })} style={{ marginBottom: 10 }} />
                                        <label className={pageStyles.label}>Duration (Days)</label>
                                        <input className={pageStyles.input} type="number" placeholder="e.g. 30, 365" value={editing.durationInDays || ''} onChange={(e) => setEditing({ ...editing, durationInDays: Number(e.target.value) })} style={{ marginBottom: 10 }} />
                                        <label className={pageStyles.label}>Discount Percentage</label>
                                        <input className={pageStyles.input} type="number" placeholder="e.g. 10" value={editing.discountPercentage || 0} onChange={(e) => setEditing({ ...editing, discountPercentage: Number(e.target.value) })} style={{ marginBottom: 10 }} />
                                        <label className={pageStyles.label}>Active Status</label>
                                        <select className={pageStyles.input} value={editing.isActive ? 'true' : 'false'} onChange={(e) => setEditing({ ...editing, isActive: e.target.value === 'true' })} style={{ marginBottom: 10 }}>
                                            <option value="true">Active</option>
                                            <option value="false">Inactive</option>
                                        </select>
                                        <div style={{ display: 'flex', gap: 8, marginTop: 4 }}>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={saveEdit}>Save</button>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => setEditing(null)}>Cancel</button>
                                        </div>
                                    </>
                                ) : (
                                    <>
                                        <div style={{ color: '#f1f5f9', fontSize: 18, fontWeight: 700, marginBottom: 8 }}>{plan.name}</div>
                                        <div style={{ color: '#34d399', fontSize: 30, fontWeight: 800, lineHeight: 1 }}>
                                            SAR {plan.price}
                                        </div>
                                        <div style={{ color: '#64748b', fontSize: 13, marginTop: 4 }}>
                                            ⏳ {plan.durationInDays} days {plan.discountPercentage > 0 ? `| 🏷️ ${plan.discountPercentage}% off` : ''}
                                        </div>
                                        <div style={{ marginTop: 12, padding: '8px 12px', background: plan.isActive ? '#0f172a' : '#2d1820', borderRadius: 8, color: plan.isActive ? '#4ade80' : '#ef4444', fontSize: 13 }}>
                                            {plan.isActive ? '✅ Active Plan' : '❌ Inactive Plan'}
                                        </div>
                                        <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => setEditing(plan)} style={{ flex: 1 }}>
                                                ✏️ Edit
                                            </button>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnGhost}`} onClick={() => handleDelete(plan._id || plan.id)} style={{ flex: 1, color: '#ef4444' }}>
                                                🗑️ Delete
                                            </button>
                                        </div>
                                    </>
                                )}
                            </div>
                        ))}
                    </div>
                )}
        </div>
    );
}
