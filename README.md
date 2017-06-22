# Fuse BodyMovin

This is a very buggy and incomplete implementation of [BodyMovin](http://github.com/bodymovin/bodymovin) for
[Fuse](http://www.fusetools.com/). I strongly recommend people *not* use this,
as it's a dirty hack I stitched together with tape in two days.

## Features

### Layers

| Feature  | Status                                       |
|----------|----------------------------------------------|
| Image    | <span style="color:red">Missing</span>       |
| Null     | <span style="color:red">Missing</span>       |
| Pre-Comp | <span style="color:red">Missing</span>       |
| Shape    | <span style="color:green">Implemented</span> |
| Solid    | <span style="color:green">Implemented</span> |
| Text     | <span style="color:red">Missing</span>       |

### Shapes

| Feature         | Status                                       |
|-----------------|----------------------------------------------|
| Ellipse         | <span style="color:green">Implemented</span> |
| Fill            | <span style="color:red">Missing</span>       |
| Gradient-Fill   | <span style="color:red">Missing</span>       |
| Gradient-Stroke | <span style="color:red">Missing</span>       |
| Group           | <span style="color:green">Implemented</span> |
| Merge           | <span style="color:red">Missing</span>       |
| Rectangle       | <span style="color:red">Missing</span>       |
| Round           | <span style="color:red">Missing</span>       |
| Shape           | <span style="color:red">Missing</span>       |
| Star            | <span style="color:red">Missing</span>       |
| Stroke          | <span style="color:red">Missing</span>       |
| Transform       | <span style="color:green">Implemented</span> |
| Trim            | <span style="color:red">Missing</span>       |

### Animations

Animation curves ignores any curve-easing, and just does Catmull-Rom
interpolation always.

## Huge hacks
- All fills and strokes are ignored, and ellipses gets a nice, pink fill
  instead.
- Everything else, really. It's a mess.
