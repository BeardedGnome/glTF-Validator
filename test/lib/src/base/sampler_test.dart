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
  //should we import members.dart?
  const String MAG_FILTER = "magFilter";
  const String MIN_FILTER = "minFilter";
  const String WRAP_S = "wrapS";
  const String WRAP_T = "wrapT";
  // should we import errors.dart?
  const String VALUE_NOT_IN_LIST = "VALUE_NOT_IN_LIST";

  test("An empty Sampler is valid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("A fully populated Sampler is valid", () {
    Map<String, Object> map = new Map();
    map[MAG_FILTER] = 9728;
    map[MIN_FILTER] = 9986;
    map[WRAP_S] = 10497;
    map[WRAP_T] = 10497;
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Invalid mag filter is detected", () {
    Map<String, Object> map = new Map();
    map[MAG_FILTER] = 0;
    map[MIN_FILTER] = 9986;
    map[WRAP_S] = 10497;
    map[WRAP_T] = 10497;
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });

  test("Invalid min filter is detected", () {
    Map<String, Object> map = new Map();
    map[MAG_FILTER] = 9728;
    map[MIN_FILTER] = 0;
    map[WRAP_S] = 10497;
    map[WRAP_T] = 10497;
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });

  test("Invalid wrap s is detected", () {
    Map<String, Object> map = new Map();
    map[MAG_FILTER] = 9728;
    map[MIN_FILTER] = 9986;
    map[WRAP_S] = 0;
    map[WRAP_T] = 10497;
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });

  test("Invalid wrap t is detected", () {
    Map<String, Object> map = new Map();
    map[MAG_FILTER] = 9728;
    map[MIN_FILTER] = 9986;
    map[WRAP_S] = 10497;
    map[WRAP_T] = 0;
    Context context = new Context();

    Sampler.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors.first.type, VALUE_NOT_IN_LIST);
    expect(context.warnings.isEmpty, true);
  });
}