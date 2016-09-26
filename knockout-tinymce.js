(function() {
  (function($, ko) {
    var binding, cache, cacheInstance, configure, writeValueToProperty;
    cache = "";
    cacheInstance = null;
    binding = {
      after: ["attr", "value"],
      defaults: {},
      extensions: {},
      init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var $element, ext, options, settings;
        $element = $(element);
        options = (allBindings.has("tinymceConfig") ? allBindings.get("tinymceConfig") : null);
        ext = (allBindings.has("tinymceExtensions") ? allBindings.get("tinymceExtensions") : []);
        settings = configure(binding["defaults"], ext, options, arguments);
        $element[$element.is('input, textarea') ? 'text' : 'html'](ko.unwrap(valueAccessor()));
        setTimeout((function() {
          $element.tinymce(settings);
        }), 0);
        ko.utils["domNodeDisposal"].addDisposeCallback(element, function() {
          var tinymce;
          tinymce = $(element).tinymce();
          if (tinymce) {
            tinymce.remove();
          }
          if (tinymce === cacheInstance) {
            cacheInstance = null;
          }
        });
        return {
          controlsDescendantBindings: true
        };
      },
      update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var tinymce, value;
        tinymce = $(element).tinymce();
        value = ko.unwrap(valueAccessor());
        if (value === null) {
          value = "";
        }
        if (tinymce && !(cacheInstance === tinymce && cache === value)) {
          cacheInstance = tinymce;
          cache = value;
          if (tinymce.getContent() !== value) {
            tinymce.setContent(value);
          }
        }
      }
    };
    writeValueToProperty = function(property, allBindings, key, value, checkIfDifferent) {
      var propWriters;
      if (!property || !ko.isObservable(property)) {
        propWriters = allBindings.get('_ko_property_writers');
        if (propWriters && propWriters[key]) {
          return propWriters[key](value);
        }
      } else if (ko.isWriteableObservable(property) && (!checkIfDifferent || property.peek() !== value)) {
        return property(value);
      }
    };
    configure = function(defaults, extensions, options, args) {
      var applyChange, config, setup;
      config = $.extend(true, {}, defaults);
      if (options) {
        ko.utils.objectForEach(options, function(property) {
          if (Object.prototype.toString.call(options[property]) === "[object Array]") {
            if (!config[property]) {
              config[property] = [];
            }
            options[property] = ko.utils.arrayGetDistinctValues(config[property].concat(options[property]));
          }
        });
        $.extend(true, config, options);
      }
      if (!config["plugins"]) {
        config["plugins"] = ["paste"];
      } else {
        if ($.inArray("paste", config["plugins"]) === -1) {
          config["plugins"].push("paste");
        }
      }
      applyChange = function(editor) {
        editor.on("change keyup nodechange", function(e) {
          return setTimeout((function() {
            var name, value;
            if (editor.destroyed) {
              return;
            }
            value = editor.getContent();
            cache = value;
            cacheInstance = editor;
            writeValueToProperty(args[1](), args[2], "tinymce", value);
            for (name in extensions) {
              if (extensions.hasOwnProperty(name)) {
                binding["extensions"][extensions[name]](editor, e, args[2], args[4]);
              }
            }
          }), 0);
        });
      };
      if (typeof config["setup"] === "function") {
        setup = config["setup"];
        config["setup"] = function(editor) {
          setup(editor);
          applyChange(editor);
        };
      } else {
        config["setup"] = applyChange;
      }
      return config;
    };
    ko.bindingHandlers["tinymce"] = binding;
    ko.expressionRewriting._twoWayBindings["tinymce"] = true;
  })(jQuery, ko);

}).call(this);
