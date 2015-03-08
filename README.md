# Reactive dropdowns for Meteor

[![Circle CI](https://circleci.com/gh/lookback/meteor-dropdowns.svg?style=svg)](https://circleci.com/gh/lookback/meteor-dropdowns)

A solid, fully customizable, reactive dropdowns package for Meteor.

## Install

```bash
meteor add lookback:dropdowns
```

## Usage

Be sure to check out the [demo](http://dropdowns.meteor.com) for samples.

### tldr;

```html
{{ ! In a template }}
{{#dropdownTrigger name="uniqueName" }}
  <button>Trigger</button>
{{/dropdownTrigger}}

{{#dropdown name="uniqueName"}}
  <p>Hello world!</p>
{{/dropdown}}
```

### Basics

A dropdown consist of a **trigger** and the actual **dropdown content**. They are wrapped in Meteor template helpers, in order to create contained components. The templates are:

- `dropdownTrigger`
- `dropdown`

Meteor's template helpers can take a bunch of arguments for customization, but the only _required_ one for the dropdowns to work is the `name` argument, which takes a string which should be **unique** in order to identify the dropdown.

Simply use the templates `dropdownTrigger` and `dropdown` in order to wrap the triggering element and the dropdown:

```html
{{#dropdownTrigger name="dropdownTest" }}
  <button>Trigger #1</button>
{{/dropdownTrigger}}

{{#dropdown name="dropdownTest"}}
  <p>Hello world</p>
{{/dropdown}}
```

You can also use a separate template for the dropdown and dropdown trigger content:


```html
{{ > dropdownTrigger name="testDropdown2" template="testDropdownTrigger" }}

{{ > dropdown name="testDropdown2" }}

<!-- Somewhere else .. -->

<template name="testDropdownTrigger">
  <button>Trigger #2</button>
</template>

<template name="testDropdown2">
  <p>External content, yo.</p>
</template>
```

Note that `dropdownTrigger` needs the template name in the `template` argument.

### Additional arguments

The `dropdown` helper takes additional arguments for positioning and custom classes. The names are:

- `align` - Defaults to `center`. Can also be `left` or `right`.
- `left` - Left offset in pixels. Defaults to `0`.
- `top` - Top offset in pixels. Defaults to `10`.
- `classes` - Additional class names for the dropdown. None as default.


```html
{{#dropdownTrigger name="testDropdown3"}}
  <button>Custom dropdown</button>
{{/dropdownTrigger}}

{{#dropdown name="testDropdown3" align="right" top="20" left="10" classes="custom-class another-one"}}
  <p>Custom dropdown.</p>
{{/dropdown}}
```

### Markup & Classes

The `dropdownTrigger` template helper doesn't produce any extra HTML around your content. `dropdown` on the other hand produces the following HTML:

```
{{#dropdownTrigger}}
  <button>A trigger</button>
{{/dropdownTrigger}}

<!-- Produces: -->

<button class="dropdown__trigger">A trigger</button>

{{#dropdown name="testDropdown4" align="center" top="20" left="10" classes="custom-class"}}
  <!-- Content [..] -->
{{/dropdown}}

<!-- Produces: -->

<div role="menu"
  class="dropdown test-dropdown4 custom-class"
  id="test-dropdown4"
  style="position: absolute; left: XXpx; top: XXpx;"
  data-dropdown-align="center"
  data-dropdown-left="10"
  data-dropdown-top="20">

  <div class="dropdown-arrow"></div>

  <!-- Content [..] -->
</div>
```

As shown, `align`, `left` and `top` produces corresponding `data-dropdown-` attributes in the markup, handy for custom CSS styling. The dropdown's name will be the `id` attribute and applied as a class.

It is **recommended** to wrap both the trigger and dropdown markup in a container element with relative positioning.

Please note that the `name` template argument will be present as `id` and `class` in <kbd>snake-case</kbd> form.

### Helpers

In order to detect active, opened dropdowns, the global `dropdownIsActive` helper can be used:

```
{{#dropdownTrigger name="testDropdown5"}}
  <button class="{{#if dropdownIsActive 'testDropdown5'}}dropdown--open{{/if}}">A trigger</button>
{{/dropdownTrigger}}
```

### Data Contexts

Both the dropdown and its trigger inherits the data context from its parent:

```coffeescript
Template.testTemplate.helpers(
  items: ['Foo', 'Bar', 'Baz']
)
```


```html
<template name="testTemplate">
  {{#dropdownTrigger name="testDropdown6"}}
    <button>Dropdown with data</button>
  {{/dropdownTrigger}}

  {{#dropdown name="testDropdown6" classes="dropdown--menu" align="left"}}
    {{#each items}}
      <li role="menuItem"><a href="#">{{this}}</a></li>
    {{/each}}
  {{/dropdown}}
</template>
```

One can build more complex components from this simple dropdown concept, such as filterables.

### API

This package exports a namespaced object: `Dropdowns`. By the power of reactivity, all dropdowns are based on an underlying data structure which stores its (quite minimal) state. When that data changes, for instance if the position is changed over an API call, the UI will react. The `Dropdowns` object has the following methods:

```coffeescript
# Manually create a dropdown with a name.
Dropdowns.create('name', opts = {top: 10, left: 0, align: 'center'})

# Get a the dropdown.
Dropdowns.get('name')

# Hide a dropdown.
Dropdowns.hide('name')

# Show a dropdown.
Dropdowns.show('name')

# Returns `true` if a dropdown is currently shown.
Dropdowns.isShown('name')

# Toggle a dropdown.
Dropdowns.toggle('name')

# Hide all dropdowns.
Dropdowns.hideAll()

# Destroy a dropdown.
Dropdowns.remove()

# Destroy all dropdowns.
Dropdowns.removeAll()

# Manually set a position of a dropdown.
Dropdowns.setPosition('name', {x: Number, y: Number})

# Hide all dropdowns except for `name`.
Dropdowns.hideAllBut('name')
```

### Animation

The dropdown uses the excellent [Momentum](https://github.com/percolatestudio/meteor-momentum/) package for creating natural animations when toggled. This is built on Meteor's UI hooks, since the dropdown content actually is removed from the DOM when hidden.

For now, a default transition is bundled. In the future, users of this package will be able to write their own Momentum plugins and provide to the dropdown helper.

### Styling

No CSS styling is provided with this dropdown package – it's up to you to style the dropdown according to your needs. For a complete styling example, check out the `_dropdowns.scss` file in this [repository](https://github.com/lookback/meteor-dropdowns/tree/master/test-app).

## Version history

- `1.0.0` - Stable release.
- `0.4.1`
  - **Fix:** The properties `x, y, top, left` are now flattened (before, they were in properties `position` and `offset` respectively).
  - **Fix:** Said properties are converted to `Numbers` when creating a `Dropdown`.
- `0.4.0` Rewrite logic to be based on data reactivity instead of DOM state.
  - **New:** New API methods on the `Dropdowns` global.
  - **New:** New template helper for the dropdown trigger (`dropdownTrigger`).
- `0.3.3` **Fix:** Issue where a descendant element of a trigger would cause dropdown to hide.
- `0.3.2` **New:** Add `.dropdown__arrow` div to template.
- `0.3.1` **Fix:** Support snake-case for classes and ids in dropdown template.
- `0.3.0` Move foundational dropdown wrapper markup into the template.
- `0.2.0` **New:** Support for horizontal positioning.
- `0.1.0` Initial commit.

## Contributions

Contributions are welcome. Please open issues and/or file Pull Requests.

***

Made by [Lookback](http://lookback.io).
