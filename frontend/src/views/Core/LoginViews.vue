<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useDashboard } from '@/composables/useDashboard'

const router = useRouter()
const { addToast } = useDashboard()

const email    = ref('')
const password = ref('')

const Login = async () => {
  try {
    const response = await fetch( 'https://129-80-171-141.nip.io/api/auth/login', {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ email: email.value, password: password.value })
    })
    
    if (response.ok) {
      const data = await response.json()
      localStorage.setItem('token', data.access_token)
      localStorage.setItem('role_id', data.role_id)
      
      addToast({ title: 'Bienvenido', description: 'Sesión iniciada correctamente', color: 'success' })
      if (String(data.role_id) === '1') {
        router.push('/dashboard')
      } else {
        addToast({ title: 'Aviso', description: 'Eres un cliente. No debes estar aquí, Cualquier uso indebido será reportado.', color: 'info' })
      }
    } else {
      const errorData = await response.json()
      const errorMsg = errorData.detail || 'Credenciales incorrectas'
      addToast({ title: 'Error al iniciar sesión', description: typeof errorMsg === 'string' ? errorMsg : 'Verifica tus credenciales', color: 'error' })
    }
  } catch (error) {
    console.error("Error logging in", error)
    addToast({ title: 'Error de conexión', description: 'No se pudo conectar con el servidor', color: 'error' })
  }
}
</script>

<template>
  <div class="login-page">
    <div class="card">
      <h2 style="margin-bottom: 20px; text-align: center; font-size: 24px;">Iniciar sesión</h2>
      <form @submit.prevent="Login" class="flex flex-col gap-4">
        <input v-model="email"    type="email"    placeholder="Correo electrónico" required class="input" />
        <input v-model="password" type="password" placeholder="Contraseña"         required class="input" />
        <button type="submit" class="btn btn-primary" style="margin-top: 10px;">Entrar</button>
        <p style="text-align: center; margin-top: 15px; font-size: 14px;">
          ¿No tienes una cuenta? <router-link to="/register" style="color: var(--primary); text-decoration: none; font-weight: bold;">Regístrate</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login-page { display: flex; align-items: center; justify-content: center; height: 100vh; background: var(--bg-soft); }
.card { background: var(--bg); padding: 32px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); width: 100%; max-width: 400px; }
</style>
