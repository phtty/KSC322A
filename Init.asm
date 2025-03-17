F_Init_SystemRam:								; ϵͳ�ڴ��ʼ��
	lda		#0001B
	sta		Sys_Status_Flag

	lda		#12
	sta		R_Time_Hour
	;lda		#00
	;sta		R_Time_Min
	;lda		#00
	;sta		R_Time_Sec

	lda		#12
	sta		R_Alarm1_Hour
	;lda		#00
	;sta		R_Alarm1_Min

	lda		#12
	sta		R_Alarm2_Hour
	;lda		#00
	;sta		R_Alarm2_Min

	lda		#12
	sta		R_Alarm3_Hour
	;lda		#00
	;sta		R_Alarm3_Min

	lda		#01
	sta		R_Date_Day
	lda		#01
	sta		R_Date_Month
	lda		#24
	sta		R_Date_Year
	;lda		#00
	;sta		R_Date_Week

	lda		#29
	sta		Count_RFC

	rts


F_Beep_Init:
	lda		#C_T000_Fsub
	sta		PADF1
	rmb0	TMCLK								; TIM0ѡ��ʱ��ԴΪFsub
	rmb1	TMCLK

	lda		#256-8								; ����TIM0Ƶ��Ϊ2048Hz
	sta		TMR0

	rmb3	PB_TYPE								; PB3ѡ��NMOS���0����©��

	rmb1	PADF0								; PB3 PWM������ƣ���ʼ�������
	rmb3	PADF0								; ����PB3��PWM���ģʽ��Ƶ��ΪTIM0/2
	smb4	PADF0

	rts


F_Port_Init:
	lda		#$1c								; PA5����Ҫ����
	sta		PA_WAKE
	lda		#$1c
	sta		PA_DIR
	lda		#$1c
	sta		PA
	smb4	IER									; ��PA���ⲿ�ж�

	lda		#$0
	sta		PC_DIR								; PC����Ϊ���
	lda		#$0
	sta		PC

	lda		PB
	and		#$b7
	sta		PB

	lda		#$07
	sta		PD_DIR								; PD0-3����Ϊ��̬���룬����Ϊ���
	lda		#$00
	sta		PD
	sta		PD_SEG								; PD��ȫ����IO��ʹ��

	lda		#C_PB2S								; PB2��PP�������
	sta		PADF0

	rts


F_Timer_Init:
	rmb1	IER									; ��TMR0��1��ʱ���ж�
	rmb1	IFR									; ���TMR0��1�жϱ�־λ
	rmb2	IER
	rmb2	IFR
	rmb0	TMRC								; �ر�TMR0
	rmb1	TMRC								; �ر�TMR1

	lda		#C_TMR1_Fsub_64+C_TMR0_Fsub			; TIM0ʱ��ԴT000
	sta		TMCLK								; TIM1ʱ��ԴFsub/64(512Hz)
	lda		#C_T000_Fsub
	sta		PADF1								; T000ѡ��ΪFsub

	; TIM2ʱ��ԴDIV,Fsub 64��Ƶ512Hz���رն�ʱ��ͬ��
	lda		#C_Asynchronous+C_DIVC_Fsub_64
	sta		DIVC								; �رն�ʱ��ͬ����DIVʱ��ԴΪFsub/64(512Hz)

	lda		#256-8								; ����TIM0Ƶ��Ϊ4096Hz
	sta		TMR0
	lda		#$0
	sta		TMR2

	lda		#$256-32							; 16Hzһ���ж�
	sta		TMR1

	lda		IER									; ����ʱ���ж�
	ora		#C_TMR0I+C_TMR1I+C_TMR2I+C_LCDI
	sta		IER

	lda		#C_TMR2ON
	sta		TMRC								; ��ʼ��ֻ��TIM2������ʱ

	lda		#C_COM_2_42_38+C_LCDIS_Rate
	sta		LCD_COM								; ��LCD�ж����ڶ�ʱ��ʾLED
	lda		#$02
	sta		FRAME

	rts



F_Timer_NormalMode:
	rmb1	IER									; ��TMR0��1��ʱ���ж�
	rmb1	IFR									; ���TMR0��1�жϱ�־λ
	rmb2	IER
	rmb2	IFR
	lda		TMRC
	pha
	rmb0	TMRC								; �ر�TMR0
	rmb1	TMRC								; �ر�TMR1
	lda		#C_TMR1_Fsub_64+C_TMR0_Fsub			; TIM0ʱ��ԴT000
	sta		TMCLK								; TIM1ʱ��ԴFsub/64(512Hz)
	lda		#C_T000_Fsub
	sta		PADF1								; T000ѡ��ΪFsub
	lda		#C_Asynchronous+C_DIVC_Fsub_64
	sta		DIVC								; �رն�ʱ��ͬ����ѡ��DIVʱ��ԴΪFsub/64(512Hz)

	lda		#256-8								; ����TIM0Ƶ��Ϊ4096Hz
	sta		TMR0
	lda		#256-32								; ����TIM1Ƶ��Ϊ16Hz
	sta		TMR1

	pla
	sta		TMRC

	rmb0	IER									; �ر�DIV�ж�
	smb1	IER									; ��TIM0��1��ʱ���ж�
	smb2	IER

	rmb0	RFC_Flag							; ������������б�־λ
	rmb3	RFC_Flag
	rmb6	RFC_Flag

	rts




F_RFC_Init:
	lda		#$0f
	sta		PD_DIR								; PD0-4����Ϊ��̬���룬����Ϊ���
	lda		#$0
	sta		PD

	rmb6	PC_SEG

	lda		RFCC0								; PD0-3����ΪRFC����
	ora		#$0f
	sta		RFCC0

	lda		#$00
	sta		RFCC1								; �ر�RFC��������
	sta		PD_SEG								; PD��ȫ����IO��ʹ��

	rts


F_KeyMatrix_PC4Scan_Ready:
	;rmb4	IER									; �ر�PA���жϣ������󴥷��ж�

	rmb4	PC
	smb5	PC
	rmb4	IFR									; ��λ��־λ,�����жϿ���ʱֱ�ӽ����жϷ���
	jsr		L_KeyDelay
	rts

F_KeyMatrix_PC5Scan_Ready:
	;rmb4	IER									; �ر�PA���жϣ������󴥷��ж�

	smb4	PC
	rmb5	PC
	rmb4	IFR									; ��λ��־λ,�����жϿ���ʱֱ�ӽ����жϷ���
	jsr		L_KeyDelay
	rts

F_KeyMatrix_Reset:
	bbs3	Timer_Flag,L_QuikAdd_ScanReset
F_QuikAdd_Scan:
	rmb4	PC
	rmb5	PC
	rts
L_QuikAdd_ScanReset:							; �г���ʱPC4,PC5����ߣ����ⳤ��ʱ©��
	smb4	PC
	smb5	PC									; ����²���Ҫ�����жϣ���ʱɨ��IO�ڼ���
	rts
