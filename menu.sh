#!/usr/bin/env bash
set -u

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
system_dir="$script_dir/system"
cores_dir="$script_dir/cores"
cocotb_test_dir="$script_dir/verif/cocotb"

# Main Menu
printf 'What would you like to do?\n'
printf '  1) FPGA project\n'
printf '  2) Run simulation\n'
printf '  3) Build CoCoTB container\n'
printf '  4) Open CoCoTB container\n'
printf '  5) Run CoCoTB tests\n'

while :; do
    read -r -p 'Choose an action [1-5] (or q to quit): ' main_action
    case "$main_action" in
        q|Q) exit 0 ;;
        1) mode=project; break ;;
        2) mode=simulation; break ;;
        3) mode=cocotb_bld; break ;;
        4) mode=cocotb_ct; break ;;
        5) mode=cocotb_tb; break ;;
        *) printf 'Please choose 1, 2, 3, 4, 5, or q.\n' ;;
    esac
done


# FPGA Project
if [[ "$mode" == "project" ]]; then

    if [[ ! -d "$system_dir" ]]; then
        printf 'Error: system directory not found: %s\n' "$system_dir" >&2
        exit 1
    fi

    # Find all FPGA folders
    mapfile -d '' -t fpga_dirs < <(
        find "$system_dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z
    )

    if (( ${#fpga_dirs[@]} == 0 )); then
        printf 'No FPGA folders found in: %s\n' "$system_dir" >&2
        exit 1
    fi

    # FPGA Choice
    printf '\nAvailable FPGAs:\n'
    for i in "${!fpga_dirs[@]}"; do
        printf '  %d) %s\n' "$((i + 1))" "$(basename -- "${fpga_dirs[i]}")"
    done

    while :; do
        read -r -p "Choose an FPGA [1-${#fpga_dirs[@]}] (or q to quit): " choice
        case "$choice" in
            q|Q) exit 0 ;;
            ''|*[!0-9]*)
                printf 'Please enter a number or q.\n'
                ;;
            *)
                if (( choice >= 1 && choice <= ${#fpga_dirs[@]} )); then
                    fpga_dir=${fpga_dirs[choice - 1]}
                    break
                fi
                printf 'Please choose a number from 1 to %d.\n' "${#fpga_dirs[@]}"
                ;;
        esac
    done

    # Project Operation
    printf '\nSelected FPGA: %s\n' "$(basename -- "$fpga_dir")"
    printf '  1) Generate project (make projgen)\n'
    printf '  2) Open project     (make open)\n'
    printf '  3) Clean project    (make clean)\n'

    while :; do
        read -r -p 'Choose an action [1-3] (or q to quit): ' action
        case "$action" in
            q|Q) exit 0 ;;
            1) make_target=projgen; break ;;
            2) make_target=open; break ;;
            3) make_target=clean; break ;;
            *) printf 'Please choose 1, 2, 3, or q.\n' ;;
        esac
    done

    # Execute Project Operation
    printf '\nRunning make %s in %s\n\n' "$make_target" "$fpga_dir"
    cd "$fpga_dir/build" && make "$make_target"

    exit $?
fi

# Simulation
if [[ "$mode" == "simulation" ]]; then

    if [[ ! -d "$cores_dir" ]]; then
        printf 'Error: cores directory not found: %s\n' "$cores_dir" >&2
        exit 1
    fi

    # Find all testbench Makefiles under cores/.../tb/...
    mapfile -d '' -t tb_makefiles < <(
        find "$cores_dir" -type f -path '*/tb/*/Makefile' -print0 | sort -z
    )

    if (( ${#tb_makefiles[@]} == 0 )); then
        printf 'No testbench Makefiles found under: %s\n' "$cores_dir" >&2
        exit 1
    fi

    printf '\nAvailable testbenches:\n'

    for i in "${!tb_makefiles[@]}"; do
        tb_dir=$(dirname -- "${tb_makefiles[i]}")
        tb_name=${tb_dir#"$cores_dir"/}
        printf '  %d) %s\n' "$((i + 1))" "$tb_name"
    done

    while :; do
        read -r -p "Choose a testbench [1-${#tb_makefiles[@]}] (or q to quit): " tb_choice

        case "$tb_choice" in
            q|Q) exit 0 ;;
            ''|*[!0-9]*)
                printf 'Please enter a number or q.\n'
                ;;
            *)
                if (( tb_choice >= 1 && tb_choice <= ${#tb_makefiles[@]} )); then
                    tb_makefile=${tb_makefiles[tb_choice - 1]}
                    tb_dir=$(dirname -- "$tb_makefile")
                    break
                fi

                printf 'Please choose a number from 1 to %d.\n' "${#tb_makefiles[@]}"
                ;;
        esac
    done

    printf '\nChoose waveform viewer :\n'
    printf '  1) Surfer\n'
    printf '  2) GTKWave\n'
    printf '  3) WaveCrux\n'

    while :; do
        read -r -p 'Choose a waveform viewer [1-3] (or q to quit): ' viewer_choice

        case "$viewer_choice" in
            q|Q)
                exit 0
                ;;
            1)
                waveform_viewer=surfer
                break
                ;;
            2)
                waveform_viewer=gtkwave
                break
                ;;
            3)
                waveform_viewer=wavecrux
                break
                ;;
            *)
                printf 'Please choose 1, 2, 3, or q.\n'
                ;;
        esac
    done

    # Run Simulation
    printf '\nCleaning Environment in %s\n\n' "$tb_dir"
    cd "$tb_dir" && make clean
    printf '\nBuilding model in %s\n\n' "$tb_dir"
    cd "$tb_dir" && make build
    printf '\nRunning simulation in %s\n\n' "$tb_dir"
    cd "$tb_dir" && make run
    printf '\nViewing waveform in %s\n\n' "$tb_dir"
    cd "$tb_dir" && make view WAVEFORM_VIEWER="$waveform_viewer"

    exit $?
fi

# CoCoTB Container Build
if [[ "$mode" == "cocotb_bld" ]]; then
    cd "${script_dir}/verif/cocotb/runner/" || exit 1
    make build
    exit $?
fi

# CoCoTB Test
if [[ "$mode" == "cocotb_tb" ]]; then

    if [[ ! -d "$cocotb_test_dir" ]]; then
        printf 'Error: cocotb directory not found: %s\n' "$cocotb_test_dir" >&2
        exit 1
    fi

    mapfile -d '' -t tb_makefiles < <(
        find "$cocotb_test_dir" -type f -path '*/tests/*/tb.py' -print0 | sort -z
    )

    if (( ${#tb_makefiles[@]} == 0 )); then
        printf 'No tests found under: %s\n' "$cocotb_test_dir" >&2
        exit 1
    fi

    printf '\nAvailable testbenches:\n'

    for i in "${!tb_makefiles[@]}"; do
        tb_dir=$(dirname -- "${tb_makefiles[i]}")
        tb_name=${tb_dir#"$cocotb_test_dir"/}

        printf '  %d) %s\n' "$((i + 1))" "$tb_name"
    done

    while :; do
        read -r -p "Choose a testbench [1-${#tb_makefiles[@]}] (or q to quit): " tb_choice

        case "$tb_choice" in
            q|Q)
                exit 0
                ;;
            ''|*[!0-9]*)
                printf 'Please enter a number or q.\n'
                ;;
            *)
                if (( tb_choice >= 1 && tb_choice <= ${#tb_makefiles[@]} )); then
                    tb_makefile=${tb_makefiles[tb_choice - 1]}
                    tb_dir=$(dirname -- "$tb_makefile")
                    break
                fi

                printf 'Please choose a number from 1 to %d.\n' \
                    "${#tb_makefiles[@]}"
                ;;
        esac
    done

    printf '\nSelected test: %s\n' \
        "${tb_dir#"$cocotb_test_dir"/}"

    printf '\nRunning test in Podman...\n'
    cd "$cocotb_test_dir" || exit 1
    make test TEST="${tb_dir#"$cocotb_test_dir/tests"/}"

    exit $?
fi
