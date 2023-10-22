/// A standard library of shapes, CSG operations, transforms, and so on.
///
/// All standard library functions return a `Tree`.
/// License: MPL-2.0
/// See_Also: <a href="https://github.com/libfive/libfive/tree/master/libfive/stdlib#readme">Upstream Standard Library</a>
module libfive.std;

import libfive: Vec3;
import libfive.tree;
import stdlib = libfive.stdlib;

/// Section: <abbr title="Constructive Solid Geometry">CSG</abbr>

/// Returns: The union of two shapes.
Tree _union(Tree a, Tree b) {
  return new Tree(stdlib._union(a.ptr, b.ptr));
}
/// Returns: The intersection of two shapes.
Tree intersection(Tree a, Tree b) {
  return new Tree(stdlib.intersection(a.ptr, b.ptr));
}
/// Returns: A shape that's the inverse of the input shape.
Tree inverse(Tree x) {
  return new Tree(stdlib.inverse(x.ptr));
}
/// Subtracts the second shape from the first.
Tree difference(Tree a, Tree b) {
  return new Tree(stdlib.difference(a.ptr, b.ptr));
}
/// Expand or contract a given shape by an offset.
///
/// Positive offsets expand the shape; negative offsets shrink it.
Tree offset(Tree, TreeFloat);
/// Expands shape b by the given offset then subtracts it from shape `a`.
Tree clearance(Tree, Tree, TreeFloat);
/// Returns: A shell of a shape with the given offset.
Tree shell(Tree, TreeFloat);
/// Blends two shapes by the given amount using exponents.
Tree blend_expt(Tree, Tree, TreeFloat);
/// Blends two shapes by the given amount using exponents, with the blend term adjusted to produce results
/// approximately resembling `blend_rough` for values between 0 and 1.
Tree blend_expt_unit(Tree, Tree, TreeFloat);
/// Blends two shapes by the given amount, using a fast-but-rough <abbr title="Constructive Solid Geometry">CSG</abbr>
/// approximation that may not preserve gradients.
Tree blend_rough(Tree, Tree, TreeFloat);
/// Blends the subtraction of `b`, with optional offset `o`, from `a`, with smoothness `m`.
Tree blend_difference(Tree, Tree, TreeFloat, TreeFloat);
/// Morphs between two shapes.
///
/// Remarks: `m = 0` produces `a`, `m = 1` produces `b`.
Tree morph(Tree, Tree, TreeFloat);
/// Produces a blended loft between `a` (at z-min) and `b` (at z-max).
///
/// `a` and `b` should be 2D shapes, i.e. invariant along the z axis.
Tree loft(Tree, Tree, TreeFloat, TreeFloat);
/// Produces a blended loft between `a` (at `lower.z`) and `b` (at `upper.z`), with XY coordinates remapped to slide
/// between `lower.xy` and `upper.xy`.
///
/// `a` and `b` should be 2D shapes, i.e. invariant along the z axis.
Tree loft_between(Tree, Tree, TreeVec3, TreeVec3);

/// Section: Shapes

/// A 2D circle with the given radius and optional `center`.
Tree circle(TreeFloat r, TreeVec2 center);
/// A 2D ring with the given `outer`/`inner` radii and optional `center`.
Tree ring(TreeFloat outer, TreeFloat inner, TreeVec2 center);
/// A polygon with center-to-vertex distance `r` and `n` sides.
Tree polygon(TreeFloat r, int n, TreeVec2 center);
/// A rectangle with the given bounding corners.
Tree rectangle(TreeVec2, TreeVec2);
/// A rectangle with rounded corners.
Tree rounded_rectangle(TreeVec2, TreeVec2, TreeFloat);
/// A rectangle from an exact distance field.
Tree rectangle_exact(TreeVec2, TreeVec2);
/// An exact-field rectangle at the (optional) center.
Tree rectangle_centered_exact(TreeVec2, TreeVec2);
/// A 2D triangle.
Tree triangle(TreeVec2, TreeVec2, TreeVec2);
/// A box with the given bounds, which will stay creased if offset.
Tree box_mitered(TreeVec3, TreeVec3);
/// ditto
alias cube = box_mitered;
/// ditto
alias box = box_mitered;
/// A box with the given size and (optional) center, with edges that will stay sharp if offset.
Tree box_mitered_centered(TreeVec3 size, TreeVec3 center);
/// ditto
alias cube_centered = box_mitered_centered;
/// ditto
alias box_centered = box_mitered_centered;
/// A box with the given size, centered around the given point, with a Euclidean distance metric.
Tree box_exact_centered(TreeVec3 size, TreeVec3 center);
/// A box with the given bounds with a Euclidean distance metric.
Tree box_exact(TreeVec3 a, TreeVec3 b);
/// Rounded box with the given bounds and radius (as a 0-1 fraction).
Tree rounded_box(TreeVec3, TreeVec3, TreeFloat);
/// A sphere with the given radius and (optional) center.
Tree sphere(float radius, Vec3 center = Vec3.init) {
  return sphere(new Tree(radius), center);
}
/// ditto
Tree sphere(TreeFloat radius, Vec3 center = Vec3.init) {
  return sphere(radius, center);
}
/// ditto
Tree sphere(TreeFloat radius, TreeVec3 center = TreeVec3.zero) {
  return new Tree(stdlib.sphere(radius.ptr, stdlib.tvec3(center.x.ptr, center.y.ptr, center.z.ptr)));
}
/// A plane which divides the world into inside and outside, defined by its normal and a single point on the plane.
Tree half_space(TreeVec3, TreeVec3);
/// A cylinder with the given radius and height, extruded from the (optional) base position.
Tree cylinder_z(TreeFloat, TreeFloat, TreeVec3);
/// A cone defined by its slope angle, height, and (optional) base location.
Tree cone_ang_z(TreeFloat, TreeFloat, TreeVec3);
/// A cone defined by its radius, height, and (optional) base location.
Tree cone_z(TreeFloat, TreeFloat, TreeVec3);
/// A pyramid defined by its base rectangle, lower Z value, and height.
Tree pyramid_z(TreeVec2, TreeVec2, TreeFloat, TreeFloat);
/// A torus with the given outer radius, inner radius, and (optional) center.
Tree torus_z(TreeFloat, TreeFloat, TreeVec3);
/// A volume-filling gyroid with the given periods and thickness.
/// Remarks: A gyroid arises naturally in polymer science and biology, as an interface with high surface area.
/// See_Also: <a href="https://en.wikipedia.org/wiki/Gyroid">Gyroid</a> (Wikipedia)
Tree gyroid(TreeVec3, TreeFloat);
/// A value which is empty everywhere.
Tree emptiness_();
/// Iterates a part in a 1D array.
Tree array_x(Tree shape, int nx, TreeFloat);
/// Iterates a part in a 2D array.
Tree array_xy(Tree shape, int nx, int ny, TreeVec2 delta);
/// Iterates a part in a 3D array.
Tree array_xyz(Tree shape, int nx, int ny, int nz, TreeVec3 delta);
/// Iterates a `shape` about an optional `center` position.
Tree array_polar_z(Tree shape, int n, TreeVec2 center = TreeVec2.zero);
/// Extrudes a 2D shape between `zmin` and `zmax`.
Tree extrude_z(Tree t, TreeFloat zmin, TreeFloat zmax);

unittest {
  auto s = sphere(0.5);
}

/// Section: Transforms

///
Tree move(Tree, TreeVec3);
///
Tree reflect_x(Tree, TreeFloat);
///
Tree reflect_y(Tree, TreeFloat);
///
Tree reflect_z(Tree, TreeFloat);
///
Tree reflect_xy(Tree);
///
Tree reflect_yz(Tree);
///
Tree reflect_xz(Tree);
///
Tree symmetric_x(Tree);
///
Tree symmetric_y(Tree);
///
Tree symmetric_z(Tree);
///
Tree scale_x(Tree, TreeFloat, TreeFloat);
///
Tree scale_y(Tree, TreeFloat, TreeFloat);
///
Tree scale_z(Tree, TreeFloat, TreeFloat);
///
Tree scale_xyz(Tree, TreeVec3, TreeVec3);
///
Tree rotate_x(Tree, TreeFloat, TreeVec3);
///
Tree rotate_y(Tree, TreeFloat, TreeVec3);
///
Tree rotate_z(Tree, TreeFloat, TreeVec3);
///
Tree taper_x_y(Tree, TreeVec2, TreeFloat, TreeFloat, TreeFloat);
///
Tree taper_xy_z(Tree, TreeVec3, TreeFloat, TreeFloat, TreeFloat);
///
Tree shear_x_y(Tree, TreeVec2, TreeFloat, TreeFloat, TreeFloat);
///
Tree repel(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_x(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_y(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_z(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_xy(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_yz(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree repel_xz(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_x(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_y(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_z(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_xy(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_yz(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree attract_xz(Tree, TreeVec3, TreeFloat, TreeFloat);
///
Tree revolve_y(Tree, TreeFloat);
///
Tree twirl_x(Tree, TreeFloat, TreeFloat, TreeVec3);
///
Tree twirl_axis_x(Tree, TreeFloat, TreeFloat, TreeVec3);
///
Tree twirl_y(Tree, TreeFloat, TreeFloat, TreeVec3);
///
Tree twirl_axis_y(Tree, TreeFloat, TreeFloat, TreeVec3);
///
Tree twirl_z(Tree, TreeFloat, TreeFloat, TreeVec3);
///
Tree twirl_axis_z(Tree, TreeFloat, TreeFloat, TreeVec3);

/// Section: Text

///
Tree text(const string, TreeVec2);
