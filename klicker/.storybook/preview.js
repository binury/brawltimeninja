import '../components/index.css'
import '../fixtures/layout.css'

import Vue from 'vue'
import VueCompositionApi from '@vue/composition-api'

Vue.use(VueCompositionApi)

export const parameters = {
  actions: { argTypesRegex: '^on[A-Z].*' },
  darkMode: {
    current: 'dark',
    darkClass: 'dark',
    lightClass: 'light',
    stylePreview: true,
  },
  backgrounds: {
    default: 'dark',
    values: [{
      name: 'dark',
      value: '#18181b', // bg-gray-900
    }],
  },
}
