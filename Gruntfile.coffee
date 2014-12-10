module.exports = (grunt) ->
  grunt.initConfig {

    # compile coffeescript files
    coffee:
      tinymce:
        files:
          'knockout-tinymce.js': 'knockout-tinymce.coffee'

    # uglifyjs files
    uglify:
      tinymce:
        src: 'knockout-tinymce.js'
        dest: 'knockout-tinymce.min.js'
  }

  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask('default', [
    'coffee',
    'uglify'
  ])
