# Knockout TinyMCE Binding

A TinyMCE binding for Knockout.js

## Demo

Check out the [demo](http://rawgit.com/immense/knockout-tinymce/master/demo.html)
to get a quick idea of how it works and how to use it.

## Installation

The knockout-tinymce binding is available in the bower repository. To install
it in your bower enabled project, just do:

`bower install knockout-tinymce-binding`

## Usage

Bind to a textarea:

```html
<textarea data-bind='tinymce: observable'>
```

And then refer to the [demo](http://rawgit.com/immense/knockout-tinymce/master/demo.html)
page on detailed usage instructions.

## Building

To build knockout-tinymce from the coffeescript source, do the
following in a node.js enabled environment:

```
npm install -g grunt-cli
npm install
grunt
```
## License

The knockout-tinymce binding is released under the MIT License. Please see the
LICENSE file for details.
