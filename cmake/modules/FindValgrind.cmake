include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `valgrind` tool version extraction regex.
set(Valgrind_VERSION_REGEX "valgrind-(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(Valgrind_VERSION_TOTAL_MATCH 1)
set(Valgrind_VERSION_MAJOR_MATCH 2)
set(Valgrind_VERSION_MINOR_MATCH 4)
set(Valgrind_VERSION_PATCH_MATCH 6)
set(Valgrind_VERSION_TWEAK_MATCH 8)
set(Valgrind_VARIANT_MATCH IGNORE)

# The `valgrind` tool validation function.
function(validator result candidate)
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  CxxAutoCMake_extract_and_validate_executable_version(Valgrind
    Valgrind_VERSION_REGEX
    Valgrind_VERSION_TOTAL_MATCH
    Valgrind_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
endfunction()

# Find the `valgrind` tool.
CxxAutoCMake_find_program(Valgrind valgrind
  VALIDATOR validator
  NO_CACHE
)

# Extract the `valgrind` tool version components.
if(CxxAutoCMake_Valgrind_EXECUTABLE)
  block()
    # Obtain the `valgrind` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_Valgrind_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `valgrind` tool `--version` command failed.")
    endif()
    # Parse the `valgrind` tool `--version` output.
    if(${command_output} MATCHES ${Valgrind_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(Valgrind)
    endif()
  endblock()
endif()

# Configure the `valgrind` tool package variables.
find_package_handle_standard_args(Valgrind
  REQUIRED_VARS
    CxxAutoCMake_Valgrind_EXECUTABLE
  VERSION_VAR Valgrind_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Valgrind_FOUND ${Valgrind_FOUND})

# Define the `valgrind` tool package targets.
if(${Valgrind_FOUND} AND NOT TARGET CxxAutoCMake::Valgrind)
  CxxAutoCMake_define_target_executable(Valgrind)
endif()
