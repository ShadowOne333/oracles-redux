; TODO: Finish labelling these
;
; Naming conventions:
; - PALH_TILESET: Palettes used by tilesets, should load bg palettes 2-7.
;                 May also load a sprite palette or two (ie. PALH_TILESET_BIGGORON)
; - PALH_BG:      Loads bg palettes only (not used for tilesets)
; - PALH_SPR:     Loads sprite palettes only
; - PALH:         If none of the above, could load both sprite & bg palettes (or not yet categorized)

.enum 0
	; Common palettes
	PALH_00:	db ; $00
	PALH_01:	db ; $01
	PALH_02:	db ; $02
	PALH_03:	db ; $03
	PALH_04:	db ; $04
	PALH_05:	db ; $05
	PALH_06:	db ; $06
	PALH_07:	db ; $07
	PALH_08:	db ; $08
	PALH_09:	db ; $09
	PALH_0a:	db ; $0a
	PALH_0b:	db ; $0b
	PALH_0c:	db ; $0c
	PALH_0d:	db ; $0d
	PALH_0e:	db ; $0e
	PALH_0f:	db ; $0f

.ifdef ROM_AGES

	PALH_TILESET_LYNNA_CITY:	db ; $10
	PALH_TILESET_LYNNA_VILLAGE:	db ; $11
	PALH_TILESET_FAIRIES_FOREST:	db ; $12
	PALH_TILESET_DEKU_FOREST:	db ; $13
	PALH_TILESET_CRESCENT_ISLAND_PRESENT:	db ; $14
	PALH_TILESET_CRESCENT_ISLAND_PAST:	db ; $15
	PALH_TILESET_SYMMETRY_CITY_RUINED:	db ; $16
	PALH_TILESET_SYMMETRY_CITY_PAST:	db ; $17
	PALH_TILESET_ROLLING_RIDGE_PRESENT:	db ; $18
	PALH_19:	db ; $19
	PALH_1a:	db ; $1a
	PALH_TILESET_ROLLING_RIDGE_PAST:	db ; $1b
	PALH_TILESET_EYEGLASS_LIBRARY_OUTSIDE_PRESENT:	db ; $1c
	PALH_TILESET_EYEGLASS_LIBRARY_OUTSIDE_PAST:	db ; $1d
	PALH_1e:	db ; $1e
	PALH_TILESET_SEA_OF_NO_RETURN:	db ; $1f
	PALH_20:	db ; $20
	PALH_21:	db ; $21
	PALH_TILESET_YOLL_GRAVEYARD:	db ; $22
	PALH_TILESET_YOLL_GRAVEYARD_ALTERNATE:	db ; $23
	PALH_TILESET_BLACK_TOWER_OUTSIDE_PRESENT:	db ; $24
	PALH_TILESET_BLACK_TOWER_OUTSIDE_PAST:	db ; $25
	PALH_TILESET_NUUN_HIGHLANDS:	db ; $26
	PALH_TILESET_AMBIS_PALACE_OUTSIDE:	db ; $27
	PALH_TILESET_TALUS_PEAKS_PRESENT:	db ; $28
	PALH_TILESET_TALUS_PEAKS_PAST:	db ; $29
	PALH_TILESET_TALUS_PEAKS_PAST_ALTERNATE:	db ; $2a
	PALH_TILESET_UNDERWATER_PRESENT:	db ; $2b
	PALH_TILESET_UNDERWATER_PAST:	db ; $2c
	PALH_TILESET_FOREST_OF_TIME:	db ; $2d
	PALH_TILESET_SYMMETRY_CITY_RESTORED:	db ; $2e
	PALH_TILESET_MERMAIDS_CAVE_PAST_ENTRANCE:	db ; $2f
	PALH_TILESET_MAKU_TREE:	db ; $30
	PALH_TILESET_MAKU_TREE_TOP:	db ; $31
	PALH_TILESET_JABU_JABU_OUTSIDE:	db ; $32
	PALH_TILESET_OVERWORLD_PAST_ALTERNATE:	db ; $33
	PALH_SEAWEED_CUT:	db ; $34
	PALH_35:	db ; $35
	PALH_36:	db ; $36
	PALH_37:	db ; $37
	PALH_38:	db ; $38
	PALH_39:	db ; $39
	PALH_3a:	db ; $3a
	PALH_3b:	db ; $3b
	PALH_3c:	db ; $3c
	PALH_3d:	db ; $3d
	PALH_3e:	db ; $3e
	PALH_3f:	db ; $3f
	PALH_TILESET_MAKU_PATH_PRESENT:	db ; $40
	PALH_TILESET_SPIRITS_GRAVE:	db ; $41
	PALH_TILESET_WING_DUNGEON:	db ; $42
	PALH_TILESET_MOONLIT_GROTTO:	db ; $43
	PALH_TILESET_SKULL_DUNGEON:	db ; $44
	PALH_TILESET_CROWN_DUNGEON:	db ; $45
	PALH_TILESET_MERMAIDS_CAVE_PRESENT:	db ; $46
	PALH_TILESET_JABU_JABUS_BELLY:	db ; $47
	PALH_TILESET_ANCIENT_TOMB:	db ; $48
	PALH_TILESET_BLACK_TOWER_TOP:	db ; $49
	PALH_TILESET_ROOM_OF_RITES:	db ; $4a
	PALH_TILESET_HEROS_CAVE:	db ; $4b
	PALH_TILESET_MERMAIDS_CAVE_PAST:	db ; $4c
	PALH_TILESET_MAKU_PATH_PAST:	db ; $4d
	PALH_4e:	db ; $4e
	PALH_4f:	db ; $4f
	PALH_TILESET_SIDESCROLL_MERMAIDS_CAVE_PRESENT:	db ; $50
	PALH_TILESET_SIDESCROLL_SPIRITS_GRAVE:	db ; $51
	PALH_TILESET_SIDESCROLL:	db ; $52
	PALH_TILESET_SIDESCROLL_SKULL_DUNGEON_CROWN_DUNGEON:	db ; $53
	PALH_TILESET_SIDESCROLL_JABU_JABUS_BELLY:	db ; $54
	PALH_TILESET_SIDESCROLL_ANCIENT_TOMB:	db ; $55
	PALH_TILESET_SIDESCROLL_MERMAIDS_CAVE_PAST:	db ; $56
	PALH_TILESET_SIDESCROLL_B:	db ; $57
	PALH_TILESET_SIDESCROLL_C:	db ; $58
	PALH_BLACK_TOWER_TOP_WITH_BUSHES:	db ; $59
	PALH_5a:	db ; $5a
	PALH_5b:	db ; $5b
	PALH_5c:	db ; $5c
	PALH_5d:	db ; $5d
	PALH_5e:	db ; $5e
	PALH_5f:	db ; $5f
	PALH_TILESET_BLACK_TOWER:	db ; $60
	PALH_TILESET_MERMAIDS_CAVE_PAST_UNDERWATER:	db ; $61
	PALH_TILESET_JABU_JABUS_BELLY_UNDERWATER:	db ; $62
	PALH_TILESET_ANCIENT_TOMB_BOSS:	db ; $63
	PALH_TILESET_ANCIENT_TOMB_UNDERWATER:	db ; $64
	PALH_TILESET_HEROS_CAVE_UNDERWATER:	db ; $65
	PALH_TILESET_HEROS_CAVE_WITH_BUSHES:	db ; $66
	PALH_TILESET_ROOM_OF_RITES_ICE:	db ; $67
	PALH_68:	db ; $68
	PALH_69:	db ; $69
	PALH_6a:	db ; $6a
	PALH_6b:	db ; $6b
	PALH_6c:	db ; $6c
	PALH_6d:	db ; $6d
	PALH_6e:	db ; $6e
	PALH_6f:	db ; $6f
	PALH_TILESET_INDOORS_PRESENT:	db ; $70
	PALH_TILESET_OLD_MAN_CAVE_PRESENT:	db ; $71
	PALH_TILESET_INDOORS_PAST:	db ; $72
	PALH_TILESET_CAVE:	db ; $73
	PALH_TILESET_AMBIS_PALACE:	db ; $74
	PALH_TILESET_MOBLIN_FORTRESS:	db ; $75
	PALH_TILESET_ZORA_PALACE:	db ; $76
	PALH_TILESET_MAKU_TREE_INSIDE:	db ; $77
	PALH_TILESET_ROLLING_RIDGE_CAVE_PRESENT:	db ; $78
	PALH_TILESET_UNDERWATER_CAVE:	db ; $79
	PALH_7a:	db ; $7a
	PALH_7b:	db ; $7b
	PALH_7c:	db ; $7c
	PALH_7d:	db ; $7d
	PALH_7e:	db ; $7e
	PALH_SPR_LINK_STONE:	db ; $7f
	PALH_80:	db ; $80
	PALH_81:	db ; $81
	PALH_82:	db ; $82
	PALH_83:	db ; $83
	PALH_84:	db ; $84
	PALH_85:	db ; $85
	PALH_86:	db ; $86
	PALH_87:	db ; $87
	PALH_88:	db ; $88
	PALH_89:	db ; $89
	PALH_8a:	db ; $8a
	PALH_8b:	db ; $8b
	PALH_8c:	db ; $8c
	PALH_8d:	db ; $8d
	PALH_8e:	db ; $8e
	PALH_8f:	db ; $8f
	PALH_90:	db ; $90
	PALH_91:	db ; $91
	PALH_92:	db ; $92
	PALH_93:	db ; $93
	PALH_94:	db ; $94
	PALH_95:	db ; $95
	PALH_96:	db ; $96
	PALH_97:	db ; $97
	PALH_98:	db ; $98
	PALH_99:	db ; $99
	PALH_9a:	db ; $9a
	PALH_9b:	db ; $9b
	PALH_9c:	db ; $9c
	PALH_9d:	db ; $9d
	PALH_9e:	db ; $9e
	PALH_9f:	db ; $9f
	PALH_a0:	db ; $a0
	PALH_a1:	db ; $a1
	PALH_a2:	db ; $a2
	PALH_a3:	db ; $a3
	PALH_a4:	db ; $a4
	PALH_a5:	db ; $a5
	PALH_a6:	db ; $a6
	PALH_a7:	db ; $a7
	PALH_SECRET_LIST_MENU:	db ; $a8
	PALH_a9:	db ; $a9
	PALH_aa:	db ; $aa
	PALH_ab:	db ; $ab
	PALH_ac:	db ; $ac
	PALH_ad:	db ; $ad
	PALH_ae:	db ; $ae
	PALH_af:	db ; $af
	PALH_b0:	db ; $b0
	PALH_b1:	db ; $b1
	PALH_b2:	db ; $b2
	PALH_b3:	db ; $b3
	PALH_b4:	db ; $b4
	PALH_b5:	db ; $b5
	PALH_b6:	db ; $b6
	PALH_b7:	db ; $b7
	PALH_b8:	db ; $b8
	PALH_b9:	db ; $b9
	PALH_ba:	db ; $ba
	PALH_bb:	db ; $bb
	PALH_bc:	db ; $bc
	PALH_bd:	db ; $bd
	PALH_be:	db ; $be
	PALH_bf:	db ; $bf
	PALH_c0:	db ; $c0
	PALH_c1:	db ; $c1
	PALH_c2:	db ; $c2
	PALH_c3:	db ; $c3
	PALH_c4:	db ; $c4
	PALH_c5:	db ; $c5
	PALH_c6:	db ; $c6
	PALH_c7:	db ; $c7
	PALH_c8:	db ; $c8
	PALH_c9:	db ; $c9
	PALH_ca:	db ; $ca

.else; ROM_SEASONS

	PALH_TILESET_OVERWORLD_SPRING_A:	db ; $10
	PALH_TILESET_OVERWORLD_SUMMER_A:	db ; $11
	PALH_TILESET_OVERWORLD_AUTUMN_A:	db ; $12
	PALH_TILESET_OVERWORLD_WINTER_A:	db ; $13
	PALH_TILESET_OVERWORLD_SPRING_B:	db ; $14
	PALH_TILESET_OVERWORLD_SUMMER_B:	db ; $15
	PALH_TILESET_OVERWORLD_AUTUMN_B:	db ; $16
	PALH_TILESET_OVERWORLD_WINTER_B:	db ; $17
	PALH_TILESET_OVERWORLD_SPRING_C:	db ; $18
	PALH_TILESET_OVERWORLD_SUMMER_C:	db ; $19
	PALH_TILESET_OVERWORLD_AUTUMN_C:	db ; $1a
	PALH_TILESET_OVERWORLD_WINTER_C:	db ; $1b
	PALH_TILESET_SUNKEN_CITY_UNUSED_SPRING:	db ; $1c
	PALH_TILESET_SUNKEN_CITY_UNUSED_SUMMER:	db ; $1d
	PALH_TILESET_SUNKEN_CITY_UNUSED_AUTUMN:	db ; $1e
	PALH_TILESET_SUNKEN_CITY_UNUSED_WINTER:	db ; $1f
	PALH_TILESET_OVERWORLD_SPRING_D:	db ; $20
	PALH_TILESET_OVERWORLD_SUMMER_D:	db ; $21
	PALH_TILESET_OVERWORLD_AUTUMN_D:	db ; $22
	PALH_TILESET_OVERWORLD_WINTER_D:	db ; $23
	PALH_TILESET_TARM_RUINS_SPRING:	db ; $24
	PALH_TILESET_TARM_RUINS_SUMMER:	db ; $25
	PALH_TILESET_TARM_RUINS_AUTUMN:	db ; $26
	PALH_TILESET_TARM_RUINS_WINTER:	db ; $27
	PALH_TILESET_ANCIENT_RUINS_ENTRANCE_SPRING:	db ; $28
	PALH_TILESET_ANCIENT_RUINS_ENTRANCE_SUMMER:	db ; $29
	PALH_TILESET_ANCIENT_RUINS_ENTRANCE_AUTUMN:	db ; $2a
	PALH_TILESET_ANCIENT_RUINS_ENTRANCE_WINTER:	db ; $2b
	PALH_TILESET_GRAVEYARD_SPRING:	db ; $2c
	PALH_TILESET_GRAVEYARD_SUMMER:	db ; $2d
	PALH_TILESET_GRAVEYARD_AUTUMN:	db ; $2e
	PALH_TILESET_GRAVEYARD_WINTER:	db ; $2f
	PALH_TILESET_TEMPLE_REMAINS_SPRING_A:	db ; $30
	PALH_TILESET_TEMPLE_REMAINS_SUMMER_A:	db ; $31
	PALH_TILESET_TEMPLE_REMAINS_AUTUMN_A:	db ; $32
	PALH_TILESET_TEMPLE_REMAINS_WINTER_A:	db ; $33
	PALH_TILESET_TEMPLE_REMAINS_SPRING_B:	db ; $34
	PALH_TILESET_TEMPLE_REMAINS_SUMMER_B:	db ; $35
	PALH_TILESET_TEMPLE_REMAINS_AUTUMN_B:	db ; $36
	PALH_TILESET_TEMPLE_REMAINS_WINTER_B:	db ; $37
	PALH_TILESET_ONOX_CASTLE_OUTSIDE_SPRING:	db ; $38
	PALH_TILESET_ONOX_CASTLE_OUTSIDE_SUMMER:	db ; $39
	PALH_TILESET_ONOX_CASTLE_OUTSIDE_AUTUMN:	db ; $3a
	PALH_TILESET_ONOX_CASTLE_OUTSIDE_WINTER:	db ; $3b
	PALH_TILESET_SIDESCROLL_HEROS_CAVE:	db ; $3c
	PALH_TILESET_SIDESCROLL_GNARLED_ROOT_DUNGEON:	db ; $3d
	PALH_TILESET_SIDESCROLL_POISON_MOTHS_LAIR:	db ; $3e
	PALH_SECRET_LIST_MENU:	db ; $3f
	PALH_TILESET_HEROS_CAVE:	db ; $40
	PALH_TILESET_GNARLED_ROOT_DUNGEON:	db ; $41
	PALH_TILESET_SNAKES_REMAINS:	db ; $42
	PALH_TILESET_POISON_MOTHS_LAIR:	db ; $43
	PALH_TILESET_DANCING_DRAGON_DUNGEON:	db ; $44
	PALH_TILESET_UNICORNS_CAVE:	db ; $45
	PALH_TILESET_ANCIENT_RUINS:	db ; $46
	PALH_TILESET_EXPLORERS_CRYPT_A:	db ; $47
	PALH_TILESET_SWORD_AND_SHIELD_MAZE_ICE:	db ; $48
	PALH_TILESET_ONOX_CASTLE:	db ; $49
	PALH_TILESET_ROOM_OF_RITES:	db ; $4a
	PALH_4b:	db ; $4b
	PALH_4c:	db ; $4c
	PALH_TILESET_EXPLORERS_CRYPT_B:	db ; $4d
	PALH_TILESET_SWORD_AND_SHIELD_MAZE_FIRE:	db ; $4e
	PALH_TILESET_SWORD_AND_SHIELD_MAZE_FIRE_MINIBOSS:	db ; $4f
	PALH_TILESET_MAKU_TREE:	db ; $50
	PALH_TILESET_MAKU_TREE_SMALL:	db ; $51
	PALH_SPR_MAKU_TREE:	db ; $52
	PALH_53:	db ; $53
	PALH_TILESET_BIGGORON:	db ; $54
	PALH_SPR_ANCIENT_RUINS_ENTRANCE:	db ; $55
	PALH_TILESET_TARM_RUINS_PEDESTAL:	db ; $56
	PALH_57:	db ; $57
	PALH_TILESET_SUBROSIA_TEMPLE_OUTSIDE_WEST:	db ; $58
	PALH_TILESET_SUBROSIA_TEMPLE_OUTSIDE_EAST:	db ; $59
	PALH_TILESET_SUBROSIA_A:	db ; $5a
	PALH_TILESET_SUBROSIA_B:	db ; $5b
	PALH_TILESET_SUBROSIAN_SMITHY_OUTSIDE:	db ; $5c
	PALH_TILESET_SUBROSIA_C:	db ; $5d
	PALH_TILESET_SUBROSIA_BEACH:	db ; $5e
	PALH_TILESET_SUBROSIA_TEMPLE_VARIANT_UNUSED:	db ; $5f
	PALH_TILESET_TEMPLE_SPRING:	db ; $60
	PALH_TILESET_TEMPLE_SUMMER:	db ; $61
	PALH_TILESET_TEMPLE_AUTUMN:	db ; $62
	PALH_TILESET_TEMPLE_WINTER:	db ; $63
	PALH_TILESET_NATZU_PRAIRIE:	db ; $64
	PALH_TILESET_NATZU_RIVER:	db ; $65
	PALH_TILESET_NATZU_WASTELAND:	db ; $66
	PALH_67:	db ; $67
	PALH_TILESET_SIDESCROLL_SNAKES_REMAINS:	db ; $68
	PALH_TILESET_SIDESCROLL_DANCING_DRAGON_DUNGEON:	db ; $69
	PALH_TILESET_SIDESCROLL_UNICORNS_CAVE:	db ; $6a
	PALH_TILESET_SIDESCROLL_SWORD_AND_SHIELD_MAZE_ICE:	db ; $6b
	PALH_TILESET_SIDESCROLL_SWORD_AND_SHIELD_MAZE_FIRE:	db ; $6c
	PALH_TILESET_SIDESCROLL_UNUSED:	db ; $6d
	PALH_TILESET_SIDESCROLL_UNDERWATER:	db ; $6e
	PALH_TILESET_SIDESCROLL_SUBROSIA:	db ; $6f
	PALH_TILESET_INDOORS_A:	db ; $70
	PALH_TILESET_INDOORS_B:	db ; $71
	PALH_TILESET_SUBROSIA_FURNACE:	db ; $72
	PALH_TILESET_OLD_MAN_CAVE:	db ; $73
	PALH_TILESET_MOBLIN_HOUSE:	db ; $74
	PALH_TILESET_SUBROSIA_BOOMERANG_ROOM:	db ; $75
	PALH_TILESET_VASE_HOUSE:	db ; $76
	PALH_TILESET_CAVE:	db ; $77
	PALH_TILESET_SUBROSIA_CAVE:	db ; $78
	PALH_TILESET_MAKU_TREE_INSIDE:	db ; $79
	PALH_TILESET_MOBLIN_KEEP:	db ; $7a
	PALH_TILESET_TEMPLE_OF_SEASONS:	db ; $7b
	PALH_TILESET_SUBROSIA_INDOORS:	db ; $7c
	PALH_7d:	db ; $7d
	PALH_7e:	db ; $7e
	PALH_SPR_LINK_STONE:	db ; $7f
	PALH_SPR_AQUAMENTUS:	db ; $80
	SEASONS_PALH_81:	db ; $81
	SEASONS_PALH_82:	db ; $82
	SEASONS_PALH_83:	db ; $83
	SEASONS_PALH_84:	db ; $84
	SEASONS_PALH_85:	db ; $85
	SEASONS_PALH_86:	db ; $86
	SEASONS_PALH_87:	db ; $87
	SEASONS_PALH_88:	db ; $88
	SEASONS_PALH_89:	db ; $89
	SEASONS_PALH_8a:	db ; $8a
	SEASONS_PALH_8b:	db ; $8b
	SEASONS_PALH_8c:	db ; $8c
	PALH_BG_DRAGON_ONOX:	db ; $8d
	PALH_TILESET_ROOM_OF_RITES_ICE:	db ; $8e
	SEASONS_PALH_8f:	db ; $8f
	SEASONS_PALH_90:	db ; $90
	SEASONS_PALH_91:	db ; $91
	SEASONS_PALH_92:	db ; $92
	SEASONS_PALH_93:	db ; $93
	SEASONS_PALH_94:	db ; $94
	SEASONS_PALH_95:	db ; $95
	SEASONS_PALH_96:	db ; $96
	SEASONS_PALH_97:	db ; $97
	SEASONS_PALH_98:	db ; $98
	SEASONS_PALH_99:	db ; $99
	SEASONS_PALH_9a:	db ; $9a
	SEASONS_PALH_9b:	db ; $9b
	SEASONS_PALH_9c:	db ; $9c
	SEASONS_PALH_9d:	db ; $9d
	SEASONS_PALH_9e:	db ; $9e
	SEASONS_PALH_9f:	db ; $9f
	SEASONS_PALH_a0:	db ; $a0
	SEASONS_PALH_a1:	db ; $a1
	SEASONS_PALH_a2:	db ; $a2
	SEASONS_PALH_a3:	db ; $a3
	SEASONS_PALH_a4:	db ; $a4
	SEASONS_PALH_a5:	db ; $a5
	SEASONS_PALH_a6:	db ; $a6
	SEASONS_PALH_a7:	db ; $a7
	SEASONS_PALH_a8:	db ; $a8
	SEASONS_PALH_a9:	db ; $a9
	SEASONS_PALH_aa:	db ; $aa
	SEASONS_PALH_ab:	db ; $ab
	PALH_ac:	db ; $ac (Confirmed the same as ages's PALH_ac; maybe others are the same too)
	SEASONS_PALH_ad:	db ; $ad
	SEASONS_PALH_ae:	db ; $ae
	SEASONS_PALH_af:	db ; $af
	SEASONS_PALH_b0:	db ; $b0
	SEASONS_PALH_b1:	db ; $b1
	SEASONS_PALH_b2:	db ; $b2
	SEASONS_PALH_b3:	db ; $b3
	SEASONS_PALH_b4:	db ; $b4
	SEASONS_PALH_b5:	db ; $b5
	SEASONS_PALH_b6:	db ; $b6
	SEASONS_PALH_b7:	db ; $b7
	SEASONS_PALH_b8:	db ; $b8
	SEASONS_PALH_b9:	db ; $b9
	SEASONS_PALH_ba:	db ; $ba
	SEASONS_PALH_bb:	db ; $bb
	SEASONS_PALH_bc:	db ; $bc
	SEASONS_PALH_bd:	db ; $bd

.endif

.ende
