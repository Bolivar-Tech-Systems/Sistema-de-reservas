<script setup>
import { format, isToday } from 'date-fns'

const props = defineProps({ mails: Array })
const selectedMail = defineModel()

function fmtDate(d) {
  const date = new Date(d)
  return isToday(date) ? format(date, 'HH:mm') : format(date, 'dd MMM')
}
</script>

<template>
  <div class="mail-list">
    <div
      v-for="mail in mails" :key="mail.id"
      class="mail-item"
      :class="{ active: selectedMail?.id === mail.id, unread: mail.unread }"
      @click="selectedMail = mail"
    >
      <div class="mail-row">
        <div class="flex items-center gap-2">
          <span class="font-medium">{{ mail.from.name }}</span>
          <span v-if="mail.unread" class="chip"></span>
        </div>
        <span class="text-xs text-muted">{{ fmtDate(mail.date) }}</span>
      </div>
      <p class="mail-subject">{{ mail.subject }}</p>
      <p class="mail-preview">{{ mail.body }}</p>
    </div>
  </div>
</template>

<style scoped>
.mail-list { overflow-y: auto; }
.mail-item { padding: 14px 20px; border-bottom: 1px solid var(--border); cursor: pointer; border-left: 2px solid transparent; transition: all 150ms; }
.mail-item:hover { border-left-color: var(--primary); background: rgba(0,220,130,0.03); }
.mail-item.active { border-left-color: var(--primary); background: var(--primary-light); }
.mail-item.unread { color: var(--text); }
.mail-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 2px; }
.mail-subject { font-size: 0.8125rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 2px; }
.mail-item.unread .mail-subject, .mail-item.unread .mail-row .font-medium { font-weight: 600; }
.mail-preview { font-size: 0.75rem; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
</style>
