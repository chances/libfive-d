/// License: MPL-2.0
/// See_Also: <a href="https://github.com/libfive/libfive/blob/master/libfive/include/libfive/tree/tree.hpp">libfive/include/libfive/tree/tree.hpp</a>
module libfive.tree;

import std.meta : Alias;

import libfive.opcode;
import stdlib;

/// Section: Tree Abstractions
/// We accept trees for every argument, even those that would normally be floats, so that we can pass in free variables
/// to parameterize shapes.

///
struct TreeVec2 {
  import libfive : Vec2;

  ///
  Tree x, y;

  static TreeVec2 zero() {
    return TreeVec2(new Tree(0), new Tree(0));
  }

  ///
  TreeVec2 opAssign(float value) {
    x = new Tree(value);
    y = new Tree(value);
    return this;
  }
  ///
  TreeVec2 opAssign(Vec2 value) {
    x = new Tree(value.x);
    y = new Tree(value.y);
    return this;
  }
}

///
struct TreeVec3 {
  import libfive : Vec3;

  ///
  Tree x, y, z;

  static TreeVec3 zero() {
    return TreeVec3(new Tree(0), new Tree(0), new Tree(0));
  }

  ///
  TreeVec3 opAssign(float value) {
    x = new Tree(value);
    y = new Tree(value);
    z = new Tree(value);
    return this;
  }
  ///
  TreeVec3 opAssign(Vec3 value) {
    x = new Tree(value.x);
    y = new Tree(value.y);
    z = new Tree(value.z);
    return this;
  }
}
///
alias TreeFloat = Tree;

/// Opaque pointer representing a `Tree`'s unique ID.
/// See_Also: `Tree.id`
alias Id = const void*;
///
alias NativeTree = libfive_tree_*;

/// A Tree represents a tree of math expressions.
///
/// It is a data object (passed around by value), which is a reference-counted wrapper around a TreeData pointer on the
/// heap. This is a class because we have very particular needs:
///
/// $(UL
///   $(LI
///     For the C API, we want to release pointers without decrementing the reference count, which prohibits shared_ptr.
///   )
///   $(LI
///     When destroying deeply nested trees, use the heap rather than the stack to prevent overflow, which prohibits `struct`.
///   )
/// )
///
/// See_Also: <a href="https://github.com/libfive/libfive/blob/master/libfive/include/libfive/tree/tree.hpp">libfive/include/libfive/tree/tree.hpp</a>
class Tree {
  import libfive.opcode;
  import std.conv : castFrom, to;

  /// This is the managed pointer. It's mutable so that the destructor can swap it out for `null` when flattening out
  /// destruction of a Tree (to avoid blowing up the stack).
  package(libfive) NativeTree ptr = null;

  /// Unique identifier for the underlying clause. This is not automatically deduplicated, so the same logic trees may
  /// have different IDs.
  ///
  /// This is primarily used to uniquely identify free variables, i.e. trees returned from `Tree.var`.
  Id id() @trusted const nothrow {
    import std.exception : assumeWontThrow;
    return assumeWontThrow(libfive_tree_id(cast(NativeTree) this.ptr));
  }

  /// Constructor to build from the raw variant pointer. This is used to build a temporary Tree around a raw pointer
  /// acquired from `release()` in libfive's C API.
  this(Id raw) {
    this.ptr = castFrom!Id.to!NativeTree(raw);
  }
  /// Constructs a constant Tree with a floating-point value.
  this(float v) {
    this.ptr = libfive_tree_const(v);
  }

  ~this() {
    if (ptr !is null) libfive_tree_delete(this.ptr);
  }

  /// These are the main constructors used to build Trees.
  ///
  /// In code `X`, `Y`, and `Z` are singletons, since they're used a lot
  static Tree X() {
    return new Tree(libfive_tree_x());
  }
  /// ditto
  static Tree Y() {
    return new Tree(libfive_tree_y());
  }
  /// ditto
  static Tree Z() {
    return new Tree(libfive_tree_z());
  }

  ///
  static Tree one() {
    return new Tree(1);
  }

  /// Returns a tree for which `invalid` is `true` (under the hood, uses the `TreeInvalid` variant).
  static Tree invalid() {
    assert(0, "Unimplemented!");
  }

  /// Returns a new unique variable.
  static Tree var() {
    return new Tree(libfive_tree_var());
  }

  /// Constructs a tree with the given no-argument opcode.
  /// Returns: `null` if the opcode is invalid.
  static Tree nullary(Opcode op) {
    auto tree = libfive_tree_nullary(op.to!int);
    if (tree is null) return null;
    return new Tree(tree);
  }

  /// Constructs a tree with the given one-argument opcode.
  /// Returns: `null` if the opcode or argument is invalid.
  static Tree unary(Opcode op, const Tree a) {
    auto tree = libfive_tree_unary(op.to!int, cast(NativeTree) a.ptr);
    if (tree is null) return null;
    return new Tree(tree);
  }

  /// Constructs a tree with the given two-argument opcode.
  /// Returns: `null` if the opcode or arguments are invalid.
  static Tree binary(Opcode op, const Tree lhs, const Tree rhs) {
    auto tree = libfive_tree_binary(op.to!int, cast(NativeTree) lhs.ptr, cast(NativeTree) rhs.ptr);
    if (tree is null) return null;
    return new Tree(tree);
  }

  /// Returns a tree with all remap operations expanded.
  Tree flatten() inout {
    // FIXME: This may not be correct
    return this.optimized;
  }

  /// Returns a new tree which has been optimized!
  ///
  /// Remarks:
  /// An optimized tree is deduplicated: subexpressions which are logically the same become shared, to make evaluation
  /// more efficient.
  ///
  /// An optimized tree also has nested affine forms collapsed, e.g. (2*X + 3*Y) + 5*(X - Y) ==> 7*X - 2*Y
  ///
  /// If the input tree contained remap operations, it will be flattened before optimization.
  Tree optimized() inout {
    auto tree = libfive_tree_optimized(cast(NativeTree) this.ptr);
    if (tree is null) return null;
    return new Tree(tree);
  }

  /// If this tree is a constant value, returns that value.
  /// Throws: `libfive.data.ValueException` When this tree is not a constant value.
  float value() const {
    import libfive.data : ValueException;

    bool success;
    auto result = libfive_tree_get_const(cast(NativeTree) this.ptr, &success);
    if (!success) throw new ValueException("Accessed value of non-constant Tree");
    return result;
  }

  /// Counts the number of unique nodes in the tree.
  size_t size() const {
    assert(0, "Unimplemented!");
  }

  /// Remaps the coordinates of this tree, returning a new tree.
  /// Remarks: This is a constant-time lazy operation that is expanded during a call to `Tree.flatten` or `Tree.optimized`.
  Tree remap(Tree x, Tree y, Tree z) const {
    auto tree = libfive_tree_remap(cast(NativeTree) this.ptr, x.ptr, y.ptr, z.ptr);
    if (tree is null) return null;
    return new Tree(tree);
  }

  /// Substitutes a variable within a tree.
  /// Remarks: This is a constant-time lazy operation that is expanded during a call to `Tree.flatten` or `Tree.optimized`.
  /// Throws: `libfive.data.ApplyException` if `var` is not a tree from `Tree.var`
  Tree apply(Tree var, Tree value) const {
    import libfive.data : ApplyException;
    if (!var.isVar) throw new ApplyException("Can only apply with a variable as first argument");

    assert(value);
    assert(0, "Unimplemented!");
  }

  /// For associative arrays of `Tree`s.
  override size_t toHash() const @safe nothrow {
    return this.id.hashOf;
    // return (cast (size_t) this.id).hashOf;
  }
  /// ditto
  bool opEquals(R)(const R other) const {
    return this.toHash == other.toHash;
  }

  ///
  Tree opUnary(string op : "-")() const {
    return Tree.unary("min".opcode, this);
  }

  ///
  Tree opBinary(string op)(const double rhs) const {
    switch (op) {
      case "+": return Tree.binary("add".opcode, this, new Tree(rhs));
      case "-": return Tree.binary("sub".opcode, this, new Tree(rhs));
      case "*": return Tree.binary("mul".opcode, this, new Tree(rhs));
      case "/": return Tree.binary("div".opcode, this, new Tree(rhs));
      default: return Tree.binary(Opcode.invalid, this, new Tree(rhs));
    }
  }

  ///
  Tree opBinary(string op)(const Tree rhs) const {
    switch (op) {
      case "+": return Tree.binary("add".opcode, this, rhs);
      case "-": return Tree.binary("sub".opcode, this, rhs);
      case "*": return Tree.binary("mul".opcode, this, rhs);
      case "/": return Tree.binary("div".opcode, this, rhs);
      default: return Tree.binary(Opcode.invalid, this, rhs);
    }
  }

  // TODO: Use this to serialize trees
  override string toString() const @trusted {
    import std.string: fromStringz;

    auto ptr = libfive_tree_print(cast(NativeTree) this.ptr);
    assert(ptr);
    auto result = ptr.fromStringz.to!string.idup;
    libfive_free_str(ptr);
    return result;
  }
}

unittest {
  // Singletons
  assert(Tree.X() == Tree.X());

  // Operations and stuff
  // Using vars because they're unique
  const a = Tree.var();
  const b = Tree.var();
  assert(a != b);
  assert(a + 1);
  assert(a - 1);
  assert(a * 1);
  assert(a / 1);
  assert(a + b);
  assert(a - b);
  assert(a * b);
  assert(a / b);

  // Remapping
  auto x = Tree.X();
  assert(x.remap(Tree.Y(), Tree.X(), Tree.X()).optimized == Tree.Y());

  // Remapping to a constant
  auto t = x.remap(new Tree(12), Tree.X(), Tree.X()).flatten();
  assert(t.value == 12);

  // Collapsing while remapping
  x = Tree.X() + 5;
  t = x.remap(new Tree(3), Tree.X(), Tree.X()).flatten();
  assert(t.value == 8);

  import std.algorithm : equal;
  assert(x.remap(new Tree(3), Tree.X(), Tree.X()).toString.equal("(remap (+ x 5) 3 x x)"));
}

/// Returns: `true` if the given tree is a free variable
bool isVar(const Tree tree) {
  return libfive_tree_is_var(cast(NativeTree) tree.ptr);
}

unittest {
  assert(Tree.var().isVar);

  const tree = new Tree(2);
  assert(tree);
  assert(!tree.isVar);
}
