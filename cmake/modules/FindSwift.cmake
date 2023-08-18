include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

get_property(LLVM_FOUND GLOBAL PROPERTY CxxAutoCMake_LLVM_FOUND)
if(LLVM_FOUND)
  get_property(LLVM_DIR GLOBAL PROPERTY CxxAutoCMake_LLVM_DIR)
endif()

get_property(Clang_FOUND GLOBAL PROPERTY CxxAutoCMake_Clang_FOUND)
if(Clang_FOUND)
  get_property(Clang_DIR GLOBAL PROPERTY CxxAutoCMake_Clang_DIR)
endif()

# Prepare to search for `Swift` relative to `Clang`
if(DEFINED Clang_DIR AND NOT DEFINED Swift_DIR)
  set(Swift_DIR "${Clang_DIR}/../clang/../swift")
# Prepare to search for `Swift` relative to `LLVM`
elseif(DEFINED LLVM_DIR AND NOT DEFINED Swift_DIR)
  set(Swift_DIR "${LLVM_DIR}/../llvm/../swift")
else()
  message(NOTICE "Using -DSwift_DIR=${Swift_DIR}")
endif()

# Determine if we found `${Swift_DIR}` within the Homebrew prefix. If so, we will adjust the
# `CMAKE_PREFIX_PATH` so we also prioritize searching for the other libraries LLVM needs under the
# Homebrew prefix first, before checking other system locations.
if(TARGET CxxAutoCMake::Homebrew)
  block()
    # Expect that we haven't found Homebrew `Swift` by default.
    set(Homebrew_Swift_DIR_FOUND FALSE PARENT_SCOPE)

    # Recover variables from `Homebrew` target properties.
    get_target_property(Homebrew_PREFIX CxxAutoCMake::Homebrew Homebrew_PREFIX)
    get_target_property(Homebrew_Clang_DIR_FOUND CxxAutoCMake::Homebrew Clang_DIR_FOUND)
    get_target_property(Homebrew_LLVM_DIR_FOUND CxxAutoCMake::Homebrew LLVM_DIR_FOUND)

    # Check if `Swift_DIR` is a prefix of the Homebrew prefix path.
    set(prefix_index -1)
    string(FIND ${Swift_DIR} ${Homebrew_PREFIX} prefix_index)

    if(${prefix_index} EQUAL 0)
      message(VERBOSE "Considering Swift variant Homebrew")
      set(Homebrew_Swift_DIR_FOUND TRUE PARENT_SCOPE)

      # Adjust `CMAKE_PREFIX_PATH` to priorize searching under Homebrew.
      LIST(PREPEND CMAKE_PREFIX_PATH ${Homebrew_PREFIX})
      set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)

      # Warn about potential issues with using Homebrew `Swift` with non-Homebrew `LLVM`.
      if(NOT DEFINED Homebrew_LLVM_DIR_FOUND OR NOT ${Homebrew_LLVM_DIR_FOUND})
        message(WARNING "Using Homebrew Swift with non-Homebrew LLVM. This will likely fail.")
      endif()

      # Warn about potential issues with using Homebrew `Swift` with non-Homebrew `Clang`.
      if(NOT DEFINED Homebrew_Clang_DIR_FOUND OR NOT ${Homebrew_Clang_DIR_FOUND})
        message(WARNING "Using Homebrew Swift with non-Homebrew Clang. This will likely fail.")
      endif()
    else()
      # Warn about potential issues with using non-Homebrew `Swift` with Homebrew `LLVM`.
      if(DEFINED Homebrew_LLVM_DIR_FOUND AND ${Homebrew_LLVM_DIR_FOUND})
        message(WARNING "Using non-Homebrew Swift with Homebrew LLVM. This will likely fail.")
      endif()

      # Warn about potential issues with using non-Homebrew `Swift` with Homebrew `Clang`.
      if(DEFINED Homebrew_Clang_DIR_FOUND AND ${Homebrew_Clang_DIR_FOUND})
        message(WARNING "Using non-Homebrew Swift with Homebrew Clang. This will likely fail.")
      endif()
    endif()
  endblock()
endif()

# Set properties on the `Homebrew` target detailing whether Homebrew `Swift` was found.
set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
  Swift_DIR_FOUND ${Homebrew_Swift_DIR_FOUND}
)
if(${Homebrew_Swift_DIR_FOUND})
  set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
    Swift_DIR ${Swift_DIR}
  )
endif()

# Find the `Swift` CMake package.
#
# NOTE: The find procedure for `Swift` appears recursive as we invoke `find_package(Swift)` from
# within `FindClang.cmake`. However, the procedure will not recurse because we specify `CONFIG`
# mode, triggering a search for `ClangConfig.cmake` module at the specified path.
CxxAutoCMake_find_package(Swift
  CONFIG
  PATHS ${Swift_DIR}
  NO_DEFAULT_PATH
)
mark_as_advanced(Swift_DIR)

# Configure the `Swift` package variables.
find_package_handle_standard_args(Swift
  REQUIRED_VARS
    Swift_VERSION
    Swift_DIR
    SWIFT_CMAKE_DIR
    SWIFT_INCLUDE_DIR
    SWIFT_LIBRARY_DIR
    SWIFT_MAIN_SRC_DIR
  VERSION_VAR Swift_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Swift_FOUND ${Swift_FOUND})

if(${Swift_FOUND})
  set_property(GLOBAL PROPERTY CxxAutoCMake_Swift_DIR ${Swift_DIR})
endif()
