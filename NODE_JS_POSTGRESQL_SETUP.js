// ============================================================
// EJEMPLO DE INTEGRACIÓN CON POSTGRESQL - NODE.JS/EXPRESS
// ============================================================

// Instalación de dependencias:
// npm install express pg cors dotenv bcryptjs jsonwebtoken

// ============================================================
// 1. ARCHIVO: config/database.js
// ============================================================

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'control_coladas',
  // Pool de conexiones
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Error en pool de conexiones:', err);
});

module.exports = pool;

// ============================================================
// 2. ARCHIVO: .env (Configuración)
// ============================================================

/*
DB_USER=postgres
DB_PASSWORD=tu_password_seguro
DB_HOST=localhost
DB_PORT=5432
DB_NAME=control_coladas
JWT_SECRET=tu_secreto_jwt
JWT_EXPIRE=24h
NODE_ENV=development
PORT=3000
*/

// ============================================================
// 3. ARCHIVO: routes/usuarios.js
// ============================================================

/*
const express = require('express');
const pool = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const router = express.Router();

// Login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const result = await pool.query(
      'SELECT id, username, email, rol, password FROM usuarios WHERE username = $1',
      [username.toLowerCase()]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    const usuario = result.rows[0];
    const passwordValida = await bcrypt.compare(password, usuario.password);

    if (!passwordValida) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    // Crear token JWT
    const token = jwt.sign(
      { id: usuario.id, username: usuario.username, rol: usuario.rol },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    // Registrar sesión
    await pool.query(
      'INSERT INTO sesiones (usuario_id, token, ip_address, user_agent, activa) VALUES ($1, $2, $3, $4, true)',
      [usuario.id, token, req.ip, req.get('user-agent')]
    );

    res.json({
      token,
      usuario: {
        id: usuario.id,
        username: usuario.username,
        email: usuario.email,
        rol: usuario.rol
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

// Obtener todos los usuarios
router.get('/', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, email, rol, activo, created_at FROM usuarios ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Crear usuario
router.post('/', async (req, res) => {
  try {
    const { username, email, password, rol } = req.body;

    // Validar
    if (!username || !email || !password || !rol) {
      return res.status(400).json({ error: 'Campos requeridos' });
    }

    // Hashear password
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await pool.query(
      'INSERT INTO usuarios (username, email, password, rol) VALUES ($1, $2, $3, $4) RETURNING id, username, email, rol',
      [username.toLowerCase(), email.toLowerCase(), hashedPassword, rol]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Actualizar usuario
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { email, rol } = req.body;

    const result = await pool.query(
      'UPDATE usuarios SET email = $1, rol = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      [email, rol, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Eliminar usuario
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM usuarios WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.json({ mensaje: 'Usuario eliminado' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
*/

// ============================================================
// 4. ARCHIVO: routes/coladas-basculante.js
// ============================================================

/*
const express = require('express');
const pool = require('../config/database');

const router = express.Router();

// Obtener todas las coladas basculante
router.get('/', async (req, res) => {
  try {
    const { usuario_id, estado } = req.query;
    let query = 'SELECT * FROM coladas_basculante WHERE 1=1';
    const params = [];

    if (usuario_id) {
      query += ' AND usuario_id = $' + (params.length + 1);
      params.push(usuario_id);
    }

    if (estado) {
      query += ' AND estado = $' + (params.length + 1);
      params.push(estado);
    }

    query += ' ORDER BY fecha DESC';

    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Obtener colada específica con detalles
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Obtener colada principal
    const coladaResult = await pool.query(
      'SELECT * FROM coladas_basculante WHERE id = $1',
      [id]
    );

    if (coladaResult.rows.length === 0) {
      return res.status(404).json({ error: 'Colada no encontrada' });
    }

    const colada = coladaResult.rows[0];

    // Obtener componentes
    const componentesResult = await pool.query(
      'SELECT * FROM basculante_componentes WHERE colada_id = $1 ORDER BY orden_fila',
      [id]
    );

    // Obtener adiciones
    const adicionesResult = await pool.query(
      'SELECT * FROM basculante_adiciones WHERE colada_id = $1 ORDER BY orden_fila',
      [id]
    );

    // Obtener análisis químico
    const analisisResult = await pool.query(
      'SELECT * FROM basculante_analisis_quimico WHERE colada_id = $1 ORDER BY orden_fila',
      [id]
    );

    // Obtener temperaturas
    const temperaturesResult = await pool.query(
      'SELECT * FROM basculante_temperaturas WHERE colada_id = $1 ORDER BY orden_fila',
      [id]
    );

    // Obtener firmas
    const firmasResult = await pool.query(
      'SELECT * FROM basculante_firmas WHERE colada_id = $1',
      [id]
    );

    res.json({
      colada,
      componentes: componentesResult.rows,
      adiciones: adicionesResult.rows,
      analisis_quimico: analisisResult.rows,
      temperaturas: temperaturesResult.rows,
      firmas: firmasResult.rows[0] || null
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Crear colada basculante
router.post('/', async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const {
      codigo, version, fecha, usuario_id, rol_usuario,
      colada, metal, arranque, temperatura_sangrado,
      total_acumulado, nro_wo, nro_articulo,
      componentes, adiciones, analisis_quimico, temperaturas
    } = req.body;

    // Insertar colada principal
    const coladaResult = await client.query(
      `INSERT INTO coladas_basculante 
       (codigo, version, fecha, usuario_id, rol_usuario, colada, metal, arranque, temperatura_sangrado, total_acumulado, nro_wo, nro_articulo)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       RETURNING id`,
      [codigo, version, fecha, usuario_id, rol_usuario, colada, metal, arranque, temperatura_sangrado, total_acumulado, nro_wo, nro_articulo]
    );

    const coladaId = coladaResult.rows[0].id;

    // Insertar componentes
    if (componentes && componentes.length > 0) {
      for (let i = 0; i < componentes.length; i++) {
        const c = componentes[i];
        await client.query(
          `INSERT INTO basculante_componentes (colada_id, codigo_componente, nombre_componente, cantidad_horno, cantidad_callana, orden_fila)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [coladaId, c.codigo_componente, c.nombre_componente, c.cantidad_horno, c.cantidad_callana, i]
        );
      }
    }

    // Insertar adiciones
    if (adiciones && adiciones.length > 0) {
      for (let i = 0; i < adiciones.length; i++) {
        const a = adiciones[i];
        await client.query(
          `INSERT INTO basculante_adiciones (colada_id, codigo_adicion, nombre_adicion, cantidad_callana, cantidad_horno, orden_fila)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [coladaId, a.codigo_adicion, a.nombre_adicion, a.cantidad_callana, a.cantidad_horno, i]
        );
      }
    }

    await client.query('COMMIT');
    res.status(201).json({ id: coladaId, mensaje: 'Colada creada' });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error(err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

// Actualizar colada
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { estado, temperatura_sangrado } = req.body;

    const result = await pool.query(
      'UPDATE coladas_basculante SET estado = $1, temperatura_sangrado = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      [estado, temperatura_sangrado, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Colada no encontrada' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Eliminar colada (con cascada)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM coladas_basculante WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Colada no encontrada' });
    }

    res.json({ mensaje: 'Colada eliminada' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
*/

// ============================================================
// 5. ARCHIVO: app.js (Servidor principal)
// ============================================================

/*
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
app.use('/api/usuarios', require('./routes/usuarios'));
app.use('/api/coladas-basculante', require('./routes/coladas-basculante'));
// Agregar más rutas según sea necesario

// Error handling
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});
*/

// ============================================================
// 6. ARCHIVO: package.json (Dependencias)
// ============================================================

/*
{
  "name": "control-coladas-api",
  "version": "1.0.0",
  "description": "API REST para Control de Coladas con PostgreSQL",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.10.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.5.0"
  }
}
*/

// ============================================================
// INSTRUCCIONES DE USO
// ============================================================

/*
1. INSTALAR DEPENDENCIAS
   npm install

2. CONFIGURAR .env
   Crear archivo .env con las variables de conexión

3. EJECUTAR SERVIDOR EN DESARROLLO
   npm run dev

4. ENDPOINTS DISPONIBLES

   USUARIOS:
   POST   /api/usuarios/login           - Login
   GET    /api/usuarios                 - Obtener todos
   POST   /api/usuarios                 - Crear usuario
   PUT    /api/usuarios/:id             - Actualizar usuario
   DELETE /api/usuarios/:id             - Eliminar usuario

   COLADAS BASCULANTE:
   GET    /api/coladas-basculante       - Obtener todas
   GET    /api/coladas-basculante/:id   - Obtener una
   POST   /api/coladas-basculante       - Crear
   PUT    /api/coladas-basculante/:id   - Actualizar
   DELETE /api/coladas-basculante/:id   - Eliminar

5. EJEMPLOS DE REQUEST

   LOGIN:
   POST http://localhost:3000/api/usuarios/login
   {
     "username": "supervisor",
     "password": "supervisor123"
   }

   CREAR COLADA:
   POST http://localhost:3000/api/coladas-basculante
   {
     "codigo": "BASC-2025-001",
     "version": "1.0",
     "fecha": "2025-12-03",
     "usuario_id": 1,
     "rol_usuario": "supervisor",
     "colada": "COLADA-001",
     "metal": "BRONCE",
     "temperatura_sangrado": 1150.50,
     "componentes": [
       {
         "codigo_componente": "LHO2002",
         "nombre_componente": "LIGA",
         "cantidad_horno": 100,
         "cantidad_callana": 50
       }
     ]
   }
*/

module.exports = {};
