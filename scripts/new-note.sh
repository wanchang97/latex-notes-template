#!/bin/bash

# 创建新笔记目录
if [ -z "$1" ]; then
echo "Usage: ./scripts/new-note.sh <note-name>"
exit 1
fi

NOTE_NAME="$1"
NOTE_DIR="notes/$NOTE_NAME"

# 创建目录
mkdir -p "$NOTE_DIR/chapters"

# 从模板创建主文件
cp templates/single-note.tex "$NOTE_DIR/main.tex"

# 创建示例章节
cat > "$NOTE_DIR/chapters/introduction.tex" << 'EOF'
\section{Introduction}

This is the introduction section of your note.

\begin{important}
	Remember to update this content!
\end{important}
EOF

echo "Created new note: $NOTE_DIR"
echo "Edit $NOTE_DIR/main.tex to get started!"