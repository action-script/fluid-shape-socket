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

      concat:
         options:
            separator: '/* ---- */\n',
         dev:
            files:
               'public/dist/view/main.js': ['public/javascript/helper.js', 'public/javascript/webgl.js', 'public/javascript/fbo.js', 'public/javascript/shader.js', 'public/javascript/camera.js', 'public/javascript/mesh.js', 'public/javascript/themesh.js', 'public/javascript/normalsvisor.js', 'public/javascript/mesh-draw.js', 'public/javascript/loading-draw.js', 'public/javascript/main-view.js']
               # 'public/dist/slave/main.js': []

      watch:
         coffee:
            files: ['public/coffee/**/*.coffee']
            tasks: ['coffee:dev', 'concat:dev']

   grunt.loadNpmTasks('grunt-contrib-watch')
   grunt.loadNpmTasks('grunt-contrib-coffee')
   grunt.loadNpmTasks('grunt-contrib-concat')

   grunt.registerTask('default', ['coffee:dev', 'concat:dev'])

