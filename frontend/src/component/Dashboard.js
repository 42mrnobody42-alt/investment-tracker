import { useEffect, useState } from 'react';
import api from '../services/api';
import GraficoRendimiento from './GraficoRendimiento';
import ResumenInversiones from './ResumenInversiones';

const Dashboard = () => {
  const [resumen, setResumen] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchResumen();
  }, []);

  const fetchResumen = async () => {
    try {
      const response = await api.get('/transacciones/resumen');
      setResumen(response.data);
    } catch (error) {
      console.error('Error fetching resumen:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="loading-spinner">Cargando...</div>;

  return (
    <div className="dashboard">
      <h1>Dashboard de Inversiones</h1>
      {resumen && (
        <>
          <ResumenInversiones data={resumen} />
          <GraficoRendimiento data={resumen.detallePorSimbolo} />
        </>
      )}
    </div>
  );
};