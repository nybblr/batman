#= require ./abstract_binding

class Batman.DOM.EditableBinding extends Batman.DOM.AbstractBinding
  nodeChange: (node, context) ->
    if @isTwoWay()
      @set('filteredValue', @node.textContent)

  dataChange: (value, node) ->
    jQuery(@node).text(value)

  onlyAll = Batman.BindingDefinitionOnlyObserve.All
  onlyData = Batman.BindingDefinitionOnlyObserve.Data
  onlyNode = Batman.BindingDefinitionOnlyObserve.Node

  bind: ->
    # Attach the observers.
    if @node and @onlyObserve in [onlyAll, onlyNode]
      @_setupEvents @node, @_fireNodeChange.bind(this)

      # Usually, we let the HTML value get updated upon binding by `observeAndFire`ing the dataChange
      # function below. When dataChange isn't attached, we update the JS land value such that the
      # sync between DOM and JS is maintained.
      if @onlyObserve is onlyNode
        @_fireNodeChange()

    # Observe the value of this binding's `filteredValue` and fire it immediately to update the node.
    if @onlyObserve in [onlyAll, onlyData]
      @observeAndFire 'filteredValue', @_fireDataChange

    @view._addChildBinding(this)

  _setupEvents: (node, callback, view) ->
    Batman.DOM.addEventListener node, 'focus', (args...) ->
      self = $(this)
      self.data 'before', self.html()

    for eventName in ['change', 'blur', 'keyup', 'keypress', 'keydown', 'paste']
      Batman.DOM.addEventListener node, eventName, (args...) ->
        window.self = $(@)
        if self.data('before') isnt self.html()
          self.data 'before', self.html()
          callback node, args..., view

Batman.DOM.readers.editable = (definition) ->
  new Batman.DOM.EditableBinding(definition)

