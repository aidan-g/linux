#!/sbin/openrc-run

description="Runs nct6775_fancontrol"

depend()
{
	need root
	keyword -prefix -systemd-nspawn
}

start()
{
	ebegin "Running nct6775_fancontrol"

	local PATH=$(which "nct6775_fancontrol")	

	if ! [ -f "$PATH" ]
	then
		eend 1 "Could not locate nct6775_fancontrol."
	else
		exec "nct6775_fancontrol"
		eend 0
	fi
	return 0
}

