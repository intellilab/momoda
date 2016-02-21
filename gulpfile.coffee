gulp = require 'gulp'
coffee = require 'gulp-coffee'
cssmin = require 'gulp-cssmin'
uglify = require 'gulp-uglify'
autoprefixer = require 'gulp-autoprefixer'
merge2 = require 'merge2'
del = require 'del'

gulp.task 'clean', -> del 'dist'

gulp.task 'coffee', ->
  gulp.src 'src/assets/**/*.coffee'
    .pipe do coffee
    #.pipe do uglify
    .pipe gulp.dest 'dist'

gulp.task 'css', ->
  gulp.src 'src/assets/**/*.css'
    .pipe do autoprefixer
    #.pipe do cssmin
    .pipe gulp.dest 'dist'

gulp.task 'copy', ->
  merge2 [
    gulp.src 'src/index.html'
      .pipe gulp.dest 'dist'
    gulp.src 'src/lib/**'
      .pipe gulp.dest 'dist/lib'
  ]

gulp.task 'default', ['coffee', 'css', 'copy']

gulp.task 'watch', ->
  gulp.watch 'src/assets/**/*.coffee', ['coffee']
  gulp.watch 'src/assets/**/*.css', ['css']
  gulp.watch [
    'src/lib/**'
    'src/index.html'
  ], ['copy']
