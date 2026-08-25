import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import styles from './Sidebar.module.css';

const navItems = [
    { to: '/', label: 'Dashboard', icon: '📊' },
    { to: '/users', label: 'Users', icon: '👤' },
    { to: '/questions', label: 'Questions', icon: '📚' },
    { to: '/categories', label: 'Categories', icon: '🗂️' },
    { to: '/topics', label: 'Topics', icon: '📂' },
    { to: '/mock-exams', label: 'Mock Exams', icon: '📝' },
    { to: '/achievements', label: 'Achievements', icon: '🏆' },
    { to: '/reports', label: 'Reports', icon: '🚩' },
    { to: '/promo', label: 'Promo Codes', icon: '🏷️' },
    { to: '/plans', label: 'Plans', icon: '💳' },
    { to: '/notify', label: 'Notifications', icon: '🔔' },
    { to: '/ai-insights', label: 'AI Insights', icon: '🤖' },
    { to: '/settings', label: 'Settings', icon: '⚙️' },
];


export default function Sidebar({ collapsed, setCollapsed }) {
    const { admin, logout } = useAuth();
    const navigate = useNavigate();

    function handleLogout() {
        logout();
        navigate('/login');
    }

    return (
        <aside className={`${styles.sidebar} ${collapsed ? styles.collapsed : ''}`}>
            <div className={styles.header}>
                <span className={styles.logo}>⚕</span>
                {!collapsed && <span className={styles.title}>Medical Q</span>}
                <button className={styles.toggle} onClick={() => setCollapsed(!collapsed)}>
                    {collapsed ? '→' : '←'}
                </button>
            </div>

            <nav className={styles.nav}>
                {navItems.map((item) => (
                    <NavLink
                        key={item.to}
                        to={item.to}
                        end={item.to === '/'}
                        className={({ isActive }) =>
                            `${styles.link} ${isActive ? styles.active : ''}`
                        }
                    >
                        <span className={styles.icon}>{item.icon}</span>
                        {!collapsed && <span className={styles.label}>{item.label}</span>}
                    </NavLink>
                ))}
            </nav>

            <div className={styles.footer}>
                {!collapsed && (
                    <div className={styles.adminInfo}>
                        <span className={styles.adminAvatar}>
                            {(admin?.fullName || admin?.name || 'A')?.[0]?.toUpperCase()}
                        </span>
                        <div>
                            <div className={styles.adminName}>{admin?.fullName || admin?.name || 'Admin'}</div>
                            <div className={styles.adminRole}>Administrator</div>
                        </div>
                    </div>
                )}
                <button className={styles.logoutBtn} onClick={handleLogout} title="Logout">
                    🚪
                </button>
            </div>
        </aside>
    );
}
