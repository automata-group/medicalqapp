import { useEffect, useState } from 'react';
import { getDiscountCodes, createDiscountCode, deleteDiscountCode } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

export default function Promo() {
    const [codes, setCodes] = useState([]);
    const [loading, setLoading] = useState(true);
    const [form, setForm] = useState({ code: '', discount: '', maxUses: '', expiresAt: '' });

    useEffect(() => {
        getDiscountCodes()
            .then((r) => setCodes(r.data?.data || r.data || []))
            .finally(() => setLoading(false));
    }, []);

    async function handleCreate(e) {
        e.preventDefault();
        const res = await createDiscountCode(form);
        setCodes((p) => [...p, res.data?.data || res.data]);
        setForm({ code: '', discount: '', maxUses: '', expiresAt: '' });
    }

    async function remove(id) {
        if (!confirm('Delete this code?')) return;
        await deleteDiscountCode(id);
        setCodes((p) => p.filter((c) => (c._id || c.id) !== id));
    }

    return (
        <div>
            <h2 className={styles.pageTitle}>🏷️ Promo Codes</h2>
            <form className={pageStyles.form} onSubmit={handleCreate}>
                <div className={pageStyles.row}>
                    <div>
                        <label className={pageStyles.label}>Code</label>
                        <input className={pageStyles.input} placeholder="SUMMER50" value={form.code} onChange={(e) => setForm({ ...form, code: e.target.value })} required />
                    </div>
                    <div>
                        <label className={pageStyles.label}>Discount %</label>
                        <input className={pageStyles.input} type="number" placeholder="20" value={form.discount} onChange={(e) => setForm({ ...form, discount: e.target.value })} required />
                    </div>
                    <div>
                        <label className={pageStyles.label}>Max Uses</label>
                        <input className={pageStyles.input} type="number" placeholder="100" value={form.maxUses} onChange={(e) => setForm({ ...form, maxUses: e.target.value })} />
                    </div>
                    <div>
                        <label className={pageStyles.label}>Expires At</label>
                        <input className={pageStyles.input} type="date" value={form.expiresAt} onChange={(e) => setForm({ ...form, expiresAt: e.target.value })} />
                    </div>
                </div>
                <button type="submit" className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} style={{ width: 'fit-content' }}>
                    + Create Code
                </button>
            </form>

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr><th>Code</th><th>Discount</th><th>Used / Max</th><th>Expires</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        {loading ? (
                            <tr><td colSpan="5" style={{ textAlign: 'center', color: '#64748b' }}>Loading…</td></tr>
                        ) : codes.map((c) => (
                            <tr key={c._id || c.id}>
                                <td><code style={{ color: '#60a5fa' }}>{c.code}</code></td>
                                <td style={{ color: '#34d399' }}>{c.discount}%</td>
                                <td style={{ color: '#94a3b8' }}>{c.usedCount || 0} / {c.maxUses || '∞'}</td>
                                <td style={{ color: '#64748b' }}>{c.expiresAt ? new Date(c.expiresAt).toLocaleDateString() : '—'}</td>
                                <td><button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={() => remove(c._id || c.id)}>Delete</button></td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
