# zellij-release.nu: build our zellij fork and publish it as a GitHub release.
# Machines pick up the new release on their next `setup.nu --tools`.
#
#   nu ~/.dotfiles/zellij-release.nu <path-to-zellij-checkout>
#   nu ~/.dotfiles/zellij-release.nu <checkout> --no-build    # publish the existing build
#
# Needs on PATH: cargo, gh (logged in), protoc, perl + nasm (vendored OpenSSL).
# Tags are v<zellij version>-rax.<n>; n counts up per zellij version.

const REPO = 'IbrahimHindawi/zellij'
const BRANCH = 'rax'

def main [src: path, --no-build] {
    cd $src
    let branch = (^git branch --show-current | str trim)
    if $branch != $BRANCH { error make { msg: $"checkout is on '($branch)', expected '($BRANCH)'" } }
    # The build rewrites the bundled plugin .wasm files; anything else uncommitted means
    # the binary wouldn't match any commit.
    let dirty = (^git status --porcelain | lines | where {|l| not ($l =~ 'zellij-utils/assets/plugins/') })
    if ($dirty | is-not-empty) { error make { msg: $"uncommitted changes:\n($dirty | str join "\n")" } }
    ^git push --quiet    # the branch's upstream on the fork

    let exe = ($src | path join target release zellij.exe)
    if not $no_build {
        let missing = ([cargo gh protoc perl nasm] | where {|t| which $t | is-empty })
        if ($missing | is-not-empty) { error make { msg: $"not on PATH: ($missing | str join ', ')" } }
        with-env { RUSTFLAGS: '-C target-feature=+crt-static' } { ^cargo xtask ci build-release }
    }
    if not ($exe | path exists) { error make { msg: $"($exe) not found" } }

    let version = (^$exe --version | str trim | split row ' ' | last)
    let existing = (^gh release list -R $REPO --limit 100 --json tagName | from json | get tagName
        | parse $"v($version)-rax.{n}" | get n | into int)
    let tag = $"v($version)-rax.(($existing | append 0 | math max) + 1)"
    let commit = (^git rev-parse --short HEAD | str trim)
    let upstream = (^git rev-parse --short (^git merge-base HEAD origin/main | str trim) | str trim)

    let out = ($env.TEMP | path join zellij-release)
    rm -rf $out
    mkdir $out
    cp $exe $out
    let sha = (open --raw ($out | path join zellij.exe) | hash sha256)
    $"($sha) *zellij.exe\n" | save ($out | path join zellij.exe.sha256)

    let notes = $"Windows build of `($BRANCH)` at ($commit) \(upstream main ($upstream) plus our patches\).

Built locally \(no CI\), release profile, static CRT: a single exe with no runtime dependencies.
sha256: `($sha)`"
    print $"publishing ($tag) from ($commit)"
    ^gh release create $tag -R $REPO --target $BRANCH --title $tag --notes $notes ($out | path join zellij.exe) ($out | path join zellij.exe.sha256)
    rm -rf $out
}
