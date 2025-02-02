<template>
  <card v-bind="$attrs">
    <div
      slot="content"
      class="flex flex-wrap items-center py-1"
    >
      <div class="grid grid-cols-12-1fr gap-y-3 items-center">
        <h1 class="inline font-semibold mr-4">
          Source
        </h1>

        <div>
          <b-select
            :value="value.cubeId"
            dark
            sm
            @input="v => onInputCubeId(v)"
          >
            <option
              v-for="c in cubes"
              :key="c.id"
              :value="c.id"
            >
              {{ c.name }}
            </option>
          </b-select>
        </div>

        <c-metric
          :value="value"
          :multiple="advancedMode"
          class="col-span-2"
          @input="s => $emit('input', s)"
        ></c-metric>

        <span
          v-if="advancedMode"
          class="font-semibold mr-2"
        >
          Group By
        </span>

        <div
          v-if="advancedMode"
          class="flex flex-wrap gap-y-1 gap-x-1"
        >
          <b-select
            v-for="index in numDimensions"
            :key="index"
            :value="value.dimensionsIds[index - 1]"
            dark
            sm
            @input="v => onInputDimensionsIds(index - 1, v)"
          >
            <option
              v-for="d in dimensions.filter(d => d.id == value.dimensionsIds[index - 1] || !value.dimensionsIds.includes(d.id))"
              :key="d.id"
              :value="d.id"
            >
              {{ d.name }}
            </option>
          </b-select>

          <div class="flex gap-x-1">
            <b-button
              v-if="numDimensions < dimensions.length"
              class="font-semibold"
              primary
              sm
              @click="numDimensions++"
            >
              <font-awesome-icon
                :icon="faPlus"
              ></font-awesome-icon>
            </b-button>

            <b-button
              v-if="numDimensions > 0"
              class="font-semibold"
              primary
              sm
              @click="onDimensionRemove()"
            >
              <font-awesome-icon
                :icon="faMinus"
              ></font-awesome-icon>
            </b-button>
          </div>
        </div>

        <label
          v-if="advancedMode && canCompare"
          class="col-span-2 flex items-center"
        >
          <b-checkbox v-model="compareMode"></b-checkbox>
          <span class="ml-2">Comparison Mode</span>
        </label>

        <label class="col-span-2 flex items-center">
          <b-checkbox v-model="advancedMode"></b-checkbox>
          <span class="ml-2">Expert Options</span>
        </label>
      </div>
    </div>
  </card>
</template>

<script lang="ts">
import Vue, { PropType } from 'vue'
import { State, Cube, Dimension, Measurement } from '~/lib/cube'
import { faMinus, faPlus } from '@fortawesome/free-solid-svg-icons'

export default Vue.extend({
  inheritAttrs: false,
  props: {
    value: {
      type: Object as PropType<State>,
      required: true
    },
  },
  data() {
    const stateIsDefault = !this.$cube.config[this.value.cubeId].hidden
      && this.value.measurementsIds.length == this.$cube.config[this.value.cubeId].defaultMeasurementIds.length
      && JSON.stringify(this.value.dimensionsIds) == JSON.stringify(this.$cube.config[this.value.cubeId].defaultDimensionsIds)
      && this.value.comparingSlices == undefined

    return {
      advancedMode: !stateIsDefault,
      numDimensions: this.value.dimensionsIds.length,
    }
  },
  methods: {
    onInputCubeId(c: string) {
      // filter & keep old slice values that exist in the new cube too
      const slicesDefaults = Object.assign({},
        this.$cube.config[c].defaultSliceValues,
        Object.fromEntries(
          Object.entries(this.value.slices)
            .filter(([key, value]) => this.$cube.config[c].slices.some(s => s.id == key))
        ))
      const comparingSliceDefaults = Object.assign({},
        this.$cube.config[c].defaultSliceValues,
        Object.fromEntries(
          Object.entries(this.value.comparingSlices ?? {})
            .filter(([key, value]) => this.$cube.config[c].slices.some(s => s.id == key))
        ))

      // keep old measurements if they all exist in the new cube
      const measurementsIdsDefaults = this.value.measurementsIds
        .every(m => this.$cube.config[c].measurements.some(mm => mm.id == m))
        ? this.value.measurementsIds
        : this.$cube.config[c].defaultMeasurementIds

      this.$emit('input', <State>{
        cubeId: c,
        slices: slicesDefaults,
        comparingSlices: comparingSliceDefaults,
        dimensionsIds: this.$cube.config[c].defaultDimensionsIds,
        measurementsIds: measurementsIdsDefaults,
      })
      this.numDimensions = this.$cube.config[c].defaultDimensionsIds.length
    },
    onInputDimensionsIds(index: number, d: string) {
      const dimensionsIds = this.value.dimensionsIds.slice()
      dimensionsIds[index] = d
      this.$emit('input', <State>{
        ...this.value,
        dimensionsIds,
      })
      this.numDimensions = dimensionsIds.length
    },
    onDimensionRemove() {
      const dimensionsIds = this.value.dimensionsIds.slice()
      dimensionsIds.pop()
      this.$emit('input', <State>{
        ...this.value,
        dimensionsIds,
      })
      this.numDimensions--
    },
  },
  computed: {
    compareMode: {
      get(): boolean {
        return this.value.comparingSlices != undefined
      },
      set(comparing: boolean) {
        this.$emit('input', <State>{
          ...this.value,
          comparingSlices: comparing ? this.$cube.config[this.value.cubeId].defaultSliceValues : undefined,
        })
      }
    },
    cubes(): Cube[] {
      return Object.values(this.$cube.config)
        .filter((cube) => this.advancedMode || !cube.hidden)
    },
    dimensions(): Dimension[] {
      return this.$cube.config[this.value.cubeId].dimensions
        .filter(d => this.advancedMode || !d.hidden)
    },
    canCompare(): boolean {
      const measurements = this.$cube.config[this.value.cubeId].measurements
      return measurements
        .filter(m => this.value.measurementsIds.includes(m.id))
        .every(m => m.type == 'quantitative')
    },
    faPlus() {
      return faPlus
    },
    faMinus() {
      return faMinus
    },
  }
})
</script>

<style lang="postcss" scoped>
.grid-cols-12-1fr {
  grid-template-columns: 6rem 1fr;
}
</style>
