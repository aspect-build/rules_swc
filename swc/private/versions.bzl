"""Mirror of release info

TODO: generate this file from GitHub API, populating for all platforms and versions"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "1.2.117": {
        "linux-x64-gnu": "sha384-8sSlYQ8URKdZmanscL8HxGR3oHIvu/iE0mU/FM25tvy7Vcwdc+Rxm8tMddeylFd9",
    },
}
