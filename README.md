# Fuse BodyMovin

This is a very buggy and incomplete implementation of [BodyMovin](http://github.com/bodymovin/bodymovin) for
[Fuse](http://www.fusetools.com/). I strongly recommend people *not* use this,
as it's a dirty hack I stitched together with tape in two days.

## Features
- Simple transform animations: This ignores any curve-easing, and just does
  Catmull-Rom interpolation always.
- Ellipses: Also quite limited
- Solid layers

## Huge hacks
- All fills and strokes are ignored, and ellipses gets a nice, pink fill
  instead.
- Everything else, really. It's a mess.
