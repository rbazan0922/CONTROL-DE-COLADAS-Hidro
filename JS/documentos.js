function getToken() {
    return localStorage.getItem('token');
}

function getRol() {
    return localStorage.getItem('rol');
}

function getUsuario() {
    const usuarioStr = localStorage.getItem('usuario');
    return usuarioStr ? JSON.parse(usuarioStr) : null;
}

async function guardarDocumento(tipo, datos) {
    const codigo = document.querySelector('.input-codigo')?.value?.trim();
    const version = document.querySelector('.input-version')?.value?.trim();

    if (!codigo) {
        mostrarBanner('⚠️ Por favor ingresa un CÓDIGO para guardar', false);
        return;
    }

    if (!version) {
        mostrarBanner('⚠️ Por favor ingresa una VERSIÓN', false);
        return;
    }

    try {
        const usuarioLogueado = localStorage.getItem('usuarioLogueado');
        const rol = localStorage.getItem('rol');

        if (!usuarioLogueado || !rol) {
            mostrarBanner('❌ No estás autenticado', false);
            return;
        }

        const dataGuardar = {
            codigo,
            version,
            fecha: document.querySelector('.input-fecha')?.value || new Date().toISOString().split('T')[0],
            usuario: usuarioLogueado,
            rol: rol,
            estado: 'guardado',
            ...datos
        };

        mostrarBanner(`✅ Documento guardado con código: ${codigo}`, true);

        setTimeout(() => {
            window.location.href = 'menuDocs.html';
        }, 2000);

    } catch (error) {
        console.error('Error:', error);
        mostrarBanner('❌ Error al guardar', false);
    }
}

function mostrarBanner(mensaje, esExito) {
    const banner = document.createElement('div');
    banner.textContent = mensaje;
    banner.style.cssText = `
        position: fixed;
        top: 15px;
        left: 50%;
        transform: translateX(-50%);
        background: ${esExito ? '#4caf50' : '#f44336'};
        color: white;
        padding: 14px 36px;
        border-radius: 50px;
        font-weight: bold;
        font-size: 16px;
        z-index: 9999;
        box-shadow: 0 6px 20px rgba(0,0,0,0.3);
        animation: bounce 1.5s ease-in-out;
    `;
    
    document.body.appendChild(banner);
    setTimeout(() => banner.remove(), 3000);
}

function inicializarDocumento(tipo) {
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('input[type="date"], .input-fecha').forEach(input => {
            if (!input.value) input.value = new Date().toISOString().split('T')[0];
        });

        if (getRol() === 'hornero') {
            document.querySelectorAll('input[type="file"]').forEach(input => {
                if (input.id.includes('supervisor')) {
                    const caja = input.closest('label');
                    if (caja) {
                        caja.style.pointerEvents = 'none';
                        caja.style.opacity = '0.4';
                        caja.style.background = '#ffebee';
                        caja.style.border = '2px dashed #c62828';
                        caja.innerHTML = `
                            <div style="text-align:center;color:#c62828;font-weight:bold;padding:20px;">
                                SOLO EL SUPERVISOR<br>PUEDE FIRMAR AQUÍ
                            </div>
                        `;
                    }
                }
            });
        }
    });
}
