const DROPDOWN_TRIGGER = '.dropdown__trigger';
const DROPDOWN = '.dropdown';

const DEFAULT_ANIMATION = 'spring';

const Directions = Object.freeze({
  NORTH: 'n',
  SOUTH: 's',
  EAST: 'e',
  WEST: 'w'
});

const toSnakeCase = (str) => {
  if (str) {
    return str.replace(/([A-Z])/g, ($1) => `-${$1.toLowerCase()}`);
  }

  return '';
};

const createDropdown = (key, opts = {}) => {
  check(key, String);

  const defaults = {
    showing: false,
    persistent: false,
    direction: Directions.SOUTH,
    align: 'center',
    x: 0,
    y: 0,
    top: 0,
    left: 0
  };

  const toIntOr = (val, org) => {
    const int = parseInt(val, 10);
    return _.isNaN(int) ? org : int;
  };

  const dropdown = (function(obj) {
    if (opts) {
      for (const prop in opts) {
        if (Match.test(prop, Match.OneOf('x', 'y', 'top', 'left'))) {
          obj[prop] = toIntOr(opts[prop], obj[prop]);
        } else if (prop === 'persistent') {
          obj[prop] = opts[prop] === 'true';
        } else {
          if (opts[prop] && _.isUndefined(opts[prop]) === false) {
            obj[prop] = opts[prop];
          }
        }
      }
    }

    obj.name = key;

    return obj;
  })(defaults);

  if (!Match.test(dropdown.align, Match.OneOf('center', 'left', 'right'))) {
    throw new Error('Dropdowns: align parameter must be center, left or right!');
  }

  return dropdown;
};

/**
 * Takes a plain dropdown object and attaches helpers.
 *
 * @param  {object} dropdown - From Dropdowns.get('name')
 * @return {object} Same dropdown extended with helpers.
 */
const dropdownTransform = (dropdown) => {
  if (!Match.test(dropdown, Object)) {
    return {};
  }

  _(dropdown).extend({
    element() {
      return $(`[data-dropdown-key="${dropdown.name}"]`);
    }
  });

  return dropdown;
};

const factory = () => {
  const list = new ReactiveDict();

  const all = () =>
    list.all();

  const allKeys = () =>
    Object.keys(list.keys);

  const except = (keys) =>
    _.without(allKeys(), ...keys);

  const get = (key) => {
    const dropdown = list.get(key);
    return dropdown ? dropdownTransform(dropdown) : null;
  };

  const add = (key, opts) => {
    list.set(key, createDropdown(key, opts));
    return get(key);
  };

  const setPosition = (key, coords) => {
    check(coords, {
      x: Match.Optional(Number),
      y: Match.Optional(Number)
    });

    const dropdown = get(key);

    if (dropdown) {
      if (coords.x) {
        dropdown.x = coords.x;
      }
      if (coords.y) {
        dropdown.y = coords.y;
      }

      list.set(key, dropdown);

      return dropdown;
    }

    return false;
  };

  const show = (key) => {
    const dropdown = list.get(key);

    if (dropdown) {
      dropdown.showing = true;
      return list.set(key, dropdown);
    }

    return false;
  };

  const hide = (key) => {
    const dropdown = list.get(key);

    if (dropdown) {
      dropdown.showing = false;
      return list.set(key, dropdown);
    }

    return false;
  };

  const hideAll = (keys = allKeys()) =>
    keys.forEach(hide);

  const isShown = (key) => {
    const dropdown = list.get(key);
    return dropdown && dropdown.showing;
  };

  const toggle = (key) => {
    const dropdown = list.get(key);

    if (dropdown) {
      const oldVal = dropdown.showing;
      dropdown.showing = !oldVal;
      list.set(key, dropdown);
      return oldVal;
    }

    return false;
  };

  const remove = (key) =>
    delete list.keys[key];

  const removeAll = () =>
    allKeys().forEach(remove);

  return {
    all,
    get,
    hide,
    show,
    isShown,
    toggle,
    hideAll,
    remove,
    removeAll,
    setPosition,
    create: add,
    animations: {
      default: DEFAULT_ANIMATION
    },

    hideAllBut(keys) {
      const notTheseKeys = Array.isArray(keys) ? keys : [keys];
      return hideAll(except(notTheseKeys));
    },

    getPersistentKeys() {
      return allKeys().filter(key => list.get(key).persistent);
    }
  };
};

Dropdowns = factory();

const isActive = (name) =>
  Dropdowns.isShown(name);

const center = (args) => {
  const middle = args[0] + args[1] / 2;
  return middle - args[2] / 2;
};

const horizontally = ($el, $reference) =>
  [$reference.position().left, $reference.outerWidth(), $el.outerWidth()];

const vertically = ($el, $reference) =>
  [$reference.position().top, $reference.outerHeight(), $el.outerHeight()];

Template.dropdown.onCreated(function() {
  const opts = _.pick(this.data,
    'align',
    'top',
    'left',
    'direction',
    'persistent',
    'animation'
  );

  return Dropdowns.create(this.data.name, opts);
});

Template.dropdown.helpers({
  animation() {
    const dropdown = Dropdowns.get(this.name);

    return dropdown && dropdown.animation || Dropdowns.animations.default;
  },

  show() {
    return isActive(this.name);
  },

  templateOrName() {
    return this.template || this.name;
  },

  toSnakeCase: toSnakeCase,

  position() {
    const dropdown = Dropdowns.get(this.name);
    if (dropdown) {
      return {
        x: dropdown.x,
        y: dropdown.y
      };
    }

    return {x: 0, y: 0};
  },

  attributes() {
    const dropdown = Dropdowns.get(this.name);

    if (dropdown) {
      const attrs = {};
      attrs['data-dropdown-key'] = dropdown.name;
      attrs['data-dropdown-top'] = dropdown.top;
      attrs['data-dropdown-left'] = dropdown.left;
      attrs['data-dropdown-align'] = dropdown.align;
      attrs['data-dropdown-direction'] = dropdown.direction;
      return attrs;
    }

    return {};
  },

  arrowDirection() {
    const dropdown = Dropdowns.get(this.name);
    const map = {
      n: 'down',
      s: 'up',
      e: 'left',
      w: 'right'
    };
    return map[dropdown.direction];
  }
});

Template.dropdownTrigger.onRendered(function() {
  this.$('*').first().addClass(DROPDOWN_TRIGGER.slice(1));
});

Template.dropdownTrigger.helpers({
  isActive() {
    return isActive(this.name);
  }
});

Dropdowns.positionDropdown = (key, reference) => {
  const dropdown = Dropdowns.get(key);

  if (!dropdown.showing) {
    return;
  }

  const $dropdown = dropdown.element();
  const $el = $(reference);

  if ($dropdown.length === 0) {
    console.error(`Dropdowns: Couldn't find a dropdown: ${key}`);
    return;
  }
  if ($el.length === 0) {
    console.error(`Dropdowns: Couldn't find the trigger element for ${key}`);
    return;
  }

  const align = dropdown.align;
  const offLeft = dropdown.left;
  const offTop = dropdown.top;
  const direction = dropdown.direction;
  const ref = $el.position();
  const position = {};

  position.y = (function() {
    switch (direction) {
    case 'w':
    case 'e':
    default:
      if (align === 'left') {
        return ref.top - $dropdown.outerHeight() + $el.outerHeight() + offTop;
      } else if (align === 'right') {
        return ref.top + offTop;
      }

      return center(vertically($dropdown, $el)) + offTop;

    case 'n':
      return ref.top - $dropdown.outerHeight() + offTop;
    case 's':
      return ref.top + $el.outerHeight() + offTop;
    }
  })();

  position.x = (function() {
    switch (direction) {
    case 'n':
    case 's':
    default:
      if (align === 'left') {
        return ref.left - offLeft;
      } else if (align === 'right') {
        return ref.left + $el.outerWidth() - $dropdown.outerWidth() - offLeft;
      }

      return center(horizontally($dropdown, $el)) + offLeft;
    case 'w':
      return ref.left - $dropdown.outerWidth() + offLeft;
    case 'e':
      return ref.left + $el.outerWidth() + offLeft;
    }
  })();

  Dropdowns.setPosition(key, position);
};

Template.dropdownTrigger.events({
  click(evt, tmpl) {
    evt.preventDefault();
    const {name, hideOthers = true} = tmpl.data;

    if (hideOthers) {
      Dropdowns.hideAllBut(name);
    }

    Dropdowns.toggle(name);

    Tracker.afterFlush(() =>
      Dropdowns.positionDropdown(name, tmpl.find(DROPDOWN_TRIGGER))
    );
  }
});

Template.registerHelper('dropdownIsActive', isActive);

$(() => {
  const childOf = (el, selector) =>
    el.parents(selector).length !== 0;

  const isTrigger = (el) =>
    childOf(el, DROPDOWN_TRIGGER) || el.is(DROPDOWN_TRIGGER);

  const isDropdown = (el) =>
    childOf(el, DROPDOWN) || el.is(DROPDOWN) || el.is(DROPDOWN_TRIGGER);

  const isInput = (el) => {
    const node = el.get(0);
    return node.tagName === 'INPUT' || node.tagName === 'TEXTAREA';
  };

  $(document).on('keyup', (evt) => {
    if (evt.keyCode === 27) {
      const el = $(evt.target);
      if (isDropdown(el)) {
        if (isInput(el) && el.val() !== '') {
          return;
        }
      }

      Dropdowns.hideAll();
    }
  });

  $(document).on('click', (evt) => {
    const el = $(evt.target);

    if (el.length < 1) {
      return;
    }
    if (!(isDropdown(el) || isTrigger(el))) {
      Dropdowns.hideAllBut(Dropdowns.getPersistentKeys());
    }
  });
});
