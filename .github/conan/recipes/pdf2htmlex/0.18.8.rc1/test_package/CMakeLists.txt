cmake_minimum_required(VERSION 3.15)
project(link_test LANGUAGES CXX)

find_package(pdf2htmlEX CONFIG REQUIRED)

add_executable(${PROJECT_NAME} link_test.cpp)
target_link_libraries(${PROJECT_NAME} pdf2htmlex::pdf2htmlex)

