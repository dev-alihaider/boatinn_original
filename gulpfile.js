const gulp = require('gulp');
const imagemin = require('gulp-imagemin');
 
gulp.task('default', () =>
  gulp.src('app/assets/images/*')
    .pipe(imagemin([
      imagemin.optipng({optimizationLevel: 7})
    ]))
    .pipe(gulp.dest('app/assets/images/'))
);