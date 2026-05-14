<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useDashboard } from '@/composables/useDashboard'

const router = useRouter()
const { addToast } = useDashboard()

const name = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')

const Register = async () => {
  if (password.value !== confirmPassword.value) {
    addToast({ title: 'Error', description: 'Las contraseñas no coinciden', color: 'error' })
    return
  }
  try {
    const response = await fetch('https://129-80-171-141.nip.io/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: name.value, email: email.value, password: password.value, password_confirmation: confirmPassword.value })
    })
    
    if (response.ok) {
      addToast({ title: 'Éxito', description: 'Cuenta creada correctamente. Ahora inicia sesión.', color: 'success' })
      router.push('/login')
    } else {
      const errorData = await response.json()
      const errorMsg = errorData.detail || 'Ocurrió un error al registrarse'
      addToast({ title: 'Error de registro', description: typeof errorMsg === 'string' ? errorMsg : 'Verifica los datos ingresados', color: 'error' })
    }
  } catch (error) {
    console.error("Error al registrar", error)
    addToast({ title: 'Error de conexión', description: 'No se pudo conectar con el servidor', color: 'error' })
  }
}
</script>

<template>
  <div class="register-page">
    <div class="card">
      <h2 style="margin-bottom: 20px; text-align: center; font-size: 24px;">Registrarse</h2>
      <form @submit.prevent="Register" class="flex flex-col gap-4">
        <input v-model="name" type="text" placeholder="Nombre completo" required class="input" />
        <input v-model="email" type="email" placeholder="Correo electrónico" required class="input" />
        <input v-model="password" type="password" placeholder="Contraseña" required class="input" />
        <input v-model="confirmPassword" type="password" placeholder="Confirmar contraseña" required class="input" />
        <button type="submit" class="btn btn-primary" style="margin-top: 10px;">Registrarse</button>
        <p style="text-align: center; margin-top: 15px; font-size: 14px;">
          ¿Ya tienes cuenta? <router-link to="/login" style="color: var(--primary); text-decoration: none; font-weight: bold;">Inicia sesión</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<style scoped>
.register-page { display: flex; align-items: center; justify-content: center; height: 100vh; background: var(--bg-soft); }
.card { background: var(--bg); padding: 32px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); width: 100%; max-width: 400px; }
</style>
