
FUNCTION(KOKKOS_DEVICE_OPTION SUFFIX DEFAULT DOCSTRING OVERRIDE)
  KOKKOS_OPTION(ENABLE_${SUFFIX} ${DEFAULT} BOOL ${DOCSTRING} ${OVERRIDE})
  STRING(TOUPPER ${SUFFIX} UC_NAME)
  IF (KOKKOS_ENABLE_${UC_NAME})
    LIST(APPEND KOKKOS_ENABLED_DEVICES    ${SUFFIX})
    #I hate that CMake makes me do this
    SET(KOKKOS_ENABLED_DEVICES    ${KOKKOS_ENABLED_DEVICES}    PARENT_SCOPE)
  ENDIF()
  SET(KOKKOS_ENABLE_${SUFFIX} ${KOKKOS_ENABLE_${SUFFIX}} PARENT_SCOPE)
ENDFUNCTION()

KOKKOS_CFG_DEPENDS(DEVICES NONE)

KOKKOS_OPTION(DEVICES "SERIAL" STRING "A list of devices to enable" DEFAULT)
IF (KOKKOS_DEVICES MATCHES ",")
  MESSAGE(WARNING "-- Detected a comma in: Kokkos_DEVICES=`${KOKKOS_DEVICES}`")
  MESSAGE("-- Although we prefer KOKKOS_DEVICES to be semicolon-delimited, we do allow")
  MESSAGE("-- comma-delimited values for compatibility with scripts (see github.com/trilinos/Trilinos/issues/2330)")
  STRING(REPLACE "," ";" KOKKOS_DEVICES "${KOKKOS_DEVICES}")
  MESSAGE("-- Commas were changed to semicolons, now Kokkos_DEVICES=`${KOKKOS_DEVICES}`")
ENDIF()

FOREACH(DEV ${KOKKOS_DEVICES})
  STRING(TOUPPER ${DEV} UC_NAME)
  KOKKOS_DEVICE_OPTION(${UC_NAME} ON "Set ${UC_NAME} from Kokkos_DEVICES" OVERRIDE)
  MESSAGE(STATUS "Setting Kokkos_ENABLE_${UC_NAME}=ON from Kokkos_DEVICES")
ENDFOREACH()
KOKKOS_DEVICE_OPTION(SERIAL        OFF  "Whether to build serial  backend" DEFAULT)
KOKKOS_DEVICE_OPTION(PTHREAD       OFF "Whether to build Pthread backend" DEFAULT)
KOKKOS_DEVICE_OPTION(ROCM          OFF "Whether to build AMD ROCm backend" DEFAULT)

IF(Trilinos_ENABLE_Kokkos AND Trilinos_ENABLE_OpenMP)
  SET(OMP_DEFAULT ON)
ELSE()
  SET(OMP_DEFAULT OFF)
ENDIF()
KOKKOS_DEVICE_OPTION(OPENMP ${OMP_DEFAULT} "Whether to build OpenMP backend" DEFAULT)

IF(Trilinos_ENABLE_Kokkos AND TPL_ENABLE_CUDA)
  SET(CUDA_DEFAULT ON)
ELSE()
  SET(CUDA_DEFAULT OFF)
ENDIF()
KOKKOS_DEVICE_OPTION(CUDA ${CUDA_DEFAULT} "Whether to build CUDA backend" DEFAULT)

IF (KOKKOS_ENABLE_CUDA)
MESSAGE(STATUS "Disabling extensions because CUDA is enabled")
GLOBAL_SET(KOKKOS_DONT_ALLOW_EXTENSIONS "CUDA enabled")
ENDIF()

##
## Turn on serial if we cannot find an active host execution space
##
IF (NOT KOKKOS_ENABLE_OPENMP) 
   IF (NOT KOKKOS_ENABLE_PTHREAD)
      IF (NOT KOKKOS_ENABLE_HPX)
         MESSAGE(STATUS "Setting Kokkos_ENABLE_SERIAL=ON because we need a host execution environment")
         KOKKOS_DEVICE_OPTION(SERIAL        ON "Enable serial backend because no other host backend present" OVERRIDE)
      ENDIF()
   ENDIF()
ENDIF()
