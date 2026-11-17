//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <inside_scoop/inside_scoop_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) inside_scoop_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "InsideScoopPlugin");
  inside_scoop_plugin_register_with_registrar(inside_scoop_registrar);
}
