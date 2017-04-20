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
  const String SAMPLER = "sampler";
  const String SOURCE = "source";
  const String IMAGES = "images";
  const String SAMPLERS = "samplers";
  const String URI = "uri";

  test("An empty Texture is valid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Texture.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("An full Texture is valid", () {
    Map<String, Object> map = new Map();
    map[SAMPLER] = 0;
    map[SOURCE] = 0;
    Context context = new Context();

    Texture.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link a valid texture", () {
    Map<String, Object> map = new Map();
    map[SAMPLER] = 0;
    map[SOURCE] = 0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[SAMPLERS] = [{}];
    gltfMap[IMAGES] = [{ URI : "" }];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    Texture texture = Texture.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    texture.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(texture.sampler, isNotNull);
    expect(texture.source, isNotNull);
  });
}