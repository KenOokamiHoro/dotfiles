export ANDROID_ROOT=/data/libhybris
function sfossdk(){
    source ~/.env/.hadk.env
    export PLATFORM_SDK_ROOT=/srv/mer
    $PLATFORM_SDK_ROOT/sdks/sfossdk/mer-sdk-chroot 
}
function hybris_build(){
    export PS1="(hybris) "$PS1
    source ~/.env/.hadk.env
    setopt shwordsplit
    export LC_ALL=C
    cd $ANDROID_ROOT
    source build/envsetup.sh
    source venv/bin/activate
    export USE_CCACHE=1 
    breakfast $DEVICE
}


