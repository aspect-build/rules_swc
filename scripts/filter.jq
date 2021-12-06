map(
    {
        "key": .tag_name,
        "value": .assets
            | map({
                # convert swc.android-arm64.node -> android-arm64
                "key": .name | split(".")[1],
                # We'll replace the url with the shasum of that referenced file in a later processing step
                "value": .browser_download_url
            })
            | from_entries
    }
) | from_entries
