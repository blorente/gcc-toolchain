# Copyright (c) Thulio Ferraz Assis 2025
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def _with_libstdcxx(rule, name, gcc_toolchain_prefix = "gcc_toolchain", static_libstdcxx = False, **kwargs):
    target_name = "libstdcxx{}".format("_static" if static_libstdcxx else "")
    deps = kwargs.pop("deps", [])
    deps += select({
        "@platforms//cpu:aarch64": ["{}_aarch64//:{}".format(gcc_toolchain_prefix, target_name)],
        "@platforms//cpu:armv7": ["{}_armv7//:{}".format(gcc_toolchain_prefix, target_name)],
        "@platforms//cpu:x86_64": ["{}_x86_64//:{}".format(gcc_toolchain_prefix, target_name)],
    })
    rule(
        name = name,
        deps = deps,
        **kwargs
    )

def cc_library(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_library,
        name = name,
        gcc_toolchain_prefix = "@gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )

def cc_binary(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_binary,
        name = name,
        gcc_toolchain_prefix = "@gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )

def cc_test(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_test,
        name = name,
        gcc_toolchain_prefix = "@gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )

# These targets should only be used to patch dependencies of gcc-toolchain that should use our toolchain.
# For instance, we depend on protobuf to run `examples/protobuf`.
# However, we also want protobuf to link against libstdc++, so we patch it to use our version of the targets.
# You may be wondering: Why can't we use the "public" versions of the targets?
# In Bzlmod, the repositories `@gcc_toolchain_<arch>` that we create in MODULE.bazel are not visible to our dependencies.
# Therefore, we need to use the "absolute path" of these repositories to address them (main~extension~toolchain.
# Documentation: https://bazel.build/external/extension#repository_names_and_visibility
def cc_library_internal(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_library,
        name = name,
        gcc_toolchain_prefix = "@@_main~gcc_register_toolchain_ext~gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )

def cc_binary_internal(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_binary,
        name = name,
        gcc_toolchain_prefix = "@@_main~gcc_register_toolchain_ext~gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )

def cc_test_internal(name, static_libstdcxx = False, **kwargs):
    _with_libstdcxx(
        rule = native.cc_test,
        name = name,
        gcc_toolchain_prefix = "@@_main~gcc_register_toolchain_ext~gcc_toolchain",
        static_libstdcxx = static_libstdcxx,
        **kwargs,
    )
