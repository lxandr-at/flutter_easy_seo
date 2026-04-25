library flutter_easy_seo;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'src/helper/platform_helper_stub.dart'
  if (dart.library.js_interop) 'src/helper/platform_helper_web.dart';

part 'src/extensions/all_extensions.dart';
part 'src/models/seo_metadata_models.dart';
part 'src/traversal/widget_tree_processor.dart';
part 'src/widgets/easy_seo.dart';
part 'src/widgets/wrappers/seo_text_wrapper.dart';
part 'src/widgets/wrappers/seo_container_wrapper.dart';
part 'src/widgets/wrappers/seo_article_wrapper.dart';
part 'src/widgets/wrappers/seo_aside_wrapper.dart';
part 'src/widgets/wrappers/seo_time_wrapper.dart';
part 'src/widgets/wrappers/seo_section_wrapper.dart';
part 'src/widgets/wrappers/seo_navigation_wrapper.dart';
part 'src/widgets/wrappers/seo_main_wrapper.dart';
part 'src/widgets/wrappers/seo_list_wrapper.dart';
part 'src/widgets/wrappers/seo_image_wrapper.dart';
part 'src/widgets/wrappers/seo_header_wrapper.dart';
part 'src/widgets/wrappers/seo_form_wrapper.dart';
part 'src/widgets/wrappers/seo_figure_wrapper.dart';
part 'src/widgets/wrappers/seo_custom_wrapper.dart';
part 'src/output/file_system_handler.dart';