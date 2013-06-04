# Script for quickly replacing resources inside built jar archive, without running full rebuild.
# For some reason, maven does not catch changes in resource files, during incremental build.
# I do not have enough expertise in maven to fix this and I do not want to spend too much time on investigating this.
# TODO: Configure incremental build properly and get rid of this.

source ./common.sh
if [ ! -d "$REPACK_DIR" ]
then
	mkdir "$REPACK_DIR"
	unzip "$UBERJAR_PATH" -d "$REPACK_DIR"
fi

cd "$REPACK_DIR"
TEMLATES_DIR="org/antlr/codegen/templates/Cpp"
rm -Rf "$REPACK_DIR/$TEMLATES_DIR"
cp -R "$ANTLR3_PATH/tool/src/main/resources/$TEMLATES_DIR" "$REPACK_DIR/$TEMLATES_DIR"
zip -ru "$CURRENT_DIR/antlr-complete-3.5.jar.new" *
cd "$CURRENT_DIR"
rm -Rf "antlr-complete-3.5.jar.old"
mv "$UBERJAR_PATH" "antlr-complete-3.5.jar.old"
mv "antlr-complete-3.5.jar.new" "$UBERJAR_PATH"
