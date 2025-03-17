F_Calendar_Add:										; ������
	smb1	Calendar_Flag
	jsr		F_Is_Leap_Year
	ldx		R_Date_Month							; �·�����Ϊ���������
	dex
	bbs0	Calendar_Flag,L_Leap_Year				; ��������꣬�������·�������
	lda		L_Table_Month_Common,x					; �����ƽ���·�������
	bra		L_Day_Juge
L_Leap_Year:
	lda		L_Table_Month_Leap,x
L_Day_Juge:
	cmp		R_Date_Day
	bne		L_Day_Add			
	lda		#1
	sta		R_Date_Day								; �ս�λ����
	lda		R_Date_Month
	cmp		#12										; �����·ݵ��Ѿ��Ƶ�12
	beq		L_Year_Add								; �·ݽ�λ
	inc		R_Date_Month							; �·�������
	rts

L_Day_Add:
	inc		R_Date_Day
	rts

L_Year_Add:
	lda		#1
	sta		R_Date_Month
	lda		R_Date_Year
	cmp		#99										; ����ߵ�2099
	beq		L_Reload_Year							; ����һ��ص�2000
	inc		R_Date_Year
	rts
L_Reload_Year:
	lda		#0
	sta		R_Date_Year
	rts

; �ж�ƽ���꺯��
F_Is_Leap_Year:
	lda		R_Date_Year
	and		#0011B									; ȡ�����λ
	beq		L_Set_LeapYear_Flag						; ����Ϊ0���ܱ�4����
	rmb0	Calendar_Flag
	rts
L_Set_LeapYear_Flag:
	smb0	Calendar_Flag
	rts


; ͨ����ǰ���ڼ��㵱ǰ������
L_GetWeek:
	jsr		F_Is_Leap_Year

	ldx		R_Date_Day
	dex												; ��ǰ����-1->A
	txa
	jsr		L_MOD_A_7
	sta		P_Temp									; ��ǰ������������յ�������ƫ����->P_Temp

	ldx		R_Date_Month
	dex
	bbs0	Calendar_Flag,L_DateToWeek_Leap
	lda		L_Table_Gap_CommonMonth,x				; ƽ���·����յ�������->A
	bra		L_Get_Week
L_DateToWeek_Leap:
	lda		L_Table_Gap_LeapMonth,x					; �����·����յ�������->A
L_Get_Week:
	sta		P_Temp+1								; �·����յ�������->P_Temp+1

	lda		R_Date_Year								; ��ȡ��ǰ�����յ�������
	clc
	ror												; ��ݳ���2�����
	tax
	lda		L_Table_WeekInYear,x
	bbs0	R_Date_Year,L_Odd_Year
	and		#0111B									; ż�����ȡ��4λ
	bra		L_Get_Weak_YearFirstDay
L_Odd_Year:
	jsr		L_LSR_4Bit
	and		#0111B									; �������ȡ��4λ
L_Get_Weak_YearFirstDay:
	clc
	adc		P_Temp
	clc
	adc		P_Temp+1								; ��ǰ�����յ�������+��ƫ��==��ǰ������
	jsr		L_MOD_A_7
	sta		R_Date_Week
	rts



; ������ʾ
F_Date_Display:
	jsr		F_ClrCol								; ���ڲ���ʾCOL��PM
	jsr		F_ClrPM

	jsr		F_Display_Date							; ��ʾ����

	rts



F_DisYear_Set:
	bbs3	Timer_Flag,L_KeyTrigger_NoBlink_Year	; �п��ʱ����˸
	bbs0	Timer_Flag,L_Blink_Year					; û�а�S��־����˸
	rts
L_Blink_Year:
	rmb0	Timer_Flag								; ���S��־
	bbs1	Timer_Flag,L_Year_Clear					; ��1S��־ʱ��
L_KeyTrigger_NoBlink_Year:
	jsr		L_DisDate_Year
	rts
L_Year_Clear:
	rmb1	Timer_Flag								; ��1S��־
	jsr		F_UnDisplay_D0_1
	jsr		F_UnDisplay_D2_3
	rts


F_DisMonth_Set:
	bbs3	Timer_Flag,L_KeyTrigger_NoBlink_Month	; �п��ʱ����˸
	bbs0	Timer_Flag,L_Blink_Month				; û�а�S��־����˸
	rts
L_Blink_Month:
	rmb0	Timer_Flag								; ���S��־
	bbs1	Timer_Flag,L_Month_Clear				; ��1S��־ʱ��
L_KeyTrigger_NoBlink_Month:
	jsr		L_DisDate_Month
	jsr		L_DisDate_Day
	rts	
L_Month_Clear:
	rmb1	Timer_Flag								; ��1S��־
	jsr		F_UnDisplay_D0_1
	rts


F_DisDay_Set:
	bbs3	Timer_Flag,L_KeyTrigger_NoBlink_Day		; �п��ʱ����˸
	bbs0	Timer_Flag,L_Blink_Day					; û�а�S��־����˸
	rts
L_Blink_Day:
	rmb0	Timer_Flag								; ���S��־
	bbs1	Timer_Flag,L_Day_Clear					; ��1S��־ʱ��
L_KeyTrigger_NoBlink_Day:
	jsr		L_DisDate_Day
	jsr		L_DisDate_Month
	rts	
L_Day_Clear:
	rmb1	Timer_Flag								; ��1S��־
	jsr		F_UnDisplay_D2_3
	rts


L_MOD_A_7:
	cmp		#7
	bcc		L_MOD_A_7Over
	sec
	sbc		#7
	bra		L_MOD_A_7
L_MOD_A_7Over:
	rts



; ƽ���ÿ�·�������
L_Table_Month_Common:
	.byte	31	; January
	.byte	28	; February
	.byte	31	; March
	.byte	30	; April
	.byte	31	; May
	.byte	30	; June
	.byte	31	; July
	.byte	31	; August
	.byte	30	; September
	.byte	31	; October
	.byte	30	; November
	.byte	31	; December

; �����ÿ�·�������
L_Table_Month_Leap:
	.byte	31	; January
	.byte	29	; February
	.byte	31	; March
	.byte	30	; April
	.byte	31	; May
	.byte	30	; June
	.byte	31	; July
	.byte	31	; August
	.byte	30	; September
	.byte	31	; October
	.byte	30	; November
	.byte	31	; December

L_Table_WeekInYear:
	.byte	$1E	; 2001,2000 E="1110"����2000��1��1����������(110),������(1)
	.byte	$32	; 2003,2002
	.byte	$6C	; 2005,2004
	.byte	$10	; 2007,2006
	.byte	$4A	; 2009,2008
	.byte	$65	; 2011,2010
	.byte	$28	; 2013,2012
	.byte	$43	; 2015,2014
	.byte	$0D	; 2017,2016
	.byte	$21	; 2019,2018
	.byte	$5B	; 2021,2020
	.byte	$06	; 2023,2022
	.byte	$39	; 2025,2024
	.byte	$54	; 2027,2026
	.byte	$1E	; 2029,2028
	.byte	$32	; 2031,2030
	.byte	$6C	; 2033,2032
	.byte	$10	; 2035,2034
	.byte	$4A	; 2037,2036
	.byte	$65	; 2039,2038
	.byte	$28	; 2041,2040
	.byte	$43	; 2043,2042
	.byte	$0D	; 2045,2044
	.byte	$21	; 2047,2046
	.byte	$5B	; 2049,2048
	.byte	$06	; 2051,2050
	.byte	$39	; 2053,2052
	.byte	$54	; 2055,2054
	.byte	$1E	; 2057,2056
	.byte	$32	; 2059,2058
	.byte	$6C	; 2061,2060
	.byte	$10	; 2063,2062
	.byte	$4A	; 2065,2064
	.byte	$65	; 2067,2066
	.byte	$28	; 2069,2068
	.byte	$43	; 2071,2070
	.byte	$0D	; 2073,2072
	.byte	$21	; 2075,2074
	.byte	$5B	; 2077,2076
	.byte	$06	; 2079,2078
	.byte	$39	; 2081,2080
	.byte	$54	; 2083,2082
	.byte	$1E	; 2085,2084
	.byte	$32	; 2087,2086
	.byte	$6C	; 2089,2088
	.byte	$10	; 2091,2090
	.byte	$4A	; 2093,2092
	.byte	$65	; 2095,2094
	.byte	$28	; 2097,2096
	.byte	$43	; 2099,2098

; ƽ����ÿ�·����նԵ�ǰ������յ�����ƫ��
L_Table_Gap_CommonMonth:
	.byte	$0	; 1��1��
	.byte	$3	; 2��1��
	.byte	$3	; 3��1��
	.byte	$6	; 4��1��
	.byte	$1	; 5��1��
	.byte	$4	; 6��1��
	.byte	$6	; 7��1��
	.byte	$2	; 8��1��
	.byte	$5	; 9��1��
	.byte	$0	; 10��1��
	.byte	$3	; 11��1��
	.byte	$5	; 12��1��

; ������ÿ�·����նԵ�ǰ������յ�����ƫ��
L_Table_Gap_LeapMonth:
	.byte	$0	; 1��1��
	.byte	$3	; 2��1��
	.byte	$4	; 3��1��
	.byte	$0	; 4��1��
	.byte	$2	; 5��1��
	.byte	$5	; 6��1��
	.byte	$0	; 7��1��
	.byte	$3	; 8��1��
	.byte	$6	; 9��1��
	.byte	$1	; 10��1��
	.byte	$4	; 11��1��
	.byte	$6	; 12��1��
