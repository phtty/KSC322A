F_Test_Mode:
	jsr		F_ClearScreen
	jsr		F_FillScreen						; �ϵ�ȫ��2S
	lda		#2
	sta		P_Temp+4
Loop_FillScr:
	bbr1	Timer_Flag,Loop_FillScr
	rmb1	Timer_Flag
	dec		P_Temp+4
	lda		P_Temp+4
	bne		Loop_FillScr

	jsr		F_ClearScreen						; ��0��ʾ��9
	jsr		L_DisSymbol_Test
	lda		#0
	sta		P_Temp+4
	jsr		L_DisDigit_Test
Loop_DisDigit:
	bbr0	Timer_Flag,Loop_DisDigit
	rmb0	Timer_Flag
	jsr		L_DisDigit_Test
	inc		P_Temp+4
	lda		P_Temp+4
	cmp		#11
	bne		Loop_DisDigit

	jsr		F_ClearScreen						; ��ʾPM��AL��
	lda		#0
	sta		P_Temp+4
	jsr		F_DisPM
	jsr		F_DisAL1
	jsr		F_DisAL2
	jsr		F_DisAL3
Loop_DisSymbol1:
	bbr0	Timer_Flag,Loop_DisSymbol1
	rmb0	Timer_Flag

	jsr		F_ClearScreen						; ��ʾdot��
	lda		#0
	sta		P_Temp+4
	jsr		F_DisCol
Loop_DisSymbol2:
	bbr0	Timer_Flag,Loop_DisSymbol2
	rmb0	Timer_Flag

	jsr		F_ClearScreen						; ��ʾ�¶ȵ�
	lda		#0
	sta		P_Temp+4
	ldx		#led_TMP
	jsr		F_DisSymbol

	bbr6	PB,StartUp_WakeUp
	smb0	Backlight_Flag						; ��5V��������λDC��־
StartUp_WakeUp:
	smb3	Key_Flag							; �ϵ��ȸ�һ�������¼�������ϵ粻��ʾ
	rmb4	PD
	rts


L_DisDigit_Test:
	ldx		#led_d0
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d1
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d2
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d3
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d5
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d6
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d7
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d8
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot

	ldx		#led_d9
	lda		P_Temp+4
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisSymbol_Test:
	ldx		#led_minus
	jsr		F_DisSymbol
	lda		#1
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot					; digit4ȫ��
	ldx		#led_Per1
	jsr		F_DisSymbol
	ldx		#led_Per2
	jsr		F_DisSymbol							; �ٷֺ���ʾ
	rts
