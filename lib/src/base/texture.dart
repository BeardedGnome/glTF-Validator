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

library gltf.core.texture;

import 'gltf_property.dart';

class Texture extends GltfChildOfRootProperty implements Linkable {
  final String _samplerId;
  final String _sourceId;

  Sampler sampler;
  Image source;

  Texture._(
      this._samplerId,
      this._sourceId,
      String name,
      Map<String, Object> extensions,
      Object extras)
      : super(name, extensions, extras);

  String toString([_]) => super.toString({
        SAMPLER: _samplerId,
        SOURCE: _sourceId
      });

  static Texture fromMap(Map<String, Object> map, Context context) {
    if (context.validate) checkMembers(map, TEXTURE_MEMBERS, context);

    return new Texture._(
        getInt(map, SAMPLER, context, min: 0).toString(),
        getInt(map, SOURCE, context, min: 0).toString(),
        getName(map, context),
        getExtensions(map, Texture, context),
        getExtras(map));
  }

  void link(Gltf gltf, Context context) {
    source = gltf.images[_sourceId];
    if (context.validate && source == null)
      context.addIssue(GltfError.UNRESOLVED_REFERENCE,
          name: SOURCE, args: [_sourceId]);

    sampler = gltf.samplers[_samplerId];
    if (context.validate && sampler == null)
      context.addIssue(GltfError.UNRESOLVED_REFERENCE,
          name: SAMPLER, args: [_samplerId]);
  }
}
