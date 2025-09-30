"Placeholder for a rule like webpack which may produce an unpredictable number of JS chunks"

load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def mock_codesplit(name):
    write_file(
        name = "write1",
        out = "file1.js",
        content = ["const a = 1"],
    )

    write_file(
        name = "write2",
        out = "file2.js",
        content = ["const a = 2"],
    )

    copy_to_directory(
        name = name,
        srcs = ["file1.js", "file2.js"],
    )
