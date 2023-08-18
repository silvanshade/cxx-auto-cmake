# FIXME: express dependency on `FindClangFormat` somehow.

include(FetchContent)
include(FindPackageHandleStandardArgs)

# Fetch the `run-clang-format` script from GitHub.
FetchContent_Declare(
  run_clang_format
  GIT_REPOSITORY https://github.com/silvanshade/run-clang-format
  GIT_TAG cda7e00)
FetchContent_MakeAvailable(run_clang_format)

# Add the downloaded script to the CMake program path.
list(APPEND CMAKE_PROGRAM_PATH ${run_clang_format_SOURCE_DIR})

# Find the `run-clang-format` tool.
find_program(CxxAutoCMake_RunClangFormat_EXECUTABLE
  run-clang-format
  NAMES run-clang-format.py
  NO_CACHE
)

# NOTE: the `run-clang-format` tool does not have a `--version` option so we don't perform any
# version extraction logic.

# Configure the `run-clang-format` tool package variables.
find_package_handle_standard_args(RunClangFormat
  REQUIRED_VARS
    CxxAutoCMake_RunClangFormat_EXECUTABLE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_RunClangFormat_FOUND ${RunClangFormat_FOUND})

# Define the `run-clang-format` tool package targets.
if(${RunClangFormat_FOUND} AND NOT TARGET CxxAutoCMake::RunClangFormat)
  CxxAutoCMake_define_target_executable(RunClangFormat HAS_NO_VERSION)
endif()
