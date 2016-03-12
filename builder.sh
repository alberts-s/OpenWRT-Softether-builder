#!/bin/bash

if [ $1 == "barrier_breaker" ]; then VER="14.07"
elif [ $1 == "chaos_calmer" ]; then VER="15.05"
fi
##barrier_breaker or chaos_calmer
BUILDFOR=$1
PATH_MAIN=/vm/1/openwrt
CONFIGS=/vm/1/openwrt/OpenWRT-Softether-builder/openwrt_configs
PACKAGES=/vm/1/openwrt/packs/$BUILDFOR/
BUILDROOT=/vm/1/openwrt/$BUILDFOR
MAKEFILE=/tmp/OpenWRT-package-softether/softethervpn/Makefile
UPDATEMAKEFILE=/vm/1/openwrt/OpenWRT-Softether-builder/update_makefile.py
CORES=3

cleaner (){
	rm -rf $BUILDROOT
}

construct_mips(){
	cd $PATH_MAIN
	git clone git://git.openwrt.org/$VER/openwrt.git ./$BUILDFOR
	cd $BUILDFOR
	echo "src-cpy softethervpn /tmp/OpenWRT-package-softether" >> feeds.conf.default
	./scripts/feeds update
	./scripts/feeds install softethervpn
}

get_ipk(){
	cd $BUILDROOT
	make prepare -j$CORES
	make package/softethervpn/compile V=99 -j$CORES
	find $BUILDROOT -name "softether*.ipk" -type f -exec /bin/mv {} $PACKAGES/ \;
}



cd $PATH_MAIN

git clone https://github.com/Alberts00/OpenWRT-package-softether /tmp/OpenWRT-package-softether
python3 $UPDATEMAKEFILE $MAKEFILE

construct_mips
if cp $CONFIGS/$BUILDFOR/.config_ar71xx $BUILDROOT/.config ; then get_ipk; fi

if cp $CONFIGS/$BUILDFOR/.config_atheros $BUILDROOT/.config ; then get_ipk; fi

if cp $CONFIGS/$BUILDFOR/.config_brcm47xx $BUILDROOT/.config ; then get_ipk; fi

if cp $CONFIGS/$BUILDFOR/.config_brcm63xx $BUILDROOT/.config ; then get_ipk; fi

if cp $CONFIGS/$BUILDFOR/.config_ramips_24ksec $BUILDROOT/.config ; then get_ipk; fi

if cp $CONFIGS/$BUILDFOR/.config_x86 $BUILDROOT/.config ; then get_ipk; fi

cleaner

rm -rf /tmp/OpenWRT-package-softether
