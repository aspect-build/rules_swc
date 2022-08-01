"Mirror of release info"

TOOL_VERSIONS = {
    "v1.2.222": {
        "android-arm-eabi": "sha512-20/gPOmvdtmHFm4lZnJ0ZxVf1xth+CISsf6sgk0oYVXkHnylCfWkB2CTwm0ZNd1W2anOYED9on5wPK1aCO6Q7Q==",
        "android-arm64": "sha512-/0u2Hlf5u2wclfMNI5J610hWoEY897cl7Poqoym7wuihod9oudG1wF+CEXJBXmGI18KLvlYM2tuBmGqHBjguTA==",
        "darwin-arm64": "sha512-mGy8BzBvw47mm9+DmQZ7RmVuu7cPO8W1ivcJEdXEGibRwSCyrV5FbyqxX5XFtN+ZyA/H8hOm+SLQJoiF90klYg==",
        "darwin-x64": "sha512-5NMf5jfnecFgKGos98pOEaHoLwd7hzKqzXPJFlGSVYzj/EodQ4Qu+ihqc8rEIdCy7DqJugjS2DUUoP+5UDhZjw==",
        "freebsd-x64": "sha512-TuQPUfRdH1gtMBGNKRGef/mpDuVqhAfhWpxjgUVNmjqGkDFZhNgqvDdFKlgkFURlMo+UlUiOcgJ0S0oTNr037Q==",
        "linux-arm-gnueabihf": "sha512-qPlCMXJzHdwzoXNhfhXmNMF4dDezJiJEjfJdKHv5+Fqe8nT0kakg7OD0/oo/S0gMP+Fp18YX+C78Z1bT19W07w==",
        "linux-arm64-gnu": "sha512-eu5TYPZItU/nK+OXQ+EQcQqvM3/HxOyuu7pJL9bIn3ZtVBkOlR372xP8g5nzOl499PX9Zk+GCJTiof9DyTlMjg==",
        "linux-arm64-musl": "sha512-FkJOIHiivayFeJ9YspHNLXlJDq5i1ZGZqGJSmMKqIHzYSSatsKaopriRC+gYQ/hQ2hJY6woaivC7qqZissSjbQ==",
        "linux-x64-gnu": "sha512-lSKcEntOSV79zgHBPxgslKGkS/br3Ou54h1a5Sb8RpzcHp+uCM9EYwT7gbXQObCJ3KJR3dxeTdsiAzX+I/wzZw==",
        "linux-x64-musl": "sha512-lWVUgRx1tcNjfT2vu6PZ12/J/8Y0Idyp8OUwaYzPvHjXbf9ThGmsaBzN694z9FVKyMECC1f0r/7PGqXPr/AS2Q==",
        "win32-arm64-msvc": "sha512-Log6DezU2Nld290oI7rt8dTMYz1LfaMOeeDswkzabSPtC/XHV85fMzAsLmOWNIO8YpxHtIEmXEXuKEZLhfZ8/A==",
        "win32-ia32-msvc": "sha512-ImQ0AvLX8TwyNTdK7vjHLb9GIvoV6mgDqSfOgGFSZKLpzqqfkZbM/wHRbJynI/ixVx8g358lbuGL6lY7C7wZ6A==",
        "win32-x64-msvc": "sha512-ZkvsMeak1xZdh6TCFemPncIJ2HZ0alpl1qm20Z119Gnp0IP3NURs9JbzvKBT47B7c+PV2hFZr+inJuppnC14jA==",
    },

    # Note, versions prior to 1.2.211 don't work because of https://github.com/swc-project/swc/issues/5124
    "v1.2.211": {
        "android-arm-eabi": "sha512-17ghPDAkBvymWM8fffeG6Lc6KD2W03FNiIKY6sCETdz/D204fNQOBdJgYNhrGHdefeWnV72MUeoIsgrsqakzAQ==",
        "android-arm64": "sha512-fAp5d2TYN9XILkV8Vj50aX1eB6DBpbsu/VoIcRfTk361ckqpBQoSGTzSMcihhOdGTf/MtLdcb6TzYH3v+1Zg3A==",
        "darwin-arm64": "sha512-dfkg90Bs+xX4QQl2kPyq3gGlyquD0wq3fpfdmlW7nWy/uSRWwEiUKmir8CvZ4iRsKvGOYA1RTOTAvACRPWN/4Q==",
        "darwin-x64": "sha512-i+vbjgJ7QHDxxCNOgyvthfyJgxbpumKLYbBzp7uc00SQSFjymz1y0ukeh8KULrLMtBBmKxs9Ne20L2Ei40CHng==",
        "freebsd-x64": "sha512-yHOP6xDbBZCgD/2C1IRIQV/eYkqx9pf7DX3hbaXzntt5V7lcXUsS/jP9I3c7PFnOTdHzecOKV/kg5zLwr2Dh3g==",
        "linux-arm-gnueabihf": "sha512-gBimwr8j09dWS1pbxeOEAoYjfZ2+Tpjf1WMhIQvsX2PWqgiUqrhtiTv3fQg9TZWS1lCUA6m8r4wqIvMi71pjaQ==",
        "linux-arm64-gnu": "sha512-pAjIT+ioDxklxr4XZVARQUxDVaOg1FQOoWhj0si86VxO/6/mEAMtjWLKMoodFAff+1sOBqyyerLmr9ErcwyZJg==",
        "linux-arm64-musl": "sha512-YeY+1bZE2LRbnKHoqZPKirJcnGXw+geewBD6KKE4oS3SzU7ZCsPyQLgzBs6BD0MbVxNPc1ju2+P/PwitbzSXIQ==",
        "linux-x64-gnu": "sha512-CYVDTuKIjluHvq38KuB9E6hCYxNR0J3KK5yvXhD0QSxtnBabBXMW/POmiIkDTLjzdadyGQSUsKOtN8iLGy7CjQ==",
        "linux-x64-musl": "sha512-J9Vj92XuaJpKR6tMP75A9qM+ViF6m4cQnhloYXzlIPpHIxesEmWKLKaMIUnopp6j8CBOirmadDPXppt5zUu2Cg==",
        "win32-arm64-msvc": "sha512-qMF7Mw3Nrrg3FjOBlksxZuhFnKFI/dXwIYMdZihWOnbKYMXKLvMoqER1zpqu+xIitp9zJmujdJO3KrrytF6oVg==",
        "win32-ia32-msvc": "sha512-hJdiRKcycarFgCYHsjigtX4i1XcY2xiXKcDFGT0ts+BRAzI1shLD4o/+ZMvzSvw1g+VG5SVKjRDs3A1X/r/EwA==",
        "win32-x64-msvc": "sha512-+Ez5zjknHg4tHqcE/JluFnLlqSs8lMrD10BWz4ahOtMJ3IVOprgGcK4fPvGpcudCSm+k6Rrj9WgMExzl9tGz6w==",
    },
}
