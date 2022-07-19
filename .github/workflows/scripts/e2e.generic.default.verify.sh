#!/usr/bin/env bash

# shellcheck source=/dev/null
source "./.github/workflows/scripts/e2e-verify.common.sh"

go env -w GOFLAGS=-mod=mod

# verify_provenance_content verifies provenance content generated by the generic generator.
verify_provenance_content() {
    ATTESTATION=$(jq -r '.payload' <"$PROVENANCE" | base64 -d)

    echo "  **** Provenance content verification *****"

    # Verify all common provenance fields.
    e2e_verify_common_all "$ATTESTATION"

    e2e_verify_predicate_subject_name "$ATTESTATION" "$BINARY"
    e2e_verify_predicate_builder_id "$ATTESTATION" "https://github.com/slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@refs/heads/main"
    e2e_verify_predicate_buildType "$ATTESTATION" "https://github.com/slsa-framework/slsa-github-generator@v1"
}

ASSETS=$(echo "$THIS_FILE" | cut -d '.' -f5 | grep assets)

THIS_FILE=$(e2e_this_file)
BRANCH=$(echo "$THIS_FILE" | cut -d '.' -f4)
echo "branch is $BRANCH"
echo "GITHUB_REF_NAME: $GITHUB_REF_NAME"
echo "GITHUB_REF_TYPE: $GITHUB_REF_TYPE"
echo "GITHUB_REF: $GITHUB_REF"
echo "DEBUG: file is $THIS_FILE"

# Verify provenance authenticity.
# Verification should work with HEAD.
#TODO(https://github.com/slsa-framework/slsa-verifier/issues/145): use a version after release.
e2e_run_verifier_all_releases "HEAD"

# Verify the provenance content.
verify_provenance_content

# Verify assets
e2e_verify_release_assets "$ASSETS"