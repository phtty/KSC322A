F_Time_Run:
	bbs0	Time_Flag,L_TimeRun_Add				; ����S��־�Ž�����
	rts
L_TimeRun_Add:
	rmb0	Time_Flag								; ����S��־

	inc		R_Time_Sec
	lda		R_Time_Sec
	cmp		#60
	bcc		L_Time_SecRun_Exit						; δ�������ӽ�λ
	lda		#0
	sta		R_Time_Sec
	inc		R_Time_Min
	jsr		CompensationTime_CHG					; ÿ�μӷ��ӵ�ʱ��Ҫ�����²�ʱ��
	lda		R_Time_Min
	cmp		#60
	bcc		L_Time_SecRun_Exit						; δ����Сʱ��λ
	lda		#0
	sta		R_Time_Min
	inc		R_Time_Hour
	lda		R_Time_Hour
	cmp		#24
	bcc		L_Time_SecRun_Exit						; δ�������λ
	lda		#0
	sta		R_Time_Hour
	jsr		F_Calendar_Add
L_Time_SecRun_Exit:
	rts




; ʱ����ʾģʽ
F_Clock_Display:
	bbs0	Sys_Status_Ordinal,L_DisDate_Mode
	jsr		F_Time_Display
	rts
L_DisDate_Mode:
	jsr		F_Date_Display
	rts




; ʱ����ʾ
F_Time_Display:
	bbs1	Timer_Flag,L_TimeDot_Out
	rts
L_TimeDot_Out:
	rmb1	Timer_Flag
	jsr		F_Display_Time

	bbs0	Timer_Flag,L_Dot_Clear
	jsr		F_DisCol								; û1S��־����
	rts												; ��S����ʱû1S��־����ʱ��ֱ�ӷ���
L_Dot_Clear:
	rmb0	Timer_Flag
	jsr		F_ClrCol								; ��1S��־��S��
	rts




; ʱ������ģʽ
F_Clock_Set:
	lda		Sys_Status_Ordinal
	bne		No_TMSwitch_Display
	jmp		F_TimeMode_Switch						; 12/24hģʽ�л�
No_TMSwitch_Display:
	cmp		#1
	bne		No_HourSet_Display
	jmp		F_DisHour_Set
No_HourSet_Display:
	cmp		#2
	bne		No_MinSet_Display
	jmp		F_DisMin_Set
No_MinSet_Display:
	cmp		#3
	bne		No_YearSet_Display
	jsr		F_ClrCol								; ���ڲ���ʾCOL��PM
	jsr		F_ClrPM
	jmp		F_DisYear_Set
No_YearSet_Display:
	cmp		#4
	bne		No_MonthSet_Display
	jsr		F_ClrCol								; ���ڲ���ʾCOL��PM
	jsr		F_ClrPM

	jmp		F_DisMonth_Set
No_MonthSet_Display:
	jsr		F_ClrCol								; ���ڲ���ʾCOL��PM
	jsr		F_ClrPM

	jmp		F_DisDay_Set




; ʱ������ģʽ�л���ʾ
F_TimeMode_Switch:
	bbs1	Timer_Flag,L_TimeMode_Out
	rts
L_TimeMode_Out:
	rmb1	Timer_Flag
	jsr		F_ClrCol
	jsr		F_ClrPM
	bbs2	Key_Flag,L_TimeMode_Display
	bbs0	Timer_Flag,L_Mode_Clear
L_TimeMode_Display:
	jsr		L_Dis_xxHr
	rts
L_Mode_Clear:
	rmb0	Timer_Flag								; ��1S��־
	jsr		F_UnDisplay_D0_1
	rts




F_DisHour_Set:
	bbs2	Key_Flag,L_KeyTrigger_NoBlink_Hour	; �п��ʱ����˸
	bbs1	Timer_Flag,L_Blink_Hour
	rts
L_Blink_Hour:
	rmb1	Timer_Flag								; ���S��־

	jsr		F_DisCol

	bbs0	Timer_Flag,L_Hour_Clear
L_KeyTrigger_NoBlink_Hour:
	jsr		L_DisTime_Hour							; ��S��
	jsr		L_DisTime_Min
	rts
L_Hour_Clear:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D0_1						; 1S��
	rts


F_DisMin_Set:
	bbs2	Key_Flag,L_KeyTrigger_NoBlink_Min		; �п��ʱ����˸
	bbs1	Timer_Flag,L_Blink_Min					; û�а�S��־ʱ����˸
	rts
L_Blink_Min:
	rmb1	Timer_Flag								; ���S��־

	jsr		F_DisCol

	bbs0	Timer_Flag,L_Min_Clear
L_KeyTrigger_NoBlink_Min:
	jsr		L_DisTime_Min							; ��S��
	jsr		L_DisTime_Hour
	rts
L_Min_Clear:
	rmb0	Timer_Flag
	jsr		F_UnDisplay_D2_3						; 1S��
	rts
