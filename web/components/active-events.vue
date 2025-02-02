<template>
  <div>
    <experiment experiment-id="DPjOgfntTfmh8d_ubFfVeA">
      <div
        slot="1"
        class="mt-2 flex flex-wrap justify-center w-full max-w-2xl"
      >
        <button
          v-for="(mode, index) in modes"
          :key="mode"
          :class="['border-r-2 border-t-2 border-b-2 border-gray-900 w-12 h-12 flex justify-center items-center', {
            'rounded-l border-l-2': index == 0,
            'rounded-r': index == modes.length - 1,
            'bg-gray-600': true,
            'bg-yellow-400 text-gray-800': mode == modeFilter,
          }]"
          @click="modeFilter = mode"
        >
          <span v-if="mode == 'all'">{{ $t('option.all') }}</span>
          <media-img
            v-else
            :path="'/modes/' + camelToKebab(mode) + '/icon'"
            size="120"
            clazz="w-8 mx-auto my-auto"
          ></media-img>
        </button>
      </div>

      <div class="mt-3 flex flex-wrap justify-center items-end w-full">
        <lzy-map-best-brawlers-card
          v-for="event in filteredEvents"
          :key="event.battle_event_map + '-' + event.battle_event_id"
          :mode="event.battle_event_mode"
          :map="event.battle_event_map"
          :id="event.battle_event_id"
          :powerplay="event.battle_event_powerplay"
          :end-date="event.end"
          :eager="eager"
          link
        ></lzy-map-best-brawlers-card>
      </div>

      <div
        v-show="modeFilter != 'all'"
        class="mt-3 text-right w-full max-w-2xl"
      >
        <b-button
          sm
          primary
          :to="localePath(`/tier-list/mode/${camelToKebab(modeFilter)}`)"
        >
          {{ $t('action.open.tier-list.mode', { mode: $tc('mode.' + modeFilter) }) }}
        </b-button>
      </div>
    </experiment>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { camelToKebab } from '~/lib/util'
import { EventMetadata } from '~/plugins/cube'

export default Vue.extend({
  props: {
    eager: {
      type: Boolean,
    },
  },
  data() {
    return {
      events: [] as EventMetadata[],
      modeFilter: 'all',
    }
  },
  fetchDelay: 0,
  async fetch() {
    this.events = await this.$cube.queryActiveEvents()
  },
  computed: {
    camelToKebab() {
      return camelToKebab
    },
    modes(): string[] {
      return [...new Set(['all', ...this.events.map(e => e.battle_event_mode).sort()])]
    },
    filteredEvents(): EventMetadata[] {
      return this.events.filter(e => this.modeFilter == 'all' || this.modeFilter == e.battle_event_mode)
    },
  },
})
</script>
