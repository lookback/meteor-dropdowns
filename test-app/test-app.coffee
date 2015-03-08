if Meteor.isClient

  Template.content.rendered = ->
    $('pre code').each (i, block) ->
      hljs.highlightBlock(block)

    $('.toc a').on 'click', (evt) ->
      evt.preventDefault()
      hash = this.hash

      if hash
        $('html,body').animate(
          scrollTop: $(hash).offset().top - 50
        )

  Template.testTemplate.helpers(
    items: ['Foo', 'Bar', 'Baz']
  )


  Drinks = new Mongo.Collection(null)

  Meteor.startup ->
    ['Mojito', 'Sangria', 'White Russian', 'Black Russian',
      'Piña Colada', 'Sex on the Beach', 'Tropical Sunset',
      'Old Fashioned'].forEach (name) ->

      Drinks.insert(name: name)

  Template.filterDropdown.created = ->
    @filter = new ReactiveVar()
    Session.setDefault 'selected', Drinks.findOne().name

  Template.filterDropdown.helpers(

    drinks: ->
      tmpl = Template.instance()
      filter = tmpl.filter.get()

      if filter and filter isnt ''
        search =
          name:
            $regex: new RegExp(filter)
            $options: 'i'

        Drinks.find(search)
      else
        Drinks.find()

    isSelected: ->
      Session.equals 'selected', @name
  )

  Template.filterDropdown.events(
    'keyup input': (evt, tmpl) ->
      val = evt.currentTarget.value
      tmpl.filter.set(val)

    'search input': (evt, tmpl) ->
      tmpl.filter.set ''

    'click a': (evt, tmpl) ->
      evt.preventDefault()
      Session.set 'selected', @name
  )
