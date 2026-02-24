import sys

file_path = "islApp.nosync/ios/Runner.xcodeproj/project.pbxproj"
with open(file_path, "r") as f:
    content = f.read()

target1 = 'shellScript = "/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" build";'
replace1 = 'shellScript = "/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" build\\nxattr -cr \\"${BUILT_PRODUCTS_DIR}\\" 2>/dev/null || true\\nxattr -cr \\"${TARGET_BUILD_DIR}\\" 2>/dev/null || true\\nxattr -cr \\"${PROJECT_DIR}/..\\" 2>/dev/null || true";'

target2 = 'shellScript = "/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" embed_and_thin";'
replace2 = 'shellScript = "xattr -cr \\"${BUILT_PRODUCTS_DIR}\\" 2>/dev/null || true\\nxattr -cr \\"${TARGET_BUILD_DIR}\\" 2>/dev/null || true\\nxattr -cr \\"${PROJECT_DIR}/..\\" 2>/dev/null || true\\n/bin/sh \\"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\\" embed_and_thin";'

if target1 in content and target2 in content:
    content = content.replace(target1, replace1)
    content = content.replace(target2, replace2)
    with open(file_path, "w") as f:
        f.write(content)
    print("Patched successfully")
else:
    print("Targets not found")
