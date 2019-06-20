# Get Compiler flags from our current CMake environment,
# Will be passed to Autotools and Meson

# -g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -Wa,--noexecstack -Wformat -Werror=format-security 
SET(CFLAGS ${CMAKE_C_FLAGS})
# -g -DANDROID -fdata-sections -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-addrsig -Wa,--noexecstack -Wformat -Werror=format-security -stdlib=libc++ 
SET(CXXFLAGS ${CMAKE_CXX_FLAGS})
# -Wl,--exclude-libs,libgcc.a -Wl,--exclude-libs,libatomic.a -static-libstdc++ -Wl,--build-id -Wl,--warn-shared-textrel -Wl,--fatal-warnings -Wl,--no-undefined -Qunused-arguments -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now
SET(LDFLAGS ${ANDROID_LINKER_FLAGS})

if (CMAKE_BUILD_TYPE STREQUAL Debug)
  # -O0 -fno-limit-debug-info
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_DEBUG})
  # -O0 -fno-limit-debug-info 
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_DEBUG})
elseif(CMAKE_BUILD_TYPE STREQUAL Release)
  # -O2 -DNDEBUG
  STRING(APPEND CFLAGS ${CMAKE_C_FLAGS_RELEASE})
  # -O2 -DNDEBUG 
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELEASE})
elseif(CMAKE_BUILD_TYPE STREQUAL RelWithDebInfo)
  # -O2 -g -DNDEBUG
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
elseif(CMAKE_BUILD_TYPE STREQUAL MinSizeRel)
  # -Os -DNDEBUG
  STRING(APPEND CXXFLAGS ${CMAKE_CXX_FLAGS_MINSIZEREL})
endif()

STRING(APPEND CFLAGS " -I${THIRDPARTY_PREFIX}/include")
STRING(APPEND CXXFLAGS " -I${THIRDPARTY_PREFIX}/include")
STRING(APPEND LDFLAGS " -L${THIRDPARTY_PREFIX}/lib")
