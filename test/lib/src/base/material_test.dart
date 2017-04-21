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
  const String PBR_METALLIC_ROUGHNESS = "pbrMetallicRoughness";
  const String NORMAL_TEXTURE = "normalTexture";
  const String OCCLUSION_TEXTURE = "occlusionTexture";
  const String EMISSIVE_TEXTURE = "emissiveTexture";
  const String EMISSIVE_FACTOR = "emissiveFactor";
  const String ALPHA_MODE = "alphaMode";
  const String ALPHA_CUTOFF = "alphaCutoff";
  const String DOUBLE_SIDED = "doubleSided";
  const String INDEX = "index";
  const String TEX_COORD = "texCoord";
  const String TEXTURES = "textures";
  const String STRENGTH = "strength";
  const String SCALE = "scale";
  const String BASE_COLOR_FACTOR = "baseColorFactor";
  const String BASE_COLOR_TEXTURE = "baseColorTexture";
  const String METALLIC_FACTOR = "metallicFactor";
  const String ROUGHNESS_FACTOR = "roughnessFactor";
  const String METALLIC_ROUGHNESS_TEXTURE = "metallicRoughnessTexture";
  // should we import errors.dart?
  const String UNDEFINED_PROPERTY = "UNDEFINED_PROPERTY";
  //const String TYPE_MISMATCH = "TYPE_MISMATCH";
  //const String PATTERN_MISMATCH = "PATTERN_MISMATCH";

  test("An empty Material is valid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    Material.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("A full Material is valid", () {
    Map<String, Object> map = new Map();
    map[PBR_METALLIC_ROUGHNESS] = {METALLIC_FACTOR: 0.0};
    map[NORMAL_TEXTURE] = {INDEX: 0};
    map[OCCLUSION_TEXTURE] = {INDEX: 0};
    map[EMISSIVE_TEXTURE] =  {INDEX: 0};
    map[EMISSIVE_FACTOR] = [ 0.0, 0.0, 0.0 ];
    map[ALPHA_MODE] = "OPAQUE";
    map[ALPHA_CUTOFF] = 0.5;
    map[DOUBLE_SIDED] = false;
    Context context = new Context();

    Material material = Material.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(material.pbrMetallicRoughness, isNotNull);
    expect(material.normalTexture, isNotNull);
    expect(material.occlusionTexture, isNotNull);
    expect(material.emissiveTexture, isNotNull);
  });

  test("Link a full Material", () {
    Map<String, Object> map = new Map();
    map[PBR_METALLIC_ROUGHNESS] = {METALLIC_FACTOR: 0.0};
    map[NORMAL_TEXTURE] = {INDEX: 0};
    map[OCCLUSION_TEXTURE] = {INDEX: 1};
    map[EMISSIVE_TEXTURE] =  {INDEX: 2};
    map[EMISSIVE_FACTOR] = [ 0.0, 0.0, 0.0 ];
    map[ALPHA_MODE] = "OPAQUE";
    map[ALPHA_CUTOFF] = 0.5;
    map[DOUBLE_SIDED] = false;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[TEXTURES] = [{}, {}, {}];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    Material material = Material.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(material.pbrMetallicRoughness, isNotNull);
    expect(material.normalTexture, isNotNull);
    expect(material.occlusionTexture, isNotNull);
    expect(material.emissiveTexture, isNotNull);

    material.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(material.normalTexture.texture, isNotNull);
    expect(material.occlusionTexture.texture, isNotNull);
    expect(material.emissiveTexture.texture, isNotNull);
  });

  // MaterialPbrMetallicRoughness
  test("An empty MaterialPbrMetalicRoughness is valid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    MaterialPbrMetallicRoughness roughness = MaterialPbrMetallicRoughness.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(roughness, isNotNull);
  });

  test("A full MaterialPbrMetalicRoughness is valid", () {
    Map<String, Object> map = new Map();
    map[BASE_COLOR_FACTOR] = [ 1.0, 1.0, 1.0, 1.0 ];
    map[BASE_COLOR_TEXTURE] = {INDEX: 0};
    map[METALLIC_FACTOR] = 1.0;
    map[ROUGHNESS_FACTOR] = 1.0;
    map[METALLIC_ROUGHNESS_TEXTURE] = {INDEX: 0};
    Context context = new Context();

    MaterialPbrMetallicRoughness pbr = MaterialPbrMetallicRoughness.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(pbr.baseColorTexture, isNotNull);
    expect(pbr.metallicRoughnessTexture, isNotNull);
  });

  // MaterialNormalTextureInfo
  test("An empty MaterialNormalTextureInfo is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    MaterialNormalTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum valid MaterialNormalTextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    Context context = new Context();

    MaterialNormalTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("A full MaterialNormalTextureInfo is valid", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    map[SCALE] = 1.0;
    Context context = new Context();

    MaterialNormalTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link full MaterialNormalTextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    map[SCALE] = 1.0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[TEXTURES] = [{}];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    MaterialNormalTextureInfo textureInfo = MaterialNormalTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    textureInfo.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(textureInfo.texture, isNotNull);
  });

  // MaterialOcclusionTextureInfo
  test("An empty MaterialOcclusionTextureInfo is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    MaterialOcclusionTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum valid MaterialOcclusionTextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    Context context = new Context();

    MaterialOcclusionTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("A full MaterialOcclusionTextureInfo is valid", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    map[STRENGTH] = 1.0;
    Context context = new Context();

    MaterialOcclusionTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link full MaterialOcclusionTextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    map[STRENGTH] = 1.0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[TEXTURES] = [{}];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    MaterialOcclusionTextureInfo textureInfo = MaterialOcclusionTextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    textureInfo.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(textureInfo.texture, isNotNull);
  });

  // TextureInfo
  test("An empty TextureInfo is invalid", () {
    Map<String, Object> map = new Map();
    Context context = new Context();

    TextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, false);
    expect(context.errors.length, 1);
    expect(context.errors[0].type, UNDEFINED_PROPERTY);
    expect(context.warnings.isEmpty, true);
  });

  test("Minimum valid TextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    Context context = new Context();

    TextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("A full TextureInfo is valid", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    Context context = new Context();

    TextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);
  });

  test("Link full TextureInfo", () {
    Map<String, Object> map = new Map();
    map[INDEX] = 0;
    map[TEX_COORD] = 0;
    Context context = new Context();

    Map<String, Object> gltfMap = new Map();
    gltfMap[TEXTURES] = [{}];
    Context gltfContext = new Context();
    Gltf gltf = new Gltf.fromMap(gltfMap, gltfContext);

    expect(gltfContext.errors.isNotEmpty, true);
    expect(gltfContext.warnings.isEmpty, true);

    TextureInfo textureInfo = TextureInfo.fromMap(map, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    textureInfo.link(gltf, context);

    expect(context.errors.isEmpty, true);
    expect(context.warnings.isEmpty, true);

    expect(textureInfo.texture, isNotNull);
  });
}