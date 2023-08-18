set(RUSTUP_TOOLCHAIN_CHANNEL_REGEX "^stable|beta|nightly|([0-9]+)(\\.([0-9]+))(\\.([0-9]+))?$")
set(RUSTUP_TOOLCHAIN_CHANNEL_MAJOR_VERSION_MATCH 1)
set(RUSTUP_TOOLCHAIN_CHANNEL_MINOR_VERSION_MATCH 3)
set(RUSTUP_TOOLCHAIN_CHANNEL_PATCH_VERSION_MATCH 5)

set(RUSTUP_TOOLCHAIN_DATE_REGEX "^([0-9]+)-([0-9]+)-([0-9]+)$")
set(RUSTUP_TOOLCHAIN_DATE_YEAR_MATCH 1)
set(RUSTUP_TOOLCHAIN_DATE_MONTH_MATCH 2)
set(RUSTUP_TOOLCHAIN_DATE_DAY_MATCH 3)

# See: https://doc.rust-lang.org/cargo/appendix/glossary.html#target
set(RUSTUP_TOOLCHAIN_HOST_REGEX "^([^- \t\r\n]+)(-([^- \t\r\n]+))?-([^- \t\r\n]+)(-([^- \t\r\n]+))?$")
set(RUSTUP_TOOLCHAIN_HOST_ARCHITECTURE_MATCH 1)
set(RUSTUP_TOOLCHAIN_HOST_VENDOR_MATCH 3)
set(RUSTUP_TOOLCHAIN_HOST_OPERATING_SYSTEM_MATCH 4)
set(RUSTUP_TOOLCHAIN_HOST_ENVIRONMENT_MATCH 6)

set(RUSTUP_TOOLCHAIN_REGEX "^(stable|beta|nightly|[0-9]+\\.[0-9]+(\\.[0-9]+)?)(-[0-9]+-[0-9]+-[0-9]+)?(-([^- \t\r\n]+-[^- \t\r\n]+-[^- \t\r\n]+(-[^- \t\r\n]+)?))?$")
set(RUSTUP_TOOLCHAIN_CHANNEL_MATCH 1)
set(RUSTUP_TOOLCHAIN_DATE_MATCH 3)
set(RUSTUP_TOOLCHAIN_HOST_MATCH 5)

function(CxxAutoCMake_rustup_toolchain_list output)
  execute_process(COMMAND ${Rustup_EXECUTABLE} toolchain list
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT ${command_result} EQUAL 0)
    message(FATAL_ERROR "Failed to execute: `${Rustup_EXECUTABLE} toolchain list`")
  endif()
  set(${output} ${command_output} PARENT_SCOPE)
endfunction()

# FIXME: take optional toolchain
function(CxxAutoCMake_rustup_component_list output)
  execute_process(COMMAND ${Rustup_EXECUTABLE} component list
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT ${command_result} EQUAL 0)
    message(FATAL_ERROR "Failed to execute: `${Rustup_EXECUTABLE} component list`")
  endif()
  set(${output} ${command_output} PARENT_SCOPE)
endfunction()

function(CxxAutoCMake_rustup_run)
endfunction()

# FIXME: take optional toolchain
function(CxxAutoCMake_rustup_component_check)
endfunction()

function(CxxAutoCMake_rustup_discover_toolchains)
  CxxAutoCMake_rustup_command_toolchain_list(command_output)
  if(${command_output} MATCHES "(^|[\r\n]+)([^ \t]+)[ \t]+\\(default\\)[ \t]*[ \r\t\n]+")
    set(CxxAutoCMake_RUSTUP_DEFAULT_TOOLCHAIN ${CMAKE_MATCH_2} CACHE INTERNAL "Default toolchain reported by `rustup` tool")
  endif()
  string(REGEX REPLACE "([^ \t]+)([ \t]+\\(default\\))?[ \t]*([\r\n]+)" "\\1\\3" toolchains ${command_output})
  string(REGEX MATCHALL "[^ \t\r\n]+" toolchains ${toolchains})
  set(CxxAutoCMake_RUSTUP_TOOLCHAINS ${toolchains} CACHE INTERNAL "List of installed toolchains reported by `rustup` tool")
endfunction()

function(CxxAutoCMake_rustup_toolchain_spread toolchain)
  set(parse_prefix ARG)
  set(parse_options)
  set(parse_one_value_keywords CHANNEL_VARIABLE DATE_VARIABLE HOST_VARIABLE)
  set(parse_multi_value_keywords)
  cmake_parse_arguments(
    "${parse_prefix}"
    "${parse_options}"
    "${parse_one_value_keywords}"
    "${parse_multi_value_keywords}"
    ${ARGN}
  )
  if(DEFINED ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unparsed arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT DEFINED ARG_CHANNEL_VARIABLE)
    message(FATAL_ERROR "Missing required argument: CHANNEL_VARIABLE")
  endif()
  if(NOT DEFINED ARG_DATE_VARIABLE)
    message(FATAL_ERROR "Missing required argument: DATE_VARIABLE")
  endif()
  if(NOT DEFINED ARG_HOST_VARIABLE)
    message(FATAL_ERROR "Missing required argument: HOST_VARIABLE")
  endif()
  if(${toolchain} MATCHES ${RUSTUP_TOOLCHAIN_REGEX})
    set(${ARG_CHANNEL_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_CHANNEL_MATCH}} PARENT_SCOPE)
    set(${ARG_DATE_VARIABLE} NOTFOUND PARENT_SCOPE)
    set(${ARG_HOST_VARIABLE} NOTFOUND PARENT_SCOPE)
    if(DEFINED CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_MATCH} AND NOT CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_MATCH} STREQUAL "")
      set(${ARG_DATE_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_MATCH}} PARENT_SCOPE)
    endif()
    if(DEFINED CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_MATCH} AND NOT CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_MATCH} STREQUAL "")
      set(${ARG_HOST_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_MATCH}} PARENT_SCOPE)
    endif()
  else()
    message(FATAL_ERROR "Toolchain does not match expected format: ${toolchain}")
  endif()
endfunction()

function(CxxAutoCMake_rustup_toolchain_date_spread toolchain_date)
  set(parse_prefix ARG)
  set(parse_options)
  set(parse_one_value_keywords YEAR_VARIABLE MONTH_VARIABLE DAY_VARIABLE)
  set(parse_multi_value_keywords)
  cmake_parse_arguments(
    "${parse_prefix}"
    "${parse_options}"
    "${parse_one_value_keywords}"
    "${parse_multi_value_keywords}"
    ${ARGN}
  )
  if(DEFINED ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unparsed arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT DEFINED ARG_YEAR_VARIABLE)
    message(FATAL_ERROR "Missing required argument: YEAR_VARIABLE")
  endif()
  if(NOT DEFINED ARG_MONTH_VARIABLE)
    message(FATAL_ERROR "Missing required argument: MONTH_VARIABLE")
  endif()
  if(NOT DEFINED ARG_DAY_VARIABLE)
    message(FATAL_ERROR "Missing required argument: DAY_VARIABLE")
  endif()
  set(${ARG_YEAR_VARIABLE} NOTFOUND PARENT_SCOPE)
  set(${ARG_MONTH_VARIABLE} NOTFOUND PARENT_SCOPE)
  set(${ARG_DAY_VARIABLE} NOTFOUND PARENT_SCOPE)
  if(NOT toolchain_date STREQUAL NOTFOUND)
    if(${toolchain_date} MATCHES ${RUSTUP_TOOLCHAIN_DATE_REGEX})
      set(${ARG_YEAR_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_YEAR_MATCH}} PARENT_SCOPE)
      set(${ARG_MONTH_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_MONTH_MATCH}} PARENT_SCOPE)
      set(${ARG_DAY_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_DATE_DAY_MATCH}} PARENT_SCOPE)
    else()
      message(FATAL_ERROR "Toolchain date does not match expected format: ${toolchain_date}")
    endif()
  endif()
endfunction()

function(CxxAutoCMake_rustup_toolchain_host_spread toolchain_host)
  set(parse_prefix ARG)
  set(parse_options)
  set(parse_one_value_keywords ARCHITECTURE_VARIABLE VENDOR_VARIABLE OPERATING_SYSTEM_VARIABLE ENVIRONMENT_VARIABLE)
  set(parse_multi_value_keywords)
  cmake_parse_arguments(
    "${parse_prefix}"
    "${parse_options}"
    "${parse_one_value_keywords}"
    "${parse_multi_value_keywords}"
    ${ARGN}
  )
  if(DEFINED ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unparsed arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT DEFINED ARG_ARCHITECTURE_VARIABLE)
    message(FATAL_ERROR "Missing required argument: ARCHITECTUR_VARIABLE")
  endif()
  if(NOT DEFINED ARG_VENDOR_VARIABLE)
    message(FATAL_ERROR "Missing required argument: VENDOR_VARIABLE")
  endif()
  if(NOT DEFINED ARG_OPERATING_SYSTEM_VARIABLE)
    message(FATAL_ERROR "Missing required argument: OPERATING_SYSTEM_VARIABLE")
  endif()
  if(NOT DEFINED ARG_ENVIRONMENT_VARIABLE)
    message(FATAL_ERROR "Missing required argument: ENVIRONMENT_VARIABLE")
  endif()
  set(${ARG_ARCHITECTURE_VARIABLE} NOTFOUND PARENT_SCOPE)
  set(${ARG_VENDOR_VARIABLE} NOTFOUND PARENT_SCOPE)
  set(${ARG_OPERATING_SYSTEM_VARIABLE} NOTFOUND PARENT_SCOPE)
  set(${ARG_ENVIRONMENT_VARIABLE} NOTFOUND PARENT_SCOPE)
  if(NOT toolchain_host STREQUAL NOTFOUND)
    if(${toolchain_host} MATCHES ${RUSTUP_TOOLCHAIN_HOST_REGEX})
      set(${ARG_ARCHITECTURE_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_ARCHITECTURE_MATCH}} PARENT_SCOPE)
      if(DEFINED CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_VENDOR_MATCH} AND NOT CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_VENDOR_MATCH} STREQUAL "")
        set(${ARG_VENDOR_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_VENDOR_MATCH}} PARENT_SCOPE)
      endif()
      set(${ARG_OPERATING_SYSTEM_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_OPERATING_SYSTEM_MATCH}} PARENT_SCOPE)
      if(DEFINED CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_ENVIRONMENT_MATCH} AND NOT CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_ENVIRONMENT_MATCH} STREQUAL "")
        set(${ARG_ENVIRONMENT_VARIABLE} ${CMAKE_MATCH_${RUSTUP_TOOLCHAIN_HOST_ENVIRONMENT_MATCH}} PARENT_SCOPE)
      endif()
    else()
      message(FATAL_ERROR "Toolchain host does not match expected format: ${toolchain_host}")
    endif()
  endif()
endfunction()
