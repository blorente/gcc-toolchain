load(":defs.bzl", "ARCHS", "gcc_toolchain", _TOOLCHAINS= "BL_TOOLCHAINS")

def gcc_register_toolchain(
        name,
        target_arch,
        **kwargs):
    """Declares a `gcc_toolchain` and calls `register_toolchain` for it.

    Args:
        name: The name passed to `gcc_toolchain`.
        target_arch: The target architecture of the toolchain.
        **kwargs: The extra arguments passed to `gcc_toolchain`. See `gcc_toolchain` for more info.
    """
    print("BL: gcc_register_toolchain(name={}, target_arch={})".format(name, target_arch))
    binary_prefix = kwargs.pop("binary_prefix", None)
    if binary_prefix == None:
        if target_arch == ARCHS.aarch64:
            binary_prefix = "aarch64-linux-"
        elif target_arch == ARCHS.armv7:
            binary_prefix = "arm-linux-gnueabihf-"
        elif target_arch == ARCHS.x86_64:
            binary_prefix = ""
        else:
            fail("Unsupported target architecture: {}".format(target_arch))

    print("BL: about_to_call::gcc_toolchain(name={}, target_arch={})".format(name, target_arch))
    gcc_toolchain(
        name = name,
        binary_prefix = binary_prefix,
        extra_cflags = kwargs.pop("extra_cflags", []),
        extra_cxxflags = kwargs.pop("extra_cxxflags", []),
        extra_fflags = kwargs.pop("extra_fflags", []),
        extra_ldflags = kwargs.pop("extra_ldflags", []),
        includes = kwargs.pop("includes", []),
        fincludes = kwargs.pop("fincludes", []),
        target_arch = target_arch,
        toolchain_files = _TOOLCHAINS[target_arch],
        **kwargs
    )

#    native.register_toolchains("@{}//:cc_toolchain".format(name))
#    print("BL: registering toolchain @{}//:fortran_toolchain".format(name))
#    native.register_toolchains("@{}//:fortran_toolchain".format(name))

def _gcc_register_toolchain_module_extension(ctx):
    # collect artifacts from across the dependency graph
    print("BL: _gcc_register_toolchain_module_extension(ctx={})".format(ctx))
    for mod in ctx.modules:
      for register in mod.tags.register_toolchain:
          print("BL: _gcc_register_toolchain_module_extension::register(mod={}, register.name={})".format(mod, register.name))
          gcc_register_toolchain(
              name = register.name,
              target_arch = register.target_arch
          )

_register_gcc_toolchain = tag_class(attrs = {"name": attr.string(), "target_arch": attr.string(values = [ARCHS.aarch64, ARCHS.armv7, ARCHS.x86_64])})
gcc_register_toolchain_ext = module_extension(
    implementation = _gcc_register_toolchain_module_extension,
    tag_classes = {
        "register_toolchain": _register_gcc_toolchain,
    }
)
