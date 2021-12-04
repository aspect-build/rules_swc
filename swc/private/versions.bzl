"""Mirror of release info

TODO: generate this file from GitHub API, populating for all platforms and versions"""

# The integrity hashes can be computed with
# shasum -b -a 384 $FILE | awk '{ print $1 }' | xxd -r -p | base64
TOOL_VERSIONS = {
    "1.2.117": {
        "linux-x64-gnu": "sha384-8sSlYQ8URKdZmanscL8HxGR3oHIvu/iE0mU/FM25tvy7Vcwdc+Rxm8tMddeylFd9",
        "darwin-arm64": "sha384-VNtoXdv97tzPWl87t7yora9qi1PvzRLi/96mU0ZfFX7XYg+lxB0gTyzOxhRJ8/qv",
        "darwin-x86": "sha384-lEwDzi0261EwR9cgxIQmCHCNx/sr37ToZtgAjCuFjmy8XTsePJ8f5m+S95v2eHp7",
    },
}
