include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/Clang/Support)

# The `include-what-you-use` tool version extraction regex.
set(IncludeWhatYouUse_VERSION_REGEX "^include-what-you-use[ \t\r\n]+(${CxxAutoCMake_VERSION_COMPONENT_REGEX})[^ \t\r\n]*")
set(IncludeWhatYouUse_VERSION_TOTAL_MATCH 1)
set(IncludeWhatYouUse_VERSION_MAJOR_MATCH 2)
set(IncludeWhatYouUse_VERSION_MINOR_MATCH 4)
set(IncludeWhatYouUse_VERSION_PATCH_MATCH 6)
set(IncludeWhatYouUse_VERSION_TWEAK_MATCH 8)
set(IncludeWhatYouUse_VARIANT_MATCH IGNORE)

# The `include-what-you-use` tool version extraction regex for its corresponding `clang` version.
set(IncludeWhatYouUse_Clang_VERSION_REGEX "based[ \t\r\n]+on[ \t\r\n]+${Clang_VERSION_REGEX}")
set(IncludeWhatYouUse_Clang_VERSION_TOTAL_MATCH 2)
set(IncludeWhatYouUse_Clang_VERSION_MAJOR_MATCH 3)
set(IncludeWhatYouUse_Clang_VERSION_MINOR_MATCH 5)
set(IncludeWhatYouUse_Clang_VERSION_PATCH_MATCH 7)
set(IncludeWhatYouUse_Clang_VERSION_TWEAK_MATCH 9)
set(IncludeWhatYouUse_Clang_VARIANT_MATCH 1)

# The `include-what-you-use` tool validation function.
function(validator result candidate)
  # Obtain the `include-what-you-use` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `include-what-you-use` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(IncludeWhatYouUse
    IncludeWhatYouUse_VERSION_REGEX
    IncludeWhatYouUse_VERSION_TOTAL_MATCH
    IncludeWhatYouUse_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Parse the `include-what-you-use` tool `--version` output (for clang toolchain).
  if(NOT ${command_output} MATCHES ${IncludeWhatYouUse_Clang_VERSION_REGEX})
    message(WARNING "regex `IncludeWhatYouUse_Clang_VERSION_REGEX` failed to parse version for `${candidate}`")
    set(${result} FALSE PARENT_SCOPE)
    return()
  endif()
  # Validate the `include-what-you-use` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(IncludeWhatYouUse_Clang_VARIANT_MATCH result)
  if(DEFINED ClangCC_VERSION)
    # Check if the toolchain variant is major-version compatible with the already found `clang`.
    if(NOT ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VERSION_MAJOR_MATCH}} VERSION_GREATER_EQUAL ${ClangCC_VERSION_MAJOR})
      message(WARNING "`IncludeWhatYouUse_Clang_VERSION_MAJOR` does not match `ClangCC_VERSION_MAJOR`: ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VERSION_MAJOR_MATCH}} != ${ClangCC_VERSION_MAJOR}")
      set(${result} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
  if(DEFINED ClangCXX_VERSION_MAJOR)
    # Check if the toolchain variantis major-version compatible with the already found `clang++`.
    if(NOT ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VERSION_MAJOR_MATCH}} VERSION_GREATER_EQUAL ${ClangXX_VERSION_MAJOR})
    message(WARNING "`IncludeWhatYouUse_Clang_VERSION_MAJOR` does not match `ClangCXX_VERSION_MAJOR`: ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VERSION_MAJOR_MATCH}} != ${ClangCXX_VERSION_MAJOR}")
      set(${result} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
endfunction()

# Find the `include-what-you-use` tool.
CxxAutoCMake_find_program(IncludeWhatYouUse include-what-you-use
  VALIDATOR validator
  NO_CACHE
)

# Extract the `include-what-you-use` tool version components.
if(CxxAutoCMake_IncludeWhatYouUse_EXECUTABLE)
  block()
    # Obtain the `include-what-you-use` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_IncludeWhatYouUse_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `include-what-you-use` tool `--version` command failed.")
    endif()
    # Parse the `include-what-you-use` tool `--version` output.
    if(${command_output} MATCHES ${IncludeWhatYouUse_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(IncludeWhatYouUse)
    endif()
    # Parse the `include-what-you-use` tool `--version` output (for toolchain variant).
    if(${command_output} MATCHES ${IncludeWhatYouUse_Clang_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(IncludeWhatYouUse_Clang)
      if(NOT ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VARIANT_MATCH}} STREQUAL "")
        set(IncludeWhatYouUse_Clang_VARIANT ${CMAKE_MATCH_${IncludeWhatYouUse_Clang_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `include-what-you-use` tool package variables.
find_package_handle_standard_args(IncludeWhatYouUse
  REQUIRED_VARS
    CxxAutoCMake_IncludeWhatYouUse_EXECUTABLE
  VERSION_VAR IncludeWhatYouUse_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_IncludeWhatYouUse_FOUND ${IncludeWhatYouUse_FOUND})

# Define the `include-what-you-use` tool package targets.
if(${IncludeWhatYouUse_FOUND} AND NOT TARGET CxxAutoCMake::IncludeWhatYouUse)
  CxxAutoCMake_define_target_executable(IncludeWhatYouUse)
endif()
