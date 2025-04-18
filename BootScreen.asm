F_BootScreen:
	jsr		F_FillScreen						; …œµÁ»´œ‘2S
	jsr		L_Send_DRAM
	lda		#2
	sta		P_Temp+4
Loop_FillScr:
	bbr0	Timer_Flag,Loop_FillScr
	rmb0	Timer_Flag
	dec		P_Temp+4
	lda		P_Temp+4
	bne		Loop_FillScr

	jsr		F_ClearScreen
	jsr		F_Display_Time
	jsr		F_DisCol
	jsr		L_Send_DRAM
	rmb6	Time_Flag

	rts
