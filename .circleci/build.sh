#!/usr/bin/env bash
echo "Cloning dependencies"
git clone https://github.com/najahiiii/aarch64-linux-gnu.git -b 4.9-mirror --depth=1 gcc
git clone --depth=1 https://github.com/dndxtz/AnyKernel3 AnyKernel
echo "Done"
tanggal=$(TZ=Asia/Jakarta date "+%Y%m%d-%H%M")
ZIP_NAME="FateXNeesanKernel-HMP-Rolex-${tanggal}.zip"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
chat_id=-1001944300223
export PATH="${PATH}:$(pwd)/gcc/bin"
export ARCH=arm64
export KBUILD_BUILD_HOST=DESKTOP-9ODEROB
export KBUILD_BUILD_USER=dndxtz
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot728234533:AAHgxu6Y_PsExZNJoYiDgC74K_J-Ok0OaUk/sendSticker" \
        -d sticker="CAACAgEAAxkBAAEnKnJfZOFzBnwC3cPwiirjZdgTMBMLRAACugEAAkVfBy-aN927wS5blhsE" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot728234533:AAHgxu6Y_PsExZNJoYiDgC74K_J-Ok0OaUk/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• IdkSer Kernel •</b>%0ABuild started on <code>Circle CI</code>%0AFor device <b>Xiaomi Redmi 4A</b> (Rolex)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>${KBUILD_COMPILER_STRING}</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#Stable"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    curl -F document=@$ZIP_NAME "https://api.telegram.org/bot728234533:AAHgxu6Y_PsExZNJoYiDgC74K_J-Ok0OaUk/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
	-F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot728234533:AAHgxu6Y_PsExZNJoYiDgC74K_J-Ok0OaUk/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
    make O=out ARCH=arm64 rolex_defconfig
    make -C $(pwd) CROSS_COMPILE=aarch64-linux-android- O=out -j8

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 $ZIP_NAME *
    cd ..
}
sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
