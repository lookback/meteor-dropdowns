beforeEach ->
  jasmine.addMatchers
    toBeVisible: ->
      compare: (actual) ->
        $el = actual

        result =
          pass: $(actual).is(':visible')

        if result.pass
          result.message = "Expected element not to be visible."
        else
          result.message = "Expected element to be visible."

        return result
