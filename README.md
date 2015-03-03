# Reactive dropdowns for Meteor

[![Circle CI](https://circleci.com/gh/lookback/meteor-dropdowns.svg?style=svg)](https://circleci.com/gh/lookback/meteor-dropdowns)

A barebones dropdowns package that's doing it the "Meteor Way".

## How to use

```html
// template.html

<button class="{{#if isDropdownActive}}active{{/if}}" data-dropdown="menu-dropdown">Menu</button>

{{#dropdown name='menu-dropdown'}}
  <div role="menu" class="dropdown">
    <p>This is the dropdown content.</p>
  </div>
{{/dropdown}}
```

The package exposes three things:

- A template block helper: `dropdown`
- A template helper: `isDropdownActive`
- A top level Javascript namespace: `Dropdown`

## Version history

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
