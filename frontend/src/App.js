import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import PrivateRoute from './components/PrivateRoute';
import { AuthProvider } from './context/AuthContext';
import CalculadoraVenta from './pages/CalculadoraVenta';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Transacciones from './pages/Transacciones';
import './styles/global.css';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <div className="app">
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/dashboard" element={
              <PrivateRoute>
                <Dashboard />
              </PrivateRoute>
            } />
            <Route path="/transacciones" element={
              <PrivateRoute>
                <Transacciones />
              </PrivateRoute>
            } />
            <Route path="/calculadora" element={
              <PrivateRoute>
                <CalculadoraVenta />
              </PrivateRoute>
            } />
            <Route path="/" element={<Navigate to="/dashboard" />} />
          </Routes>
        </div>
      </BrowserRouter>
    </AuthProvider>
  );
}