devTasks = ['clean', 'copy', 'haml', 'coffee']
filesToWatch = [
  'source/**/*'
]

module.exports = (grunt) ->
  grunt.initConfig
    clean: ["./dist"]

    copy:
      main:
        files: [
          { expand: true, cwd: 'source/', src: ['images/**'], dest: 'dist/' }
          { expand: true, cwd: 'source/', src: ['stylesheets/**'], dest: 'dist/' }
        ]

    haml:
      index:
        src: 'source/index.haml'
        dest: 'dist/index.html'

    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'source/'
        src: ['javascripts/*.coffee']
        dest: 'dist/'
        ext: '.js'

    watch:
      dev:
        files: filesToWatch
        tasks: devTasks

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-haml'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.registerTask 'build:dev', ['clean', 'copy', 'haml', 'coffee']
  grunt.registerTask 'default', 'watch:dev'
