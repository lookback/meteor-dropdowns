describe 'Template', ->

  beforeEach ->
    @trigger = $('#dropdown1')
    @dropdown = '#test-dropdown1'

  it 'should show dropdown on click', ->
    @trigger.click()
    Tracker.flush()
    expect($ @dropdown).toBeVisible()

  it 'should close dropdown when clicked outside', (done) ->
    @trigger.click()
    Tracker.flush()

    $(document).click()

    Meteor.setTimeout =>
      expect($ @dropdown).not.toBeVisible()
      done()
    , 200

  describe 'dropdownTrigger', ->

    it 'should add .dropdown__trigger class to dropdown trigger element', ->
      expect(@trigger.hasClass 'dropdown__trigger').toBe true

  describe 'dropdown', ->

    it 'should add a .dropdown class to the dropdown element', ->
      @trigger.click()
      Tracker.flush()
      expect($(@dropdown).hasClass 'dropdown').toBe true

    it 'should have the dropdown name in snake-case as class', ->
      @trigger.click()
      Tracker.flush()
      expect($(@dropdown).hasClass 'test-dropdown1').toBe true

    it 'should support custom classes', ->
      $('#customClassesTrigger').click()
      Tracker.flush()

      expect($('#test-dropdown-custom-offset').hasClass 'custom-class another-one' ).toBe true

    it 'should keep the parent template\'s data context', ->
      $('#custom-data-trigger').click()
      Tracker.flush()

      content = $('#test-dropdown6').text()

      expect(content.match /Foo\s+Bar\s+Baz/g ).not.toBe null


  describe 'dropdownIsActive', ->

    it 'should yield true if a dropdown is active', ->
      isActive = Blaze._globalHelpers.dropdownIsActive

      @trigger.click()
      Tracker.flush()

      expect(isActive 'testDropdown1').toBe true
