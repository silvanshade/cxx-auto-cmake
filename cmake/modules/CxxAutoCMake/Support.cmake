include(modules/CxxAutoCMake/Settings)

# A version component extraction regex for strings of the form `major[.minor[.patch[-tweak]]]`
set(CxxAutoCMake_VERSION_COMPONENT_REGEX "([0-9]+)(\\.([0-9]+))?(\\.([0-9]+))?(\\-([^ \t\r\n]+))?")

# A helper function that replicates the behavior of `check_required_components` but also reports
# which components are missing on failure. Additionally, it will print a message that `CxxAutoCMake`
# is found, on success.
function(CxxAutoCMake_check_required_components)
  list(APPEND CxxAutoCMake_FOUND_COMPONENTS)
  foreach(component ${CxxAutoCMake_FIND_COMPONENTS})
    get_property(CxxAutoCMake_${component}_FOUND GLOBAL PROPERTY CxxAutoCMake_${component}_FOUND)
    if(CxxAutoCMake_${component}_FOUND)
      list(APPEND CxxAutoCMake_FOUND_COMPONENTS ${component})
    else()
      if(${CxxAutoCMake_FIND_REQUIRED_${component}})
        list(APPEND CxxAutoCMake_MISSING_REQUIRED_COMPONENTS ${component})
      endif()
    endif()
  endforeach()
  if(CxxAutoCMake_MISSING_REQUIRED_COMPONENTS)
    list(JOIN CxxAutoCMake_MISSING_REQUIRED_COMPONENTS ", " CxxAutoCMake_MISSING_REQUIRED_COMPONENTS)
    set(CxxAutoCMake_FOUND FALSE PARENT_SCOPE)
    if(CxxAutoCMake_FIND_REQUIRED)
      message(FATAL_ERROR "CxxAutoCMake: could not find required components: ${CxxAutoCMake_MISSING_REQUIRED_COMPONENTS}")
    endif()
  else()
    list(JOIN CxxAutoCMake_FOUND_COMPONENTS ", " CxxAutoCMake_FOUND_COMPONENTS)
    set(CxxAutoCMake_FOUND TRUE PARENT_SCOPE)
    if(NOT CxxAutoCMake_FIND_QUIETLY)
      message(STATUS "Found CxxAutoCMake:")
      list(APPEND CMAKE_MESSAGE_INDENT "  ")
      message(STATUS "components: ${CxxAutoCMake_FOUND_COMPONENTS}")
      list(POP_BACK CMAKE_MESSAGE_INDENT)
    endif()
  endif()
endfunction()

# A helper function that attempts to determine the host platform without using `CMAKE_SYSTEM_NAME`
# or `CMAKE_HOST_SYSTEM_NAME` since these variables are not always set. Specifically, this function
# is useful when this information is needed before `project()` has been invoked.
function(CxxAutoCMake_detect_host host_result)
  if(DEFINED CMAKE_SYSTEM_NAME)
    set(${host_result} ${CMAKE_SYSTEM_NAME} PARENT_SCOPE)
    return()
  else()
    if(${UNIX})
      execute_process(COMMAND uname -s
        RESULT_VARIABLE command_result
        OUTPUT_VARIABLE command_output
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )
      if(${command_result} EQUAL 0)
        set(${host_result} ${command_output} PARENT_SCOPE)
        return()
      endif()
    elseif(${WIN32})
      set(${host_result} "Windows" PARENT_SCOPE)
      return()
    endif()
    message(FATAL_ERROR "Could not determine `CMAKE_SYSTEM_NAME`")
  endif()
endfunction()

# A helper function for defining a target executable and setting associated properties.
function(CxxAutoCMake_define_target_executable package_name)
  set(parse_prefix ARG)
  set(parse_options HAS_NO_VERSION)
  set(parse_one_value_keywords)
  set(parse_multi_value_keywords)
  cmake_parse_arguments(
    "${parse_prefix}"
    "${parse_options}"
    "${parse_one_value_keywords}"
    "${parse_multi_value_keywords}"
    ${ARGN}
  )

  add_executable(CxxAutoCMake::${package_name}
    IMPORTED
  )
  set_target_properties(CxxAutoCMake::${package_name} PROPERTIES
    IMPORTED_LOCATION "${CxxAutoCMake_${package_name}_EXECUTABLE}"
  )

  if(NOT DEFINED ARG_HAS_NO_VERSION)
    CxxAutoCMake_set_target_executable_version_properties(${package_name})
  endif()
endfunction()

# A helper function for setting version properties on a target executable.
function(CxxAutoCMake_set_target_executable_version_properties package_name)
  set_target_properties("CxxAutoCMake::${package_name}" PROPERTIES
    VERSION       "${${package_name}_VERSION}"
    VERSION_MAJOR "${${package_name}_VERSION_MAJOR}"
    VERSION_MINOR "${${package_name}_VERSION_MINOR}"
    VERSION_PATCH "${${package_name}_VERSION_PATCH}"
    VERSION_TWEAK "${${package_name}_VERSION_TWEAK}"
  )
endfunction()

# A helper function that emits the `cxx-auto-cmake.json` file used for exposing config data to `build.rs`.
function(CxxAutoCMake_emit_cxx_auto_cmake_json)
  function(get_target_property_if_defined output target property)
    if(TARGET ${target})
      get_target_property(variable ${target} IMPORTED_LOCATION)
      if(variable)
        set(${output} \"${variable}\" PARENT_SCOPE)
      endif()
    endif()
  endfunction()

  function(set_json key input)
    set(value null)
    if(DEFINED ${input})
      set(value ${${input}})
    elseif(${input} MATCHES "^\".*\"$")
      set(value ${input})
    endif()
    string(JSON json SET ${json} "${key}" ${value})
    set(json ${json} PARENT_SCOPE)
  endfunction()

  set(json "{}")

  set_json("CMake::CURRENT_BINARY_DIR" \"${CMAKE_CURRENT_BINARY_DIR}\")
  set_json("CMake::CURRENT_SOURCE_DIR" \"${CMAKE_CURRENT_SOURCE_DIR}\")

  get_target_property_if_defined(CxxAutoCMake_ClangCC_IMPORTED_LOCATION CxxAutoCMake::ClangCC IMPORTED_LOCATION)
  set_json("CxxAutoCMake::ClangCC::IMPORTED_LOCATION" CxxAutoCMake_ClangCC_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_ClangCXX_IMPORTED_LOCATION CxxAutoCMake::ClangCXX IMPORTED_LOCATION)
  set_json("CxxAutoCMake::ClangCXX::IMPORTED_LOCATION" CxxAutoCMake_ClangCXX_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_ClangD_IMPORTED_LOCATION CxxAutoCMake::ClangD IMPORTED_LOCATION)
  set_json("CxxAutoCMake::ClangD::IMPORTED_LOCATION" CxxAutoCMake_ClangD_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_ClangFormat_IMPORTED_LOCATION CxxAutoCMake::ClangFormat IMPORTED_LOCATION)
  set_json("CxxAutoCMake::ClangFormat::IMPORTED_LOCATION" CxxAutoCMake_ClangFormat_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_ClangTidy_IMPORTED_LOCATION CxxAutoCMake::ClangTidy IMPORTED_LOCATION)
  set_json("CxxAutoCMake::ClangTidy::IMPORTED_LOCATION" CxxAutoCMake_ClangTidy_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_CodeChecker_IMPORTED_LOCATION CxxAutoCMake::CodeChecker IMPORTED_LOCATION)
  set_json("CxxAutoCMake::CodeChecker::IMPORTED_LOCATION" CxxAutoCMake_CodeChecker_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_Homebrew_IMPORTED_LOCATION CxxAutoCMake::Homebrew IMPORTED_LOCATION)
  set_json("CxxAutoCMake::Homebrew::IMPORTED_LOCATION" CxxAutoCMake_Homebrew_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_IncludeWhatYouUse_IMPORTED_LOCATION CxxAutoCMake::IncludeWhatYouUse IMPORTED_LOCATION)
  set_json("CxxAutoCMake::IncludeWhatYouUse::IMPORTED_LOCATION" CxxAutoCMake_IncludeWhatYouUse_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_LLVMConfig_IMPORTED_LOCATION CxxAutoCMake::LLVMConfig IMPORTED_LOCATION)
  set_json("CxxAutoCMake::LLVMConfig::IMPORTED_LOCATION" CxxAutoCMake_LLVMConfig_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_RunClangFormat_IMPORTED_LOCATION CxxAutoCMake::RunClangFormat IMPORTED_LOCATION)
  set_json("CxxAutoCMake::RunClangFormat::IMPORTED_LOCATION" CxxAutoCMake_RunClangFormat_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_RunClangTidy_IMPORTED_LOCATION CxxAutoCMake::RunClangTidy IMPORTED_LOCATION)
  set_json("CxxAutoCMake::RunClangTidy::IMPORTED_LOCATION" CxxAutoCMake_RunClangTidy_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_RustC_IMPORTED_LOCATION CxxAutoCMake::RustC IMPORTED_LOCATION)
  set_json("CxxAutoCMake::RustC::IMPORTED_LOCATION" CxxAutoCMake_RustC_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_RustC_IMPORTED_LOCATION CxxAutoCMake::RustC IMPORTED_LOCATION)
  set_json("CxxAutoCMake::RustC::IMPORTED_LOCATION" CxxAutoCMake_RustC_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_Rustup_IMPORTED_LOCATION CxxAutoCMake::Rustup IMPORTED_LOCATION)
  set_json("CxxAutoCMake::Rustup::IMPORTED_LOCATION" CxxAutoCMake_Rustup_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_Sccache_IMPORTED_LOCATION CxxAutoCMake::Sccache IMPORTED_LOCATION)
  set_json("CxxAutoCMake::Sccache::IMPORTED_LOCATION" CxxAutoCMake_Sccache_IMPORTED_LOCATION)

  get_target_property_if_defined(CxxAutoCMake_Valgrind_IMPORTED_LOCATION CxxAutoCMake::Valgrind IMPORTED_LOCATION)
  set_json("CxxAutoCMake::Valgrind::IMPORTED_LOCATION" CxxAutoCMake_Valgrind_IMPORTED_LOCATION)

  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/cxx-auto-cmake.json" "${json}\n")
endfunction()

# A helper macro for extracting and defining the version components for `package_name` given a
# collection of variables of the form `VERSION_*_MATCH` whose values are match numbers N. This is
# expected to be called after a successful match has been performed using a tool version extraction
# regex, in a context where the variables `CMAKE_MATCH_N` are defined.
macro(CxxAutoCMake_extract_and_set_executable_version_variables package_name)
  if(DEFINED CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} AND NOT CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} STREQUAL "")
    set(${package_name}_VERSION ${CMAKE_MATCH_${${package_name}_VERSION_TOTAL_MATCH}} PARENT_SCOPE)
  else()
    set(${package_name}_VERSION NOTFOUND PARENT_SCOPE)
  endif()

  if(DEFINED CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} AND NOT CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} STREQUAL "")
    set(${package_name}_VERSION_MAJOR ${CMAKE_MATCH_${${package_name}_VERSION_MAJOR_MATCH}} PARENT_SCOPE)
  else()
    set(${package_name}_VERSION_MAJOR NOTFOUND PARENT_SCOPE)
  endif()

  if(DEFINED CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} AND NOT CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH} STREQUAL "")
    set(${package_name}_VERSION_MINOR ${CMAKE_MATCH_${${package_name}_VERSION_MINOR_MATCH}} PARENT_SCOPE)
  else()
    set(${package_name}_VERSION_MINOR NOTFOUND PARENT_SCOPE)
  endif()

  if(DEFINED CMAKE_MATCH_${${package_name}_VERSION_PATCH_MATCH} AND NOT CMAKE_MATCH_${${package_name}_VERSION_PATCH_MATCH} STREQUAL "")
    set(${package_name}_VERSION_PATCH ${CMAKE_MATCH_${${package_name}_VERSION_PATCH_MATCH}} PARENT_SCOPE)
  else()
    set(${package_name}_VERSION_PATCH NOTFOUND PARENT_SCOPE)
  endif()

  if(DEFINED CMAKE_MATCH_${${package_name}_VERSION_TWEAK_MATCH} AND NOT CMAKE_MATCH_${${package_name}_VERSION_TWEAK_MATCH} STREQUAL "")
    set(${package_name}_VERSION_TWEAK ${CMAKE_MATCH_${${package_name}_VERSION_TWEAK_MATCH}} PARENT_SCOPE)
  else()
    set(${package_name}_VERSION_TWEAK NOTFOUND PARENT_SCOPE)
  endif()
endmacro()

# A helper macro for processing the output of a call to `execute_process` with a tool that reports
# its version.
#
# The macro will extract the program version output with `version_regex`, where `version_match` is a
# variable whose value is number N corresponding to the capture group
# `CMAKE_MATCH_${version_match}`, which is expected to capture the full version string. The macro
# then performs version validation for the `candidate` program and records both the path and version
# for each candidate processed this way, for later reporting as a CMake warning (see
# `CxxAutoCMake_find_program`) in case there are no suitable candidates.
#
# The macro also takes an "optional" `variant_match` argument, which is a variable whose value is a
# number N corresponding to the capture group `CMAKE_MATCH_${variant_match}`, which is expected to
# capture the variant string. Not all tools have a notion of variant, so in the case where this
# match does not exist, `variant_match` is expected to be the value `IGNORE` and the reported
# considered variant will be set to `NOTFOUND`.
macro(CxxAutoCMake_extract_and_validate_executable_version
  package_name
  version_regex
  version_match
  variant_match
  candidate
  command_result
  command_output
  validator_result
)
  # If the command failed, immediately return.
  if(NOT ${${command_result}} EQUAL 0)
    set(${${validator_result}} FALSE PARENT_SCOPE)
    return()
  endif()

  # Record the considered candidate executable.
  list(APPEND CxxAutoCMake_${package_name}_CONSIDERED_EXECUTABLES ${${candidate}})
  set(CxxAutoCMake_${package_name}_CONSIDERED_EXECUTABLES "${CxxAutoCMake_${package_name}_CONSIDERED_EXECUTABLES}"
    CACHE INTERNAL
    "Executable names of candidates considered for `${package_name}`"
  )

  # If the command output doesn't match the version regex, set the considered candidate version to
  # `NOTFOUND` and report a CMake warning that the regex failed to parse the version.
  if(NOT ${command_output} MATCHES ${${version_regex}})
    list(APPEND CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS NOTFOUND)
    set(CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS "${CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS}"
      CACHE INTERNAL
      "Versions of candidates considered for `${package_name}`"
    )
    message(WARNING "regex `${version_regex}` failed to parse version for `${candidate}`")
    set(${${validator_result}} FALSE PARENT_SCOPE)
    return()
  endif()

  # Record the considered candidate version.
  list(APPEND CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS ${CMAKE_MATCH_${${version_match}}})
  set(CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS "${CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS}"
    CACHE INTERNAL
    "Versions of candidates considered for `${package_name}`"
  )

  # Record the considered candidate variant.
  if(${${variant_match}} STREQUAL IGNORE OR CMAKE_MATCH_${${variant_match}} STREQUAL "")
    list(APPEND CxxAutoCMake_${package_name}_CONSIDERED_VARIANTS NOTFOUND)
  else()
    list(APPEND CxxAutoCMake_${package_name}_CONSIDERED_VARIANTS ${CMAKE_MATCH_${${variant_match}}})
  endif()
  set(CxxAutoCMake_${package_name}_CONSIDERED_VARIANTS "${CxxAutoCMake_${package_name}_CONSIDERED_VARIANTS}"
    CACHE INTERNAL
    "Variants of candidates considered for `${package_name}`"
  )

  # Check the version of the considered candidate.
  set(check_version_handle_version_range)
  if(DEFINED ${package_name}_FIND_VERSION_RANGE)
    set(check_version_handle_version_range HANDLE_VERSION_RANGE)
  endif()
  find_package_check_version(${CMAKE_MATCH_${${version_match}}}
    check_version_result
    ${check_version_handle_version_range}
    RESULT_MESSAGE_VARIABLE check_version_result_message
  )
  if(NOT check_version_result)
    message(VERBOSE "${check_version_result_message}")
    set(${${validator_result}} FALSE PARENT_SCOPE)
  endif()
  unset(check_version_result_message)
  unset(check_version_result)
  unset(check_version_handle_version_range)
endmacro()

function(CxxAutoCMake_find_component component_name)
  set(${component_name}_version_spec)

  # Skip computing the version spec for packages which have no version information.
  if(NOT ${component_name} MATCHES "^RunClangFormat|RunClangTidy$")
    # Skip computing the version spec for packages where the version is disabled.
    if(NOT IGNORE MATCHES "^${CxxAutoCMake_${component_name}_VERSION_MIN}|${CxxAutoCMake_${component_name}_VERSION_MAX}$")
      set(${component_name}_version_spec "${CxxAutoCMake_${component_name}_VERSION_MIN}...${CxxAutoCMake_${component_name}_VERSION_MAX}")
    endif()
  endif()

  list(FIND CxxAutoCMake_FIND_COMPONENTS ${component_name} CxxAutoCMake_FIND_COMPONENTS_${component_name}_INDEX)
  if(${CxxAutoCMake_FIND_COMPONENTS_${component_name}_INDEX} GREATER -1)
    CxxAutoCMake_find_package(${component_name} ${${component_name}_version_spec} GLOBAL ${ARGN})
  endif()
endfunction()

# A helper function for finding the include dir for a cxx crate by searching cargo's `target` dir.
function(CxxAutoCMake_find_crate_include_dirs_for_globs crate_include_dirs_result)
  set(parse_prefix ARG)
  set(parse_options)
  set(parse_one_value_keywords)
  set(parse_multi_value_keywords GLOBS)
  cmake_parse_arguments(
    "${parse_prefix}"
    "${parse_options}"
    "${parse_one_value_keywords}"
    "${parse_multi_value_keywords}"
    ${ARGN}
  )

  file(GLOB_RECURSE input_dirs
    FOLLOW_SYMLINKS
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    ${ARG_GLOBS}
  )

  foreach(dir ${input_dirs})
    string(REGEX REPLACE "^(.*/cxxbridge/crate)/.*$" "\\1" dir ${dir})
    list(APPEND output_dirs ${dir})
  endforeach()

  set(${crate_include_dirs_result} ${output_dirs} PARENT_SCOPE)
endfunction()

# A wrapper macro for `find_package` that calls an inner `find_package` in a modified environment to
# account for certain packages not reporting their versions properly.
macro(CxxAutoCMake_find_package package_name)
  if(DEFINED ${package_name}_FIND_VERSION_RANGE)
    set(${package_name}_version_spec ${${package_name}_FIND_VERSION_RANGE})
  elseif(DEFINED ${package_name}_FIND_VERSION)
    set(${package_name}_version_spec ${${package_name}_FIND_VERSION})
  else()
    set(${package_name}_version_spec)
  endif()

  # Special handling for {Clang, Swift} packages which do not properly set versions.
  if(${package_name} MATCHES "^Clang|LLVM|Swift$")
    # Ensure version requirements are unset for the inner `find_package` invocation.

    unset(${package_name}_FIND_NAME)

    unset(${package_name}_FIND_VERSION)

    unset(${package_name}_FIND_VERSION_MAJOR)
    unset(${package_name}_FIND_VERSION_MINOR)
    unset(${package_name}_FIND_VERSION_PATCH)
    unset(${package_name}_FIND_VERSION_TWEAK)
    unset(${package_name}_FIND_VERSION_COUNT)

    unset(${package_name}_FIND_VERSION_RANGE)
    unset(${package_name}_FIND_VERSION_RANGE_MIN)
    unset(${package_name}_FIND_VERSION_RANGE_MAX)

    unset(${package_name}_FIND_VERSION_MIN)
    unset(${package_name}_FIND_VERSION_MIN_MAJOR)
    unset(${package_name}_FIND_VERSION_MIN_MINOR)
    unset(${package_name}_FIND_VERSION_MIN_PATCH)
    unset(${package_name}_FIND_VERSION_MIN_TWEAK)
    unset(${package_name}_FIND_VERSION_MIN_COUNT)

    unset(${package_name}_FIND_VERSION_MAX)
    unset(${package_name}_FIND_VERSION_MAX_MAJOR)
    unset(${package_name}_FIND_VERSION_MAX_MINOR)
    unset(${package_name}_FIND_VERSION_MAX_PATCH)
    unset(${package_name}_FIND_VERSION_MAX_TWEAK)
    unset(${package_name}_FIND_VERSION_MAX_COUNT)

    unset(${package_name}_FIND_VERSION_COMPLETE)

    find_package(${package_name} ${ARGN})
  else()
    find_package(${package_name} ${${package_name}_version_spec} ${ARGN})
  endif()

  unset(${package_name}_version_spec)
endmacro()

# A wrapper macro that calls `find_program` and keeps track of considered executables and versions.
macro(CxxAutoCMake_find_program package_name)
  find_program(CxxAutoCMake_${package_name}_EXECUTABLE ${ARGN})
  block()
    if(NOT CxxAutoCMake_${package_name}_EXECUTABLE)
      set(message_mode WARNING)
    else()
      set(message_mode VERBOSE)
    endif()

    foreach(entry IN ZIP_LISTS CxxAutoCMake_${package_name}_CONSIDERED_EXECUTABLES CxxAutoCMake_${package_name}_CONSIDERED_VERSIONS CxxAutoCMake_${package_name}_CONSIDERED_VARIANTS)
      set(candidate_path ${entry_0})
      set(candidate_version "(version: <unknown>)")
      set(candidate_variant "")

      if(NOT ${entry_1} STREQUAL NOTFOUND)
        set(candidate_version " (version: \"${entry_1}\")")
      endif()

      if(NOT ${entry_2} STREQUAL NOTFOUND)
        set(candidate_variant " (variant: \"${entry_2}\")")
      endif()

      string(APPEND entries "  ${candidate_path}${candidate_version}${candidate_variant}\n")
    endforeach()

    if(DEFINED entries)
      message(${message_mode} "${package_name} executables considered:\n${entries}")
    endif()
  endblock()
endmacro()

# FIXME: If both `clang` and `rustc` are found, check if the `rustc` LLVM version is compatible with
# `clang`. If it is, set some variable indicating that `linker-plugin-lto` is available for FFI.
#
# A helper function for validating that certain various toolchain conditions hold.
function(CxxAutoCMake_validate_cxx_toolchain)
  # Check that the C compiler is `Clang`.
  if(NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")
    message(FATAL_ERROR "`CMAKE_C_COMPILER_ID` must be `Clang` but found `${CMAKE_C_COMPILER_ID}`")
  endif()

  # Check that the `Clang` C compiler has a compatible version.
  if(NOT ${CMAKE_C_COMPILER_VERSION} VERSION_GREATER_EQUAL ${CxxAutoCMake_BIN_CLANG_CC_EXPECTED_VERSION})
    message(FATAL_ERROR "`CMAKE_C_COMPILER_VERSION` must be at least `${CxxAutoCMake_BIN_CLANG_CC_EXPECTED_VERSION}` but found `${CMAKE_C_COMPILER_VERSION}`")
  endif()

  # Check that the C++ compiler is `Clang`.
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    message(FATAL_ERROR "`CMAKE_CXX_COMPILER_ID` must be `Clang` but found `${CMAKE_CXX_COMPILER_ID}`")
  endif()

  # Check that the `Clang` C++ compiler has a compatible version.
  if(NOT ${CMAKE_CXX_COMPILER_VERSION} VERSION_GREATER_EQUAL ${CxxAutoCMake_BIN_CLANG_CXX_EXPECTED_VERSION})
    message(FATAL_ERROR "`CMAKE_CXX_COMPILER_VERSION` must be at least `${CxxAutoCMake_BIN_CLANG_CXX_EXPECTED_VERSION}` but found `${CMAKE_CXX_COMPILER_VERSION}`")
  endif()
endfunction()

# A helper macro that perform a validation of the variant of a candidate LLVM tool. This is expected
# to be called after a successful match has been performed using a tool version extraction regex, in
# a context where the variables `CMAKE_MATCH_*` are defined.
macro(CxxAutoCMake_validate_llvm_toolchain_variant
  variant_match
  validator_result
)
  # Fail validation if the variant is Apple since we need to select the official LLVM toolchain.
  if(DEFINED CMAKE_MATCH_${${variant_match}} AND CMAKE_MATCH_${${variant_match}} STREQUAL Apple)
    message(VERBOSE "Apple LLVM toolchains are not supported")
    set(${${validator_result}} FALSE PARENT_SCOPE)
    return()
  endif()
endmacro()
