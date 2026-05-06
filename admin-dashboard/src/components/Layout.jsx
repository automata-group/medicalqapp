import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import styles from './Layout.module.css';

export default function Layout() {
    const [collapsed, setCollapsed] = useState(false);
    return (
        <div className={styles.shell}>
            <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />
            <main className={styles.main}>
                <Outlet />
            </main>
        </div>
    );
}
