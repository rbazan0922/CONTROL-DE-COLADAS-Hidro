/**
 * login.js
 * Autenticación local sin backend
 */

document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('loginForm');
    const userInput = document.getElementById('username');
    const passInput = document.getElementById('password');
    const submitBtn = document.getElementById('submitBtn');
    const errorMessage = document.getElementById('errorMessage');

    // Validación de entrada en username
    userInput.addEventListener('input', function () {
        this.value = this.value.replace(/[^a-zA-Z0-9]/g, '').toLowerCase();
    });

    // Enviar formulario
    form.addEventListener('submit', (e) => {
        e.preventDefault();

        const usuario = userInput.value.trim().toLowerCase();
        const clave = passInput.value;

        // Validaciones básicas
        if (!usuario || !clave) {
            mostrarError('Usuario y contraseña requeridos');
            return;
        }

        // Deshabilitar botón mientras se procesa
        submitBtn.disabled = true;
        submitBtn.textContent = 'Ingresando...';
        errorMessage.style.display = 'none';

        try {
            // Verificar credenciales localmente
            // Asegurar que las funciones existen
            if (typeof verificarCredenciales !== 'function') {
                console.error('verificarCredenciales no está definida');
                mostrarError('Error: Sistema no inicializado correctamente');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Ingresar';
                return;
            }

            const usuarioEncontrado = verificarCredenciales(usuario, clave);

            if (!usuarioEncontrado) {
                mostrarError('Usuario o contraseña incorrectos');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Ingresar';
                passInput.value = '';
                passInput.focus();
                return;
            }

            // Guardar sesión en localStorage
            localStorage.setItem('usuarioLogueado', usuarioEncontrado.username.toUpperCase());
            localStorage.setItem('rol', usuarioEncontrado.rol);
            localStorage.setItem('usuarioId', usuarioEncontrado.id);
            localStorage.setItem('usuarioEmail', usuarioEncontrado.email);

            // Redirigir al menú
            window.location.href = 'pages/menu.html';

        } catch (error) {
            console.error('Error:', error);
            mostrarError('Error en la autenticación');
            submitBtn.disabled = false;
            submitBtn.textContent = 'Ingresar';
        }
    });

    // Función para mostrar errores
    function mostrarError(mensaje) {
        errorMessage.textContent = mensaje;
        errorMessage.style.display = 'block';
    }

    // Si ya hay usuario logueado, redirigir a menú
    if (localStorage.getItem('usuarioLogueado')) {
        window.location.href = 'pages/menu.html';
    }
});
