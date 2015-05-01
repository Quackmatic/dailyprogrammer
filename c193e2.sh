#!/bin/bash
declare -A SUBS=(
	['lol']='laugh out loud' \
	['dw']='don'\''worry' \
	['hf']='have fun' \
	['gg']='good game' \
	['brb']='be right back' \
	['g2g']='got to go' \
	['wtf']='what the fuck' \
	['wp']='well played' \
	['gl']='good luck' \
	['imo']='in my opinion')
read INPUT
eval "echo "$INPUT" | sed -r $(for ACR in "${!SUBS[@]}"; do printf " -e \"s/\\\\b$ACR\\\\b/${SUBS[$ACR]}/g\""; done)"