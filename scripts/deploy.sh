#!/usr/bin/env sh
set -eu

deploy_repo="${DEPLOY_REPO:-git@github.com:LeoAlex0/LeoAlex0.github.io.git}"
deploy_branch="${DEPLOY_BRANCH:-master}"
deploy_dir="${DEPLOY_DIR:-dist}"
deploy_message="${DEPLOY_MESSAGE:-Deploy Hakyll site}"

if [ "${DEPLOY_SKIP_BUILD:-false}" != "true" ]; then
  echo "Building site..."

  if command -v hakyll-site >/dev/null 2>&1; then
    hakyll-site build
  elif command -v nix >/dev/null 2>&1; then
    nix run . build
  else
    echo "Neither hakyll-site nor nix is available for building." >&2
    exit 1
  fi
fi

if [ ! -d "$deploy_dir" ]; then
  echo "Deploy directory '$deploy_dir' does not exist. Run hakyll-site build first." >&2
  exit 1
fi

worktree="$(mktemp -d "${TMPDIR:-/tmp}/hakyll-deploy.XXXXXX")"
trap 'rm -rf "$worktree"' EXIT

if ! git clone --single-branch --branch "$deploy_branch" "$deploy_repo" "$worktree"; then
  rm -rf "$worktree"
  git clone "$deploy_repo" "$worktree"

  if git -C "$worktree" show-ref --verify --quiet "refs/heads/$deploy_branch"; then
    git -C "$worktree" checkout "$deploy_branch"
  else
    git -C "$worktree" checkout --orphan "$deploy_branch"
  fi
fi

if ! git -C "$worktree" config user.name >/dev/null; then
  git -C "$worktree" config user.name "${DEPLOY_USER_NAME:-hakyll-site}"
fi

if ! git -C "$worktree" config user.email >/dev/null; then
  git -C "$worktree" config user.email "${DEPLOY_USER_EMAIL:-hakyll-site@users.noreply.github.com}"
fi

find "$worktree" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$deploy_dir"/. "$worktree"/
touch "$worktree/.nojekyll"

git -C "$worktree" add -A

if git -C "$worktree" diff --cached --quiet; then
  echo "No deploy changes."
  exit 0
fi

git -C "$worktree" commit -m "$deploy_message"
git -C "$worktree" push origin "$deploy_branch"
