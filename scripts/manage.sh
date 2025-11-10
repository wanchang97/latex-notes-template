#!/bin/bash

# LaTeX 笔记管理系统 - 统一脚本
PROJECT_ROOT="/Users/wanchang/Documents/GitHub/latex-notes-template"

cd "$PROJECT_ROOT"

function show_usage {
    echo "📚 LaTeX 笔记管理系统"
    echo ""
    echo "使用方法: ./manage.sh [命令]"
    echo ""
    echo "命令:"
    echo "  new [名称]       创建新笔记"
    echo "  compile [名称]   编译笔记"
    echo "  list            列出所有笔记"
    echo "  test            测试所有笔记"
    echo "  deploy          部署到 GitHub"
    echo "  clean           清理临时文件"
    echo "  help            显示帮助"
}

function new_note {
    if [ -z "$1" ]; then
        echo "❌ 请提供笔记名称"
        echo "用法: ./manage.sh new 机器学习笔记"
        exit 1
    fi
    
    NOTE_NAME="$1"
    NOTE_DIR="notes/$NOTE_NAME"
    
    echo "📝 创建新笔记: $NOTE_NAME"
    
    # 创建目录
    mkdir -p "$NOTE_DIR/chapters"
    mkdir -p "$NOTE_DIR/assets"
    
    # 创建主文件
    cat > "$NOTE_DIR/main.tex" << 'EOF'
\documentclass[11pt]{article}
\usepackage{/Users/wanchang/Documents/GitHub/latex-notes-template/styles/notes}

\title{笔记标题}
\author{wanchang}
\date{\today}

\begin{document}

\maketitle

\begin{abstract}
这里是笔记摘要。
\end{abstract}

\section{引言}

开始写你的笔记...

\section{数学示例}

行内公式：$E = mc^2$

行间公式：
\[
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
\]

\begin{definition}[概念]
定义内容。
\end{definition}

\section{代码示例}

\begin{lstlisting}[style=python, caption=Python代码]
print("Hello, World!")
\end{lstlisting}

\begin{note}
这是一个笔记示例。
\end{note}

\end{document}
EOF
    
    echo "✅ 创建成功: $NOTE_DIR/main.tex"
    echo "🚀 开始编辑: open $NOTE_DIR/main.tex"
    echo "🔧 编译测试: ./manage.sh compile $NOTE_NAME"
}

function compile_note {
    if [ -z "$1" ]; then
        echo "❌ 请提供笔记名称"
        echo "可用笔记:"
        list_notes
        exit 1
    fi
    
    NOTE_NAME="$1"
    NOTE_DIR="notes/$NOTE_NAME"
    
    if [ ! -f "$NOTE_DIR/main.tex" ]; then
        echo "❌ 笔记不存在: $NOTE_DIR/main.tex"
        exit 1
    fi
    
    echo "🔧 编译笔记: $NOTE_NAME"
    cd "$NOTE_DIR"
    
    # 使用 xelatex 编译
    xelatex -interaction=nonstopmode main.tex
    
    if [ -f "main.pdf" ]; then
        echo "✅ 编译成功!"
        echo "📄 PDF 位置: $(pwd)/main.pdf"
        echo "📏 文件大小: $(du -h main.pdf | cut -f1)"
        
        # 询问是否打开
        read -p "是否打开 PDF? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open main.pdf
        fi
    else
        echo "❌ 编译失败"
        echo "查看日志: main.log"
    fi
    
    cd "$PROJECT_ROOT"
}

function list_notes {
    echo "📚 现有笔记:"
    find notes -name "main.tex" | while read note; do
        dir=$(dirname "$note")
        name=$(basename "$dir")
        echo "  - $name"
    done
}

function test_all_notes {
    echo "🧪 测试所有笔记编译..."
    find notes -name "main.tex" | while read note; do
        dir=$(dirname "$note")
        name=$(basename "$dir")
        echo "测试: $name"
        
        cd "$dir"
        xelatex -interaction=nonstopmode main.tex > /dev/null 2>&1
        
        if [ -f "main.pdf" ]; then
            echo "  ✅ $name"
        else
            echo "  ❌ $name"
        fi
        
        cd "$PROJECT_ROOT"
    done
}

function deploy {
    echo "🚀 部署到 GitHub..."
    
    # 检查是否有未提交的更改
    if git diff-index --quiet HEAD --; then
        echo "📦 没有需要提交的更改"
    else
        echo "📝 提交更改..."
        git add .
        git commit -m "更新笔记"
    fi
    
    echo "⬆️  推送到 GitHub..."
    git push
    
    echo "✅ 已推送! GitHub Actions 将自动部署"
    echo "🌐 稍后访问: https://wanchang.github.io/latex-notes-template/"
}

function clean {
    echo "🧹 清理临时文件..."
    find . -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" | xargs rm -f
    echo "✅ 清理完成"
}

# 主程序
case "$1" in
    "new")
        new_note "$2"
        ;;
    "compile")
        compile_note "$2"
        ;;
    "list")
        list_notes
        ;;
    "test")
        test_all_notes
        ;;
    "deploy")
        deploy
        ;;
    "clean")
        clean
        ;;
    "help"|"")
        show_usage
        ;;
    *)
        echo "❌ 未知命令: $1"
        show_usage
        ;;
esac
