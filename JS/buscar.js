/**
 * buscar.js
 * Búsqueda de documentos locales (usando localStorage con datos de demo)
 */

let documentosActuales = [];
let paginaActual = 1;
const DOCUMENTOS_POR_PAGINA = 10;
let tipoDocumentoActual = '';
let codigoActual = '';

// Documentos de demo (se guardarían en localStorage)
const DOCUMENTOS_DEMO = {
    basculantes: [
        { id: 1, codigo: 'BASC-2025-001', version: '1.0', fecha: new Date(2025, 0, 10), usuario_id: 1, estado: 'guardado' },
        { id: 2, codigo: 'BASC-2025-002', version: '1.0', fecha: new Date(2025, 0, 11), usuario_id: 2, estado: 'guardado' },
        { id: 3, codigo: 'BASC-2025-003', version: '1.0', fecha: new Date(2025, 0, 12), usuario_id: 1, estado: 'guardado' },
        { id: 4, codigo: 'BASC-2025-004', version: '1.0', fecha: new Date(2025, 0, 13), usuario_id: 2, estado: 'guardado' },
        { id: 5, codigo: 'BASC-2025-005', version: '1.0', fecha: new Date(2025, 0, 14), usuario_id: 1, estado: 'guardado' },
        { id: 6, codigo: 'BASC-2025-006', version: '1.0', fecha: new Date(2025, 0, 15), usuario_id: 2, estado: 'guardado' },
        { id: 7, codigo: 'BASC-2025-007', version: '1.0', fecha: new Date(2025, 0, 16), usuario_id: 1, estado: 'guardado' },
        { id: 8, codigo: 'BASC-2025-008', version: '1.0', fecha: new Date(2025, 0, 17), usuario_id: 2, estado: 'guardado' },
        { id: 9, codigo: 'BASC-2025-009', version: '1.0', fecha: new Date(2025, 0, 18), usuario_id: 1, estado: 'guardado' },
        { id: 10, codigo: 'BASC-2025-010', version: '1.0', fecha: new Date(2025, 0, 19), usuario_id: 2, estado: 'guardado' },
        { id: 11, codigo: 'BASC-2025-011', version: '1.0', fecha: new Date(2025, 0, 20), usuario_id: 1, estado: 'guardado' },
        { id: 12, codigo: 'BASC-2025-012', version: '1.0', fecha: new Date(2025, 0, 21), usuario_id: 2, estado: 'guardado' },
    ],
    electrico: [
        { id: 1, codigo: 'ELEC-2025-001', version: '1.0', fecha: new Date(2025, 0, 10), usuario_id: 1, estado: 'guardado' },
        { id: 2, codigo: 'ELEC-2025-002', version: '1.0', fecha: new Date(2025, 0, 11), usuario_id: 2, estado: 'guardado' },
        { id: 3, codigo: 'ELEC-2025-003', version: '1.0', fecha: new Date(2025, 0, 12), usuario_id: 1, estado: 'guardado' },
    ],
    temperaturas: [
        { id: 1, codigo: 'TEMP-2025-001', version: '1.0', fecha: new Date(2025, 0, 10), usuario_id: 1, estado: 'guardado' },
        { id: 2, codigo: 'TEMP-2025-002', version: '1.0', fecha: new Date(2025, 0, 11), usuario_id: 2, estado: 'guardado' },
        { id: 3, codigo: 'TEMP-2025-003', version: '1.0', fecha: new Date(2025, 0, 12), usuario_id: 1, estado: 'guardado' },
        { id: 4, codigo: 'TEMP-2025-004', version: '1.0', fecha: new Date(2025, 0, 13), usuario_id: 2, estado: 'guardado' },
        { id: 5, codigo: 'TEMP-2025-005', version: '1.0', fecha: new Date(2025, 0, 14), usuario_id: 1, estado: 'guardado' },
    ]
};

/**
 * Obtener rol del usuario
 */
function getRol() {
    return localStorage.getItem('rol');
}

/**
 * Buscar documentos
 */
function buscarDocumentos() {
    const tipoDoc = document.getElementById('tipoDocumento').value;
    const codigo = document.getElementById('codigoDocumento').value.trim();

    if (!tipoDoc) {
        mostrarMensaje('Por favor selecciona un tipo de documento', 'error');
        return;
    }

    tipoDocumentoActual = tipoDoc;
    codigoActual = codigo;
    paginaActual = 1;

    try {
        // Obtener documentos de demo
        let documentos = [...(DOCUMENTOS_DEMO[tipoDoc] || [])];

        // Filtrar por código si se especificó
        if (codigo) {
            documentos = documentos.filter(doc => 
                doc.codigo && doc.codigo.toLowerCase().includes(codigo.toLowerCase())
            );
        }

        if (documentos.length === 0) {
            mostrarMensaje('No se encontraron documentos con ese criterio', 'error');
            document.getElementById('cuerpoTabla').innerHTML = '<tr><td colspan="6" style="text-align: center; color: #999;">No hay resultados</td></tr>';
            return;
        }

        documentosActuales = documentos;
        mostrarMensaje('', '');
        mostrarResultados();

    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error al buscar documentos', 'error');
    }
}

/**
 * Mostrar resultados en la tabla
 */
function mostrarResultados() {
    const tbody = document.getElementById('cuerpoTabla');
    const rol = getRol();

    if (documentosActuales.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #999;">No se encontraron documentos</td></tr>';
        document.getElementById('paginacion').style.display = 'none';
        return;
    }

    // Calcular paginación
    const inicio = (paginaActual - 1) * DOCUMENTOS_POR_PAGINA;
    const fin = inicio + DOCUMENTOS_POR_PAGINA;
    const documentosPagina = documentosActuales.slice(inicio, fin);

    tbody.innerHTML = documentosPagina.map(doc => {
        const fecha = new Date(doc.fecha).toLocaleDateString('es-ES');
        const estado = doc.estado || 'Pendiente';
        const estadoColor = estado === 'guardado' ? '#4CAF50' : '#FF9800';
        const nombreUsuario = obtenerUsuarioPorId(doc.usuario_id)?.username || 'N/A';

        let botonesAcciones = `
            <div class="btn-acciones">
                <button class="btn-editar" onclick="editarDocumento(${doc.id}, '${tipoDocumentoActual}')">Editar</button>
                <button class="btn-imprimir" onclick="imprimirDocumento(${doc.id}, '${tipoDocumentoActual}', '${doc.codigo}')">PDF</button>
        `;

        // Mostrar botón eliminar solo para supervisor; hornero ve Editar y PDF
        if (rol === 'supervisor') {
            botonesAcciones += `
                <button class="btn-eliminar" onclick="eliminarDocumento(${doc.id}, '${tipoDocumentoActual}', '${doc.codigo}')">Eliminar</button>
            `;
        }

        botonesAcciones += '</div>';

        return `
            <tr>
                <td>${doc.codigo}</td>
                <td>${doc.version}</td>
                <td>${fecha}</td>
                <td>${nombreUsuario}</td>
                <td><span class="estado-badge">${estado}</span></td>
                <td>${botonesAcciones}</td>
            </tr>
        `;
    }).join('');

    // Mostrar paginación si hay más de 10 documentos
    if (documentosActuales.length > DOCUMENTOS_POR_PAGINA) {
        mostrarPaginacion();
    } else {
        document.getElementById('paginacion').style.display = 'none';
    }
}

/**
 * Mostrar controles de paginación
 */
function mostrarPaginacion() {
    const div = document.getElementById('paginacion');
    const totalPaginas = Math.ceil(documentosActuales.length / DOCUMENTOS_POR_PAGINA);
    
    document.getElementById('infoPaginacion').textContent = `Página ${paginaActual} de ${totalPaginas}`;
    
    document.querySelector('[onclick="paginaAnterior()"]').disabled = paginaActual === 1;
    document.querySelector('[onclick="paginaSiguiente()"]').disabled = paginaActual === totalPaginas;
    
    div.style.display = 'flex';
}

/**
 * Ir a página anterior
 */
function paginaAnterior() {
    if (paginaActual > 1) {
        paginaActual--;
        mostrarResultados();
        window.scrollTo(0, 0);
    }
}

/**
 * Ir a página siguiente
 */
function paginaSiguiente() {
    const totalPaginas = Math.ceil(documentosActuales.length / DOCUMENTOS_POR_PAGINA);
    if (paginaActual < totalPaginas) {
        paginaActual++;
        mostrarResultados();
        window.scrollTo(0, 0);
    }
}

/**
 * Ver documento
 */
function verDocumento(id, tipo) {
    sessionStorage.setItem('documentoId', id);
    sessionStorage.setItem('documentoTipo', tipo);
    sessionStorage.setItem('modoVista', 'ver');

    const rutaMap = {
        'basculantes': 'basculantes.html',
        'electrico': 'electrico.html',
        'temperaturas': 'ControlTermpe.html'
    };

    window.location.href = rutaMap[tipo];
}

/**
 * Editar documento
 */
function editarDocumento(id, tipo) {
    sessionStorage.setItem('documentoId', id);
    sessionStorage.setItem('documentoTipo', tipo);
    sessionStorage.setItem('modoVista', 'editar');

    const rutaMap = {
        'basculantes': 'basculantes.html',
        'electrico': 'electrico.html',
        'temperaturas': 'ControlTermpe.html'
    };

    window.location.href = rutaMap[tipo];
}

/**
 * Imprimir documento como PDF
 */
function imprimirDocumento(id, tipo, codigo) {
    // Borrador descargable para futura integración con base de datos
    const doc = documentosActuales.find(d => d.id === id) || {};
    const usuario = obtenerUsuarioPorId(doc.usuario_id)?.username || 'N/A';
    const fecha = doc.fecha ? new Date(doc.fecha).toLocaleDateString('es-ES') : '-';

    const htmlContenido = `<!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8" />
      <title>${codigo} - ${tipo.toUpperCase()}</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 24px; color: #222; }
        h1 { text-align: center; color: #1F4E6C; margin-bottom: 12px; }
        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .box { border: 1px solid #C7CCD1; padding: 10px; background: #FAFBFC; }
        .label { font-weight: 700; color: #2A2A2A; margin-bottom: 6px; }
        .footer { text-align: right; margin-top: 18px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <h1>Documento ${codigo}</h1>
      <div class="grid">
        <div class="box"><div class="label">Código</div><div>${codigo}</div></div>
        <div class="box"><div class="label">Tipo</div><div>${tipo.toUpperCase()}</div></div>
        <div class="box"><div class="label">Fecha</div><div>${fecha}</div></div>
        <div class="box"><div class="label">Usuario</div><div>${usuario}</div></div>
        <div class="box"><div class="label">Versión</div><div>${doc.version || '-'}</div></div>
        <div class="box"><div class="label">Estado</div><div>${doc.estado || '-'}</div></div>
      </div>
      <div class="footer">Generado: ${new Date().toLocaleString('es-ES')}</div>
    </body>
    </html>`;

    const blob = new Blob([htmlContenido], { type: 'text/html;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${codigo}.html`; // Borrador descargable (luego será PDF real)
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

/**
 * Eliminar documento
 */
function eliminarDocumento(id, tipo, codigo) {
    if (!confirm(`¿Estás seguro de que quieres eliminar el documento ${codigo}?`)) {
        return;
    }

    try {
        // Eliminar de demo (en producción se haría por API)
        const documentos = DOCUMENTOS_DEMO[tipo];
        const index = documentos.findIndex(d => d.id === id);
        
        if (index > -1) {
            documentos.splice(index, 1);
            mostrarMensaje('✓ Documento eliminado exitosamente', 'success');
            
            // Recargar búsqueda
            setTimeout(() => {
                buscarDocumentos();
            }, 1500);
        }

    } catch (error) {
        console.error('Error:', error);
        mostrarMensaje('Error al eliminar documento', 'error');
    }
}

/**
 * Mostrar mensajes
 */
function mostrarMensaje(mensaje, tipo) {
    const div = document.getElementById('mensaje');
    
    if (!mensaje) {
        div.style.display = 'none';
        return;
    }

    div.textContent = mensaje;
    div.style.display = 'block';
    div.className = `mensaje ${tipo}`;
}

// Inicializar al cargar la página
document.addEventListener('DOMContentLoaded', () => {
    const usuarioLogueado = localStorage.getItem('usuarioLogueado');
    if (!usuarioLogueado) {
        // Redirigir silenciosamente si no está autenticado
        window.location.href = '../index.html';
    }
});
