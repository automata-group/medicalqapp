import { useEffect, useState } from 'react';
import { getSpecialties, createSpecialty, updateSpecialty, deleteSpecialty, uploadSpecialtyImage } from '../api/api';
import styles from './Dashboard.module.css';
import pageStyles from './Page.module.css';

const API_STATIC_URL = (import.meta.env.VITE_API_URL || '').replace('/api/v1', '');

export default function Categories() {
    const [categories, setCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [isCreating, setIsCreating] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [newCat, setNewCat] = useState({ name: '', icon: '', isPremium: false });
    const [editId, setEditId] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [preview, setPreview] = useState('');

    useEffect(() => {
        loadCategories();
    }, []);

    const loadCategories = () => {
        setLoading(true);
        getSpecialties()
            .then(res => setCategories(res.data?.data || []))
            .catch(err => console.error(err))
            .finally(() => setLoading(false));
    };

    const handleFileChange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('image', file);

        setUploading(true);
        try {
            const res = await uploadSpecialtyImage(formData);
            if (isEditing) {
                setNewCat({ ...newCat, icon: res.data.data });
            } else {
                setNewCat({ ...newCat, icon: res.data.data });
            }
            setPreview(API_STATIC_URL + res.data.data);
            alert('Image uploaded successfully');
        } catch (error) {
            console.error(error);
            alert('Image upload failed');
        } finally {
            setUploading(false);
        }
    };

    const handleCreate = async () => {
        if (!newCat.name) return alert('Name is required');
        try {
            if (isEditing) {
                await updateSpecialty(editId, newCat);
            } else {
                await createSpecialty({ ...newCat, order: 0 });
            }
            resetForm();
            loadCategories();
        } catch (error) {
            console.error(error);
            alert(isEditing ? 'Failed to update category' : 'Failed to create category');
        }
    };

    const resetForm = () => {
        setIsCreating(false);
        setIsEditing(false);
        setEditId(null);
        setNewCat({ name: '', icon: '', isPremium: false });
        setPreview('');
    };

    const handleEdit = (c) => {
        setEditId(c.id);
        setNewCat({ name: c.name, icon: c.icon, isPremium: c.isPremium });
        if (c.icon) setPreview(API_STATIC_URL + c.icon);
        setIsEditing(true);
        setIsCreating(true);
    };

    const handleDelete = async (id) => {
        if (!confirm('Are you sure you want to delete this category? Ensure no topics or questions are attached.')) return;
        try {
            await deleteSpecialty(id);
            loadCategories();
        } catch (error) {
            console.error(error);
            alert(error.response?.data?.message || 'Failed to delete category');
        }
    };

    const filtered = categories.filter(c => c.name.toLowerCase().includes(search.toLowerCase()));

    return (
        <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h2 className={styles.pageTitle}>🗂️ Categories (Specialties)</h2>
                <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={() => isCreating ? resetForm() : setIsCreating(true)}>
                    {isCreating ? 'Cancel' : '+ New Category'}
                </button>
            </div>

            {isCreating && (
                <div style={{ background: '#1e293b', padding: '25px', borderRadius: '12px', marginBottom: '30px', border: '1px solid #334155' }}>
                    <h3 style={{ marginTop: 0, color: '#f8fafc', marginBottom: '20px' }}>{isEditing ? '🔧 Edit Category' : '✨ Create New Specialty Category'}</h3>
                    <div style={{ display: 'flex', gap: '25px', flexWrap: 'wrap', alignItems: 'flex-start' }}>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '15px', flex: 1 }}>
                            <div className={pageStyles.formGroup}>
                                <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Specialty Name (e.g. Cardiology, Neurology)</label>
                                <input className={pageStyles.search} placeholder="Category Name" value={newCat.name} onChange={e => setNewCat({ ...newCat, name: e.target.value })} />
                            </div>

                            <div style={{ display: 'flex', gap: '15px', alignItems: 'center', paddingTop: '10px' }}>
                                <label style={{ color: '#cbd5e1', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
                                    <input type="checkbox" checked={newCat.isPremium} onChange={e => setNewCat({ ...newCat, isPremium: e.target.checked })} />
                                    <span style={{ fontWeight: 600 }}>Premium Category (Subscription required for students)</span>
                                </label>
                            </div>
                        </div>

                        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', minWidth: '200px' }}>
                            <label style={{ color: '#94a3b8', fontSize: '13px', marginBottom: '5px', display: 'block' }}>Category Icon / Thumbnail</label>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                                {preview ? (
                                    <img src={preview} alt="Icon Preview" style={{ width: 60, height: 60, borderRadius: '12px', objectFit: 'cover', background: '#334155', border: '2px solid #475569' }} />
                                ) : (
                                    <div style={{ width: 60, height: 60, borderRadius: '12px', background: '#334155', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '24px', border: '2px dashed #475569' }}>🖼️</div>
                                )}
                                <div style={{ position: 'relative' }}>
                                    <button className={pageStyles.btn} style={{ background: '#334155', border: '1px solid #475569' }} disabled={uploading}>
                                        {uploading ? 'Uploading...' : '📁 Choose Image'}
                                    </button>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        onChange={handleFileChange}
                                        style={{ position: 'absolute', left: 0, top: 0, opacity: 0, width: '100%', height: '100%', cursor: 'pointer' }}
                                    />
                                </div>
                            </div>
                        </div>

                        <button className={`${pageStyles.btn} ${pageStyles.btnPrimary}`} onClick={handleCreate} style={{ alignSelf: 'flex-end', height: '42px', minWidth: '120px', marginBottom: '5px' }}>
                            {isEditing ? 'Update Category' : 'Save Category'}
                        </button>
                    </div>
                </div>
            )}

            <div className={pageStyles.toolbar}>
                <input className={pageStyles.search} placeholder="Search categories..." value={search} onChange={(e) => setSearch(e.target.value)} />
                <span className={pageStyles.count}>{filtered.length} categories</span>
            </div>

            <div className={styles.tableWrap}>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Icon</th>
                            <th>Name</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        {loading ? <tr><td colSpan="5" style={{ textAlign: 'center' }}>Loading...</td></tr> : filtered.length === 0 ? <tr><td colSpan="5" style={{ textAlign: 'center' }}>No categories found</td></tr> : (
                            filtered.map(c => (
                                <tr key={c.id}>
                                    <td>{c.id}</td>
                                    <td>
                                        {c.icon ? (
                                            <img src={API_STATIC_URL + c.icon} alt={c.name} style={{ width: 40, height: 40, borderRadius: '50%', objectFit: 'cover' }} />
                                        ) : (
                                            <div style={{ width: 40, height: 40, borderRadius: '50%', background: '#334155', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>❓</div>
                                        )}
                                    </td>
                                    <td>{c.name}</td>
                                    <td>
                                        {c.isPremium ? (
                                            <span className={pageStyles.badge} style={{ background: '#4c1d95', color: '#ddd6fe' }}>Premium</span>
                                        ) : (
                                            <span className={pageStyles.badge} style={{ background: '#14532d', color: '#4ade80' }}>Free</span>
                                        )}
                                    </td>
                                    <td>
                                        <div style={{ display: 'flex', gap: '5px' }}>
                                            <button className={pageStyles.btn} style={{ background: '#0ea5e9' }} onClick={() => handleEdit(c)}>Edit</button>
                                            <button className={`${pageStyles.btn} ${pageStyles.btnDanger}`} onClick={() => handleDelete(c.id)}>Delete</button>
                                        </div>
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
