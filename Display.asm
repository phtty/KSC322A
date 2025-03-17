F_Display_Time:									; ������ʾ������ʾ��ǰʱ��
	jsr		L_DisTime_Min
	jsr		L_DisTime_Hour
	rts

L_DisTime_Min:
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




; Sys_Status_Ordinal = �������
F_Display_Alarm:								; ������ʾ������ʾ��ǰ����
	jsr		L_DisAlarm_Min
	jsr		L_DisAlarm_Hour
	rts

L_DisAlarm_Min:
	lda		Sys_Status_Ordinal					; �ж�Ҫ��ʾ�������ӵ���һ��
	bne		No_Alarm1Min_Display
	lda		R_Alarm1_Min
	bra		AlarmMin_Display_Start
No_Alarm1Min_Display:
	cmp		#1
	bne		No_Alarm2Min_Display
	lda		R_Alarm2_Min
	bra		AlarmMin_Display_Start
No_Alarm2Min_Display:
	lda		R_Alarm3_Min
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
	lda		Sys_Status_Ordinal					; �ж�Ҫ��ʾ�������ӵ���һ��
	cmp		#0
	bne		No_Alarm1Hour_Display
	lda		R_Alarm1_Hour
	bra		AlarmHour_Display_Start
No_Alarm1Hour_Display:
	cmp		#1
	bne		No_Alarm2Hour_Display
	lda		R_Alarm2_Hour
	bra		AlarmHour_Display_Start
No_Alarm2Hour_Display:
	lda		R_Alarm3_Hour
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
	ldx		#led_d3
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Day_Tens_NoZero					; ����ʮλ0����ʾ
	lda		#10
L_Day_Tens_NoZero:
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	rts

L_DisDate_Month:
	lda		R_Date_Month
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	bne		L_Month_Tens_NoZero					; �·�ʮλ0����ʾ
	lda		#10
L_Month_Tens_NoZero:
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
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
	lda		#0
	jsr		L_Dis_2Bit_DigitDot					; ���¶Ȱ�λ��ʾ
	lda		#10
	ldx		#led_d7
	jsr		L_Dis_7Bit_DigitDot					; �����¶ȵ�λ��ʾ

	bbr4	RFC_Flag,Dis_CDegree
	jmp		Display_FahrenheitDegree
Dis_CDegree:
	jmp		Display_CelsiusDegree


Display_CelsiusDegree:
	lda		R_Temperature
	jsr		L_A_DecToHex
	sta		P_Temp+7
	and		#$0f
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	lda		P_Temp+7
	and		#$f0
	beq		Degree_NoTens						; ��4λΪ0����d5����ʾ
	jsr		L_LSR_4Bit
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	bra		Dis_CelSymbol
Degree_NoTens:
	lda		#10
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	bbr2	RFC_Flag,NoMinusTemper				; �¶��Ǹ�λ����ʱ��d5��ʾ����

	ldx		#led_d5+6
	jsr		F_DisSymbol
	bra		NoMinusTemper

Dis_CelSymbol:
	bbr2	RFC_Flag,NoMinusTemper				; �¶�Ϊʮλ����ʱ��d4��ʾ����
	ldx		#led_minus
	jsr		F_DisSymbol

NoMinusTemper:
	lda		#0									; ��ʾ���϶�C
	ldx		#led_d7
	jsr		L_Dis_7Bit_WordDot
	rts


Display_FahrenheitDegree:
	jsr		F_C2F
	lda		R_Temperature_F
	jsr		L_A_DecToHex
	
	pha
	txa
	jsr		L_Dis_2Bit_DigitDot
	pla
	pha
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$0f
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	lda		#1									; ��ʾ���϶�C
	ldx		#led_d7
	jsr		L_Dis_7Bit_WordDot
	rts





; ��ʾʪ�Ⱥ���
F_Display_Humid:
	lda		R_Humidity
	beq		DisHumid_MinusTemper				; �¶�Ϊ��ʱ������ʾʪ��
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d8
	jsr		L_Dis_7Bit_DigitDot
	rts
DisHumid_MinusTemper:
	lda		#9
	ldx		#led_d8
	jsr		L_Dis_7Bit_WordDot
	lda		#9
	ldx		#led_d9
	jsr		L_Dis_7Bit_WordDot
	rts



F_SymbolRegulate:								; ��ʾ������
	ldx		#led_TMP
	jsr		F_DisSymbol
	ldx		#led_Per1
	jsr		F_DisSymbol
	ldx		#led_Per2
	jsr		F_DisSymbol

	jsr		L_ALMDot_Blink
	jsr		F_AlarmSW_Display
	rts


; ̰˯ʱ��ALM��
L_ALMDot_Blink:
	bbr3	Clock_Flag,L_SymbolDis_Exit			; �����̰˯״̬���򲻽����ӳ���
	bbs0	Symbol_Flag,L_SymbolDis
L_SymbolDis_Exit:
	rts
L_SymbolDis:
	rmb0	Symbol_Flag							; ALM���S��־
	bbs1	Symbol_Flag,L_ALM_Dot_Clr
L_ALM_Dot_Dis:
	bbs0	Triggered_AlarmGroup,Group1_Bright
	bbs1	Triggered_AlarmGroup,Group2_Bright
	bbs2	Triggered_AlarmGroup,Group3_Bright
Group1_Bright:
	jsr		F_DisAL1
	rts
Group2_Bright:
	jsr		F_DisAL2
	rts
Group3_Bright:
	jsr		F_DisAL3
	rts
	
L_ALM_Dot_Clr:
	rmb1	Symbol_Flag							; ALM��1S��־
	bbs0	Triggered_AlarmGroup,Group1_Extinguish
	bbs1	Triggered_AlarmGroup,Group2_Extinguish
	bbs2	Triggered_AlarmGroup,Group3_Extinguish
Group1_Extinguish:
	jsr		F_ClrAL1
	rts
Group2_Extinguish:
	jsr		F_ClrAL2
	rts
Group3_Extinguish:
	jsr		F_ClrAL3
	rts



; ��������ʾ״̬�£���ʾ����������
F_AlarmSW_Display:
	bbs3	Clock_Flag,F_AlarmSW_Exit			; ̰˯ʱ���������ӳ���ӹ�
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
	bra		Alarm3_Switch
Alarm2_Switch_Off:
	jsr		F_ClrAL2

Alarm3_Switch:
	lda		Alarm_Switch
	and		#100B
	beq		Alarm3_Switch_Off
	jsr		F_DisAL3
	rts
Alarm3_Switch_Off:
	jsr		F_ClrAL3
	rts




F_DP_Display:
	bbs6	Key_Flag,DP_Display				; û��DP��ʾ��־����ʾʱ��
	rts
DP_Display:
	jsr		F_ClrCol						; DP��ʾ��Ҫ������PM��
	jsr		F_ClrPM
	bbs7	Key_Flag,DP_Display_Juge		; ��DP��ʾ����û1S�򲻼�����ʾʱ�ӣ�ֱ���˳�
	pla
	pla
	rts
DP_Display_Juge:
	rmb7	Key_Flag
	inc		Counter_DP
	lda		Counter_DP
	cmp		#6
	beq		DP_Display_Over					; ����5sǰһֱ��ʾDP

	bbs2	Key_Flag,DP_RDMode
	jsr		L_Dis_dp_1						; ����DP-1
	bra		DP_Mode_Return
DP_RDMode:
	jsr		L_Dis_dp_2						; ����DP-2
DP_Mode_Return:
	pla										; �ȴ�1S��־���������Ӽ���
	pla
	rts
DP_Display_Over:
	lda		#0
	sta		Counter_DP
	rmb6	Key_Flag
	rts


L_Dis_dp_1:
	ldx		#led_d0
	lda		#5
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d1
	lda		#6
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d2
	lda		#9
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d3
	lda		#1
	jsr		L_Dis_7Bit_DigitDot
	rts


L_Dis_dp_2:
	ldx		#led_d0
	lda		#5
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d1
	lda		#6
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d2
	lda		#9
	jsr		L_Dis_7Bit_WordDot

	ldx		#led_d3
	lda		#2
	jsr		L_Dis_7Bit_DigitDot
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

; ��AL3��
F_DisAL3:
	ldx		#led_AL3
	jsr		F_DisSymbol
	rts

; ��AL3��
F_ClrAL3:
	ldx		#led_AL3
	jsr		F_ClrSymbol
	rts



L_LSR_4Bit:
	clc
	ror
	ror
	ror
	ror
	rts



; ��256���ڵ�����ʮ���ƴ洢��ʮ�����Ƹ�ʽ��
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
