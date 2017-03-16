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
  const String VALUE_NOT_IN_LIST = "VALUE_NOT_IN_LIST";
  const String TYPE_MISMATCH = "TYPE_MISMATCH";
  const String BUFFER = "buffer"; //should we import members.dart?
  const String BYTE_OFFSET = "byteOffset";
  const String BYTE_LENGTH = "byteLength";
  const String BYTE_STRIDE = "byteStride";
  const String TARGET = "target";
  const String BUFFERS = "buffers";

  test("An empty Buffer View is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 3);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.errors[1].type, UNDEFINED_PROPERTY);
    expect(context.errors[2].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated Buffer View", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Buffer index must be at least 0", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = -1;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Buffer index must be an integer", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = "0";
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, TYPE_MISMATCH);
    expect(context.warnings.isEmpty, true);
  });

  test("Byte Offset must be at least 0", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = -1;
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Byte Length must be at least 0", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = -1;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Byte Stride must be at least 0", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    map[BYTE_STRIDE] = -1;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Byte Stride must be less than 256", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    map[BYTE_STRIDE] = 256;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_OUT_OF_RANGE);
    expect(context.warnings.isEmpty, true);
  });

  test("Target must be valid enum [34962, 34963]", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    map[TARGET] = 0;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });

  test("Target as array buffer: 34962", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    map[TARGET] = 34962;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Target as element array buffer: 34963", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    map[TARGET] = 34963;
    Context context = new Context();

    BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to buffer views", () {
    Map<String, Object> map = new Map();
    map[BUFFER] = 0;
    map[BYTE_OFFSET] = 0;
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[BUFFERS] = [
      {BYTE_LENGTH: 1}
    ];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    BufferView bufferView = BufferView.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    bufferView.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });
}
