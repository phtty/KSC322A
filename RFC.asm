F_RFC_MeasureManage:
	bbs1	RFC_Flag,L_RFC_Exit					; �������ֺͰ�������ʱ��TIM0��1��ռ�ã������в���
	bbs4	Key_Flag,L_RFC_Exit
	bbs0	Key_Flag,L_RFC_Exit					; ��������ʱ�������в���

	bbr6	RFC_Flag,RFC_NoComplete
	rmb6	RFC_Flag
	jsr		F_RFC_MeasureStop					; ������ɣ�ֹͣ����DIV�жϣ��ر�RFC��������
RFC_NoComplete:
	bbr5	RFC_Flag,L_RFC_Exit					; 1S��־������30S
	rmb5	RFC_Flag
	lda		Count_RFC
	cmp		#30
	bcs		F_RFC_MeasureStart
	inc		Count_RFC
	rts
F_RFC_MeasureStart:
	lda		#0
	sta		Count_RFC							; ��30S�󣬲��ټ�������ʼ����
	sta		RFC_ChannelCount					; ������ʼ�����ͨ������

	smb0	RFC_Flag
	rmb0	IFR									; ���DIV�жϱ�־λ
	smb0	IER									; ��DIV�ж�

L_RFC_Exit:
	rts




F_RFC_Channel_Select:
	jsr		F_RFC_TimerReset					; ��ʼ��RFC������ʱ��״̬

	lda		TMRC								; T0I����ΪFrcx
	ora		#C_T0I_1
	sta		TMRC
	lda		#C_TMR0_T0I+C_TMR1_TMR0				; ����TM0ʱ��ԴΪT0I,TM1ʱ��ԴΪTM0,����TM0��TM1
	sta		TMCLK

	lda		#C_SyncWithDIV+C_DIVC_Fsub_64
	sta		DIVC								; ������ʱ��ͬ����DIVʱ��ԴΪFsub/64(512Hz)

	smb0	TMRC								; ����TMR0
	smb1	TMRC								; ����TMR1

	ldx		RFC_ChannelCount
	lda		T_RFC_Channel,x
	sta		RFCC1

	rts




L_Get_RFC_Data:
	lda		RFC_ChannelCount
	bne		L_NoHumi
	lda		TMR0								; PD3��ȡ��ʪ�ȼ���ֵ
	sta		RFC_HumiCount_L
	lda		TMR1
	sta		RFC_HumiCount_M
	bra		L_Sample_Over
L_NoHumi:
	lda		RFC_ChannelCount
	cmp		#01									; PD2��ȡ���¶ȼ���ֵ
	bne		L_NoTemp
	lda		TMR0
	sta		RFC_TempCount_L
	lda		TMR1
	sta		RFC_TempCount_M
	bra		L_Sample_Over
L_NoTemp:
	lda		RFC_ChannelCount
	cmp		#02									; PD1��ȡ�ñ�׼�������ֵ
	bne		L_Sample_Over
	lda		TMR0
	sta		RFC_StanderCount_L
	lda		TMR1
	sta		RFC_StanderCount_M
	smb6	RFC_Flag							; ������ɣ�׼������
L_Sample_Over:
	lda		#0
	sta		RFCC1								; ��ǰͨ��������ɣ��ر�RFC
	inc		RFC_ChannelCount

F_RFC_TimerReset:								; �ȴ���һͨ��������ʼ�����ö�ʱ��״̬
	rmb1	IER									; ��TMR0��1��ʱ���ж�
	rmb1	IFR									; ���TMR0��1�жϱ�־λ
	rmb2	IER
	rmb2	IFR
	rmb0	TMRC								; �ر�TMR0
	rmb1	TMRC								; �ر�TMR1
	lda		#$0									; ��0��ʱ��ֵ
	sta		TMR0
	sta		TMR1
	rts




F_RFC_MeasureStop:
	jsr		F_Timer_NormalMode					; ��ʱ������Ϊ����ͳ���״̬,�رն�ʱ��ͬ��

	jsr		L_Temper_Handle
	jsr		L_Humid_Handle
	jsr		F_Display_Temper					; ���ݴ������ʾ�¶Ⱥ�ʪ��
	jsr		F_Display_Humid

L_CLR_RFC:
	lda		#0
	sta		RFC_TempCount_H						; ������ر���
	sta		RFC_TempCount_M
	sta		RFC_TempCount_L
	sta		RFC_HumiCount_H
	sta		RFC_HumiCount_M
	sta		RFC_HumiCount_L
	sta		RFC_StanderCount_H
	sta		RFC_StanderCount_M
	sta		RFC_StanderCount_L

	rts



; RFC���������,ͨ������������Ҫ��ʱ���Ĺ��ܵ���
; ��ʱ��Ҫ����RFC����ֱ���˹��ܽ���
F_RFC_Abort:
	smb1	RFC_Flag							; ����RFC����
	jsr		F_Timer_NormalMode					; ��ʱ������Ϊ����ͳ���״̬,�رն�ʱ��ͬ��

	jsr		L_CLR_RFC
	sta		RFC_ChannelCount					; ����ͨ������

	rts




T_RFC_Channel:
	db		$20	; CTRT0	PD3
	db		$10	; RS0	PD2
	db		$60	; CSRT0	PD1
