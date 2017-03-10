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
  const String URI = "uri"; //should we import members.dart?
  const String BYTE_LENGTH = "byteLength";

  test("An empty Buffer is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Buffer.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 2);
    expect(context.errors.first.type, UNDEFINED_PROPERTY);
    expect(context.errors.last.type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum to create a validiated buffer", () {
    Map<String, Object> map = new Map();
    map[URI] = "";
    map[BYTE_LENGTH] = 0;
    Context context = new Context();

    Buffer.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });
}
