if [[ -n ${FOO} ]] && [[ -n ${BAR} ]]; then
	echo "@${FOO}@" ", @${BAR}@" >&2;
fi
