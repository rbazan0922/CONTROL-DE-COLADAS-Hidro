/**
 * usuarios.js
 * Gestión de usuarios local sin backend
 */

let usuarioEditar = null;

/**
 * Cargar lista de usuarios desde localStorage
 */
function cargarUsuarios() {
    try {
        const usuarios = obtenerTodosUsuarios();
        mostrarUsuarios(usuarios);
        document.getElementById('contadorUsuarios').textContent = `Total: ${usuarios.length} usuario(s)`;

    } catch (error) {
        console.error('Error:', error);
        mostrarError('Error al cargar usuarios');
    }
}

/**
 * Mostrar usuarios en la tabla
 */
function mostrarUsuarios(usuarios) {
    const tbody = document.getElementById('cuerpoTabla');
    
    if (usuarios.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px; color: #999;">No hay usuarios</td></tr>';
        return;
    }

    const usuario_actual = parseInt(localStorage.getItem('usuarioId'));

    tbody.innerHTML = usuarios.map(usuario => {
        const fecha = new Date(usuario.createdAt || new Date()).toLocaleDateString('es-ES');
        const rolColor = usuario.rol === 'supervisor' ? '#5C7C99' : '#7A8C9E';
        const rolTexto = usuario.rol === 'supervisor' ? 'Supervisor' : 'Hornero';
        
        return `
            <tr style="border-bottom: 1px solid #ddd;">
                <td style="padding: 12px; border: 1px solid #ddd;">${usuario.username}</td>
                <td style="padding: 12px; border: 1px solid #ddd;">${usuario.email}</td>
                <td style="padding: 12px; text-align: center; border: 1px solid #ddd;">
                    <span style="background-color: ${rolColor}; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px;">
                        ${rolTexto}
                    </span>
                </td>
                <td style="padding: 12px; text-align: center; border: 1px solid #ddd;">${fecha}</td>
                <td style="padding: 12px; text-align: center; border: 1px solid #ddd;">
                    <div style="display: flex; gap: 5px; justify-content: center;">
                        <button onclick="abrirModalCambiarRol(${usuario.id}, '${usuario.username}')" class="btn-menu" style="background-color: #1F4E6C; color: white; padding: 5px 10px; font-size: 12px; cursor: pointer; border: none; border-radius: 3px;">
                            Cambiar Rol
                        </button>
                        ${usuario.id !== usuario_actual ? `
                            <button onclick="eliminarUsuarioFunc(${usuario.id}, '${usuario.username}')" class="btn-menu" style="background-color: #1F4E6C; color: white; padding: 5px 10px; font-size: 12px; cursor: pointer; border: none; border-radius: 3px;">
                                Eliminar
                            </button>
                        ` : ''}
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

/**
 * Crear nuevo usuario
 */
function crearNuevoUsuario() {
    const username = document.getElementById('nuevoUsername').value.trim().toLowerCase();
    const email = document.getElementById('nuevoEmail').value.trim().toLowerCase();
    const password = document.getElementById('nuevoPassword').value;
    const rol = document.getElementById('nuevoRol').value;

    // Validaciones
    if (!username || !email || !password || !rol) {
        mostrarMensajeCrear('Por favor completa todos los campos', 'error');
        return;
    }

    if (password.length < 4) {
        mostrarMensajeCrear('La contraseña debe tener al menos 4 caracteres', 'error');
        return;
    }

    try {
        crearUsuario(username, email, password, rol);
        mostrarMensajeCrear('✓ Usuario creado exitosamente', 'success');
        
        // Limpiar formulario
        document.getElementById('nuevoUsername').value = '';
        document.getElementById('nuevoEmail').value = '';
        document.getElementById('nuevoPassword').value = '';
        document.getElementById('nuevoRol').value = '';

        // Recargar lista
        setTimeout(() => cargarUsuarios(), 1500);

    } catch (error) {
        mostrarMensajeCrear(error.message, 'error');
    }
}

/**
 * Abrir modal para cambiar rol
 */
function abrirModalCambiarRol(usuarioId, usuarioNombre) {
    usuarioEditar = usuarioId;
    document.getElementById('modalUsuario').textContent = `Usuario: ${usuarioNombre}`;
    document.getElementById('nuevoRolModal').value = '';
    document.getElementById('modalCambiarRol').style.display = 'flex';
}

/**
 * Cerrar modal
 */
function cerrarModal() {
    document.getElementById('modalCambiarRol').style.display = 'none';
    usuarioEditar = null;
}

/**
 * Confirmar cambio de rol
 */
function confirmarCambiarRol() {
    const nuevoRol = document.getElementById('nuevoRolModal').value;

    if (!nuevoRol) {
        alert('Por favor selecciona un rol');
        return;
    }

    try {
        cambiarRolUsuario(usuarioEditar, nuevoRol);
        alert('✓ Rol cambiado exitosamente');
        cerrarModal();
        cargarUsuarios();

    } catch (error) {
        alert(error.message);
    }
}

/**
 * Eliminar usuario
 */
function eliminarUsuarioFunc(usuarioId, usuarioNombre) {
    if (!confirm(`¿Estás seguro de que quieres eliminar a ${usuarioNombre}?`)) {
        return;
    }

    try {
        eliminarUsuario(usuarioId);
        alert('✓ Usuario eliminado exitosamente');
        cargarUsuarios();

    } catch (error) {
        mostrarError(error.message);
    }
}

/**
 * Mostrar mensaje en sección crear
 */
function mostrarMensajeCrear(mensaje, tipo) {
    const div = document.getElementById('mensajeCrear');
    div.textContent = mensaje;
    div.style.display = 'block';
    div.style.backgroundColor = tipo === 'success' ? '#e8f5e9' : '#ffebee';
    div.style.color = tipo === 'success' ? '#2e7d32' : '#c62828';
    div.style.borderLeft = `4px solid ${tipo === 'success' ? '#4caf50' : '#f44336'}`;
}

/**
 * Mostrar error
 */
function mostrarError(mensaje) {
    const div = document.getElementById('mensajeError');
    div.textContent = mensaje;
    div.style.display = 'block';
}

// Cargar usuarios al abrir la página
document.addEventListener('DOMContentLoaded', () => {
    // Verificar que el usuario sea supervisor
    const rol = localStorage.getItem('rol');
    if (rol !== 'supervisor') {
        alert('No tienes permiso para acceder a esta página');
        window.location.href = 'menu.html';
        return;
    }

    cargarUsuarios();
});
