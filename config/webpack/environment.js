  const { environment } = require('@rails/webpacker')
  environment.loaders.get('sass').use.splice(-1, 0, {
    loader: 'resolve-url-loader'
  });
  const nodeModulesLoader = environment.loaders.get('nodeModules');
  if (!Array.isArray(nodeModulesLoader.exclude)) {
    nodeModulesLoader.exclude =
      nodeModulesLoader.exclude == null ? [] : [nodeModulesLoader.exclude];
  }
  module.exports = environment;
