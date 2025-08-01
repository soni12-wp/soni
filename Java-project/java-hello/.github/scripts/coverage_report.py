import csv
import os

def read_coverage_data(csv_path):
    coverage_data = []
    with open(csv_path, 'r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            coverage_data.append(row)
    return coverage_data

def calculate_coverage_percentage(covered, missed):
    total = float(covered) + float(missed)
    if total == 0:
        return 0.0
    return (float(covered) / total) * 100

def calculate_coverage_metrics(coverage_data):
    total_instruction_covered = sum(int(row['INSTRUCTION_COVERED']) for row in coverage_data)
    total_instruction_missed = sum(int(row['INSTRUCTION_MISSED']) for row in coverage_data)
    total_branch_covered = sum(int(row['BRANCH_COVERED']) for row in coverage_data)
    total_branch_missed = sum(int(row['BRANCH_MISSED']) for row in coverage_data)
    total_line_covered = sum(int(row['LINE_COVERED']) for row in coverage_data)
    total_line_missed = sum(int(row['LINE_MISSED']) for row in coverage_data)

    return {
        'instruction': calculate_coverage_percentage(total_instruction_covered, total_instruction_missed),
        'branch': calculate_coverage_percentage(total_branch_covered, total_branch_missed),
        'line': calculate_coverage_percentage(total_line_covered, total_line_missed)
    }

def generate_coverage_summary(coverage_data, base_metrics=None):
    summary = "## 📊 Code Coverage Report\n\n"
    
    # Current coverage table
    summary += "### Current Coverage\n\n"
    summary += "| Package | Class | Instruction Coverage | Branch Coverage | Line Coverage |\n"
    summary += "|---------|-------|---------------------|-----------------|---------------|\n"

    for row in coverage_data:
        instruction_coverage = calculate_coverage_percentage(
            row['INSTRUCTION_COVERED'], row['INSTRUCTION_MISSED'])
        branch_coverage = calculate_coverage_percentage(
            row['BRANCH_COVERED'], row['BRANCH_MISSED'])
        line_coverage = calculate_coverage_percentage(
            row['LINE_COVERED'], row['LINE_MISSED'])

        summary += f"| {row['PACKAGE']} | {row['CLASS']} | {instruction_coverage:.2f}% | {branch_coverage:.2f}% | {line_coverage:.2f}% |\n"

    # Calculate current metrics
    current_metrics = calculate_coverage_metrics(coverage_data)
    
    summary += "\n### 📈 Coverage Summary\n\n"
    
    if base_metrics:
        summary += "| Metric | Base Coverage | Current Coverage | Difference |\n"
        summary += "|--------|---------------|------------------|------------|\n"
        
        for metric in ['instruction', 'branch', 'line']:
            diff = current_metrics[metric] - base_metrics[metric]
            diff_symbol = "🔺" if diff > 0 else "🔻" if diff < 0 else "➖"
            summary += f"| **{metric.title()}** | {base_metrics[metric]:.2f}% | {current_metrics[metric]:.2f}% | {diff_symbol} {abs(diff):.2f}% |\n"
    else:
        summary += "| Metric | Coverage |\n"
        summary += "|--------|----------|\n"
        for metric, value in current_metrics.items():
            summary += f"| **{metric.title()}** | {value:.2f}% |\n"

    # Calculate current metrics for threshold check
    passed_threshold, failure_message = check_coverage_threshold(
        current_metrics['instruction'],
        current_metrics['branch'],
        current_metrics['line']
    )
    
    if not passed_threshold:
        summary += failure_message

    return summary, current_metrics, passed_threshold

def check_coverage_threshold(total_instruction, total_branch, total_line, threshold=70.0):
    """Check if coverage metrics meet the minimum threshold"""
    all_metrics = [
        ("Instruction", total_instruction),
        ("Branch", total_branch),
        ("Line", total_line)
    ]
    
    failed_metrics = [f"{name} ({value:.2f}%)" 
                     for name, value in all_metrics 
                     if value < threshold]
    
    if failed_metrics:
        failure_message = f"\n### ❌ Coverage Check Failed\n\n"
        failure_message += f"**Coverage below {threshold}% threshold for:** {', '.join(failed_metrics)}\n"
        return False, failure_message
    return True, ""

def main():
    current_csv_path = "target/site/jacoco/jacoco.csv"
    base_csv_path = "target/site/jacoco/base_coverage.csv"
    
    if not os.path.exists(current_csv_path):
        print(f"Error: Could not find Jacoco CSV report at {current_csv_path}")
        exit(1)

    current_coverage_data = read_coverage_data(current_csv_path)
    base_metrics = None

    # If this is a PR, read base coverage
    if os.environ.get('IS_PR') == 'true' and os.path.exists(base_csv_path):
        base_coverage_data = read_coverage_data(base_csv_path)
        base_metrics = calculate_coverage_metrics(base_coverage_data)

    summary, current_metrics, passed_threshold = generate_coverage_summary(current_coverage_data, base_metrics)
    
    # Write to GitHub Actions summary
    with open(os.environ.get('GITHUB_STEP_SUMMARY', 'coverage_summary.md'), 'w') as f:
        f.write(summary)

    # Check coverage threshold
    if not passed_threshold:
        exit(1)

if __name__ == "__main__":
    main()