#!/bin/sh
# This script was generated using Makeself 2.1.5

CRCsum="512451893"
MD5="2f683ac16f67a1260474e4b5a27d4285"
TMPROOT=${TMPDIR:=/tmp}

label="LAMP HOME"
script="./setup.sh"
scriptargs=""
targetdir="lamp-home"
filesizes="30168"
keep=n

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_Progress()
{
    while read a; do
	MS_Printf .
    done
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{print $4}'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.1.5
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
 
 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --target NewDirectory Extract in NewDirectory
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || type digest`
    PATH="$OLD_PATH"

    MS_Printf "Verifying archive integrity..."
    offset=`head -n 401 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test `basename $MD5_PATH` = digest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test $md5 = "00000000000000000000000000000000"; then
				test x$verb = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test "$md5sum" != "$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x$verb = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test $crc = "0000000000"; then
			test x$verb = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test "$sum1" = "$crc"; then
				test x$verb = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc"
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    echo " All good."
}

UnTAR()
{
    tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
}

finish=true
xterm_loop=
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 404 KB
	echo Compression: gzip
	echo Date of packaging: Sat Feb 28 00:35:20 IST 2015
	echo Built with Makeself version 2.1.5 on 
	echo Build command was: "./makeself.sh \\
    \"lamp-home/\" \\
    \"lamp-home.sh\" \\
    \"LAMP HOME\" \\
    \"./setup.sh\""
	if test x$script != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"lamp-home\"
	echo KEEP=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=404
	echo OLDSKIP=402
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 401 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 401 "$0" | wc -c | tr -d " "`
	arg1="$2"
	shift 2
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - $*
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
	shift 2
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --xwin)
	finish="echo Press Return to close this window...; read junk"
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test "$nox11" = "n"; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm rxvt dtterm eterm Eterm kvt konsole aterm"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test "$targetdir" = "."; then
    tmpdir="."
else
    if test "$keep" = y; then
	echo "Creating directory $targetdir" >&2
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target OtherDirectory' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x$SETUP_NOCHECK != x1; then
    MS_Check "$0"
fi
offset=`head -n 401 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 404 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

MS_Printf "Uncompressing $label"
res=3
if test "$keep" = n; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

leftspace=`MS_diskspace $tmpdir`
if test $leftspace -lt 404; then
    echo
    echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (404 KB)" >&2
    if test "$keep" = n; then
        echo "Consider setting TMPDIR to a directory with more free space."
   fi
    eval $finish; exit 1
fi

for s in $filesizes
do
    if MS_dd "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; UnTAR x ) | MS_Progress; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
echo

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = xy; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval $script $scriptargs $*; res=$?;
		fi
    else
		eval $script $scriptargs $*; res=$?
    fi
    if test $res -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test "$keep" = n; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
� ��T�[[s�ȱ����)��Tť-_��TR�DY<�H-I٫G��X� �$�ߟ��g�/�$U��SgU��"3}�{�ݗ/��W�����>���U����8�����7�~�����޼�߽�/�T��
�_�U������������?ݗ��&�y��@������_�e��y����[�	��ջ�՟�����w�]98=����7��ϟ�7?ݗ����p�����q���^������o�����w������A���ޭ���1hgJ��l
��~���SeF���ӹR�2�l�d�*���>��O~��c�$_��Qa�u^eqTb��d�nG�uU���_�\�E7/�/���;z+ʾ�I�'%�/;�:Y�+}��y���-i���~����Տ�o^��IO���)�9�J�ޘb����u��9�Q�8�e�̪�h����5=L�U:_�r�7�dn2kt�ϫ��p>���*ʖI��II�gy��4͟M�U���?���ֳ�Ъ����^�^�m�������2���+>|��z�W�Z@q��'v�����ˮ�[0��EdAt��X�&3E���j��խ�<$Yi�X�ZV�^B]t���Q�Ly��K�D�����������@�Օ�	uI�UmҴ'-�lRh�g��bLۘTcL?�@�se[��Bo�|YDk���i�\充��0�T�����I�6�c��bn�Æ ��Vya��ƒ̖&��gZ?敞G��BK�l��<g���2�~�\7&�J�`�zB:�*��q8�u�Nզ��`pT���^�Ҩ$�P��IG�O�F{��Sg:Œ-A��AHO8Z'�Z?'vu֩�/s�<�&U1��c(�`�-��T�E�,�^�5�P[ƈ�a{4΅J�$әyz��?���f�s�o�Ӟ�v��-kg�ӫ����9-k%3�,C���Y�%���R�"a��=�";�d���<�I+�m�ʪ���;�S��6�J�|n�2�X���d��I��0D;�D�A����EN��<Nd�,�k<0ߢ�&�"���v���t�EY�y��_e�s�����dj�L���:l�A8V)�\ɍ4�jW����1g��e�Ԧ�����O&Q�aW0	�Y{c@��Ļ���_I��jȇ�!+��#����ii6�g}z~ƹJ�i[�0Ku���;3	���*�PIF��f	7�,h9g�4�	5�=_rb5��1ս�BB���8z"�:VhWr0$�����b���+2\��,��*$�f9�/(	m�H殕k���b/�0�	�a|�6t�I��M�x
3�O�haC�Ne �����tb�$Y�vp��D9�@f_s*-��CH��N� �9%Փ���KG?`��*9���\��t��C��D$�+ 
dn��lO�,�B�{�7���4�����)Ob>?��X��_�(1�9#z�8��$���$��(��8��!5���g��6��m��V�6��4d���]4ad.P3K|ńe�<5��"p���j�i:���������^���u=ې�k�����C���'9
8�4��ٺk�X� ����i|7ѽᕾ���h8�ף1��?u��`2.�/�]��=���|�eu69�dɃ�4�y�Յ	B�СUɉ�&���41h���il�u�w4
4A$VU��D�H�]��ɽ�wxm Ŏb S��9"���� =aVf��6��wSk���M�,Oh��&OP��w�����gq��i�8V�:�9�n�7y�6�Ȣ�u�AP�����['�	��S)���$���ID�Dܩ_���ӊ�<�Wd����q��f�Ix�	��>�u�&�8.����$��w��I�B��J(똓��ddI(�A�b�>J�e�V�6a�G:���T"
�UTٞ�]������x7UĄ|����g��| ��Ԥ����M��O͆pX�
�73 �����Ϻꋠ]YQ���,��P�d�I�]A4��_�h=ps��`CPC��6a�$cY#%T@ep>�|ӀaE��$�*�l*�#�p`���9:��`���W���\�qL��(YC* �À���1r	� ���f}�"0D�r+JH�G3k2�B���[+ZÈ��T��Y�͝��4�v�5���ZKR�0�u��v��p��ٵ8����$A{[�K�@c�q�x��R �(�U�G�l9��q`�w����#��lJ"VT�$�B��P�q�U�4D��ہ�x} �Ls�*��o�%L�{m��paM����5�<���5�\$���9d˂�����xKq�}��,o�9���@1�^��d��
�=:�6I ���� �Y��EL�m����)�����:f%�_;!�)��������Z�
1"r�D$oϔ���"�w!:�|���g�ע��>�]1�č�Oå������c�6(E�d������R}&� ��׃1&�#��ME�L[P��*�%�R
���S���u	]f�hE<}0�E����x!tJ �L�#��>��gM��;m������fu���ҨIS��h;͕o���y��������)��RviM���G���[P��^[�_ZYK�	b���G���B�1���f�3U�Px�Zܟsɤ6W>��.LUBP �#���ׄa�Piɯ:�NKԇ���3��]]BF�v�bk�|dft�upo?QMV�#�.(�%��ڡ���>sd��|���xĽ���M�窬_P;6g�u �͑��M�0R�$��S�nN��M��d_ ��|Rm	H/�i�H�'�ca�ߨ;�T�H��;�c̊���F���Va�Q#���~�,-��)^��D)���:^:9q."\���R�m$,�⮠� &V�X�QCK+�����Q�)��M4�Q;#=(�~����:���� xdTY$r���@-�$%��+y��ʡ��.����~���ߑ~�ӊ������U.�7�	�m�Ь��/�N�&�4)�ܛ�#�]v��
Rr�G?��(E�ߨ�����޼*9� ;�~��{�9��Z3�:���}�|J��@�zs����o��,5��
�/s\�3 �~�\ND
~jj���y�AO�;@PRM�V�S����H`��o5C�9�>B����s��Ĉ����4�� �ѹ�^��5Q��6MU���¶��P�lI3:��=�E����Lᡶ\h�N�"{�aW�A��UNK��$��k:8.��?����u�t
� �AP�2<u��$��N��Q�y��%�x�P��֕���[�Q��������@I�ޯ����;/�[�Ө�:��!�B�;zR�|v���ri]�-��"1���E�:s�"��s]�vay���5�!�Ґ�]_NW|���f����8��R)i�vie�0������"2|�H�D��Tf����d#�˔���_D\��d{�[��Q����DB'l��ưƍǲ�=~Bw��>��G7{|QXwzjL�vJU�t�ΐьEz:k<a��`�ftz*�_a�&hb)��9rT!5���Ѝ{Lx��S��V���>J9�9�>s[zH�=��N+� ��qm26tЧ�;�6G�Z��������4�u�f�rg�=��p��(o��|���V�����r���ݞK�s�A����t�a0dx�@2"iI��������%�*����6.�O.��h �ؤ��bS*�8���?��']1�	�QTQ(].�$��[W��R�z�����:�JǊ��o�Y�� <@:��U�bH�f�&�=��D��bO �A����U*�%M"����w�:_݅�&Y��)�lB-IO͖�&/8���&f���%�Ҵm�꺆"��P7���72�Co䋲���V�,)�Q�F��E�����}�[r���m厌�-|�Ӻ?u�ţ-�3i���㼶9?r-ݖ�KƯtcM�F?p����	�5�jG�;��zxߕ[�2Y�O������|Î9�
�{��h��)�'24"N��$w��.x7���n�͑{Q?M��S��������۪��+������5]lu���X�WW�=��HBa���IO��� 3;ه�,$�s7.Z�P@��[/��'%(N��Y�R�1~�����P�F����:q�����Z{�Q�2f9�!�휺QbJ��c@�j��D�3��i�nR:�_��#�l_�tA�O:�Ό�ߕ�7
E���܁qK<0/���nj�H�/�C�V6Q_��6�ܞ�.����2��	y{�<�{n`H)�ڭi�*'#��ȷ��?�tA��L� �	��y"'����K��0�in����dP>�E�<\W��O2P��;��;K*�s�lF����JZu7�����W>{�(�seR�R�P]&Ni�I��-��U!�&żZ[���fQڄpn̤*�I���(��ؙau�����
����A�㶩
�`Zn�L��3�%^��f����0խk�q����V���r����e�����4�]@���sC5���p;��̦�n�X0�n���L�"����gx��pC������X�L�%Mu��%�c�J��.����A�=�L���s�r%	&�x�g��8y�e�l�����P�M}���T/�<��>1��ԕ�+����[���VO_��2|ROK�0�2��U�0&��xMh�<G��)���Y�gW#� �$03��J��-����7k�]��n�u'`%6����?&�eQA1�զd*��϶͵VX�K�n��� E.�l���*�z��u �����oV|}�b1�xAZ��8%q�f�#C�Q�~��ei�d�֨T#��u��2b&7S�H�k���s80]�X���ps�o/���Yoj��.���I'I�ы�<%|u+*���'�҆UN�G���%o�o�7!��=�w�.�����n���}�ɒߺ7��D!`'�-�����R��2m�GԳ�r�C�aH��n3RuW��H*��+0MaѯȪ��ͤ�/�����Z}g�^!�2��s���b7Mi~��NS�q��M�<h����������#�����=2u��xo�3D�C"ع"��,����*MSs��2���뱣�F������	�I��Q���ky��K�br1�N�M�zo
i��$P�F�a�w$�s�1��_��׆��*Nu��ֳ����X������_�Q��;W<y�T��S�`/�oz ����O�4�S��뒝�$�1�K#�+K�'��w�5�/��7�>�Q�w�E���0���M_ߏG�ƽ;=��9�+}=����Z_��Ɵ�Z7�ӊp/��6�����u�N�}|7�N��ţ���c���m_���@��_/��S��?T#��� �L�=za0�_ƃ�`��7�������Tߌn��c��}���E}�O���Wm�Nz�}���7��iM<1�>��W��F�_���	�W�{p��x8^�>\�h�v���8���Ư������c�o8�]n8�f���!����P~�p���ѤO=!6��ǃ�?to��`y��A���7�dE�(��Տ�J%����(����W����t���J3y��;yO�,��[=�_����QO��σK����{�����c�e4���Kʃ��?�<o��q���s�h��'X	3л�2�ᤡ]�w�<h��3�ޣ�j?:� ��,w�*`�u�.F$��3`�@	�Ttջ�}�O:�6>ڍ�w��9��9L�����~y -����A��١S� ������������#��M��pȴ��b�����qy�;�./�p-ZAo����m0d�(◽y0����r�׽���x��p�"�-��j�x#��u���G]�8���>��⢏e����<r��/LN&#����hn����7nd���U�tb���#E�!P�K��^u)4FN����Mʹe�87��꒿2bK�ZE�i������2�҂�ܻ^Q)"�H��9Y%�j'I��w|h~���<Z�)�6������,PnT��.�x6�4�Ҍ�v�kV��$����zmo����؎=#��T�4bf��,�@K8@�����4��K�I	�S�IC�� �IC�ch�/��������f��V�����~��Z+ͼ�}����>Ou�8�{2U���&���L:d�d�:n�q9u�{�X��(��=���e�R�B-A�؅J��H��+�UL���Ί�ag�H��Q ��e�!��Uo��l�����#-��	�� �$wt��=܄z��_�}�ǰ��8���ȫ94Nӑ���g��^}e��**Q1��F�$��F��|�+��v��X�ɛ\"��KP�r����C/�KG�-t�DA9R��'��~+��w�ѬS��`Z@WvQ�عx6f,ޢ�W��pO�� ����&H�8�ڵ:wK�&DF��F4Ɏ���8����6+���b/Qe2�����������W�Ӕu]G���{�cl���~k�1�L�P�J,#l�f�yh�AxW֠*�*Ì*;�.��y�#*�J�l�kdwR~ v���/6����h�I�\é�y��wQ1��񞮚���2��0��^�6u������6��b�f�4�GF�; x�C|qXE*��#TV�Α����Z� H��TYQ�����%C��D��J�T�;:r�U����G�PN�`�ٶʇ�j�8��������������%���gk��6dD��sq�[5�c�j�	�P gB��$�`'�`�P��rv8�U{d�l����������%6x�������%H��9������9du��}�
�x�n�3�<�[Ǉ��]����8�+�(���y�oS'�5�=���%
,�X���ÔzUl6Kf��G^H��i�rA��R2C���2a�p�h�o���A1��hS/^�wR����Y֞Aa_���רɝ�"Lp�Z�`o%#%�i�~v�"H[V� !J��At�v���F�����?�*�	QE��Ǐ��D��9������,?+R�a�e�h�l4���1���ab�OW+r�Hk��q�K�i���I����Q�0�Y�z��)�<?���-��[�Qb�`KGe�'UUp���p��x\�񟤸���5��9�B��D��B��O�zե�\���RDQf��p��:>Q�S8�����xѹ�e��7�{/՝�9� ��R����h4�䌨E8W���3`�(>����y�,�B{p�i�>a��0`������>[Olq�0`��0`��5�qߟ�q ���x�d�{�v�� ��� �#����a��0`���R�r|�):�Ocw���v�L;�F��=�4�4�B>]��I�v�d��:Yr\{{��n��nr��v$�]?n�� ?�ˊCɌ����/[��Y��[�/�4�qk�o� dN<f�#�Vjg|a�2.�8�|�F^�~���}�?	Q��	���	����D��i��/�	���/�e9������cA���w�|��� ��� 55Pk��d�Us~���s����N~��F�Q�F%�Xű�	�39A>c!��3�`�-.J�#���<�H.tZE��c�Յ�J�,�{(�G��q|j5��H��AGB�C]��Vl߰~���;���Bx�ɏ�+���d;�v��n�.Ƚ���W~;�w���SvV�}!�;�W݆�"Im��_���:��w�������R�7p�@_W���pXQ�^L���V~	T�_�KՒ�n杰����J���/8���Sړj� 4_�-L��-+�|�;<�k߻�_���vA�O,O��m���i�+��w��*w1G��8��Ă}��	���X���Z�E�������]�2&��꼡Y�����C��z0�-�SH�hԴ)
����$�[ͬ��h�C���ܮ��;A+�ڗ+��\6��u�Ky�N+O�"9�/�'���꒢��uӄ9P;jI($@�\���z�Xꊤ�N��E`"Dm�کZe��;��gIp�f�����e�/�f�:�?�B�N�@��ϣ`���_$��5�O�5ߕ���� ����h��~�n�bj�w�8�7�t�h8|A�!����H� k<�_rg�w]�˞�X�$�VQs�(������,'n�^~K�4��ᛍz�����I���x��C�PD���/��/�
��M��S���0�VQ��n�)4#�)4*��1�)58�)t?�cs�{�8{���$y�_D�1���M�k/X�z^�l<���Y�>��8w����9����Gv����9�K�=����������D��_���?��g��4x�iV�]�Jǒ�|���K#���u��Fk�g����<�����0>����������}W^1іe'>�8��#[��֑�G^���m���D��n���w�Z��k}wч���^�N��C��v�I�g^������r���Ϗ(;
?;����x(���B���������������1�w������S�߾��[��4�>�����~���\�{����ƃ[6�o�ZZ|1��3�|no�s�������v\��-�[_���羴H�pK[�K�ط�|�K��|c�x��/|��g}唛�x��E�=Ҳ7��䩙�N:���O}䤽��S�nn�ߦ���ն��C���TX�c�	+"�Z{_�|/�˓��k~�[�O����O������_2���-g����^���_}�N�z�Oer+�������-���y��]�)9<�~��+v\9���㱳���9��b�e���i,s�by'����Q��/Ԋy����*}A!?mᘞ�i�<�TLc�ͳV:�� ��޲>����?�2"M��NX5��|/O3�OI�]<^���@��O��ra��ཚz���+�W���YU�.BVJͫ]����0�1Y�/���b��LR_SquL;K����A��ደ`�吋.���l����݂@����f:��륕��/����z�ɏ���f��[��s�:C���]��L�^|�P6U��V�g�uE��ml"��f�K�%��/�QK�0p^�W�0U��CM_J�@�5*�z��Au#�OY9�r���\o@��):�4�թ��I-��W�Jkj��u�b��_$��W��D���i7I���b����T�Xgl�S�S}MM�$���gY�̣J���}�m�f�/�QDkm�+;Ȱ-4t��95�-�#����N�2la��Xm=%��w������������F �I�?I�����́��W<����f��k�ʀ�1,�0`���<���m�X�?0`��0`���8�_���~�XN�:��O�7 _�9�>
��ۀ�^���	�� n\�p�B�V�_��_ ��2�����������p� �
�(������9�� �ೀ� >x7�M���*��	�`;�I��u |��o��5�+ 3�:�V�A�3 [�>��^ �g������ w:��^8�
0x�Y��|��m����a��s0`��S �}B��g���3��<sn�&:�	8��^�kO�՚�sU��n��f�Z��� ��o,ϕ��JWe���7���Z�s����p��'pe����Zw�'���)�	~\]�nj�n��d�6��d��������G�Zg�V�o��&w�gu\���nD�D�#���?�����Mtz���F�F��?�q5�U\,��Kk���u���%V��\'3_�k}�8��g
55ʈ5#��7�����ꥮ�%�@רq���q����e��r�C�(����a�)8����f,)�|�?�(zT�_Ÿ"���"��?�aݺ��C+�G�mZ� �O�S�k�(���j$3j>�l>��bQ�J����$�;�q���-�^�q�_���e���f��N�j����r���JB`��)���y���\��d���pGCX��ܒ	�$�ί��I|@��1 -�� ��x�B|���`�bG��U�ū^�?>gڎQ�+�`�f�9����E#�k�N�&,B��MrpK������w�n	8�����Y�G�<	_V�Iȱ\g/$^�b�����Ŭ��߰qx��5C�W6��O)��Do��H� Q9���f $=%j=� ����� �I]�VZw������H%Sl�|�翅t�h����/+L�k:�-�3t�����$����oZ�t6m:���'��������6�s��v�
�1��9 *)�l'�T<SDD����#���ӓJJ��J$���ɗ���A#�����(8$<���B�#�����������M����n�`��?��`����7̴}t����_d���4���R�\���B��V�� %�a��q��g��GP	8s�'����4��H���i�F�+	 ��_3@�&���#Y%YR���S��h)A�)�.j=IA�U=���&���~�˖���t`_��H��t�=����B�0x:�x:�zyہ�i�'Ӯ��D�[�׺5INv+��B��J)]U�ٕ��t�B�����Pm1F�\VR3��/�,�
vkZ,�T�dE;�vq1	����V��8�v"�b��r<�#�c1IdU�S3��"'��k��		x��IISU�-u1�TI��0Yu]�դ
�h3�WL����vq�UPL�^1!�x�z���
�o�x�����`翳I�#�>���5��x\`��]��t�f�nu�!gʇ�5'$���NV5:{y=k�OL��Ƭ�SK(됕F�-E�l��P�h��](�+L��m!A�Wuv/����G!��T�~��%VS�b�0U\[M��IܩŤS��}��s�x���M�.&�+v!g�EA�i���s����d�[��ˉ8�������g����ԣ�<f*�l�Q����GYa�́��9z�çF޻���'� �}r����E�p��;8(����=���5/��������v���;a�����MC���{��3���>�|�S�����n���^<����G/y��o\����ʃ8�ϟ�s�`7��u|����|��{�����57\��?ٻ�0���UC�qme^ƍ�����)�����?�w7����9���.�¶{�Ȇ�|�����.��}�k+OQ��u�>k�<uA�*7�wk�y�W~|����ߚ�曟��[v�;\[�ˑ�C�}s��������}�������{��O<��=�5K�'3�16 �a�!��������F9 �����2��m��?��6�"�zCX��8N��Fae��z�T�:�r�/�<��
�I+[��fa��b-���L�k
\�ϫ9�UY�DT3�R�RY�U��y��G;��d�UIa���z�'ͼ�M���O����O$x��%��o
lI��h�Leݴr��Y6չv(m����o�UD�6G�X��a�7�L��a!�����k[�-�� S�x:��N� r@�X�;�\�[�^i1cD�3�3���a���)&1���ӿ`�0����0��$�K1���q�d���о �۴3�@;�<ϣ݄�<<��ȷG�-�8�ȅ�f��"fS(��AX�~��1�n'O������ QfT�OfPr'�D�G�:@�;E��� G��x5_���A���)fX���[9�;��4���Cl�/C��f
�i>�Y���5���LH3�3I�N��IUP-w�	v/I�P��a~=�M����L6I��p����F��<(��NqH	i����{{��ۻ��}���`l�V�;�����M�;����q�NZ�-�
I)�q�&��j�AD�TɠBQ�(��m�UQ)*E���罙�������,�ξ��}������(;6^��a�}�w,�Z�:��1�oz���d�ygP��4�-���Q奎۬���mںYSf�<		jt����y�z�ja��U��ˁ�8�b�eÅfvƳl�6��hbs����a�ٛ5��Eο(*���}aO�9ܤ9�H�#x��p�o�쏀!"j��3&_I��x�����u�=縇ֺ�̸�0��4`H�fu����5��|f�\s��6~�����i��*.�(Z��Q~�����#<�ʎ�*�У~S��(� �f���Z$�%��a��Yz�'��I����v�s��8	�t�S��P��\�M�A��ra�K�v �ѥ��0���R��W,��7��iH�n��oD�͆��: ��\$m���X���>��ǩ�i�h�G��ނ�4��z�*;4F�߶
Ł:�I#�/��j�4�����l����_V�2����?�]��^`�ߵ�P�8䉦m��@%�ÍO�퐂��6��[� `ؒi��(ҥ�V�
��P0	�ҩ��� dl��>B��.2���S �΄����X|H�?�@ԝ2P��@Z��M�q��a�u��N�
�Υ*�J㠂�Tk@�BaBl�!]1�UR�`69v��T+,,�a�e �v(i�=~=Xv�a��f���ԉ2�J��иH�&�� �\;��s]�JR� 
ʦ=OП(�ê�r��#Z���Q�8H0Ӽ
$^&Z��Z�A���$���<*�m`�ܫ��{��٘g+[cx;����N���%�I�d8F�p�v�EM,�DFJ��s���ݷ��O%���,�y!'��p���"�A��?^|���UKֵhː��E���;�΃t,���k~��sR�$I��P�E�L�!��"2&�uP�r��m�Z;�.ѻ�i�����614�}ɰ\G�aW�8��ԁ&���G0�|�4E,{8Ph8�ǵ���uԁ�4�3i���cB�.r�{zz����И�1��d9`{��~d�&��O���|�Dg�QRr.Z/�T
�� Y^V�dÑv�@�����-��ե�5i�+���8D����)mH�l���[g4�g�l(��D�Ê�jB�LȎW��$xqq�֛v�EA�Cp��ƔXѣ�SWW0���[i�]\���qh��І���>kBD[fMྠ�ޢ�Y�Vx��#�,�Q��@�@MIOLƈ�I�o���3h*c�������0�$Y0�¨��oYD�)��J�<V�$���b�������J�~�P�Y�p���İ �>���n67�>�����2b�K��>�<��^j����8,�U2��B��(�1�N��@*z�]�R�%�oTY���o��~Jk_D��9z[)xUڦ�܄��Z��B���o%��6�{Zt�;�"�(�������p��o��!��!T�A���9���~<�J>�ah[��s���M�]o�F�>�!���%�c�_7���-�������
X.�����?K$�X�s@�8/bO|h3Y3��
ͫ�c�<G:jO����5I,c2� ̵P���?H|��H;;�P�#u��VV�S��B'��&�eh�5�E��-�<�b��ף[a��l=�ݠG]?�m�V����\� �r������?�Y��^T�[��!0���{���/�q@H� �f�������1�Λ�"D�#�Aׂ�;Ya�$��h�By��koes@K�6�����?�������N}�^3,�Kq��,���jږ#F�v�f؎����bt���ɟ��j��F��et9����g�b��?��O���dF��6�bh����^h3/�Eq�iֽx���@c���P֡�C�R~I��>"�P�jˢ$�Y�7�p�H8>�D��麸R�M�[�X5V)�:���H.s����a�2����m�����8c6!  o�@�m(�P����5=�SX!�U`��,V�Y 0�k��Ϊ��2bM����bң]�i�y�r��P3���(���׊N�*%���SJ���1�͈M �	$E޹��H�Yo@�͆QBX�g8�I3P�3��-it��9��-=�,/�4�	6gҦ�M���	��k%����;:�|�+�<�hw���=6��[p�1��ޔCT�2Z�E#������u;&�� �����w�4�H6�#��q�qO�Qi�q1�[4@ȔeO���"�$�m�1?��&&��An�4���o�c�Z(�C�r'�腁�H��R��"+�F� g����g.:�wD��
�����fC�B�h�Cqa�� m̀���p���v�ʶ!���A�?ѣ����c0�ۘu�-�=��@���Bpp�24�´D���� y�i*Y��9EA2����)	Ҭ'N��W�j�#�j�T��]a�M�B0\��B`@��t�sIG�M�J)+��6/��Fv�p���&���� �{T�{��jj�1єJ*l��u9L�'C��a��QG��D��d��F�2�!.��>��khXd�����U�ѝ���		^v�~BSa4�fMt�C��ٝ�Gy��9���-8vn2�q�&��㠽���?J&�K�eSj��R�#�σ�۳wl��݄E Ҵ����:Z�BM���(�f��I�7����c�F���Ӵ�Rf�Ȩ�3M�-{��Y��e���$�d�V��p` ~0(*H݆�51�)�{�����.��MYx�K��'b�WHIeT�+3f��ݦ�e�k��E�t����������� k?�4���q���Ȼ��EIi�L�Ŧl�<Θ������V-��@K�!�K`٫9��]���B6
@�Ѫ�"]\J�w�X>y!�6KGr�I���pf�`�@` �C�YǕ�������h�r��Ex�$%ɒ����%ጊ��V�b[B-S,7��þyB��{�	�?�\r��DP�J��ǭq��Ge����8bUV��P�ʬ�%�~��P������{X��&6��Ț�C؞T�S�` ywg�"�Ja஍�Pb)E�J����@3��v�C���k4�V�'����O�KT�Ӭ+OE�
��	�d�L�[�q��``	6�Ж�d7u6*�t�9�Z7�"!��f8�}�#�	!�@PBA� ���u��*!��z�y�ދ�
U��"d~F�&D;X0ou>�f�P�����L�A��b	�t׬r�	�����I�c!7Q�@�Uf��M��������V����M��~֨{���a�
�'{�Ѭ_'�tȢ&@���Ă�*�C{I݈����I&���I��ii�CV_�gl��E1�`�t۳ڄ��_	F����Ζ��_�o��a�]�@mi)ۥ�2MX?�Tz^�F���Q��Z�����Eź��dI�H���$곕�Td�^c��}��FP�4�u�WJ,#���V����QQ��F$50�Q�mR�m�Q9� �c��X���3m0�]c�ԶvL�t��y ��xA�� c�� ��\j�~`�B�Fsh�`�`�`ya`r��H:źUN�j��1J,.
5e����KI��}㿙l���Bf-�sq���3ȧ��Z-P�����>Q�����a���a��,,Cs���9d�a�E���-��U�������sO|;F;�����u��K���*�2x[b�5c��S�$����Qh��/[t��,@�e���3সF����^2 H��c�~�Mi��d��][ey�� �
F��ݾk���ض�{1�%���y�ݩ��x�'�nY�F1�M�cq��r%{k���?�R̒+����0=�T�\QkIZ��f�j�p�;�����a떇�� �ɉ�� ��i[�X=rE����ɞ,�7]��;b�cK��X/*�<��X.�_��;�rk���"������se��X��"�q��G��2�yT���UC�F+U5ԑ�����_o�/�i��������-g�Np��Ӧ���.�TQ��5�r):��z�!��H���n;��)0���3g��:��\����V��ǳP`R�@�5�F.��`�|q �W.��s�b�Y42��/_���s��i�3y�����[� �vd���8����1(^<�r#ǡK�R|�^ɲ�;
���I��&g�J���k�M�MqUW�ёf\��D�j4��!�{��6Ih�c�{�*��K)j�,_m.����&�Y��H�_1Jv>����a�nP+����F��H���T,�L�*NhUˀ�������2H;��94U�U0
U:�gN��'�c���%D77�Ap����M@u9A�x�-ZU�Aѣ=N6��L�~6�����Qhm��t	 ,�Wy�����˾��Hk������,�-i6���d��E�$�U���ãhX,0���"|4�Ŏѩ�;�Fq�ɲ���NNdb`{ϕ��#3�����7Ol�u���uw�1Tc��>S+ѐߙ�	=os��w�V+��m!��2r��*�-i��H�,C8����Q>by��|ᢌ
M�%&BX��7�!�͏��1^���
��.��|���X+ݞC'N�on|:&i�%��	T�X��u�{��TP�I;�7�Þ������L�k~ �?ۢ +b.w�W�|��o��2����������E ���D����1!�4yD�s�c�ryEP����s�n)1�aխ�Y�����f�,/�@Y���b	y��=��b���/v>vf�q40tC�]�69��V��#eD/ʡ���^0��T-��6�X��@�����&�"W�&��T�2�0�R�ϥa�tu4���Hd�� ��/�*���rXΏ�;.a�͖��8�c�9��S�5b�$�0��C��b���zBſ�b��S3X޹�PL�%�3xu�Z��*U:��v�9c���j�/*�%��TS*+qJU���Y��� ��h�K��K�]�4"���E*%��&��2@�i�H�Z<�*O��ґ��c�Z��X���.RbzQ����i�+�d�׋(�ۆbL�0B��E�v5��k����?������z�k���|f���U��A3�z��_o�����g��u��4��\�Q2
����@�@v�R�d���������h�/z����u�sY�c����n�t��^yF�;a̜��U�9uו����W^>�%�>s�?�u��N_y˳�}d�����L=�/��:;)��+��������Eb������|ý?|��g>_�����'�m�ݟ�xJ3N?9�+�n���?�{>bo��G���N\S:����8:_����ԡ�������_��K'�]S�����VW���?�s��k�u�?3ؗ��|o��Л/�%�P(��S(�fƨ������������e�k���P����W���n����ߘx������u]S��g�o~�����o~��g�Ԟ�ʋ�^����|���?�9��������~��W>9�x����6�6l�>;v`ﺯ�?���ݿ_z��ϟy���O=�~�{���h,u˚ؽX���_]����˲�߻&�Wg��fn�X̕�e���Łbn� �g�3�3��������[���P���#�o|��ݙ�K.�����k�g[�W�U�������LaM��������@���+<������>P�F_���E����?۱��l/�oM�_���ޛ�pf���MV�v���~�����~�/����?��F�qv�]�uz�:���qgۉ�n��o.����?��[����^��������n"}vW�la�٣gN���˾�֡C�����������ll���������λ���_�q���o��Ș�?���o��w��b�wt�s��t��o�/�c�����������-���O=����}녿zc���޺��;�&����Mg��?��/�16��Cs������}����U�N}�΍O^����_���O���{
g'������7~����y�"w���}�^-��=���@O�����_ۚ{3qG��7|���;�h����'	�$B]c�J{ﳇs��2�2k�s�N�1$�H���-$���rQ�1�(B�B*s	]ӣ{�Z�����z�z\�u������{}^���3|����5VFa�}S|��Z���H:����ct�����+O-t��gK�Y�I�k?Z����0r;�e<n댟����9tMo8(�ۗۆ�d�;��]��(B��#�$�,�'��d�e��7��8Zi�v:o�=�!�6��>���y���
�q��O;��b�a~�U{����J-n௔���dS��w�fJ�@���*�]�V�E�Z�aI~�qo�ƎO�o��P��� D�j��4���z�W��p��l���-0R�*D�͊���Ja  Sq&I 0�FEP*m.�?����M���y����t�̀��> �:�o<4|�변3�^���|rOr�j�T�ܔ�K��)��/��6F�nz��+f��m_k��t�e�7��06}�}����P�����PӉ~����O6���)y�Q1����5����Vu�<�%P0�����\��BWI�����>Zqﮭ�����@���H��Q�*�e�;��뵚s�����0�r�?���������6�O���C�3g] �0�8A�f$��8�)1����a����oN������X���a�QU��Qrk���*/��M��V_����v�Y�N��#��?,�8}1@���+b�]8ս�)bM�٤u6��v�'h��E�3�4)��w�y������:�-P\w/ܖ{�#Љ�|�MOP��6�&����5������?��j;�_F�1F�q�!��G%�C�~Ygy�d�����.������~��-�|s�8���?���������� A*���(t*L!L��!�Ϻ2����Q����G��؟��@���;o��5(�X��6�,��yu�T	�E�l\�y�+�n�Ž�{gTO���x��ʿjN�s��Oq�Ea9�j�J��e�Xq���j�Eg�9���,��Fu*�kt���'J���ƫ�ݞ�F�; _��wq��o+�v�s+|�����
���<��7h�<��k�1���X�U�U�M�]˴y��b�-�q	���^+��l�y�-n64���=Q^��N�*H��Y)R⬡�s ����?����9�l��!��Ϟ�i�~���LE)$N��
fR����`؟��@����ijk���z/-U�ٖ�}�#����뇴���\æ�s����. ��=T���t+��K�!Ǟ<lL6��G�vLS'_D{р���nUھ��
�#���iky(�pݵ�B�Rq�����E5%�b-|�N����_��.@tᥬ���v�f�ϡ_m����� Z��ƙ��Ќ+1N��$�L6�8���2�ʘP9���ߚ?Lo��ϝ|����Rj����胍!*��"0�Kյ/@�/�RI֞�z��C��7jh_����R����MK�h��tL�HV5Ũ�OM"�?�˓�I}%{��tびgT3��8��ϻ��V=^^�K��3R�U�M�h��=����]��!�/���N.��h+ܓb�O�QsQλ����Ɓ��F���6}�o�7���c�O�$k�2C3J�	i�h�J�8�{�+����-�Q�ٝ��w�A(��M�ާb�����VYr-�J��&T[9ў�z�~�9��+T���T��7or���<a�p4^+S[�h��L��.����\x+R��X���}��tK2ʜ���KQ|!@�v�[���K�x�U�����W:�_K����/;d���@�Y�Gv�� ������.�q&��ab6�8��!$4��� �DH�B���ƾ�)�����������Q/�!ɋ"�
/lK�e��k�޼k�p[��n.�-ʪ.���)9L����/{QD7OY�J{ho�O�l> Y}`�S��ҧ>�����|{��U�ILS�/OY˳Wr�����O�LƋ?�9����ђt�S��6���1����I�z�^�}3~,���z��u�m�=$�����	TN�7��Z�o�U�U^�.��R��:�o�z�֔����;�ox.y�O�r��6�6��w5��m����VW��	�T�#Awh��	>�D��ԄՒ�?�\�޲k�3�U~p��j�at��W"K4t��YVa���)����c��  ` ̞	�p��(�at`�$�����������  ���y���0@������7m��n�g{,�o��� o���J�8~�;�����?����M:�� Ʃ�?H0��Si�CL���6+�\�� �F���?������y���7O>R�.Raj�I��[�p$+�H�T.��|���T��y��,b|��-�X���:ǳ/\��R��,�|g�����)N��M��L
B�(�d�8L0 �!$ht���$��s����C g�s����Dwi���8+��}�-��ʨ��V�j�W���;�}��`��{id�	����[�)V�v?���;���L�=���H��I4]=e��vM����_��9>Z{��@�~�Z�p5k���U����U��Fu���-5�����������"��_6�c4�Ɯ=�8	L	:3

�&�(@'�U����F������῭IKH= �M���"Vegz�)5S���L,�>b1lJ��9Z,Ӓ��0#ٓ�vl�e<��y��\�h{pl�_��Q����n�F��J�.�L�׼�2V�e>�-tN�j.��u��$@=vy϶`���VLS۰u����{ƞK2���̂g��5l�:q�m�}���B��M�6v�+��jOBvE�o_O���}�Ú�^����O�v�|��ؘ렴U<�f�����U�y��9��1#C��~y�+�:s"�)�'U5k�m�p�t�c�"#jE���P<�Kb�s�A&<^�ܐRև\cd|jU��Z���z�H�K��l4�*�zgoF�Pi}����!�m�	܂�^v<2�r�b��C��*�W����R����/��g,�?�J�x��������H:���[,��K�D��`�>"�$<����P�lX�����v���[�<� �ގ^	n]+�ԙ1�zƴ���3����?���Ϲ����՟I`�
�(��i4��D&RP:@�
�u����B���y�l�N�ǀ�z~�&Ҟ/jD.4>b�&Z�_V��v��q����
w��u'���<mkc%Ɠ1�7�]%|)V��.�q@�W9��`�E�R?�z�b�Nbq1���+Kӫ���T��29��k��5Q�a���r`�=��QV���ckwޣ��]o�Ln�H��j�ܾP&��f�5��/���=m����c�S���)0���I�Ө0�d2(�!4� Lg��A�a��)��G�����r����s���_��:��\8��������/s�?��g��,fُ� @&��0�}�ƠC ���t�B�o�����9���o�����5�F�x��$�=�����VīGI�I�v�A:I4�9�ʎ���)\�è�5��,
J_� #�.�m�2�Х���� hS�O�,�m�s��Rs��`��&�Ҝ8�@�G�U�\��.q�1�Zo�$Q/�op�b�|]s�[�wv�j�f���OÛ��Y�a��oW�k=��歗W~��d�����L����b��A��M�C$$h$ �9���B'*�T*HP�Tc��� �������������1�R���b�;8���ΰ�7#o��-0���u47��?��8�6M�J��S|pŕ��5��Â�/��X�T@,z�X�/�2��߷���tWܵ��0�A��A����+���>�tb��x�Z����G������ئ?��L�AG	B�	)(@�q�` 4G0�1��Pʿ��������*��{�dAǞ��Π�z;�����N�ph����*h�s㟁~'���إ?N�@(Jb0����Iڬ$��ɤ�����b ����fY���<��[����3ckt�����&YJgZZ�l%!��6,�F�Iٍ��\J;�n\�2��7O|�����F�{Z�Ǿ�ݿ�!O��@�������m��/�-J:��<h�qfȌP:+���t����\o���K��ןP��6w�K���{�ݯ�7�8Te�����mY71q�����ޥʭY;k����j�j��['GZ����٘/k�ry3�W�rw<�R k�:����x���ԣwSs�_�ۏ�tuM�l8��tIk��9q����"y�e9ƺ�4�:���^����4�n��%~�j?�D
��f�G�f%<y� ������ Yu�Hyo�K�1cg�<��Ц�5��O��(�6֛ݺ-_��l��ny��ݺDK��~�i�#Y9C߇�*x�e�X��}��q+55VK���W{wTg��A���Np���������C���;��^�3��L�����og�����g����M�$��8��tR�W��-����&�x.s�_����W/>_$��@ZT��У]-_�Lf��냇Vά�a�q��}��&�fg'�þ���qa|�`�f���H�j�Yr��XR �{)�k;���G�̕DU�ʴ+'����{�(c���P-BH��4��}��R#?3V���B�:�Zt�E��ϻW�tty����~�
c���sZ����HVg2�R&g�&�<���Kijl�Cb���(%)�M�.���t�\�5����͞�xm�]��w'������٨�%#�œ�VV���e��{ǘ����r1З�	}_���B�eq�%W�K{�3�\{�vG8-�R�(u�G�����"W^U�(j��y��1(a���ܷĝ��h�y���,#C;Ƙt�~�F�*�x4���Q��H�0�$=�w4�m���Р��s�=!▥S��V{蝲}�d�K��e���i������~��h8_�n=L���7E\��Zo4{g�r��Sc�ua.��"�9�S+�@o�R-��nK�� ���	b�h �o�i�{���0��� [����F��Ua��|�_ ���Ԛ�D�	/}�+Z��2�Sy���5cTE�U ��*�<�"��>�}�|~��X;l<��s��W�VUޏlf���v�DU;��z��n���f��������O֧9�g5���#߬�;�ιkD�b�7��b�Lg���{��8������H�o�O��F�qCsNenp���aIj2�Z�',�'͘�|d E���F��؅ʪ���X�mbf���|�`(ܝN%fUsâJR�_����	��p�*��3�ؙo�,	\U{�jv��<j�Cyk��X8���ĥ��ЁS���ƞԅ��.�3�����%�h���������7�Fc$��.�7�l�/�	 *���靠!I��G_�}>.�m�YB�nG¥P�['D�h�%�R2��]q��7t9���S��]�e�R|���XGS�ĵ>�'̃������X�#}u�*s~���g�A�~�Y�W,�e5߷A�'*���/�����y	��%�[*@�#�+�pu����}�TD���ݒ�j��ս��k��d���ӻ���'�A��-#2��������ْ@E	���ú�݁�mHfQ�!��4tp��h�x�d��Zќn�^26����y��t�ÙYU���O��禰ZHg�	�����r��։�<BPe�M?��N/Yo<�mի�D���_E؍EK��
�S lu��@hX�S�&�|+]-=?�;�����Y���k>#�VL�@�=�x���z�:��ӏ�|�J�o�'���:%y��Q�:���c�ߘ4�0$,b��2�u�}�@i�R�@X��������F�t����]�����'���d�+��O=��+�h�N�Bm�l�Mz6<.�B���|�QZ6�Ea,�?�,w��ҿec��i���k�4\m���d� �*�&!�^�J]%�������Q��DŇ�RV��B���
�\M��4�>�t�Q�u͊��P���4�-�v9�=Q JE�
p��+��}A�{0G�����҈��q�)O�N�P���D�ǯ��>��̭5�����	��6�l� vs�G0̔n����v���(Y1�\'��|0���+~$*uU�Y�`�iN�E����aC1�g#�� $��q��V5 އ����3}�9��NU����R�1xϸ�a.��ιM����)r��G�B���E�Z�7����&�}��$��_#��O��8�1�qY2���x���į�~���Yo�m
 1��`��q�,h~i���$gc!����Ǆ�y�J�C����>��Nl�
mr��,�?\�hȩ�b��vy'�"�\�5K�mY�y96\�.���0L����D�d/���_���x-yzn?�=��F`W5��!S	�A	�!�-����	��T��N��`)�F^i�6TE]�d�2hM�ү�hJ�1�9�*d����"i�B�S
���� �YHӺ1'�>�KeK�y;�߿�=���a�ҩbSW(�p�UV�"B*K{�� �]ra�ȣ���=��}��bS�*��q7vCQ�j�M3W�%��N{q�on��21�I�VOq����Ϭ���@�9��i�ռ�x�)��7��d{9OC���eф��A\�&ד9qC�$�Z�����%��H[e��"�op�a~m���&�ԁ�U����*�����K-3�M�em_�WF�]���d���m��'W�W��k[Pt�t;ҋ6Q��?�O~��f��a���3�IO�FjI����ʩ*ދ^@��I~P�##�e-�u��� ��.Z��1�!���;��K���"aX�H�9�^��ys���@u��Z�X�x���*,`,T
j>1q�I�eZHqClz.�\R�o5r��}��EV�� �A��<�ļ��f��L��(�����8c�<������H�]࿰:qW�FEdQ��5�1\K���#	���h�k���v9��2���׀X���������Mq�"sI�����S~�-�""����A�W����Nz���`f媖n�S���;��H8�ݼ��.�VO�.G\@�^�k�F7n8�E�k�����L�RF���~⺌
b�Sk���O�U��"���o����;��Q�!��ɂ�MY/�~Kp��Ph,JFcx�|���]��s����WjF��%ݹq���
��6r6�E��S��D�5�u���H^�=������;��T�)�8��^y
�$��`�'�v����'`&Iv�����q�<�[��w�AY�-}���Tm��6h�w[�TYݥ"�a��]�V��Ern�Z�Ş��Ԅ�������ҩ��_�!�M⥞4������D�ܬ�V]��|�6n�(���'U�j�l��W]�&�m�l;ڵ�S}
@4z�p%��p:v�T�¤����ݢ�0�P���~��I�c�TW5K�d������RJ��9��n|��w;g�P�P��儼w����SL��`��R�/�U)/s��/�:
� �'=�m�
0W����h�FO ��e��NL��E��Fţ�i4��H�)O)E3�q�2��^�2��Z��O�~�S/��|ƫb�W��&��m2�[8����{=�9���G��H�j��c�Jk���#+��B�.x�-W �LF�|��:�w����-1#j�,���θ��׼��z
^���K��[����S��F7E1Ѕ�b��2��#c��I�KL�F/�g�&��,�@L�/��*+c�^8��x.��Y�r>S�kCJ�K:,f-�]ů���Z��]�ļ_w�'�G����S�I�ѥ�����@|������I�b9�*�a�NS���;kFaؤ�Z��&\�.��Ce�d��[N���v	���'�+�!hF�T�`����ڎo�l�c���6�}�����0�R�w2�Fn�P�Ϥ��ح3�f'�_��aΦ4�%o2�x``ܞa���Z�nV��)Xr]O/�괔Q���u(�R����h���zJ�2tu����g������Z�9�v� ���S�,Y�4iPd�j��
�AJ������ձ���.�i�Ꝍ3Kc��.�S8�˖C���Z(I��@�i��� I��`�#�EG^rg��!H]��!'���	�Z�ya�����Z��:yvC��EM{  ��g�<[��i'����Y��vk���eXr�}ł�@m.���6х��gT�]��u��ƍ��i��������/�_��ɸ$���l��Y�o���g�!O���V#��6l�>l�\78)�6�F����0'��áJ��ZkM{�h�:��f�	�m3nJm5ށ�.A_X�T^��Y�+�SɨQo���;�p��߈�X��@�������L�����Hb4����7���QdJ��7�6�����m�Y��{&M��b�"�CQ�~�<Ś�pIEk�s9�^o/yTф����T� ���s�y����?�?��H����LtA��?/ڿg�z���96׷���ny�D�U���=#�?Zz��	���91�$�KΔč�g��I���X��.I�VOx�o"�����J���N2����#���=����o����l%7�w�ĿjY@:�ߒ�5�Zi#+��p�ܺ׫�F^4�*q_��X _�@*N4'��NN'�"��԰��]n��>�Z�� ��o⥗�A��r1[�#���6�d���t���U���pLϕ20�{��T�ZpU��*��a�0�6��/�Q������u픨�Ae��ٔ�{��6k�ؑ�0�h�	Lp,i;����񱾆�?��@Gy.�v��hj��#�~x����&
��&�v�<S��N�D�F@h#�b�JܗN+��6�
�<썤[�f���*�������8r���o���N�S��q���&���*-����lN�_�Px�'0��N�-N��~��{'��VfY��gj�BD�!�DF����U?���2�$��,3��3-�|B���,��M=�V��������F�d��p�3�ŕ�r
��L=KJ!�\�����/�N�?H=R�Y��z�:='RIQ�L��%¦T��v��Vch�/p��w�jp�<��ѡ%�`f�?��K6�xj�!�n�}��hY�=�L�V��?q�?ͻHyՇ�2l��v��ڞMR�"2�����ΙeJ��_�]�k�~��MZq�[�^@��O���l0=q�>gi ;�)n�bD;�F��h}\�td��?`L��e�`l���H��rr�R_У����Iu�P���T���)��эr�<��t����ʓ�7ħ۟>"�� dl&c7���7��1��a�*)��Gkrv x���\�au���P4ִ����e��b7[?=�|z��t�(-6Șdw�R�:�3�'r=dơ�lY����!b-i�sy�����ōH��+␕�q��t���Ë�l�d-׋3�Sk.l���;�	��c;��6�hMńn�(@�8O^W{�)��M���f{|�����xE���Gl �ߖ�*���n��];M�C�l;U/U���L���?N�{�Ӓwn���J?�G>~&���F�W$����`���1�Q�y��KG5Tv�fﯓ�x2��J�qJ�Z�GZ
�Pw�C�$��U����ӡ��w���}4���v�ҸY�1���Q�����T���0�R���~�]wUZ����E?��̒ye���^�r�`R�.K�e`B%�⏠'�G�l2�;��b�����1-�1��W�}�㺺[R���%�[wT��Ƽ}�6X@\o>Ȗ�ь�aO��)���Eu������c�	��.Q���5��x@��:O[.�8m�3����Rh`m߾�k"�މ,�p)���8�qB�6𐶂�z���c���I6�<
{{��[����J��ͬɫ5d�y����������E$�7W��;��XjZ�k��+�	�0ޜ�[�[�RCNv�BHŧ<g����M��=�ؕͬ�\����gc|�����"�!SqP�<+|����ƠK���"���Z�w~�r�C|yf��R��)ȫ�������)��.�2c����K�d��y��*0Pp��&�vti�+����n��3�����0�Xɼ���8D�H�_md����.:p������?���τ�Q���N|��n=#cE����&j��ܴe	��J4� 뺜�����O� �sp�
�)�Jߍ��oy��^���,2�������%�ҁ6ϟ�V��E6z��d�I_1��N�w�ۮ}�CYu�6`
���;=�+��I�ǝ/
*�����h���0��2������v��W�0?)n�M�o�O��2� MK,j2v�=�d7� �p��#Y�Ѓr�i�q����>��6[���::���.�u��0=?���%D��s��-/�!���х���\IN�4���G�>�ɹ�0����b�P�y"U���d`�Ӿ�m����*he��yD1*!.�����bP/�y~:/�� v�hm��A}x�?�lu��q	� r��������!F4�
��Ԍ���Z%��.�Q����� 	`���*�p��_���� ���a�щ�.�S�D�dd:��m�y[!��0>)�7���Q�>����!YH���C�
I�xf}E9f�7%/ЭӦ�U��͗	H�d�D�Zk��wi&�#�jP?Q�׌� �e�edl���d���cN�h�]4�����{���*�<��+�=����6���ۥ��8
c�÷�}��=Z���uu��'���/��5+���<?���w��0Da=��n�ـK�Ξ��Iȸm,����6�c	<� ?��
L���-�nHI����aw>ɑ�,��p��fUt�G}(�nD��u��6��S�$`G3���_���X�@�"�`���]MM�"O*K�ݕ�}��q�GL}|�٥��&��)uw����Aj>�R�j㟆�5��#�@)�bjXF�y5��mK����L���"�h�����Q6��+�t"��\�(en���7l?_�j�q��CVD<�t�	
ː���H=�����V�'���^ �Aw����Og0fr<��V4�6T`.|�6�X�P�gX��ĵ��>���)Iy;z�?�gom�0￨�F
t�Б�)���&�zQ%KN�V󟎀zG$|�B<qB�d���>3c�?3������ޯ�
�'�������ݦW�`�FG�^�(ޑlZ��99C����'��PD9@���礙O�q��ԒVeֈc�wB��j��#�?�=���9�ˈ��w��M��l����~����A�k�vŰycb{��1^X7�&�GL����2�Hˊl��f1C���h�V�fCc�1`O�ł���	���AG҉h�Vf��V�y�?�~c��)�\*1��[�v����!zY���PEC�A�[=3%�f����ط�x7�>����ϖ�f��͡�.ɾ�sF�=�<�-k��uΞ�5}{�l��(��rn��I���+��GCB�}�`4���}����o�1��+{���̽�;_#(^�7�2V���xq%�<���C�����oY�I}������t�Zy���1��������߀�P+z�[��98^:��
�NE��b�׌�/
0�w���-v�͹f�u`v���a�{��?�1����y��������4�� nS>663v^ ����637��A�<�|�|߁��3�@v��������?4��c�?r�W��'�"�C�J�z����e��(�GD;W �6I��q�����;�Lm��x�������e��$��}�D���;�v��j�l�?�1���������ji���jrq5sF�8?|���Ç>|���Ç>|��qɘ� 0 