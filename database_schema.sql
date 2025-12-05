-- ============================================================
-- SCRIPT DE BASE DE DATOS - CONTROL DE COLADAS
-- Motor: PostgreSQL
-- Descripción: Base de datos completa para el sistema de control de coladas
-- ============================================================

-- ============================================================
-- 1. CREAR EXTENSIONES NECESARIAS 
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- 2. TABLA DE USUARIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('supervisor', 'hornero')),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para búsquedas rápidas de usuarios
CREATE INDEX idx_usuarios_username ON usuarios(username);
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- ============================================================
-- 3. TABLA CONTROL COLADAS BASCULANTE
-- ============================================================
CREATE TABLE IF NOT EXISTS coladas_basculante (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version VARCHAR(20) NOT NULL,
    fecha DATE NOT NULL,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    rol_usuario VARCHAR(20) NOT NULL,
    
    -- DATOS GENERALES
    colada VARCHAR(100),
    metal VARCHAR(100),
    arranque TIME,
    temperatura_sangrado NUMERIC(8, 2),
    total_acumulado VARCHAR(100),
    nro_wo VARCHAR(100),
    nro_articulo VARCHAR(100),
    
    estado VARCHAR(20) DEFAULT 'guardado' CHECK (estado IN ('guardado', 'enviado')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para coladas_basculante
CREATE INDEX idx_coladas_basculante_codigo ON coladas_basculante(codigo);
CREATE INDEX idx_coladas_basculante_usuario ON coladas_basculante(usuario_id);
CREATE INDEX idx_coladas_basculante_fecha ON coladas_basculante(fecha);

-- ============================================================
-- 4. TABLA COMPONENTES BASCULANTE (detalle de la colada)
-- ============================================================
CREATE TABLE IF NOT EXISTS basculante_componentes (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_basculante(id) ON DELETE CASCADE,
    codigo_componente VARCHAR(50),
    nombre_componente VARCHAR(100),
    cantidad_horno NUMERIC(10, 2),
    cantidad_callana NUMERIC(10, 2),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_basculante_componentes_colada ON basculante_componentes(colada_id);

-- ============================================================
-- 5. TABLA ADICIONES BASCULANTE
-- ============================================================
CREATE TABLE IF NOT EXISTS basculante_adiciones (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_basculante(id) ON DELETE CASCADE,
    codigo_adicion VARCHAR(50),
    nombre_adicion VARCHAR(100),
    cantidad_callana NUMERIC(10, 2),
    cantidad_horno NUMERIC(10, 2),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_basculante_adiciones_colada ON basculante_adiciones(colada_id);

-- ============================================================
-- 6. TABLA ANÁLISIS QUÍMICO BASCULANTE
-- ============================================================
CREATE TABLE IF NOT EXISTS basculante_analisis_quimico (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_basculante(id) ON DELETE CASCADE,
    metal VARCHAR(50),
    si NUMERIC(8, 3),
    zn NUMERIC(8, 3),
    fe NUMERIC(8, 3),
    pb NUMERIC(8, 3),
    sn NUMERIC(8, 3),
    mg NUMERIC(8, 3),
    al NUMERIC(8, 3),
    bi NUMERIC(8, 3),
    p NUMERIC(8, 3),
    mn NUMERIC(8, 3),
    s NUMERIC(8, 3),
    cu NUMERIC(8, 3),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_basculante_analisis_quimico_colada ON basculante_analisis_quimico(colada_id);

-- ============================================================
-- 7. TABLA TEMPERATURA BASCULANTE
-- ============================================================
CREATE TABLE IF NOT EXISTS basculante_temperaturas (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_basculante(id) ON DELETE CASCADE,
    hora TIME,
    temperatura NUMERIC(8, 2),
    observaciones VARCHAR(500),
    notas_adicionales VARCHAR(500),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_basculante_temperaturas_colada ON basculante_temperaturas(colada_id);

-- ============================================================
-- 8. TABLA FIRMAS BASCULANTE
-- ============================================================
CREATE TABLE IF NOT EXISTS basculante_firmas (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL UNIQUE REFERENCES coladas_basculante(id) ON DELETE CASCADE,
    firma_hornero BYTEA,
    firma_supervisor BYTEA,
    signed_at TIMESTAMP
);

-- ============================================================
-- 9. TABLA CONTROL COLADAS ELÉCTRICO
-- ============================================================
CREATE TABLE IF NOT EXISTS coladas_electrico (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version VARCHAR(20) NOT NULL,
    fecha DATE NOT NULL,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    rol_usuario VARCHAR(20) NOT NULL,
    
    -- DATOS GENERALES
    colada VARCHAR(100),
    metal VARCHAR(100),
    arranque TIME,
    temperatura_sangrado NUMERIC(8, 2),
    total_acumulado VARCHAR(100),
    nro_wo VARCHAR(100),
    nro_articulo VARCHAR(100),
    
    estado VARCHAR(20) DEFAULT 'guardado' CHECK (estado IN ('guardado', 'enviado')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para coladas_electrico
CREATE INDEX idx_coladas_electrico_codigo ON coladas_electrico(codigo);
CREATE INDEX idx_coladas_electrico_usuario ON coladas_electrico(usuario_id);
CREATE INDEX idx_coladas_electrico_fecha ON coladas_electrico(fecha);

-- ============================================================
-- 10. TABLA COMPONENTES ELÉCTRICO
-- ============================================================
CREATE TABLE IF NOT EXISTS electrico_componentes (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_electrico(id) ON DELETE CASCADE,
    codigo_componente VARCHAR(50),
    nombre_componente VARCHAR(100),
    cantidad_horno NUMERIC(10, 2),
    cantidad_callana NUMERIC(10, 2),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_electrico_componentes_colada ON electrico_componentes(colada_id);

-- ============================================================
-- 11. TABLA ANÁLISIS QUÍMICO ELÉCTRICO
-- ============================================================
CREATE TABLE IF NOT EXISTS electrico_analisis_quimico (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_electrico(id) ON DELETE CASCADE,
    metal VARCHAR(50),
    si NUMERIC(8, 3),
    zn NUMERIC(8, 3),
    fe NUMERIC(8, 3),
    pb NUMERIC(8, 3),
    sn NUMERIC(8, 3),
    mg NUMERIC(8, 3),
    al NUMERIC(8, 3),
    bi NUMERIC(8, 3),
    p NUMERIC(8, 3),
    mn NUMERIC(8, 3),
    s NUMERIC(8, 3),
    cu NUMERIC(8, 3),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_electrico_analisis_quimico_colada ON electrico_analisis_quimico(colada_id);

-- ============================================================
-- 12. TABLA TEMPERATURAS ELÉCTRICO
-- ============================================================
CREATE TABLE IF NOT EXISTS electrico_temperaturas (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL REFERENCES coladas_electrico(id) ON DELETE CASCADE,
    metal VARCHAR(50),
    ino NUMERIC(8, 2),
    nod NUMERIC(8, 2),
    casi NUMERIC(8, 2),
    al NUMERIC(8, 2),
    s NUMERIC(8, 2),
    ca NUMERIC(8, 2),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_electrico_temperaturas_colada ON electrico_temperaturas(colada_id);

-- ============================================================
-- 13. TABLA FIRMAS ELÉCTRICO
-- ============================================================
CREATE TABLE IF NOT EXISTS electrico_firmas (
    id SERIAL PRIMARY KEY,
    colada_id INTEGER NOT NULL UNIQUE REFERENCES coladas_electrico(id) ON DELETE CASCADE,
    firma_hornero BYTEA,
    firma_supervisor BYTEA,
    signed_at TIMESTAMP
);

-- ============================================================
-- 14. TABLA CONTROL DE TEMPERATURAS
-- ============================================================
CREATE TABLE IF NOT EXISTS control_temperaturas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    version VARCHAR(20) NOT NULL,
    fecha DATE NOT NULL,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    rol_usuario VARCHAR(20) NOT NULL,
    
    -- DATOS GENERALES
    fecha_control DATE,
    moldeo_manual VARCHAR(100),
    modelo_maquina VARCHAR(100),
    
    estado VARCHAR(20) DEFAULT 'guardado' CHECK (estado IN ('guardado', 'enviado')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para control_temperaturas
CREATE INDEX idx_control_temperaturas_codigo ON control_temperaturas(codigo);
CREATE INDEX idx_control_temperaturas_usuario ON control_temperaturas(usuario_id);
CREATE INDEX idx_control_temperaturas_fecha ON control_temperaturas(fecha);

-- ============================================================
-- 15. TABLA ANÁLISIS QUÍMICO TEMPERATURAS
-- ============================================================
CREATE TABLE IF NOT EXISTS temp_analisis_quimico (
    id SERIAL PRIMARY KEY,
    control_id INTEGER NOT NULL REFERENCES control_temperaturas(id) ON DELETE CASCADE,
    nro_callana VARCHAR(50),
    codigo VARCHAR(50),
    material VARCHAR(100),
    temp NUMERIC(8, 2),
    cantidad NUMERIC(10, 2),
    hora_inicio TIME,
    hora_final TIME,
    nro_colada_1 VARCHAR(50),
    nro_colada_2 VARCHAR(50),
    orden_fila INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_temp_analisis_quimico_control ON temp_analisis_quimico(control_id);

-- ============================================================
-- 16. TABLA FIRMAS TEMPERATURAS
-- ============================================================
CREATE TABLE IF NOT EXISTS temp_firmas (
    id SERIAL PRIMARY KEY,
    control_id INTEGER NOT NULL UNIQUE REFERENCES control_temperaturas(id) ON DELETE CASCADE,
    firma_supervisor BYTEA,
    signed_at TIMESTAMP
);

-- ============================================================
-- 17. TABLA DE AUDITORÍA - LOG DE CAMBIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS auditoria_log (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    tabla_afectada VARCHAR(100) NOT NULL,
    registro_id INTEGER NOT NULL,
    accion VARCHAR(20) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE')),
    datos_anterior JSON,
    datos_nuevo JSON,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_auditoria_log_usuario ON auditoria_log(usuario_id);
CREATE INDEX idx_auditoria_log_tabla ON auditoria_log(tabla_afectada);
CREATE INDEX idx_auditoria_log_fecha ON auditoria_log(created_at);

-- ============================================================
-- 18. TABLA DE SESIONES
-- ============================================================
CREATE TABLE IF NOT EXISTS sesiones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_at TIMESTAMP,
    activa BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_sesiones_usuario ON sesiones(usuario_id);
CREATE INDEX idx_sesiones_token ON sesiones(token);
CREATE INDEX idx_sesiones_activa ON sesiones(activa);

-- ============================================================
-- 19. TABLA DE CONFIGURACIÓN DEL SISTEMA
-- ============================================================
CREATE TABLE IF NOT EXISTS configuracion_sistema (
    id SERIAL PRIMARY KEY,
    clave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    descripcion VARCHAR(500),
    tipo VARCHAR(20) DEFAULT 'string' CHECK (tipo IN ('string', 'integer', 'boolean', 'json')),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 20. DATOS INICIALES
-- ============================================================

-- Insertar usuarios por defecto
INSERT INTO usuarios (username, email, password, rol) 
VALUES 
    ('supervisor', 'supervisor@hidrostal.com', 'supervisor123', 'supervisor'),
    ('hornero', 'hornero@hidrostal.com', 'hornero123', 'hornero')
ON CONFLICT (username) DO NOTHING;

-- Insertar configuración por defecto
INSERT INTO configuracion_sistema (clave, valor, descripcion, tipo)
VALUES
    ('version_app', '1.0.0', 'Versión de la aplicación', 'string'),
    ('empresa_nombre', 'Hidrostal S.A.', 'Nombre de la empresa', 'string'),
    ('permite_editar_documentos', 'true', 'Permite editar documentos después de guardarlos', 'boolean'),
    ('dias_retencion_logs', '90', 'Días de retención de logs de auditoría', 'integer')
ON CONFLICT (clave) DO NOTHING;

-- ============================================================
-- 21. VISTAS ÚTILES PARA REPORTES
-- ============================================================

-- Vista: Resumen de coladas basculante por usuario
CREATE OR REPLACE VIEW v_resumen_basculante AS
SELECT 
    u.username,
    u.rol,
    COUNT(cb.id) as total_coladas,
    MIN(cb.fecha) as primera_colada,
    MAX(cb.fecha) as ultima_colada,
    COUNT(CASE WHEN cb.estado = 'guardado' THEN 1 END) as pendientes,
    COUNT(CASE WHEN cb.estado = 'enviado' THEN 1 END) as enviadas
FROM usuarios u
LEFT JOIN coladas_basculante cb ON u.id = cb.usuario_id
GROUP BY u.id, u.username, u.rol;

-- Vista: Resumen de coladas eléctrico por usuario
CREATE OR REPLACE VIEW v_resumen_electrico AS
SELECT 
    u.username,
    u.rol,
    COUNT(ce.id) as total_coladas,
    MIN(ce.fecha) as primera_colada,
    MAX(ce.fecha) as ultima_colada,
    COUNT(CASE WHEN ce.estado = 'guardado' THEN 1 END) as pendientes,
    COUNT(CASE WHEN ce.estado = 'enviado' THEN 1 END) as enviadas
FROM usuarios u
LEFT JOIN coladas_electrico ce ON u.id = ce.usuario_id
GROUP BY u.id, u.username, u.rol;

-- Vista: Actividad reciente
CREATE OR REPLACE VIEW v_actividad_reciente AS
SELECT 
    usuario_id,
    tabla_afectada,
    accion,
    created_at,
    COUNT(*) as cantidad
FROM auditoria_log
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY usuario_id, tabla_afectada, accion, created_at
ORDER BY created_at DESC;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
