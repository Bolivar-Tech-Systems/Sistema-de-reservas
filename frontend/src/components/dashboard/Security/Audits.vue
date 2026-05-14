<script setup>
import { ref, computed } from 'vue'
import { Search, ChevronLeft, ChevronRight, Activity, Eye, X } from 'lucide-vue-next'
import { useDashboard } from '@/composables/useDashboard'

const { addToast } = useDashboard()
const audits = ref([])
const search = ref('')
const methodFilter = ref('all')
const statusFilter = ref('all')
const page = ref(1)
const perPage = 15

// Modal state
const selectedAudit = ref(null)

const loadAudits = async () => {
  const token = localStorage.getItem('token')
  if (!token) return
  
  try {
    const response = await fetch('https://129.80.171.141/api/auditoria/http-logs?limit=500', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
    })
    if (response.ok) {
      audits.value = await response.json()
    } else {
      addToast({ title: 'Error', description: 'No se pudieron cargar las auditorías', color: 'error' })
    }
  } catch (error) {
    console.error('Error al cargar las auditorías:', error)
  }
}

loadAudits()

const filtered = computed(() => {
  let list = [...audits.value]
  
  // Search
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(a => a.path?.toLowerCase().includes(q) || a.ip_address?.toLowerCase().includes(q))
  }
  
  // Method filter
  if (methodFilter.value !== 'all') {
    list = list.filter(a => a.method === methodFilter.value)
  }
  
  // Status filter
  if (statusFilter.value !== 'all') {
    if (statusFilter.value === 'success') list = list.filter(a => a.status_code >= 200 && a.status_code < 300)
    if (statusFilter.value === 'error') list = list.filter(a => a.status_code >= 400)
  }
  
  return list
})

const totalPages = computed(() => Math.max(1, Math.ceil(filtered.value.length / perPage)))
const paginated = computed(() => filtered.value.slice((page.value - 1) * perPage, page.value * perPage))

const formatDate = (dateStr) => {
  if (!dateStr) return 'N/A'
  const d = new Date(dateStr)
  return d.toLocaleString('es-CO')
}

const getStatusColor = (code) => {
  if (!code) return 'badge-neutral'
  if (code >= 200 && code < 300) return 'badge-success'
  if (code >= 400 && code < 500) return 'badge-warning'
  if (code >= 500) return 'badge-error'
  return 'badge-neutral'
}

const getMethodColor = (method) => {
  if (!method) return ''
  switch (method.toUpperCase()) {
    case 'GET': return 'color: var(--info); font-weight: 700;'
    case 'POST': return 'color: var(--success); font-weight: 700;'
    case 'PUT': return 'color: var(--warning); font-weight: 700;'
    case 'DELETE': return 'color: var(--error); font-weight: 700;'
    default: return 'font-weight: 700;'
  }
}

const viewDetails = (audit) => {
  selectedAudit.value = audit
}

const formatJson = (jsonStr) => {
  if (!jsonStr) return 'N/A'
  try {
    const parsed = JSON.parse(jsonStr)
    return JSON.stringify(parsed, null, 2)
  } catch (e) {
    return jsonStr // Devuelve como string si no es JSON válido
  }
}
</script>

<template>
  <div class="audits-container">
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-3">
        <div class="avatar avatar-lg bg-primary-subtle text-primary" style="background-color: var(--primary); color: white; display: flex; align-items: center; justify-content: center; border-radius: 8px; width: 40px; height: 40px;">
          <Activity :size="20" />
        </div>
        <div>
          <h2 style="font-size: 1.25rem; font-weight: bold; margin: 0;">Registros de Auditoría</h2>
          <p style="color: var(--text-muted); font-size: 0.875rem; margin: 0;">Monitoreo detallado del tráfico HTTP y acciones en el sistema</p>
        </div>
      </div>
      <button class="btn btn-outline" @click="loadAudits">
        Actualizar datos
      </button>
    </div>

    <!-- Barra de herramientas y Filtros -->
    <div class="flex flex-wrap items-center justify-between gap-3" style="margin-bottom: 24px; background: var(--bg-soft); padding: 12px; border-radius: 8px;">
      <div class="input-with-icon" style="flex-grow: 1; max-width: 400px;">
        <Search />
        <input v-model="search" class="input" placeholder="Buscar por ruta o IP..." style="border: none; background: transparent; box-shadow: none;">
      </div>
      
      <div class="flex gap-2" style="display: flex; gap: 8px;">
        <select v-model="methodFilter" class="select" style="min-width: 150px;">
          <option value="all">Todos los Métodos</option>
          <option value="GET">GET</option>
          <option value="POST">POST</option>
          <option value="PUT">PUT</option>
          <option value="DELETE">DELETE</option>
        </select>
        
        <select v-model="statusFilter" class="select" style="min-width: 150px;">
          <option value="all">Cualquier Estado</option>
          <option value="success">Exitoso (2xx)</option>
          <option value="error">Error (4xx - 5xx)</option>
        </select>
      </div>
    </div>

    <!-- Tabla -->
    <div style="overflow-x: auto; border: 1px solid var(--border); border-radius: 8px;">
      <table class="data-table" style="width: 100%; min-width: 900px; border-collapse: collapse;">
        <thead>
          <tr style="background: var(--bg-soft); text-align: left;">
            <th style="padding: 12px 16px; width: 60px;">ID</th>
            <th style="padding: 12px 16px; width: 180px;">Fecha y Hora</th>
            <th style="padding: 12px 16px; width: 100px;">Método</th>
            <th style="padding: 12px 16px;">Ruta</th>
            <th style="padding: 12px 16px; width: 100px;">Estado</th>
            <th style="padding: 12px 16px; width: 120px;">IP</th>
            <th style="padding: 12px 16px; width: 100px;">Duración</th>
            <th style="padding: 12px 16px; width: 80px; text-align: center;">Detalles</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in paginated" :key="a.id" class="hover-row">
            <td style="padding: 12px 16px; color: var(--text-muted); font-family: monospace; font-size: 0.85rem;">{{ a.id }}</td>
            <td style="padding: 12px 16px; font-size: 0.9rem;">{{ formatDate(a.timestamp) }}</td>
            <td style="padding: 12px 16px; font-size: 0.85rem;" :style="getMethodColor(a.method)">{{ a.method }}</td>
            <td style="padding: 12px 16px; max-width: 250px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-family: monospace; font-size: 0.9rem;" :title="a.path">{{ a.path }}</td>
            <td style="padding: 12px 16px;">
              <span class="badge" :class="getStatusColor(a.status_code)">{{ a.status_code || 'N/A' }}</span>
            </td>
            <td style="padding: 12px 16px; font-size: 0.9rem;">{{ a.ip_address || 'N/A' }}</td>
            <td style="padding: 12px 16px; font-size: 0.9rem;">{{ a.duration_ms ? a.duration_ms.toFixed(1) : '0' }} ms</td>
            <td style="padding: 12px 16px; text-align: center;">
              <button class="btn btn-icon btn-ghost btn-sm" style="color: var(--primary);" @click="viewDetails(a)" title="Ver Payload">
                <Eye :size="16" />
              </button>
            </td>
          </tr>
          <tr v-if="paginated.length === 0">
            <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">
              No hay registros que coincidan con los filtros.
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Paginación -->
    <div style="display: flex; align-items: center; justify-content: space-between; margin-top: 16px;">
      <span style="font-size: 0.875rem; color: var(--text-muted);">Mostrando {{ paginated.length }} de {{ filtered.length }} registros.</span>
      <div class="pagination">
        <button class="page-btn" :disabled="page <= 1" @click="page--"><ChevronLeft :size="14" /></button>
        <button v-for="p in totalPages" :key="p" class="page-btn" :class="{ active: page === p }" @click="page = p">{{ p }}</button>
        <button class="page-btn" :disabled="page >= totalPages" @click="page++"><ChevronRight :size="14" /></button>
      </div>
    </div>

    <!-- Modal de Detalles -->
    <Teleport to="body">
      <div v-if="selectedAudit" class="modal-overlay" @click="selectedAudit = null">
        <div class="modal-content modal-lg" @click.stop style="max-width: 700px;">
          <div class="modal-header flex justify-between items-center mb-4">
            <h3 class="text-lg font-bold">Detalle de Petición #{{ selectedAudit.id }}</h3>
            <button class="btn btn-ghost btn-icon" @click="selectedAudit = null"><X :size="20"/></button>
          </div>
          
          <div class="modal-body space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="p-3 bg-soft rounded-lg">
                <p class="text-xs text-muted mb-1">Ruta Solicitada</p>
                <p class="font-mono text-sm break-all" :style="getMethodColor(selectedAudit.method)">{{ selectedAudit.method }} <span class="text-foreground">{{ selectedAudit.path }}</span></p>
              </div>
              <div class="p-3 bg-soft rounded-lg">
                <p class="text-xs text-muted mb-1">Información de Red</p>
                <p class="text-sm">IP: {{ selectedAudit.ip_address }} • {{ formatDate(selectedAudit.timestamp) }}</p>
              </div>
            </div>

            <div>
              <h4 class="text-sm font-bold mb-2">Request Body (Payload enviado)</h4>
              <div class="code-block">
                <pre>{{ formatJson(selectedAudit.request_body) }}</pre>
              </div>
            </div>

            <div>
              <h4 class="text-sm font-bold mb-2">Response Body (Respuesta del servidor)</h4>
              <div class="code-block">
                <pre>{{ formatJson(selectedAudit.response_body) }}</pre>
              </div>
            </div>
          </div>
          
          <div class="modal-footer flex justify-end mt-6">
            <button class="btn btn-outline" @click="selectedAudit = null">Cerrar</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.hover-row {
  transition: background-color 0.2s;
}
.hover-row:hover {
  background: var(--bg-soft);
}
.bg-soft {
  background: var(--bg-soft);
}
.code-block {
  background: #1e1e1e;
  color: #d4d4d4;
  padding: 12px;
  border-radius: 8px;
  overflow-x: auto;
  font-family: monospace;
  font-size: 13px;
  max-height: 250px;
  overflow-y: auto;
}
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(2px);
}
.modal-content {
  background: var(--bg);
  padding: 24px;
  border-radius: 12px;
  width: 100%;
  max-width: 500px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15);
  max-height: 90vh;
  overflow-y: auto;
}
.modal-lg {
  max-width: 800px;
}
</style>