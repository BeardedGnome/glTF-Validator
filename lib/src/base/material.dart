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

library gltf.core.material;

import 'gltf_property.dart';

class Material extends GltfChildOfRootProperty implements Linkable {
  final MaterialPbrMetallicRoughness pbrMetallicRoughness;
  final MaterialNormalTextureInfo normalTexture;
  final MaterialOcclusionTextureInfo occlusionTexture;
  final TextureInfo emissiveTexture;
  final List<num> emissiveFactor;
  final String alphaMode;
  final num alphaCutoff;
  final bool doubleSided;

  Material._(this.pbrMetallicRoughness, this.normalTexture, this.occlusionTexture, this.emissiveTexture,
    this.emissiveFactor, this.alphaMode, this.alphaCutoff, this.doubleSided,
    String name, Map<String, Object> extensions, Object extras)
    : super(name, extensions, extras);

  String toString([_]) => super.toString({
    PBR_METALLIC_ROUGHNESS: pbrMetallicRoughness,
    NORMAL_TEXTURE: normalTexture,
    OCCLUSION_TEXTURE: occlusionTexture,
    EMISSIVE_TEXTURE: emissiveTexture,
    EMISSIVE_FACTOR: emissiveFactor,
    ALPHA_MODE: alphaMode,
    ALPHA_CUTOFF: alphaCutoff,
    DOUBLE_SIDED: doubleSided
  });

  static Material fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, MATERIAL_MEMBERS, context);

    MaterialPbrMetallicRoughness roughness;
    final roughnessMap = getMap(map, PBR_METALLIC_ROUGHNESS, context);
    if (roughnessMap.isNotEmpty) {
      context.path.add(PBR_METALLIC_ROUGHNESS);
      roughness = MaterialPbrMetallicRoughness.fromMap(roughnessMap, context);
      context.path.removeLast();
    }

    MaterialNormalTextureInfo normal;
    final normalMap = getMap(map, NORMAL_TEXTURE, context);
    if (normalMap.isNotEmpty) {
      context.path.add(NORMAL_TEXTURE);
      normal = MaterialNormalTextureInfo.fromMap(normalMap, context);
      context.path.removeLast();
    }

    MaterialOcclusionTextureInfo occlusion;
    final occlusionMap = getMap(map, OCCLUSION_TEXTURE, context);
    if (occlusionMap.isNotEmpty) {
      context.path.add(OCCLUSION_TEXTURE);
      occlusion = MaterialOcclusionTextureInfo.fromMap(occlusionMap, context);
      context.path.removeLast();
    }

    TextureInfo emissive;
    final emissiveMap = getMap(map, EMISSIVE_TEXTURE, context);
    if (emissiveMap.isNotEmpty) {
      context.path.add(EMISSIVE_TEXTURE);
      emissive = TextureInfo.fromMap(emissiveMap, context);
      context.path.removeLast();
    }

    const List<String> alphaModeEnum = const <String>[
      OPAQUE,
      MASK,
      BLEND
    ];

    return new Material._(
      roughness,
      normal,
      occlusion,
      emissive,
      getNumList(map, EMISSIVE_FACTOR, context, min: 0.0, max: 1.0, minItems: 3, maxItems: 3, def: [ 0.0, 0.0, 0.0 ]),
      getString(map, ALPHA_MODE, context, list: alphaModeEnum, def: OPAQUE),
      getNum(map, ALPHA_CUTOFF, context, min: 0.0, def: 0.5),
      getBool(map, DOUBLE_SIDED, context, def: false),
      getName(map, context),
      getExtensions(map, Material, context),
      getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    if (normalTexture != null) normalTexture.link(gltf, context);
    if (occlusionTexture != null) occlusionTexture.link(gltf, context);
    if (emissiveTexture != null) emissiveTexture.link(gltf, context);
  }
}

class MaterialPbrMetallicRoughness extends Stringable {
  final List<num> baseColorFactor;
  final TextureInfo baseColorTexture;
  final num metallicFactor;
  final num roughnessFactor;
  final TextureInfo metallicRoughnessTexture;

  MaterialPbrMetallicRoughness._(this.baseColorFactor, this.baseColorTexture, this.metallicFactor, this.roughnessFactor, this.metallicRoughnessTexture)
      : super();

  String toString([_]) => super.toString({
      BASE_COLOR_FACTOR: baseColorFactor,
      BASE_COLOR_TEXTURE: baseColorTexture,
      METALLIC_FACTOR: metallicFactor,
      ROUGHNESS_FACTOR: roughnessFactor,
      METALLIC_ROUGHNESS_TEXTURE: metallicRoughnessTexture
    });

  static MaterialPbrMetallicRoughness fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, MATERIAL_PBR_METALLIC_ROUGHNESS_MEMBERS, context);

    TextureInfo colorTexture;
    final colorMap = getMap(map, BASE_COLOR_TEXTURE, context);
    if (colorMap.isNotEmpty) {
      context.path.add(BASE_COLOR_TEXTURE);
      colorTexture = TextureInfo.fromMap(colorMap, context);
      context.path.removeLast();
    }

    TextureInfo roughnessTexture;
    final roughnessMap = getMap(map, METALLIC_ROUGHNESS_TEXTURE, context);
    if (roughnessMap.isNotEmpty) {
      context.path.add(METALLIC_ROUGHNESS_TEXTURE);
      roughnessTexture = TextureInfo.fromMap(roughnessMap, context);
      context.path.removeLast();
    }

    return new MaterialPbrMetallicRoughness._(
      getNumList(map, BASE_COLOR_FACTOR, context, min: 0.0, max: 1.0, minItems: 4, maxItems: 4, def: [ 1.0, 1.0, 1.0, 1.0 ]),
      colorTexture,
      getNum(map, METALLIC_FACTOR, context, min: 0.0, max: 1.0, def: 1.0),
      getNum(map, ROUGHNESS_FACTOR, context, min: 0.0, max: 1.0, def: 1.0),
      roughnessTexture
    );
  }
}

class MaterialNormalTextureInfo extends Stringable implements Linkable {
  final String _textureId; // index
  final int texCoord;
  final num scale;

  Texture texture;

  MaterialNormalTextureInfo._(this._textureId, this.texCoord, this.scale)
      : super();

  String toString([_]) => super.toString({
      INDEX: _textureId,
      TEX_COORD: texCoord,
      SCALE: scale
    });

  static MaterialNormalTextureInfo fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, MATERIAL_NORMAL_TEXTURE_MEMBERS, context);

    return new MaterialNormalTextureInfo._(
      getInt(map, INDEX, context, req: true, min: 0).toString(),
      getInt(map, TEX_COORD, context, min: 0, def: 0),
      getNum(map, SCALE, context, def: 1.0)
    );
  }

  void link(Gltf gltf, Context context) {
    texture = gltf.textures[_textureId];

    if (context.validate && texture == null) {
      context.addIssue(GltfError.UNRESOLVED_REFERENCE,
          name: INDEX, args: [_textureId]);
    }
  }
}

class MaterialOcclusionTextureInfo extends Stringable implements Linkable {
  final String _textureId; // index
  final int texCoord;
  final num strength;

  Texture texture;

  MaterialOcclusionTextureInfo._(this._textureId, this.texCoord, this.strength)
      : super();

  String toString([_]) => super.toString({
      INDEX: _textureId,
      TEX_COORD: texCoord,
      STRENGTH: strength
    });

  static MaterialOcclusionTextureInfo fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, MATERIAL_OCCLUSION_TEXTURE_MEMBERS, context);

    return new MaterialOcclusionTextureInfo._(
      getInt(map, INDEX, context, req: true, min: 0).toString(),
      getInt(map, TEX_COORD, context, min: 0, def: 0),
      getNum(map, STRENGTH, context, min: 0.0, max: 1.0, def: 1.0)
    );
  }

  void link(Gltf gltf, Context context) {
    texture = gltf.textures[_textureId];

    if (context.validate && texture == null) {
      context.addIssue(GltfError.UNRESOLVED_REFERENCE,
          name: INDEX, args: [_textureId]);
    }
  }
}

class TextureInfo extends Stringable implements Linkable {
  final String _textureId; // index
  final int texCoord;

  Texture texture;

  TextureInfo._(this._textureId, this.texCoord)
      : super();

  String toString([_]) => super.toString({
      INDEX: _textureId,
      TEX_COORD: texCoord
    });

  static TextureInfo fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, TEXTURE_INFO_MEMBERS, context);

    return new TextureInfo._(
      getInt(map, INDEX, context, req: true, min: 0).toString(),
      getInt(map, TEX_COORD, context, min: 0, def: 0)
    );
  }

  void link(Gltf gltf, Context context) {
    texture = gltf.textures[_textureId];

    if (context.validate && texture == null) {
      context.addIssue(GltfError.UNRESOLVED_REFERENCE,
          name: INDEX, args: [_textureId]);
    }
  }
}