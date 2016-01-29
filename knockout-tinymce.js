(function() {
  (function($, ko) {
    var binding, configure;
    binding = {
      after: ["attr", "value"],
      defaults: {},
      extensions: {},
      init: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var ext, options, settings;
        if (!ko.isWriteableObservable(valueAccessor())) {
          throw "valueAccessor must be writeable and observable";
        }
        options = (allBindings.has("tinymceConfig") ? allBindings.get("tinymceConfig") : null);
        ext = (allBindings.has("tinymceExtensions") ? allBindings.get("tinymceExtensions") : []);
        settings = configure(binding["defaults"], ext, options, arguments);
        $(element).text(valueAccessor()());
        setTimeout((function() {
          $(element).tinymce(settings);
        }), 0);
        ko.utils["domNodeDisposal"].addDisposeCallback(element, function() {
          var tinymce = $(element).tinymce();
          if(tinymce){
            tinymce.remove();
          }
        });
        return {
          controlsDescendantBindings: true
        };
      },
      update: function(element, valueAccessor, allBindings, viewModel, bindingContext) {
        var tinymce, value;
        tinymce = $(element).tinymce();
        value = valueAccessor()();
        if (tinymce) {
          if (tinymce.getContent() !== value) {
            tinymce.setContent(value);
            tinymce.execCommand("keyup");
          }
        }
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
          var name;
          args[1]()(editor.getContent());
          for (name in extensions) {
            if (extensions.hasOwnProperty(name)) {
              binding["extensions"][extensions[name]](editor, e, args[2], args[4]);
            }
          }
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
  })(jQuery, ko);

}).call(this);
