<script setup>
import { ref, computed } from 'vue'
import InboxList from '@/components/dashboard/inbox/InboxList.vue'
import InboxMail from '@/components/dashboard/inbox/InboxMail.vue'
import { Inbox as InboxIcon } from 'lucide-vue-next'

const mails = ref([]) // Empty array since we don't use fake data anymore
const selectedTab = ref('all')
const selectedMail = ref(null)

const filteredMails = computed(() => {
  if (selectedTab.value === 'unread') return mails.value.filter(m => m.unread)
  return mails.value
})
</script>

<template>
  <div class="inbox-layout">
    <div class="inbox-sidebar">
      <div class="inbox-toolbar">
        <div class="tabs">
          <button class="tab-btn" :class="{ active: selectedTab === 'all' }" @click="selectedTab = 'all'">Todos</button>
          <button class="tab-btn" :class="{ active: selectedTab === 'unread' }" @click="selectedTab = 'unread'">No leídos</button>
        </div>
        <span class="badge badge-neutral">{{ filteredMails.length }}</span>
      </div>
      <InboxList v-model="selectedMail" :mails="filteredMails" />
    </div>
    <div class="inbox-content">
      <InboxMail v-if="selectedMail" :mail="selectedMail" @close="selectedMail = null" />
      <div v-else class="inbox-empty">
        <InboxIcon :size="64" style="color: var(--text-muted); opacity: 0.4;" />
        <p class="text-muted">Selecciona un mensaje para leer</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.inbox-layout { display: flex; margin: -24px; height: calc(100vh - var(--navbar-h)); }
.inbox-sidebar { width: 340px; min-width: 280px; border-right: 1px solid var(--border); display: flex; flex-direction: column; overflow: hidden; }
.inbox-toolbar { display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-bottom: 1px solid var(--border); }
.inbox-content { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
.inbox-empty { flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; }
@media (max-width: 768px) { .inbox-sidebar { width: 100%; } .inbox-content { display: none; } }
</style>
