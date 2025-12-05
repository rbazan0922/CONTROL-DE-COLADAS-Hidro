-- ============================================================
-- GUÍA DE USO Y EJEMPLOS DE CONSULTAS SQL
-- CONTROL DE COLADAS - PostgreSQL
-- ============================================================

-- ============================================================
-- 1. CONSULTAS PARA OBTENER DATOS
-- ============================================================

-- Obtener todas las coladas basculante de un usuario específico
SELECT * FROM coladas_basculante 
WHERE usuario_id = 1 
ORDER BY fecha DESC;

-- Obtener colada específica con todos sus detalles
SELECT 
    cb.codigo,
    cb.fecha,
    u.username,
    cb.colada,
    cb.metal,
    cb.temperatura_sangrado,
    COUNT(DISTINCT bc.id) as total_componentes,
    COUNT(DISTINCT ba.id) as total_adiciones,
    COUNT(DISTINCT baq.id) as analisis_quimicos
FROM coladas_basculante cb
JOIN usuarios u ON cb.usuario_id = u.id
LEFT JOIN basculante_componentes bc ON cb.id = bc.colada_id
LEFT JOIN basculante_adiciones ba ON cb.id = ba.colada_id
LEFT JOIN basculante_analisis_quimico baq ON cb.id = baq.colada_id
WHERE cb.codigo = 'BASC-2025-001'
GROUP BY cb.id, u.username;

-- Obtener componentes de una colada específica
SELECT 
    codigo_componente,
    nombre_componente,
    cantidad_horno,
    cantidad_callana,
    (cantidad_horno + cantidad_callana) as total
FROM basculante_componentes
WHERE colada_id = 1
ORDER BY orden_fila;

-- Obtener análisis químico de una colada
SELECT 
    metal,
    si, zn, fe, pb, sn, mg, al, bi, p, mn, s, cu
FROM basculante_analisis_quimico
WHERE colada_id = 1;

-- Obtener todas las coladas sin firmar
SELECT 
    codigo,
    fecha,
    u.username,
    bf.firma_hornero IS NULL as sin_firma_hornero,
    bf.firma_supervisor IS NULL as sin_firma_supervisor
FROM coladas_basculante cb
JOIN usuarios u ON cb.usuario_id = u.id
LEFT JOIN basculante_firmas bf ON cb.id = bf.colada_id
WHERE bf.id IS NULL OR bf.firma_hornero IS NULL OR bf.firma_supervisor IS NULL;

-- ============================================================
-- 2. CONSULTAS PARA INSERTAR DATOS
-- ============================================================

-- Insertar nueva colada basculante
INSERT INTO coladas_basculante (
    codigo, version, fecha, usuario_id, rol_usuario,
    colada, metal, arranque, temperatura_sangrado,
    total_acumulado, nro_wo, nro_articulo
) VALUES (
    'BASC-2025-001', '1.0', '2025-12-03', 1, 'supervisor',
    'COLADA-2025-001', 'BRONCE', '09:00', 1150.50,
    '500', 'WO-12345', 'ART-67890'
);

-- Insertar componente a una colada
INSERT INTO basculante_componentes (
    colada_id, codigo_componente, nombre_componente,
    cantidad_horno, cantidad_callana, orden_fila
) VALUES (
    1, 'LHO2002', 'LIGA', 100.50, 50.25, 1
);

-- Insertar análisis químico
INSERT INTO basculante_analisis_quimico (
    colada_id, metal, si, zn, fe, pb, sn, mg, al, bi, p, mn, s, cu, orden_fila
) VALUES (
    1, 'BRONCE', 0.5, 0.2, 0.1, 0.05, 0.15, 0.01, 0.02, 0.001, 0.001, 0.01, 0.001, 98.5, 1
);

-- ============================================================
-- 3. CONSULTAS PARA ACTUALIZAR DATOS
-- ============================================================

-- Actualizar estado de colada a enviada
UPDATE coladas_basculante 
SET estado = 'enviado', updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- Actualizar temperatura de una colada
UPDATE coladas_basculante 
SET temperatura_sangrado = 1160.75
WHERE id = 1;

-- Cambiar rol de usuario
UPDATE usuarios 
SET rol = 'hornero'
WHERE username = 'newuser';

-- ============================================================
-- 4. CONSULTAS PARA ELIMINAR DATOS
-- ============================================================

-- Eliminar colada y todos sus registros relacionados (en cascada)
DELETE FROM coladas_basculante 
WHERE id = 1;

-- Eliminar un componente específico
DELETE FROM basculante_componentes 
WHERE id = 1;

-- ============================================================
-- 5. REPORTES Y ESTADÍSTICAS
-- ============================================================

-- Reporte: Total de coladas por usuario
SELECT 
    u.username,
    u.rol,
    COUNT(cb.id) as coladas_basculante,
    COUNT(ce.id) as coladas_electrico,
    COUNT(ct.id) as controls_temperatura
FROM usuarios u
LEFT JOIN coladas_basculante cb ON u.id = cb.usuario_id
LEFT JOIN coladas_electrico ce ON u.id = ce.usuario_id
LEFT JOIN control_temperaturas ct ON u.id = ct.usuario_id
GROUP BY u.id, u.username, u.rol
ORDER BY coladas_basculante DESC;

-- Reporte: Coladas por mes
SELECT 
    DATE_TRUNC('month', fecha)::DATE as mes,
    COUNT(*) as total_coladas,
    COUNT(CASE WHEN rol_usuario = 'supervisor' THEN 1 END) as supervisor,
    COUNT(CASE WHEN rol_usuario = 'hornero' THEN 1 END) as hornero
FROM coladas_basculante
GROUP BY DATE_TRUNC('month', fecha)
ORDER BY mes DESC;

-- Reporte: Estado de firmas pendientes
SELECT 
    cb.codigo,
    cb.fecha,
    u.username,
    CASE WHEN bf.firma_hornero IS NULL THEN 'Pendiente' ELSE 'Firmado' END as firma_hornero,
    CASE WHEN bf.firma_supervisor IS NULL THEN 'Pendiente' ELSE 'Firmado' END as firma_supervisor
FROM coladas_basculante cb
JOIN usuarios u ON cb.usuario_id = u.id
LEFT JOIN basculante_firmas bf ON cb.id = bf.colada_id
WHERE cb.estado = 'guardado'
ORDER BY cb.fecha DESC;

-- Reporte: Análisis químico promedio por metal
SELECT 
    metal,
    ROUND(AVG(si)::NUMERIC, 2) as promedio_si,
    ROUND(AVG(zn)::NUMERIC, 2) as promedio_zn,
    ROUND(AVG(fe)::NUMERIC, 2) as promedio_fe,
    ROUND(AVG(pb)::NUMERIC, 2) as promedio_pb,
    COUNT(*) as total_analisis
FROM basculante_analisis_quimico
GROUP BY metal
ORDER BY total_analisis DESC;

-- ============================================================
-- 6. CONSULTAS DE AUDITORÍA
-- ============================================================

-- Ver registro de cambios de un usuario
SELECT 
    tabla_afectada,
    accion,
    registro_id,
    created_at,
    datos_anterior,
    datos_nuevo
FROM auditoria_log
WHERE usuario_id = 1
ORDER BY created_at DESC
LIMIT 20;

-- Ver sesiones activas
SELECT 
    u.username,
    u.rol,
    s.login_at,
    s.logout_at,
    s.ip_address,
    CASE WHEN s.activa THEN 'Activa' ELSE 'Cerrada' END as estado
FROM sesiones s
JOIN usuarios u ON s.usuario_id = u.id
ORDER BY s.login_at DESC;

-- ============================================================
-- 7. CONSULTAS DE MANTENIMIENTO
-- ============================================================

-- Limpiar logs de auditoría antiguos (mayor a 90 días)
DELETE FROM auditoria_log
WHERE created_at < CURRENT_DATE - INTERVAL '90 days';

-- Cerrar sesiones inactivas
UPDATE sesiones 
SET activa = FALSE, logout_at = CURRENT_TIMESTAMP
WHERE activa = TRUE 
AND login_at < CURRENT_TIMESTAMP - INTERVAL '24 hours';

-- Obtener estadísticas de la base de datos
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamaño
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ============================================================
-- 8. CONSULTAS DE VALIDACIÓN
-- ============================================================

-- Verificar integridad de datos: códigos duplicados
SELECT codigo, COUNT(*) as cantidad
FROM (
    SELECT codigo FROM coladas_basculante
    UNION ALL
    SELECT codigo FROM coladas_electrico
    UNION ALL
    SELECT codigo FROM control_temperaturas
) t
GROUP BY codigo
HAVING COUNT(*) > 1;

-- Verificar usuarios sin coladas
SELECT u.username, u.rol
FROM usuarios u
LEFT JOIN coladas_basculante cb ON u.id = cb.usuario_id
LEFT JOIN coladas_electrico ce ON u.id = ce.usuario_id
WHERE cb.id IS NULL AND ce.id IS NULL;

-- Verificar firmas incompletas
SELECT 
    COUNT(*) as total_sin_firmar,
    SUM(CASE WHEN firma_hornero IS NULL THEN 1 ELSE 0 END) as sin_firma_hornero,
    SUM(CASE WHEN firma_supervisor IS NULL THEN 1 ELSE 0 END) as sin_firma_supervisor
FROM basculante_firmas;

-- ============================================================
-- 9. BÚSQUEDAS Y FILTROS
-- ============================================================

-- Buscar coladas por período de fechas
SELECT 
    codigo, fecha, metal, temperatura_sangrado
FROM coladas_basculante
WHERE fecha BETWEEN '2025-01-01' AND '2025-12-31'
AND estado = 'guardado'
ORDER BY fecha DESC;

-- Buscar coladas por metal
SELECT codigo, fecha, metal, temperatura_sangrado
FROM coladas_basculante
WHERE LOWER(metal) LIKE '%bronce%'
ORDER BY fecha DESC;

-- Búsqueda full-text (requiere columna tsvector)
SELECT 
    codigo, fecha, colada, metal
FROM coladas_basculante
WHERE codigo ILIKE '%BASC%'
OR metal ILIKE '%BRONCE%'
ORDER BY fecha DESC;

-- ============================================================
-- 10. FUNCIONES ÚTILES
-- ============================================================

-- Función para obtener resumen de colada
CREATE OR REPLACE FUNCTION fn_resumen_colada(p_colada_id INTEGER)
RETURNS TABLE (
    codigo VARCHAR,
    fecha DATE,
    usuario VARCHAR,
    total_componentes BIGINT,
    total_adiciones BIGINT,
    temperatura NUMERIC
) AS $$
SELECT 
    cb.codigo,
    cb.fecha,
    u.username,
    COUNT(DISTINCT bc.id),
    COUNT(DISTINCT ba.id),
    cb.temperatura_sangrado
FROM coladas_basculante cb
JOIN usuarios u ON cb.usuario_id = u.id
LEFT JOIN basculante_componentes bc ON cb.id = bc.colada_id
LEFT JOIN basculante_adiciones ba ON cb.id = ba.colada_id
WHERE cb.id = p_colada_id
GROUP BY cb.id, u.username;
$$ LANGUAGE SQL;

-- Usar la función
SELECT * FROM fn_resumen_colada(1);

-- ============================================================
-- NOTAS IMPORTANTES
-- ============================================================
/*
1. RESPALDOS: Realizar respaldos regulares
   pg_dump -U postgres control_coladas > backup.sql

2. RESTAURAR: Para restaurar desde un backup
   psql -U postgres control_coladas < backup.sql

3. USUARIOS: Cambiar contraseñas en producción
   UPDATE usuarios SET password = 'nueva_password' WHERE username = 'supervisor';

4. ÍNDICES: Se han creado índices para optimizar búsquedas
   - Verificar índices con: \di en psql

5. MONITOREO: 
   - Revisar logs: tail -f /var/log/postgresql/postgresql.log
   - Estadísticas: SELECT * FROM pg_stat_user_tables;

6. PERFORMANCE:
   - VACUUM ANALYZE regularmente
   - Monitorear tamaño de tablas
   - Revisar planes de ejecución con EXPLAIN

7. SEGURIDAD:
   - Usar SSL en producción
   - Implementar roles y permisos específicos
   - Auditar cambios con auditoria_log
*/
