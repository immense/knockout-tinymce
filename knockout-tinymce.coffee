(($, ko) ->
  binding =
    after: [
      "attr"
      "value"
    ]
    defaults: {}
    extensions: {}
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      throw "valueAccessor must be writeable and observable"  unless ko.isWriteableObservable(valueAccessor())

      # Get custom configuration object from the 'wysiwygConfig' binding, more settings here... http://www.tinymce.com/wiki.php/Configuration
      options = (if allBindings.has("tinymceConfig") then allBindings.get("tinymceConfig") else null)

      # Get any extensions that have been enabled for this instance.
      ext = (if allBindings.has("tinymceExtensions") then allBindings.get("tinymceExtensions") else [])
      settings = configure(binding["defaults"], ext, options, arguments)

      # Ensure the valueAccessor's value has been applied to the underlying element, before instanciating the tinymce plugin
      $(element)[if $(element).is('input, textarea') then 'text' else 'html'] valueAccessor()()

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
      value = valueAccessor()()
      if tinymce
        if tinymce.getContent() isnt value
          tinymce.setContent value
          tinymce.execCommand "keyup"
      return

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

        # Update the valueAccessor
        args[1]() editor.getContent()

        # Run all applied extensions
        for name of extensions
          binding["extensions"][extensions[name]] editor, e, args[2], args[4]  if extensions.hasOwnProperty(name)
        return

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
  return
) jQuery, ko
