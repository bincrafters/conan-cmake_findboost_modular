#!/usr/bin/env python
# -*- coding: utf-8 -*-

from conans import ConanFile


class CMakeFindboostModularConan(ConanFile):
    name = "cmake_findboost_modular"
    version = "1.68.0"
    url = "https://github.com/bincrafters/cmake_findboost_modular"
    description = "Enables use of Boost Modular Packages with traditional CMake FindBoost"
    author = "Bincrafters <bincrafters@gmail.com>"
    license = "MIT"
    exports = ["LICENSE.md"]
    exports_sources = ["FindBoost.cmake"]
        
    def package(self):
        self.copy("FindBoost.cmake")
