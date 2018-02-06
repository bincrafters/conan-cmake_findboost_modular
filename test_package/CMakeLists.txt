project(test_package)
cmake_minimum_required(VERSION 2.8.11)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(TARGETS)

add_executable(${PROJECT_NAME} test_package.cpp)

find_package(Boost COMPONENTS REQUIRED process)

IF (Boost_FOUND)
	target_include_directories(${PROJECT_NAME} PUBLIC ${Boost_INCLUDE_DIR})
	target_link_libraries(${PROJECT_NAME} PUBLIC ${Boost_LIBRARY_DIRS})
endif()
