(($, ko) ->
  binding =
    after: [
      "attr"
      "value"
    ]
    defaults: {}
    extensions: {}
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->

      # Get custom configuration object from the 'wysiwygConfig' binding, more settings here... http://www.tinymce.com/wiki.php/Configuration
      options = (if allBindings.has("tinymceConfig") then allBindings.get("tinymceConfig") else null)

      # Get any extensions that have been enabled for this instance.
      ext = (if allBindings.has("tinymceExtensions") then allBindings.get("tinymceExtensions") else [])
      settings = configure(binding["defaults"], ext, options, arguments)

      # Ensure the valueAccessor's value has been applied to the underlying element, before instanciating the tinymce plugin
      $(element)[if $(element).is('input, textarea') then 'text' else 'html'] ko.unwrap(valueAccessor())

      # Defer TinyMCE instantiation
      setTimeout (->
        $(element).tinymce settings
        return
      ), 0

      # To prevent a memory leak, ensure that the underlying element's disposal destroys it's associated editor.
      ko.utils["domNodeDisposal"].addDisposeCallback element, ->
        tinymce = $(element).tinymce()
        tinymce.remove() if tinymce
        return

      controlsDescendantBindings: true

    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      tinymce = $(element).tinymce()
      # ko.unwrap makes sure that this works
      # even if the given binding value is not an observable
      value = ko.unwrap(valueAccessor())
      # tiny mce crashes if value is null
      if value == null
        value = ""
      if tinymce
        if tinymce.getContent() isnt value
          tinymce.setContent value
      return

  writeValueToProperty = (property, allBindings, key, value, checkIfDifferent) -> 
    if !property or !ko.isObservable property
      propWriters = allBindings.get '_ko_property_writers'
      propWriters[key](value) if propWriters && propWriters[key]
    else if ko.isWriteableObservable(property) and (!checkIfDifferent or property.peek() != value)
        property value
    

  configure = (defaults, extensions, options, args) ->

    # Apply global configuration over TinyMCE defaults
    config = $.extend(true, {}, defaults)
    if options

      # Concatenate element specific configuration
      ko.utils.objectForEach options, (property) ->
        if Object::toString.call(options[property]) is "[object Array]"
          config[property] = []  unless config[property]
          options[property] = ko.utils.arrayGetDistinctValues(config[property].concat(options[property]))
        return

      $.extend true, config, options

    # Ensure paste functionality
    unless config["plugins"]
      config["plugins"] = ["paste"]
    else config["plugins"].push "paste"  if $.inArray("paste", config["plugins"]) is -1

    # Define change handler
    applyChange = (editor) ->

      # Ensure the valueAccessor state to achieve a realtime responsive UI.
      editor.on "change keyup nodechange", (e) ->

        setTimeout (->
          # Update the view model
          writeValueToProperty(args[1](), args[2], "tinymce", editor.getContent())

          # Run all applied extensions
          for name of extensions
            binding["extensions"][extensions[name]] editor, e, args[2], args[4]  if extensions.hasOwnProperty(name)
          return
        ), 0

      return

    if typeof (config["setup"]) is "function"
      setup = config["setup"]

      # Concatenate setup functionality with the change handler
      config["setup"] = (editor) ->
        setup editor
        applyChange editor
        return
    else

      # Apply change handler
      config["setup"] = applyChange
    config


  # Export the binding
  ko.bindingHandlers["tinymce"] = binding
  ko.expressionRewriting._twoWayBindings["tinymce"] = true;
  return
) jQuery, ko
