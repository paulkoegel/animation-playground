devTasks = ['clean', 'copy', 'haml', 'coffee']
filesToWatch = [
  'source/**/*'
]

module.exports = (grunt) ->
  grunt.initConfig
    connect:
      server:
        options:
          base: './dist'
          port: 3000
          keepalive: true # without this the server process would close immediately after a successful start; you can then not chain any task behind connect, however

    clean:
      all:
        files:[
          { src: [
            './dist/images/**',
            './dist/javascripts/**',
            './dist/index.html'
            ]
            , filter: 'isFile' # this line MUST start with a comma; reason for this option: https://github.com/gruntjs/grunt-contrib-clean/issues/15#issuecomment-14301612
          }
        ]

    copy:
      main:
        files: [
          { expand: true, cwd: 'source/', src: ['images/**'], dest: 'dist/' }
        ]

    haml:
      compile:
        files:
          'dist/index.html': 'source/index.haml'
          'dist/blocks.html' : 'source/blocks.haml'
        options:
          language: 'coffee'

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
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.registerTask 'build:dev', ['clean', 'copy', 'haml', 'coffee']
  grunt.registerTask 'default', ['watch:dev']
  grunt.registerTask 'server', ['connect']
