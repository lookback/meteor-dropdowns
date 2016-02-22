# Reactive dropdowns for Meteor

[![Circle CI](https://circleci.com/gh/lookback/meteor-dropdowns.svg?style=svg)](https://circleci.com/gh/lookback/meteor-dropdowns)

A solid, fully customizable, reactive dropdowns package for Meteor.

## Install

Install [`lookback:dropdowns`](http://atmospherejs.com/lookback/dropdowns) from Atmosphere:

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
- `top` - Top offset in pixels. Defaults to `0`.
- `classes` - Additional class names for the dropdown. None as default.
- `direction` - One of `n`, `s`, `e` or `w`. Where to position the dropdown around the element. Defaults to `s`.
- `persistent` - Defaults to `false`. Set to `true` if you want the dropdown *not* to hide when clicking outside it (on `document`).

```html
{{#dropdownTrigger name="testDropdown3"}}
  <button>Custom dropdown</button>
{{/dropdownTrigger}}

{{#dropdown name="testDropdown3" align="right" top="20" left="10" direction="n" classes="custom-class another-one"}}
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
  data-dropdown-key="testDropdown4"
  data-dropdown-align="center"
  data-dropdown-left="10"
  data-dropdown-top="20">

  <div class="dropdown-arrow"></div>

  <!-- Content [..] -->
</div>
```

As shown, `name`, `align`, `left` and `top` produces corresponding `data-dropdown-` attributes in the markup, handy for custom CSS styling. The dropdown's name will be the `id` attribute and applied as a class.

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

    <ul class="dropdown__menu">
    {{#each items}}
      <li role="menuItem"><a href="#">{{this}}</a></li>
    {{/each}}
    </ul>

  {{/dropdown}}
</template>
```

One can build more complex components from this simple dropdown concept, such as [filterables](http://dropdowns.meteor.com/#data).

## Persistent dropdowns

Dropdowns can be persistent too, which means they won't close when you click anywhere outside them. It's done setting `persistent` to `true` on a dropdown template:

```
{{#dropdownTrigger name="persistentDropdown"}}
  <button>Persistent dropdown</button>
{{/dropdownTrigger}}

{{#dropdown name="persistentDropdown" persistent="true"}}
  <p>
    This one is persistent.
  </p>
{{/dropdown}}
```

## Animations

The dropdown uses the excellent [Momentum](https://github.com/percolatestudio/meteor-momentum/) package for creating natural animations when toggled. This is built on Meteor's UI hooks, since the dropdown content actually is removed from the DOM when hidden.

Two animations are included: `spring` and `appear`.

- `spring` is making the dropdown appear with a spring physics effect.
- `appear` is simply showing and hiding the dropdown as-is.

### Changing default animation

You can change the default animation for *all* dropdowns by defining a new Momentum plugin and refer to it by its string name:

```js
Dropdowns.animations.default = 'name-of-momentum-plugin';
```

### Changing animation for a single dropdown

You can also change animation per dropdown basis. Just specify the `animation` attribute for the `dropdown` helper.

```html
<div class="test-area dropdown-container">
  {{#dropdownTrigger name="appearAnimation"}}
    <button>Non-standard animation</button>
  {{/dropdownTrigger}}

  {{#dropdown name="appearAnimation" animation="appear"}}
    <p>Hey there.</p>
  {{/dropdown}}
</div>
```

## Styling

No CSS styling is provided with this dropdown package – it's up to you to style the dropdown according to your needs. For a complete styling example, check out the `_dropdowns.scss` file in this [repository](https://github.com/lookback/meteor-dropdowns/tree/master/test-app).

## API

This package exports a namespaced object: `Dropdowns`. By the power of reactivity, all dropdowns are based on an underlying data structure which stores its (quite minimal) state. When that data changes, for instance if the position is changed over an API call, the UI will react. The `Dropdowns` object has the following methods:

```coffeescript
# This is the struct for a "dropdown" object, returned
# by Dropdowns.get('key')
{
  name: 'key'
  showing: false
  align: 'center'
  x: 0
  y: 0
  top: 10
  left: 0
  persistent: false
  element: -> # jQuery reference to the dropdown component in the DOM.
}

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

# Manually set a position of a dropdown. Both x and y are optional.
Dropdowns.setPosition('name', {x: Number, y: Number})

# Hide all dropdowns except for `name` (can also be an array of names).
Dropdowns.hideAllBut('name')

# Get names of all persistent dropdowns
Dropdowns.getPersistentKeys()
```

## Version history

- `1.4.0`
  - Use `data-dropdown-key` attribute when positioning dropdowns, instead of `id`.
  - Expose dropdown name on the `name` property of a dropdown object.
  - Add `element()` function on dropdown objects returned from `Dropdowns.get()`. `element()` returns a
  jQuery reference to the DOM element for the dropdown.
- `1.3.0` - Add support for [custom animations](#animations).
- `1.2.1` - Add `persistent` option.
- `1.2.0` - Add support for dropdown *directions*. Note that this release removes the default top offset (`10px`).
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

## Tests

This package's API interface (methods on the `Dropdown` object) is unit tested in TinyTest (using MUnit). Those tests reside in `/tests`.

```bash
meteor test-packages ./
```

Furthermore, there are Jasmine Velocity integration tests in the demo app: `/test-app/tests`. These tests test the UI and template integration.

```bash
cd test-app
meteor --test
```

## Contributions

Contributions are welcome. Please open issues and/or file Pull Requests.

***

Made by [Lookback](http://lookback.io).
