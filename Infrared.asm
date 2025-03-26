IR_ReceiveHandle:
	lda		IR_ReceivePhase
	clc
	rol
	tax
	lda		Receive_Phase_Table+1,x
	pha
	lda		Receive_Phase_Table,x
	pha
	rts										; 根据当前收码阶段，跳转到对应的收码处理函数

Receive_Phase_Table:
	dw		IR_Receive_Phase_0-1
	dw		IR_Receive_Phase_1-1
	dw		IR_Receive_Phase_2-1
	dw		IR_Receive_Phase_3-1
	dw		IR_Receive_Phase_4-1



; 收码阶段0，空闲时运行，下降沿到来时开始收码
IR_Receive_Phase_0:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,IR_Turn2Phase1
	rts
IR_Turn2Phase1:
	lda		#1
	sta		IR_ReceivePhase					; 收码进入阶段1
	smb3	IR_Flag							; IR开始计数

	lda		#0
	sta		IR_Counter						; 初始化变量
	sta		T_Temp
	lda		#32
	sta		Code_Counter
	rts


; 收码阶段1，检测引导码/重复码的第一个电平时间是否合法
IR_Receive_Phase_1:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_FirstCode_Juge
	rts
?IR_FirstCode_Juge:
	lda		IR_Counter
	cmp		#60
	bcc		Phase1_Abort					; 终止收码
	lda		#80
	cmp		IR_Counter
	bcc		Phase1_Abort
	lda		#2
	sta		IR_ReceivePhase					; 收码进入阶段2
	lda		#0
	sta		IR_Counter
	rts
Phase1_Abort:
	bbs5	IR_Flag,?No_Mark
	smb0	IR_Test
	lda		IR_Counter
	sta		Counter_Bak
	lda		Code_Counter
	sta		Counter_Bak2
?No_Mark:
	jmp		Receive_Abort


; 收码阶段2，区分是引导码还是重复码
IR_Receive_Phase_2:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_FirstCode_Juge
	rts
?IR_FirstCode_Juge:
	lda		IR_Counter
	cmp		#30
	bcc		Phase2_NoGuid					; 非引导码
	lda		#38
	cmp		IR_Counter
	bcc		Phase2_NoGuid
	lda		#3
	sta		IR_ReceivePhase					; 收码进入阶段3
	lda		#0
	sta		IR_Counter
	rts
Phase2_NoGuid:
	lda		IR_Counter
	cmp		#14
	bcc		Phase2_Abort					; 也非重复码，终止收码
	lda		#20
	cmp		IR_Counter
	bcc		Phase2_Abort					; 也非重复码，终止收码
	inc		Repeat_Coutner					; 收到重复码则递增重复码计数
	rts
Phase2_Abort:
	bbs5	IR_Flag,?No_Mark
	smb1	IR_Test
	lda		IR_Counter
	sta		Counter_Bak
	lda		Code_Counter
	sta		Counter_Bak2
?No_Mark:
	jmp		Receive_Abort


; 收码阶段3，检测码元第一个电平时间是否合法
IR_Receive_Phase_3:
	IR_RISING_EDGE_JUGE
	bbs0	IR_Flag,?IR_FirstCode_Juge
	rts
?IR_FirstCode_Juge:
	lda		IR_Counter
	cmp		#2
	bcc		Phase3_Abort					; 终止收码
	lda		#6
	cmp		IR_Counter
	bcc		Phase3_Abort
	lda		#4
	sta		IR_ReceivePhase					; 收码进入阶段4
	lda		#0
	sta		IR_Counter
	rts
Phase3_Abort:
	bbs5	IR_Flag,?No_Mark
	smb2	IR_Test
	lda		IR_Counter
	sta		Counter_Bak
	lda		Code_Counter
	sta		Counter_Bak2
?No_Mark:
	jmp		Receive_Abort


; 收码阶段4，区分0码和1码，并入队缓冲区，同时判断接收是否完成
IR_Receive_Phase_4:
	IR_FALLING_EDGE_JUGE
	bbs1	IR_Flag,?IR_FirstCode_Juge
	rts
?IR_FirstCode_Juge:
	lda		IR_Counter
	cmp		#2
	bcc		Phase4_No0Code					; 非0码
	lda		#6
	cmp		IR_Counter
	bcc		Phase4_No0Code
	clc										; 入队0码
	jmp		Receive_AfterHandle				; 收码1bit的后处理
Phase4_No0Code:
	lda		IR_Counter
	cmp		#11
	bcc		Phase4_Abort					; 也非1码，终止收码
	lda		#15
	cmp		IR_Counter
	bcc		Phase4_Abort					; 也非1码，终止收码
	sec										; 入队1码
	jmp		Receive_AfterHandle				; 收码1bit的后处理
Phase4_Abort:
	bbs5	IR_Flag,?No_Mark
	smb3	IR_Test
	lda		IR_Counter
	sta		Counter_Bak
	lda		Code_Counter
	sta		Counter_Bak2
?No_Mark:
	jmp		Receive_Abort


Receive_Abort:
	lda		#0
	sta		IR_ReceivePhase
	sta		IR_Flag
	sta		ID_Code							; 清空解码缓冲区
	sta		D_Code
	sta		IA_Code
	sta		A_Code
	smb5	IR_Flag
	rts


; 收码1bit的后处理
Receive_AfterHandle:
	ror		ID_Code							; 将接收到的码元入队
	ror		D_Code
	ror		IA_Code
	ror		A_Code

	dec		Code_Counter
	beq		Receive_Complete				; 若已接收32个码，则收码完成
	lda		#3
	sta		IR_ReceivePhase					; 收码回到阶段3，接收下一个码
	lda		#0
	sta		IR_Counter
	rts
Receive_Complete:
	lda		#0
	sta		IR_ReceivePhase					; 收码阶段重置为阶段0
	lda		#%00000100						; 复位相关标志位并打开解码标志位
	sta		IR_Flag
	smb4	IR_Flag
	rts




; 根据红外接收的NEC码执行对应的功能函数
F_IR_Decode:
	bbs2	IR_Flag,IR_Decode_Start
	rts
IR_Decode_Start:
	rmb2	IR_Flag							; 每次收码完成后只解码1次
	ldx		#0
Compare_DCode_Loop:
	lda		Table_IR_KeyCode,x
	cmp		D_Code
	beq		IR_KeyHandle					; 比对接收的数据码和表格内容，进对应的按键功能
	inx
	cpx		#21
	bcc		Compare_DCode_Loop
	rts

; 跳转至对应功能函数
IR_KeyHandle:
	txa
	clc
	rol
	tax
	lda		IR_Func_JumpTable+1,x
	pha
	lda		IR_Func_JumpTable,x
	pha
	rts

IR_Func_JumpTable:
	dw		L_IR_Func_OnOff-1
	dw		L_IR_Func_12_24-1
	dw		L_IR_Func_Fun-1
	dw		L_IR_Func_Inc-1
	dw		L_IR_Func_Set-1
	dw		L_IR_Func_Dec-1
	dw		L_IR_Func_LightStaue-1
	dw		L_IR_Func_OK-1
	dw		L_IR_Func_CF-1
	dw		L_IR_Func_TimerUp-1
	dw		L_IR_Func_TimerDown-1
	dw		L_IR_Func_0-1
	dw		L_IR_Func_1-1
	dw		L_IR_Func_2-1
	dw		L_IR_Func_3-1
	dw		L_IR_Func_4-1
	dw		L_IR_Func_5-1
	dw		L_IR_Func_6-1
	dw		L_IR_Func_7-1
	dw		L_IR_Func_8-1
	dw		L_IR_Func_9-1


L_IR_Func_OnOff:
	lda		#0
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_12_24:
	lda		#1
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_Fun:
	lda		#2
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_Inc:
	lda		#3
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_Set:
	lda		#4
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_Dec:
	lda		#5
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_LightStaue:
	lda		#6
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_OK:
	lda		#7
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_CF:
	lda		#8
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_TimerUp:
	lda		#9
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_TimerDown:
	lda		#0
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_0:
	lda		#1
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_1:
	lda		#2
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_2:
	lda		#3
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_3:
	lda		#4
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_4:
	lda		#5
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_5:
	lda		#6
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_6:
	lda		#7
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_7:
	lda		#8
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_8:
	lda		#9
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


L_IR_Func_9:
	lda		#0
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	jsr		L_Send_DRAM
	rts


IR_Test_1:
	bbs4	IR_Flag,Receive_Complete_1
	rts
Receive_Complete_1:
	rmb4	IR_Flag

	ldx		#led_Month
	jsr		F_ClrSymbol
	ldx		#led_Date
	jsr		F_DisSymbol

	lda		A_Code
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot

	lda		IA_Code
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

	lda		D_Code
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d6
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d5
	jsr		L_Dis_7Bit_DigitDot

	lda		ID_Code
	jsr		L_A_DecToHex
	pha
	and		#$0f
	ldx		#led_d10
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d9
	jsr		L_Dis_7Bit_DigitDot

	jsr		L_Send_DRAM
	rts

IR_Test_2:
	lda		IR_Test
	bne		Receive_Abort_1
	rts
Receive_Abort_1:
	ldx		#led_Month
	jsr		F_DisSymbol

	bbr0	IR_Test,NoPhase1
	rmb0	IR_Test
	ldx		#led_MON1
	jsr		F_DisSymbol
	ldx		#led_TUE1
	jsr		F_ClrSymbol
	ldx		#led_WED1
	jsr		F_ClrSymbol
	ldx		#led_THU1
	jsr		F_ClrSymbol
	bra		Juge_Over
NoPhase1:
	bbr1	IR_Test,NoPhase2
	rmb1	IR_Test
	ldx		#led_MON1
	jsr		F_ClrSymbol
	ldx		#led_TUE1
	jsr		F_DisSymbol
	ldx		#led_WED1
	jsr		F_ClrSymbol
	ldx		#led_THU1
	jsr		F_ClrSymbol
	bra		Juge_Over
NoPhase2:
	bbr2	IR_Test,NoPhase3
	rmb2	IR_Test
	ldx		#led_MON1
	jsr		F_ClrSymbol
	ldx		#led_TUE1
	jsr		F_ClrSymbol
	ldx		#led_WED1
	jsr		F_DisSymbol
	ldx		#led_THU1
	jsr		F_ClrSymbol
	bra		Juge_Over
NoPhase3:
	rmb3	IR_Test
	ldx		#led_MON1
	jsr		F_ClrSymbol
	ldx		#led_TUE1
	jsr		F_ClrSymbol
	ldx		#led_WED1
	jsr		F_ClrSymbol
	ldx		#led_THU1
	jsr		F_DisSymbol
Juge_Over:

	lda		Counter_Bak
	jsr		L_A_DecToHex
	pha
	txa
	ldx		#led_d0
	jsr		L_Dis_7Bit_DigitDot
	pla
	pha
	and		#$0f
	ldx		#led_d2
	jsr		L_Dis_7Bit_DigitDot
	pla
	and		#$f0
	jsr		L_LSR_4Bit
	ldx		#led_d1
	jsr		L_Dis_7Bit_DigitDot

	;lda		#32
	;sec
	;sbc		Counter_Bak2
	;jsr		L_A_DecToHex
	;pha
	;and		#$0f
	;ldx		#led_d6
	;jsr		L_Dis_7Bit_DigitDot
	;pla
	;and		#$f0
	;jsr		L_LSR_4Bit
	;ldx		#led_d5
	;jsr		L_Dis_7Bit_DigitDot
	

	jsr		L_Send_DRAM
?Test_Over
	rts
