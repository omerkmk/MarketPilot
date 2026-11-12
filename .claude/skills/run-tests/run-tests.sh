#!/usr/bin/env bash
# MarketPilot testlerini çalıştırır ve sonucu sabit bir formatta raporlar.
# Kullanım: run-tests.sh [unit|all]   (varsayılan: unit)
# Sayılar log'dan değil, xcresult bundle'ından (xcresulttool + jq) okunur.

set -uo pipefail

UNIT_TARGET="MarketPilotTests"
UI_TARGET="MarketPilotUITests"
DESTINATION='platform=iOS Simulator,name=iPhone 16,OS=18.5,arch=arm64'

MODE="${1:-unit}"
if [[ "$MODE" != "unit" && "$MODE" != "all" ]]; then
    echo "Kullanım: $0 [unit|all]" >&2
    exit 2
fi

# Script'in konumundan repo köküne geç (.claude/skills/run-tests → kök).
cd "$(dirname "$0")/../../.." || exit 2

TMP_ROOT="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "${TMP_ROOT%/}/run-tests.XXXXXX")"
LOG_FILE="$WORK_DIR/xcodebuild.log"
RESULT_BUNDLE="$WORK_DIR/Result.xcresult"

ARGS=(
    -project MarketPilot.xcodeproj
    -scheme MarketPilot
    -destination "$DESTINATION"
    -parallel-testing-enabled NO
    -resultBundlePath "$RESULT_BUNDLE"
    test
)
if [[ "$MODE" == "unit" ]]; then
    ARGS+=("-only-testing:$UNIT_TARGET")
fi

SECONDS=0
xcodebuild "${ARGS[@]}" > "$LOG_FILE" 2>&1
DURATION=$SECONDS

# Test ağacını JSON olarak al. Bundle yoksa (ör. derleme hatası) boş ağaç kullan.
TESTS_JSON='{"testNodes":[]}'
if [[ -d "$RESULT_BUNDLE" ]]; then
    TESTS_JSON="$(xcrun xcresulttool get test-results tests --path "$RESULT_BUNDLE" 2>/dev/null || echo '{"testNodes":[]}')"
fi

# Bir hedefteki test case'leri "Suite/test<TAB>sonuç" satırları olarak listeler.
list_cases() {
    jq -r --arg target "$1" '
        .testNodes[]
        | .. | objects
        | select((.nodeType == "Unit test bundle" or .nodeType == "UI test bundle") and .name == $target)
        | .. | objects
        | select(.nodeType == "Test Suite") as $suite
        | $suite.children[]?
        | select(.nodeType == "Test Case")
        | "\($suite.name)/\(.name)\t\(.result)"
    ' <<< "$TESTS_JSON"
}

UNIT_CASES="$(list_cases "$UNIT_TARGET")"
UNIT_TOTAL=$(grep -c . <<< "$UNIT_CASES")
UNIT_PASSED=$(grep -c $'\tPassed$' <<< "$UNIT_CASES")
ALL_CASES="$UNIT_CASES"
TOTAL=$UNIT_TOTAL

if [[ "$MODE" == "all" ]]; then
    UI_CASES="$(list_cases "$UI_TARGET")"
    UI_TOTAL=$(grep -c . <<< "$UI_CASES")
    UI_PASSED=$(grep -c $'\tPassed$' <<< "$UI_CASES")
    ALL_CASES="$UNIT_CASES"$'\n'"$UI_CASES"
    TOTAL=$((UNIT_TOTAL + UI_TOTAL))
fi

FAILED_NAMES="$(grep $'\tFailed$' <<< "$ALL_CASES" | cut -f1)"

if grep -qE '\*\* (TEST )?BUILD FAILED \*\*|Testing cancelled because the build failed' "$LOG_FILE"; then
    RESULT="BUILD HATASI"
elif [[ $TOTAL -eq 0 ]]; then
    RESULT="TEST BULUNAMADI"
elif [[ -n "$FAILED_NAMES" ]]; then
    RESULT="KALDI"
else
    RESULT="GEÇTİ"
fi

echo "RUN-TESTS: $MODE"
echo "Sonuç: $RESULT"
echo "Birim testler: $UNIT_PASSED / $UNIT_TOTAL geçti"
if [[ "$MODE" == "all" ]]; then
    echo "UI testler: $UI_PASSED / $UI_TOTAL geçti"
fi
if [[ -z "$FAILED_NAMES" ]]; then
    echo "Başarısız testler: yok"
else
    echo "Başarısız testler:"
    while IFS= read -r name; do
        echo "  ✘ $name"
    done <<< "$FAILED_NAMES"
fi
echo "Süre: $DURATION sn"
if [[ "$RESULT" == "BUILD HATASI" ]]; then
    grep -m 5 'error:' "$LOG_FILE"
fi
echo "Log: $LOG_FILE"

[[ "$RESULT" == "GEÇTİ" ]]
