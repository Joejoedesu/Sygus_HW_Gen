import subprocess

test_name = "FP_NRA_testing_simple.smt"
test_name = "./tests/" + test_name
cmd = ["/usr/bin/time", "-f", "time=%E\nmem=%M KB", "../cvc5/build/bin/cvc5", test_name, "--lang=sygus2", "--fp-exp"]
result = subprocess.run(cmd, capture_output=True, text=True)

print("=== Solver output (stdout) ===")
print(result.stdout)

print("=== Time/memory info (stderr) ===")
print(result.stderr)