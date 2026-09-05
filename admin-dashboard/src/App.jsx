import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { lazy, Suspense, useEffect } from 'react';
import Layout from './components/Layout';

// Lazy-load all pages so the browser only downloads what's needed initially
const Login = lazy(() => import('./pages/Login'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Users = lazy(() => import('./pages/Users'));
const Questions = lazy(() => import('./pages/Questions'));
const AIInsights = lazy(() => import('./pages/AIInsights'));
const Reports = lazy(() => import('./pages/Reports'));
const Promo = lazy(() => import('./pages/Promo'));
const Plans = lazy(() => import('./pages/Plans'));
const Notify = lazy(() => import('./pages/Notify'));
const Categories = lazy(() => import('./pages/Categories'));
const Topics = lazy(() => import('./pages/Topics'));
const MockExams = lazy(() => import('./pages/MockExams'));
const Achievements = lazy(() => import('./pages/Achievements'));
const Settings = lazy(() => import('./pages/Settings'));
const Contributions = lazy(() => import('./pages/Contributions'));


const PageLoader = () => (
  <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#94a3b8', background: '#0d1117' }}>Loading…</div>
);

function ProtectedRoute({ children }) {
  const { admin, loading } = useAuth();
  if (loading) return <PageLoader />;
  return admin ? children : <Navigate to="/login" replace />;
}

export default function App() {
  useEffect(() => {
    // Parallel prefetching for all pages in the background
    // This allows the initial load to be fast (lazy), but subsequent clicks are instant (preloaded)
    const preloadPages = () => {
      import('./pages/Dashboard');
      import('./pages/Users');
      import('./pages/Questions');
      import('./pages/AIInsights');
      import('./pages/Categories');
      import('./pages/Topics');
      import('./pages/Reports');
      import('./pages/Promo');
      import('./pages/Plans');
      import('./pages/Notify');
      import('./pages/Settings');
    };
    // Delay prefetching slightly to prioritize initial UI render
    setTimeout(preloadPages, 1000);
  }, []);

  return (
    <AuthProvider>
      <BrowserRouter>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route
              path="/"
              element={
                <ProtectedRoute>
                  <Layout />
                </ProtectedRoute>
              }
            >
              <Route index element={<Dashboard />} />
              <Route path="users" element={<Users />} />
              <Route path="questions" element={<Questions />} />
              <Route path="contributions" element={<Contributions />} />
              <Route path="ai-insights" element={<AIInsights />} />
              <Route path="categories" element={<Categories />} />
              <Route path="topics" element={<Topics />} />
              <Route path="mock-exams" element={<MockExams />} />
              <Route path="achievements" element={<Achievements />} />
              <Route path="reports" element={<Reports />} />
              <Route path="promo" element={<Promo />} />
              <Route path="plans" element={<Plans />} />
              <Route path="notify" element={<Notify />} />
              <Route path="settings" element={<Settings />} />
            </Route>
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Suspense>
      </BrowserRouter>
    </AuthProvider>
  );
}



