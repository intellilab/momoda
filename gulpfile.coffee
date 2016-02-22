gulp = require 'gulp'
coffee = require 'gulp-coffee'
cssmin = require 'gulp-cssmin'
uglify = require 'gulp-uglify'
order = require 'gulp-order'
autoprefixer = require 'gulp-autoprefixer'
concat = require 'gulp-concat'
del = require 'del'

gulp.task 'clean', -> del 'dist'

gulp.task 'coffee', ->
  gulp.src 'src/assets/**/*.coffee'
    .pipe order [
      '!**/app.coffee'
    ]
    .pipe concat 'app.js'
    .pipe do coffee
    #.pipe do uglify
    .pipe gulp.dest 'dist'

gulp.task 'css', ->
  gulp.src 'src/assets/**/*.css'
    .pipe do autoprefixer
    #.pipe do cssmin
    .pipe gulp.dest 'dist'

gulp.task 'copy-lib', ->
  gulp.src 'src/lib/**'
    .pipe gulp.dest 'dist/lib'

gulp.task 'copy-files', ->
  gulp.src 'src/index.html'
    .pipe gulp.dest 'dist'

gulp.task 'copy', ['copy-lib', 'copy-files']

gulp.task 'default', ['coffee', 'css', 'copy']

gulp.task 'watch', ->
  gulp.watch 'src/assets/**/*.coffee', ['coffee']
  gulp.watch 'src/assets/**/*.css', ['css']
  gulp.watch 'src/index.html', ['copy-files']
