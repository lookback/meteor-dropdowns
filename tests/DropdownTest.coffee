Should = should()

describe 'Dropdowns', ->

  beforeEach ->
    Dropdowns.removeAll()

  it 'should exist', ->
    Dropdowns.should.exists

  describe '#get (axiom)', ->

    it 'should be reactive', ->
      spy = sinon.spy()
      Tracker.autorun ->
        Dropdowns.get 'Foo'
        spy()

      spy.should.have.been.called

  describe '#create', ->

    it 'should create a new Dropdown', ->
      Dropdowns.create 'foo'

      dropdown = Dropdowns.get('foo')
      dropdown.should.be.defined
      dropdown.should.be.an 'object'

    it 'should be reactive', ->
      spy = sinon.spy()
      Tracker.autorun ->
        Dropdowns.get 'Foo'
        spy()

      Dropdowns.create 'Foo'
      spy.should.have.been.called

    it 'should have default options', ->
      Dropdowns.create 'foo'

      dropdown = Dropdowns.get 'foo'
      dropdown.align.should.equal 'center'
      dropdown.showing.should.be.false
      dropdown.top.should.equal 0

    it 'should use options when creating', ->
      Dropdowns.create 'foo', { top: 20, left: 10, align: 'right' }

      dropdown = Dropdowns.get 'foo'
      dropdown.top.should.equal 20
      dropdown.left.should.equal 10
      dropdown.align.should.equal 'right'

    it 'should parse string coordinates to numbers', ->
      Dropdowns.create 'foo', { x: '10', top: '20' }

      dropdown = Dropdowns.get 'foo'
      dropdown.x.should.be.a 'number'
      dropdown.x.should.equal 10
      dropdown.top.should.be.a 'number'
      dropdown.top.should.equal 20

    it 'should throw error if called with incorrect align', ->
      (() ->
        Dropdowns.create 'foo', { align: 'Foo' }
      ).should.throw

    it 'should fallback to defaults if called with non-number parameters', ->
      Dropdowns.create 'foo', { top: 'Foo', showing: true }

      dropdown = Dropdowns.get 'foo'
      dropdown.top.should.equal 0    # Fallback for 'top'
      dropdown.showing.should.be.true # .. but not for 'showing'

  describe '#all', ->

    it 'should return all dropdowns as a dict', ->
      Dropdowns.create 'foo'
      Dropdowns.create 'foo2'

      dropdowns = Dropdowns.all()
      Object.keys(dropdowns).length.should.equal 2
      dropdowns.foo.should.be.an 'object'
      dropdowns.foo2.should.be.an 'object'

  describe '#hide', ->

    it 'should hide a dropdown', ->
      Dropdowns.create 'Foo', { showing: true }
      dropdown = Dropdowns.get 'Foo'
      dropdown.showing.should.be.true

      Dropdowns.hide 'Foo'
      dropdown = Dropdowns.get 'Foo'
      dropdown.showing.should.be.false

  describe '#show', ->

    it 'should show a dropdown', ->
      Dropdowns.create 'Foo'
      Dropdowns.show 'Foo'
      Dropdowns.get('Foo').showing.should.be.true

  describe '#hideAll', ->

    it 'should hide all dropdowns', ->
      Dropdowns.create 'Foo1', { showing: true }
      Dropdowns.create 'Foo2', { showing: true }

      Dropdowns.hideAll()
      d1 = Dropdowns.get 'Foo1'
      d2 = Dropdowns.get 'Foo2'
      d1.showing.should.be.false
      d2.showing.should.be.false

  describe '#isShown', ->

    it 'should say if a dropdown is shown or not', ->
      Dropdowns.create 'Foo'
      Dropdowns.isShown('Foo').should.be.false
      Dropdowns.show 'Foo'
      Dropdowns.isShown('Foo').should.be.true

    it 'should be reactive', ->
      spy = sinon.spy()
      Dropdowns.create 'Foo'
      Tracker.autorun ->
        Dropdowns.isShown 'Foo'
        spy()

      Dropdowns.show 'Foo'

  describe '#toggle', ->

    it 'should toggle a dropdown state', ->
      Dropdowns.create 'Foo'
      oldVal = Dropdowns.toggle 'Foo'
      oldVal.should.be.false
      Dropdowns.get('Foo').showing.should.be.true

      oldVal = Dropdowns.toggle 'Foo'
      oldVal.should.be.true
      Dropdowns.get('Foo').showing.should.be.false

  describe '#remove', ->

    it 'should remove a dropdown', ->
      Dropdowns.create 'Foo'
      Dropdowns.remove 'Foo'
      Should.equal Dropdowns.get('Foo'), null

  describe '#removeAll', ->

    it 'should remove all dropdowns', ->
      Dropdowns.create 'Foo'
      Dropdowns.create 'Foo2'
      Dropdowns.removeAll()

      Should.equal Dropdowns.get('Foo'), null
      Should.equal Dropdowns.get('Foo2'), null

  describe '#setPosition', ->

    it 'should set the coordinates of a dropdown', ->
      Dropdowns.create 'Foo'
      Dropdowns.setPosition 'Foo', x: 10, y: 20
      dropdown = Dropdowns.get 'Foo'

      dropdown.x.should.equal 10
      dropdown.y.should.equal 20

    it 'should only accept numbers', ->
      (() ->
        Dropdowns.create 'Foo'
        Dropdowns.setPosition x: 'Lol'
      ).should.throw Match.Error

  describe '#hideAllBut', ->

    it 'should hide all dropdowns except for the one specified', ->
      Dropdowns.create 'Foo1', showing: true
      Dropdowns.create 'Foo2', showing: true
      Dropdowns.create 'Foo3', showing: true

      Dropdowns.hideAllBut 'Foo2'
      Dropdowns.isShown('Foo1').should.be.false
      Dropdowns.isShown('Foo2').should.be.true
      Dropdowns.isShown('Foo3').should.be.false
