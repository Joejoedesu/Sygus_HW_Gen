import subprocess

# test_name = "FP_constant_suggestion.smt"
# test_name = "FP_BV_constant_suggestion_2.smt"
# test_name = "FP_BV_sampling_3.smt"
# test_name = "FP_NRA_testing_4.smt"
# test_name = "NRA_testing_2.smt"
test_name = "FP_BV_constant_input.smt"
# test_name = "simple_constant.smt"
test_name = "./tests/" + test_name
# cmd = ["/usr/bin/time", "-f", "time=%E\nmem=%M KB", "../cvc5/build/bin/cvc5", test_name, "--lang=sygus2", "--fp-exp", "--dag-thresh=0"]
# cmd = ["/usr/bin/time", "-f", "time=%E\nmem=%M KB", "../cvc5/build/bin/cvc5", test_name, "--lang=sygus2", "--fp-exp", "--dag-thresh=0", "--incremental"]
cmd = ["/usr/bin/time", "-f", "time=%E\nmem=%M KB", "../cvc5/build/bin/cvc5", test_name, "--lang=sygus2", "--fp-exp", "--dag-thresh=0", "--sygus-unif-pi=cond-enum"]
# cmd = ["/usr/bin/time", "-f", "time=%E\nmem=%M KB", "../cvc5/build/bin/cvc5", test_name]

print("Running command:", ' '.join(cmd))
result = subprocess.run(cmd, capture_output=True, text=True)

print("=== Solver output (stdout) ===")
print(result.stdout)
# dump time/memory info from stderr to output.txt
with open("output.txt", "w") as f:
    f.write(result.stdout)

print("=== Time/memory info (stderr) ===")
print(result.stderr)
with open("error.txt", "w") as f:
    f.write(result.stderr)