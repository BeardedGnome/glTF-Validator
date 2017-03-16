/*
 * # Copyright (c) 2016 The Khronos Group Inc.
 * # Copyright (c) 2016 Alexey Knyazev
 * #
 * # Licensed under the Apache License, Version 2.0 (the "License");
 * # you may not use this file except in compliance with the License.
 * # You may obtain a copy of the License at
 * #
 * #     http://www.apache.org/licenses/LICENSE-2.0
 * #
 * # Unless required by applicable law or agreed to in writing, software
 * # distributed under the License is distributed on an "AS IS" BASIS,
 * # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * # See the License for the specific language governing permissions and
 * # limitations under the License.
 */

library gltf.core.accessor;

import 'gltf_property.dart';
import 'package:gltf/src/gl.dart' as gl;

class Accessor extends GltfChildOfRootProperty implements Linkable {
  final String _bufferViewId;
  final int byteOffset;
  final int componentType;
  final bool normalized;
  final int count;
  final String type;
  final List<num> max;
  final List<num> min;
  final AccessorSparse accessorSparse;

  int get byteLength =>
      (gl.COMPONENT_TYPE_LENGTHS[componentType] *
              ACCESSOR_TYPES_LENGTHS[type]) *
          (count - 1) +
      gl.COMPONENT_TYPE_LENGTHS[componentType] * ACCESSOR_TYPES_LENGTHS[type];

  BufferView bufferView;

  Accessor._(
      this._bufferViewId,
      this.byteOffset,
      this.componentType,
      this.normalized,
      this.count,
      this.type,
      this.max,
      this.min,
      this.accessorSparse,
      String name,
      Map<String, Object> extensions,
      Object extras)
      : super(name, extensions, extras);

  String toString([_]) => super.toString({
        BUFFER_VIEW: _bufferViewId,
        BYTE_OFFSET: byteOffset,
        COMPONENT_TYPE: componentType,
        NORMALIZED: normalized,
        COUNT: count,
        TYPE: type,
        MAX: max,
        MIN: min,
        SPARSE: accessorSparse
      });

  static Accessor fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, ACCESSORS_MEMBERS, context);

    final byteOffset = getInt(map, BYTE_OFFSET, context, min: 0, def: 0);
    final componentType = getInt(map, COMPONENT_TYPE, context,
        req: true, list: gl.COMPONENT_TYPE_LENGTHS.keys);

    final normalized = getBool(map, NORMALIZED, context, def: false);

    final count = getInt(map, COUNT, context, req: true, min: 1);
    final type = getString(map, TYPE, context,
        req: true, list: ACCESSOR_TYPES_LENGTHS.keys);

    List<num> max;
    List<num> min;
    int minValue;
    int maxValue;
    if (componentType != null && componentType != gl.FLOAT) {
      minValue = gl.TYPE_MINS[componentType];
      maxValue = gl.TYPE_MAXS[componentType];
    }
    if (type != null) {
      min = getNumList(map, MIN, context,
          req: true,
          min: minValue,
          max: maxValue,
          minItems: 1,
          maxItems: 16,
          lengthsList: [ACCESSOR_TYPES_LENGTHS[type]]);
      max = getNumList(map, MAX, context,
          req: true,
          min: minValue,
          max: maxValue,
          minItems: 1,
          maxItems: 16,
          lengthsList: [ACCESSOR_TYPES_LENGTHS[type]]);
    }

    AccessorSparse sparse;
    final sparseMap = getMap(map, SPARSE, context);
    if (sparseMap.isNotEmpty) {
      context.path.add(SPARSE);
      sparse = AccessorSparse.fromMap(sparseMap, context);
      context.path.removeLast();
    }

    if (context.validate) {
      if (normalized && componentType == gl.FLOAT) {
        context.addIssue(GltfWarning.NORMALIZED_FLOAT, name: NORMALIZED);
      }

      if (componentType == gl.UNSIGNED_INT) {
        if (!context.glExtensionsUsed.contains(gl.OES_ELEMENT_INDEX_UINT)) {
          context.addIssue(GltfError.ACCESSOR_UINT_NO_EXT,
              name: COMPONENT_TYPE);
        }
        if (type != SCALAR) {
          context.addIssue(GltfError.ACCESSOR_UINT_NO_SCALAR,
              name: COMPONENT_TYPE);
        }
      }

      if (byteOffset != null && componentType != null && type != null) {
        if (byteOffset % gl.COMPONENT_TYPE_LENGTHS[componentType] != 0) {
          context.addIssue(GltfError.ACCESSOR_MULTIPLE_COMPONENT_TYPE,
              name: BYTE_OFFSET,
              args: [byteOffset, gl.COMPONENT_TYPE_LENGTHS[componentType]]);
        }
      }
    }
    return new Accessor._(
        getInt(map, BUFFER_VIEW, context).toString(), // tests needed
        byteOffset,
        componentType,
        normalized,
        count,
        type,
        max,
        min,
        sparse,
        getName(map, context),
        getExtensions(map, Accessor, context),
        getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    bufferView = gltf.bufferViews[_bufferViewId];

    if (context.validate && _bufferViewId != null && bufferView != null) {
      if (byteOffset != null &&
          componentType != null &&
          count != null &&
          type != null) {
        if (byteOffset > bufferView.byteLength) {
          context.addIssue(GltfError.ACCESSOR_TOO_LONG,
              name: BYTE_OFFSET,
              args: [byteOffset, _bufferViewId, bufferView.byteLength]);
        } else if (byteOffset + byteLength > bufferView.byteLength) {
          context.addIssue(GltfError.ACCESSOR_TOO_LONG,
              name: BYTE_LENGTH,
              args: [byteLength, _bufferViewId, bufferView.byteLength]);
        }
      }

      if (byteOffset != null &&
          componentType != null &&
          bufferView.byteOffset != null &&
          (bufferView.byteOffset + byteOffset) %
                  gl.COMPONENT_TYPE_LENGTHS[componentType] !=
              0) {
        context.addIssue(GltfError.ACCESSOR_TOTAL_MULTIPLE_COMPONENT_TYPE,
            name: BYTE_OFFSET,
            args: [
              bufferView.byteOffset + byteOffset,
              gl.COMPONENT_TYPE_LENGTHS[componentType]
            ]);
      }

      if (componentType != null && bufferView.target != null) {
        if (componentType == gl.UNSIGNED_INT &&
            bufferView.target != gl.ELEMENT_ARRAY_BUFFER) {
          context.addIssue(GltfError.ACCESSOR_UINT_NO_ELEMENT_ARRAY,
              name: COMPONENT_TYPE);
        }

        if (bufferView.target == gl.ELEMENT_ARRAY_BUFFER &&
            !gl.ELEMENT_ARRAY_TYPES.contains(componentType)) {
          context.addIssue(GltfError.ACCESSOR_INVALID_ELEMENT_ARRAY_TYPE,
              name: COMPONENT_TYPE, args: [componentType]);
        }

        if (bufferView.target != gl.ARRAY_BUFFER && normalized == true) {
          context.addIssue(GltfWarning.NORMALIZED_NON_ARRAY_BUFFER,
              name: NORMALIZED);
        }
      }
    }

    if (accessorSparse != null) accessorSparse.link(gltf, context);
  }
}

class AccessorSparse extends GltfProperty implements Linkable {
  final int count;
  final AccessorSparseIndices indices;
  final AccessorSparseValues values;

  AccessorSparse._(this.count, this.indices, this.values,
      Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  String toString([_]) =>
      super.toString({COUNT: count, INDICES: indices, VALUES: values});

  static AccessorSparse fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, ACCESSORS_SPARSE_MEMBERS, context);

    final indicesMap = getMap(map, INDICES, context);
    context.path.add(INDICES);
    final AccessorSparseIndices indices =
        AccessorSparseIndices.fromMap(indicesMap, context);
    context.path.removeLast();

    final valuesMap = getMap(map, VALUES, context);
    context.path.add(VALUES);
    final AccessorSparseValues values =
        AccessorSparseValues.fromMap(valuesMap, context);
    context.path.removeLast();

    return new AccessorSparse._(
        getInt(map, COUNT, context, req: true, min: 1),
        indices,
        values,
        getExtensions(map, AccessorSparse, context),
        getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    indices.link(gltf, context);
    values.link(gltf, context);
  }
}

class AccessorSparseIndices extends GltfProperty implements Linkable {
  final String _bufferViewId;
  final int byteOffset;
  final int componentType;

  BufferView bufferView;

  AccessorSparseIndices._(this._bufferViewId, this.byteOffset,
      this.componentType, Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  String toString([_]) => super.toString({
        BUFFER_VIEW: _bufferViewId,
        BYTE_OFFSET: byteOffset,
        COMPONENT_TYPE: componentType
      });

  static AccessorSparseIndices fromMap(
      Map<String, Object> map, Context context) {
    if (context.validate)
      checkMembers(map, ACCESSORS_SPARSE_INDICES_MEMBERS, context);

    return new AccessorSparseIndices._(
        getInt(map, BUFFER_VIEW, context, req: true).toString(),
        getInt(map, BYTE_OFFSET, context, min: 0, def: 0),
        getInt(map, COMPONENT_TYPE, context,
            req: true, list: gl.ACCESSOR_SPARCE_INDICES_COMPONENT_TYPES),
        getExtensions(map, AccessorSparseIndices, context),
        getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    bufferView = gltf.bufferViews[_bufferViewId];

    if (context.validate && _bufferViewId != null && bufferView != null) {
      if (byteOffset != null && componentType != null) {
        if (byteOffset > bufferView.byteLength) {
          context.addIssue(GltfError.ACCESSOR_TOO_LONG,
              name: BYTE_OFFSET,
              args: [byteOffset, _bufferViewId, bufferView.byteLength]);
        }
      }

      if (byteOffset != null &&
          componentType != null &&
          bufferView.byteOffset != null &&
          (bufferView.byteOffset + byteOffset) %
                  gl.COMPONENT_TYPE_LENGTHS[componentType] !=
              0) {
        context.addIssue(GltfError.ACCESSOR_TOTAL_MULTIPLE_COMPONENT_TYPE,
            name: BYTE_OFFSET,
            args: [
              bufferView.byteOffset + byteOffset,
              gl.COMPONENT_TYPE_LENGTHS[componentType]
            ]);
      }

      if (componentType != null && bufferView.target != null) {
        if (componentType == gl.UNSIGNED_INT &&
            bufferView.target != gl.ELEMENT_ARRAY_BUFFER) {
          context.addIssue(GltfError.ACCESSOR_UINT_NO_ELEMENT_ARRAY,
              name: COMPONENT_TYPE);
        }

        if (bufferView.target == gl.ELEMENT_ARRAY_BUFFER &&
            !gl.ELEMENT_ARRAY_TYPES.contains(componentType)) {
          context.addIssue(GltfError.ACCESSOR_INVALID_ELEMENT_ARRAY_TYPE,
              name: COMPONENT_TYPE, args: [componentType]);
        }
      }
    }
  }
}

class AccessorSparseValues extends GltfProperty implements Linkable {
  final String _bufferViewId;
  final int byteOffset;

  BufferView bufferView;

  AccessorSparseValues._(this._bufferViewId, this.byteOffset,
      Map<String, Object> extensions, Object extras)
      : super(extensions, extras);

  String toString([_]) =>
      super.toString({BUFFER_VIEW: _bufferViewId, BYTE_OFFSET: byteOffset});

  static AccessorSparseValues fromMap(
      Map<String, Object> map, Context context) {
    if (context.validate)
      checkMembers(map, ACCESSORS_SPARSE_VALUES_MEMBERS, context);

    return new AccessorSparseValues._(
        getInt(map, BUFFER_VIEW, context, req: true).toString(),
        getInt(map, BYTE_OFFSET, context, min: 0, def: 0),
        getExtensions(map, AccessorSparseValues, context),
        getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    bufferView = gltf.bufferViews[_bufferViewId];

    if (context.validate && _bufferViewId != null && bufferView != null) {
      if (byteOffset != null) {
        if (byteOffset > bufferView.byteLength) {
          context.addIssue(GltfError.ACCESSOR_TOO_LONG,
              name: BYTE_OFFSET,
              args: [byteOffset, _bufferViewId, bufferView.byteLength]);
        }
      }
    }
  }
}
