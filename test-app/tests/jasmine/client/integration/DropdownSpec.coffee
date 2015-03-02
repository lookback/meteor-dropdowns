describe 'Dropdown template', ->

  beforeEach ->
    @trigger = $('#dropdown1')

  it 'should show dropdown on click', ->

    @trigger.click()
    Tracker.flush()
    expect($('#test-dropdown1')).toBeVisible()

  it 'should close dropdown when clicked outside', (done) ->
    @trigger.click()
    Tracker.flush()

    $(document).click()

    Meteor.setTimeout ->
      expect($('#test-dropdown1')).not.toBeVisible()
      done()
    , 100
