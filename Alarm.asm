F_Alarm_GroupDis:
	bbs3	Backlight_Flag,F_Alarm_GroupNoDis
	jmp		F_Display_Alarm
F_Alarm_GroupNoDis:
	rts




F_Alarm_GroupSet:
	bbs3	Backlight_Flag,Alarm_GroupSet_NoDis

	lda		Sys_Status_Ordinal
	clc
	rol
	tax
	lda		AlarmGroupHandle_Table+1,x
	pha
	lda		AlarmGroupHandle_Table,x
	pha
Alarm_GroupSet_NoDis:
	rts											; ���ݵ�ǰ��ģʽ����ת����Ӧ����ʾ����

; ���ݵ�ǰ���������Ӧ����ģʽ
AlarmGroupHandle_Table:
	dw		F_Alarm_SwitchStatue-1
	dw		F_AlarmHour_Set-1
	dw		F_AlarmMin_Set-1
	dw		F_AlarmWorkDay_Set-1




; ���ӿ�����ʾ
F_Alarm_SwitchStatue:
	bbs1	Timer_Flag,?AlarmSW_BlinkStart
	rts
?AlarmSW_BlinkStart:
	rmb1	Timer_Flag
	bbs0	Timer_Flag,AlarmSW_UnDisplay
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	and		Alarm_Switch						; �����ӿ���״̬����ó���λ���ǿ����ǹ�

	beq		ALSwitch_DisOff
	lda		#2
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; ��ʾON

	lda		#3
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot
	bra		ALSwitch_DisNum

ALSwitch_DisOff:
	lda		#9
	ldx		#led_d0
	jsr		L_Dis_7Bit_WordDot					; ��ʾ--

	lda		#9
	ldx		#led_d1
	jsr		L_Dis_7Bit_WordDot

ALSwitch_DisNum:
	lda		#4
	ldx		#led_d2
	jsr		L_Dis_7Bit_WordDot					; ��ʾA

	lda		Alarm_Group
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot					; ��ʾ�������
	bra		AlarmSW_Blink_Exit

AlarmSW_UnDisplay:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3

AlarmSW_Blink_Exit:
	REFLASH_DISPLAY
	rts



F_AlarmHour_Set:
	bbs1	Timer_Flag,L_AlarmHour_Set
	rts
L_AlarmHour_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmHour_Display		; �п��ʱ����
	bbs5	IR_Flag,L_AlarmHour_Display			; �п��ʱ����
	bbs0	Timer_Flag,L_AlarmHour_Clear
L_AlarmHour_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts
L_AlarmHour_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jsr		F_UnDisplay_D0_1
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts




F_AlarmMin_Set:
	bbs1	Timer_Flag,L_AlarmMin_Set
	rts
L_AlarmMin_Set:
	rmb1	Timer_Flag

	jsr		F_DisCol

	bbs2	Key_Flag,L_AlarmMin_Display			; �п��ʱ����
	bbs5	IR_Flag,L_AlarmMin_Display			; �п��ʱ����
	bbs0	Timer_Flag,L_AlarmMin_Clear
L_AlarmMin_Display:
	jsr		F_Display_Alarm
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts
L_AlarmMin_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts




F_AlarmWorkDay_Set:
	bbs1	Timer_Flag,L_AlarmWorkDay_Set
	rts
L_AlarmWorkDay_Set:
	rmb1	Timer_Flag

	jsr		F_ClrCol

	bbs0	Timer_Flag,L_AlarmWorkDay_Clear
	ldx		#led_d1
	lda		#1
	jsr		L_Dis_7Bit_DigitDot					; �̶���ʾ1-
	ldx		#led_d2
	lda		#10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d2+6
	jsr		F_DisSymbol

	ldx		Alarm_Group
	dex											; Alarm_Group-1Ϊ����ʵ�ʶ�Ӧ�Ĺ�����
	lda		Alarm_WorkDayAddr,x
	clc
	adc		#5
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts
L_AlarmWorkDay_Clear:
	rmb0	Timer_Flag							; ��1S��־
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	REFLASH_DISPLAY								; ��λˢ����ʾ��־λ
	rts




AlarmDot_Blink:
	bbs1	Symbol_Flag,AL_Blink_Start
	rts
AL_Blink_Start:
	rmb1	Symbol_Flag
	bbs0	Symbol_Flag,AL_Blink_NoDis

	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbr0	P_Temp+1,AL1_NoDisplay				; ��������ʹ����������������ж�bit0��bit1������AL1��AL2
	jsr		F_DisAL1
AL1_NoDisplay:
	bbr1	P_Temp+1,AL2_NoDisplay
	jsr		F_DisAL2
AL2_NoDisplay:
	rts

AL_Blink_NoDis:
	rmb0	Symbol_Flag
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbr0	P_Temp+1,AL1_NoClear				; ��������ʹ����������������ж�bit0��bit1������AL1��AL2
	jsr		F_ClrAL1
AL1_NoClear:
	bbr1	P_Temp+1,AL2_NoClear
	jsr		F_ClrAL2
AL2_NoClear:
	rts


AlarmDot_Const:
	bbs2	Symbol_Flag,AL_Const_Start
	rts
AL_Const_Start:
	rmb2	Symbol_Flag
	ldx		Alarm_Group
	lda		Bit_Num_Table,x
	ora		Triggered_AlarmGroup
	sta		P_Temp+1
	bbs0	P_Temp+1,AL2_Const_Juge				; �ж�AL1���޲�����������֣����򲻽��г���
	bbr0	Alarm_Switch,AL1_Const_Clear		; ����Alarm Swtich����AL1
	jsr		F_DisAL1
	bra		AL2_Const_Juge
AL1_Const_Clear:
	jsr		F_ClrAL1

AL2_Const_Juge:
	bbs1	P_Temp+1,AL_Const_Exit				; �ж�AL2���޲�����������֣����򲻽��г���
	bbr1	Alarm_Switch,AL2_Const_Clear		; ����Alarm Swtich����AL2
	jsr		F_DisAL2
	bra		AL_Const_Exit
AL2_Const_Clear:
	jsr		F_ClrAL2
AL_Const_Exit:
	rts




F_Alarm_Handler:
	bbr5	Time_Flag,Alarm_NoJuge				; ÿSֻ��1�������ж�
	rmb5	Time_Flag
	lda		Alarm_Switch
	bne		Is_Alarm_Trigger					; û���κ����ӿ����򲻻��ж������Ƿ񴥷�
Alarm_NoJuge:
	rts

; ����һ�������趨ֵ��ʱ���ַ��ϵ�ǰʱ�䣬���������Ӵ�����־λ,��ͬ������������
; ͬʱ�жϴ������Ƿ��ڹ�����
Is_Alarm_Trigger:
	lda		Alarm_Switch
	and		#010B
	beq		L_Alarm2_NoMatch					; ���������û�п������򲻻��ж���
	lda		R_Time_Hour
	cmp		R_Alarm2_Hour
	beq		L_Alarm2_HourMatch
L_Alarm2_NoMatch:
	lda		Alarm_Switch
	and		#001B
	beq		L_Alarm1_NoMatch					; ���������û�п������򲻻��ж���
	lda		R_Time_Hour
	cmp		R_Alarm1_Hour
	beq		L_Alarm1_HourMatch
L_Alarm1_NoMatch:
	rts

L_Alarm1_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm1_Min
	beq		L_Alarm1_MinMatch						
	rts											; ����1���Ӳ�ƥ�䣬����δ����

L_Alarm2_HourMatch:
	lda		R_Time_Min
	cmp		R_Alarm2_Min
	beq		L_Alarm2_MinMatch
	bra		L_Alarm2_NoMatch					; ����2���Ӳ�ƥ�䣬�ж�����1


L_Alarm1_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm1_SecMatch
	rts											; ���벻ƥ�䣬�����Ӳ��������˳�
Alarm1_SecMatch:
	lda		Alarm1_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; ��������ȫΪ�����գ���һ������
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm1_NoMatch					; �������첻����
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week 
	beq		L_Alarm1_NoMatch					; ˫�����첻����
	cmp		#6
	beq		L_Alarm1_NoMatch					; ˫������Ҳ������
?No_WorkDay_Juge:
	bbs1	Triggered_AlarmGroup,AL2_Triggered	; ����2�Ѿ�����������²����ظ�ִ�����ֳ�ʼ��
	jsr		L_Alarm_Match_Handle
AL2_Triggered:
	lda		Triggered_AlarmGroup
	ora		#001B
	sta		Triggered_AlarmGroup
	rts

L_Alarm2_MinMatch:
	lda		R_Time_Sec
	cmp		#00
	beq		Alarm2_SecMatch						; ���벻ƥ�䣬�����Ӳ��������˳�
	rts
Alarm2_SecMatch:
	lda		Alarm2_WorkDay
	cmp		#2
	beq		?No_WorkDay_Juge					; ��������ȫΪ�����գ���һ������
	cmp		#1
	bne		?No_WorkDay_1_6
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; �������첻����
	bra		?No_WorkDay_Juge
?No_WorkDay_1_6:
	lda		R_Date_Week
	beq		L_Alarm2_NoMatch					; ˫�����첻����
	cmp		#6
	beq		L_Alarm2_NoMatch					; ˫������Ҳ������
?No_WorkDay_Juge:
	jsr		L_Alarm_Match_Handle
	lda		#010B
	sta		Triggered_AlarmGroup
	bra		L_Alarm2_NoMatch					; �ж���AL2�����ж�AL1




; ȷ�����Ӵ�����Ĵ���
L_Alarm_Match_Handle:
	smb1	Clock_Flag							; ͬʱ����Сʱ�ͷ��ӵ�ƥ�䣬�������Ӵ���
	smb2	Clock_Flag							; ��������ģʽ
	rmb1	Timekeep_Flag						; ��ϵ���ʱ��ɴ���

	jsr		F_RFC_Abort							; ��������ʱ��ѹ������ֹRFC����
	smb1	Time_Flag
	smb3	Timer_Switch						; ����21Hz���������ʱ
	lda		#0
	sta		Counter_21Hz
	sta		Louding_Counter

	bbs4	Sys_Status_Flag,?Timekeep_Mode
	lda		#%00001
	sta		Sys_Status_Flag
	lda		#0
	sta		Sys_Status_Ordinal					; ����Ϩ�����ص�ʱ����ʾģʽ
?Timekeep_Mode:
	REFLASH_DISPLAY

	bbs1	Backlight_Flag,No_CloseScreen_Alarm
	smb1	Backlight_Flag
	smb4	Clock_Flag							; �������������֣���Ҫ��ʱ30S�����
	rmb7	Time_Flag
	lda		#90
	sta		CloseLED_Counter
No_CloseScreen_Alarm:
	rts




; X���̣�AΪ����
L_A_Div_3:
	ldx		#0
L_A_Div_3_Start:
	cmp		#3
	bcc		L_A_Div_3_Over
	sec
	sbc		#3
	inx
	bra		L_A_Div_3_Start
L_A_Div_3_Over:
	rts


; ��A����Xλ
L_A_LeftShift_XBit:
	sta		P_Temp
Shift_Start:
	txa
	beq		Shift_End
	lda		P_Temp
	clc
	rol		P_Temp
	dex
	bra		Shift_Start
Shift_End:
	lda		P_Temp
	rts


Bit_Num_Table:
	db		00H
	db		01H
	db		02H
	db		04H
	db		08H
	db		10H
	db		20H
	db		40H
	db		80H
