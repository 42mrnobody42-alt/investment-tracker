--
-- PostgreSQL database dump
--

\restrict TTO54JYkFetE6RKMvnTECvqDm5GmAzKXIybSmLbHb6RU43jdrhqnYZifH7Q71rG

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: investment_tracker; Type: SCHEMA; Schema: -; Owner: investor
--

CREATE SCHEMA investment_tracker;


ALTER SCHEMA investment_tracker OWNER TO investor;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: calcular_comision(uuid, numeric); Type: FUNCTION; Schema: investment_tracker; Owner: investor
--

CREATE FUNCTION investment_tracker.calcular_comision(p_plataforma_id uuid, p_valor_transaccion numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_comision DECIMAL(10,2) := 0;
    v_porcentaje DECIMAL(5,4);
    v_valor_fijo DECIMAL(10,2);
BEGIN
    SELECT c.porcentaje, c.valor_fijo 
    INTO v_porcentaje, v_valor_fijo
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
    
    IF v_porcentaje IS NOT NULL THEN
        v_comision := v_comision + (p_valor_transaccion * v_porcentaje);
    END IF;
    IF v_valor_fijo IS NOT NULL THEN
        v_comision := v_comision + v_valor_fijo;
    END IF;
    
    RETURN ROUND(v_comision::numeric, 2);
END;
$$;


ALTER FUNCTION investment_tracker.calcular_comision(p_plataforma_id uuid, p_valor_transaccion numeric) OWNER TO investor;

--
-- Name: calcular_venta_optima(uuid, character varying, numeric, uuid); Type: FUNCTION; Schema: investment_tracker; Owner: investor
--

CREATE FUNCTION investment_tracker.calcular_venta_optima(p_usuario_id uuid, p_simbolo character varying, p_ganancia_deseada numeric, p_plataforma_id uuid) RETURNS TABLE(precio_minimo numeric, cantidad_optima integer, comision_estimada numeric, ingreso_bruto numeric, ganancia_neta numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cantidad_actual INTEGER;
    v_costo_promedio DECIMAL(10,4);
    v_comision_compra DECIMAL(10,2);
    v_porcentaje_comision DECIMAL(5,4);
    v_valor_fijo_comision DECIMAL(10,2);
    v_costo_total DECIMAL(10,2);
    v_precio_minimo_calc DECIMAL(10,4);
    v_comision_venta DECIMAL(10,2);
BEGIN
    SELECT 
        SUM(CASE WHEN tipo = 'COMPRA' THEN cantidad ELSE -cantidad END),
        AVG(CASE WHEN tipo = 'COMPRA' THEN precio_unitario ELSE NULL END),
        SUM(CASE WHEN tipo = 'COMPRA' THEN comision ELSE 0 END)
    INTO v_cantidad_actual, v_costo_promedio, v_comision_compra
    FROM investment_tracker.transacciones
    WHERE usuario_id = p_usuario_id 
      AND simbolo = p_simbolo
      AND tipo IN ('COMPRA', 'VENTA');
    
    IF v_cantidad_actual IS NULL OR v_cantidad_actual <= 0 THEN
        RETURN;
    END IF;
    
    SELECT porcentaje, valor_fijo
    INTO v_porcentaje_comision, v_valor_fijo_comision
    FROM investment_tracker.obtener_comision_actual(p_plataforma_id);
    
    v_costo_total := (v_cantidad_actual * v_costo_promedio) + v_comision_compra;
    
    IF v_porcentaje_comision IS NOT NULL AND v_porcentaje_comision > 0 THEN
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada + COALESCE(v_valor_fijo_comision, 0)) / 
                                (v_cantidad_actual * (1 - v_porcentaje_comision));
    ELSE
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada) / v_cantidad_actual;
    END IF;
    
    v_comision_venta := investment_tracker.calcular_comision(
        p_plataforma_id, 
        v_precio_minimo_calc * v_cantidad_actual
    );
    
    RETURN QUERY
    SELECT 
        ROUND(v_precio_minimo_calc::numeric, 4),
        v_cantidad_actual,
        v_comision_venta,
        ROUND((v_precio_minimo_calc * v_cantidad_actual)::numeric, 2),
        p_ganancia_deseada;
END;
$$;


ALTER FUNCTION investment_tracker.calcular_venta_optima(p_usuario_id uuid, p_simbolo character varying, p_ganancia_deseada numeric, p_plataforma_id uuid) OWNER TO investor;

--
-- Name: obtener_comision_actual(uuid); Type: FUNCTION; Schema: investment_tracker; Owner: investor
--

CREATE FUNCTION investment_tracker.obtener_comision_actual(p_plataforma_id uuid) RETURNS TABLE(porcentaje numeric, valor_fijo numeric, descripcion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT c.porcentaje, c.valor_fijo, c.descripcion
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
END;
$$;


ALTER FUNCTION investment_tracker.obtener_comision_actual(p_plataforma_id uuid) OWNER TO investor;

--
-- Name: resumen_inversiones(uuid); Type: FUNCTION; Schema: investment_tracker; Owner: investor
--

CREATE FUNCTION investment_tracker.resumen_inversiones(p_usuario_id uuid) RETURNS TABLE(simbolo character varying, empresa_nombre character varying, cantidad_actual integer, precio_promedio_compra numeric, total_invertido numeric, total_comisiones numeric, ultima_transaccion timestamp without time zone, cantidad_compras bigint, cantidad_ventas bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.simbolo::VARCHAR(20),
        MAX(t.empresa_nombre)::VARCHAR(200),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END)::INTEGER,
        ROUND(AVG(CASE WHEN t.tipo = 'COMPRA' THEN t.precio_unitario ELSE NULL END)::numeric, 4)::DECIMAL(10,4),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.valor_total ELSE 0 END)::DECIMAL(10,2),
        SUM(t.comision)::DECIMAL(10,2),
        MAX(t.fecha_transaccion),
        COUNT(*) FILTER (WHERE t.tipo = 'COMPRA'),
        COUNT(*) FILTER (WHERE t.tipo = 'VENTA')
    FROM investment_tracker.transacciones t
    WHERE t.usuario_id = p_usuario_id
    GROUP BY t.simbolo
    HAVING SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END) > 0
    ORDER BY total_invertido DESC;
END;
$$;


ALTER FUNCTION investment_tracker.resumen_inversiones(p_usuario_id uuid) OWNER TO investor;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calculos_hist; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.calculos_hist (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid,
    plataforma_id uuid,
    simbolo character varying(20) NOT NULL,
    ganancia_deseada numeric(10,2) NOT NULL,
    precio_minimo_calculado numeric(10,4),
    cantidad_optima integer,
    comision_estimada numeric(10,2),
    ganancia_neta_estimada numeric(10,2),
    parametros_json jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE investment_tracker.calculos_hist OWNER TO investor;

--
-- Name: comisiones; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.comisiones (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    plataforma_id uuid,
    porcentaje numeric(5,4),
    valor_fijo numeric(10,2),
    descripcion character varying(200),
    fecha_inicio timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_fin timestamp without time zone,
    activo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_comision CHECK (((porcentaje IS NOT NULL) OR (valor_fijo IS NOT NULL)))
);


ALTER TABLE investment_tracker.comisiones OWNER TO investor;

--
-- Name: plataformas; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.plataformas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid,
    nombre character varying(100) NOT NULL,
    descripcion text,
    tipo character varying(50),
    activo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE investment_tracker.plataformas OWNER TO investor;

--
-- Name: roles; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE investment_tracker.roles OWNER TO investor;

--
-- Name: schema_version; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.schema_version (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version character varying(50) NOT NULL,
    descripcion text,
    script_name character varying(255) NOT NULL,
    ejecutado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ejecutado_por character varying(100) DEFAULT CURRENT_USER
);


ALTER TABLE investment_tracker.schema_version OWNER TO investor;

--
-- Name: transacciones; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.transacciones (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    usuario_id uuid,
    plataforma_id uuid,
    tipo character varying(10) NOT NULL,
    simbolo character varying(20) NOT NULL,
    empresa_nombre character varying(200),
    cantidad integer NOT NULL,
    precio_unitario numeric(10,4) NOT NULL,
    comision numeric(10,2) DEFAULT 0,
    valor_total numeric(10,2) NOT NULL,
    fecha_transaccion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notas text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT transacciones_cantidad_check CHECK ((cantidad > 0)),
    CONSTRAINT transacciones_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['COMPRA'::character varying, 'VENTA'::character varying])::text[])))
);


ALTER TABLE investment_tracker.transacciones OWNER TO investor;

--
-- Name: usuario_roles; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.usuario_roles (
    usuario_id uuid NOT NULL,
    rol_id uuid NOT NULL,
    asignado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE investment_tracker.usuario_roles OWNER TO investor;

--
-- Name: usuarios; Type: TABLE; Schema: investment_tracker; Owner: investor
--

CREATE TABLE investment_tracker.usuarios (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    nombre_completo character varying(200),
    activo boolean DEFAULT true,
    ultimo_login timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE investment_tracker.usuarios OWNER TO investor;

--
-- Data for Name: calculos_hist; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.calculos_hist (id, usuario_id, plataforma_id, simbolo, ganancia_deseada, precio_minimo_calculado, cantidad_optima, comision_estimada, ganancia_neta_estimada, parametros_json, created_at) FROM stdin;
\.


--
-- Data for Name: comisiones; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio, fecha_fin, activo, created_at) FROM stdin;
d0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a	f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c	0.0050	0.00	Comisión estándar eToro 0.5%	2024-01-01 00:00:00	\N	t	2026-07-10 17:03:27.137908
e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b	a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d	0.0010	1.00	Comisión IBKR Pro	2024-01-01 00:00:00	\N	t	2026-07-10 17:03:27.146504
f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c	b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e	0.0000	0.00	Sin comisiones	2024-01-01 00:00:00	\N	t	2026-07-10 17:03:27.154623
a3b4c5d6-e7f8-4a9b-0c1d-2e3f4a5b6c7d	c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f	0.0010	0.00	Comisión estándar Binance 0.1%	2024-01-01 00:00:00	\N	t	2026-07-10 17:03:27.162944
\.


--
-- Data for Name: plataformas; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, activo, created_at) FROM stdin;
f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	eToro	Plataforma de trading social y copy trading	broker	t	2026-07-10 17:03:27.104623
a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	Interactive Brokers	Broker profesional con acceso a mercados globales	broker	t	2026-07-10 17:03:27.112891
b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	Robinhood	App de trading sin comisiones	broker	t	2026-07-10 17:03:27.12126
c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	Binance	Exchange de criptomonedas	exchange	t	2026-07-10 17:03:27.129566
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.roles (id, nombre, descripcion, created_at) FROM stdin;
a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d	ROLE_ADMIN	Administrador del sistema con acceso total	2026-07-10 17:03:27.038229
b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e	ROLE_USER	Usuario regular con funcionalidades básicas	2026-07-10 17:03:27.054592
c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f	ROLE_PREMIUM	Usuario premium con acceso a calculadora avanzada	2026-07-10 17:03:27.0629
\.


--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.schema_version (id, version, descripcion, script_name, ejecutado_en, ejecutado_por) FROM stdin;
d4b07a3b-75d2-4276-8983-6f4a022f5698	2.0.0	Esquema con UUID	01_schema.sql	2026-07-10 17:03:26.954722	investor
982030c2-b133-4d3a-bbdc-d43a431c3d9b	2.0.0	Funciones con UUID	02_functions.sql	2026-07-10 17:03:27.021188	investor
\.


--
-- Data for Name: transacciones; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion, notas, created_at) FROM stdin;
b4c5d6e7-f8a9-4b0c-1d2e-3f4a5b6c7d8e	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c	COMPRA	AAPL	Apple Inc.	10	175.5000	8.78	1763.78	2024-01-15 10:30:00	\N	2026-07-10 17:03:27.171318
c5d6e7f8-a9b0-4c1d-2e3f-4a5b6c7d8e9f	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c	COMPRA	TSLA	Tesla Inc.	5	245.3000	6.13	1232.63	2024-02-01 11:00:00	\N	2026-07-10 17:03:27.179697
d6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d	COMPRA	GOOGL	Alphabet Inc.	3	140.5000	1.42	422.92	2024-03-01 09:45:00	\N	2026-07-10 17:03:27.188068
e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b	d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c	COMPRA	MSFT	Microsoft Corp.	8	380.7500	15.23	3061.23	2024-03-10 15:20:00	\N	2026-07-10 17:03:27.196354
\.


--
-- Data for Name: usuario_roles; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.usuario_roles (usuario_id, rol_id, asignado_en) FROM stdin;
d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e	2026-07-10 17:03:27.079583
e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b	a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d	2026-07-10 17:03:27.096255
e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b	b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e	2026-07-10 17:03:27.096255
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: investment_tracker; Owner: investor
--

COPY investment_tracker.usuarios (id, username, password_hash, email, nombre_completo, activo, ultimo_login, created_at, updated_at) FROM stdin;
d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a	demo_user	$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy	demo@investment-tracker.com	Usuario Demo	t	\N	2026-07-10 17:03:27.071195	2026-07-10 17:03:27.071195
e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b	admin	$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkf9RlFP0KxDsF3jkHNGOofQQUmSi	admin@investment-tracker.com	Administrador	t	\N	2026-07-10 17:03:27.087941	2026-07-10 17:03:27.087941
\.


--
-- Name: calculos_hist calculos_hist_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.calculos_hist
    ADD CONSTRAINT calculos_hist_pkey PRIMARY KEY (id);


--
-- Name: comisiones comisiones_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.comisiones
    ADD CONSTRAINT comisiones_pkey PRIMARY KEY (id);


--
-- Name: plataformas plataformas_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.plataformas
    ADD CONSTRAINT plataformas_pkey PRIMARY KEY (id);


--
-- Name: plataformas plataformas_usuario_id_nombre_key; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.plataformas
    ADD CONSTRAINT plataformas_usuario_id_nombre_key UNIQUE (usuario_id, nombre);


--
-- Name: roles roles_nombre_key; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.roles
    ADD CONSTRAINT roles_nombre_key UNIQUE (nombre);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.schema_version
    ADD CONSTRAINT schema_version_pkey PRIMARY KEY (id);


--
-- Name: transacciones transacciones_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.transacciones
    ADD CONSTRAINT transacciones_pkey PRIMARY KEY (id);


--
-- Name: schema_version uq_schema_version_script; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.schema_version
    ADD CONSTRAINT uq_schema_version_script UNIQUE (version, script_name);


--
-- Name: usuario_roles usuario_roles_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuario_roles
    ADD CONSTRAINT usuario_roles_pkey PRIMARY KEY (usuario_id, rol_id);


--
-- Name: usuarios usuarios_email_key; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- Name: idx_comisiones_activas; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_comisiones_activas ON investment_tracker.comisiones USING btree (plataforma_id, activo) WHERE (activo = true);


--
-- Name: idx_comisiones_fecha; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_comisiones_fecha ON investment_tracker.comisiones USING btree (fecha_inicio, fecha_fin);


--
-- Name: idx_comisiones_plataforma; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_comisiones_plataforma ON investment_tracker.comisiones USING btree (plataforma_id);


--
-- Name: idx_transacciones_fecha; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_transacciones_fecha ON investment_tracker.transacciones USING btree (fecha_transaccion);


--
-- Name: idx_transacciones_simbolo; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_transacciones_simbolo ON investment_tracker.transacciones USING btree (simbolo);


--
-- Name: idx_transacciones_tipo; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_transacciones_tipo ON investment_tracker.transacciones USING btree (tipo);


--
-- Name: idx_transacciones_usuario; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_transacciones_usuario ON investment_tracker.transacciones USING btree (usuario_id);


--
-- Name: idx_transacciones_usuario_simbolo; Type: INDEX; Schema: investment_tracker; Owner: investor
--

CREATE INDEX idx_transacciones_usuario_simbolo ON investment_tracker.transacciones USING btree (usuario_id, simbolo);


--
-- Name: calculos_hist calculos_hist_plataforma_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.calculos_hist
    ADD CONSTRAINT calculos_hist_plataforma_id_fkey FOREIGN KEY (plataforma_id) REFERENCES investment_tracker.plataformas(id);


--
-- Name: calculos_hist calculos_hist_usuario_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.calculos_hist
    ADD CONSTRAINT calculos_hist_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE;


--
-- Name: comisiones comisiones_plataforma_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.comisiones
    ADD CONSTRAINT comisiones_plataforma_id_fkey FOREIGN KEY (plataforma_id) REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE;


--
-- Name: plataformas plataformas_usuario_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.plataformas
    ADD CONSTRAINT plataformas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE;


--
-- Name: transacciones transacciones_plataforma_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.transacciones
    ADD CONSTRAINT transacciones_plataforma_id_fkey FOREIGN KEY (plataforma_id) REFERENCES investment_tracker.plataformas(id);


--
-- Name: transacciones transacciones_usuario_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.transacciones
    ADD CONSTRAINT transacciones_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE;


--
-- Name: usuario_roles usuario_roles_rol_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuario_roles
    ADD CONSTRAINT usuario_roles_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES investment_tracker.roles(id) ON DELETE CASCADE;


--
-- Name: usuario_roles usuario_roles_usuario_id_fkey; Type: FK CONSTRAINT; Schema: investment_tracker; Owner: investor
--

ALTER TABLE ONLY investment_tracker.usuario_roles
    ADD CONSTRAINT usuario_roles_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict TTO54JYkFetE6RKMvnTECvqDm5GmAzKXIybSmLbHb6RU43jdrhqnYZifH7Q71rG

