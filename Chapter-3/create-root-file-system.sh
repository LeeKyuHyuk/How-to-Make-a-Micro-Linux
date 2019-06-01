#!/bin/bash
set -o nounset
set -o errexit

export CONFIG_TARGET=arm-linux-gnueabihf
export CONFIG_PREFIX=$HOME/tools
export CONFIG_ROOTFS=$HOME/rootfs
export CC="$CONFIG_PREFIX/bin/$CONFIG_TARGET-gcc"
export CXX="$CONFIG_PREFIX/bin/$CONFIG_TARGET-g++"
export AR="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ar"
export AS="$CONFIG_PREFIX/bin/$CONFIG_TARGET-as"
export LD="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ld"
export RANLIB="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ranlib"
export READELF="$CONFIG_PREFIX/bin/$CONFIG_TARGET-readelf"
export STRIP="$CONFIG_PREFIX/bin/$CONFIG_TARGET-strip"
export PARALLEL_JOBS=$(cat /proc/cpuinfo | grep cores | wc -l)

rm -rf $CONFIG_ROOTFS
mkdir -pv $CONFIG_ROOTFS

# Creating Directories
mkdir -pv $CONFIG_ROOTFS/{dev,etc,lib,media,mnt,opt,proc,root,run,sys,tmp,usr,qnas}
mkdir -pv $CONFIG_ROOTFS/usr/{bin,lib,sbin}
ln -snvf lib $CONFIG_ROOTFS/lib32
ln -snvf lib $CONFIG_ROOTFS/usr/lib32
mkdir -pv $CONFIG_ROOTFS/var/log

# Creating Essential Files and Symlinks
ln -snvf ../proc/self/fd $CONFIG_ROOTFS/dev/fd
ln -snvf ../proc/self/fd/2 $CONFIG_ROOTFS/dev/stderr
ln -snvf ../proc/self/fd/0 $CONFIG_ROOTFS/dev/stdin
ln -snvf ../proc/self/fd/1 $CONFIG_ROOTFS/dev/stdout
ln -snvf ../proc/self/mounts $CONFIG_ROOTFS/etc/mtab
ln -snvf ../tmp/resolv.conf $CONFIG_ROOTFS/etc/resolv.conf

cat > $CONFIG_ROOTFS/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/sh
daemon:x:1:1:daemon:/usr/sbin:/bin/false
bin:x:2:2:bin:/bin:/bin/false
sys:x:3:3:sys:/dev:/bin/false
sync:x:4:100:sync:/bin:/bin/sync
mail:x:8:8:mail:/var/spool/mail:/bin/false
www-data:x:33:33:www-data:/var/www:/bin/false
operator:x:37:37:Operator:/var:/bin/false
nobody:x:65534:65534:nobody:/home:/bin/false
EOF

cat > $CONFIG_ROOTFS/etc/shadow << "EOF"
root::10933:0:99999:7:::
daemon:*:10933:0:99999:7:::
bin:*:10933:0:99999:7:::
sys:*:10933:0:99999:7:::
sync:*:10933:0:99999:7:::
mail:*:10933:0:99999:7:::
www-data:*:10933:0:99999:7:::
operator:*:10933:0:99999:7:::
nobody:*:10933:0:99999:7:::
EOF
# sed -i -e s,^root:[^:]*:,root:"`$CONFIG_PREFIX/bin/mkpasswd -m "sha-512" "$CONFIG_ROOT_PASSWD"`":, $CONFIG_ROOTFS/etc/shadow

cat > $CONFIG_ROOTFS/etc/group << "EOF"
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
kmem:x:9:
wheel:x:10:root
cdrom:x:11:
dialout:x:18:
floppy:x:19:
video:x:28:
audio:x:29:
tape:x:32:
www-data:x:33:
operator:x:37:
utmp:x:43:
plugdev:x:46:
staff:x:50:
lock:x:54:
netdev:x:82:
users:x:100:
nogroup:x:65534:
EOF

echo "localhost" > $CONFIG_ROOTFS/etc/hostname
echo "127.0.0.1	localhost" > $CONFIG_ROOTFS/etc/hosts

cat > $CONFIG_ROOTFS/etc/protocols << "EOF"
# Internet (IP) protocols
#
# Updated from http://www.iana.org/assignments/protocol-numbers and other
# sources.

ip	0	IP		# internet protocol, pseudo protocol number
hopopt	0	HOPOPT		# IPv6 Hop-by-Hop Option [RFC1883]
icmp	1	ICMP		# internet control message protocol
igmp	2	IGMP		# Internet Group Management
ggp	3	GGP		# gateway-gateway protocol
ipencap	4	IP-ENCAP	# IP encapsulated in IP (officially ``IP'')
st	5	ST		# ST datagram mode
tcp	6	TCP		# transmission control protocol
egp	8	EGP		# exterior gateway protocol
igp	9	IGP		# any private interior gateway (Cisco)
pup	12	PUP		# PARC universal packet protocol
udp	17	UDP		# user datagram protocol
hmp	20	HMP		# host monitoring protocol
xns-idp	22	XNS-IDP		# Xerox NS IDP
rdp	27	RDP		# "reliable datagram" protocol
iso-tp4	29	ISO-TP4		# ISO Transport Protocol class 4 [RFC905]
dccp	33	DCCP		# Datagram Congestion Control Prot. [RFC4340]
xtp	36	XTP		# Xpress Transfer Protocol
ddp	37	DDP		# Datagram Delivery Protocol
idpr-cmtp 38	IDPR-CMTP	# IDPR Control Message Transport
ipv6	41	IPv6		# Internet Protocol, version 6
ipv6-route 43	IPv6-Route	# Routing Header for IPv6
ipv6-frag 44	IPv6-Frag	# Fragment Header for IPv6
idrp	45	IDRP		# Inter-Domain Routing Protocol
rsvp	46	RSVP		# Reservation Protocol
gre	47	GRE		# General Routing Encapsulation
esp	50	IPSEC-ESP	# Encap Security Payload [RFC2406]
ah	51	IPSEC-AH	# Authentication Header [RFC2402]
skip	57	SKIP		# SKIP
ipv6-icmp 58	IPv6-ICMP	# ICMP for IPv6
ipv6-nonxt 59	IPv6-NoNxt	# No Next Header for IPv6
ipv6-opts 60	IPv6-Opts	# Destination Options for IPv6
rspf	73	RSPF CPHB	# Radio Shortest Path First (officially CPHB)
vmtp	81	VMTP		# Versatile Message Transport
eigrp	88	EIGRP		# Enhanced Interior Routing Protocol (Cisco)
ospf	89	OSPFIGP		# Open Shortest Path First IGP
ax.25	93	AX.25		# AX.25 frames
ipip	94	IPIP		# IP-within-IP Encapsulation Protocol
etherip	97	ETHERIP		# Ethernet-within-IP Encapsulation [RFC3378]
encap	98	ENCAP		# Yet Another IP encapsulation [RFC1241]
#	99			# any private encryption scheme
pim	103	PIM		# Protocol Independent Multicast
ipcomp	108	IPCOMP		# IP Payload Compression Protocol
vrrp	112	VRRP		# Virtual Router Redundancy Protocol [RFC5798]
l2tp	115	L2TP		# Layer Two Tunneling Protocol [RFC2661]
isis	124	ISIS		# IS-IS over IPv4
sctp	132	SCTP		# Stream Control Transmission Protocol
fc	133	FC		# Fibre Channel
mobility-header 135 Mobility-Header # Mobility Support for IPv6 [RFC3775]
udplite	136	UDPLite		# UDP-Lite [RFC3828]
mpls-in-ip 137	MPLS-in-IP	# MPLS-in-IP [RFC4023]
manet	138			# MANET Protocols [RFC5498]
hip	139	HIP		# Host Identity Protocol
shim6	140	Shim6		# Shim6 Protocol [RFC5533]
wesp	141	WESP		# Wrapped Encapsulating Security Payload
rohc	142	ROHC		# Robust Header Compression
EOF

cat > $CONFIG_ROOTFS/etc/protocols << "EOF"
# /etc/services:
# $Id: services,v 1.1 2004/10/09 02:49:18 andersen Exp $
#
# Network services, Internet style
#
# Note that it is presently the policy of IANA to assign a single well-known
# port number for both TCP and UDP; hence, most entries here have two entries
# even if the protocol doesn't support UDP operations.
# Updated from RFC 1700, ``Assigned Numbers'' (October 1994).  Not all ports
# are included, only the more common ones.

tcpmux		1/tcp				# TCP port service multiplexer
echo		7/tcp
echo		7/udp
discard		9/tcp		sink null
discard		9/udp		sink null
systat		11/tcp		users
daytime		13/tcp
daytime		13/udp
netstat		15/tcp
qotd		17/tcp		quote
msp		18/tcp				# message send protocol
msp		18/udp				# message send protocol
chargen		19/tcp		ttytst source
chargen		19/udp		ttytst source
ftp-data	20/tcp
ftp		21/tcp
fsp		21/udp		fspd
ssh		22/tcp				# SSH Remote Login Protocol
ssh		22/udp				# SSH Remote Login Protocol
telnet		23/tcp
# 24 - private
smtp		25/tcp		mail
# 26 - unassigned
time		37/tcp		timserver
time		37/udp		timserver
rlp		39/udp		resource	# resource location
nameserver	42/tcp		name		# IEN 116
whois		43/tcp		nicname
re-mail-ck	50/tcp				# Remote Mail Checking Protocol
re-mail-ck	50/udp				# Remote Mail Checking Protocol
domain		53/tcp		nameserver	# name-domain server
domain		53/udp		nameserver
mtp		57/tcp				# deprecated
bootps		67/tcp				# BOOTP server
bootps		67/udp
bootpc		68/tcp				# BOOTP client
bootpc		68/udp
tftp		69/udp
gopher		70/tcp				# Internet Gopher
gopher		70/udp
rje		77/tcp		netrjs
finger		79/tcp
www		80/tcp		http		# WorldWideWeb HTTP
www		80/udp				# HyperText Transfer Protocol
link		87/tcp		ttylink
kerberos	88/tcp		kerberos5 krb5	# Kerberos v5
kerberos	88/udp		kerberos5 krb5	# Kerberos v5
supdup		95/tcp
# 100 - reserved
hostnames	101/tcp		hostname	# usually from sri-nic
iso-tsap	102/tcp		tsap		# part of ISODE.
csnet-ns	105/tcp		cso-ns		# also used by CSO name server
csnet-ns	105/udp		cso-ns
# unfortunately the poppassd (Eudora) uses a port which has already
# been assigned to a different service. We list the poppassd as an
# alias here. This should work for programs asking for this service.
# (due to a bug in inetd the 3com-tsmux line is disabled)
#3com-tsmux	106/tcp		poppassd
#3com-tsmux	106/udp		poppassd
rtelnet		107/tcp				# Remote Telnet
rtelnet		107/udp
pop-2		109/tcp		postoffice	# POP version 2
pop-2		109/udp
pop-3		110/tcp				# POP version 3
pop-3		110/udp
sunrpc		111/tcp		portmapper	# RPC 4.0 portmapper TCP
sunrpc		111/udp		portmapper	# RPC 4.0 portmapper UDP
auth		113/tcp		authentication tap ident
sftp		115/tcp
uucp-path	117/tcp
nntp		119/tcp		readnews untp	# USENET News Transfer Protocol
ntp		123/tcp
ntp		123/udp				# Network Time Protocol
netbios-ns	137/tcp				# NETBIOS Name Service
netbios-ns	137/udp
netbios-dgm	138/tcp				# NETBIOS Datagram Service
netbios-dgm	138/udp
netbios-ssn	139/tcp				# NETBIOS session service
netbios-ssn	139/udp
imap2		143/tcp				# Interim Mail Access Proto v2
imap2		143/udp
snmp		161/udp				# Simple Net Mgmt Proto
snmp-trap	162/udp		snmptrap	# Traps for SNMP
cmip-man	163/tcp				# ISO mgmt over IP (CMOT)
cmip-man	163/udp
cmip-agent	164/tcp
cmip-agent	164/udp
xdmcp		177/tcp				# X Display Mgr. Control Proto
xdmcp		177/udp
nextstep	178/tcp		NeXTStep NextStep	# NeXTStep window
nextstep	178/udp		NeXTStep NextStep	# server
bgp		179/tcp				# Border Gateway Proto.
bgp		179/udp
prospero	191/tcp				# Cliff Neuman's Prospero
prospero	191/udp
irc		194/tcp				# Internet Relay Chat
irc		194/udp
smux		199/tcp				# SNMP Unix Multiplexer
smux		199/udp
at-rtmp		201/tcp				# AppleTalk routing
at-rtmp		201/udp
at-nbp		202/tcp				# AppleTalk name binding
at-nbp		202/udp
at-echo		204/tcp				# AppleTalk echo
at-echo		204/udp
at-zis		206/tcp				# AppleTalk zone information
at-zis		206/udp
qmtp		209/tcp				# The Quick Mail Transfer Protocol
qmtp		209/udp				# The Quick Mail Transfer Protocol
z3950		210/tcp		wais		# NISO Z39.50 database
z3950		210/udp		wais
ipx		213/tcp				# IPX
ipx		213/udp
imap3		220/tcp				# Interactive Mail Access
imap3		220/udp				# Protocol v3
ulistserv	372/tcp				# UNIX Listserv
ulistserv	372/udp
https		443/tcp				# MCom
https		443/udp				# MCom
snpp		444/tcp				# Simple Network Paging Protocol
snpp		444/udp				# Simple Network Paging Protocol
saft		487/tcp				# Simple Asynchronous File Transfer
saft		487/udp				# Simple Asynchronous File Transfer
npmp-local	610/tcp		dqs313_qmaster	# npmp-local / DQS
npmp-local	610/udp		dqs313_qmaster	# npmp-local / DQS
npmp-gui	611/tcp		dqs313_execd	# npmp-gui / DQS
npmp-gui	611/udp		dqs313_execd	# npmp-gui / DQS
hmmp-ind	612/tcp		dqs313_intercell# HMMP Indication / DQS
hmmp-ind	612/udp		dqs313_intercell# HMMP Indication / DQS
#
# UNIX specific services
#
exec		512/tcp
biff		512/udp		comsat
login		513/tcp
who		513/udp		whod
shell		514/tcp		cmd		# no passwords used
syslog		514/udp
printer		515/tcp		spooler		# line printer spooler
talk		517/udp
ntalk		518/udp
route		520/udp		router routed	# RIP
timed		525/udp		timeserver
tempo		526/tcp		newdate
courier		530/tcp		rpc
conference	531/tcp		chat
netnews		532/tcp		readnews
netwall		533/udp				# -for emergency broadcasts
uucp		540/tcp		uucpd		# uucp daemon
afpovertcp	548/tcp				# AFP over TCP
afpovertcp	548/udp				# AFP over TCP
remotefs	556/tcp		rfs_server rfs	# Brunhoff remote filesystem
klogin		543/tcp				# Kerberized `rlogin' (v5)
kshell		544/tcp		krcmd		# Kerberized `rsh' (v5)
kerberos-adm	749/tcp				# Kerberos `kadmin' (v5)
#
webster		765/tcp				# Network dictionary
webster		765/udp
#
# From ``Assigned Numbers'':
#
#> The Registered Ports are not controlled by the IANA and on most systems
#> can be used by ordinary user processes or programs executed by ordinary
#> users.
#
#> Ports are used in the TCP [45,106] to name the ends of logical
#> connections which carry long term conversations.  For the purpose of
#> providing services to unknown callers, a service contact port is
#> defined.  This list specifies the port used by the server process as its
#> contact port.  While the IANA can not control uses of these ports it
#> does register or list uses of these ports as a convienence to the
#> community.
#
nfsdstatus	1110/tcp
nfsd-keepalive	1110/udp

ingreslock	1524/tcp
ingreslock	1524/udp
prospero-np	1525/tcp			# Prospero non-privileged
prospero-np	1525/udp
datametrics	1645/tcp	old-radius	# datametrics / old radius entry
datametrics	1645/udp	old-radius	# datametrics / old radius entry
sa-msg-port	1646/tcp	old-radacct	# sa-msg-port / old radacct entry
sa-msg-port	1646/udp	old-radacct	# sa-msg-port / old radacct entry
radius		1812/tcp			# Radius
radius		1812/udp			# Radius
radacct		1813/tcp			# Radius Accounting
radacct		1813/udp			# Radius Accounting
nfsd		2049/tcp	nfs
nfsd		2049/udp	nfs
cvspserver	2401/tcp			# CVS client/server operations
cvspserver	2401/udp			# CVS client/server operations
mysql		3306/tcp			# MySQL
mysql		3306/udp			# MySQL
rfe		5002/tcp			# Radio Free Ethernet
rfe		5002/udp			# Actually uses UDP only
cfengine	5308/tcp			# CFengine
cfengine	5308/udp			# CFengine
bbs		7000/tcp			# BBS service
#
#
# Kerberos (Project Athena/MIT) services
# Note that these are for Kerberos v4, and are unofficial.  Sites running
# v4 should uncomment these and comment out the v5 entries above.
#
kerberos4	750/udp		kerberos-iv kdc	# Kerberos (server) udp
kerberos4	750/tcp		kerberos-iv kdc	# Kerberos (server) tcp
kerberos_master	751/udp				# Kerberos authentication
kerberos_master	751/tcp				# Kerberos authentication
passwd_server	752/udp				# Kerberos passwd server
krb_prop	754/tcp				# Kerberos slave propagation
krbupdate	760/tcp		kreg		# Kerberos registration
kpasswd		761/tcp		kpwd		# Kerberos "passwd"
kpop		1109/tcp			# Pop with Kerberos
knetd		2053/tcp			# Kerberos de-multiplexor
zephyr-srv	2102/udp			# Zephyr server
zephyr-clt	2103/udp			# Zephyr serv-hm connection
zephyr-hm	2104/udp			# Zephyr hostmanager
eklogin		2105/tcp			# Kerberos encrypted rlogin
#
# Unofficial but necessary (for NetBSD) services
#
supfilesrv	871/tcp				# SUP server
supfiledbg	1127/tcp			# SUP debugging
#
# Datagram Delivery Protocol services
#
rtmp		1/ddp				# Routing Table Maintenance Protocol
nbp		2/ddp				# Name Binding Protocol
echo		4/ddp				# AppleTalk Echo Protocol
zip		6/ddp				# Zone Information Protocol
#
# Services added for the Debian GNU/Linux distribution
poppassd	106/tcp				# Eudora
poppassd	106/udp				# Eudora
mailq		174/tcp				# Mailer transport queue for Zmailer
mailq		174/tcp				# Mailer transport queue for Zmailer
omirr		808/tcp		omirrd		# online mirror
omirr		808/udp		omirrd		# online mirror
rmtcfg		1236/tcp			# Gracilis Packeten remote config server
xtel		1313/tcp			# french minitel
coda_opcons	1355/udp			# Coda opcons            (Coda fs)
coda_venus	1363/udp			# Coda venus             (Coda fs)
coda_auth	1357/udp			# Coda auth              (Coda fs)
coda_udpsrv	1359/udp			# Coda udpsrv            (Coda fs)
coda_filesrv	1361/udp			# Coda filesrv           (Coda fs)
codacon		1423/tcp	venus.cmu	# Coda Console           (Coda fs)
coda_aux1	1431/tcp			# coda auxiliary service (Coda fs)
coda_aux1	1431/udp			# coda auxiliary service (Coda fs)
coda_aux2	1433/tcp			# coda auxiliary service (Coda fs)
coda_aux2	1433/udp			# coda auxiliary service (Coda fs)
coda_aux3	1435/tcp			# coda auxiliary service (Coda fs)
coda_aux3	1435/udp			# coda auxiliary service (Coda fs)
cfinger		2003/tcp			# GNU Finger
afbackup	2988/tcp			# Afbackup system
afbackup	2988/udp			# Afbackup system
icp		3130/tcp			# Internet Cache Protocol (Squid)
icp		3130/udp			# Internet Cache Protocol (Squid)
postgres	5432/tcp			# POSTGRES
postgres	5432/udp			# POSTGRES
fax		4557/tcp			# FAX transmission service        (old)
hylafax		4559/tcp			# HylaFAX client-server protocol  (new)
noclog		5354/tcp			# noclogd with TCP (nocol)
noclog		5354/udp			# noclogd with UDP (nocol)
hostmon		5355/tcp			# hostmon uses TCP (nocol)
hostmon		5355/udp			# hostmon uses TCP (nocol)
ircd		6667/tcp			# Internet Relay Chat
ircd		6667/udp			# Internet Relay Chat
webcache	8080/tcp			# WWW caching service
webcache	8080/udp			# WWW caching service
tproxy		8081/tcp			# Transparent Proxy
tproxy		8081/udp			# Transparent Proxy
mandelspawn	9359/udp	mandelbrot	# network mandelbrot
amanda		10080/udp			# amanda backup services
amandaidx	10082/tcp			# amanda backup services
amidxtape	10083/tcp			# amanda backup services
isdnlog		20011/tcp			# isdn logging system
isdnlog		20011/udp			# isdn logging system
vboxd		20012/tcp			# voice box system
vboxd		20012/udp			# voice box system
binkp           24554/tcp			# Binkley
binkp           24554/udp			# Binkley
asp		27374/tcp			# Address Search Protocol
asp		27374/udp			# Address Search Protocol
tfido           60177/tcp			# Ifmail
tfido           60177/udp			# Ifmail
fido            60179/tcp			# Ifmail
fido            60179/udp			# Ifmail

# Local services
EOF

mkdir -pv $CONFIG_ROOTFS/etc/profile.d
echo "umask 022" > $CONFIG_ROOTFS/etc/profile.d/umask.sh

wget -c https://www.busybox.net/downloads/busybox-1.30.1.tar.bz2
tar xvjf busybox-1.30.1.tar.bz2
make -j$PARALLEL_JOBS distclean -C busybox-1.30.1
make -j$PARALLEL_JOBS ARCH=arm defconfig -C busybox-1.30.1
sed -i "s/.*CONFIG_STATIC.*/CONFIG_STATIC=y/" busybox-1.30.1/.config
make -j$PARALLEL_JOBS ARCH=arm CROSS_COMPILE="$CONFIG_PREFIX/bin/$CONFIG_TARGET-" -C busybox-1.30.1
make -j$PARALLEL_JOBS ARCH=arm CROSS_COMPILE="$CONFIG_PREFIX/bin/$CONFIG_TARGET-" CONFIG_PREFIX=$CONFIG_ROOTFS install -C busybox-1.30.1
rm -rf busybox-1.30.1

# Bootscripts
mkdir -pv $CONFIG_ROOTFS/etc/init.d
cat > $CONFIG_ROOTFS/etc/init.d/rcK << "EOF"
#!/bin/sh


# Stop all init scripts in /etc/init.d
# executing them in reversed numerical order.
#
for i in $(ls -r /etc/init.d/S??*) ;do

     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     case "$i" in
	*.sh)
	    # Source shell script for speed.
	    (
		trap - INT QUIT TSTP
		set stop
		. $i
	    )
	    ;;
	*)
	    # No sh extension, so fork subprocess.
	    $i stop
	    ;;
    esac
done
EOF
chmod -v 755 $CONFIG_ROOTFS/etc/init.d/rcK

cat > $CONFIG_ROOTFS/etc/init.d/rcS << "EOF"
#!/bin/sh


# Start all init scripts in /etc/init.d
# executing them in numerical order.
#
for i in /etc/init.d/S??* ;do

     # Ignore dangling symlinks (if any).
     [ ! -f "$i" ] && continue

     case "$i" in
	*.sh)
	    # Source shell script for speed.
	    (
		trap - INT QUIT TSTP
		set start
		. $i
	    )
	    ;;
	*)
	    # No sh extension, so fork subprocess.
	    $i start
	    ;;
    esac
done
EOF
chmod -v 755 $CONFIG_ROOTFS/etc/init.d/rcS

# System V Bootscript Usage and Configuration
cat > $CONFIG_ROOTFS/etc/inittab << "EOF"
# /etc/inittab
#
# Copyright (C) 2001 Erik Andersen <andersen@codepoet.org>
#
# Note: BusyBox init doesn't support runlevels.  The runlevels field is
# completely ignored by BusyBox init. If you want runlevels, use
# sysvinit.
#
# Format for each entry: <id>:<runlevels>:<action>:<process>
#
# id        == tty to run on, or empty for /dev/console
# runlevels == ignored
# action    == one of sysinit, respawn, askfirst, wait, and once
# process   == program to run

# Startup the system
::sysinit:/bin/mount -t proc proc /proc
::sysinit:/bin/mount -o remount,rw /
::sysinit:/bin/mkdir -p /dev/pts /dev/shm
::sysinit:/bin/mount -a
::sysinit:/sbin/swapon -a
null::sysinit:/bin/ln -sf /proc/self/fd /dev/fd
null::sysinit:/bin/ln -sf /proc/self/fd/0 /dev/stdin
null::sysinit:/bin/ln -sf /proc/self/fd/1 /dev/stdout
null::sysinit:/bin/ln -sf /proc/self/fd/2 /dev/stderr
::sysinit:/bin/hostname -F /etc/hostname
# now run any rc scripts
::sysinit:/etc/init.d/rcS

# Put a getty on the serial port
console::respawn:/sbin/getty -L  ttyAMA0 0 vt100 # GENERIC_SERIAL
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console

# Stuff to do for the 3-finger salute
#::ctrlaltdel:/sbin/reboot

# Stuff to do before rebooting
::shutdown:/etc/init.d/rcK
::shutdown:/sbin/swapoff -a
::shutdown:/bin/umount -a -r
EOF

echo "Welcome to Miero Linux" > $CONFIG_ROOTFS/etc/issue


# The Bash Shell Startup Files
cat > $CONFIG_ROOTFS/etc/profile << "EOF"
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [ "$PS1" ]; then
	if [ "`id -u`" -eq 0 ]; then
		export PS1='# '
	else
		export PS1='$ '
	fi
fi

export PAGER='/bin/more'
export EDITOR='/bin/vi'

# Source configuration files from /etc/profile.d
for i in /etc/profile.d/*.sh ; do
	if [ -r "$i" ]; then
		. $i
	fi
done
unset i
EOF

# Creating the /etc/fstab File
cat > $CONFIG_ROOTFS/etc/fstab << "EOF"
# <file system>	<mount pt>	<type>	<options>	<dump>	<pass>
/dev/root	/		ext2	rw,noauto	0	1
proc		/proc		proc	defaults	0	0
devpts		/dev/pts	devpts	defaults,gid=5,mode=620,ptmxmode=0666	0	0
tmpfs		/dev/shm	tmpfs	mode=0777	0	0
tmpfs		/tmp		tmpfs	mode=1777	0	0
tmpfs		/run		tmpfs	mode=0755,nosuid,nodev	0	0
sysfs		/sys		sysfs	defaults	0	0
EOF
