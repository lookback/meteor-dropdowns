/* eslint no-undef: 0, no-unused-vars: 0 */
Momentum.registerPlugin('appear', (options) => {
  return {
    insertElement(node, next) {
      $(node).insertBefore(next);
    },

    moveElement(node, next) {
      this.removeElement(node);
      this.insertElement(node, next);
    },

    removeElement(node) {
      $(node).remove();
    }
  };
});
