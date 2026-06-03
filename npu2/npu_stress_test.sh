#!/bin/bash
# npu2/npu_stress_test.sh - NPU inference stress test

DIR_NPU="$(cd "$(dirname "$0")" && pwd)"
source "${DIR_NPU}/../common/common.sh"

# Model paths per SoC family
get_npu_model() {
    case "$SOC_FAMILY" in
        rk3588)    echo "/usr/share/model/RK3588/mobilenet_v1.rknn" ;;
        rk3566|rk3568) echo "/usr/share/model/RK3566_RK3568/mobilenet_v1.rknn" ;;
        rk3562)    echo "/usr/share/model/RK3562/mobilenet_v1.rknn" ;;
        rk3576)    echo "/usr/share/model/RK3576/mobilenet_v1.rknn" ;;
        rv1126b)   echo "/usr/share/model/RV1126B/mobilenet_v1.rknn" ;;
        *)
            log_error "npu" "No NPU model for SoC: $SOC_FAMILY"
            return 1
            ;;
    esac
}

MODEL=$(get_npu_model) || exit 1
TEST_IMAGE="/usr/share/model/dog_224x224.jpg"

require_command rknn_common_test || exit 1
require_file "$MODEL" || exit 1
require_file "$TEST_IMAGE" || exit 1

TEST_ID=$(test_begin "npu" "stress" "NPU inference stress on $SOC_FAMILY")
log_info "npu" "Running rknn_common_test with model: $MODEL"

set +e
while true; do
    rknn_common_test "$MODEL" "$TEST_IMAGE" 10
    EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        test_end "$TEST_ID" "FAIL" "rknn_common_test exited with code $EXIT_CODE"
        exit 1
    fi
done
set -e
