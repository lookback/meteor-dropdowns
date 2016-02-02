/* eslint no-undef: 0 */
Momentum.registerPlugin('dropdown', (options) => {
  options = _.extend({}, options, {
    duration: {
      in: 400,
      out: 300
    },
    easing: [600, 20]
  });

  return {
    insertElement(node, next) {
      const $node = $(node);

      $node.css('opacity', 0).insertBefore(next).velocity({
        scaleY: [1, 0.5],
        scaleX: [1, 0.8]
      }, {
        easing: options.easing,
        duration: options.duration.in,
        queue: false
      }).velocity('fadeIn', {
        duration: options.duration.in - 200,
        queue: false
      });
    },

    moveElement(node, next) {
      this.removeElement(node);
      this.insertElement(node, next);
    },

    removeElement(node) {
      const $node = $(node);

      $node.velocity({
        scale: [0.8, 1]
      }, {
        duration: options.duration.out,
        easing: 'ease',
        queue: false,
        complete: function() {
          return $node.remove();
        }
      }).velocity('fadeOut', {
        queue: false,
        duration: options.duration.out - 200
      });
    }
  };
});
