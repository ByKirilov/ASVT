.global _start

.text
_start:
	BL	getche
	CMP	R0, #27
	BEQ	exit
	B	_start

exit:
	MOV	R7, #1
	EOR	R0, R0
	SVC	#0
