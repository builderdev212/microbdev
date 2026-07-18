import sys
import yaml

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <coverage.yml>", file=sys.stderr)
    sys.exit(1)

with open(sys.argv[1]) as f:
    report = yaml.safe_load(f)

print(f"## Coverage: `{report['module']}`")
print()

print("```text")
print(f"{'Metric':<12} {'Coverage':>8}")
print(f"{'-' * 12} {'-' * 8}")

for metric, value in report["coverage"].items():
    name = metric.replace("_", " ").title()
    num = float(value.rstrip("%"))
    print(f"{name:<12} {num:8.2f}")

print("```")