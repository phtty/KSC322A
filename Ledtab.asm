; LED显示，没有COM切换，只有SEG线
.MACRO	db_c_s	com,seg
		.byte	com*0+seg/8
.ENDMACRO

.MACRO	db_c_y	com,seg
		.byte	1.shl.(seg-seg/8*8)
.ENDMACRO

Led_byte:							;段码<==>SEG/COM表
led_table1:
led_d0	equ	$-led_table1
	db_c_s	0,68	; 0a
	db_c_s	0,67	; 0b
	db_c_s	0,75	; 0c
	db_c_s	0,77	; 0d
	db_c_s	0,74	; 0e
	db_c_s	0,70	; 0f
	db_c_s	0,73	; 0g

led_d1	equ	$-led_table1
	db_c_s	0,65	; 1a
	db_c_s	0,64	; 1b
	db_c_s	0,79	; 1c
	db_c_s	0,78	; 1d
	db_c_s	0,76	; 1e
	db_c_s	0,66	; 1f
	db_c_s	0,71	; 1g

led_d2	equ	$-led_table1
	db_c_s	0,61	; 2a
	db_c_s	0,59	; 2b
	db_c_s	0,52	; 2c
	db_c_s	0,49	; 2d
	db_c_s	0,51	; 2e
	db_c_s	0,62	; 2f
	db_c_s	0,56	; 2g

led_d3	equ	$-led_table1
	db_c_s	0,60	; 3a
	db_c_s	0,57	; 3b
	db_c_s	0,54	; 3c
	db_c_s	0,50	; 3d
	db_c_s	0,53	; 3e
	db_c_s	0,58	; 3f
	db_c_s	0,55	; 3g

led_d4	equ	$-led_table1
	db_c_s	0,46	; 4b
	db_c_s	0,47	; 4c

led_d5	equ	$-led_table1
	db_c_s	0,44	; 5a
	db_c_s	0,43	; 5b
	db_c_s	0,39	; 5c
	db_c_s	0,38	; 5d
	db_c_s	0,41	; 5e
	db_c_s	0,45	; 5f
	db_c_s	0,42	; 5g

led_d6	equ	$-led_table1
	db_c_s	0,36	; 6a
	db_c_s	0,34	; 6b
	db_c_s	0,33	; 6c
	db_c_s	0,32	; 6d
	db_c_s	0,37	; 6e
	db_c_s	0,40	; 6f
	db_c_s	0,35	; 6g

led_d7	equ	$-led_table1
	db_c_s	0,28	; 7a
	db_c_s	0,26	; 7b
	db_c_s	0,25	; 7c
	db_c_s	0,24	; 7d
	db_c_s	0,30	; 7e
	db_c_s	0,29	; 7f
	db_c_s	0,27	; 7g

led_d8	equ	$-led_table1
	db_c_s	0,5		; 8b
	db_c_s	0,3		; 8c
led_minus	equ	$-led_table1
	db_c_s	0,2		; 8g

led_d9	equ	$-led_table1
	db_c_s	0,12	; 9a
	db_c_s	0,11	; 9b
	db_c_s	0,10	; 9c
	db_c_s	0,6		; 9d
	db_c_s	0,4		; 9e
	db_c_s	0,7		; 9f
	db_c_s	0,9		; 9g

led_d10	equ	$-led_table1
	db_c_s	0,16	; 10a
	db_c_s	0,19	; 10b
	db_c_s	0,18	; 10c
	db_c_s	0,17	; 10d
	db_c_s	0,14	; 10e
	db_c_s	0,13	; 10f
	db_c_s	0,15	; 10g


led_dot:
led_week1	equ	$-led_table1
led_SUN1	equ	$-led_table1
	db_c_s	0,89	; SUN1
led_MON1	equ	$-led_table1
	db_c_s	0,95	; MON1
led_TUE1	equ	$-led_table1
	db_c_s	0,94	; TUE1
led_WED1	equ	$-led_table1
	db_c_s	0,93	; WED1
led_THU1	equ	$-led_table1
	db_c_s	0,92	; THU1
led_FRI1	equ	$-led_table1
	db_c_s	0,91	; FRI1
led_SAT1	equ	$-led_table1
	db_c_s	0,90	; SAT1

led_week2	equ	$-led_table1
led_SUN2	equ	$-led_table1
	db_c_s	0,88	; SUN2
led_MON2	equ	$-led_table1
	db_c_s	0,87	; MON2
led_TUE2	equ	$-led_table1
	db_c_s	0,86	; TUE2
led_WED2	equ	$-led_table1
	db_c_s	0,85	; WED2
led_THU2	equ	$-led_table1
	db_c_s	0,84	; THU2
led_FRI2	equ	$-led_table1
	db_c_s	0,83	; FRI2
led_SAT2	equ	$-led_table1
	db_c_s	0,82	; SAT2


led_Month	equ	$-led_table1
	db_c_s	0,31	; Month
led_Date	equ	$-led_table1
	db_c_s	0,23	; Date
led_PM		equ	$-led_table1
	db_c_s	0,69	; PM
led_AL1		equ	$-led_table1
	db_c_s	0,0		; AL1
led_AL2		equ	$-led_table1
	db_c_s	0,1		; AL2
led_COL1	equ	$-led_table1
	db_c_s	0,63	; COL1
led_COL2	equ	$-led_table1
	db_c_s	0,48	; COL2
led_TMPC	equ	$-led_table1
	db_c_s	0,22	; ℃
led_TMPF	equ	$-led_table1
	db_c_s	0,21	; ℉

;==========================================================
;==========================================================

Led_bit:
	db_c_y	0,68	; 0a
	db_c_y	0,67	; 0b
	db_c_y	0,75	; 0c
	db_c_y	0,77	; 0d
	db_c_y	0,74	; 0e
	db_c_y	0,70	; 0f
	db_c_y	0,73	; 0g

	db_c_y	0,65	; 1a
	db_c_y	0,64	; 1b
	db_c_y	0,79	; 1c
	db_c_y	0,78	; 1d
	db_c_y	0,76	; 1e
	db_c_y	0,66	; 1f
	db_c_y	0,71	; 1g

	db_c_y	0,61	; 2a
	db_c_y	0,59	; 2b
	db_c_y	0,52	; 2c
	db_c_y	0,49	; 2d
	db_c_y	0,51	; 2e
	db_c_y	0,62	; 2f
	db_c_y	0,56	; 2g

	db_c_y	0,60	; 3a
	db_c_y	0,57	; 3b
	db_c_y	0,54	; 3c
	db_c_y	0,50	; 3d
	db_c_y	0,53	; 3e
	db_c_y	0,58	; 3f
	db_c_y	0,55	; 3g

	db_c_y	0,46	; 4b
	db_c_y	0,47	; 4c

	db_c_y	0,44	; 5a
	db_c_y	0,43	; 5b
	db_c_y	0,39	; 5c
	db_c_y	0,38	; 5d
	db_c_y	0,41	; 5e
	db_c_y	0,45	; 5f
	db_c_y	0,42	; 5g

	db_c_y	0,36	; 6a
	db_c_y	0,34	; 6b
	db_c_y	0,33	; 6c
	db_c_y	0,32	; 6d
	db_c_y	0,37	; 6e
	db_c_y	0,40	; 6f
	db_c_y	0,35	; 6g

	db_c_y	0,28	; 7a
	db_c_y	0,26	; 7b
	db_c_y	0,25	; 7c
	db_c_y	0,24	; 7d
	db_c_y	0,30	; 7e
	db_c_y	0,29	; 7f
	db_c_y	0,27	; 7g

	db_c_y	0,5		; 8b
	db_c_y	0,3		; 8c
	db_c_y	0,2		; 8g

	db_c_y	0,12	; 9a
	db_c_y	0,11	; 9b
	db_c_y	0,10	; 9c
	db_c_y	0,6		; 9d
	db_c_y	0,4		; 9e
	db_c_y	0,7		; 9f
	db_c_y	0,9		; 9g

	db_c_y	0,16	; 10a
	db_c_y	0,19	; 10b
	db_c_y	0,18	; 10c
	db_c_y	0,17	; 10d
	db_c_y	0,14	; 10e
	db_c_y	0,13	; 10f
	db_c_y	0,15	; 10g


	db_c_y	0,89	; SUN1
	db_c_y	0,95	; MON1
	db_c_y	0,94	; TUE1
	db_c_y	0,93	; WED1
	db_c_y	0,92	; THU1
	db_c_y	0,91	; FRI1
	db_c_y	0,90	; SAT1

	db_c_y	0,88	; SUN2
	db_c_y	0,87	; MON2
	db_c_y	0,86	; TUE2
	db_c_y	0,85	; WED2
	db_c_y	0,84	; THU2
	db_c_y	0,83	; FRI2
	db_c_y	0,82	; SAT2

	db_c_y	0,31	; Month
	db_c_y	0,23	; Date
	db_c_y	0,69	; PM
	db_c_y	0,0		; AL1
	db_c_y	0,1		; AL2
	db_c_y	0,63	; COL1
	db_c_y	0,48	; COL2
	db_c_y	0,22	; ℃
	db_c_y	0,21	; ℉
