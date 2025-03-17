L_Humid_Handle:
	jsr		L_RR_Multi_512
	jsr		L_RR_Div_RH
	jsr		L_Search_HumidTable

	rts

L_Search_HumidTable:
	lda		R_Temperature
	bbr2	RFC_Flag,?Start						; ���¶�Ϊ��������ʪ�Ȳ���ʾ
	lda		#0
	sta		R_Humidity
	rts
?Start:
	cmp		#51
	bcc		L_Temper_NoOverFlow					; �����¶ȴ���50�ȣ��̶�Ϊ50��
	lda		#50
L_Temper_NoOverFlow:
	jsr		L_A_Mod_5							; ���¶�ֵ����5�õ�ʪ�ȱ�����N�����ڲ�����Ӧ�¶��µ�ʪ��ֵ���Ա���к�����ʪ�ȼ���
	stx		P_Temp
	cmp		#2
	bcs		N_GreaterThan1
	bra		Temper_GapSmall						; ����Ϊ0��1ʱ������N���
N_GreaterThan1:
	cmp		#4
	bcs		N_GreaterThan3
	bra		Temper_GapMiddle					; ����Ϊ2��3ʱ������N��N+1�����α�ȡ���ߵ�ƽ����
N_GreaterThan3:
	inc		P_Temp
	bra		Temper_GapLong						; ����Ϊ4��������ֵΪN+1���

Temper_GapSmall:
	jsr		L_SearchTable_N						; ���¶ȵ�������Сʱ��ֱ�Ӳ��ýӽ���ʪ�ȱ���ʪ��ֵ
	rts
Temper_GapMiddle:
	lda		P_Temp
	sta		P_Temp+1							; ����ı�����ֵ���ݴ�����ֵ
	jsr		L_SearchTable_N						; �����ϴ�ʱ����������ʪ�ȱ�������ƽ��ֵ��Ϊʪ��ֵ
	lda		R_Humidity
	sta		P_Temp+2
	lda		P_Temp+1
	sta		P_Temp
	inc		P_Temp								; ������ֵΪN+1��ʪ�ȱ�
	jsr		L_SearchTable_N
	lda		R_Humidity
	clc
	adc		P_Temp+2							; ǰ��ȡ�õ�ʪ��ֵ���Ȼ�����2�����ƽ��ֵ
	clc
	ror
	sta		R_Humidity							; �������ƽ��ֵΪ����ʪ��ֵ
	rts
Temper_GapLong:
	jsr		L_SearchTable_N						; ���¶ȵ������ϴ�ʱ������һ�׵�ʪ�ȱ���ʪ��ֵ
	rts

; ��N��Ϊ��������ʪ�ȱ�ó���ǰʪ��ֵ
; P_TempΪʪ�ȱ�����N��QhΪL_RR_Div_RH
L_SearchTable_N:
	lda		P_Temp
	clc
	rol											; Nֵ����2�õ���ȷ��ƫ��
	sta		P_Temp
	lda		#0
	sta		R_Humidity							; ʪ��ֵ
Loop_Start:
	bbs3	RFC_Flag,Loop_Over					; ����ڵݼ�������м��꣬���˳�ѭ��
	lda		Humid_SearchLoop_Addr+1				; ��ջѭ����ʼ��ǩ�ĵ�ַ
	pha											; �Ա�����ѭ���������
	lda		Humid_SearchLoop_Addr				; �ܷ��ص��ú���ѭ����ʼ
	pha

	ldx		P_Temp
	lda		Temper_Humid_table+1,x
	pha											; ��ջ��Ӧ��ѭ���������ַ
	lda		Temper_Humid_table,x
	pha
	rts											; ��ת����Ӧѭ�������
Loop_Over:
	rmb3	RFC_Flag							; ��λѭ����ɱ�־λ
	lda		R_Humidity
	beq		Humid_LowerThan20
	clc
	ror											; ѭ�����õ���ֵ����2��19(+20-1)
	clc
	adc		#19
	sta		R_Humidity							; ����ʵ��ʪ��ֵ
	rts
Humid_LowerThan20:
	lda		#20
	sta		R_Humidity
	rts




Humid_SearchLoop_Addr:							; �ӳ���ĵ�ַ��
	dw		Loop_Start-1
Temper_Humid_table:
	dw		L_0Degree_Humid-1
	dw		L_5Degree_Humid-1
	dw		L_10Degree_Humid-1
	dw		L_15Degree_Humid-1
	dw		L_20Degree_Humid-1
	dw		L_25Degree_Humid-1
	dw		L_30Degree_Humid-1
	dw		L_35Degree_Humid-1
	dw		L_40Degree_Humid-1
	dw		L_45Degree_Humid-1
	dw		L_50Degree_Humid-1

; ��׼��������9λ����ʪ�ȵ��裬�����ֵQh
L_RR_Div_RH:
	lda		#0
	sta		RR_Div_RH_H
	sta		RR_Div_RH_L
?Div_Juge:
	lda		RFC_StanderCount_H					; �Ƚϱ�׼�����ʪ�ȵ���Ĳ���ֵ��8λ
	cmp		RFC_HumiCount_H
	bcc		?Loop_Over							; ��8λRH>RRʱ��Ϊ������
	lda		RFC_HumiCount_H
	cmp		RFC_StanderCount_H
	bcc		?Div_Start	

	lda		RFC_StanderCount_M					; �Ƚϱ�׼�����ʪ�ȵ���Ĳ���ֵ��8λ
	cmp		RFC_HumiCount_M
	bcc		?Loop_Over							; ��8λRH>RRʱ��Ϊ������
	lda		RFC_HumiCount_M
	cmp		RFC_StanderCount_M
	bcc		?Div_Start							; ��8λRR>RH����û����

	lda		RFC_StanderCount_L					; ��8λ��ȵ�����£�����8λ
	cmp		RFC_HumiCount_L
	bcc		?Loop_Over							; ��8λRH>RR��Ҳ�ǳ�����
	beq		?Loop_Over							; ��ʱ��8λRR==0���򲻼�������˵����������ֱ�ӷ���
?Div_Start:
	sec
	lda		RFC_StanderCount_L					; RRѭ����RH
	sbc		RFC_HumiCount_L
	sta		RFC_StanderCount_L
	lda		RFC_StanderCount_M
	sbc		RFC_HumiCount_M
	sta		RFC_StanderCount_M
	lda		RFC_StanderCount_H
	sbc		RFC_HumiCount_H
	sta		RFC_StanderCount_H

	lda		RR_Div_RH_L
	clc
	adc		#1
	sta		RR_Div_RH_L
	lda		RR_Div_RH_H
	adc		#0
	sta		RR_Div_RH_H							; ������
	bra		?Div_Juge
?Loop_Over:
	rts


L_0Degree_Humid:
	ldx		R_Humidity
	lda		Humid_0Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_0Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_0Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_0Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_0Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_0Degree_Humid_NoOverFlow:
	rts

L_5Degree_Humid:
	ldx		R_Humidity
	lda		Humid_5Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_5Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_5Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_5Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_5Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_5Degree_Humid_NoOverFlow:
	rts

L_10Degree_Humid:
	ldx		R_Humidity
	lda		Humid_10Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_10Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_10Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_10Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_10Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_10Degree_Humid_NoOverFlow:
	rts

L_15Degree_Humid:
	ldx		R_Humidity
	lda		Humid_15Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_15Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_15Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_15Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_15Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_15Degree_Humid_NoOverFlow:
	rts

L_20Degree_Humid:
	ldx		R_Humidity
	lda		Humid_20Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_20Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_20Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_20Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_20Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_20Degree_Humid_NoOverFlow:
	rts

L_25Degree_Humid:
	ldx		R_Humidity
	lda		Humid_25Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_25Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_25Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_25Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_25Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_25Degree_Humid_NoOverFlow:
	rts

L_30Degree_Humid:
	ldx		R_Humidity
	lda		Humid_30Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_30Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_30Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_30Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_30Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_30Degree_Humid_NoOverFlow:
	rts

L_35Degree_Humid:
	ldx		R_Humidity
	lda		Humid_35Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_35Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_35Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_35Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_35Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_35Degree_Humid_NoOverFlow:
	rts

L_40Degree_Humid:
	ldx		R_Humidity
	lda		Humid_40Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_40Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_40Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_40Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_40Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_40Degree_Humid_NoOverFlow:
	rts

L_45Degree_Humid:
	ldx		R_Humidity
	lda		Humid_45Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_45Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_45Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_45Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_45Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_45Degree_Humid_NoOverFlow:
	rts

L_50Degree_Humid:
	ldx		R_Humidity
	lda		Humid_50Degree_Table,x
	sec
	sbc		RR_Div_RH_L
	inx
	lda		Humid_50Degree_Table,x
	sbc		RR_Div_RH_H
	bcs		L_50Degree_Humid_BackLoop
	smb3	RFC_Flag							; �������������˵��ѭ�����
	dex
	rts
L_50Degree_Humid_BackLoop:
	inx
	stx		R_Humidity							; ����ʪ��ֵ
	txa
	cmp		#151
	bcc		L_50Degree_Humid_NoOverFlow
	smb3	RFC_Flag							; ��ʪ��ֵ����95����ﵽ������̣�ֹͣ��������˳�
L_50Degree_Humid_NoOverFlow:
	rts


; ��׼�������ֵ����512
L_RR_Multi_512:
	lda		#9
	sta		P_Temp
RR_Multi_512_Loop:
	clc
	rol		RFC_StanderCount_L
	rol		RFC_StanderCount_M
	rol		RFC_StanderCount_H
	dec		P_Temp
	bne		RR_Multi_512_Loop
	rts




; X���̣�AΪ����
L_A_Mod_5:
	ldx		#0
L_A_Mod_5_Start:
	cmp		#5
	bcc		L_A_Mod_5_Over
	sec
	sbc		#5
	inx
	bra		L_A_Mod_5_Start
L_A_Mod_5_Over:
	rts
