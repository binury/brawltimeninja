<template>
  <div class="flex flex-wrap justify-around">
    <brawler-starpower-card
      v-for="entry in data"
      :key="entry.id"
      :id="entry.id"
      :kind="kind"
      :name="getStrings(entry).name || entry.dimensions.gadget || entry.dimensions.starpower"
      :brawler-name="brawlerName"
      :description="getStrings(entry).description"
      :winRate="entry.measurementsRaw.winRate"
      :without-winRate="totals == undefined ? 0 : totals.measurementsRaw.winRate"
    ></brawler-starpower-card>
  </div>
</template>

<script lang="ts">
import Vue from 'vue'
import { BrawlerData } from '@/model/Media'
import { MetaGridEntry } from '~/lib/util'

export default Vue.extend({
  props: {
    brawlerId: {
      type: String,
      required: true
    },
    brawlerName: {
      type: String,
      required: true
    },
    kind: {
      type: String, // 'starpowers', 'gadgets'
      required: true
    },
  },
  data() {
    return {
      data: [] as MetaGridEntry[],
      totals: undefined as undefined|MetaGridEntry,
      descriptions: undefined as Record<string, { name: string, description: string}>|undefined,
    }
  },
  fetchDelay: 0,
  async fetch() {
    const singular = this.kind == 'starpowers' ? 'starpower' : 'gadget'

    // TODO queries could be combined
    const dataWith = await this.$cube.query({
      cubeId: singular,
      slices: {
        brawler: [this.brawlerName.toUpperCase()],
        [this.kind == 'starpowers' ? 'starpowerIdNeq' : 'gadgetIdNeq']: ['0'],
      },
      dimensionsIds: [singular],
      measurementsIds: ['winRate'],
      sortId: 'timestamp',
    })

    const dataWithout = await this.$cube.query({
      cubeId: singular,
      slices: {
        brawler: [this.brawlerName.toUpperCase()],
        [this.kind == 'starpowers' ? 'starpowerIdEq' : 'gadgetIdEq']: ['0'],
      },
      dimensionsIds: [singular],
      measurementsIds: ['winRate'],
      sortId: 'timestamp',
    })

    this.data = dataWith.data.map(r => ({
      ...r,
      id: this.kind == 'gadgets' ? r.dimensionsRaw.gadget.gadget : r.dimensionsRaw.starpower.starpower,
    }))
      // in case of duplicate IDs, use the first (most recent)
      .filter((el, index, all) => all.findIndex(e => e.id == el.id) == index)

    this.totals = dataWithout.data[0]

    const info = await this.$http.$get<BrawlerData>(`${this.$config.mediaUrl}/brawlers/${this.brawlerId}/${this.$i18n.locale}.json`).catch(() => undefined) as BrawlerData|undefined
    if (info != undefined) {
      if (this.kind == 'starpowers') {
        this.descriptions = info.starpowerDescriptions
      } else {
        this.descriptions = info.gadgetDescriptions
      }
    }
  },
  computed: {
    getId(): (entry: MetaGridEntry) => string|undefined {
      return (entry: MetaGridEntry) => this.kind == 'gadgets' ? entry.dimensionsRaw.gadget.gadget : entry.dimensionsRaw.starpower.starpower
    },
    getStrings(): (entry: MetaGridEntry) => { name?: string, description?: string } {
      return (entry: MetaGridEntry) => {
        const id = this.getId(entry)
        return this.descriptions == undefined || id == undefined || !(id in this.descriptions) ? {} : this.descriptions[id]
      }
    },
  },
})
</script>
