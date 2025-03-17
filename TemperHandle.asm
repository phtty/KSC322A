L_Temper_Handle:
	jsr		L_RT_Multi_256
	jsr		L_RT_Div_RR
	jsr		L_Search_TemperTable
	jsr		Temper_Compen
	sec
	lda		R_Temperature
	sbc		R_Temper_Comp
	sta		R_Temperature
	rts

; ͨ��Qt���ȷ����ǰ�¶�
L_Search_TemperTable:
	rmb2	RFC_Flag							; ��������¶ȱ�־λ
	ldx		#255								; ��ʼֵΪ255������ѭ�����+1�����Ϊ0
L_Sub_Temper:
	inx
	txa
	cmp		#61
	bcs		L_Temper_Overflow					; ���ڵ���50�����˳�ѭ��
	lda		RT_Div_RR_L
	sec
	sbc		Temperature_Table,x
	sta		RT_Div_RR_L
	lda		RT_Div_RR_H
	sbc		#0
	sta		RT_Div_RR_H
	bcs		L_Sub_Temper

L_Temper_Overflow:
	txa
	beq		Temper_LowerThan_M10				; -10�����²��ڱ��в���Ҫ�ݼ�1��
	dex
Temper_LowerThan_M10:
	stx		P_Temp
	txa
	sec
	sbc		#10
	bcs		L_Search_Over						; ����0��Ϊ����or0�¶�
	lda		#10									; �����¶ȵĴ���
	sec
	sbc		P_Temp
	smb2	RFC_Flag							; �����¶ȱ�־λ
L_Search_Over:
	sta		R_Temperature
	rts

; ������������8λ���Ա�׼���裬�����ֵQt������Ϊ-10~50��
L_RT_Div_RR:
	lda		#0
	sta		RT_Div_RR_H
	sta		RT_Div_RR_L
?Div_Juge:
	lda		RFC_TempCount_H
	cmp		RFC_StanderCount_H					; �Ƚ���������ͱ�׼����Ĳ���ֵ��8λ
	bcc		?Loop_Over
	lda		RFC_StanderCount_H
	cmp		RFC_TempCount_H
	bcc		?Div_Start

	lda		RFC_TempCount_M						; �Ƚ�����������8λ�ͱ�׼����Ĳ���ֵ��8λ
	cmp		RFC_StanderCount_M
	bcc		?Loop_Over							; ��׼���������������ʱ��Ϊ������
	lda		RFC_StanderCount_M
	cmp		RFC_TempCount_M
	bcc		?Div_Start							; RT<RR����һ��û����

	lda		RFC_TempCount_L						; ��8λ��ȵ�����£�����8λ
	cmp		RFC_StanderCount_L
	bcc		?Loop_Over							; ��8λRR<RT����ѭ��������
	beq		?Loop_Over							; ��ʱ��8λRT==0���򲻼�������˵����������ֱ�ӷ���
?Div_Start:
	sec
	lda		RFC_TempCount_L						; RTѭ����RR
	sbc		RFC_StanderCount_L
	sta		RFC_TempCount_L
	lda		RFC_TempCount_M
	sbc		RFC_StanderCount_M
	sta		RFC_TempCount_M
	lda		RFC_TempCount_H
	sbc		RFC_StanderCount_H
	sta		RFC_TempCount_H

	lda		RT_Div_RR_L
	clc
	adc		#1
	sta		RT_Div_RR_L
	lda		RT_Div_RR_H
	adc		#0
	sta		RT_Div_RR_H							; ������
	bra		?Div_Juge
?Loop_Over:
	rts

; �����������256
L_RT_Multi_256:
	lda		#8
	sta		P_Temp
RT_Multi_256_Loop:
	clc
	rol		RFC_TempCount_L
	rol		RFC_TempCount_M
	rol		RFC_TempCount_H
	dec		P_Temp
	bne		RT_Multi_256_Loop
	rts




; ����->���϶�ת��
F_C2F:
	lda		R_Temperature
	sta		P_Temp							; ��ʼ��һЩ����

	lda		#0
	sta		P_Temp+1

	clc
	rol		P_Temp							; ������λ����8
	rol		P_Temp+1
	clc
	rol		P_Temp							; ������λ����8
	rol		P_Temp+1
	clc
	rol		P_Temp							; ������λ����8
	rol		P_Temp+1


	lda		P_Temp
	clc
	adc		R_Temperature					; ������������ɳ�9
	sta		P_Temp
	lda		P_Temp+1
	adc		#0
	sta		P_Temp+1

	ldx		#0								; ʹ��X�Ĵ�����������
?Div_By_5_Loop:
	lda		P_Temp+1
	bne		?Div_By_5_Loop_Start			; �и�8λ��ʱ��ֱ�Ӽ�
	lda		P_Temp							; �޸�8λʱ�����жϵ�8λ�����
	cmp		#5
	bcc		?Loop_Over
?Div_By_5_Loop_Start:
	lda		P_Temp
	sec
	sbc		#5
	sta		P_Temp
	lda		P_Temp+1
	sbc		#0
	sta		P_Temp+1
	inx
	bra		?Div_By_5_Loop
?Loop_Over:
	stx		P_Temp							; �������5��ֵ
	bbs2	RFC_Flag,Minus_Temper
	txa
	clc
	adc		#32								; ���¶�ʱ��ֱ�Ӽ���32��Ϊ���϶Ƚ��
	sta		R_Temperature_F
	rts

Minus_Temper:								; �����¶ȵ����
	lda		#32
	sec
	sbc		P_Temp							; �����¶�����32-����ֵ
	sta		R_Temperature_F
	rts


; �¶Ȳ�������������7��~43��
Temper_Compen:
	lda		R_Temperature
	cmp		#7
	bcc		No_Compensation
	lda		R_Temperature
	cmp		#43
	bcc		Compensation_Trigger

No_Compensation:
	lda		#0
	sta		R_Temper_Comp					; ��ղ���ֵ�Ͳ���ʱ��
	sta		R_Temper_Comp_Time
	rts

; ͨ������ʱ����㲹��ֵ
Compensation_Trigger:
	ldx		#0
?Loop_Start:
	lda		R_Temper_Comp_Time
	sec
	sbc		CompensationLevel_Table,x		; ��ǰ����ʱ��ѭ�����ó������ȼ�
	bcc		?Loop_Over
	inx
	bra		?Loop_Start
?Loop_Over
	txa
	beq		Compensation_Juge
	clc
	adc		#1
Compensation_Juge:
	bbr0	PC_IO_Backup,LowLight_ADJ
	sta		R_Temper_Comp
	rts
LowLight_ADJ:
	clc
	ror
	sta		R_Temper_Comp
	rts


; ���ݸ�������Ϩ����������ʱ��
CompensationTime_CHG:
	lda		#18
	cmp		R_Temper_Comp_Time
	bcc		DecCompensation					; ����ʱ����������󲹳�ʱ����ֱ��ת�벹��ʱ��ݼ�

	bbs4	PD,DecCompensation				; Ϩ��״̬Ҳת�벹��ʱ��ݼ�
	lda		R_Temper_Comp_Time
	cmp		#18	
	bcs		CompensationTime_Overflow		; ������ʱ�����ڵ�����󲹳�ʱ�������������
	inc		R_Temper_Comp_Time
CompensationTime_Overflow:
	rts

DecCompensation:
	lda		R_Temper_Comp_Time
	beq		CompensationTime_Overflow		; ������ʱ������0�����������
	dec		R_Temper_Comp_Time
	rts


CompensationLevel_Table:
	.byte	2
	.byte	3
	.byte	4
	.byte	5
	.byte	10
	.byte	15
