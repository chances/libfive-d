/// License: MPL-2.0
/// See_Also: <a href="https://github.com/libfive/libfive/blob/master/libfive/includelibfive/render/brep/mesh.hpp">libfive/includelibfive/render/brep/mesh.hpp</a>
module libfive.mesh;

import libfive.stdlib;
import libfive.tree;

/// An indexed 3D mesh.
struct Mesh {
  import libfive: Region3, Tri, Vec3;
  import std.conv: castFrom;

  /// Opaque pointer to C API-managed mesh.
  package libfive_mesh* mesh;

  ~this() {
    libfive_mesh_delete(mesh);
    mesh = null;
  }

  ///
  Vec3[] verts() inout {
    return castFrom!(inout(Vec3)[]).to!(Vec3[])(mesh.verts[0 .. mesh.vert_count]);
  }
  ///
  Tri[] tris() inout {
    return castFrom!(inout(Tri)[]).to!(Tri[])(mesh.tris[0 .. mesh.tri_count]);
  }

  /// Renders a tree to a set of triangles
  ///
  /// R is a region that will be subdivided into an octree. For clean triangles, it should be near-cubical, but that isn't a hard requirement.
  ///
  /// res should be approximately half the model's smallest feature size;
  /// subdivision halts when all sides of the region are below it.
  ///
  /// Returns: `null` if min_feature is invalid or cancel is set to `true` partway through the computation.
  static auto render(const Tree tree, const Region3 region, float res) {
    return Mesh(libfive_tree_render_mesh(cast(NativeTree) tree.ptr, region, res));
  }
}

unittest {
  auto s = sphere(0.5);
}

///
size_t triCount(const Mesh m) {
  return m.tris.length;
}
