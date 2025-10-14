zip -9 -r cogmura.love data lib src main.lua conf.lua
mv cogmura.love ~/love2d-build/
cd ~/love2d-build
./love-11.5-x86_64.AppImage --appimage-extract
cat squashfs-root/bin/love cogmura.love > squashfs-root/bin/cogmura
chmod +x squashfs-root/bin/cogmura
rm squashfs-root/bin/love
rm squashfs-root/love.svg
cp ~/Projects/cogmura-love/release/AppRun squashfs-root/
cp ~/Projects/cogmura-love/release/cogmura.desktop squashfs-root/
cp ~/Projects/cogmura-love/release/cogmura.svg squashfs-root/
./appimagetool-x86_64.AppImage squashfs-root cogmura.AppImage
rm -r squashfs-root
rm cogmura.love
mv cogmura.AppImage ~/Projects/cogmura-love/release/
