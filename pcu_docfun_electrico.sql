CREATE DATABASE pcu_docfun;

-- Conectar a la base de datos `pcu_docfun` antes de ejecutar el resto (use psql: \c pcu_docfun)

-- Extensiones útiles
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Tabla: usuarios de la aplicación
CREATE TABLE IF NOT EXISTS pcu_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(200) NOT NULL,
    role VARCHAR(30) NOT NULL,
    full_name VARCHAR(200),
    email VARCHAR(200),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_pcu_users_username_lower ON pcu_users (LOWER(username));
CREATE INDEX IF NOT EXISTS idx_pcu_users_email ON pcu_users (email);

-- Tabla: electrico_documento
CREATE TABLE IF NOT EXISTS electrico_documento (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version INTEGER NOT NULL,
    fecha DATE NOT NULL,
    colada VARCHAR(50),
    metal VARCHAR(50),
    t_acumulada VARCHAR(50),
    kw_inicio VARCHAR(50),
    kw_fin VARCHAR(50),
    temperatura_sangrado VARCHAR(50),
    nro_wo VARCHAR(50),
    nro_articulo VARCHAR(50),
    componente_1 VARCHAR(100), horno_kg1_1 NUMERIC(12,3), horno_kg2_1 NUMERIC(12,3), horno_kg3_1 NUMERIC(12,3),
    componente_2 VARCHAR(100), horno_kg1_2 NUMERIC(12,3), horno_kg2_2 NUMERIC(12,3), horno_kg3_2 NUMERIC(12,3),
    componente_3 VARCHAR(100), horno_kg1_3 NUMERIC(12,3), horno_kg2_3 NUMERIC(12,3), horno_kg3_3 NUMERIC(12,3),
    componente_4 VARCHAR(100), horno_kg1_4 NUMERIC(12,3), horno_kg2_4 NUMERIC(12,3), horno_kg3_4 NUMERIC(12,3),
    componente_5 VARCHAR(100), horno_kg1_5 NUMERIC(12,3), horno_kg2_5 NUMERIC(12,3), horno_kg3_5 NUMERIC(12,3),
    componente_6 VARCHAR(100), horno_kg1_6 NUMERIC(12,3), horno_kg2_6 NUMERIC(12,3), horno_kg3_6 NUMERIC(12,3),
    componente_7 VARCHAR(100), horno_kg1_7 NUMERIC(12,3), horno_kg2_7 NUMERIC(12,3), horno_kg3_7 NUMERIC(12,3),
    componente_8 VARCHAR(100), horno_kg1_8 NUMERIC(12,3), horno_kg2_8 NUMERIC(12,3), horno_kg3_8 NUMERIC(12,3),
    componente_9 VARCHAR(100), horno_kg1_9 NUMERIC(12,3), horno_kg2_9 NUMERIC(12,3), horno_kg3_9 NUMERIC(12,3),
    componente_10 VARCHAR(100), horno_kg1_10 NUMERIC(12,3), horno_kg2_10 NUMERIC(12,3), horno_kg3_10 NUMERIC(12,3),
    analisis_metal VARCHAR(50),
    analisis_c NUMERIC(8,4), analisis_si NUMERIC(8,4), analisis_mn NUMERIC(8,4), analisis_p NUMERIC(8,4),
    analisis_s NUMERIC(8,4), analisis_cr NUMERIC(8,4), analisis_ni NUMERIC(8,4), analisis_mo NUMERIC(8,4),
    analisis_mg NUMERIC(8,4), analisis_nb NUMERIC(8,4), analisis_n NUMERIC(8,4), analisis_cu NUMERIC(8,4), analisis_al NUMERIC(8,4),
    temp_metal VARCHAR(50), temp_ino NUMERIC(8,2), temp_nod NUMERIC(8,2), temp_casi NUMERIC(8,2), temp_al NUMERIC(8,2), temp_se NUMERIC(8,2), temp_observaciones VARCHAR(255),
    tiempo_fusion_inicio TIMESTAMP, tiempo_fusion_final TIMESTAMP, tiempo_sangrado_inicio TIMESTAMP, tiempo_sangrado_final TIMESTAMP, tiempo_lingoteo_kg NUMERIC(12,3),
    observaciones TEXT,
    firma_hornero_mime VARCHAR(100), firma_hornero_file VARCHAR(200), firma_hornero_path VARCHAR(400),
    firma_supervisor_mime VARCHAR(100), firma_supervisor_file VARCHAR(200), firma_supervisor_path VARCHAR(400),
    -- Segunda firma del supervisor (por ejemplo firma lateral/validación)
    firma_supervisor2_mime VARCHAR(100), firma_supervisor2_file VARCHAR(200), firma_supervisor2_path VARCHAR(400),
    creado_por_usuario VARCHAR(50), creado_rol_usuario VARCHAR(20) CHECK (creado_rol_usuario IN ('supervisor','hornero')),
    creado_en TIMESTAMP NOT NULL DEFAULT NOW(),
    search_tsv tsvector
);
CREATE INDEX IF NOT EXISTS idx_electrico_codigo ON electrico_documento (codigo);
CREATE INDEX IF NOT EXISTS idx_electrico_fecha ON electrico_documento (fecha);
CREATE INDEX IF NOT EXISTS idx_electrico_search_tsv ON electrico_documento USING GIN (search_tsv);

-- Tabla: control_temperatura_documento
CREATE TABLE IF NOT EXISTS control_temperatura_documento (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version INTEGER NOT NULL,
    fecha DATE NOT NULL,
    datos_fecha VARCHAR(50), moldeo_manual VARCHAR(100), modelo_maquina VARCHAR(100),
    analisis_callana_1 VARCHAR(50), analisis_codigo_1 VARCHAR(50), analisis_material_1 VARCHAR(100),
    analisis_temp_1 NUMERIC(8,2), analisis_cantidad_1 NUMERIC(12,3), analisis_hora_ini_1 TIME, analisis_hora_fin_1 TIME,
    analisis_ncolada_1a VARCHAR(50), analisis_ncolada_1b VARCHAR(50),
    firma_supervisor_lateral_mime VARCHAR(100), firma_supervisor_lateral_file VARCHAR(200), firma_supervisor_lateral_path VARCHAR(400),
    -- Firma del hornero (única)
    firma_hornero_mime VARCHAR(100), firma_hornero_file VARCHAR(200), firma_hornero_path VARCHAR(400),
    creado_por_usuario VARCHAR(50), creado_rol_usuario VARCHAR(20) CHECK (creado_rol_usuario IN ('supervisor','hornero')),
    creado_en TIMESTAMP NOT NULL DEFAULT NOW(),
    search_tsv tsvector
);
CREATE INDEX IF NOT EXISTS idx_tempcontrol_codigo ON control_temperatura_documento (codigo);
CREATE INDEX IF NOT EXISTS idx_tempcontrol_fecha ON control_temperatura_documento (fecha);
CREATE INDEX IF NOT EXISTS idx_tempcontrol_search_tsv ON control_temperatura_documento USING GIN (search_tsv);

-- Tabla: basculante_documento
CREATE TABLE IF NOT EXISTS basculante_documento (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version INTEGER NOT NULL,
    fecha DATE NOT NULL,
    colada VARCHAR(50), metal VARCHAR(50), arranque TIME, temperatura_sangrado NUMERIC(8,2), total_acumulado VARCHAR(50), nro_wo VARCHAR(50), nro_articulo VARCHAR(50),
    comp_codigo_1 VARCHAR(50), comp_nombre_1 VARCHAR(100), horno1_1 NUMERIC(12,3), horno2_1 NUMERIC(12,3), carga_fria_kg NUMERIC(12,3),
    adic_codigo_1 VARCHAR(50), adic_nombre_1 VARCHAR(100), callana1_1 NUMERIC(12,3), callana2_1 NUMERIC(12,3),
    b_analisis_metal VARCHAR(50), b_analisis_si NUMERIC(8,4), b_analisis_zn NUMERIC(8,4), b_analisis_fe NUMERIC(8,4), b_analisis_pb NUMERIC(8,4), b_analisis_sn NUMERIC(8,4),
    b_analisis_mg NUMERIC(8,4), b_analisis_al NUMERIC(8,4), b_analisis_bi NUMERIC(8,4), b_analisis_p NUMERIC(8,4), b_analisis_mn NUMERIC(8,4), b_analisis_s NUMERIC(8,4), b_analisis_cu NUMERIC(8,4),
    temp_hora_1 TIME, temp_temp_1 NUMERIC(8,2), temp_piezas_1 VARCHAR(50), temp_descripcion_1 VARCHAR(200),
    b_tiempo_fusion_inicio TIME, b_tiempo_fusion_final TIME, b_tiempo_sangr_inicio TIME, b_tiempo_sangr_final TIME, b_lingoteo_kg NUMERIC(12,3),
    b_observaciones TEXT,
    b_firma_hornero_mime VARCHAR(100), b_firma_hornero_file VARCHAR(200), b_firma_hornero_path VARCHAR(400),
    b_firma_supervisor_mime VARCHAR(100), b_firma_supervisor_file VARCHAR(200), b_firma_supervisor_path VARCHAR(400),
    -- Segunda firma del supervisor en basculante
    b_firma_supervisor2_mime VARCHAR(100), b_firma_supervisor2_file VARCHAR(200), b_firma_supervisor2_path VARCHAR(400),
    b_creado_por_usuario VARCHAR(50), b_creado_rol_usuario VARCHAR(20) CHECK (b_creado_rol_usuario IN ('supervisor','hornero')),
    b_creado_en TIMESTAMP NOT NULL DEFAULT NOW(),
    search_tsv tsvector
);
CREATE INDEX IF NOT EXISTS idx_basculante_codigo ON basculante_documento (codigo);
CREATE INDEX IF NOT EXISTS idx_basculante_fecha ON basculante_documento (fecha);
CREATE INDEX IF NOT EXISTS idx_basculante_search_tsv ON basculante_documento USING GIN (search_tsv);

-- Catálogos
CREATE TABLE IF NOT EXISTS basc_componentes_catalog (codigo VARCHAR(50) PRIMARY KEY, nombre VARCHAR(100) NOT NULL, activo BOOLEAN NOT NULL DEFAULT TRUE);
CREATE INDEX IF NOT EXISTS idx_basc_comp_nombre ON basc_componentes_catalog (nombre);
CREATE TABLE IF NOT EXISTS basc_adiciones_catalog (codigo VARCHAR(50) PRIMARY KEY, nombre VARCHAR(100) NOT NULL, activo BOOLEAN NOT NULL DEFAULT TRUE);
CREATE INDEX IF NOT EXISTS idx_basc_adic_nombre ON basc_adiciones_catalog (nombre);

-- Funciones para agregar slots (mantener funcionalidad existente)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'pcu_add_next_componente_slot') THEN
        CREATE OR REPLACE FUNCTION pcu_add_next_componente_slot(max_slots INTEGER DEFAULT 50)
        RETURNS TEXT AS $$
        DECLARE n INTEGER := 0; col TEXT; ddl TEXT; BEGIN
            FOR n IN REVERSE 1..max_slots LOOP
                col := format('componente_%s', n);
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'electrico_documento' AND column_name = col) THEN EXIT; END IF;
            END LOOP;
            IF n = max_slots THEN RETURN format('No se pueden crear más slots: límite %s', max_slots); END IF;
            n := n + 1;
            ddl := format($f$ALTER TABLE electrico_documento ADD COLUMN IF NOT EXISTS componente_%1$s VARCHAR(100), ADD COLUMN IF NOT EXISTS horno_kg1_%1$s NUMERIC(12,3), ADD COLUMN IF NOT EXISTS horno_kg2_%1$s NUMERIC(12,3), ADD COLUMN IF NOT EXISTS horno_kg3_%1$s NUMERIC(12,3);$f$, n);
            EXECUTE ddl; RETURN format('Creado slot componente_%s y horno_kg1/2/3_%s', n, n);
        END; $$ LANGUAGE plpgsql;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'pcu_temp_add_next_analisis_slot') THEN
        CREATE OR REPLACE FUNCTION pcu_temp_add_next_analisis_slot(max_slots INTEGER DEFAULT 500)
        RETURNS TEXT AS $$
        DECLARE n INTEGER := 0; col TEXT; ddl TEXT; BEGIN
            FOR n IN REVERSE 1..max_slots LOOP
                col := format('analisis_callana_%s', n);
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'control_temperatura_documento' AND column_name = col) THEN EXIT; END IF;
            END LOOP;
            IF n = max_slots THEN RETURN format('Límite de slots de análisis alcanzado: %s', max_slots); END IF;
            n := n + 1;
            ddl := format($f$ALTER TABLE control_temperatura_documento ADD COLUMN IF NOT EXISTS analisis_callana_%1$s VARCHAR(50), ADD COLUMN IF NOT EXISTS analisis_codigo_%1$s VARCHAR(50), ADD COLUMN IF NOT EXISTS analisis_material_%1$s VARCHAR(100), ADD COLUMN IF NOT EXISTS analisis_temp_%1$s NUMERIC(8,2), ADD COLUMN IF NOT EXISTS analisis_cantidad_%1$s NUMERIC(12,3), ADD COLUMN IF NOT EXISTS analisis_hora_ini_%1$s TIME, ADD COLUMN IF NOT EXISTS analisis_hora_fin_%1$s TIME, ADD COLUMN IF NOT EXISTS analisis_ncolada_%1$sa VARCHAR(50), ADD COLUMN IF NOT EXISTS analisis_ncolada_%1$sb VARCHAR(50);$f$, n);
            EXECUTE ddl; RETURN format('Creado slot analisis %s', n);
        END; $$ LANGUAGE plpgsql;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'pcu_basc_add_next_componente_slot') THEN
        CREATE OR REPLACE FUNCTION pcu_basc_add_next_componente_slot(max_slots INTEGER DEFAULT 100)
        RETURNS TEXT AS $$
        DECLARE n INTEGER := 0; col TEXT; ddl TEXT; BEGIN
            FOR n IN REVERSE 1..max_slots LOOP
                col := format('comp_codigo_%s', n);
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'basculante_documento' AND column_name = col) THEN EXIT; END IF;
            END LOOP;
            IF n = max_slots THEN RETURN format('Límite de slots componentes alcanzado: %s', max_slots); END IF;
            n := n + 1;
            ddl := format($f$ALTER TABLE basculante_documento ADD COLUMN IF NOT EXISTS comp_codigo_%1$s VARCHAR(50), ADD COLUMN IF NOT EXISTS comp_nombre_%1$s VARCHAR(100), ADD COLUMN IF NOT EXISTS horno1_%1$s NUMERIC(12,3), ADD COLUMN IF NOT EXISTS horno2_%1$s NUMERIC(12,3);$f$, n);
            EXECUTE ddl; RETURN format('Creado comp_codigo_%s, comp_nombre_%s, horno1_%s, horno2_%s', n, n, n, n);
        END; $$ LANGUAGE plpgsql;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'pcu_basc_add_next_adicion_slot') THEN
        CREATE OR REPLACE FUNCTION pcu_basc_add_next_adicion_slot(max_slots INTEGER DEFAULT 100)
        RETURNS TEXT AS $$
        DECLARE n INTEGER := 0; col TEXT; ddl TEXT; BEGIN
            FOR n IN REVERSE 1..max_slots LOOP
                col := format('adic_codigo_%s', n);
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'basculante_documento' AND column_name = col) THEN EXIT; END IF;
            END LOOP;
            IF n = max_slots THEN RETURN format('Límite de slots adiciones alcanzado: %s', max_slots); END IF;
            n := n + 1;
            ddl := format($f$ALTER TABLE basculante_documento ADD COLUMN IF NOT EXISTS adic_codigo_%1$s VARCHAR(50), ADD COLUMN IF NOT EXISTS adic_nombre_%1$s VARCHAR(100), ADD COLUMN IF NOT EXISTS callana1_%1$s NUMERIC(12,3), ADD COLUMN IF NOT EXISTS callana2_%1$s NUMERIC(12,3);$f$, n);
            EXECUTE ddl; RETURN format('Creado adic_codigo_%s, adic_nombre_%s, callana1_%s, callana2_%s', n, n, n, n);
        END; $$ LANGUAGE plpgsql;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'pcu_basc_add_next_temperatura_slot') THEN
        CREATE OR REPLACE FUNCTION pcu_basc_add_next_temperatura_slot(max_slots INTEGER DEFAULT 200)
        RETURNS TEXT AS $$
        DECLARE n INTEGER := 0; col TEXT; ddl TEXT; BEGIN
            FOR n IN REVERSE 1..max_slots LOOP
                col := format('temp_hora_%s', n);
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'basculante_documento' AND column_name = col) THEN EXIT; END IF;
            END LOOP;
            IF n = max_slots THEN RETURN format('Límite de filas de temperatura alcanzado: %s', max_slots); END IF;
            n := n + 1;
            ddl := format($f$ALTER TABLE basculante_documento ADD COLUMN IF NOT EXISTS temp_hora_%1$s TIME, ADD COLUMN IF NOT EXISTS temp_temp_%1$s NUMERIC(8,2), ADD COLUMN IF NOT EXISTS temp_piezas_%1$s VARCHAR(50), ADD COLUMN IF NOT EXISTS temp_descripcion_%1$s VARCHAR(200);$f$, n);
            EXECUTE ddl; RETURN format('Creado temp_hora_%s, temp_temp_%s, temp_piezas_%s, temp_descripcion_%s', n, n, n, n);
        END; $$ LANGUAGE plpgsql;
    END IF;
END $$;

-- Trigger que actualiza el tsvector de búsqueda usando la representación JSON de la fila
CREATE OR REPLACE FUNCTION pcu_update_search_tsv_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_tsv := to_tsvector('spanish', coalesce(row_to_json(NEW)::text, ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Asociar trigger a tablas con columna search_tsv
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='electrico_documento' AND column_name='search_tsv') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_electrico_search_tsv') THEN
            CREATE TRIGGER trg_electrico_search_tsv BEFORE INSERT OR UPDATE ON electrico_documento FOR EACH ROW EXECUTE FUNCTION pcu_update_search_tsv_trigger();
        END IF;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='basculante_documento' AND column_name='search_tsv') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_basculante_search_tsv') THEN
            CREATE TRIGGER trg_basculante_search_tsv BEFORE INSERT OR UPDATE ON basculante_documento FOR EACH ROW EXECUTE FUNCTION pcu_update_search_tsv_trigger();
        END IF;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='control_temperatura_documento' AND column_name='search_tsv') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_tempcontrol_search_tsv') THEN
            CREATE TRIGGER trg_tempcontrol_search_tsv BEFORE INSERT OR UPDATE ON control_temperatura_documento FOR EACH ROW EXECUTE FUNCTION pcu_update_search_tsv_trigger();
        END IF;
    END IF;
END $$;

-- Función de búsqueda unificada
CREATE OR REPLACE FUNCTION pcu_search_documents(q TEXT, lim INT DEFAULT 50)
RETURNS TABLE(table_name TEXT, id INT, codigo TEXT, rank FLOAT, snippet TEXT) AS $$
DECLARE qry TSQUERY := plainto_tsquery('spanish', q);
BEGIN
    RETURN QUERY
    SELECT 'electrico'::text, id, codigo, ts_rank(search_tsv, qry), ts_headline('spanish', coalesce(row_to_json(electrico_documento)::text,''), qry)
    FROM electrico_documento WHERE search_tsv @@ qry
    UNION ALL
    SELECT 'basculante'::text, id, codigo, ts_rank(search_tsv, qry), ts_headline('spanish', coalesce(row_to_json(basculante_documento)::text,''), qry)
    FROM basculante_documento WHERE search_tsv @@ qry
    UNION ALL
    SELECT 'control_temperatura'::text, id, codigo, ts_rank(search_tsv, qry), ts_headline('spanish', coalesce(row_to_json(control_temperatura_documento)::text,''), qry)
    FROM control_temperatura_documento WHERE search_tsv @@ qry
    ORDER BY rank DESC LIMIT lim;
END; $$ LANGUAGE plpgsql;

-- Índices adicionales para búsquedas por texto y trigram (mejoran LIKE y búsquedas parciales)
CREATE INDEX IF NOT EXISTS idx_electrico_codigo_trgm ON electrico_documento USING gin (codigo gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_basculante_codigo_trgm ON basculante_documento USING gin (codigo gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_tempcontrol_codigo_trgm ON control_temperatura_documento USING gin (codigo gin_trgm_ops);

