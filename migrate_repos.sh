#!/bin/bash

# ユーザー設定
BITBUCKET_USER="your_bitbucket_username"
GITHUB_USER="your_github_username"
GITHUB_TOKEN="your_github_personal_access_token"

# リポジトリリストファイル
REPO_LIST="repos.txt"

# Bitbucket のリモート URL（https認証）
BITBUCKET_URL="git@bitbucket.org"

# GitHub のリモート URL（https認証）
GITHUB_URL="https://$GITHUB_TOKEN@github.com"

# 一時フォルダ
WORK_DIR="repo_migration"

# 作業用ディレクトリ作成
mkdir -p $WORK_DIR
cd $WORK_DIR

# リポジトリリストを読み込んで処理
while read REPO; do
    if [ -z "$REPO" ]; then
        continue
    fi

    echo "🔄 Cloning Bitbucket repository: $REPO"

    # Bitbucket から --mirror でクローン
    git clone --mirror "$BITBUCKET_URL:$BITBUCKET_USER/$REPO.git"

    cd "$REPO.git"

    echo "🔄 Pushing repository to GitHub: $REPO"

    # GitHub にプッシュ
    git remote set-url --push origin "$GITHUB_URL/$GITHUB_USER/$REPO.git"
    git push --mirror

    cd ..

    # クローンしたリポジトリを削除（不要なら削除）
    rm -rf "$REPO.git"

    echo "✅ Successfully migrated: $REPO"

done < "../$REPO_LIST"

echo "🎉 All repositories migrated successfully!"

# 作業ディレクトリを削除
cd ..
rm -rf $WORK_DIR