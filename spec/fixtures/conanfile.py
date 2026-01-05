from conan import ConanFile

class MyPackage(ConanFile):
    name = "mypackage"
    version = "1.0.0"

    def requirements(self):
        self.requires("zlib/1.2.11")
        self.requires("boost/1.76.0@user/channel")
