import fs from 'fs';
import {defineConfig} from 'vite';
import dtsPlugin from 'vite-plugin-dts';
import type vitestTypes from 'vitest';

const BUILD_PATHS = {
  dtsPluginOutput: '/dist/src/',
  dtsFixedOutput: '/dist/types/',
  dtsEntryFile: './dist/index.d.ts',
};

const DTS_ENTRY_CONTENT = `export * from './types/index';`;

const testConfig: vitestTypes.InlineConfig = {
  global: true,
};

export default defineConfig({
  test: testConfig,
  plugins: [
    dtsPlugin({
      beforeWriteFile(filePath, content) {
        return {
          filePath: filePath.replace(
            BUILD_PATHS.dtsPluginOutput,
            BUILD_PATHS.dtsFixedOutput,
          ),
          content,
        };
      },
      afterBuild() {
        fs.promises
          .writeFile(BUILD_PATHS.dtsEntryFile, DTS_ENTRY_CONTENT)
          .then((_success) =>
            // eslint-disable-next-line no-console
            console.log('The build types have been generated.'),
          )
          .catch(() =>
            // eslint-disable-next-line no-console
            console.error('There was a problem processing the build.'),
          );
      },
    }),
  ],
  build: {
    lib: {
      entry: 'src/index.ts',
      name: 'Template Common',
      fileName: (format) => `template-common.${format}.js`,
    },
    // rollupOptions: {},
    minify: false,
  },
});
