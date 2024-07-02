; 2 lists per entry, each ending with $00:
; * The first is a list of tiles which produce an alternate "clinking" sound indicating
; they're bombable.
; * The second is a list of tiles which don't produce clinks at all.

clinkSoundTable:
	.dw @collisions0
	.dw @collisions1
	.dw @collisions2
	.dw @collisions3
	.dw @collisions4
	.dw @collisions5

@collisions0:
@collisions4:
	.db $c1 $c2 $c4 $d1 $cf
	.db $00

	.db $fd $fe $ff
	.db $00
	.db $00

@collisions1:
@collisions2:
@collisions5:
	.db $1f $30 $31 $32 $33 $38 $39 $3a $3b $68 $69
	.db $00

	.db $0a $0b
	.db $00

@collisions3:
	.db $12
	.db $00

	.db $00
