module.exports = (grunt) ->

   grunt.initConfig
      coffee:
         dev:
            options:
               sourceMap: false
               bare: true

            expand: true
            flatten: true
            cwd: 'public'
            src: ['coffee/**/*.coffee']
            dest: 'public/javascript'
            ext: '.js'

      watch:
         coffee:
            files: ['public/coffee/**/*.coffee']
            tasks: ['coffee:dev']

   grunt.loadNpmTasks('grunt-contrib-watch')
   grunt.loadNpmTasks('grunt-contrib-coffee')

   grunt.registerTask('default', ['coffee:dev'])

