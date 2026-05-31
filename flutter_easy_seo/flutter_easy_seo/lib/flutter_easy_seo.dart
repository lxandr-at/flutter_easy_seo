library flutter_easy_seo;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/utils/url_helper_facade.dart' as url_helper;

// Import the "facade" which handles the platform switching
import 'src/output/easy_seo_file_output_facade.dart';
import 'src/output/easy_seo_live_output_facade.dart';
import 'src/utils/platform_helper_facade.dart';

export 'src/utils/platform_helper_facade.dart';
export 'src/utils/url_helper_facade.dart';

part 'src/extensions/all_extensions.dart';
part 'src/extensions/widget_extensions.dart';
part 'src/extensions/string_extensions.dart';
part 'src/interfaces/easy_seo_text_content.dart';
part 'src/models/seo_gen_result.dart';
part 'src/models/seo_metadata_models.dart';
part 'src/models/seo_html.dart';
part 'src/traversal/widget_tree_processor.dart';
part 'src/easy_seo_manager.dart';
part 'src/widgets/easy_seo_page.dart';
part 'src/widgets/easy_seo_interactive_overlay.dart';
part 'src/widgets/config/easy_seo_config_widget.dart';
part 'src/widgets/wrappers/seo_base_wrapper.dart';
part 'src/widgets/wrappers/seo_text_wrapper.dart';
part 'src/widgets/wrappers/seo_container_wrapper.dart';
part 'src/widgets/wrappers/seo_article_wrapper.dart';
part 'src/widgets/wrappers/seo_aside_wrapper.dart';
part 'src/widgets/wrappers/seo_time_wrapper.dart';
part 'src/widgets/wrappers/seo_section_wrapper.dart';
part 'src/widgets/wrappers/seo_nav_wrapper.dart';
part 'src/widgets/wrappers/seo_main_wrapper.dart';
part 'src/widgets/wrappers/seo_list_wrapper.dart';
part 'src/widgets/wrappers/seo_list_item_wrapper.dart';
part 'src/widgets/wrappers/seo_image_wrapper.dart';
part 'src/widgets/wrappers/seo_header_wrapper.dart';
part 'src/widgets/wrappers/seo_form_wrapper.dart';
part 'src/widgets/wrappers/seo_figure_wrapper.dart';
part 'src/widgets/wrappers/seo_custom_wrapper.dart';
part 'src/widgets/wrappers/seo_nav_link_wrapper.dart';
