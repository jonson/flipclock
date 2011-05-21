#!/bin/sh

## quick script to generate the required android resources from the image sprites

## needed for the android drawable layers, so we know how much to offset the bottom image
ORIGINAL_DIGIT_HEIGHT=39

## 80 seems to be a decent speed
ANIMATION_SPEED=80

## 0 here indicates no resize
HDPI_HEIGHT=0
MDPI_HEIGHT=0
LDPI_HEIGHT=0

resieAndCopy()
{
 FILE=$1
 NAME=$2
# if ( ("$HDPI_HEIGHT" -ne "0") && ("$MDPI_HEIGHT" -ne 0) && ("$LDPI_HEIGHT" -ne 0))
 if [ "$HDPI_HEIGHT" -gt "0" ] && [ "$MDPI_HEIGHT" -gt "0" ] && [ "$LDPI_HEIGHT" -gt "0" ]
 then
   convert $FILE -resize x${HDPI_HEIGHT}  generated/drawable-hdpi/${NAME}
   convert $FILE -resize x${MDPI_HEIGHT}  generated/drawable-mdpi/${NAME}
   convert $FILE -resize x${LDPI_HEIGHT}  generated/drawable-ldpi/${NAME}
 else
   cp $FILE generated/drawable-hdpi/${NAME}
   cp $FILE generated/drawable-mdpi/${NAME}
   cp $FILE generated/drawable-ldpi/${NAME}
 fi
}

mkdir_safe()
{
  if [ ! -e $1 ]; then
    mkdir $1
  fi 
}

writeIntegerFile()
{
  FNAME=$1
  SPEED=$2
  echo '<?xml version="1.0" encoding="utf-8"?>' >> $FNAME
  echo '<resources>' >> $FNAME
  echo '  <integer name="animationSpeed">'${SPEED}'</integer>' >> $FNAME
  echo '</resources>' >> $FNAME
}

writeDimenFile()
{
  FNAME=$1
  HEIGHT=$2
  echo '<?xml version="1.0" encoding="utf-8"?>' >> $FNAME
  echo '<resources>' >> $FNAME
  echo '  <dimen name="digitHeight">'${HEIGHT}'px</dimen>' >> $FNAME
  echo '</resources>' >> $FNAME
}

writeIntegers() 
{
  mkdir_safe generated/values
  writeIntegerFile generated/values/integers.xml $ANIMATION_SPEED $ORIGINAL_DIGIT_HEIGHT
}

writeDimens()
{
  if [ "$HDPI_HEIGHT" -gt "0" ] && [ "$MDPI_HEIGHT" -gt "0" ] && [ "$LDPI_HEIGHT" -gt "0" ]
  then
    mkdir_safe generated/values-hdpi
    mkdir_safe generated/values-mdpi
    mkdir_safe generated/values-ldpi
    writeDimenFile generated/values-hdpi/dimens.xml $HDPI_HEIGHT
    writeDimenFile generated/values-mdpi/dimens.xml $MDPI_HEIGHT
    writeDimenFile generated/values-ldpi/dimens.xml $LDPI_HEIGHT
  else
    mkdir_safe generated/values
    writeDimenFile generated/values/dimens.xml $ORIGINAL_DIGIT_HEIGHT
  fi
}


rm -rf generated
mkdir generated
mkdir generated/drawable-ldpi
mkdir generated/drawable-mdpi
mkdir generated/drawable-hdpi

convert digits-top.png -crop 159x${ORIGINAL_DIGIT_HEIGHT} tmp_%d.png

for file in tmp_*;
do
  name=${file%\.*}
  name=${name:3}
  convert $file -crop 53x0 generated/top${name}_%d.png 
done

rm tmp*

for file in generated/top*png;
do
  name=${file:10}
  resieAndCopy $file $name
done

rm generated/top*png

convert digits-bottom.png -crop 212x64 tmp_%d.png

for file in tmp_*;
do
  name=${file%\.*}
  name=${name:3}
  convert $file -crop 53x0 bbb${name}_%d.png 
done

rm tmp*

for file in bbb*;
do
  name=${file:3}
  convert +repage $file -crop 53x${ORIGINAL_DIGIT_HEIGHT}+0+0 generated/bottom${name}
done

rm bbb*

for file in generated/bottom*png;
do
  name=${file:10}
  resieAndCopy $file $name
done

rm generated/bottom*png

#finally create the actual digit images

writelayerxml()
{
  FNUM=$1
  FROM=$2
  TO=$3

  TOP_DIGIT=$4
  TOP_DIGIT_INDEX=$5
  BOT_DIGIT=$6
  BOT_DIGIT_INDEX=$7
 
  FNAME=generated/drawable/full${FROM}_${TO}__${FNUM}.xml
  echo '<?xml version="1.0" encoding="utf-8"?>' >> $FNAME
  echo '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">' >> $FNAME
  echo '  <item>' >> $FNAME
  echo '    <bitmap android:gravity="top|left" android:src="@drawable/top_'${TOP_DIGIT}'_'${TOP_DIGIT_INDEX}'" />' >> $FNAME
  echo '  </item>' >> $FNAME
  echo '  <item android:top="@dimen/digitHeight" android:left="0px">' >> $FNAME
  echo '    <bitmap android:src="@drawable/bottom_'${BOT_DIGIT}'_'${BOT_DIGIT_INDEX}'" />' >> $FNAME
  echo '  </item>' >> $FNAME
  echo '</layer-list>' >> $FNAME

}

writeanim()
{
  FROM=$1
  TO=$2

  FNAME=generated/anim/flip_${FROM}_${TO}.xml
  echo '<?xml version="1.0" encoding="utf-8"?>' >> $FNAME
  echo '<animation-list xmlns:android="http://schemas.android.com/apk/res/android" android:oneshot="true">' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__0" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__1" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__2" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__3" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__4" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__5" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__6" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '  <item android:drawable="@drawable/full'${FROM}'_'${TO}'__7" android:duration="@integer/animationSpeed" />' >> $FNAME
  echo '</animation-list>' >> $FNAME
}

writexml()
{
  FROM=$1
  TO=$2
  writeanim $FROM $TO
  writelayerxml 0 ${FROM} ${TO} ${FROM} 0 ${FROM} 0
  writelayerxml 1 ${FROM} ${TO} ${FROM} 1 ${FROM} 0
  writelayerxml 2 ${FROM} ${TO} ${FROM} 2 ${FROM} 0
  writelayerxml 3 ${FROM} ${TO} ${TO} 0 ${FROM} 0
  writelayerxml 4 ${FROM} ${TO} ${TO} 0 ${FROM} 1
  writelayerxml 5 ${FROM} ${TO} ${TO} 0 ${TO} 2
  writelayerxml 6 ${FROM} ${TO} ${TO} 0 ${TO} 3
  writelayerxml 7 ${FROM} ${TO} ${TO} 0 ${TO} 0
}


FROM=0
TO=1
mkdir generated/drawable
mkdir generated/anim
writexml 0 1
writexml 1 2
writexml 2 3
writexml 3 4
writexml 4 5
writexml 5 6
writexml 6 7
writexml 7 8
writexml 8 9
writexml 9 0

# 59 -> 00 (minute)
writexml 5 0

# 23 -> 00 (hour)
writexml 2 0
writexml 3 0

# 12 -> 01 (hour)
writexml 1 0
writexml 2 1

writeIntegers
writeDimens
