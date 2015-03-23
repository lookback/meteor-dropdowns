var where = 'client';

Package.describe({
  name: 'lookback:dropdowns',
  summary: 'Reactive dropdowns for Meteor.',
  version: '1.1.0',
  git: 'http://github.com/lookback/meteor-dropdowns'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@0.9.2');
  api.use('percolate:momentum@0.7.2', where);
  api.use([
    'underscore',
    'tracker',
    'coffeescript',
    'jquery',
    'reactive-dict',
    'templating',
    'check'
  ], where);

  api.add_files([
    'transitions/default.coffee',
    'dropdown.html',
    'dropdown.coffee'
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
