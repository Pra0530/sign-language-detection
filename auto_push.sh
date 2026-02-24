#!/bin/bash
# Auto-push script: watches for file changes and pushes to GitHub automatically

PROJECT_DIR="/Users/praphulragampeta/Desktop/sign language detection"
cd "$PROJECT_DIR"

echo "🔄 Auto-push watcher started for: $PROJECT_DIR"
echo "   Watching for changes every 30 seconds..."
echo "   Press Ctrl+C to stop."
echo ""

while true; do
    # Check if there are any changes (staged, unstaged, or untracked)
    if [ -n "$(git status --porcelain)" ]; then
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Get a summary of what changed
        CHANGED_FILES=$(git status --porcelain | head -5 | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
        NUM_CHANGES=$(git status --porcelain | wc -l | tr -d ' ')
        
        if [ "$NUM_CHANGES" -gt 5 ]; then
            MSG="Auto-update: ${NUM_CHANGES} files changed at ${TIMESTAMP}"
        else
            MSG="Auto-update: ${CHANGED_FILES} at ${TIMESTAMP}"
        fi
        
        echo "📦 Changes detected! Pushing..."
        git add -A
        git commit -m "$MSG"
        git push origin main 2>/dev/null || git push origin master 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ Pushed successfully at $TIMESTAMP"
        else
            echo "❌ Push failed at $TIMESTAMP"
        fi
        echo ""
    fi
    sleep 30
done
