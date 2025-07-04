<template>
  <div>
    <NuxtRouteAnnouncer />
    <BombermanGame />
  </div>
</template>

<script setup>
import BombermanGame from './components/BombermanGame.vue'
import { useHead } from '#imports'

useHead({
  title: 'Bomberman Game'
})
</script>
