cmake_minimum_required(VERSION 2.8.8)
project(ParaViewSuperBuild)
set (ParaViewSuperBuild_CMAKE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/CMake")
include(CMakeDependentOption)

#-----------------------------------------------------------------------------
# Collect information about the build platform.
include(CheckTypeSize)
check_type_size(void* VOID_PTR_SIZE BUILTIN_TYPES_ONLY)
if (VOID_PTR_SIZE EQUAL 8)
  set (64bit_build TRUE)
else ()
  set (64bit_build FALSE)
endif()

set (platform)
if (UNIX)
  set (platform "unix")
elseif (APPLE)
  set (platform "apple")
elseif (WIN32)
  set (platform "win32")
endif()

# Set suffix to be used for generating archives. This ensures that the package
# files have decent names that we can directly upload to the website.
set (package_suffix "${CMAKE_SYSTEM_NAME}")
if (64bit_build)
  set (package_suffix "${package_suffix}-64bit")
else ()
  set (package_suffix "${package_suffix}-32bit")
endif()

#-----------------------------------------------------------------------------
# Setup CMAKE_MODULE_PATH so that platform specific configurations are processed
# before the generic ones.
set (CMAKE_MODULE_PATH
  "${ParaViewSuperBuild_CMAKE_DIR}/${platform}"
  "${ParaViewSuperBuild_CMAKE_DIR}/common"
  "${ParaViewSuperBuild_CMAKE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}"
  ${CMAKE_MODULE_PATH})

#-----------------------------------------------------------------------------
# Setup some standard variables that control various locations and flags.
set (install_location "${CMAKE_CURRENT_BINARY_DIR}/install")
set (download_location "${CMAKE_CURRENT_BINARY_DIR}/downloads")
set (ldflags "$ENV{LDFLAGS} -L${install_location}/lib")
set (cppflags "$ENV{CPPFLAGS} -I${install_location}/include -fPIC")
set (cxxflags "$ENV{CXXFLAGS} -I${install_location}/include -fPIC")
set (cflags "$ENV{CFLAGS} -I${install_location}/include")
set (ld_library_path "${install_location}/lib:$ENV{LD_LIBRARY_PATH}")
set (prefix_path "${install_location}")

string (STRIP "${ldflags}" ldflags)
string (STRIP "${cppflags}" cppflags)
string (STRIP "${cxxflags}" cxxflags)
string (STRIP "${cflags}"  cflags)

#-----------------------------------------------------------------------------
## Top-level options. These must be limited to a commonly used subset with
## default values being used for building ParaView binaries.
#option(PV_COMMAND_LINE_TOOLS_ONLY
#  "Turn this ON to build command lines tools alone." OFF)

#-----------------------------------------------------------------------------
include (ParaViewModules)
include (versions)

#-----------------------------------------------------------------------------
set (CM_PROJECTS_ALL)

# Include all optional projects. These are the ones user can pick and choose.
# Some of these allow using system libraries too.
include(zlib)
include(png)
include(szip)
include(hdf5)
include(silo)
include(cgns)
include(ffmpeg)
include(libxml2)
include(freetype)
include(fontconfig)
include(qt)
include(python)
include(numpy)
include(boost)
include(manta)
include(mpich2)
include(mesa)

# REMEMBER to tell VTK/ParaView to use VTK_SYSTEM_* for the
# libraries we've built here.
include(paraview)

process_dependencies()


return()
SET (CMAKE_INSTALL_COMPONENT runtime)
## When building with Mesa and generating command line tools alone, 
## we provide the user with an option to use OSMesa.
#dependent_option(ENABLE_OSMESA
#  "Turn ON to enable Offscreen Mesa 3D support." OFF
#  "ENABLE_MESA;PV_COMMAND_LINE_TOOLS_ONLY" OFF)

# REMEMBER to tell VTK/ParaView to use VTK_SYSTEM_* for the
# libraries we've built here.

add_project(paraview.bundle REQUIRED)

# Now add optional/proprietary plugins.
add_project(acusolve_plugin DEFAULT_OFF)
add_project(vistrails_plugin DEFAULT_OFF)
add_project(nektar_plugin DEFAULT_OFF)
#add_project(mili_plugin DEFAULT_OFF)