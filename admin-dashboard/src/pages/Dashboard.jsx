import { useEffect, useState } from 'react';
import { getUserStats, getBusinessAnalytics } from '../api/api';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, BarChart, Bar } from 'recharts';
import styles from './Dashboard.module.css';

function StatCard({ label, value, icon, color }) {
    return (
        <div className={styles.card} style={{ borderColor: color }}>
            <div className={styles.cardIcon} style={{ background: color + '22' }}>{icon}</div>
            <div>
                <div className={styles.cardValue}>{value ?? '—'}</div>
                <div className={styles.cardLabel}>{label}</div>
            </div>
        </div>
    );
}

export default function Dashboard() {
    const [stats, setStats] = useState(null);
    const [businessStats, setBusinessStats] = useState(null);
    const [error, setError] = useState('');

    useEffect(() => {
        Promise.all([getUserStats(), getBusinessAnalytics()])
            .then(([statsRes, businessRes]) => {
                setStats(statsRes.data);
                setBusinessStats(businessRes.data?.data);
            })
            .catch(() => setError('Could not load statistics'));
    }, []);

    const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6'];

    return (
        <div>
            <h2 className={styles.pageTitle}>📊 Dashboard Overview</h2>
            {error && <div className={styles.error}>{error}</div>}
            <div className={styles.grid}>
                <StatCard label="Total Users" value={stats?.totalUsers} icon="👤" color="#3b82f6" />
                <StatCard label="Premium Users" value={stats?.premiumUsers} icon="⭐" color="#f59e0b" />
                <StatCard label="Total Questions" value={stats?.totalQuestions} icon="📚" color="#10b981" />
                <StatCard label="Today Revenue" value={stats?.todayRevenue !== undefined ? `SAR ${stats.todayRevenue}` : null} icon="💰" color="#8b5cf6" />
                <StatCard label="This Month" value={stats?.monthRevenue !== undefined ? `SAR ${stats.monthRevenue}` : null} icon="📈" color="#ec4899" />
                <StatCard label="Conversion Rate (Free to Pro)" value={businessStats ? `${businessStats.conversionRate}%` : null} icon="🚀" color="#34d399" />
                <StatCard label="Churn Rate" value={businessStats ? `${businessStats.churnRate}%` : null} icon="📉" color="#fbbf24" />
            </div>

            {businessStats && (
                <div className={styles.chartsGrid}>
                    <div className={styles.chartCard}>
                        <h3>Revenue Over Time (30 Days)</h3>
                        <div className={styles.chartContainer}>
                            <ResponsiveContainer width="100%" height="100%">
                                <LineChart data={businessStats.revenueOverTime}>
                                    <CartesianGrid strokeDasharray="3 3" stroke="#1e293b" />
                                    <XAxis dataKey="date" stroke="#94a3b8" tick={{ fill: '#94a3b8' }} />
                                    <YAxis stroke="#94a3b8" tick={{ fill: '#94a3b8' }} />
                                    <Tooltip contentStyle={{ backgroundColor: '#0f172a', borderColor: '#1e293b' }} />
                                    <Line type="monotone" dataKey="revenue" stroke="#3b82f6" strokeWidth={3} dot={false} />
                                </LineChart>
                            </ResponsiveContainer>
                        </div>
                    </div>

                    <div className={styles.chartCard}>
                        <h3>Top Specialties (Questions Attempted)</h3>
                        <div className={styles.chartContainer}>
                            <ResponsiveContainer width="100%" height="100%">
                                <PieChart>
                                    <Pie
                                        data={businessStats.topSpecialties}
                                        cx="50%"
                                        cy="50%"
                                        innerRadius={60}
                                        outerRadius={80}
                                        paddingAngle={5}
                                        dataKey="value"
                                    >
                                        {businessStats.topSpecialties.map((entry, index) => (
                                            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                        ))}
                                    </Pie>
                                    <Tooltip contentStyle={{ backgroundColor: '#0f172a', borderColor: '#1e293b' }} />
                                </PieChart>
                            </ResponsiveContainer>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
