project(test_package)
cmake_minimum_required(VERSION 2.8.11)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)

conan_basic_setup(TARGETS)

add_executable(${PROJECT_NAME} test_package.cpp)

find_package(Boost COMPONENTS REQUIRED regex)

IF (Boost_FOUND)
	target_link_libraries(${PROJECT_NAME} PUBLIC Boost::regex)
endif()
