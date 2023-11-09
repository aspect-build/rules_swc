map(select(.tag_name | contains("nightly") | not))
|
map(
    {
        "key": .tag_name,
        "value": .assets
            | map({
                # filter out the node bindings and convert swc-linux-x64-gnu -> linux-x64-gnu
                "key": .name | select((contains(".node") | not) and (contains("musl") | not)) | split("swc-")[1],
                # We'll replace the url with the shasum of that referenced file in a later processing step
                "value": .browser_download_url
            })
            | from_entries
    }
) | from_entries