# Performs clean and full rebuild.
# See 'quickrepack.sh' for details.

source ./common.sh
cd $ANTLR3_PATH
mvn clean
mvn -Dgpg.skip=true -Dbootclasspath.java5=/System/Library/Frameworks/JavaVM.framework/Versions/1.5/Classes/classes.jar -Dbootclasspath.java6=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Classes/classes.jar -DskipTests package
cd $CURRENT_DIR
rm -Rf $REPACK_DIR
