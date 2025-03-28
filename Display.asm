F_Display_Time:									; ������ʾ������ʾ��ǰʱ��
	jsr		L_DisTime_Min
	jsr		L_DisTime_Hour
	rts

L_DisTime_Min:									; ��ʾ����
	lda		R_Time_Min
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisTime_Hour:									; ��ʾСʱ
	bbr0	Clock_Flag,L_24hMode_Time
	lda		R_Time_Hour
	cmp		#12
	bcs		L_Time12h_PM
	jsr		F_ClrPM								; 12hģʽAM��Ҫ��PM��
	lda		R_Time_Hour							; ���Դ溯�����Aֵ������ȡ����
	cmp		#0
	beq		L_Time_0Hour
	bra		L_Start_DisTime_Hour
L_Time12h_PM:
	jsr		F_DisPM								; 12hģʽPM��Ҫ��PM��
	lda		R_Time_Hour							; ���Դ溯�����Aֵ������ȡ����
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisTime_Hour
L_Time_0Hour:									; 12hģʽ0����Ҫ���12��
	lda		#12
	bra		L_Start_DisTime_Hour

L_24hMode_Time:
	jsr		F_ClrPM								; 24hģʽ����Ҫ��PM��
	lda		R_Time_Hour
L_Start_DisTime_Hour:
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Hour_Tens_NoZero					; Сʱģʽ��ʮλ0����ʾ
	lda		#$0a
L_Hour_Tens_NoZero:
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	rts




; Alarm_Group = ��ǰ�����������
F_Display_Alarm:								; ������ʾ������ʾ��ǰ������
	jsr		L_DisAlarm_Min
	jsr		L_DisAlarm_Hour
	
	rts

L_DisAlarm_Min:
	lda		Alarm_Group							; �ж�Ҫ��ʾ�������ӵ���һ��
	bne		No_Alarm1Min_Display
	lda		R_Alarm1_Min
	bra		AlarmMin_Display_Start
No_Alarm1Min_Display:
	lda		R_Alarm2_Min
AlarmMin_Display_Start:
	sta		R_Alarm_Min
	lda		R_Alarm_Min

	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisAlarm_Hour:								; ��ʾ����Сʱ
	lda		Alarm_Group							; �ж�Ҫ��ʾ�������ӵ���һ��
	cmp		#0
	bne		No_Alarm1Hour_Display
	lda		R_Alarm1_Hour
	bra		AlarmHour_Display_Start
No_Alarm1Hour_Display:
	lda		R_Alarm2_Hour
AlarmHour_Display_Start:
	sta		R_Alarm_Hour
	bbr0	Clock_Flag,L_24hMode_Alarm

	lda		R_Alarm_Hour
	cmp		#12
	bcs		L_Alarm12h_PM
	jsr		F_ClrPM								; 12hģʽAM��Ҫ��PM��
	lda		R_Alarm_Hour						; ���Դ溯�����Aֵ������ȡ����
	cmp		#0
	beq		L_Alarm_0Hour
	bra		L_Start_DisAlarm_Hour
L_Alarm12h_PM:
	jsr		F_DisPM								; 12hģʽPM��Ҫ��PM��
	lda		R_Alarm_Hour						; ���Դ溯�����Aֵ������ȡ����
	sec
	sbc		#12
	cmp		#0
	bne		L_Start_DisAlarm_Hour
L_Alarm_0Hour:									; 12hģʽ0����Ҫ���12��
	lda		#12
	bra		L_Start_DisAlarm_Hour

L_24hMode_Alarm:
	jsr		F_ClrPM								; 24hģʽ����Ҫ��PM��
	lda		R_Alarm_Hour
L_Start_DisAlarm_Hour:
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_AlarmHour_Tens_NoZero				; Сʱģʽ��ʮλ0����ʾ
	lda		#$0a
L_AlarmHour_Tens_NoZero:
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	rts


; ��ʾ���ں���
F_Display_Date:
	jsr		L_DisDate_Day
	jsr		L_DisDate_Month
	rts

L_DisDate_Day:
	lda		R_Date_Day
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d7
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Day_Tens_NoZero					; ����ʮλ0����ʾ
	lda		#10
L_Day_Tens_NoZero:
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisDate_Month:
	lda		R_Date_Month
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Month_Tens_NoZero					; �·�ʮλ0����ʾ
	lda		#0
L_Month_Tens_NoZero:
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot
	rts

L_DisDate_Year:
	lda		#00									; 20xx��Ŀ�ͷ20�ǹ̶���
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	lda		#02
	jsr		L_A_DecToHex
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot

	lda		R_Date_Year							; ��ʾ��ǰ�����
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts




F_UnDisplay_D0_1:								; ��˸ʱȡ����ʾ�õĺ���
	lda		#10
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	rts


F_UnDisplay_D2_3:								; ��˸ʱȡ����ʾ�õĺ���
	lda		#10
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	rts



F_UnDisplay_D4_5:								; ��˸ʱȡ����ʾ�õĺ���
	lda		#0
	ldx		#led_d4
	jsr		L_Dis_2Bit_DigitDot
	lda		#10
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	rts


F_UnDisplay_D6_7:								; ��˸ʱȡ����ʾ�õĺ���
	lda		#10
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	lda		#10
	ldx		#led_d7
	jsr		L_Dis_7Bit_DigitDot
	rts




F_Display_Week:
	jsr		L_GetWeek
	sta		R_Date_Week

	rmb2	Calendar_Flag
	ldx		#led_week1
	jsr		L_Dis_7Bit_WeekDot
	smb2	Calendar_Flag
	lda		R_Date_Week
	ldx		#led_week2
	jsr		L_Dis_7Bit_WeekDot
	rts



; ��ʾ�¶Ⱥ���
F_Display_Temper:
	ldx		#led_minus
	jsr		F_ClrSymbol							; �帺����ʾ
	ldx		#led_d8
	lda		#0
	jsr		L_Dis_2Bit_DigitDot					; ���¶Ȱ�λ��ʾ

	ldx		#led_TMPC
	jsr		F_ClrSymbol
	ldx		#led_TMPF
	jsr		F_ClrSymbol							; �����¶ȵ�λ��ʾ

	bbr3	RFC_Flag,Dis_CDegree
	jmp		Display_FahrenheitDegree
Dis_CDegree:
	jmp		Display_CelsiusDegree


Display_CelsiusDegree:
	lda		R_Temperature
	jsr		L_A_DecToHex
	sta		P_Temp+7
	and		#$0f
	ldx		#led_d10
	jsr		L_Dis_7Bit_DigitDot
	lda		P_Temp+7
	and		#$f0
	beq		Degree_NoTens						; ��4λΪ0����d9����ʾ
	jsr		L_LSR_4Bit
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	bra		Dis_CelSymbol
Degree_NoTens:
	lda		#10
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	bbr2	RFC_Flag,NoMinusTemper				; �¶��Ǹ�λ����ʱ��d9��ʾ����

	ldx		#led_d9+6
	jsr		F_DisSymbol
	bra		NoMinusTemper

Dis_CelSymbol:
	bbr2	RFC_Flag,NoMinusTemper				; �¶�Ϊʮλ����ʱ��d8��ʾ����
	ldx		#led_minus
	jsr		F_DisSymbol

NoMinusTemper:
	ldx		#led_TMPC							; ��ʾ���϶�C
	jsr		F_DisSymbol
	rts


Display_FahrenheitDegree:
	jsr		F_C2F
	lda		R_Temperature_F
	jsr		L_A_DecToHex

	pha
	txa
	ldx		#led_d8
	jsr		L_Dis_2Bit_DigitDot
	pla
	pha
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$0f
	ldx		#led_d10
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_TMPF							; ��ʾ���϶�F
	jsr		F_DisSymbol
	rts




F_SymbolRegulate:								; ��ʾ������
	jsr		L_ALMDot_Blink
	jsr		F_AlarmSW_Display
	rts


; ����ʱ��ALM��
L_ALMDot_Blink:
	bbr2	Clock_Flag,L_SymbolDis_Exit			; �����̰˯״̬���򲻽����ӳ���
	bbs0	Symbol_Flag,L_SymbolDis
L_SymbolDis_Exit:
	rts
L_SymbolDis:
	rmb0	Symbol_Flag							; ALM���S��־
	bbs1	Symbol_Flag,L_ALM_Dot_Clr
L_ALM_Dot_Dis:
	bbs0	Triggered_AlarmGroup,Group1_Bright
	bbs1	Triggered_AlarmGroup,Group2_Bright
Group1_Bright:
	jsr		F_DisAL1
	rts
Group2_Bright:
	jsr		F_DisAL2
	rts
	
L_ALM_Dot_Clr:
	rmb1	Symbol_Flag							; ALM��1S��־
	bbs0	Triggered_AlarmGroup,Group1_Extinguish
	bbs1	Triggered_AlarmGroup,Group2_Extinguish
Group1_Extinguish:
	jsr		F_ClrAL1
	rts
Group2_Extinguish:
	jsr		F_ClrAL2
	rts



; ��������ʾ״̬�£���ʾ����������
F_AlarmSW_Display:
	bbs2	Clock_Flag,F_AlarmSW_Exit			; ����ʱ���������ӳ���ӹ�
	lda		Sys_Status_Flag
	cmp		#0010B
	bne		Alarm1_Switch						; ��������ʾģʽ�£�������������ĵ���ʾ
F_AlarmSW_Exit:
	rts

Alarm1_Switch:
	lda		Alarm_Switch
	and		#001B
	beq		Alarm1_Switch_Off
	jsr		F_DisAL1
	bra		Alarm2_Switch
Alarm1_Switch_Off:
	jsr		F_ClrAL1

Alarm2_Switch:
	lda		Alarm_Switch
	and		#010B
	beq		Alarm2_Switch_Off
	jsr		F_DisAL2
	rts
Alarm2_Switch_Off:
	jsr		F_ClrAL2
	rts




L_Dis_xxHr:
	ldx		#led_d3
	lda		#8
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d2
	lda		#7
	jsr		L_Dis_7Bit_WordDot

	bbr0	Clock_Flag,L_24hMode_Set
	ldx		#led_d1
	lda		#2
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d0
	lda		#1
	jsr		L_Dis_7Bit_DigitDot
	rts
L_24hMode_Set:
	ldx		#led_d1
	lda		#4
	jsr		L_Dis_7Bit_DigitDot
	ldx		#led_d0
	lda		#2
	jsr		L_Dis_7Bit_DigitDot
	rts



; �����
F_DisCol:
	ldx		#led_COL1
	jsr		F_DisSymbol
	ldx		#led_COL2
	jsr		F_DisSymbol
	rts

; �����
F_ClrCol:
	ldx		#led_COL1
	jsr		F_ClrSymbol
	ldx		#led_COL2
	jsr		F_ClrSymbol
	rts

; ��PM��
F_DisPM:
	ldx		#led_PM
	jsr		F_DisSymbol
	rts

; ��PM��
F_ClrPM:
	ldx		#led_PM
	jsr		F_ClrSymbol
	rts

; ��AL1��
F_DisAL1:
	ldx		#led_AL1
	jsr		F_DisSymbol
	rts

; ��AL1��
F_ClrAL1:
	ldx		#led_AL1
	jsr		F_ClrSymbol
	rts

; ��AL2��
F_DisAL2:
	ldx		#led_AL2
	jsr		F_DisSymbol
	rts

; ��AL2��
F_ClrAL2:
	ldx		#led_AL2
	jsr		F_ClrSymbol
	rts


; ����Aֵ��ת��ͬ��AL���������
L_Control_ALDot:
	clc
	rol
	tax
	lda		AlarmDot_Table+1,x
	pha
	lda		AlarmDot_Table,x
	pha
	rts

AlarmDot_Table:
	dw		F_ClrAL1-1
	dw		F_ClrAL2-1
	dw		F_DisAL1-1
	dw		F_DisAL2-1




L_LSR_4Bit:
	clc
	ror
	ror
	ror
	ror
	rts



; ��A��ֵ����BCDת��
; A==ת��������X==��λ
L_A_DecToHex:
	sta		P_Temp								; ��ʮ�������뱣�浽P_Temp
	ldx		#0
	lda		#0
	sta		P_Temp+1							; ʮλ����
	sta		P_Temp+2							; ��λ����

L_DecToHex_Loop:
	lda		P_Temp
	cmp		#10
	bcc		L_DecToHex_End						; ���С��10������ת��

	sec
	sbc		#10									; ��ȥ10
	sta		P_Temp								; ����ʮ����ֵ
	inc		P_Temp+1							; ʮλ+1���ۼ�ʮ�����Ƶ�ʮλ
	bra		L_DecToHex_Loop						; �ظ�ѭ��

L_DecToHex_End:
	lda		P_Temp								; ���ʣ���ֵ�Ǹ�λ
	sta		P_Temp+2							; �����λ

Juge_3Positions:
	lda		P_Temp+1							; ��ʮλ����A�Ĵ������
	cmp		#10
	bcc		No_3Positions						; �ж��Ƿ��а�λ
	sec
	sbc		#10
	sta		P_Temp+1
	inx
	bra		Juge_3Positions
No_3Positions:
	clc
	rol
	rol
	rol
	rol											; ����4�Σ���ɳ�16
	clc
	adc		P_Temp+2							; ���ϸ�λֵ

	rts
