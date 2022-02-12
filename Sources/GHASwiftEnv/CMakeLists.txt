add_library(GHASwiftEnv
  GHASwiftEnv.swift)

target_link_libraries(GHASwiftEnv PUBLIC
  $<$<NOT:$<PLATFORM_ID:Darwin>>:Foundation>)

set_target_properties(GHASwiftEnv PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

install_swift_module(GHASwiftEnv)
set_property(GLOBAL APPEND PROPERTY GHA_SWIFT_ENV_EXPORTS GHASwiftEnv)
