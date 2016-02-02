const where = 'client';

Package.describe({
  name: 'lookback:dropdowns',
  summary: 'Reactive dropdowns for Meteor.',
  version: '1.2.1',
  git: 'http://github.com/lookback/meteor-dropdowns'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.4');

  api.use('percolate:momentum@0.7.2', where);
  api.use([
    'underscore',
    'tracker',
    'ecmascript',
    'jquery',
    'reactive-dict',
    'templating',
    'check'
  ], where);

  api.addFiles([
    'transitions/default-transition.js',
    'templates/dropdown.html',
    'lib/dropdown.js'
  ], 'client');

  api.export('Dropdowns', where);
});


Package.onTest(function(api) {
  api.use([
    'coffeescript',
    'check',
    'tracker',
    'lookback:dropdowns',
    'practicalmeteor:munit'
  ], where);

  api.addFiles('tests/DropdownTest.coffee', where);
});
