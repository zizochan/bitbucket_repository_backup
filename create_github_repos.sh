#!/bin/bash

# GitHub のユーザー名（変更してください）
GITHUB_USER="your_github_username"

# GitHubのPersonal Access Token（事前に取得したものを設定）
GITHUB_TOKEN="your_github_personal_access_token"

# リポジトリリストが記載されたファイル
REPO_LIST="repos.txt"

# リポジトリリストを読み込んで、GitHub上に作成
while read REPO; do
    if [ -n "$REPO" ]; then
        echo "Creating repository: $REPO"

        curl -s -H "Authorization: token $GITHUB_TOKEN" \
             -H "Accept: application/vnd.github.v3+json" \
             https://api.github.com/user/repos \
             -d "{\"name\":\"$REPO\", \"private\":true}"

        echo "Repository $REPO created successfully."
    fi
done < "$REPO_LIST"

echo "✅ All repositories created successfully!"