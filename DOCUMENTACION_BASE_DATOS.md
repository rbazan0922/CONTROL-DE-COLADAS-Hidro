# Documentación Base de Datos - Tablas y Origen de Datos

## BASCULANTE (pages/basculantes.html)

**Tablas relacionadas:**
- `coladas_basculante`: Almacena código, versión, fecha, colada, metal, arranque, temperatura, totales, W.O, artículo
- `basculante_componentes`: Almacena los componentes ingresados en la tabla COMPONENTES del formulario
- `basculante_adiciones`: Almacena las adiciones químicas ingresadas en la tabla ADICIONES del formulario
- `basculante_analisis_quimico`: Almacena el análisis de 13 elementos (Si, Zn, Fe, Pb, Sn, Mg, Al, Bi, P, Mn, S, Cu) de la tabla ANÁLISIS QUÍMICO
- `basculante_temperaturas`: Almacena horas y temperaturas ingresadas en la tabla TEMPERATURAS del formulario
- `basculante_firmas`: Almacena la firma digital cargada en el área de firma

**Cómo obtiene datos:** De los inputs del encabezado (código, versión, fecha), de las 5 tablas dinámicas que completa el usuario y de la imagen de firma.

---

## ELÉCTRICO (pages/electrico.html)

**Tablas relacionadas:**
- `coladas_electrico`: Almacena código, versión, fecha, colada, metal, arranque, temperatura, totales, W.O, artículo
- `electrico_componentes`: Almacena los componentes ingresados en la tabla COMPONENTES del formulario
- `electrico_analisis_quimico`: Almacena el análisis de 13 elementos de la tabla ANÁLISIS QUÍMICO
- `electrico_temperaturas`: Almacena horas y temperaturas ingresadas en la tabla TEMPERATURAS del formulario
- `electrico_firmas`: Almacena la firma digital cargada en el área de firma

**Cómo obtiene datos:** De los inputs del encabezado, de 3 tablas dinámicas (NO tiene tabla ADICIONES) y de la firma digital.

---

## CONTROL DE TEMPERATURAS (pages/ControlTermpe.html)

**Tablas relacionadas:**
- `control_temperaturas`: Almacena código, versión, fecha, fecha control, moldeo manual, modelo máquina
- `temp_analisis_quimico`: Almacena datos de la tabla ANÁLISIS con 9 columnas (callana, código, material, temperatura, cantidad, horas inicio/final, coladas)
- `temp_firmas`: Almacena la firma digital cargada en el área de firma

**Cómo obtiene datos:** De los inputs del encabezado y datos principales, de 1 tabla dinámica de análisis y de la firma digital.

---

## INFRAESTRUCTURA

- `usuarios`: Almacena usuarios (supervisor, hornero), email, contraseña, rol
- `auditoria_log`: Registra cada cambio (INSERT, UPDATE, DELETE) con usuario, tabla, acción, fecha
- `sesiones`: Controla sesiones activas de usuarios
- `configuracion_sistema`: Almacena configuraciones globales

**Cómo obtiene datos:** De login, cambios en documentos y autenticación de usuarios.

---

**Última actualización:** 3 de diciembre de 2025
