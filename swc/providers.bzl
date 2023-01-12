"""Providers for building derivative rules"""

SwcPluginConfigInfo = provider(
    doc = "Provides a configuration for an SWC plugin",
    fields = {
        "label": "the label of the target that created this provider",
        "config": "the plugin configuration string, encoded from a JSON object",
    },
)
