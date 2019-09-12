########################## NOTES ###############################################
#  List the options for configuring kokkos using CMake method of doing it.
#  These options then get mapped onto KOKKOS_SETTINGS environment variable by
#  kokkos_settings.cmake.  It is separate to allow other packages to override
#  these variables (e.g., TriBITS).

########################## AVAILABLE OPTIONS ###################################
# Use lists for documentation, verification, and programming convenience


FUNCTION(KOKKOS_ENABLE_OPTION SUFFIX DEFAULT DOCSTRING OVERRIDE)
  KOKKOS_OPTION(ENABLE_${SUFFIX} ${DEFAULT} BOOL ${DOCSTRING} ${OVERRIDE})
  STRING(TOUPPER ${SUFFIX} UC_NAME)
  IF (KOKKOS_ENABLE_${UC_NAME})
    LIST(APPEND KOKKOS_ENABLED_OPTIONS ${UC_NAME})
    #I hate that CMake makes me do this
    SET(KOKKOS_ENABLED_OPTIONS ${KOKKOS_ENABLED_OPTIONS} PARENT_SCOPE)
  ENDIF()
  SET(KOKKOS_ENABLE_${UC_NAME} ${KOKKOS_ENABLE_${UC_NAME}} PARENT_SCOPE)
ENDFUNCTION()

# Certain defaults will depend on knowing the enabled devices
KOKKOS_CFG_DEPENDS(OPTIONS DEVICES)

KOKKOS_OPTION(OPTIONS "" STRING "A list of options to enable" DEFAULT)
IF (KOKKOS_OPTIONS MATCHES ",")
  MESSAGE(WARNING "-- Detected a comma in: Kokkos_OPTIONS=`${KOKKOS_OPTIONS}`")
  MESSAGE("-- Although we prefer Kokkos_OPTIONS to be semicolon-delimited, we do allow")
  MESSAGE("-- comma-delimited values for compatibility with scripts (see github.com/trilinos/Trilinos/issues/2330)")
  STRING(REPLACE "," ";" KOKKOS_OPTIONS "${KOKKOS_OPTIONS}")
  MESSAGE("-- Commas were changed to semicolons, now Kokkos_OPTIONS=`${KOKKOS_OPTIONS}`")
ENDIF()

FOREACH(OPT ${KOKKOS_OPTIONS})
STRING(TOUPPER ${OPT} UC_NAME)
SET(ENABLE_FLAG ON)
IF (UC_NAME MATCHES "ENABLE")
   STRING(REPLACE "ENABLE_" "" OPT_SET_NAME "${UC_NAME}")
   KOKKOS_ENABLE_OPTION(${OPT_SET_NAME}  ${ENABLE_FLAG} "Set Option ${OPT_SET_NAME} to ${ENABLE_FLAG} from Kokkos_OPTIONS" OVERRIDE)
ELSE()
   IF (UC_NAME MATCHES "DISABLE")
      STRING(REPLACE "DISABLE_" "" OPT_SET_NAME "${UC_NAME}")
      SET(ENABLE_FLAG OFF)
      KOKKOS_ENABLE_OPTION(${OPT_SET_NAME}  ${ENABLE_FLAG} "Set Option ${OPT_SET_NAME} to ${ENABLE_FLAG} from Kokkos_OPTIONS" OVERRIDE)
   ELSE()
      ## This one is a special case 
      IF (UC_NAME MATCHES "AGGRESSIVE_VECTORIZATION")
         KOKKOS_ENABLE_OPTION(${UC_NAME}  ${ENABLE_FLAG} "Set Option ${UC_NAME} to ${ENABLE_FLAG} from Kokkos_OPTIONS" OVERRIDE)
         SET(UC_NAME OPT_RANGE_${UC_NAME})
         SET(ENABLE_NAME Kokkos_${UC_NAME})
         SET(UC_ENABLE_NAME KOKKOS_${UC_NAME})
         MESSAGE(STATUS "Setting ${ENABLE_NAME}=${ENABLE_FLAG} from KOKKOS_OPTIONS")
         GLOBAL_SET(${ENABLE_NAME} ${ENABLE_FLAG})
         SET(${UC_ENABLE_NAME} ${ENABLE_FLAG})
      ELSE()
         KOKKOS_ENABLE_OPTION(${UC_NAME}  ${ENABLE_FLAG} "Set Option ${UC_NAME} to ${ENABLE_FLAG} from Kokkos_OPTIONS" OVERRIDE)
      ENDIF()
   ENDIF()
ENDIF()
ENDFOREACH()

KOKKOS_OPTION(SEPARATE_LIBS  OFF BOOL "whether to build libkokkos or libkokkoscontainers, etc" DEFAULT)
KOKKOS_ENABLE_OPTION(CUDA_RELOCATABLE_DEVICE_CODE  OFF "Whether to enable relocatable device code (RDC) for CUDA" DEFAULT)
KOKKOS_ENABLE_OPTION(CUDA_UVM             OFF "Whether to enable unified virtual memory (UVM) for CUDA" DEFAULT)
KOKKOS_ENABLE_OPTION(CUDA_LDG_INTRINSIC   OFF "Whether to use CUDA LDG intrinsics" DEFAULT)
KOKKOS_ENABLE_OPTION(HPX_ASYNC_DISPATCH   OFF "Whether HPX supports asynchronous dispath" DEFAULT)
KOKKOS_ENABLE_OPTION(TESTS         OFF  "Whether to build serial  backend" DEFAULT)
KOKKOS_ENABLE_OPTION(EXAMPLES      OFF  "Whether to build OpenMP  backend" DEFAULT)
STRING(TOUPPER "${CMAKE_BUILD_TYPE}" UPPERCASE_CMAKE_BUILD_TYPE)
IF(UPPERCASE_CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  KOKKOS_ENABLE_OPTION(DEBUG                ON "Whether to activate extra debug features - may increase compile times" DEFAULT)
  KOKKOS_ENABLE_OPTION(DEBUG_DUALVIEW_MODIFY_CHECK ON "Debug check on dual views" DEFAULT)
ELSE()
  KOKKOS_ENABLE_OPTION(DEBUG                OFF "Whether to activate extra debug features - may increase compile times" DEFAULT)
  KOKKOS_ENABLE_OPTION(DEBUG_DUALVIEW_MODIFY_CHECK OFF "Debug check on dual views" DEFAULT)
ENDIF()
UNSET(_UPPERCASE_CMAKE_BUILD_TYPE)
KOKKOS_ENABLE_OPTION(DEBUG_BOUNDS_CHECK   OFF "Whether to use bounds checking - will increase runtime" DEFAULT)
KOKKOS_ENABLE_OPTION(COMPILER_WARNINGS    OFF "Whether to print all compiler warnings" DEFAULT)
KOKKOS_ENABLE_OPTION(PROFILING            ON  "Whether to create bindings for profiling tools" DEFAULT)
KOKKOS_ENABLE_OPTION(PROFILING_LOAD_PRINT OFF "Whether to print information about which profiling tools got loaded" DEFAULT)
KOKKOS_ENABLE_OPTION(AGGRESSIVE_VECTORIZATION OFF "Whether to aggressively vectorize loops" DEFAULT)
KOKKOS_ENABLE_OPTION(DEPRECATED_CODE          OFF "Whether to enable deprecated code" DEFAULT)
KOKKOS_ENABLE_OPTION(EXPLICIT_INSTANTIATION   OFF 
  "Whether to explicitly instantiate certain types to lower future compile times" DEFAULT)
GLOBAL_SET(KOKKOS_ENABLE_ETI ${KOKKOS_ENABLE_EXPLICIT_INSTANTIATION})

IF (DEFINED CUDA_VERSION AND CUDA_VERSION VERSION_GREATER "7.0")
  SET(LAMBDA_DEFAULT ON)
ELSE()
  SET(LAMBDA_DEFAULT OFF)
ENDIF()
KOKKOS_ENABLE_OPTION(CUDA_LAMBDA ${LAMBDA_DEFAULT} "Whether to activate experimental lambda features" DEFAULT)

