import { createContext, useContext, useState } from 'react';
import { login as loginApi } from '../api/api';

const AuthContext = createContext({ admin: null, login: async () => { }, logout: () => { }, loading: true });

export function AuthProvider({ children }) {
    const [admin, setAdmin] = useState(() => {
        const stored = localStorage.getItem('adminUser');
        return stored ? JSON.parse(stored) : null;
    });
    const [loading] = useState(false);

    async function login(email, password) {
        const res = await loginApi(email, password);
        // Backend returns: { success: true, data: { accessToken, role, fullName, ... } }
        const userData = res.data?.data;
        if (!userData) throw new Error('Invalid server response');
        if (userData.role !== 'admin') throw new Error('Not an admin account');
        const token = userData.accessToken;
        localStorage.setItem('adminToken', token);
        localStorage.setItem('adminUser', JSON.stringify(userData));
        setAdmin(userData);
        return userData;
    }

    function logout() {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        setAdmin(null);
    }

    return (
        <AuthContext.Provider value={{ admin, login, logout, loading }}>
            {children}
        </AuthContext.Provider>
    );
}

// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => useContext(AuthContext);
