F_PowerSavingMode:
	lda		PC
	and		#$20
	beq		L_Low_Power								; �ж�ʡ��ģʽ�������
	rts

L_Low_Power:
	jsr		Enter_LowPower							; �رպĵ���Դ
PS_Mode_Loop:
	smb4	SYSCLK
	sta		HALT									; ����
	rmb4	SYSCLK
	jsr		F_Time_Run								; �����ģʽ��ֻ����S�ж�������ʱ
	lda		PC
	and		#$20
	beq		PS_Mode_Loop							; ��DC�����޸ߵ�ƽ����ʡ��ģʽѭ��

	jsr		Exit_LowPower							; ����ѭ��ʹ�õ�������Դ
	rts

Enter_LowPower:
	rts

Exit_LowPower:
	rts
