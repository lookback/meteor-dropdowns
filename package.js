const where = 'client';

Package.describe({
  name: 'lookback:dropdowns',
  summary: 'Reactive dropdowns for Meteor.',
  version: '1.4.0',
  git: 'http://github.com/lookback/meteor-dropdowns'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');

  api.use([
    'underscore',
    'tracker',
    'ecmascript',
    'jquery',
    'reactive-dict',
    'templating',
    'check',
    'percolate:momentum@0.7.2'
  ], where);

  api.addFiles([
    'animations/animation-spring.js',
    'animations/animation-appear.js',
    'templates/dropdown.html',
    'lib/dropdown.js'
  ], where);

  api.imply('percolate:momentum@0.7.2', where);
  api.export('Dropdowns', where);
});


Package.onTest(function(api) {
  api.use([
    'coffeescript',
    'check',
    'tracker',
    'lookback:dropdowns',
    'practicalmeteor:mocha'
  ], where);

  api.addFiles('tests/DropdownTest.coffee', where);
});
