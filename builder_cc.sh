#!/bin/bash

PATH_MAIN=/vm/1/openwrt
CONFIGS=/vm/1/openwrt/openwrt_configs
PACKAGES=/vm/1/openwrt/packs
BUILDROOT=/vm/1/openwrt/chaos_calmer

cleaner (){
	rm -rf $BUILDROOT
}

construct_mips(){
	cd $PATH_MAIN
	svn co svn://svn.openwrt.org/openwrt/branches/chaos_calmer
	cd chaos_calmer
	echo "src-git softethervpn https://github.com/alberts00/OpenWRT-package-softether.git" >> feeds.conf.default
	./scripts/feeds update
	./scripts/feeds install softethervpn
}

get_ipk(){
	cd $BUILDROOT
	make prepare -j3
	make package/softethervpn/compile V=99 -j3
	find -name "softether*.ipk" -type f -exec /bin/mv {} $PACKAGES/ \;
}



cd $PATH_MAIN

construct_mips
cp $CONFIGS/.config_ar71xx $BUILDROOT/.config
get_ipk
cleaner

construct_mips
cp $CONFIGS/.config_atheros $BUILDROOT/.config
get_ipk
cleaner

construct_mips
cp $CONFIGS/.config_brcm47xx $BUILDROOT/.config
get_ipk
cleaner

construct_mips
cp $CONFIGS/.config_brcm63xx $BUILDROOT/.config
get_ipk
cleaner

construct_mips
cp $CONFIGS/.config_ramips $BUILDROOT/.config
get_ipk
cleaner

construct_mips
cp $CONFIGS/.config_x86 $BUILDROOT/.config
get_ipk
cleaner
