const { environment } = require('@rails/webpacker')

// environment.loaders.get('sass').use.splice(-1, 0, {
//   loader: 'resolve-url-loader'
// });

// environment.loaders.append('file', {
//   test: /\.(jpe?g|png|gif|svg)$/i,
//   loader: 'file'
// });

// const nodeModulesLoader = environment.loaders.get('nodeModules');

// if (!Array.isArray(nodeModulesLoader.exclude)) {
//   nodeModulesLoader.exclude =
//     nodeModulesLoader.exclude == null ? [] : [nodeModulesLoader.exclude];
// }

module.exports = environment;
