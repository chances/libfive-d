/// License: MPL-2.0
/// See_Also: <a href="https://github.com/libfive/libfive/blob/master/libfive/include/libfive/tree/data.hpp">libfive/include/libfive/tree/data.hpp</a>
module libfive.data;

import std.exception : basicExceptionCtors;

/// Thrown when `Tree.value` is called on a tree that is not a constant value.
class ValueException : Exception {
  ///
  mixin basicExceptionCtors;
}

