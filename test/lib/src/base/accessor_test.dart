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

import "package:test/test.dart";
import "package:gltf/gltf.dart";

void main() {
  const String UNDEFINED_PROPERTY =
      "UNDEFINED_PROPERTY"; // should we import errors.dart?
  const String VALUE_OUT_OF_RANGE = "VALUE_OUT_OF_RANGE";
  const String COMPONENT_TYPE =
      "componentType"; //should we import members.dart?
  const String COUNT = "count";
  const String TYPE = "type";
  const String MAX = "max";
  const String MIN = "min";
  const String BUFFER_VIEW = "bufferView";
  const String INDICES = "indices";
  const String VALUES = "values";
  const String SPARSE = "sparse";
  const String BUFFER_VIEWS = "bufferViews";
  const String BYTE_LENGTH = "byteLength";

  test("An empty Accessor is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Accessor.fromMap(map, context);

    // There are 5 required elements, but max and min are gated on type and component type existing
    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 3);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.errors[1].type, UNDEFINED_PROPERTY);
    expect(context.errors[2].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to detect min/max are missing from Accessor", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[TYPE] = "SCALAR";
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 3);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.errors[1].type, UNDEFINED_PROPERTY);
    expect(context.errors[2].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated Accessor", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [0];
    map[MIN] = [0];
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated Sparse Accessor", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [0];
    map[MIN] = [0];
    map[SPARSE] = {
      COUNT: 1,
      INDICES: {BUFFER_VIEW: 0, COMPONENT_TYPE: 5121},
      VALUES: {BUFFER_VIEW: 0}
    };
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Validate if min is outside of range it is detected", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [0];
    map[MIN] = [-129];
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Validate if max is outside of range it is detected", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [128];
    map[MIN] = [0];
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Validate if float doesn't check min/max", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5126;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [128];
    map[MIN] = [-129];
    Context context = new Context();

    Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to Accessor", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [0];
    map[MIN] = [0];
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    Accessor accessor = Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    accessor.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to Sparse Accessor", () {
    Map<String, Object> map = new Map();
    map[COMPONENT_TYPE] = 5120;
    map[COUNT] = 1;
    map[TYPE] = "SCALAR";
    map[MAX] = [0];
    map[MIN] = [0];
    map[SPARSE] = {
      COUNT: 1,
      INDICES: {BUFFER_VIEW: 0, COMPONENT_TYPE: 5121},
      VALUES: {BUFFER_VIEW: 0}
    };
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[BUFFER_VIEWS] = [
      {BYTE_LENGTH: 1}
    ];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    Accessor accessor = Accessor.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    accessor.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

// Accessor Sparce Values Tests
  test("An empty Accessor Sparse Values is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    AccessorSparseValues.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validated Accessor Sparse Values", () {
    Map<String, Object> map = new Map();
    map[BUFFER_VIEW] = 0;
    Context context = new Context();

    AccessorSparseValues.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to Accessor Sparse Values", () {
    Map<String, Object> map = new Map();
    map[BUFFER_VIEW] = 0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[BUFFER_VIEWS] = [
      {BYTE_LENGTH: 1}
    ];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    AccessorSparseValues values = AccessorSparseValues.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    values.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

// Accessor Sparse Indices Tests
  test("An empty Accessor Sparse Indices is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    AccessorSparseIndices.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 2);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.errors[1].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validated Accessor Sparse Indices", () {
    Map<String, Object> map = new Map();
    map[BUFFER_VIEW] = 0;
    map[COMPONENT_TYPE] = 5121;
    Context context = new Context();

    AccessorSparseIndices.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to Accessor Sparse Indices", () {
    Map<String, Object> map = new Map();
    map[BUFFER_VIEW] = 0;
    map[COMPONENT_TYPE] = 5121;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[BUFFER_VIEWS] = [
      {BYTE_LENGTH: 1}
    ];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    AccessorSparseIndices indices = AccessorSparseIndices.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    indices.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

// Accessor Sparse Tests
  test("An empty Accessor Sparse is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    AccessorSparse.fromMap(map, context);

    // four errors reported are: 1 for Sparce, 2 for Indices, and 1 for Values
    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 4);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.errors[1].type, UNDEFINED_PROPERTY);
    expect(context.errors[2].type, UNDEFINED_PROPERTY);
    expect(context.errors[3].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validated Accessor Sparse", () {
    Map<String, Object> map = new Map();
    map[COUNT] = 1;
    map[INDICES] = {BUFFER_VIEW: 0, COMPONENT_TYPE: 5121};
    map[VALUES] = {BUFFER_VIEW: 0};
    Context context = new Context();

    AccessorSparse.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });
}
