"Analysis test for the inputs of SWC actions"

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _swc_action_inputs_test_impl(ctx):
    env = analysistest.begin(ctx)
    actions = [a for a in analysistest.target_actions(env) if a.mnemonic == "SWCCompile"]
    asserts.true(env, len(actions) > 0, "expected SWCCompile actions")
    for action in actions:
        inputs = [f.short_path for f in action.inputs.to_list()]
        for expected in ctx.attr.expected_inputs:
            asserts.true(
                env,
                expected in inputs,
                "expected {} in inputs of the action producing {}, got {}".format(
                    expected,
                    action.outputs.to_list()[0].short_path,
                    inputs,
                ),
            )
    return analysistest.end(env)

swc_action_inputs_test = analysistest.make(
    _swc_action_inputs_test_impl,
    attrs = {
        "expected_inputs": attr.string_list(doc = "short_paths expected in the inputs of every SWCCompile action"),
    },
)
