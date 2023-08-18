cmake_minimum_required(VERSION 3.27 FATAL_ERROR)

project(CxxAutoCMake
  HOMEPAGE_URL https://github.com/silvanshade/cxx-auto-cmake)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Emit the package config file to the binary directory.
configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/config/Config.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/CxxAutoCMakeConfig.cmake"
  NO_CHECK_REQUIRED_COMPONENTS_MACRO # NOTE: we implement our own component checking.
  INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CxxAutoCMake"
)

# Copy the package config file to the package redirects library for `FetchContent` contexts.
file(COPY_FILE
  "${CMAKE_CURRENT_BINARY_DIR}/CxxAutoCMakeConfig.cmake"
  "${CMAKE_FIND_PACKAGE_REDIRECTS_DIR}/CxxAutoCMakeConfig.cmake"
)

# Install the package config file to a standard location for `find_package` contexts.
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/CxxAutoCMakeConfig.cmake"
  DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CxxAutoCMake"
)

# The following conditional will trigger only outside of `FetchContent` contexts.
if(NOT DEFINED cxxautocmake_POPULATED OR NOT cxxautocmake_POPULATED)
  set(CxxAutoCMake_DIR "${CMAKE_CURRENT_BINARY_DIR}")

  # Find the `CxxAutoCMake` package and configure dependencies.
  find_package(CxxAutoCMake REQUIRED CONFIG
    COMPONENTS
      LLVM
      Clang
      ClangCC
      ClangCXX
      RustC
      Rustup
      # Swift
    OPTIONAL_COMPONENTS
      Homebrew
      LLVMConfig
      ClangD
      ClangFormat
      ClangTidy
      Python3
      RunClangFormat
      RunClangTidy
      CodeChecker
      IncludeWhatYouUse
      Sccache
      Scoop
      Valgrind
    )

  # Emit the `cxx-auto-cmake.json` to expose config data to `build.rs`.
  CxxAutoCMake_emit_cxx_auto_cmake_json()
endif()
