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
  const String INVALID_DATA_URI = "INVALID_DATA_URI";
  const String VALUE_NOT_IN_LIST = "VALUE_NOT_IN_LIST";
  const String URI = "uri"; //should we import members.dart?
  const String BUFFER_VIEW = "bufferView";
  const String MIMETYPE = "mimeType";
  const String BUFFER_VIEWS = "bufferViews";
  const String BYTE_LENGTH = "byteLength";

  test("An empty Image is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("An Image with URI and Buffer View is invalid", () {
    Map<String, Object> map = new Map();
    map[URI] = "a";
    map[BUFFER_VIEW] = 0;
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("An Image with an empty URI is invalid", () {
    Map<String, Object> map = new Map();
    map[URI] = "";
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, INVALID_DATA_URI);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated URI image", () {
    Map<String, Object> map = new Map();
    map[URI] = "a";
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

test("Image with invalid mime type", () {
    Map<String, Object> map = new Map();
    map[URI] = "a";
    map[MIMETYPE] = "image/bmp";
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated Buffer View image", () {
    Map<String, Object> map = new Map();
    map[BUFFER_VIEW] = 0;
    Context context = new Context();

    Image.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link gltf to URI Image", () {
    Map<String, Object> map = new Map();
    map[URI] = "a";
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[BUFFER_VIEWS] = [
      {BYTE_LENGTH: 1}
    ];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    Image image = Image.fromMap(map, context);

    image.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(image.bufferView, isNull);
  });

  test("Link gltf to BufferView Image", () {
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

    Image image = Image.fromMap(map, context);

    image.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(image.bufferView, isNotNull);
  });
}
