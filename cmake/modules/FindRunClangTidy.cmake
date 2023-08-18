include(FindPackageHandleStandardArgs)

# FIXME: express dependency on `FindClangTidy` somehow.

set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `run-clang-tidy` tool.
find_program(CxxAutoCMake_RunClangTidy_EXECUTABLE run-clang-tidy
  NAMES run-clang-tidy.py
  HINTS ${LLVMConfig_BINARY_DIR}
  NO_CACHE
)

# NOTE: the `run-clang-tidy` tool does not have a `--version` option so we don't perform any
# version extraction logic.

# Configure the `run-clang-tidy` tool package variables.
find_package_handle_standard_args(RunClangTidy
  REQUIRED_VARS
    CxxAutoCMake_RunClangTidy_EXECUTABLE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_RunClangTidy_FOUND ${RunClangTidy_FOUND})

# Define the `run-clang-tidy` tool package targets.
if(${RunClangTidy_FOUND} AND NOT TARGET CxxAutoCMake::RunClangTidy)
  CxxAutoCMake_define_target_executable(RunClangTidy HAS_NO_VERSION)
endif()
