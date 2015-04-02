#!/bin/bash

PATH_MAIN=/vm/1/openwrt
CONFIGS=/vm/1/openwrt/openwrt_configs
PACKAGES=/vm/1/openwrt/packs
BUILDROOT=/vm/1/openwrt/barrier_breaker

cleaner (){
	rm -rf $BUILDROOT
}

construct_mips(){
	cd $PATH_MAIN
	svn co svn://svn.openwrt.org/openwrt/branches/barrier_breaker
	cd barrier_breaker
	echo "src-git softethervpn https://github.com/alberts00/OpenWRT-package-softether.git" >> feeds.conf.default
	./scripts/feeds update
	./scripts/feeds install softethervpn
}

get_ipk(){
	cd $BUILDROOT
	make prepare -j2
	make package/softethervpn/compile V=99 -j2
	find $BUILDROOT -name "softether*.ipk" -type f -exec /bin/mv {} $PACKAGES/ \;
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
cp $CONFIGS/.config_ramips_24ksec $BUILDROOT/.config
get_ipk
cleaner

