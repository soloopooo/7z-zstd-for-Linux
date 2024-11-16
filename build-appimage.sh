#!/bin/bash

# 定义全局变量
APP_NAME="7-Zip"
APP_NAME_DIR="wine_${APP_NAME}"
WMClass="7zfm.exe"

# 创建必要的目录
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/lib
mkdir -p AppDir/${APP_NAME_DIR}
mkdir -p AppDir/exe

# 检查并复制字体文件
if [ -d "Fonts" ]; then
    echo "检测到字体文件夹，存在到 $(ls Fonts | wc -l) 个字体文件"
    FONT_DIR="${HOME}/.${APP_NAME_DIR}/drive_c/windows/Fonts"
    if [ -d "${FONT_DIR}" ]; then
        echo "正在清空字体目录..."
        rm -rf "${FONT_DIR}"
    fi
    mkdir -p "${FONT_DIR}"
    cp -f Fonts/* "${FONT_DIR}/"
    echo "字体文件复制完成"
fi

# 检查并复制 wine 配置目录
if [ -d "${HOME}/.${APP_NAME_DIR}" ]; then
    # if [ -d "${HOME}/.${APP_NAME_DIR}/drive_c/users/$(whoami)" ]; then
    #     echo "正在删除用户配置目录..."
    #     rm -rf "${HOME}/.${APP_NAME_DIR}/drive_c/users/$(whoami)"
    # fi
    
    # 需要删除的目录列表
    DIRS_TO_DELETE=(
        "${HOME}/.${APP_NAME_DIR}/drive_c/windows/logs"
    )

    # 遍历并删除目录
    for dir in "${DIRS_TO_DELETE[@]}"; do
        if [ -d "$dir" ]; then
            echo "正在删除目录: $dir"
            rm -rf "$dir"
        fi
    done

    if [ -d "${APP_NAME_DIR}" ]; then
        echo "正在清空 ${APP_NAME_DIR} 目录..."
        rm -rf "${APP_NAME_DIR}"
    fi

    echo "正在从 ${HOME}/.${APP_NAME_DIR} 复制配置到 ${APP_NAME_DIR}/..."
    mkdir -p "${APP_NAME_DIR}"
    cp -r "${HOME}/.${APP_NAME_DIR}/"* "${APP_NAME_DIR}/"
fi

# 检查并复制WINE虚拟环境配置目录
if [ -d "${HOME}/.${APP_NAME_DIR}" ]; then
    # 复制到 AppDir 目录
    if [ -d "AppDir/${APP_NAME_DIR}" ]; then
        echo "正在清空 AppDir/${APP_NAME_DIR} 目录..."
        rm -rf "AppDir/${APP_NAME_DIR}"
    fi
    echo "正在从 ${HOME}/.${APP_NAME_DIR} 复制配置到 AppDir/${APP_NAME_DIR}/..."
    mkdir -p "AppDir/${APP_NAME_DIR}"
    cp -r "${HOME}/.${APP_NAME_DIR}/"* "AppDir/${APP_NAME_DIR}/"
fi

# 检查是否存在 ${APP_NAME}.png
if [ -f "${APP_NAME}.png" ]; then
    echo "正在复制 ${APP_NAME}.png 到 AppDir/${APP_NAME}.png..."
    cp "${APP_NAME}.png" "AppDir/${APP_NAME}.png"
else
    # 创建一个简单的 PNG 图标,代表二进制应用程序
    convert -size 256x256 xc:transparent \
        -fill '#424242' -draw 'roundrectangle 10,10 246,246 20,20' \
        -fill white -draw 'path "M80,80 L176,80 L176,176 L80,176 Z"' \
        -fill '#424242' -draw 'path "M100,100 L156,100 L156,156 L100,156 Z"' \
        "AppDir/${APP_NAME}.png"
fi

# 检查并创建 .desktop 文件
if [ -f "AppDir/${APP_NAME}.desktop" ]; then
    rm -f "AppDir/${APP_NAME}.desktop"
fi
echo "正在创建 AppDir/${APP_NAME}.desktop 文件..."
cat > "AppDir/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=${APP_NAME}
Exec=AppRun %f
Icon=${APP_NAME}
Type=Application
Categories=Graphics;
StartupNotify=true
Comment=${APP_NAME}
StartupWMClass=${WMClass}
MimeType=application/x-rar-compressed;application/zip;application/x-7z-compressed;application/x-xz-compressed;application/x-bzip;application/x-gzip;
EOF

# 复制已有的程序文件
if [ -d "AppDir/exe" ]; then
    rm -rf "AppDir/exe"
fi
cp -r exe/ AppDir/exe/

# 检查并复制 wine AppImage
if [ ! -f "wine-stable-latest.AppImage" ]; then
    echo "错误: 未找到 wine-stable-latest.AppImage"
    exit 1
fi
cp wine-stable-latest.AppImage AppDir/
chmod +x AppDir/wine-stable-latest.AppImage

# 检查并复制其他必需文件
if [ ! -f "AppRun" ]; then
    echo "错误: 未找到 AppRun 文件"
    exit 1
fi
cp AppRun AppDir/
chmod +x AppDir/AppRun

# 下载 appimagetool
if [ ! -f appimagetool-x86_64.AppImage ]; then
    echo "正在下载 appimagetool..."
    wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x appimagetool-x86_64.AppImage
fi

# 创建 AppImage
echo "正在创建 AppImage..."
ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir "${APP_NAME}-x86_64.AppImage"