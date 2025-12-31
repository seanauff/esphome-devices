#!/bin/bash

# Arrays to store results
success=()
failed=()

# Enable nullglob so unmatched patterns produce no results
shopt -s nullglob

found_any=false

# Process all .yaml and .yml files in the current directory
for config in *.yaml *.yml; do
    # Skip the secrets.yaml file
    [[ "$(basename "$config")" == "secrets.yaml" ]] && continue

    found_any=true
    echo "Compiling $config..."

    # Run compile quietly
    if esphome compile "$config" > /dev/null 2>&1; then
        success+=("$config")
    else
        failed+=("$config")
    fi
done

# If no files were found at all (after skipping secrets.yaml)
if ! $found_any; then
    echo "No YAML files found in current directory (secrets.yaml is ignored)."
    exit 0
fi

# Print summary
echo ""
echo "=== Compilation Summary ==="
echo "Successful: ${#success[@]}"
for file in "${success[@]}"; do
    echo "  ✅ $file"
done

if [[ ${#failed[@]} -eq 0 ]]; then
    echo "Failed: None"
else
    echo "Failed: ${#failed[@]}"
    for file in "${failed[@]}"; do
        echo "  ❌ $file"
    done
    exit 1  # Optional: exit with error if any failed
fi

echo "All done!"