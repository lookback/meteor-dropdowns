# Reactive dropdowns, by Johan.

# Constants

DROPDOWN_TRIGGER = '.dropdown__trigger'
DROPDOWN = '.dropdown'

# Dropdown factory function.
Dropdown = (opts = {}) ->
  defaults =
    showing: false
    align: 'center'
    x: 0
    y: 0
    top: 10       # Offsets
    left: 0

  toIntOr = (val, org) ->
    int = parseInt(val)
    if _.isNaN(int) then org else int

  # Parse strings -> int
  dropdown = do (obj = defaults) ->
    if opts
      for prop of opts
        if Match.test prop, Match.OneOf('x', 'y', 'top', 'left')
          obj[prop] = toIntOr opts[prop], obj[prop]
        else
          if opts[prop] and _.isUndefined(opts[prop]) is false
            obj[prop] = opts[prop]

    return obj

  if not Match.test dropdown.align, Match.OneOf('center', 'left', 'right')
    throw new Error 'Dropdowns: align parameter must be center, left or right!'

  return dropdown

# Simple data structure for handling
# several dropdowns' state.
DropdownsStruct = ->
  list = new ReactiveDict()

  except = (key) ->
    _.without(Object.keys(list.keys), key)

  get = (key) ->
    list.get(key)

  add = (key, opts) ->
    list.set(key, Dropdown(opts))
    list.get(key)

  setPosition = (key, coords) ->
    check(coords,
      x: Match.Optional(Number)
      y: Match.Optional(Number)
    )

    dropdown = list.get(key)

    if dropdown
      dropdown.x = coords.x if coords.x
      dropdown.y = coords.y if coords.y
      list.set(key, dropdown)
      return dropdown

  show = (key) ->
    dropdown = list.get(key)

    if dropdown
      dropdown.showing = true
      list.set(key, dropdown)

  hide = (key) ->
    dropdown = list.get(key)

    if dropdown
      dropdown.showing = false
      list.set(key, dropdown)

  hideAll = (keys) ->
    keys = keys or Object.keys(list.keys)
    keys.forEach(hide)

  isShown = (key) ->
    dropdown = list.get(key)
    dropdown and dropdown.showing

  toggle = (key) ->
    dropdown = list.get(key)

    if dropdown
      oldVal = dropdown.showing
      dropdown.showing = !oldVal
      list.set(key, dropdown)

      return oldVal

  remove = (key) ->
    list.set(key, null)

  removeAll = ->
    Object.keys(list.keys).forEach(remove)

  create: add
  get: get
  hide: hide
  show: show
  isShown: isShown
  toggle: toggle
  hideAll: hideAll
  remove: remove
  removeAll: removeAll
  setPosition: setPosition
  hideAllBut: (key) -> hideAll except key

# Singleton
Dropdowns = DropdownsStruct()

toSnakeCase = (str) ->
  if str
    str.replace /([A-Z])/g, ($1) -> '-' + $1.toLowerCase()
  else
    return ''

isActive = (name) ->
  Dropdowns.isShown(name)

# Positioning

center = (args) ->
	middle = args[0] + args[1] / 2
	middle - args[2] / 2

horizontally = ($el, $reference) ->
	[$reference.position().left, $reference.outerWidth(), $el.outerWidth()]

vertically = ($el, $reference) ->
	[$reference.position().top, $reference.outerHeight(), $el.outerHeight()]

# Templates

Template.dropdown.created = ->
  # Build a dropdown from template attributes.
  opts = _.pick(@data, 'align', 'top', 'left')
  Dropdowns.create(@data.name, opts)

Template.dropdown.helpers
  show: ->
    isActive(@name)

  templateOrName: ->
    @template or @name

  toSnakeCase: toSnakeCase

  position: ->
    dropdown = Dropdowns.get(@name)

    if dropdown
      return x: dropdown.x, y: dropdown.y

  attributes: ->
    dropdown = Dropdowns.get(@name)

    if dropdown
      attrs = {}
      attrs['data-dropdown-top'] = dropdown.top
      attrs['data-dropdown-left'] = dropdown.left
      attrs['data-dropdown-align'] = dropdown.align

      return attrs

Template.dropdownTrigger.rendered = ->
  this.$('*').first().addClass(DROPDOWN_TRIGGER.slice(1))

Template.dropdownTrigger.helpers(
  isActive: ->
    isActive(@name)
)

positionDropdown = (key, element) ->
  return () ->
    dropdown = Dropdowns.get(key)
    return unless dropdown.showing

    $dropdown = $("##{toSnakeCase(key)}")
    $el = $(element)

    if $dropdown.length is 0
      return console.error 'Dropdowns: Couldn\'t find a dropdown: ' + key
    if $el.length is 0
      return console.error 'Dropdowns: Couldn\'t find the trigger element for ' + key

    align = dropdown.align
    offLeft = dropdown.left
    offTop = dropdown.top

    ref = $el.position()

    if align is 'left'
      left = ref.left - offLeft
    else if align is 'right'
      left = ref.left + $el.outerWidth() - $dropdown.outerWidth() - offLeft
    else
      left = center horizontally $dropdown, $el
      left += offLeft

    top = ref.top + $el.outerHeight() + offTop

    Dropdowns.setPosition(key, { y: top, x: left })

Template.dropdownTrigger.events(
  'click': (evt, tmpl) ->
    evt.preventDefault()
    name = tmpl.data.name
    Dropdowns.hideAllBut(name)
    Dropdowns.toggle(name)

    Tracker.afterFlush positionDropdown(name, tmpl.find(DROPDOWN_TRIGGER))
)

Template.registerHelper 'dropdownIsActive', isActive

$ ->

  childOf = (el, selector) ->
    el.parents(selector).length isnt 0

  # Isn't trigger nor child of
  isTrigger = (el) ->
    childOf(el, DROPDOWN_TRIGGER) or el.is(DROPDOWN_TRIGGER)

  # Isn't dropdown nor child of
  isDropdown = (el) ->
    childOf(el, DROPDOWN) or el.is(DROPDOWN) or el.is(DROPDOWN_TRIGGER)

  isInput = (el) ->
    node = el.get(0)
    node.tagName is 'INPUT' or node.tagName is 'TEXTAREA'

  $(document).on 'keydown', (evt) ->
    # Close on Esc
    if evt.keyCode is 27
      el = $(evt.target)

      # Don't close dropdowns if we're writing something with content.
      if isDropdown(el)
        return if isInput(el) and el.val() isnt ''

        Dropdowns.hideAll()

  $(document).on 'click', (evt) ->
    el = $(evt.target)
    if el.length < 1
      return

    # De Morgan's Laws, baby.
    #   (!P ^ !Q) => !(P v Q)
    if not (isDropdown(el) or isTrigger(el))
      Dropdowns.hideAll()
