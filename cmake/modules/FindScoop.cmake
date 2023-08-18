# Configure the `Scoop` tool package variables.
find_package_handle_standard_args(Scoop
  REQUIRED_VARS
    CxxAutoCMake_Scoop_EXECUTABLE
  VERSION_VAR Scoop_VERSION
  HANDLE_VERSION_RANGE)
set_property(GLOBAL PROPERTY CxxAutoCMake_Scoop_FOUND ${Scoop_FOUND})

# Define the `Scoop` tool package targets.
if(${Scoop_FOUND} AND NOT TARGET CxxAutoCMake::Scoop)
  CxxAutoCMake_define_target_executable(Scoop)
endif()
