include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/LLVM/Support)

# The `clangd` tool version extraction regex.
set(ClangD_VERSION_REGEX "([^ \t\r\n]*)[ \t\r\n]*clangd${LLVM_TOOL_VERSION_REGEX}")
set(ClangD_VERSION_TOTAL_MATCH 2)
set(ClangD_VERSION_MAJOR_MATCH 3)
set(ClangD_VERSION_MINOR_MATCH 5)
set(ClangD_VERSION_PATCH_MATCH 7)
set(ClangD_VERSION_TWEAK_MATCH 9)
set(ClangD_VARIANT_MATCH 1)

# The `clangd` tool validation function.
function(validator result candidate)
  # Obtain the `clangd` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `clangd` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(ClangD
    ClangD_VERSION_REGEX
    ClangD_VERSION_TOTAL_MATCH
    ClangD_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Validate the `clangd` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(ClangD_VARIANT_MATCH result)
endfunction()

# Recover variables from `LLVMConfig` target properties.
set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `clangd` tool.
CxxAutoCMake_find_program(ClangD clangd
  HINTS ${LLVMConfig_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)

# Extract the `clangd` tool version components.
if(CxxAutoCMake_ClangD_EXECUTABLE)
  block()
    # Obtain the `clangd` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_ClangD_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `clangd` tool `--version` command failed.")
    endif()
      # Parse the `clangd` tool `--version` output.
    if(${command_output} MATCHES ${ClangD_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(ClangD)
      if(NOT ${CMAKE_MATCH_${ClangD_VARIANT_MATCH}} STREQUAL "")
        set(ClangD_VARIANT ${CMAKE_MATCH_${ClangD_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `clangd` tool package variables.
find_package_handle_standard_args(ClangD
  REQUIRED_VARS
    CxxAutoCMake_ClangD_EXECUTABLE
  VERSION_VAR ClangD_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_ClangD_FOUND ${ClangD_FOUND})

# Define the `clangd` tool package targets.
if(${ClangD_FOUND} AND NOT TARGET CxxAutoCMake::ClangD)
  CxxAutoCMake_define_target_executable(ClangD)
endif()
