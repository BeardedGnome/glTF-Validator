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
  const String VERSION = "version"; //should we import members.dart?
  const String UNDEFINED_PROPERTY = "UNDEFINED_PROPERTY"; // should we import errors.dart?
  const String TYPE_MISMATCH = "TYPE_MISMATCH";
  const String PATTERN_MISMATCH = "PATTERN_MISMATCH";

  test("An empty Asset is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Verify version 1.1 is valid", () {
    Map<String, Object> map = new Map();
    map[VERSION] = "1.1";
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Verify version required to be a string", () {
    Map<String, Object> map = new Map();
    map[VERSION] = 2.0;
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, TYPE_MISMATCH);
    expect(context.warnings.isEmpty, true);
  });

  test("Verify missing ones digit is invalid", () {
    Map<String, Object> map = new Map();
    map[VERSION] = ".1";
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, PATTERN_MISMATCH);
    expect(context.warnings.isEmpty, true);
  });

  test("Verify missing tenths digit is invalid", () {
    Map<String, Object> map = new Map();
    map[VERSION] = "1.";
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, PATTERN_MISMATCH);
    expect(context.warnings.isEmpty, true);
  });

    test("Verify missing decimal point is invalid", () {
    Map<String, Object> map = new Map();
    map[VERSION] = "10";
    Context context = new Context();

    Asset.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, PATTERN_MISMATCH);
    expect(context.warnings.isEmpty, true);
  });
}
