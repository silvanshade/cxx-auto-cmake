include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `sccache` tool version extraction regex.
set(Sccache_VERSION_REGEX "sccache[ \t\n\r]+(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(Sccache_VERSION_TOTAL_MATCH 1)
set(Sccache_VERSION_MAJOR_MATCH 2)
set(Sccache_VERSION_MINOR_MATCH 4)
set(Sccache_VERSION_PATCH_MATCH 6)
set(Sccache_VERSION_TWEAK_MATCH 8)
set(Sccache_VARIANT_MATCH IGNORE)

# The `sccache` tool validation function.
function(validator result candidate)
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `sccache` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(Sccache
    Sccache_VERSION_REGEX
    Sccache_VERSION_TOTAL_MATCH
    Sccache_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
endfunction()

# Find the `sccache` tool.
CxxAutoCMake_find_program(Sccache sccache
  VALIDATOR validator
  NO_CACHE
)

# Extract the `sccache` tool version components.
if(CxxAutoCMake_Sccache_EXECUTABLE)
  block()
    # Obtain the `sccache` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_Sccache_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `sccache` tool `--version` command failed.")
    endif()
    # Parse the `sccache` tool `--version` output.
    if(${command_output} MATCHES ${Sccache_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(Sccache)
    endif()
  endblock()
endif()

# Configure the `sccache` tool package variables.
find_package_handle_standard_args(Sccache
  REQUIRED_VARS
    CxxAutoCMake_Sccache_EXECUTABLE
  VERSION_VAR Sccache_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Sccache_FOUND ${Sccache_FOUND})

# Define the `sccache` tool package targets.
if(${Sccache_FOUND} AND NOT TARGET CxxAutoCMake::Sccache)
  CxxAutoCMake_define_target_executable(Sccache)
endif()
