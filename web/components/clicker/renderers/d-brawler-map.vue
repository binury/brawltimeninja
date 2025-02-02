<template>
  <event-card
    :mode="$t('mode.' + row.dimensionsRaw.map.mode)"
    :map="$t('map.' + row.dimensionsRaw.map.eventId)"
    :id="row.dimensionsRaw.map.eventId"
    size="w-80"
  >
    <p v-if="end != undefined" slot="infobar" class="text-right">
      {{ $t('time.ends-in', { time: timeTillEnd }) }}
    </p>

    <div
      slot="content"
      class="flex justify-center"
    >
      <div class="flex items-end bg-gray-800 rounded">
        <media-img
          :path="`/brawlers/${brawlerId}/avatar`"
          :alt="brawlerName"
          size="128"
          clazz="w-16 mr-2"
        ></media-img>
        <kv-table
          v-if="row.measurementsRaw.picks > 0"
          class="w-48 px-3 py-2"
          :data="table"
        ></kv-table>
        <div
          v-else
          class="w-48 flex"
          style="height: 112px;"
        >
          <p class="m-auto">{{ $t('state.no-data') }}</p>
        </div>
      </div>
    </div>

    <b-button
      slot="actions"
      :to="localePath(`/tier-list/mode/${camelToKebab(row.dimensionsRaw.map.mode)}/map/${slugify(row.dimensionsRaw.map.map)}`)"
      primary
      prefetch
      sm
    >
      {{ $t('action.open') }}
    </b-button>
  </event-card>
</template>

<script lang="ts">
import { formatDistanceToNow, parseISO } from 'date-fns'
import Vue, { PropType } from 'vue'
import { mapState } from 'vuex'
import { commonMeasurements } from '~/lib/cube'
import { brawlerId, camelToKebab, slugify } from '@/lib/util'

interface TotalsRow {
  picks_weighted: number
}

export default Vue.extend({
  inheritAttrs: false,
  props: {
    row: {
      type: Object,
      required: true
    },
    end: {
      type: String,
    },
  },
  data() {
    return {
      totals: {} as TotalsRow,
    }
  },
  computed: {
    useRate(): number {
      return this.row.measurementsRaw.picks / this.totals.picks_weighted
    },
    timeTillEnd(): string {
      if (this.end == undefined) {
        return ''
      }
      return formatDistanceToNow(parseISO(this.end))
    },
    table(): string[][] {
      return [
        [ this.$tc('metric.picks'), this.$clicker.format(commonMeasurements.picks, this.row.measurementsRaw.picks) ],
        [ this.$tc('metric.useRate'), this.$clicker.format(commonMeasurements.useRate, this.useRate) ],
        [ this.$tc('metric.winRate'), this.$clicker.format(commonMeasurements.winRate, this.row.measurementsRaw.winRate) ],
      ]
    },
    brawlerId(): string {
      return brawlerId({ name: this.row.dimensionsRaw.brawler.brawler })
    },
    camelToKebab() {
      return camelToKebab
    },
    slugify() {
      return slugify
    },
    ...mapState({
      totalBrawlers: (state: any) => state.totalBrawlers,
    })
  },
})
</script>
