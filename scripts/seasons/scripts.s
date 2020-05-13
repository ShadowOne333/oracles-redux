; Scripts for interactions are in this file. You may want to cross-reference with the
; corresponding code for the script to get the full picture (search for INTERACID_X in
; main.s to find the code).

stubScript:
	scriptend

genericNpcScript:
	initcollisions
--
	checkabutton
	showloadedtext
	jump2byte --


; ==============================================================================
; INTERACID_FARORE
; ==============================================================================

faroreScript:
	jumptable_memoryaddress wIsLinkedGame
	.dw _faroreUnlinked
	.dw _faroreLinked

; When talking to farore in a completed unlinked game, you can tell her secrets, but all
; she'll do is direct you to the person you're supposed to tell them to.
_faroreUnlinked:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, @finishedGame
	rungenericnpclowindex <TX_5501

@finishedGame:
	initcollisions
@npcLoop:
	enableinput
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_5502
	jumpiftextoptioneq $00, @askForPassword

@offerOtherGameSecret:
	showtextlowindex <TX_5519
	jumpiftextoptioneq $00, @sayOtherGameSecret
	showtextlowindex <TX_5505
	jump2byte @npcLoop

@sayOtherGameSecret:
	asm15 scriptHlp.faroreGenerateGameTransferSecret
	showtextlowindex <TX_551a
	jump2byte @npcLoop

@askForPassword:
	askforsecret $ff
	asm15 scriptHlp.faroreCheckSecretValidity
	jumptable_objectbyte Interaction.var3f
	.dw @offerOtherGameSecret
	.dw @offerOtherGameSecret
	.dw @offerOtherGameSecret
	.dw @secretOK
	.dw @wrongGame
	.dw @offerOtherGameSecret

@wrongGame: ; A Seasons secret was given in Ages.
	showtextlowindex <TX_550b
	jump2byte @offerOtherGameSecret

@secretOK: ; The secret is fine, but you're supposed to tell it to someone else.
	asm15 scriptHlp.faroreShowTextForSecretHint
	wait 30
	showtextlowindex <TX_5504
	jump2byte @offerOtherGameSecret


; When talking to Farore in a linked game, you can tell her secrets and she'll respond by
; giving you an item if it's correct.
_faroreLinked:
	initcollisions
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_5506
	jump2byte ++
@npcLoop:
	enableinput
	checkabutton
	disableinput
	jumpifglobalflagset GLOBALFLAG_SECRET_CHEST_WAITING, @waitForLinkToOpenChest
++
	showtextlowindex <TX_5507 ; Do you know a secret?
	jumpiftextoptioneq $00, @showPasswordScreen
	showtextlowindex <TX_5508 ; Come back anytime
	jump2byte @npcLoop

@showPasswordScreen:
	askforsecret $ff
	asm15 scriptHlp.faroreCheckSecretValidity
	jumptable_objectbyte Interaction.var3f
	.dw @script4667
	.dw @secretOK
	.dw @alreadyToldSecret
	.dw @script4667
	.dw @wrongGame
	.dw @secretNotActive

@script4667:
	showtextlowindex <TX_5505
	jump2byte @npcLoop

@secretOK:
	asm15 scriptHlp.faroreSpawnSecretChest
	checkcfc0bit 1
	xorcfc0bit 1
	enableinput
	jump2byte @npcLoop

@alreadyToldSecret: ; The secret has already been told to farore
	showtextlowindex <TX_550c
	jump2byte @npcLoop

@wrongGame: ; A secret for Seasons was told in Ages, or vice versa
	showtextlowindex <TX_550b
	jump2byte @npcLoop

@secretNotActive: ; Need to talk to the corresponding npc before you can tell the secret
	showtextlowindex <TX_551c
	jump2byte @npcLoop

@waitForLinkToOpenChest: ; A chest exists already, waiting for Link to open it
	showtextlowindex <TX_550a
	jump2byte @npcLoop


; ==============================================================================
; INTERACID_DUNGEON_STUFF
; ==============================================================================

dropSmallKeyWhenNoEnemiesScript:
	stopifitemflagset ; Stop if already got the key
	checknoenemies
	spawnitem TREASURE_SMALL_KEY, $01
	scriptend

createChestWhenNoEnemiesScript:
	stopifitemflagset ; Stop if already opened the chest
	setcollisionradii $04, $06
	checknoenemies
	playsound SND_SOLVEPUZZLE
	createpuff
	wait 30
	settilehere TILEINDEX_CHEST
	incstate
	scriptend

setRoomFlagBit7WhenNoEnemiesScript:
	stopifroomflag80set
	checknoenemies
	orroomflag $80
	scriptend


; ==============================================================================
; INTERACID_FARORES_MEMORY
; ==============================================================================
faroresMemoryScript:
	initcollisions
--
	enableinput
	checkabutton
	setdisabledobjectsto91
	showtext TX_551b
	jumpiftextoptioneq $00, @openSecretList
	wait 8
	jump2byte --

@openSecretList:
	asm15 openMenu, $0a
	wait 8
	jump2byte --


; ==================================================
; INTERACID_DOOR_CONTROLLER.
; ==================================================
;
; Door opener/closer scripts.
;
; States:
;   $01: does nothing except run the script
;   $02: opens the door
;   $03: closes the door
;
; Variables:
;   angle: the type and direction of door (see interactionTypes.s)
;   speed: for subids $14-$17, this is the number of torches that must be lit.
;   var3d: Bitmask to check on wActiveTriggers (value of "X" parameter converted to
;          a bitmask)
;   var3e: Short-form position of the tile the door is on (value of "Y" parameter)
;   var3f: Value of "X" parameter (a number from 0-7 corresponding to a switch; see
;          var3d)


_doorController_updateRespawnWhenLinkNotTouching:
	checknotcollidedwithlink_ignorez
	asm15 scriptHlp.doorController_updateLinkRespawn
	retscript


; Subid $00: door just opens.
doorOpenerScript:
	incstate
	scriptend


; Subids $04-$07:
;   Door is controlled by a bit in "wActiveTriggers" (uses the bitmask in var3d).

; Subid $04
doorController_controlledByTriggers_up:
	setcollisionradii $0a, $08
	setangle $10
	jump2byte _doorController_controlledByTriggers

; Subid $05
doorController_controlledByTriggers_right:
	setcollisionradii $08, $0a
	setangle $12
	jump2byte _doorController_controlledByTriggers

; Subid $06
doorController_controlledByTriggers_down:
	setcollisionradii $0a, $08
	setangle $14
	jump2byte _doorController_controlledByTriggers

; Subid $07
doorController_controlledByTriggers_left:
	setcollisionradii $08, $0a
	setangle $16

_doorController_controlledByTriggers:
	callscript _doorController_updateRespawnWhenLinkNotTouching
@loop:
	asm15 scriptHlp.doorController_decideActionBasedOnTriggers
	jumptable_memoryaddress wTmpcfc0.normal.doorControllerState
	.dw @loop
	.dw @open
	.dw @close
@open:
	playsound SND_SOLVEPUZZLE
	setstate $02
	jump2byte @loop
@close:
	setstate $03
	jump2byte @loop


; Subids $08-$0b:
;   Door shuts itself until [wNumEnemies] == 0.

_doorController_shutUntilEnemiesDead:
	callscript _doorController_updateRespawnWhenLinkNotTouching
	jumpifnoenemies @end
	setstate $03
	checknoenemies
	playsound SND_SOLVEPUZZLE
	wait 8
	incstate
@end:
	scriptend

_doorController_open:
	setstate $02
	scriptend

; Subid $08
doorController_shutUntilEnemiesDead_up:
	setcollisionradii $0a, $08
	setangle $10
	jumpifnoenemies _doorController_open
	jump2byte _doorController_shutUntilEnemiesDead

; Subid $09
doorController_shutUntilEnemiesDead_right:
	setcollisionradii $08, $0a
	setangle $12
	jumpifnoenemies _doorController_open
	jump2byte _doorController_shutUntilEnemiesDead

; Subid $0a
doorController_shutUntilEnemiesDead_down:
	setcollisionradii $0a, $08
	setangle $14
	jumpifnoenemies _doorController_open
	jump2byte _doorController_shutUntilEnemiesDead

; Subid $0b
doorController_shutUntilEnemiesDead_left:
	setcollisionradii $08, $0a
	setangle $16
	jumpifnoenemies _doorController_open
	jump2byte _doorController_shutUntilEnemiesDead

_doorController_openOnMinecartCollision:
	asm15 scriptHlp.doorController_checkMinecartCollidedWithDoor
	jumptable_memoryaddress wTmpcfc0.normal.doorControllerState
	.dw _doorController_openOnMinecartCollision
	.dw @incState

@incState:
	incstate

_doorController_closeDoorWhenLinkNotTouching:
	callscript _doorController_updateRespawnWhenLinkNotTouching
	setstate $03
	scriptend

_doorController_minecart:
	asm15 scriptHlp.doorController_checkTileIsMinecartTrack
	jumptable_memoryaddress wTmpcfc0.normal.doorControllerState
	.dw _doorController_openOnMinecartCollision ; Not minecart track (door is closed)
	.dw _doorController_closeDoorWhenLinkNotTouching ; Minecart track (door is open)


; Subids $0c-$0f:
;   Minecart door; opens when a minecart collides with it

; Subid $0c
doorController_minecartDoor_up:
	setcollisionradii $10, $08
	setangle $18
	jump2byte _doorController_minecart

; Subid $0d
doorController_minecartDoor_right:
	setcollisionradii $08, $0e
	setangle $1a
	jump2byte _doorController_minecart

; Subid $0e
doorController_minecartDoor_down:
	setcollisionradii $0f, $08
	setangle $1c
	jump2byte _doorController_minecart

; Subid $0f
doorController_minecartDoor_left:
	setcollisionradii $08, $0f
	setangle $1e
	jump2byte _doorController_minecart


; Subids $10-$13:
;   Door which automatically closes when Link walks out of that tile.
;   When Link transitions onto a shutter door tile, the game automatically removes that
;   tile and replaces it with an interaction of this type.

_doorController_closeDoorWhenLinkNotTouchingAndFlipcfc0:
	callscript _doorController_updateRespawnWhenLinkNotTouching
	setstate $03
	xorcfc0bit 0
	scriptend

; Subid $10
doorController_closeAfterLinkEnters_up:
	setcollisionradii $0c, $08
	setangle $10
	jump2byte _doorController_closeDoorWhenLinkNotTouchingAndFlipcfc0

; Subid $11
doorController_closeAfterLinkEnters_right:
	setcollisionradii $08, $0c
	setangle $12
	jump2byte _doorController_closeDoorWhenLinkNotTouchingAndFlipcfc0

; Subid $12
doorController_closeAfterLinkEnters_down:
	setcollisionradii $0c, $08
	setangle $14
	jump2byte _doorController_closeDoorWhenLinkNotTouchingAndFlipcfc0

; Subid $13
doorController_closeAfterLinkEnters_left:
	setcollisionradii $08, $0c
	setangle $16
	jump2byte _doorController_closeDoorWhenLinkNotTouchingAndFlipcfc0


; Subids $14-$17:
;   Door opens when a number of torches are lit.

_doorController_shutUntilTorchesLit:
	callscript _doorController_updateRespawnWhenLinkNotTouching
	setstate $03
@loop:
	asm15 scriptHlp.doorController_checkEnoughTorchesLit
	jumptable_memoryaddress wTmpcec0
	.dw @loop
	.dw @torchesLit

@torchesLit:
	wait 30
	playsound SND_SOLVEPUZZLE
	incstate
	scriptend

; Subid $14
doorController_openWhenTorchesLit_up_2Torches:
	setcollisionradii $0a, $08
	setangle $10
	setspeed $02
	jump2byte _doorController_shutUntilTorchesLit

; Subid $15
doorController_openWhenTorchesLit_left_2Torches:
	setcollisionradii $08, $0a
	setangle $16
	setspeed $02
	jump2byte _doorController_shutUntilTorchesLit

.ifdef ROM_AGES
; Subid $16
doorController_openWhenTorchesLit_down_1Torch:
	setcollisionradii $0a, $08
	setangle $14
	setspeed $01
	jump2byte _doorController_shutUntilTorchesLit

; Subid $17
doorController_openWhenTorchesLit_left_1Torch:
	setcollisionradii $08, $0a
	setangle $16
	setspeed $01
	jump2byte _doorController_shutUntilTorchesLit
.endif


; ==============================================================================
; INTERACID_SHOPKEEPER
; ==============================================================================

.ifdef ROM_SEASONS
shopkeeperScript_blockLinkAccess:
	setspeed SPEED_200
	setdisabledobjectsto11
	playsound SND_CLINK
	movedown $10
	setangleandanimation $08
	jumptable_objectbyte Interaction.var3e
	.dw @noMembersCard
	.dw @membersCard

@membersCard:
	showtextlowindex <TX_0e0c
	writeobjectbyte $7d, $01
	jump2byte +

@noMembersCard:
	showtextlowindex <TX_0e01
+
	moveup $10
	setangleandanimation $08
	enableallobjects
	scriptend
.endif

shopkeeperScript_lynnaShopWelcome:
	showtextlowindex <TX_0e00
	scriptend

shopkeeperScript_advanceShopWelcome:
	showtextlowindex <TX_0e20
	scriptend

shopkeeperScript_boughtEverything:
	showtextlowindex <TX_0e26
	scriptend

shopkeeperScript_purchaseItem:
	jumptable_objectbyte Interaction.var37
	.dw @buySatchelUpgrade
	.dw @buy3Hearts
	.dw @buyHiddenShopGashaSeed1
	.dw @buyL1Shield
	.dw @buy10Bombs
	.dw @buyTreasureMap
	.dw @buyHiddenShopGashaSeed2
	.dw @buySatchelUpgrade
	.dw @buySatchelUpgrade
	.dw @buySatchelUpgrade
	.dw @buySatchelUpgrade
	.dw @buySatchelUpgrade
	.dw @buySatchelUpgrade
	.dw @buyStrangeFlute
	.dw @buyAdvanceShopGashaSeed
	.dw @buyAdvanceShopGbaRing
	.dw @buyAdvanceShopRing
	.dw @buyL2Shield
	.dw @buyL3Shield
	.dw @buyNormalShopGashaSeed

@buySatchelUpgrade:
	showtextnonexitablelowindex <TX_0e1c
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems1, $01
	scriptend

@buy3Hearts:
	showtextnonexitablelowindex <TX_0e02
	callscript _shopkeeperConfirmPurchase
	scriptend

@buyL1Shield:
	showtextnonexitablelowindex <TX_0e03
	callscript _shopkeeperConfirmPurchase
	scriptend

@buy10Bombs:
	showtextnonexitablelowindex <TX_0e04
	callscript _shopkeeperConfirmPurchase
	scriptend

@buyHiddenShopGashaSeed1:
	showtextnonexitablelowindex <TX_0e1d
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems1, $02
	scriptend

@buyTreasureMap:
	showtextnonexitablelowindex <TX_0e1e
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems1, $08
	showtextlowindex <TX_0e27
	scriptend

@buyHiddenShopGashaSeed2:
	showtextnonexitablelowindex <TX_0e1d
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems1, $04
	scriptend

@buyStrangeFlute:
	showtextnonexitablelowindex <TX_0e1b
	callscript _shopkeeperConfirmPurchase
	ormemory wRickyState, $20
	scriptend

@buyAdvanceShopGashaSeed:
	showtextnonexitablelowindex <TX_0e1d
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems2, $01
	scriptend

@buyAdvanceShopGbaRing:
	showtextnonexitablelowindex <TX_0e23
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems2, $02
	scriptend

@buyAdvanceShopRing:
	showtextnonexitablelowindex <TX_0e25
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems2, $04
	scriptend

@buyL2Shield:
	showtextnonexitablelowindex <TX_0e29
	callscript _shopkeeperConfirmPurchase
	scriptend

@buyL3Shield:
	showtextnonexitablelowindex <TX_0e2a
	callscript _shopkeeperConfirmPurchase
	scriptend

@buyNormalShopGashaSeed:
	showtextnonexitablelowindex <TX_0e1d
	callscript _shopkeeperConfirmPurchase
	ormemory wBoughtShopItems1, $20
	scriptend

_shopkeeperConfirmPurchase:
	jumpiftextoptioneq $00, @answeredYes

	; Answered no
	writememory wcbad, $03
	writememory wTextIsActive, $01
	writeobjectbyte Interaction.var3a, $ff
	scriptend

@answeredYes:
	jumpifmemoryeq wShopHaveEnoughRupees, $00, _shopkeeperAttemptToPurchaseItem
	showtextlowindex <TX_0e06


_shopkeeperCancelPurchase:
	writeobjectbyte Interaction.var3a, $ff
	enableallobjects
	scriptend


_shopkeeperNotEnoughRupeesToReplayChestGame:
	callscript _shopkeeperReturnToDeskAfterChestGame

_shopkeeperNotEnoughRupees:
	showtextlowindex <TX_0e06
	jump2byte _shopkeeperCancelPurchase
	

_shopkeeperAttemptToPurchaseItem:
	jumptable_objectbyte Interaction.var38
	.dw @canBuy
	.dw _shopkeeperCantBuy

@canBuy:
	writememory wTextIsActive, $01
	writeobjectbyte Interaction.var3a, $01
	disablemenu
	retscript


; Can't buy an item because Link already has it
_shopkeeperCantBuy:
	writememory wcbad, $02
	writememory wTextIsActive, $01
	writeobjectbyte Interaction.var3a, $ff
	scriptend


; Advance shop shopkeeper prevents Link from stealing something
shopkeeperSubid2Script_stopLink:
	setspeed SPEED_200
	playsound SND_CLINK
	movedown $10
	moveright $18
	showtextlowindex <TX_0e07
	moveleft $18
	moveup $10
	setangleandanimation $08
	enableallobjects
	scriptend

; Horon Village shopkeeper prevents Link from stealing something
shopkeeperSubid1Script_stopLink:
	setspeed SPEED_200
	moveup $10
	showtextlowindex <TX_0e07
	setdisabledobjectsto11
	movedown $10
	setangleandanimation $08
	enableallobjects
	scriptend

.ifdef ROM_AGES
; Lynna city shopkeeper prevents Link from stealing something
shopkeeperSubid0Script_stopLink:
	setspeed SPEED_200
	playsound SND_CLINK
	movedown $08
	moveleft $18
	showtextlowindex <TX_0e07
	moveright $18
	moveup $08
	setangleandanimation $18
	enableallobjects
	scriptend
.endif


; Prompt to play the chest-choosing minigame
shopkeeperChestGameScript:
	jumpifc6xxset <wBoughtShopItems1, $80, @notFirstTime

	showtextlowindex <TX_0e0d
	ormemory wBoughtShopItems1, $80
	jump2byte ++

@notFirstTime:
	showtextlowindex <TX_0e0e
++
	setdisabledobjectsto11
	jumpiftextoptioneq $00, @answeredYes

	; Answered no
	showtextlowindex <TX_0e11
	enableallobjects
	scriptend

@answeredYes:
	jumpifmemoryeq wShootingGalleryccd5, $01, _shopkeeperNotEnoughRupees
	asm15 scriptHlp.shopkeeper_take10Rupees
	setspeed SPEED_200
	setcollisionradii $06, $06
	moveup    $08
	moveright $19
	moveup    $1a
	moveright $11
	movedown  $08
	jump2byte ++

@playAgain:
	asm15 scriptHlp.shopkeeper_take10Rupees
++
	setangleandanimation $08
	writeobjectbyte Interaction.state2, $02 ; Signal to close whichever chest he faces
	writeobjectbyte Interaction.state,  $05
	wait 60

	setangleandanimation $18
	wait 60

	setangleandanimation $10
	writeobjectbyte Interaction.var3c, $00 ; Initialize to round 0
	showtextlowindex <TX_0e10

	enableallobjects
	ormemory wInShop, $80
	writeobjectbyte Interaction.state2, $00
	writeobjectbyte Interaction.state,  $05
	; Script will stop here since state has been changed.


; Opened the incorrect chest in the chest minigame.
shopkeeperScript_openedWrongChest:
	setdisabledobjectsto11
	showtextlowindex <TX_0e17
	jumpiftextoptioneq $01, @selectedNo

	; Selected "Yes" to play again
	jumpifmemoryeq wShopHaveEnoughRupees, $01, _shopkeeperNotEnoughRupeesToReplayChestGame
	jump2byte shopkeeperChestGameScript@playAgain

@selectedNo:
	callscript _shopkeeperReturnToDeskAfterChestGame
	enableallobjects
	scriptend


; Opened the correct chest in the chest minigame.
shopkeeperScript_openedCorrectChest:
	setdisabledobjectsto11
	jumptable_objectbyte Interaction.var3c
	.dw @nextRound
	.dw @nextRound
	.dw @nextRound
	.dw @round3
	.dw @round4
	.dw @round5

@nextRound:
	showtextlowindex <TX_0e13
	setangleandanimation $08
	writeobjectbyte Interaction.state2, $02 ; Signal to close whichever chest he faces
	writeobjectbyte Interaction.state,  $05
	wait 60

	setangleandanimation $18
	wait 60

	setangleandanimation $10
	showtextlowindex <TX_0e18
	enableallobjects
	scriptend

@round3:
	showtextlowindex <TX_0e12
	jumpiftextoptioneq $00, @nextRound

	; Selected no; get round 3 prize
	showtextlowindex <TX_0e14
	writeobjectbyte Interaction.var3f, $03 ; Tier 3 ring
	callscript _shopkeeperReturnToDeskAfterChestGame
	enableallobjects
	scriptend

@round4:
	showtextlowindex <TX_0e15
	jumpiftextoptioneq $00, @nextRound

	; Selected no; get round 4 prize
	showtextlowindex <TX_0e14
	writeobjectbyte Interaction.var3f, $02 ; Tier 2 ring
	callscript _shopkeeperReturnToDeskAfterChestGame
	enableallobjects
	scriptend

@round5:
	; Get round 5 prize
	showtextlowindex <TX_0e16
	writeobjectbyte Interaction.var3f, $01 ; Tier 1 ring
	callscript _shopkeeperReturnToDeskAfterChestGame
	enableallobjects
	scriptend


; Linked talked to the shopkeep in the middle of the chest game.
shopkeeperScript_talkDuringChestGame:
	showtextlowindex <TX_0e1a
	writeobjectbyte Interaction.state2, $01
	writeobjectbyte Interaction.state,  $05
	; Script stops here since state has been changed.


_shopkeeperReturnToDeskAfterChestGame:
	moveup   $08
	moveleft $11
	movedown $1a
	moveleft $19
	movedown $08
	setangleandanimation $08
	setcollisionradii $06, $14
	retscript


; Seasons - Shop not open until Link gets sword
shopkeeperScript_notOpenYet:
	showtextlowindex <TX_0e28
	scriptend


; ==============================================================================
; INTERACID_BOMB_FLOWER
; ==============================================================================

; bomb flower placed on rocks blocking temple of autumn
bombflower_unblockAutumnTemple:
	wait 60
	incstate
	wait 10
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	shakescreen 120
	asm15 scriptHlp.createBossDeathExplosion
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	checkpalettefadedone
	setdisabledobjectsto11
	settilehere TILEINDEX_DUG_HOLE
	settileat $32, TILEINDEX_DUG_HOLE
	settileat $34, TILEINDEX_DUG_HOLE
	incstate
	wait 60
	asm15 fadeinFromWhite
	checkpalettefadedone
	orroomflag $80
	setglobalflag GLOBALFLAG_UNBLOCKED_AUTUMN_TEMPLE
	playsound SND_SOLVEPUZZLE
	xorcfc0bit 0
	scriptend


; ==============================================================================
; INTERACID_SPINNER
; ==============================================================================

spinnerScript_initialization:
	setcollisionradii $09, $09

spinnerScript_waitForLinkAfterDelay:
	wait 30

spinnerScript_waitForLink:
	checkcollidedwithlink_onground
	ormemory wcc95, $80 ; Signal that Link's in a spinner?
	asm15 dropLinkHeldItem
	setanimationfromangle
	incstate
	; Script stops here since we changed to state 2 (which reloads the script)


; ==============================================================================
; INTERACID_ESSENCE
; ==============================================================================
essenceScript_essenceGetCutscene:
	playsound MUS_ESSENCE
	asm15 scriptHlp.essence_createEnergySwirl
	wait 180
	wait 180
	playsound SND_FADEOUT
	wait 20
	playsound SND_FADEOUT
	wait 20
	playsound SND_FADEOUT
	wait 40
	playsound SND_FADEOUT
	asm15 scriptHlp.essence_stopEnergySwirl
	scriptend


; ==============================================================================
; INTERACID_VASU
; ==============================================================================

vasuScript:
	setcollisionradii $12, $06
	makeabuttonsensitive

@npcLoop:
	enableinput
	checkabutton
	disableinput
	jumpifglobalflagset GLOBALFLAG_OBTAINED_RING_BOX, @alreadyGaveRingBox
	jumpifmemoryeq wIsLinkedGame, $00, @firstTime
	jumpifmemoryset wObtainedRingBox, $01, @linkedGameFirstTime
	jump2byte @firstTime

@linkedGameFirstTime:
	showtextlowindex <TX_303e
	jumpifobjectbyteeq Interaction.var36, $01, ++ ; Check TREASURE_RING_BOX

	; Give ring box in linked game
	showtextlowindex <TX_303b
	asm15 scriptHlp.vasu_giveRingBox
	wait 1
++
	setdisabledobjectsto11
	checktext
	jump2byte @justGaveRingBox

@firstTime:
	showtextnonexitablelowindex <TX_3000
@giveExplanation:
	jumpiftextoptioneq $00, @explanationDone
	showtextnonexitablelowindex <TX_303a
	jump2byte @giveExplanation
@explanationDone:
	jumpifobjectbyteeq Interaction.var36, $01, ++ ; Check TREASURE_RING_BOX

	; Give ring box in unlinked game
	showtextlowindex <TX_303b
	asm15 scriptHlp.vasu_giveRingBox
	wait 1
	setdisabledobjectsto11
	checktext
++
	; Give friendship ring
	showtextlowindex <TX_303f
	asm15 scriptHlp.vasu_giveFriendshipRing
	wait 1
	setdisabledobjectsto11
	checktext

	; Force Link to appraise it
	showtextlowindex <TX_3033
	asm15 scriptHlp.vasu_openRingMenu, $00
	wait 10

	; Open ring list
	showtextlowindex <TX_3013
	asm15 scriptHlp.vasu_openRingMenu, $01
	wait 10
	showtextlowindex <TX_3008

@justGaveRingBox:
	setglobalflag GLOBALFLAG_OBTAINED_RING_BOX
	ormemory wObtainedRingBox, $01
	enableinput
	jump2byte @npcLoop


@alreadyGaveRingBox:
	; Check whether to give special rings
	asm15 scriptHlp.vasu_checkEarnedSpecialRing
	jumptable_objectbyte Interaction.var3b
	.dw @giveSlayersRing
	.dw @giveWealthRing
	.dw @giveVictoryRing
	.dw @noSpecialRing

@giveSlayersRing:
	showtextlowindex <TX_3036
	jump2byte @giveSpecialRing

@giveWealthRing:
	showtextlowindex <TX_3037
	jump2byte @giveSpecialRing

@giveVictoryRing:
	showtextlowindex <TX_3039
@giveSpecialRing:
	checktext
	asm15 scriptHlp.vasu_giveRingInVar3a
	jump2byte @npcLoop


; Just show normal welcome text
@noSpecialRing:
	showtextnonexitablelowindex <TX_3003
	jumpiftextoptioneq $00, @appraise
	jumpiftextoptioneq $01, @list

	; Selected "Quit"
	enableinput
	showtextlowindex <TX_3008
	jump2byte @npcLoop

@appraise:
	jumpifobjectbyteeq Interaction.var37, $00, @noUnappraisedRings
	asm15 scriptHlp.vasu_openRingMenu, $00
	jump2byte @exitedRingMenu

@list:
	jumpifobjectbyteeq Interaction.var38, $00, @noAppraisedRings
	asm15 scriptHlp.vasu_openRingMenu, $01

@exitedRingMenu:
	wait 10
	jumpifglobalflagset GLOBALFLAG_APPRAISED_HUNDREDTH_RING, @giveHundredthRing

	showtextlowindex <TX_3008
	enableinput
	jump2byte @npcLoop

@giveHundredthRing:
	showtextlowindex <TX_3038
	checktext
	unsetglobalflag GLOBALFLAG_APPRAISED_HUNDREDTH_RING
	asm15 scriptHlp.vasu_giveHundredthRing
	jump2byte @npcLoop


@noUnappraisedRings:
	showtextlowindex <TX_3014
	jump2byte @npcLoop

@noAppraisedRings:
	showtextlowindex <TX_3015
	jump2byte @npcLoop


; Red snake before beating unlinked game
redSnakeScript_preLinked:
	showtextnonexitablelowindex <TX_3009
	jumpiftextoptioneq $00, _redSnake_explain

	writememory wTextIsActive, $01
	enableinput
	scriptend

_redSnake_explain:
	wait 30
	showtextnonexitablelowindex <TX_300a
	jumpiftextoptioneq $01, @explainBox

@explainAppraisal:
	showtextnonexitablelowindex <TX_300b
	jump2byte ++

@explainBox:
	showtextnonexitablelowindex <TX_300c
++
	jumpiftextoptioneq $00, _redSnake_explain
	writememory wTextIsActive, $01
	scriptend


; Blue snake before beating unlinked game
blueSnakeScript_preLinked:
	showtextnonexitablelowindex <TX_301f
	jumpiftextoptioneq $01, blueSnakeScript_doNotRemoveCable
	jump2byte _blueSnake_linkOrFortune

; Blue snake after beating linked game
blueSnakeScript_linked:
	showtextnonexitablelowindex <TX_3024
	jumpiftextoptioneq $02, blueSnakeScript_doNotRemoveCable

_blueSnake_linkOrFortune:
	setdisabledobjectsto11
	asm15 scriptHlp.blueSnake_linkOrFortune
	wait 1
	scriptend

blueSnakeScript_doNotRemoveCable:
	showtextlowindex <TX_302e
	scriptend
blueSnakeExitScript_cableNotConnected:
	showtextlowindex <TX_300f
	scriptend
blueSnakeExitScript_linkFailed:
	showtextlowindex <TX_3031
	scriptend
blueSnakeExitScript_noValidFile:
	showtextlowindex <TX_302a
	scriptend


; Red snake after beating linked game
redSnakeScript_linked:
	showtextnonexitablelowindex <TX_3018
	jumpiftextoptioneq $02, @quit
	jumpiftextoptioneq $00, @tellSecretToSnake

	; Generate a secret
	asm15 scriptHlp.redSnake_generateRingSecret
@tellSecretToLink:
	showtextnonexitablelowindex <TX_301d
	jumpiftextoptioneq $00, @tellSecretToLink
	jump2byte @quit

@tellSecretToSnake:
	asm15 scriptHlp.redSnake_openSecretInputMenu
	wait 1
	jumpifmemoryeq wTextInputResult, $00, @toldValidSecret

	; Told invalid secret
	showtextlowindex <TX_301e
	scriptend

@quit:
	showtextlowindex <TX_3010
	scriptend

@toldValidSecret:
	showtextlowindex <TX_3027
	scriptend


blueSnakeScript_successfulFortune:
	setdisabledobjectsto11
	showtextlowindex <TX_3023
	asm15 scriptHlp.vasu_giveRingInVar3a
	wait 1
	checktext
	enableallobjects
	scriptend

blueSnakeScript_successfulRingTransfer:
	showtextlowindex <TX_3027
	scriptend


; ==============================================================================
; INTERACID_GAME_COMPLETE_DIALOG
; ==============================================================================
gameCompleteDialogScript:
	wait 30
	showtext TX_550d
	jumpiftextoptioneq $00, @dontSave

	; Save
	asm15 scriptHlp.gameCompleteDialog_markGameAsComplete
	asm15 saveFile
	wait 30
	jump2byte ++

@dontSave:
	wait 30
	showtext TX_550e
	jumpiftextoptioneq $00, gameCompleteDialogScript
++
	writememory wTmpcfc0.genericCutscene.cfde, $01
	scriptend


; ==============================================================================
; INTERACID_RING_HELP_BOOK
; ==============================================================================

ringHelpBookSubid1Reset:
	writememory wTextIsActive, $01

ringHelpBookSubid1Script:
	checkabutton
	showtextnonexitablelowindex <TX_3019
	jumpiftextoptioneq $01, ringHelpBookSubid1Reset
	showtextlowindex <TX_301a
	jump2byte ringHelpBookSubid1Script


ringHelpBookSubid0Reset:
	writememory wTextIsActive, $01

ringHelpBookSubid0Script:
	checkabutton
	showtextnonexitablelowindex <TX_3020
	jumpiftextoptioneq $01, ringHelpBookSubid0Reset

@showAgain:
	showtextnonexitablelowindex <TX_3025
	jumpiftextoptioneq $01, @option1
@option0:
	jumpiftextoptioneq $02, ringHelpBookSubid0Reset
	showtextnonexitablelowindex <TX_303d
	jumpiftextoptioneq $01, ringHelpBookSubid0Reset
	jump2byte @showAgain
@option1:
	showtextnonexitablelowindex <TX_3026
	jumpiftextoptioneq $01, ringHelpBookSubid0Reset
	jump2byte @showAgain


; ==============================================================================
; INTERACID_DUNGEON_SCRIPT
; ==============================================================================
.include "scripts/seasons/dungeonScripts.s"


; ==============================================================================
; INTERACID_GANRLED_KEYHOLE
; ==============================================================================
gnarledKeyholeScript:
	checkcfc0bit 0
	disableinput
	setmusic SNDCTRL_STOPMUSIC
	wait 60
	shakescreen 120
	wait 60
	orroomflag $80
	incstate
	scriptend


; ==============================================================================
; INTERACID_MAKU_CUTSCENES
; ==============================================================================
makuTreeScript_remoteCutscene:
	disableinput
	orroomflag $40
makuTreeScript_remoteCutsceneDontSetRoomFlag:
	writememory $cbae, $04
	setmusic MUS_MAKU_TREE
	wait 40
	asm15 hideStatusBar
	asm15 scriptHlp.seasonsFunc_15_571a, $02
	checkpalettefadedone
	spawninteraction INTERACID_MAKU_LEAF $00, $40, $50
	wait 240
	wait 60
	callscript script4e25
	asm15 showStatusBar
	asm15 clearFadingPalettes
	asm15 fadeinFromWhiteWithDelay, $02
	checkpalettefadedone
	resetmusic
	enableinput
	asm15 scriptHlp.seasonsFunc_15_576c
	scriptend
script4e25:
	jumptable_objectbyte Interaction.subid
	.dw @outsideDungeon1
	.dw @outsideDungeon2
	.dw @outsideDungeon3
	.dw @outsideDungeon4
	.dw @outsideDungeon5
	.dw @outsideDungeon6
	.dw @outsideDungeon7
	.dw @outsideDungeon8
	.dw @outsideWinterTemple
	.dw script4e83
	.dw @outsideDungeon8
@outsideDungeon1:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1704
	retscript
@outsideDungeon2:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1707
	retscript
@outsideDungeon3:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1709 ; / TX_1724
	retscript
@outsideDungeon4:
	asm15 scriptHlp.seasonsFunc_15_5744
	jumpifobjectbyteeq Interaction.var3f, $01, @@dungeon5AfterDungeon4
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_170b
	retscript
@@dungeon5AfterDungeon4:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1710
	retscript
@outsideDungeon5:
	asm15 scriptHlp.seasonsFunc_15_5748
	jumpifobjectbyteeq Interaction.var3f, $01, @@dungeon5AfterDungeon4
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_170d
	retscript
@@dungeon5AfterDungeon4:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_170f
	retscript
@outsideDungeon6:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1712
	retscript
@outsideDungeon7:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1714
	retscript
@outsideDungeon8:
	asm15 scriptHlp.seasonsFunc_15_5735, <TX_1716
	retscript
@outsideWinterTemple:
	showtext TX_1736
	retscript
script4e83: ; twinrova is behind onox
	showtext TX_5007
	retscript


makuTreeScript_gateHit:
	setcollisionradii $14, $20
@checkLinkHitGateWithSword:
	asm15 scriptHlp.makuTree_checkGateHit
	jumptable_memoryaddress $cfc0
	.dw @checkLinkHitGateWithSword
	.dw @gateHit
@gateHit:
	giveitem ITEMID_SWORD $03
	disableinput
	wait 60
	incstate
	orroomflag $80
	checkobjectbyteeq Interaction.state, $01
	playsound SND_SOLVEPUZZLE
	wait 60
	enableinput
	scriptend
	
	
; ==============================================================================
; INTERACID_SEASON_SPIRITS_SCRIPTS
; ==============================================================================
seasonsSpiritsScript_enteringTempleArea:
	loadscript seasonsSpirits_enteringTempleCutscene
	
seasonsSpiritsScript_winterTempleOrbBridge:
	loadscript seasonsSpirits_createBridgeOnOrbHit
	
seasonsSpiritsScript_spiritStatue:
	jumpifroomflagset $40, _seasonsSpiritsScript_seasonsGotten
	jumpifitemobtained TREASURE_ROD_OF_SEASONS, @haveRodOfSeasons
	setcoords $28, $70
	setcollisionradii $04, $10
	makeabuttonsensitive
-
	; no rod of seasons
	checkabutton
	disableinput
	writememory $cfc0, $00
	asm15 scriptHlp.spawnSeasonsSpiritSubId01
	xorcfc0bit 0
	playsound SND_CIRCLING
	checkcfc0bit 1
	wait 40
	showtextlowindex <TX_0811
	wait 8
	xorcfc0bit 2
	wait 30
	enableinput
	jump2byte -
@haveRodOfSeasons:
	setcollisionradii $08, $04
	checkcollidedwithlink_onground
	disableinput
	asm15 scriptHlp.spawnSeasonsSpiritSubId00
	xorcfc0bit 0
	playsound SND_CIRCLING
	checkcfc0bit 1
	callscript _seasonsSpiritsScript_showIntroText
	asm15 scriptHlp.seasonsSpirit_createSwirl
	wait 10
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	checkpalettefadedone
	xorcfc0bit 2
	wait 20
	asm15 fadeinFromWhiteWithDelay, $04
	checkpalettefadedone
	callscript _seasonsSpiritsScript_imbueSeason
	asm15 scriptHlp.seasonsSpirits_checkPostSeasonGetText
	jumptable_objectbyte $7f
	.dw @@notAllSeasonsGotten
	.dw @@allSeasonsGotten_nonAutumnText
	.dw @@allSeasonsGotten_autumnText
@@allSeasonsGotten_nonAutumnText:
	wait 30
	showtextlowindex <TX_080e
	jump2byte @@notAllSeasonsGotten
@@allSeasonsGotten_autumnText:
	wait 30
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	showtextlowindex <TX_080f
@@notAllSeasonsGotten:
	orroomflag $40
	enableinput
_seasonsSpiritsScript_seasonsGotten:
	setcoords $28, $70
	setcollisionradii $04, $10
	makeabuttonsensitive
-
	checkabutton
	disableinput
	writememory $cfc0, $00
	asm15 scriptHlp.spawnSeasonsSpiritSubId01
	xorcfc0bit 0
	playsound SND_CIRCLING
	checkcfc0bit 1
	wait 40
	callscript _seasonsSpirits_postSeasonGetText
	wait 8
	xorcfc0bit 2
	wait 30
	enableinput
	jump2byte -

_seasonsSpirits_postSeasonGetText:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, _seasonsSpirits_lastTextGameFinished
	jumpifobjectbyteeq $7e, $01, _seasonsSpirits_lastTextSaveZeldaText
	jumptable_objectbyte $43
	.dw @spring
	.dw @summer
	.dw @autumn
	.dw @winter
@spring:
	showtextlowindex <TX_0809
	retscript
@summer:
	showtextlowindex <TX_0807
	retscript
@autumn:
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	showtextlowindex <TX_080b
	retscript
@winter:
	showtextlowindex <TX_0805
	retscript

_seasonsSpirits_lastTextGameFinished:
	jumptable_objectbyte $43
	.dw @spring
	.dw @summer
	.dw @autumn
	.dw @winter
@spring:
	showtextlowindex <TX_0818
	retscript
@summer:
	showtextlowindex <TX_0819
	retscript
@autumn:
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	showtextlowindex <TX_081a
	retscript
@winter:
	showtextlowindex <TX_081b
	retscript
	
_seasonsSpirits_lastTextSaveZeldaText:
	jumptable_objectbyte $43
	.dw script4f80
	.dw script4f83
	.dw script4f86
	.dw script4f8d
script4f80:
	showtextlowindex <TX_0814
	retscript
script4f83:
	showtextlowindex <TX_0815
	retscript
script4f86:
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	showtextlowindex <TX_0816
	retscript
script4f8d:
	showtextlowindex <TX_0817
	retscript

_seasonsSpiritsScript_showIntroText:
	jumptable_objectbyte $43
	.dw @spring
	.dw @summer
	.dw @autumn
	.dw @winter
@spring:
	showtextlowindex <TX_0808
	retscript
@summer:
	showtextlowindex <TX_0806
	retscript
@autumn:
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	showtextlowindex <TX_080a
	retscript
@winter:
	showtextlowindex <TX_0804
	retscript

_seasonsSpiritsScript_imbueSeason:
	jumptable_objectbyte $43
	.dw @spring
	.dw @summer
	.dw @autumn
	.dw @winter
@spring:
	giveitem TREASURE_ROD_OF_SEASONS $02
	retscript
@summer:
	giveitem TREASURE_ROD_OF_SEASONS $03
	retscript
@autumn:
	writememory wTextboxFlags, TEXTBOXFLAG_ALTPALETTE2
	giveitem TREASURE_ROD_OF_SEASONS $04
	retscript
@winter:
	giveitem TREASURE_ROD_OF_SEASONS $05
	retscript


; ==============================================================================
; INTERACID_MAYORS_HOUSE_NPC
; ==============================================================================
mayorsScript:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	jumpifroomflagset $20, +
	showtext TX_310b
	wait 20
	giveitem TREASURE_GASHA_SEED $04
	jump2byte ++
+
; unused?
	showtextlowindex $31
	scriptend
; unused?
	jump2byte -
++
	wait 20
	showtext TX_310c
	jump2byte -


mayorsHouseLadyScript:
	initcollisions
@waitUntilTalkedTo:
	enableinput
	checkabutton
	disableinput
	jumpifglobalflagset GLOBALFLAG_DONE_RUUL_SECRET, @doneSecret
	showtext TX_3102
	jumpiftextoptioneq $00, @answeredYes
	wait 20
	showtext TX_3103
	jump2byte @waitUntilTalkedTo
@wrongSecret:
	wait 20
	showtext TX_3104
	jump2byte @waitUntilTalkedTo
@answeredYes:
	askforsecret RUUL_SECRET
	wait 20
	jumptable_memoryaddress $cca3
	.dw @correctSecret
	.dw @wrongSecret
@correctSecret:
	showtext TX_3105
	wait 20
	jumpifitemobtained TREASURE_RING_BOX, @upgradeRingbox
	showtext TX_3109
	wait 20
	giveitem TREASURE_RING_BOX $03
	jump2byte @provideReturnSecret
@upgradeRingbox:
	showtext TX_3108
	wait 20
	asm15 scriptHlp.getNextRingboxLevel
	jumpifmemoryeq wTextNumberSubstitution, $05, @upgradeTo5
	giveitem TREASURE_RING_BOX $01
	jump2byte @provideReturnSecret
@upgradeTo5:
	giveitem TREASURE_RING_BOX $02
@provideReturnSecret:
	wait 20
@doneSecret:
	generatesecret RUUL_RETURN_SECRET
-
	showtext TX_3106
	wait 20
	jumpiftextoptioneq $01, -
	setglobalflag GLOBALFLAG_DONE_RUUL_SECRET
	showtext TX_3107
	jump2byte @waitUntilTalkedTo

	
; ==============================================================================
; INTERACID_MRS_RUUL
; ==============================================================================
mrsRuulScript:
	initcollisions
	jumpifroomflagset $40, @gaveDoll
-
	checkabutton
	showtext TX_0b1a
	jumpiftradeitemeq $02, @hasDoll
	jump2byte -
@hasDoll:
	disableinput
	wait 30
-
	showtext TX_0b1b
	jumpiftextoptioneq $00, @givingDoll
	wait 30
	showtext TX_0b1e
	enableinput
	checkabutton
	disableinput
	jump2byte -
@givingDoll:
	wait 30
	showtext TX_0b1c
	giveitem TREASURE_TRADEITEM $03
	orroomflag $40
	enableinput
@gaveDoll:
	checkabutton
	showtext TX_0b1d
	jump2byte @gaveDoll
	

; ==============================================================================
; INTERACID_MR_WRITE
; ==============================================================================
mrWriteScript:
	setcollisionradii $0a, $06
	makeabuttonsensitive
	jumpifroomflagset $40, @alreadyLitTorch
-
	jumptable_memoryaddress wNumTorchesLit
	.dw @unlitTorch
	.dw @litTorch
@unlitTorch:
	jumpifobjectbyteeq $71, $00, -
	writeobjectbyte $71, $00
	showtext TX_0b00
	jump2byte -
@litTorch:
	disableinput
	wait 40
	showtext TX_0b01
	giveitem TREASURE_TRADEITEM $00
	orroomflag $40
	enableinput
@alreadyLitTorch:
	checkabutton
	disableinput
	writeobjectbyte $73, $0b
	getrandombits $72, $0f
	addobjectbyte $72, $02
	showloadedtext
	enableinput
	jump2byte @alreadyLitTorch
	
	
; ==============================================================================
; INTERACID_FICKLE_LADY
; ==============================================================================
fickleLadyScript_text1:
	rungenericnpc TX_1600
fickleLadyScript_text2:
	rungenericnpc TX_1602
fickleLadyScript_text3:
	rungenericnpc TX_1603
fickleLadyScript_text4:
	rungenericnpc TX_1604
fickleLadyScript_text5:
	rungenericnpc TX_1605
fickleLadyScript_text6:
	rungenericnpc TX_1606
fickleLadyScript_text7:
	rungenericnpc TX_1607
	
	
; ==============================================================================
; INTERACID_MALON
; ==============================================================================
malonScript:
	initcollisions
	jumpifroomflagset $40, @gaveCuccodex
-
	checkabutton
	showtext TX_0b12
	jumpiftradeitemeq $00, @haveCuccodex
	jump2byte -
@haveCuccodex:
	disableinput
	wait 30
-
	showtext TX_0b13
	jumpiftextoptioneq $00, @givingCuccodex
	wait 30
	showtext TX_0b16
	enableinput
	checkabutton
	disableinput
	jump2byte -
@givingCuccodex:
	wait 30
	showtext TX_0b14
	giveitem TREASURE_TRADEITEM $01
	orroomflag $40
	enableinput
@gaveCuccodex:
	asm15 scriptHlp.checkTalonReturned
	jumptable_objectbyte $7c
	.dw @talonNotReturned
	.dw @talonReturned
@talonNotReturned:
	checkabutton
	showtext TX_0b15
	jump2byte @talonNotReturned
@talonReturned:
	spawninteraction INTERACID_TALON $01, $68, $78
-
	checkabutton
	showtext TX_0b17
	jump2byte -
	
	
; ==============================================================================
; INTERACID_BATHING_SUBROSIANS
; ==============================================================================
bathingSubrosianScript_text1:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e05
	
bathingSubrosianScript_stub:
	wait 240
	jump2byte bathingSubrosianScript_stub
	
bathingSubrosianScript_2:
	writeobjectbyte $5c, $01
-
	wait 240
	jump2byte -

bathingSubrosianScript_text3:
	rungenericnpc TX_3e07
	
	
; ==============================================================================
; INTERACID_MASTER_DIVERS_SON
; ==============================================================================
masterDiversSonScript:
	settextid TX_1903
	jumpifglobalflagset GLOBALFLAG_MOBLINS_KEEP_DESTROYED, @commonInit
	settextid TX_1900
@commonInit:
	initcollisions
@commonInitShowText:
	checkabutton
	setdisabledobjectsto11
	cplinkx $49
	setanimationfromobjectbyte $49
	showloadedtext
	enableallobjects
	jump2byte @commonInitShowText
	
masterDiversSonScript_4thEssenceGotten:
	jumpifglobalflagset GLOBALFLAG_MOBLINS_KEEP_DESTROYED, @moblinKeepDestroyed
	initcollisions
-
	settextid TX_1901
	jump2byte masterDiversSonScript@commonInitShowText
@moblinKeepDestroyed:
	setcoords $58, $38
	initcollisions
	settextid TX_1903
	checkabutton
	setdisabledobjectsto11
	cplinkx $49
	setanimationfromobjectbyte $49
	showloadedtext
	enableallobjects
	jump2byte -
	
masterDiversSonScript_8thEssenceGotten:
	settextid TX_1902
	jump2byte masterDiversSonScript@commonInit
	
masterDiversSonScript_ZeldaKidnapped:
	settextid TX_1904
	jump2byte masterDiversSonScript@commonInit
	
masterDiversSonScript_gameFinished:
	settextid TX_1905
	jump2byte masterDiversSonScript@commonInit
	

; ==============================================================================
; INTERACID_FICKLE_MAN
; ==============================================================================
ficklManScript_text1:
	rungenericnpc TX_0f00
ficklManScript_text2:
	rungenericnpc TX_0f01
ficklManScript_text3:
	rungenericnpc TX_0f03
ficklManScript_text4:
	rungenericnpc TX_0f02
ficklManScript_text5:
	rungenericnpc TX_0f04
ficklManScript_text6:
	rungenericnpc TX_0f05
ficklManScript_text7:
	rungenericnpc TX_0f06
ficklManScript_text8:
	rungenericnpc TX_0f07
ficklManScript_text9:
	rungenericnpc TX_0f08
ficklManScript_textA:
	writeobjectbyte $5c, $02
	rungenericnpc TX_0e21
	
	
; ==============================================================================
; INTERACID_DUNGEON_WISE_OLD_MAN
; ==============================================================================
dungeonWiseOldManScript:
	initcollisions
-
	checkabutton
	showloadedtext
	asm15 scriptHlp.dungeonWiseOldMan_setLinksInvincibilityCounterTo0
	jump2byte -
	

; ==============================================================================
; INTERACID_TREASURE_HUNTER
; ==============================================================================
treasureHunterScript_text1:
	rungenericnpc TX_1b00
treasureHunterScript_text2:
	rungenericnpc TX_1b01
treasureHunterScript_text3:
	rungenericnpc TX_1b02
treasureHunterScript_text4:
	rungenericnpc TX_1b03
	
	
; ==============================================================================
; INTERACID_OLD_LADY_FARMER
; ==============================================================================
oldLadyFarmerScript_text1:
	rungenericnpc TX_1200
	
oldLadyFarmerScript_text2:
	initcollisions
-
	checkabutton
	setdisabledobjectsto91
	showtext TX_1201
	jumpiftextoptioneq $01, @answeredYes
	wait 30
	showtext TX_1202
	jump2byte @answeredNo
@answeredYes:
	wait 30
	showtext TX_1203
@answeredNo:
	enableallobjects
	jump2byte -
	
oldLadyFarmerScript_text3:
	rungenericnpc TX_1204
	
oldLadyFarmerScript_text4:
	rungenericnpc TX_1205
	
oldLadyFarmerScript_text5:
	rungenericnpc TX_1206
	
oldLadyFarmerScript_text6:
	rungenericnpc TX_1206
	
oldLadyFarmerScript_text7:
	rungenericnpc TX_1208
	

; ==============================================================================
; INTERACID_FOUNTAIN_OLD_MAN
; ==============================================================================
fountainOldManScript_text1:
	settextid TX_1000
	jumpifmemoryeq wIsLinkedGame, $01, fountainOldManScript_text2
_fountainOldManScript_showText:
	setcollisionradii $03, $0b
	makeabuttonsensitive
-
	checkabutton
	showloadedtext
	jump2byte -
	
fountainOldManScript_text2:
	settextid TX_1001
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text3:
	settextid TX_1002
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text4:
	settextid TX_1003
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text5:
	settextid TX_1004
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text6:
	settextid TX_1005
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text7:
	settextid TX_1006
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text8:
	settextid TX_1007
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_text9:
	settextid TX_1008
	jump2byte _fountainOldManScript_showText
	
fountainOldManScript_textA:
	settextid TX_1009
	jump2byte _fountainOldManScript_showText
	
	
; ==============================================================================
; INTERACID_TICK_TOCK
; ==============================================================================
tickTockScript:
	setcollisionradii $0f, $06
	makeabuttonsensitive
	jumpifroomflagset $40, @gaveEngineGrease
-
	checkabutton
	showtext TX_0b43
	jumpiftradeitemeq $09, @haveEngineGrease
	jump2byte -
@haveEngineGrease:
	disableinput
	wait 30
-
	showtext TX_0b44
	jumpiftextoptioneq $00, @givingEngineGrease
	wait 30
	showtext TX_0b47
	enableinput
	checkabutton
	disableinput
	jump2byte -
@givingEngineGrease:
	wait 30
	showtext TX_0b45
	giveitem TREASURE_TRADEITEM $0a
	orroomflag $40
	enableinput
@gaveEngineGrease:
	checkabutton
	showtext TX_0b46
	jump2byte @gaveEngineGrease
	
	
; ==============================================================================
; INTERACID_MITTENS
; ==============================================================================
mittensScript:
	rungenericnpclowindex <TX_0b34
	
	
; ==============================================================================
; INTERACID_MITTENS_OWNER
; ==============================================================================
mittensOwnerScript:
	initcollisions
	jumpifroomflagset $40, @mittensCameDown
-
	checkabutton
	disableinput
	showtextlowindex <TX_0b31
	jumpiftradeitemeq $06, @hasFish
	enableinput
	jump2byte -
@hasFish:
	wait 30
-
	showtextlowindex <TX_0b32
	jumpiftextoptioneq $00, @givingFish
	wait 30
	showtextlowindex <TX_0b37
	enableinput
	checkabutton
	disableinput
	jump2byte -
@givingFish:
	wait 30
	writememory $cfde, $00
	spawninteraction INTERACID_TRADE_ITEM $06, $44, $68
	showtextlowindex <TX_0b33
	ormemory $cceb, $01
	showtextlowindex <TX_0b34
	setcounter1 $20
	setanimation $02
	writememory $cfde, $40
	showtextlowindex <TX_0b35
	giveitem TREASURE_TRADEITEM $07
	orroomflag $40
	enableinput
@mittensCameDown:
	checkabutton
	showtextlowindex <TX_0b36
	jump2byte @mittensCameDown


; ==============================================================================
; INTERACID_SOKRA
; ==============================================================================
sokraScript_inVillage:
	initcollisions
	jumpifitemobtained TREASURE_ROD_OF_SEASONS, @haveRodOfSeasons
	jumpifroomflagset $40, @alreadyInformed
-
	wait 1
	jumpifobjectbyteeq $77, $01, @canDoEvent
	jumpifobjectbyteeq $71, $00, @sleeping
	writeobjectbyte $71, $00
	showtextlowindex <TX_5202
@sleeping:
	asm15 createSokraSnore
	jump2byte -
@canDoEvent:
	disableinput
	asm15 scriptHlp.sokra_alert
	playsound SND_CLINK
	setcounter1 $40
	setcollisionradii $00, $00
	setanimation $06
	setspeed SPEED_100
	setangle $18
	applyspeed $10
	wait 10
	setangle $10
-
	wait 1
	asm15 scriptHlp.villageSokra_waitUntilLinkInPosition
	jumpifobjectbyteeq $76, $00, -
	wait 20
	writememory $d008, $00
	showtextlowindex <TX_5200
	wait 20
	setangle $00
	setanimation $07
-
	wait 1
	asm15 scriptHlp.seasonsFunc_15_5812, $28
	jumpifobjectbyteeq $76, $01, -
	setangle $08
	applyspeed $10
	orroomflag $40
	setcollisionradii $06, $06
	setanimation $06
	wait 20
	setanimation $04
	wait 30
	enableinput
	wait 30
	setanimation $00
@alreadyInformed:
	wait 1
	asm15 createSokraSnore
	jumpifobjectbyteeq $71, $00, @alreadyInformed
	writeobjectbyte $71, $00
	showtextlowindex <TX_5202
	jump2byte @alreadyInformed
@haveRodOfSeasons:
	setanimation $02
	writeobjectbyte $43, $01
	asm15 scriptHlp.villageSokra_checkStageInGame
	jumptable_memoryaddress $cfc0
	.dw @noEssences
	.dw @firstEssenceGotten
	.dw @ZeldaTaken
@noEssences:
	rungenericnpclowindex <TX_5201
@firstEssenceGotten:
	rungenericnpclowindex <TX_5203
@ZeldaTaken:
	rungenericnpclowindex <TX_520a
	
sokraScript_easternSuburbsPortal:
	jumpifobjectbyteeq $77, $01, @canDoEvent
	wait 1
	asm15 createSokraSnore
	jump2byte sokraScript_easternSuburbsPortal
@canDoEvent:
	disableinput
	asm15 scriptHlp.sokra_alert
	playsound SND_CLINK
	setcounter1 $40
	showtextlowindex <TX_5204
	wait 40
	setanimation $06
	setspeed SPEED_100
	setangle ANGLE_DOWN
-
	wait 1
	asm15 scriptHlp.suburbsSokra_jumpOffStump
	jumpifobjectbyteeq $4f, $00, @moveLeft
	jump2byte -
@moveLeft:
	wait 30
	setangle ANGLE_LEFT
	applyspeed $24
	wait 10
	asm15 scriptHlp.seasonsFunc_15_5840
-
	wait 1
	asm15 scriptHlp.seasonsFunc_15_5802
	jumpifobjectbyteeq $76, $00, -
	wait 20
	writememory $d008, $01
	showtextlowindex <TX_5205
-
	wait 20
	showtextlowindex <TX_5206
	jumpiftextoptioneq $01, -
	wait 20
	showtextlowindex <TX_5207
	setangle $10
	setanimation $06
	setspeed SPEED_100
-
	wait 1
	asm15 scriptHlp.seasonsFunc_15_5812, $88
	jumpifobjectbyteeq $76, $01, -
	enableinput
	orroomflag $40
	scriptend
	
sokraScript_needSummerForD3:
	initcollisions
	settextid TX_5208
	checkabutton
	disableinput
	callscript @displayText
	settextid TX_5209
-
	enableinput
	checkabutton
	disableinput
	callscript @displayText
	jump2byte -
@displayText:
	cplinkx $48
	addobjectbyte $48, $08
	setanimationfromobjectbyte $48
	wait 60
	showloadedtext
	wait 30
	addobjectbyte $48, $f8
	setanimationfromobjectbyte $48
	retscript
	

; ==============================================================================
; INTERACID_BIPIN
; ==============================================================================

; Running around when baby just born
bipinScript0:
	setcollisionradii $06, $06
	makeabuttonsensitive
@loop:
	checkabutton
	jumpifmemoryeq wChildStatus, $00, @stillUnnamed
	showtext TX_4301
	jump2byte @loop
@stillUnnamed:
	showtext TX_4300
	jump2byte @loop


; Bipin gives you a random tip
bipinScript1:
	initcollisions
@loop:
	checkabutton
	setdisabledobjectsto91
	setanimation $02
	asm15 scriptHlp.bipin_showText_subid1To9
	wait 30
	callscript _bipinSayRandomTip
	enableallobjects
	jump2byte @loop


; Bipin just moved to Labrynna/Holodrum?
bipinScript2:
	initcollisions
@loop:
	checkabutton
	setdisabledobjectsto91
	asm15 scriptHlp.bipin_showText_subid1To9
	enableallobjects
	jump2byte @loop

_bipinSayRandomTip:
	; Show a random text index from TX_4309-TX_4310
	writeobjectbyte  Interaction.textID+1, >TX_4300
	getrandombits    Interaction.textID,   $07
	addobjectbyte    Interaction.textID,   <TX_4309
	showloadedtext

	setanimation $03
	retscript


.ifdef ROM_AGES
; "Past" version of Bipin who gives you a gasha seed
bipinScript3:
	loadscript scriptHlp.bipinScript3
.endif


; ==============================================================================
; INTERACID_S_BIRD
; ==============================================================================
knowItAllBirdScript:
	setcollisionradii $08, $08
	makeabuttonsensitive
@loop:
	checkabutton
	setdisabledobjectsto91
	cplinkx Interaction.direction
	writeobjectbyte Interaction.var37, $01 ; Signal to start spazzing out
	showloadedtext
	jumpiftextoptioneq $01, @doneTalking

	wait 30
	addobjectbyte Interaction.textID, $0a
	showloadedtext
	addobjectbyte Interaction.textID, -$0a

@doneTalking:
	enableallobjects
	writeobjectbyte Interaction.var37, $00
	jump2byte @loop


panickingBirdScript:
	setcollisionradii $06, $06
	makeabuttonsensitive
@loop:
	checkabutton
	setdisabledobjectsto11
	cplinkx Interaction.direction
	writeobjectbyte Interaction.var37, $01 ; Signal to start spazzing out
	showtext TX_0503
	writeobjectbyte $77, $00
	enableallobjects
	jump2byte @loop


; ==============================================================================
; INTERACID_BLOSSOM
; ==============================================================================

; Blossom asking you to name her child
blossomScript0:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $00
	jumpifobjectbyteeq Interaction.var3b, $01, @nameAlreadyGiven
@loop:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_4400

@askForName:
	asm15 scriptHlp.blossom_openNameEntryMenu
	wait 30
	jumptable_memoryaddress wTextInputResult
	.dw @validName
	.dw @invalidName

@invalidName:
	showtextlowindex <TX_440a
	enableinput
	jump2byte @loop

@validName:
	showtextlowindex <TX_4407
	disableinput
	jumptable_memoryaddress wSelectedTextOption
	.dw @nameConfirmed
	.dw @askForName

@nameConfirmed:
	asm15 scriptHlp.blossom_decideInitialChildStatus
	asm15 scriptHlp.setc6e2Bit, $00
	asm15 scriptHlp.setNextChildStage, $01
	wait 30
	showtextlowindex <TX_4408
	enableinput

@nameAlreadyGiven:
	checkabutton
	showtextlowindex <TX_4409
	jump2byte @nameAlreadyGiven


; Blossom asking for money to see a doctor
blossomScript1:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $01
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyGaveMoney
@loop:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_440b
	jumptable_memoryaddress wSelectedTextOption
	.dw @selectedYes
	.dw @selectedNo
@selectedYes:
	wait 30
	showtextlowindex <TX_440c
	jumptable_memoryaddress wSelectedTextOption
	.dw @give150Rupees
	.dw @give50Rupees
	.dw @give10Rupees
	.dw @give1Rupee

@give150Rupees:
	asm15 scriptHlp.blossom_checkHasRupees, RUPEEVAL_150
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_150
	asm15 scriptHlp.blossom_addValueToChildStatus, $08
	asm15 scriptHlp.setc6e2Bit, $01
	asm15 scriptHlp.setNextChildStage, $02
	enableallobjects
@gave150RupeesLoop:
	showtextlowindex <TX_440d
	checkabutton
	jump2byte @gave150RupeesLoop

@give50Rupees:
	asm15 scriptHlp.blossom_checkHasRupees, RUPEEVAL_050
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_050
	asm15 scriptHlp.blossom_addValueToChildStatus, $05
	asm15 scriptHlp.setc6e2Bit, $01
	asm15 scriptHlp.setNextChildStage, $02
	enableallobjects
@gave50RupeesLoop:
	showtextlowindex <TX_440e
	checkabutton
	jump2byte @gave50RupeesLoop

@give10Rupees:
	asm15 scriptHlp.blossom_checkHasRupees, RUPEEVAL_010
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_010
	asm15 scriptHlp.blossom_addValueToChildStatus, $02
	asm15 scriptHlp.setc6e2Bit, $01
	asm15 scriptHlp.setNextChildStage, $02
	enableallobjects
@gave10RupeesLoop:
	showtextlowindex <TX_440f
	checkabutton
	jump2byte @gave10RupeesLoop

@give1Rupee:
	asm15 scriptHlp.blossom_checkHasRupees, RUPEEVAL_001
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_001
	asm15 scriptHlp.setc6e2Bit, $01
	asm15 scriptHlp.setNextChildStage, $02
	enableallobjects
@gave1RupeeLoop:
	showtextlowindex <TX_4410
	checkabutton
	jump2byte @gave1RupeeLoop

@notEnoughRupees:
	wait 30
	showtextlowindex <TX_4432
	enableallobjects
	jump2byte @loop

@selectedNo:
	wait 30
	showtextlowindex <TX_4411
	enableallobjects
	jump2byte @loop

@alreadyGaveMoney:
	checkabutton
	showtextlowindex <TX_4431
	jump2byte @alreadyGaveMoney


; Blossom tells you that the baby has gotten better
blossomScript2:
	initcollisions
script4e08:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_4412
	asm15 scriptHlp.setNextChildStage, $03
	enableallobjects
	jump2byte script4e08


; Blossom asks you how to get the baby to sleep
blossomScript3:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $02
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyGaveAdvice
	checkabutton

	setdisabledobjectsto91
	showtextlowindex <TX_4413

	asm15 scriptHlp.setc6e2Bit, $02
	asm15 scriptHlp.setNextChildStage, $04

	jumptable_memoryaddress wSelectedTextOption
	.dw @sing
	.dw @play

@sing:
	wait 30
	showtextlowindex <TX_4414
	enableallobjects
	jump2byte @alreadyGaveAdvice
@play:
	wait 30
	showtextlowindex <TX_4415
	asm15 scriptHlp.blossom_addValueToChildStatus, $0a
	enableallobjects

@alreadyGaveAdvice:
	checkabutton
	showtextlowindex <TX_4416
	jump2byte @alreadyGaveAdvice


; Blossom tells you that the child has grown
blossomScript4:
	rungenericnpclowindex <TX_4417


; Blossom says "we meet again" (linked file?)
blossomScript5:
	rungenericnpclowindex <TX_4418


; Blossom asks Link what he was like when he was a kid. (var03 is set to the child's
; current personality.)
blossomScript6:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $03
	jumptable_objectbyte Interaction.var03
	.dw @hyperactive
	.dw @shy
	.dw @curious

@hyperactive:
	jumpifobjectbyteeq Interaction.var3b, $01, @hyperactiveResponseReceived

@hyperactiveLoop1:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_4419
	callscript @askAboutLinksBehaviour
	enableallobjects
	jumpifobjectbyteeq Interaction.var3a, $00, @hyperactiveLoop1

@hyperactiveResponseReceived:
	checkabutton
	showtextlowindex <TX_4422
	jump2byte @hyperactiveResponseReceived


@shy:
	jumpifobjectbyteeq Interaction.var3b, $01, @shyReponseReceived

@shyLoop1:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_441a
	callscript @askAboutLinksBehaviour
	enableallobjects
	jumpifobjectbyteeq Interaction.var3a, $00, @shyLoop1

@shyReponseReceived:
	checkabutton
	showtextlowindex <TX_4423
	jump2byte @shyReponseReceived


@curious:
	jumpifobjectbyteeq Interaction.var3b, $01, @curiousResponseReceived

@curiousLoop1:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_441b
	callscript @askAboutLinksBehaviour
	enableallobjects
	jumpifobjectbyteeq Interaction.var3a, $00, @curiousLoop1

@curiousResponseReceived:
	checkabutton
	showtextlowindex <TX_4424
	jump2byte @curiousResponseReceived


; Blossom asks about how Link was as a child. She asks a few things before giving up.
; If Link said yes to something, var3a will be set to 1, indicating to the script that she
; got a response.
@askAboutLinksBehaviour:
	jumptable_memoryaddress wSelectedTextOption
	.dw @selectedYes_1
	.dw @selectedNo_1

@selectedYes_1:
	wait 30
	showtextlowindex <TX_441c
	asm15 scriptHlp.setc6e2Bit, $03
	writeobjectbyte Interaction.var3a, $01
	asm15 scriptHlp.blossom_addValueToChildStatus, $08
	retscript

@selectedNo_1: ; Quiet, perhaps?
	wait 30
	showtextlowindex <TX_441d
	jumptable_memoryaddress wSelectedTextOption
	.dw @selectedYes_2
	.dw @selectedNo_2

@selectedYes_2:
	wait 30
	showtextlowindex <TX_441e
	asm15 scriptHlp.setc6e2Bit, $03
	writeobjectbyte Interaction.var3a, $01
	asm15 scriptHlp.blossom_addValueToChildStatus, $05
	retscript

@selectedNo_2: ; Were you weird?
	wait 30
	showtextlowindex <TX_441f
	jumptable_memoryaddress wSelectedTextOption
	.dw @selectedYes_3
	.dw @selectedNo_3

@selectedYes_3:
	wait 30
	showtextlowindex <TX_4420
	asm15 scriptHlp.setc6e2Bit, $03
	writeobjectbyte Interaction.var3a, $01
	asm15 scriptHlp.blossom_addValueToChildStatus, $01
	retscript

@selectedNo_3: ; She gives up asking (but she'll ask again next time you talk)
	wait 30
	showtextlowindex <TX_4421
	wait 30
	retscript


; Blossom tells you about how her son's grown?
blossomScript7:
	jumptable_objectbyte Interaction.var03
	.dw @slacker
	.dw @warrior
	.dw @arborist
	.dw @singer
@slacker:
	rungenericnpclowindex <TX_4425
@warrior:
	rungenericnpclowindex <TX_4426
@arborist:
	rungenericnpclowindex <TX_4427
@singer:
	rungenericnpclowindex <TX_4428


; Blossom tells you more specifically about her son's ambitions?
blossomScript8:
	jumptable_objectbyte Interaction.var03
	.dw @slacker
	.dw @warrior
	.dw @arborist
	.dw @singer
@slacker:
	rungenericnpclowindex <TX_4429
@warrior:
	rungenericnpclowindex <TX_442a
@arborist:
	rungenericnpclowindex <TX_442b
@singer:
	rungenericnpclowindex <TX_442c


; Blossom tells you about what her son has accomplished?
blossomScript9:
	jumptable_objectbyte Interaction.var03
	.dw @slacker
	.dw @warrior
	.dw @arborist
	.dw @singer
@slacker:
	rungenericnpclowindex <TX_442d
@warrior:
	rungenericnpclowindex <TX_442e
@arborist:
	rungenericnpclowindex <TX_442f
@singer:
	rungenericnpclowindex <TX_4430


; ==============================================================================
; INTERACID_FICKLE_GIRL
; ==============================================================================
sunkenCityFickleGirlScript_text1:
	rungenericnpc TX_1c00

sunkenCityFickleGirlScript_text2:
	initcollisions
-
	checkabutton
	showtext TX_1c01
	checkabutton
	showtext TX_1c02
	jump2byte -

sunkenCityFickleGirlScript_text3:
	rungenericnpc TX_1c03


; ==============================================================================
; INTERACID_S_SUBROSIAN
; ==============================================================================
subrosianScript_smelterByAutumnTemple:
	stopifroomflag80set
	asm15 scriptHlp.subrosianFunc_58ac
	rungenericnpc TX_2705

subrosianScript_smelterText1:
	jumpifglobalflagset GLOBALFLAG_UNBLOCKED_AUTUMN_TEMPLE, @autumnTempleHint
	rungenericnpc TX_2700
@autumnTempleHint:
	rungenericnpc TX_270b
	
subrosianScript_smelterText2:
	rungenericnpc TX_2701

subrosianScript_smelterText3:
	asm15 scriptHlp.subrosianFunc_58ac
	rungenericnpc TX_2702

subrosianScript_smelterText4:
	asm15 scriptHlp.subrosianFunc_58b1
	rungenericnpc TX_2703

subrosianScript_beachText1:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
	rungenericnpc TX_290c
@datedRosa:
	rungenericnpc TX_2912
@datingRosa:
	settextid TX_2917
	jump2byte _subrosian_jump
	
subrosianScript_beachText2:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
	rungenericnpc TX_290d
@datedRosa:
	rungenericnpc TX_2913
@datingRosa:
	settextid $2918
	jump2byte _subrosian_jump
	
subrosianScript_beachText3:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
@datingRosa:
	rungenericnpc TX_290e
@datedRosa:
	rungenericnpc TX_2914
	
subrosianScript_beachText4:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
@datingRosa:
	rungenericnpc TX_290f
@datedRosa:
	rungenericnpc TX_2915
	
subrosianScript_villageText1:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
@datingRosa:
	rungenericnpc TX_2910
@datedRosa:
	rungenericnpc TX_2916

subrosianScript_villageText2:
	jumpifglobalflagset GLOBALFLAG_DATING_ROSA, @datingRosa
	rungenericnpc TX_2911
@datingRosa:
	settextid TX_2919
	jump2byte _subrosian_jump
	
_subrosian_jump:
	initcollisions
-
	checkabutton
	setdisabledobjectsto11
	setzspeed -$01c0
	wait 60
	showloadedtext
	enableallobjects
	jump2byte -
	
subrosianScript_shopkeeper:
	writememory $ccea, $05
	initcollisions
-
	checkabutton
	jumpifmemoryeq $ccea, $00, script5690
	showtext TX_2b0f
	jump2byte -
script5690:
	showtext TX_2b11
-
	checkabutton
	showtext TX_2b11
	jump2byte -
	
subrosianScript_wildsText1:
	jumpifitemobtained TREASURE_FEATHER, @gotFeatherBack
	rungenericnpc TX_2807
@gotFeatherBack:
	rungenericnpc TX_280a

subrosianScript_wildsText2:
	jumpifitemobtained TREASURE_FEATHER, @gotFeatherBack
	rungenericnpc TX_2808
@gotFeatherBack:
	rungenericnpc TX_280b

subrosianScript_wildsText3:
	rungenericnpc TX_2809

subrosianScript_strangeBrother1_stealingFeather:
	stopifroomflag40set
	writeobjectbyte $5c, $02
	callscript subrosianScript_runLeft
	checkcfc0bit 0
	orroomflag $40
	asm15 scriptHlp.subrosianFunc_58c4
	applyspeed $68
	checkcfc0bit 2
	setspeed SPEED_100
	setangle $08
	asm15 scriptHlp.subrosianFunc_58d4
	setanimation $01
	setcounter1 $10
	showtext TX_2800
	wait 30
	xorcfc0bit 3
	setzspeed -$0300
	wait 8
	xorcfc0bit 7
	playsound SND_GETSEED
	checkcfc0bit 4
	updatelinkrespawnposition
	asm15 setDeathRespawnPoint
	setanimation $03
	setspeed SPEED_200
	setangle $18
	asm15 scriptHlp.subrosianFunc_5968
	wait 4
	scriptend
subrosianScript_strangeBrother2_stealingFeather:
	loadscript subrosianScript_steaLinksFeather

subrosianScript_runLeft:
	writeobjectbyte $40, $81
	setstate $02
	setcollisionradii $06, $06
	setspeed SPEED_200
	setangleandanimation $18
	retscript

subrosianScript_strangeBrother1_inHouse:
	loadscript subrosianScript_inHouseRunFromLink

subrosianScript_strangeBrother2_inHouse:
	jumpifglobalflagset GLOBALFLAG_SAW_STRANGE_BROTHERS_IN_HOUSE, stubScript
	writeobjectbyte $5c, $01
	callscript subrosianScript_runLeft
	checkcfc0bit 0
	setzspeed -$0300
	showtext TX_2802
	xorcfc0bit 1
	setcounter1 $02
	applyspeed $40
	setglobalflag GLOBALFLAG_SAW_STRANGE_BROTHERS_IN_HOUSE
	enableallobjects
	scriptend

subrosianScript_5716:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e00

subrosianScript_westVolcanoesText1:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, stubScript
	rungenericnpc TX_3e01

subrosianScript_westVolcanoesText2:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, stubScript
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e02

subrosianScript_eastVolcanoesText1:
	rungenericnpc TX_3e03

subrosianScript_eastVolcanoesText2:
	rungenericnpc TX_3e04

subrosianScript_southOfExitToSuburbsPortal:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, stubScript
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e08

subrosianScript_nearExitToTempleRemainsNorthsPortal:
	rungenericnpc TX_3e0a

subrosianScript_wildsNearLockedDoor:
	rungenericnpc TX_3e0b

subrosianScript_boomerangSubrosianFriend:
	writeobjectbyte $5c, $02
	rungenericnpc TX_3e0d

subrosianScript_screenRightOfBoomerangSubrosian:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e10

subrosianScript_wildsInAreaWithOre:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e11
	
subrosianScript_wildsOtherSideOfTreesToOre:
	rungenericnpc TX_3e13
	
subrosianScript_wildsNorthOfStrangeBrothersHouse:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e14
	
subrosianScript_wildsOutsideStrangeBrothersHouse:
	writeobjectbyte $5c, $01
	; Place where roc's feather is gotten
	jumpifmemoryset wPastRoomFlags|<ROOM_SEASONS_160, $20, @gotFeatherBack
	rungenericnpc TX_3e29
@gotFeatherBack:
	rungenericnpc TX_3e16
	
subrosianScript_villageSouthOfShop:
	rungenericnpc TX_3e17

subrosianScript_hasLavaPoolInHouse:
	rungenericnpc TX_3e0c

subrosianScript_beachText5:
	rungenericnpc TX_3e19

subrosianScript_goldenByBombFlower:
	writeobjectbyte $5c, $03


; ==============================================================================

; Used by linked game NPCs that give secrets.
; The npcs set "var3f" to the "secret index" (corresponds to wShortSecretIndex) before
; running this script.
linkedGameNpcScript:
	initcollisions
	asm15 scriptHlp.linkedNpc_checkSecretBegun
	jumpifobjectbyteeq Interaction.var3f, $01, @secretBegun
-
	enableinput
	asm15 scriptHlp.linkedNpc_initHighTextIndex, $00
	checkabutton
	disableinput
	showloadedtext
	wait 20
	jumpiftextoptioneq $00, +
	addobjectbyte Interaction.textID, $04
	showloadedtext
	jump2byte -
+
	addobjectbyte Interaction.textID, $01
@showTextAndSecret:
	showloadedtext
	asm15 scriptHlp.linkedNpc_initHighTextIndex, $05
	wait 20
	jumpiftextoptioneq $01, @showTextAndSecret
	asm15 scriptHlp.linkedNpc_generateSecret
	asm15 scriptHlp.linkedNpc_calcLowTextIndex, <TX_5302
-
	showloadedtext
	wait 20
	jumpiftextoptioneq $01, -
	asm15 scriptHlp.linkedNpc_calcLowTextIndex, <TX_5303
	showloadedtext
	enableinput
@secretBegun:
	checkabutton
	disableinput
	asm15 scriptHlp.linkedNpc_initHighTextIndex, $05
	jump2byte @showTextAndSecret
	

; ==============================================================================
; INTERACID_S_SUBROSIAN (cont.)
; ==============================================================================
subrosianScript_signsGuy:
	initcollisions
	jumpifroomflagset $20, @ringGotten
	asm15 scriptHlp.subrosian_checkSignsDestroyed
	jumptable_memoryaddress $cfc0
	.dw @0signsBroken
	.dw @lessThan20SignsBroken
	.dw @lessThan50SignsBroken
	.dw @lessThan90SignsBroken
	.dw @lessThan100SignsBroken
	.dw @100orMoreSignsBroken
@0signsBroken:
	checkabutton
	showtext TX_3e23
	rungenericnpc TX_3e1b
@lessThan20SignsBroken:
	checkabutton
	showtext TX_3e24
	rungenericnpc TX_3e1c
@lessThan50SignsBroken:
	checkabutton
	showtext TX_3e25
	rungenericnpc TX_3e1d
@lessThan90SignsBroken:
	checkabutton
	showtext TX_3e26
	rungenericnpc TX_3e1e
@lessThan100SignsBroken:
	checkabutton
	showtext TX_3e27
	rungenericnpc TX_3e1f
@100orMoreSignsBroken:
	checkabutton
	disableinput
	showtext TX_3e20
	wait 30
	asm15 scriptHlp.subrosian_fakeReset
	wait 10
	checkpalettefadedone
	showtext TX_3e21
	wait 30
	asm15 scriptHlp.subrosian_giveSignRing
	enableinput
	jump2byte @areYouTreatingSignsProperly
@ringGotten:
	checkabutton
	showtext TX_3e28
@areYouTreatingSignsProperly:
	rungenericnpc TX_3e22


; ==============================================================================
; INTERACID_DATING_ROSA_EVENT
; ==============================================================================
rosaScript_goOnDate:
	initcollisions
	jumpifglobalflagset GLOBALFLAG_DATED_ROSA, @datedRosa
	jumpifitemobtained TREASURE_RIBBON, @haveRibbon
	rungenericnpclowindex <TX_2900
@haveRibbon:
	checkabutton
	showtextlowindex <TX_2901
	jumpiftextoptioneq $00, @givingRibbon
	showtextlowindex <TX_2902
	jump2byte @haveRibbon
@givingRibbon:
	disableinput
	setglobalflag GLOBALFLAG_DATED_ROSA
	showtextlowindex <TX_2903
	wait 10
	playsound SND_GETSEED
	asm15 scriptHlp.rosa_tradeRibbon
	setanimation $02
	wait 60
	showtextlowindex <TX_2904
	setglobalflag GLOBALFLAG_DATING_ROSA
	asm15 scriptHlp.rosa_startDate
	enableinput
	scriptend
@datedRosa:
	checkabutton
	showtextlowindex <TX_2905
	jumpiftextoptioneq $00, @acceptDate
	showtextlowindex <TX_2907
	jump2byte @datedRosa
@acceptDate:
	disableinput
	setglobalflag GLOBALFLAG_DATING_ROSA
	showtextlowindex <TX_2906
	asm15 scriptHlp.rosa_startDate
	enableinput
	scriptend


rosaScript_dateEnded:
	setspeed SPEED_100
	movedown $20
	setanimation $00
	wait 30
	showtextlowindex <TX_291a
	setanimation $02
	scriptend


; ==============================================================================
; INTERACID_SUBROSIAN_WITH_BUCKETS
; ==============================================================================
bucketSubrosianScript_text1:
	rungenericnpc TX_2706

bucketSubrosianScript_text2:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, stubScript
	rungenericnpc TX_3e06

bucketSubrosianScript_text3:
	writeobjectbyte $5c, $01
	rungenericnpc TX_3e09

bucketSubrosianScript_text4:
	rungenericnpc TX_3e0f

bucketSubrosianScript_text5:
	rungenericnpc TX_3e12

bucketSubrosianScript_text6:
	rungenericnpc TX_3e15


; ==============================================================================
; INTERACID_CHILD
; ==============================================================================

; For a summary of the child's behaviour, see:
; http://wiki.zeldahacking.net/oracle/Bipin_and_Blossom's_son

childScript00:
	scriptend

childScript_stage4_hyperactive:
	initcollisions
@loop:
	checkabutton
	showtext TX_4700
	jump2byte @loop

childScript_stage4_shy:
	initcollisions
@loop:
	checkabutton
	showtext TX_4200
	jump2byte @loop

childScript_stage4_curious:
	initcollisions
@loop:
	checkabutton
	showtext TX_4900
	jump2byte @loop


childScript_stage5_hyperactive:
	initcollisions
@loop:
	checkabutton
	showtext TX_4701
	asm15 scriptHlp.setNextChildStage, $06
	jump2byte @loop

childScript_stage5_shy:
	initcollisions
@loop:
	checkabutton
	showtext TX_4201
	asm15 scriptHlp.setNextChildStage, $06
	jump2byte @loop

childScript_stage5_curious:
	initcollisions
@loop:
	checkabutton
	showtext TX_4901
	asm15 scriptHlp.setNextChildStage, $06
	jump2byte @loop


; Stage 6: the child asks a question. The question differs based on his personality, but
; the result is always the same: wChildStatus is incremented by 4 if you answer yes.

childScript_stage6_hyperactive:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $04
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered
	checkabutton
	disableinput
	showtext TX_4702
	asm15 scriptHlp.setc6e2Bit, $04
	asm15 scriptHlp.setNextChildStage, $07
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredYes
	.dw @answeredNo

@answeredYes:
	wait 30
	showtext TX_4703
	asm15 scriptHlp.child_addValueToChildStatus, $04
	enableinput
	jump2byte @alreadyAnswered

@answeredNo:
	wait 30
	showtext TX_4704
	enableinput

@alreadyAnswered:
	checkabutton
	showtext TX_4705
	jump2byte @alreadyAnswered


childScript_stage6_shy:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $04
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered
	checkabutton
	disableinput
	showtext TX_4202
	asm15 scriptHlp.setc6e2Bit, $04
	asm15 scriptHlp.setNextChildStage, $07
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredYes
	.dw @answeredNo

@answeredYes:
	wait 30
	showtext TX_4203
	asm15 scriptHlp.child_addValueToChildStatus, $04
	enableinput
	jump2byte @alreadyAnswered

@answeredNo:
	wait 30
	showtext TX_4204
	enableinput

@alreadyAnswered:
	checkabutton
	showtext TX_4205
	jump2byte @alreadyAnswered


childScript_stage6_curious:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $04
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered
	checkabutton
	disableinput
	showtext TX_4902
	asm15 scriptHlp.setc6e2Bit, $04
	asm15 scriptHlp.setNextChildStage, $07
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredChicken
	.dw @answeredEgg

@answeredChicken:
	wait 30
	showtext TX_4903
	asm15 scriptHlp.child_addValueToChildStatus, $04
	enableinput
	jump2byte @alreadyAnswered

@answeredEgg:
	wait 30
	showtext TX_4904
	enableinput

@alreadyAnswered:
	checkabutton
	showtext TX_4905
	jump2byte @alreadyAnswered


; Stage 7: just says some text.

childScript_stage7_slacker:
	initcollisions
@loop:
	checkabutton
	showtext TX_4b00
	asm15 scriptHlp.setNextChildStage, $08
	jump2byte @loop

childScript_stage7_warrior:
	initcollisions
@loop:
	checkabutton
	showtext TX_4a00
	asm15 scriptHlp.setNextChildStage, $08
	jump2byte @loop

childScript_stage7_arborist:
	initcollisions
@loop:
	checkabutton
	showtext TX_4800
	asm15 scriptHlp.setNextChildStage, $08
	jump2byte @loop

childScript_stage7_singer:
	initcollisions
@loop:
	checkabutton
	showtext TX_4600
	asm15 scriptHlp.setNextChildStage, $08
	jump2byte @loop


; Stage 8: asks a question or makes a request. This affects what he will do in stage 9.

childScript_stage8_slacker:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $05
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered

@loop:
	checkabutton
	disableinput
	showtext TX_4b01
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredYes
	.dw @answeredNo

@answeredYes:
	wait 30
	showtext TX_4b02
	jumptable_memoryaddress wSelectedTextOption
	.dw @answered100Rupees
	.dw @answered50Rupees
	.dw @answered10Rupees
	.dw @answered0Rupees

@answered100Rupees:
	asm15 scriptHlp.child_checkHasRupees, RUPEEVAL_100
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_100
	asm15 scriptHlp.child_setStage8Response, $00
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	enableinput
@answered100Loop:
	showtext TX_4b04
	checkabutton
	jump2byte @answered100Loop

@answered50Rupees:
	asm15 scriptHlp.child_checkHasRupees, RUPEEVAL_050
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_050
	asm15 scriptHlp.child_setStage8Response, $01
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	enableinput
@answered50Loop:
	showtext TX_4b05
	checkabutton
	jump2byte @answered50Loop

@answered10Rupees:
	asm15 scriptHlp.child_checkHasRupees, RUPEEVAL_010
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_010
	asm15 scriptHlp.child_setStage8Response, $02
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	enableinput
@answered10Loop:
	showtext TX_4b06
	checkabutton
	jump2byte @answered10Loop

@answered0Rupees: ; He takes 1 rupee anyway...
	asm15 scriptHlp.child_checkHasRupees, RUPEEVAL_001
	jumpifobjectbyteeq Interaction.var3c, $01, @notEnoughRupees
	asm15 removeRupeeValue, RUPEEVAL_001
	asm15 scriptHlp.child_setStage8Response, $03
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	enableinput
@answered0Loop:
	showtext TX_4b07
	checkabutton
	jump2byte @answered0Loop

@notEnoughRupees:
	wait 30
	showtext TX_4b08
	enableinput
	jump2byte @loop

@answeredNo:
	wait 30
	showtext TX_4b03
	enableinput
	jump2byte @loop

@alreadyAnswered:
	checkabutton
	showtext TX_4b09
	jump2byte @alreadyAnswered


; Asks Link what will make him mightiest.
childScript_stage8_warrior:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $05
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered
	checkabutton
	disableinput
	showtext TX_4a01
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredDailyTraining
	.dw @answeredNo_1

@answeredNo_1:
	wait 30
	showtext TX_4a02
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredNaturalTalent
	.dw @answeredNo_2

@answeredNo_2:
	wait 30
	showtext TX_4a03
	jumptable_memoryaddress wSelectedTextOption
	.dw @answeredCaringHeart
	.dw @answeredNo_3

@answeredNo_3: ; He gives up asking
	asm15 scriptHlp.child_setStage8Response, $03
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	showtext TX_4a04
	enableinput
	wait 30
	jump2byte @alreadyAnswered

@answeredDailyTraining:
	asm15 scriptHlp.child_setStage8Response, $00
	jump2byte @gaveResponse

@answeredNaturalTalent:
	asm15 scriptHlp.child_setStage8Response, $01
	jump2byte @gaveResponse

@answeredCaringHeart:
	asm15 scriptHlp.child_setStage8Response, $02

@gaveResponse:
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	showtext TX_4a05
	wait 30
	enableinput

@alreadyAnswered:
	checkabutton
	showtext TX_4a08
	jump2byte @alreadyAnswered


; Gives Link a gasha seed.
childScript_stage8_arborist:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $05
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyGaveSeed

	checkabutton
	disableinput
	showtext TX_4801
	giveitem TREASURE_GASHA_SEED, $03
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	showtext TX_4802
	wait 30
	enableinput

@alreadyGaveSeed:
	checkabutton
	showtext TX_4803
	jump2byte @alreadyGaveSeed


; Asks link what's more important, love or courage.
childScript_stage8_singer:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $05
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyAnswered

	checkabutton
	disableinput
	showtext TX_4601
	asm15 scriptHlp.child_setStage8ResponseToSelectedTextOption, $00
	asm15 scriptHlp.setc6e2Bit, $05
	asm15 scriptHlp.setNextChildStage, $09
	wait 30
	enableinput
	jump2byte @showResponseText

@alreadyAnswered:
	checkabutton
@showResponseText:
	showtext TX_4602
	jump2byte @alreadyAnswered


; Stage 9: the child gives a reward based on your response in stage 8.

childScript_stage9_slacker:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $06
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyGaveReward
	checkabutton
	disableinput
	showtext TX_4b0a
	asm15 scriptHlp.setc6e2Bit, $06
	wait 30
	jumptable_memoryaddress wChildStage8Response
	.dw @fillSatchel
	.dw @give200Rupees
	.dw @giveGashaSeed
	.dw @give10Bombs

@fillSatchel:
	asm15 refillSeedSatchel
	showtext TX_0052
	jump2byte @justGaveReward

@give200Rupees:
	asm15 scriptHlp.child_giveRupees, RUPEEVAL_200
	showtext TX_0009
	jump2byte @justGaveReward

@giveGashaSeed:
	giveitem TREASURE_GASHA_SEED, $03
	jump2byte @justGaveReward

@give10Bombs:
	giveitem TREASURE_BOMBS, $02

@justGaveReward:
	wait 30
	enableinput
	jump2byte @showTextAfterGiving

@alreadyGaveReward:
	checkabutton
@showTextAfterGiving:
	showtext TX_4b0b
	jump2byte @alreadyGaveReward


childScript_stage9_warrior:
	initcollisions
	asm15 scriptHlp.checkc6e2BitSet, $06
	jumpifobjectbyteeq Interaction.var3b, $01, @alreadyGaveReward
	checkabutton
	disableinput
	showtext TX_4a06
	wait 30
	showtext TX_4a07
	asm15 scriptHlp.setc6e2Bit, $06
	wait 30
	jumptable_memoryaddress wChildStage8Response
	.dw @give100Rupees
	.dw @give1Heart
	.dw @restoreHealth
	.dw @give1Rupee

@give100Rupees:
	asm15 scriptHlp.child_giveRupees, RUPEEVAL_100
	showtext TX_0007
	jump2byte @justGaveReward

@give1Heart:
	asm15 scriptHlp.child_giveOneHeart, $01
	showtext TX_0051
	jump2byte @justGaveReward

@restoreHealth:
	asm15 scriptHlp.child_giveHeartRefill
	showtext TX_0053
	jump2byte @justGaveReward

@give1Rupee:
	asm15 scriptHlp.child_giveRupees, RUPEEVAL_001
	showtext TX_0001

@justGaveReward:
	wait 30
	enableinput
	jump2byte @showTextAfterGiving

@alreadyGaveReward:
	checkabutton
@showTextAfterGiving:
	showtext TX_4a08
	jump2byte @alreadyGaveReward


childScript_stage9_arborist:
	initcollisions
@loop:
	checkabutton
	disableinput
	showtext TX_4804
	wait 30
	callscript @showTip
	enableinput
	jump2byte @loop

@showTip:
	writeobjectbyte Interaction.textID+1, >TX_4800
	getrandombits   Interaction.textID,   $07
	addobjectbyte   Interaction.textID,   <TX_4805
	showloadedtext
	retscript


childScript_stage9_singer:
	initcollisions
@loop:
	checkabutton
	disableinput
	showtext TX_4603
	jumptable_memoryaddress wSelectedTextOption
	.dw @selectedYes
	.dw @selectedNo

@selectedYes:
	asm15 scriptHlp.child_playMusic
	asm15 scriptHlp.child_giveHeartRefill
	wait 30
	enableinput

@singingLoop:
	showtext TX_4604
	checkabutton
	jump2byte @singingLoop

@selectedNo:
	wait 30
	showtext TX_4605
	enableinput
	jump2byte @loop


; ==============================================================================
; INTERACID_S_GORON
; ==============================================================================
goronScript_pacingLeftAndRight:
	initcollisions
	setspeed SPEED_080
	writeobjectbyte $76, $03
	setangle ANGLE_LEFT
	setanimationfromangle
	applyspeed $a0
	wait 20
-
	writeobjectbyte $76, $01
	setangle ANGLE_RIGHT
	setanimationfromangle
	applyspeed $e0
	wait 20
	writeobjectbyte $76, $03
	setangle ANGLE_LEFT
	setanimationfromangle
	applyspeed $e0
	wait 20
	jump2byte -

goronScript_text1_biggoronSick:
	rungenericnpclowindex <TX_3701
goronScript_text1_biggoronHealed:
	rungenericnpclowindex <TX_3706

goronScript_text2:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, @finishedGame
	rungenericnpclowindex <TX_3702
@finishedGame:
	rungenericnpclowindex <TX_370e

goronScript_text3_biggoronSick:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, goronScript_text3_finishedGame
	rungenericnpclowindex <TX_3703
goronScript_text3_biggoronHealed:
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, goronScript_text3_finishedGame
	rungenericnpclowindex <TX_3707
goronScript_text3_finishedGame:
	rungenericnpclowindex <TX_370f

goronScript_text4_biggoronSick:
	rungenericnpclowindex <TX_3704

goronScript_text4_biggoronHealed:
	rungenericnpclowindex <TX_3708

goronScript_text5:
	rungenericnpclowindex <TX_3705

goronScript_upgradeRingBox:
	initcollisions
	jumpifroomflagset $40, @alreadyGivenRingBox
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_3709
	jumpiftextoptioneq $01, @answeredNo
	jumpifitemobtained TREASURE_RING_BOX, @haveRingBox
	wait 30
	showtextlowindex <TX_370d
	enableallobjects
	rungenericnpclowindex <TX_370d
@haveRingBox:
	wait 30
	showtextlowindex <TX_370a
	asm15 scriptHlp.getNextRingboxLevel
	jumpifmemoryeq $cba8, $05, @upgradeTo5
	giveitem TREASURE_RING_BOX $01
	jump2byte @finishedGivingRingBox
@upgradeTo5:
	giveitem TREASURE_RING_BOX $02
@finishedGivingRingBox:
	orroomflag $40
	enableallobjects
@alreadyGivenRingBox:
	rungenericnpclowindex <TX_370b
@answeredNo:
	wait 30
	showtextlowindex <TX_370c
	enableallobjects
	rungenericnpclowindex <TX_370c

goronScript_giveSubrosianSecret:
	initcollisions
--
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_5330
	wait 20
	jumpiftextoptioneq $00, @answeredYes
	showtextlowindex <TX_5335
	jump2byte --
@answeredYes:
	setglobalflag GLOBALFLAG_BEGAN_ELDER_SECRET
	 ; This should be "generatesecret SUBROSIAN_SECRET" but, for some reason, this is the only opcode in
	 ; seasons where the parameter doesn't have "| $30" applied? This may change the xor cipher,
	 ; but nothing else?
	 ; TODO: figure out what's up (does this cause any problems?)
	.db $86, $08
-
	showtextlowindex <TX_5333
	wait 20
	jumpiftextoptioneq $01, -
	showtextlowindex <TX_5334
	jump2byte --
	

; ==============================================================================
; INTERACID_MISC_BOY_NPCS
; ==============================================================================
boyWithDogScript_text1:
	rungenericnpc TX_1500
boyWithDogScript_text2:
	initcollisions
-
	checkabutton
	showtext TX_1501
	checkabutton
	showtext TX_1502
	jump2byte -
boyWithDogScript_text3:
	rungenericnpc TX_1406
boyWithDogScript_text4:
	rungenericnpc TX_1503
boyWithDogScript_text5:
	rungenericnpc TX_1504
boyWithDogScript_text6:
	rungenericnpc TX_1505
boyWithDogScript_text7:
	rungenericnpc TX_1506

horonVillageBoyScript_text1:
	initcollisions
-
	checkabutton
	showtext TX_1400
	checkabutton
	showtext TX_1401
	jump2byte -
horonVillageBoyScript_text2:
	initcollisions
-
	checkabutton
	setdisabledobjectsto91
	showtext TX_1402
	jumpiftextoptioneq $01, @dontKnowAboutOwls
	wait 30
	showtext TX_1403
	jump2byte @knowAboutOwls
@dontKnowAboutOwls:
	wait 30
	showtext TX_1404
@knowAboutOwls:
	enableallobjects
	jump2byte -
horonVillageBoyScript_text3:
	rungenericnpc TX_1405
horonVillageBoyScript_text4:
	rungenericnpc TX_1406
horonVillageBoyScript_text5:
	setanimation $00
	settextid TX_1407
	writeobjectbyte $7b, $00
--
	initcollisions
-
	checkabutton
	asm15 scriptHlp.seasonsFunc_15_63b8
	showloadedtext
	wait 10
	setanimationfromobjectbyte $7b
	jump2byte -
horonVillageBoyScript_text6:
	setanimation $02
	settextid TX_1408
	writeobjectbyte $7b, $02
	jump2byte --
horonVillageBoyScript_text7:
	initcollisions
-
	checkabutton
	showtext TX_1409
	writeobjectbyte $45, $00
	jump2byte -
	
springBloomBoyScript_text1:
	jumptable_memoryaddress wRoomStateModifier
	.dw @spring
	.dw @summer
	.dw @autumn
@spring:
	rungenericnpc TX_1300
@summer:
	rungenericnpc TX_1301
@autumn:
	rungenericnpc TX_1302
springBloomBoyScript_text2:
	rungenericnpc TX_1303
springBloomBoyScript_text3:
	rungenericnpc TX_1304
	
sunkenCityBoyScript_text1:
	jumpifglobalflagset GLOBALFLAG_MOBLINS_KEEP_DESTROYED, _sunkenCityBoyScript_text1_moblinsKeepDestroyed
	rungenericnpc TX_1a00
sunkenCityBoyScript_text2:
	jumpifglobalflagset GLOBALFLAG_MOBLINS_KEEP_DESTROYED, _sunkenCityBoyScript_text2_moblinsKeepDestroyed
	jump2byte sunkenCityBoyScript_text3
_sunkenCityBoyScript_text2_moblinsKeepDestroyed:
	initcollisions
	checkabutton
	showtext TX_1a02
	checkabutton
	showtext TX_1a01
	jump2byte _sunkenCityBoyScript_text2_moblinsKeepDestroyed
_sunkenCityBoyScript_text1_moblinsKeepDestroyed:
	rungenericnpc TX_1a02
sunkenCityBoyScript_text3:
	rungenericnpc TX_1a01
sunkenCityBoyScript_text4:
	rungenericnpc TX_1a03


; ==============================================================================
; INTERACID_PIRATIAN
; INTERACID_PIRATIAN_CAPTAIN
; ==============================================================================
piratianCaptainScript_inHouse:
	initcollisions
	jumpifobjectbyteeq $7a, $01, @6thEssenceGotten
	checkabutton
	showtextlowindex <TX_3a17
	disableinput
	wait 30
	enableinput
-
	checkabutton
	showtextlowindex <TX_3a18
	jump2byte -
@6thEssenceGotten:
	jumptable_objectbyte $7b
	.dw @noPiratesBell
	.dw @haveRustedPiratesBell
	.dw @haveFixedPiratesBell
@noPiratesBell:
	checkabutton
	showtextlowindex <TX_3a19
	disableinput
	writememory wTalkedToPirationCaptainState, $01
	wait 30
	enableinput
-
	checkabutton
	showtextlowindex <TX_3a1a
	jump2byte -
@haveRustedPiratesBell:
	checkabutton
	showtextlowindex <TX_3a1c
	disableinput
	writememory wTalkedToPirationCaptainState, $02
	wait 30
	enableinput
-
	checkabutton
	showtextlowindex <TX_3a1d
	jump2byte -
@haveFixedPiratesBell:
	checkabutton
	disableinput
	showtextlowindex <TX_3a1e
	wait 30
	showtextlowindex <TX_3a1f
	wait 30
	writememory wTalkedToPirationCaptainState, $02
	jumptable_memoryaddress wIsLinkedGame
	.dw @unlinkedCaptain
	.dw @linkedCaptain
@unlinkedCaptain:
	showtextlowindex <TX_3a14
	wait 30
	xorcfc0bit 0
	setcounter1 $64
	enableinput
	asm15 scriptHlp.headToPirateShip
-
	setcounter1 $ff
	jump2byte -
@linkedCaptain:
	wait 60
	showtextlowindex <TX_3a26
	asm15 scriptHlp.linkedGame_spawnAmbi
	checkcfc0bit 1
	wait 30
	showtextlowindex <TX_3a27
	wait 30
	writeobjectbyte $7c, $01
	setspeed SPEED_100
	asm15 scriptHlp.seasonsFunc_15_5a70
	jumptable_objectbyte $79
	.dw script5d7f
	.dw script5d5f
	.dw script5d6f
script5d5f:
	setanimation $02
	setangle ANGLE_LEFT
	applyspeed $0d
	movedown $21
	setanimation $02
	setangle ANGLE_RIGHT
	applyspeed $0d
	jump2byte ++
script5d6f:
	setanimation $02
	setangle ANGLE_RIGHT
	applyspeed $0d
	movedown $21
	setanimation $02
	setangle ANGLE_LEFT
	applyspeed $0d
	jump2byte ++
script5d7f:
	movedown $21
++
	loadscript linkedPirateCaptainScript_sayingByeToAmbi

piratian1FScript_text1BasedOnD6Beaten:
	initcollisions
--
	jumptable_memoryaddress wTalkedToPirationCaptainState
	.dw @noFixedPiratesBell
	.dw @noFixedPiratesBell
	.dw @haveFixedPiratesBell
@noFixedPiratesBell:
	jumpifobjectbyteeq $71, $00, --
	writeobjectbyte $71, $00
	asm15 scriptHlp.showPiratianTextBasedOnD6Done, $00
	wait 1
	jump2byte --
@haveFixedPiratesBell:
	jumpifobjectbyteeq $71, $01, @talkedTo
	jumpifmemoryset $cfc0, $01, @readyToLeave
	jump2byte @haveFixedPiratesBell
@talkedTo:
	writeobjectbyte $71, $00
	asm15 scriptHlp.showPiratianTextBasedOnD6Done, $01
	wait 1
	jump2byte @haveFixedPiratesBell
@readyToLeave:
	callscript piratianScript_jump
-
	setcounter1 $ff
	jump2byte -

piratian1FScript_text2BasedOnD6Beaten:
	initcollisions
--
	jumpifobjectbyteeq $71, $01, @talkedTo
	jumpifmemoryset $cfc0, $01, @readyToLeave
	jump2byte --
@talkedTo:
	setdisabledobjectsto91
	writeobjectbyte $71, $00
	asm15 scriptHlp.showPiratianTextBasedOnD6Done, $00
	wait 1
	enableallobjects
	jump2byte --
@readyToLeave:
	callscript piratianScript_jump
-
	setcounter1 $ff
	jump2byte -

unluckySailorScript:
	initcollisions
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, @finishedGame
	jumpifglobalflagset GLOBALFLAG_PIRATES_LEFT_FOR_SHIP, @piratesLeft
-
	checkabutton
	showtextlowindex <TX_3a0a
	jump2byte -
@piratesLeft:
	checkabutton
	showtextlowindex <TX_3a0b
	jump2byte @piratesLeft
@finishedGame:
	jumpifglobalflagset GLOBALFLAG_DONE_PIRATE_SECRET, @finishedPiratesSecret
	jumpifglobalflagset GLOBALFLAG_BEGAN_PIRATE_SECRET, @beganPiratesSecret
--
	checkabutton
	disableinput
	showtextlowindex <TX_3a2c
	jumpiftextoptioneq $00, @knowSecret
	wait 30
	showtextlowindex <TX_3a2d
	enableinput
	jump2byte --
@knowSecret:
	wait 30
	showtextlowindex <TX_3a2e
	askforsecret PIRATE_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw @incorrectSecret
	.dw @correctSecret
@correctSecret:
	showtextlowindex <TX_3a2d
	enableinput
	jump2byte --
@beganPiratesSecret:
	checkabutton
	disableinput
@incorrectSecret:
	setglobalflag GLOBALFLAG_BEGAN_PIRATE_SECRET
	showtextlowindex <TX_3a2f
	wait 30
	asm15 scriptHlp.unluckySailor_checkHave777OreChunks
	jumpifobjectbyteeq $79, $01, @have777OreChunks
-
	showtextlowindex <TX_3a31
	enableinput
	checkabutton
	disableinput
	jump2byte -
@have777OreChunks:
	showtextlowindex <TX_3a32
	asm15 scriptHlp.unluckySailor_increaseBombCapacityAndCount
	giveitem TREASURE_BOMB_UPGRADE $00
	wait 60
	setglobalflag GLOBALFLAG_DONE_PIRATE_SECRET
--
	generatesecret PIRATE_RETURN_SECRET
-
	showtextlowindex <TX_3a33
	wait 30
	jumpiftextoptioneq $00, @gotSecret
	jump2byte -
@gotSecret:
	showtextlowindex <TX_3a34
	enableinput
@finishedPiratesSecret:
	checkabutton
	disableinput
	jump2byte --

piratian2FScript_textBasedOnD6Beaten:
	initcollisions
	jumpifglobalflagset GLOBALFLAG_PIRATES_LEFT_FOR_SHIP, @piratesLeft
@showGateCombo:
	loadscript showSamasaGateCombination
@piratesLeft:
	checkabutton
	showtextlowindex <TX_3a0e
	jump2byte @piratesLeft
	
pirationScript_closeOpenCupboard:
	setspeed SPEED_100
	moveup $07
	asm15 scriptHlp.piratian_replaceTileAtPiratian, $db
	playsound SND_DOORCLOSE
	wait 10
	asm15 scriptHlp.piratian_replaceTileAtPiratian, $d9
	playsound SND_DOORCLOSE
	setanimation $00
	setangle $10
	applyspeed $07
	setspeed SPEED_200
	wait 4
	retscript
	
piratianRoofScript:
	rungenericnpclowindex <TX_3a0f
	
samasaGatePiratianScript:
	initcollisions
	jumptable_memoryaddress wTalkedToPirationCaptainState
	.dw @notTalkedToPirateCaptainAfterD6
	.dw @talkedToPirateCaptainAfterD6
	.dw @talkedToPirateCaptainAfterD6
@notTalkedToPirateCaptainAfterD6:
	checkabutton
	showtextlowindex <TX_3a12
	jump2byte @notTalkedToPirateCaptainAfterD6
@talkedToPirateCaptainAfterD6:
	checkabutton
	showtextlowindex <TX_3a13
	wait 40
	writeobjectbyte $7c, $01
	setspeed SPEED_200
	moveleft $39
	orroomflag $40
	scriptend

piratianCaptainByShipScript:
	loadscript piratianCaptain_preCutsceneScene

piratianFromShipScript:
	writeobjectbyte $7c, $01
	asm15 objectSetVisible80
	setspeed SPEED_080
	movedown $03
	wait 20
	applyspeed $03
	wait 20
	setspeed SPEED_100
	applyspeed $0f
	applyspeed $21
	setspeed SPEED_100
	moveleft $41
	wait 4
	setspeed SPEED_080
	moveup $11
	wait 30
	showtextlowindex <TX_3a15
	wait 30
	xorcfc0bit 0
	checkcfc0bit 1
	setcounter1 $40
	setspeed SPEED_100
	moveright $41
	wait 4
	setspeed SPEED_100
	moveup $27
	callscript piratianScript_moveUpPauseThenUp
	scriptend

piratianByCaptainWhenDeparting1Script:
	checkcfc0bit 1
	wait 20
	setcounter1 $6a
	setcounter1 $44
	writeobjectbyte $7c, $01
	asm15 objectSetVisible80
	setspeed SPEED_100
	movedown $0f
	wait 4
	moveright $21
	setspeed SPEED_080
	moveup $03
	wait 20
	applyspeed $03
	wait 20
	scriptend

piratianByCaptainWhenDeparting2Script:
	checkcfc0bit 1
	wait 4
	setcounter1 $6a
	setcounter1 $44
	setcounter1 $32
	setcounter1 $44
	xorcfc0bit 2
	writeobjectbyte $7c, $01
	asm15 objectSetVisible80
	setspeed SPEED_100
	moveright $11
	wait 4
	moveup $0f
	callscript piratianScript_moveUpPauseThenUp
	scriptend
	
piratianScript_moveUpPauseThenUp:
	setspeed SPEED_080
	moveup $03
	wait 20
	applyspeed $03
	wait 20
	retscript

piratianScript_jump:
	writeobjectbyte $50, $28
	setzspeed -$0200
	playsound SND_JUMP
-
	asm15 scriptHlp.piratian_waitUntilJumpDone
	wait 1
	jumpifobjectbyteeq $7d, $00, -
	retscript


; ==============================================================================
; INTERACID_PIRATE_HOUSE_SUBROSIAN
; ==============================================================================
pirateHouseSubrosianScript_piratesAround:
	rungenericnpc TX_3a10
pirateHouseSubrosianScript_piratesLeft:
	rungenericnpc TX_3a11


; ==============================================================================
; INTERACID_SYRUP
; ==============================================================================
syrupScript_notTradedMushroomYet:
	checkabutton
	showtext TX_0b3e
	jumpiftradeitemeq $08, @haveMushroom
	jump2byte syrupScript_notTradedMushroomYet
@haveMushroom:
	setdisabledobjectsto91
	wait 30
-
	showtext TX_0b3f
	jumpiftextoptioneq $00, @tradingMushroom
	wait 30
	showtext TX_0b42
	enableallobjects
	checkabutton
	setdisabledobjectsto91
	jump2byte -
@tradingMushroom:
	wait 30
	disableinput
	giveitem TREASURE_TRADEITEM $09
	wait 30
	showtext TX_0b40
	orroomflag $40
	enableinput
-
	checkabutton
	showtext TX_0b41
	jump2byte -

syrupScript_spawnShopItems:
	spawninteraction INTERACID_SHOP_ITEM, $0b, $28, $44
	spawninteraction INTERACID_SHOP_ITEM, $07, $28, $4c
	spawninteraction INTERACID_SHOP_ITEM, $08, $28, $74
	scriptend

syrupScript_showWelcomeText:
	showtext TX_0d00
	scriptend

; "We're closed"
syrupScript_showClosedText:
	showtext TX_0d0b
	scriptend

syrupScript_purchaseItem:
.ifdef ROM_AGES
	jumptable_objectbyte Interaction.var37
.else
	jumptable_objectbyte Interaction.var38
.endif
	.dw @buyMagicPotion
	.dw @buyGashaSeed
	.dw @buyMagicPotion
	.dw @buyGashaSeed
	.dw @buyBombchus

@buyMagicPotion:
	showtextnonexitable TX_0d01
	jump2byte @checkAcceptPurchase

@buyGashaSeed:
	showtextnonexitable TX_0d05
	jump2byte @checkAcceptPurchase

@buyBombchus:
	showtextnonexitable TX_0d0a
.ifdef ROM_SEASONS
	jump2byte @checkAcceptPurchase
.endif

@checkAcceptPurchase:
	jumpiftextoptioneq $00, @tryToPurchase

	; Said "no" when asked to purchase
.ifdef ROM_AGES
	writeobjectbyte Interaction.var3a, $ff
.else
	writeobjectbyte Interaction.var3b, $ff
.endif
	writememory wcbad, $03
	writememory wTextIsActive, $01
	scriptend

@tryToPurchase:
.ifdef ROM_AGES
	jumpifmemoryeq wShopHaveEnoughRupees, $00, @enoughRupees
	writeobjectbyte Interaction.var3a, $ff
.else
	jumptable_objectbyte Interaction.var39
	.dw @enoughRupees
	.dw @notEnoughRupees
@notEnoughRupees:
	writeobjectbyte Interaction.var3b, $ff
.endif
	writememory wcbad, $01
	writememory wTextIsActive, $01
	scriptend

@enoughRupees:
.ifdef ROM_AGES
	jumptable_objectbyte Interaction.var38
	.dw @buy
	.dw _shopkeeperCantBuy
@buy:
	writeobjectbyte Interaction.var3a, $01
.else
	jumptable_objectbyte Interaction.var3a
	.dw @buy
	.dw @shopkeeperCantBuy
@buy:
	writeobjectbyte Interaction.var3b, $01
.endif
	writememory wcbad, $00
	writememory wTextIsActive, $01
	scriptend
.ifdef ROM_SEASONS
@shopkeeperCantBuy:
	writeobjectbyte Interaction.var3b, $ff
	writememory wcbad, $02
	writememory wTextIsActive, $01
	scriptend
.endif


; ==============================================================================
; INTERACID_S_ZELDA
; ==============================================================================
zeldaScript_ganonBeat:
	setcollisionradii $08, $04
	makeabuttonsensitive
	checkabutton
	setdisabledobjectsto11
	writememory $cc1d, $b0
	writememory $cc17, $01
	setanimation $06
	setcounter1 $dc
	showtext TX_3d05
	wait 60
	writememory $cc04, $0f
	scriptend

zeldaScript_afterEscapingRoomOfRites:
	loadscript zelda_triforceOnHandText

zeldaScript_zeldaKidnapped:
	loadscript zelda_kidnapped

script5fe6:
	loadscript script_14_49b6

script5fea:
	loadscript script_14_49c8

script5fee:
	checkmemoryeq $cfc0, $01
	setanimation $02
	checkmemoryeq $cfc0, $02
	setspeed SPEED_100
	movedown $45
	setanimation $00
	checkmemoryeq $cfc0, $07
	setcoords $8c, $40
	moveup $45
	setanimation $01
	checkmemoryeq $cfc0, $09
	setanimation $02
	checkmemoryeq $cfc0, $0a
	setanimation $01
	checkmemoryeq $cfc0, $0b
	movedown $49
	scriptend

zeldaScript_withAnimalsHopefulText:
	rungenericnpc TX_5010

zeldaScript_blessingBeforeFightingOnox:
	jumpifglobalflagset GLOBALFLAG_TALKED_TO_ZELDA_BEFORE_ONOX_FIGHT, @talkedToZelda
	setdisabledobjectsto11
	setspeed SPEED_100
	setangleandanimation $00
	wait 60
	applyspeed $29
	wait 10
	setspeed SPEED_060
	setangleandanimation $18
	wait 60
	applyspeed $20
	wait 30
	asm15 scriptHlp.forceLinkState8AndSetDirection, DIR_RIGHT
	showtext TX_0607
	asm15 scriptHlp.child_giveHeartRefill
	checkheartdisplayupdated
	wait 30
	setangle $08
	applyspeed $20
	wait 20
	setglobalflag GLOBALFLAG_TALKED_TO_ZELDA_BEFORE_ONOX_FIGHT
	enableinput
@talkedToZelda:
	setcoords $68, $68
	initcollisions
-
	checkabutton
	showtext TX_0608
	asm15 scriptHlp.child_giveHeartRefill
	checkheartdisplayupdated
	jump2byte -

zeldaScript_healLinkIfNeeded:
	initcollisions
	checkabutton
	asm15 scriptHlp.zelda_checkIfLinkFullyHealed
	jumpifobjectbyteeq $7f, $01, @fullyHealedAlready
	showtext TX_050c
	disableinput
	asm15 scriptHlp.child_giveHeartRefill
	checkheartdisplayupdated
	enableinput
	jump2byte @comeBackText
@fullyHealedAlready:
	showtext TX_050d
@comeBackText:
	wait 30
-
	checkabutton
	showtext TX_050e
	jump2byte -


; ==============================================================================
; INTERACID_TALON
; ==============================================================================
caveTalonScript:
	writememory $cfde, $00
	writememory $cfdf, $00
	spawninteraction INTERACID_TRADE_ITEM $08, $68, $48
	initcollisions
-
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_0b38
	jumpiftradeitemeq $07, @haveMegaphone
	wait 30
	showtextlowindex <TX_0b39
	enableallobjects
	jump2byte -
@haveMegaphone:
	wait 30
-
	showtextlowindex <TX_0b3a
	jumpiftextoptioneq $00, @usingMegaphone
	wait 30
	showtextlowindex <TX_0b3c
	enableallobjects
	checkabutton
	setdisabledobjectsto91
	jump2byte -
@usingMegaphone:
	loadscript talon_giveMushroomAfterWaking
	
returnedTalonScript:
	rungenericnpclowindex <TX_0b18


; ==============================================================================
; INTERACID_SYRUP_CUCCO
; ==============================================================================
syrupCuccoScript_awaitingMushroomText:
	showtext TX_0b3d
	scriptend

syrupCuccoScript_triedToSteal:
	showtext TX_0d09
	scriptend


; ==============================================================================
; INTERACID_PIRATE_SKULL
; ==============================================================================
pirateSkullScript_notYetCarried:
	initcollisions
	checkabutton
	jumpifitemobtained TREASURE_PIRATES_BELL, @obtainedPiratesBell
	jumpifroomflagset $40, @canCarrySkull
	showtextlowindex <TX_4d02
	orroomflag $40
	jump2byte @setState2ff
@canCarrySkull:
	showtextlowindex <TX_4d03
@setState2ff:
	setstate2 $ff
	scriptend
@obtainedPiratesBell:
	showtextlowindex <TX_4d05
	jump2byte @setState2ff
	

; ==============================================================================
; INTERACID_DIN_DANCING_EVENT
; ==============================================================================
troupeScript1:
	initcollisions
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c00
-
	checkabutton
	showloadedtext
	ormemory $cfd3, $01
	jump2byte -

troupeScript2:
	initcollisions
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c01
-
	checkabutton
	setdisabledobjectsto11
	cplinkx $48
	setanimationfromobjectbyte $48
	showloadedtext
	ormemory $cfd3, $02
	enableallobjects
	jump2byte -

troupeScript3:
	initcollisions
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c02
-
	checkabutton
	showloadedtext
	ormemory $cfd3, $04
	jump2byte -

troupeScript4:
	initcollisions
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c03
-
	checkabutton
	showloadedtext
	ormemory $cfd3, $08
	jump2byte -

troupeScript_Impa:
	initcollisions
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c04
	checkabutton
	asm15 scriptHlp.dinDancing_spinLink
	showloadedtext
	ormemory $cfd3, $10
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c05
-
	checkabutton
	asm15 scriptHlp.dinDancing_spinLink
	showloadedtext
	jump2byte -

troupeScript_stub:
troupeScript_Din:
	setcollisionradii $12, $04
	makeabuttonsensitive
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c06
-
	checkabutton
	setanimation $06
	showloadedtext
	ormemory $cfd3, $20
	jump2byte -

troupeScript_startDanceScene:
	setcollisionradii $12, $04
	makeabuttonsensitive
	asm15 scriptHlp.dinDancingEvent_setTextAdd_0a_ifLinked, <TX_0c07
-
	checkabutton
	setdisabledobjectsto11
	setanimation $06
	showloadedtext
	ormemory $cfd3, $40
	orroomflag $40
	jump2byte -

troupeScript_tornadoStart:
	loadscript tornadoScript_startDestruction

troupeScript_tornadoEnd:
	loadscript tornadoScript_endDestruction

troupeScript_inHoronVillage:
	initcollisions
	settextid TX_3d19
-
	checkabutton
	setdisabledobjectsto11
	cplinkx $48
	setanimationfromobjectbyte $48
	showloadedtext
	wait 8
	writeobjectbyte $48, $01
	setanimationfromobjectbyte $48
	enableallobjects
	jump2byte -


; ==============================================================================
; INTERACID_DIN_IMPRISONED_EVENT
; ==============================================================================
dinImprisonedScript_setDinCoords:
	setcoords $53, $82
	scriptend

dinImprisonedScript_OnoxExplainsMotive:
	loadscript dinImprisoned_OnoxExplainsMotive

dinImprisonedScript_OnoxSendsTempleDown:
	wait 60
	showtext TX_1e06
	wait 60
	writememory $cfd0, $0f
	scriptend

dinImprisonedScript_OnoxSaysComeIfYouDare:
	loadscript dinImprisoned_OnoxSaysComeIfYouDare


; ==============================================================================
; INTERACID_BIGGORON
; ==============================================================================
biggoronScript:
	setcollisionradii $22, $20
	makeabuttonsensitive
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, @finishedGame
@haventGivenSoup:
	jumpifroomflagset $40, @coldHealed
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
-
	checkabutton
	disableinput
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b26
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	jumpiftradeitemeq $04, @haveLavaSoup
	enableinput
	jump2byte -
@haveLavaSoup:
	wait 30
-
	setanimation $02
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b27
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	jumpiftextoptioneq $00, @givingSoup
	wait 30
	setanimation $00
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b2a
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
	checkabutton
	disableinput
	jump2byte -
@givingSoup:
	wait 30
	setanimation $03
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	wait 60
	setanimation $02
	asm15 scriptHlp.biggoron_loadAnimationData, $0c
	wait 60
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b28
	disableinput
	giveitem TREASURE_TRADEITEM $05
	orroomflag $40
@coldHealed:
	disableinput
	setanimation $01
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
-
	checkabutton
	disableinput
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b29
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
	jump2byte -
@finishedGame:
	asm15 scriptHlp.biggoron_checkSoupGiven
	jumpifobjectbyteeq $7f, $00, @haventGivenSoup
	setanimation $01
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	jumpifglobalflagset GLOBALFLAG_DONE_BIGGORON_SECRET, @doneBiggoronSecret
@promptSecret:
	checkabutton
	disableinput
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b52
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	jumpiftextoptioneq $00, @biggoronSecretKnown
	wait 30
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b53
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
	jump2byte @promptSecret
@biggoronSecretKnown:
	wait 30
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b54
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	askforsecret BIGGORON_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw @correctSecret
	.dw @incorrectSecret
@incorrectSecret:
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b56
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
	jump2byte @promptSecret
@correctSecret:
	loadscript biggoronScript_giveBiggoronSword
@generateSecret:
	generatesecret BIGGORON_RETURN_SECRET
-
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b58
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	wait 30
	jumpiftextoptioneq $00, -
	asm15 scriptHlp.biggoron_loadAnimationData, $0d
	showtextlowindex <TX_0b59
	asm15 scriptHlp.biggoron_loadAnimationData, $0b
	enableinput
@doneBiggoronSecret:
	checkabutton
	disableinput
	jump2byte @generateSecret
	
	
; ==============================================================================
; INTERACID_HEAD_SMELTER
; ==============================================================================
headSmelterAtTempleScript:
	initcollisions
-
	checkabutton
	disablemenu
	asm15 scriptHlp.headSmelter_disableScreenTransitions
	jumpifitemobtained TREASURE_BOMB_FLOWER, @haveBombFlower
	showtext TX_2707
	asm15 scriptHlp.headSmelter_enableScreenTransitions
	enablemenu
	jump2byte -
@haveBombFlower:
	loadscript headSmelterScript_blowUpRocks
	
headSmelterAtTempleScript_hideFromBomb:
	checkcfc0bit 0
	setstate $04
	setspeed SPEED_200
	moveleft $19
	moveup $11
	checkcfc0bit 1
	setangleandanimation $10
	checkcfc0bit 2
	movedown $21
	scriptend
	
headSmelterAtFurnaceScript:
	jumpifroomflagset $40, @oresAlreadySmelted
	jumpifitemobtained TREASURE_BLUE_ORE, @haveBlueOre
-
	rungenericnpc TX_270a
@haveBlueOre:
	jumpifitemobtained TREASURE_RED_ORE, @haveBothOres
	jump2byte -
@haveBothOres:
	initcollisions
-
	checkabutton
	showtext TX_2a00
	jumpiftextoptioneq $00, @startSmeltingOres
	showtext TX_2a01
	jump2byte -
@startSmeltingOres:
	loadscript script_14_4aea
@oresAlreadySmelted:
	rungenericnpc TX_2a05

; coordinate dancing?
script62b1:
	xorcfc0bit 0
	wait 20
	xorcfc0bit 1
	wait 20
	xorcfc0bit 2
	wait 20
	xorcfc0bit 0
	wait 20
	xorcfc0bit 1
	wait 20
	xorcfc0bit 2
	wait 20
	xorcfc0bit 0
	setcounter1 $12
	xorcfc0bit 1
	setcounter1 $12
	xorcfc0bit 2
	setcounter1 $12
	xorcfc0bit 0
	wait 20
	retscript

headSmelter_danceMovementText1:
	setspeed SPEED_100
	setstate $04
	moveup $31
	setangleandanimation $10
	setstate $05
	checkcfc0bit 7
	movedown $31
	setstate $01
	rungenericnpc TX_2702

headSmelter_danceMovementText2:
	setspeed SPEED_100
	setstate $04
	moveup $11
	moveright $21
	setangleandanimation $10
	setstate $05
	checkcfc0bit 7
	moveleft $21
	movedown $11
	setstate $01
	rungenericnpc TX_2703


; ==============================================================================
; INTERACID_SUBROSIAN_AT_D8
; ==============================================================================
subrosianAtD8Script_tossItemIntoHole:
	callscript @spin2win
	callscript @spin2win
	setspeed SPEED_200
	applyspeed $04
	asm15 scriptHlp.subrosianAtD8_spawnitem
	setangle $18
	applyspeed $04
	scriptend

@spin2win:
	setangleandanimation $00
	wait 4
	setangleandanimation $18
	wait 4
	setangleandanimation $10
	wait 4
	setangleandanimation $08
	wait 4
	retscript

subrosianAtD8Script:
	jumpifroomflagset $80, @alreadyBlewUpVolcano
	orroomflag $80
	disableinput
	playsound SND_SOLVEPUZZLE
	writememory w1Link.direction, $03
	wait 60
	showtext TX_3c01
	enableinput

@alreadyBlewUpVolcano:
	rungenericnpc TX_3c01


; ==============================================================================
; INTERACID_INGO
; ==============================================================================
ingoScript_tradingVase:
	initcollisions
	jumpifroomflagset $40, @tradedVase
-
	checkabutton
	setdisabledobjectsto91
	setanimation $05
	showtextlowindex <TX_0b2b
	setanimationfromangle
	jumpiftradeitemeq $05, @haveVase
	enableallobjects
	jump2byte -
@haveVase:
	wait 30
-
	showtextlowindex <TX_0b2c
	jumpiftextoptioneq $00, @tradingVase
	wait 30
	showtextlowindex <TX_0b2f
	enableallobjects
	checkabutton
	setdisabledobjectsto91
	jump2byte -
@tradingVase:
	wait 30
	callscript _ingoScript_yahoo
	showtextlowindex <TX_0b51
	wait 30
	showtextlowindex <TX_0b2d
	disableinput
	giveitem TREASURE_TRADEITEM $06
	spawninteraction INTERACID_MISC_STATIC_OBJECTS $09, $08, $58
	orroomflag $40
	enableinput
@tradedVase:
	checkabutton
	showtextlowindex $2e
	jump2byte @tradedVase

ingoScript_LinkApproachingVases:
	writeobjectbyte $7e, $01
	setspeed SPEED_200
	moveup $14
	wait 4
	moveleft $11
	writeobjectbyte $7e, $00
	wait 10
	setanimation $05
	showtextlowindex <TX_0b30
	writeobjectbyte $7e, $01
	getrandombits $7f, $01
	jumptable_objectbyte $7f
	.dw @blockEntrance1
	.dw @blockEntrance2
@blockEntrance1:
	moveright $11
	wait 4
	movedown $14
	writeobjectbyte $7e, $00
	enableinput
	scriptend
@blockEntrance2:
	movedown $14
	wait 4
	moveleft $19
	wait 4
	movedown $11
	wait 4
	moveright $19
	wait 4
	moveup $11
	wait 4
	moveright $11
	writeobjectbyte $7e, $00
	enableinput
	scriptend

_ingoScript_yahoo:
	asm15 scriptHlp.ingo_animatePlaySound
-
	asm15 scriptHlp.ingo_jump
	wait 1
	jumpifobjectbyteeq $7d, $00, -
	retscript


; ==============================================================================
; INTERACID_GURU_GURU
; ==============================================================================
guruGuruScript:
	initcollisions
	jumpifroomflagset $40, @alreadyTradedGrease
-
	checkabutton
	disableinput
	writeobjectbyte $7b, $00
	showtextlowindex <TX_0b48
	jumpiftradeitemeq $0a, @haveGrease
	writeobjectbyte $7b, $01
	enableinput
	jump2byte -
@haveGrease:
	wait 30
-
	showtextlowindex <TX_0b49
	jumpiftextoptioneq $00, @tradingGrease
	wait 30
	showtextlowindex <TX_0b4c
	writeobjectbyte $7b, $01
	enableinput
	checkabutton
	disableinput
	writeobjectbyte $7b, $00
	jump2byte -
@tradingGrease:
	wait 30
	showtextlowindex <TX_0b4a
	disableinput
	cplinkx $48
	addobjectbyte $48, $06
	setanimationfromobjectbyte $48
	giveitem TREASURE_TRADEITEM $0b
	orroomflag $40
	writeobjectbyte $79, $01
	setcounter1 $32
	writeobjectbyte $7b, $01
	enableinput
@alreadyTradedGrease:
	checkabutton
	disableinput
	writeobjectbyte $7b, $00
	showtextlowindex <TX_0b4b
	writeobjectbyte $7b, $01
	enableinput
	jump2byte @alreadyTradedGrease


; ==============================================================================
; INTERACID_LOST_WOODS_SWORD
; ==============================================================================
lostWoodsSwordScript:
	setcollisionradii $0c, $06
	makeabuttonsensitive
	checkabutton
	disableinput
	asm15 objectSetInvisible
	xorcfc0bit 0
	callscript @giveSword
	orroomflag $40
	wait 90
	enableinput
	scriptend
@giveSword:
	jumptable_objectbyte $42
	.dw @giveNobleSword
	.dw @giveMasterSword
@giveNobleSword:
	giveitem TREASURE_SWORD $01
	giveitem TREASURE_SWORD $04
	retscript
@giveMasterSword:
	giveitem TREASURE_SWORD $02
	giveitem TREASURE_SWORD $05
	retscript


; ==============================================================================
; INTERACID_BLAINO_SCRIPT
; ==============================================================================
blainoScript:
	initcollisions
	asm15 scriptHlp.blainoScript_spawnBlaino

@waitUntilSpokenTo:
	asm15 scriptHlp.blainoScript_saveVariables
	asm15 scriptHlp.blainoScript_adjustRupeesInText
	jumpifroomflagset $40, @beatenOnce
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_2300
	jumpiftextoptioneq $00, @acceptedFight
	jump2byte @choseNotToFight

@beatenOnce:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_230a
	jumpiftextoptioneq $00, @acceptedFight
	jump2byte @choseNotToFight

@promptCost:
	checkabutton
	setdisabledobjectsto91
	showtextlowindex <TX_2301
	jumpiftextoptioneq $00, @acceptedFight

@choseNotToFight:
	wait 30
	showtextlowindex <TX_2302
	enableallobjects
	jump2byte @promptCost

@acceptedFight:
	wait 30

@checkRupees:
	jumpifobjectbyteeq Interaction.var37, $00, @acceptedWithEnoughRupees

@notEnoughRupees:
	showtextlowindex <TX_2304
	enableallobjects
	checkabutton
	jump2byte @notEnoughRupees

@acceptedWithEnoughRupees:
	disableinput

@rulesExplanation:
	jumpifobjectbyteeq Interaction.var38, $05, @cheatedExplanation
	showtextlowindex <TX_2303
	jump2byte @checkIfUnderstoodRules

@cheatedExplanation:
	showtextlowindex <TX_230d

@checkIfUnderstoodRules:
	jumpiftextoptioneq $00, @beginFight
	wait 30
	jump2byte @rulesExplanation

@beginFight:
	asm15 scriptHlp.blainoScript_takeRupees
	asm15 fadeoutToWhite
	checkpalettefadedone
	setdisabledobjectsto11
	writememory $cced, $01
	asm15 scriptHlp.blainoScript_clearItemsAndPegasusSeeds
	asm15 scriptHlp.blainoScript_setLinkPositionAndState
	asm15 scriptHlp.blainoScript_spawnBlainoEnemy
	asm15 scriptHlp.putAwayLinksItems, $00
	wait 4
	asm15 fadeinFromWhite
	checkpalettefadedone
	showtextlowindex <TX_2305
	playsound SND_DING
	setmusic MUS_MINIBOSS
	enableinput
	scriptend


blainoFightDoneScript:
	disableinput
	wait 20
	playsound SND_DING
	wait 20
	playsound SND_DING
	wait 20
	playsound SND_DING
	wait 90
	asm15 fadeoutToWhite
	checkpalettefadedone
	setdisabledobjectsto11
	asm15 scriptHlp.blainoScript_setBlainoPosition
	asm15 scriptHlp.blainoScript_setLinkPositionAndState
	wait 4
	asm15 fadeinFromWhite
	checkpalettefadedone
	resetmusic
	writeobjectbyte Interaction.pressedAButton, $00
	jumptable_memoryaddress $ccec
	.dw @fightWon
	.dw @fightWon
	.dw @fightLost
	.dw @cheated

@fightWon:
	jumpifroomflagset $40, @give30Rupees
	showtextlowindex <TX_2306
	giveitem TREASURE_RICKY_GLOVES $00
	orroomflag $40
	enableinput
	jump2byte @finishedTalking

@give30Rupees:
	showtextlowindex <TX_230b
	asm15 scriptHlp.blainoScript_give30Rupees
	enableinput

@finishedTalking:
	checkabutton
	jump2byte blainoScript@waitUntilSpokenTo

@fightLost:
	showtextlowindex <TX_2308
	jumpiftextoptioneq $00, @rematch
	jump2byte @declinedRematch

@cheated:
	setglobalflag GLOBALFLAG_CHEATED_BLAINO

@cheatedText:
	showtextlowindex <TX_2309
	jumpiftextoptioneq $00, @rematch
	jump2byte @declinedRematchAfterCheating

@rematch:
	asm15 scriptHlp.blainoScript_saveVariables
	enableinput
	jump2byte blainoScript@checkRupees

@declinedRematch:
	wait 30
	showtextlowindex <TX_2302
	wait 30
	enableinput
	checkabutton
	disableinput
	jump2byte @fightLost

@declinedRematchAfterCheating:
	wait 30
	showtextlowindex <TX_2302
	wait 30
	enableinput
	checkabutton
	disableinput
	jump2byte @cheatedText


; ==============================================================================
; INTERACID_LOST_WOODS_DEKU_SCRUB
; ==============================================================================
lostWoodsDekuScrubScript:
	setcollisionradii $20, $30
	checkcollidedwithlink_onground
	setdisabledobjectsto91
	setcollisionradii $06, $06
	writeobjectbyte $77, $01
	setanimation $01
	checkobjectbyteeq $61, $ff
	writeobjectbyte $77, $02
	jumpiftradeitemeq $0b, @havePhonograph
	showtextlowindex <TX_0b4d
--
	writeobjectbyte $77, $03
	setanimation $03
	checkobjectbyteeq $61, $ff
	writeobjectbyte $77, $00
	enableallobjects
	scriptend
@havePhonograph:
	showtextlowindex <TX_0b4e
	wait 30
	showtextlowindex <TX_0b4f
	jumpiftextoptioneq $00, @playingPhonograph
	jump2byte --
@playingPhonograph:
	wait 30
	writeobjectbyte $77, $04
	setanimation $04
	writeobjectbyte $4f, $ff
	showtextlowindex <TX_0b50
	checkobjectbyteeq $61, $ff
	writeobjectbyte $4f, $00
	jump2byte --


; ==============================================================================
; INTERACID_LAVA_SOUP_SUBROSIAN
; ==============================================================================
lavaSoupSubrosianScript:
	initcollisions
	jumpifroomflagset $40, @filledPot
-
	checkabutton
	showtextlowindex <TX_0b1f
	jumpiftradeitemeq $03, @havePot
	jump2byte -
@havePot:
	setdisabledobjectsto91
	wait 30
-
	showtextlowindex <TX_0b20
	jumpiftextoptioneq $00, @fillingPot
	wait 30
	showtextlowindex <TX_0b25
	enableallobjects
	checkabutton
	setdisabledobjectsto91
	jump2byte -
@fillingPot:
	loadscript script_14_4b8e
@filledPot:
	checkabutton
	showtextlowindex <TX_0b24
	jump2byte @filledPot
	
	
script6571:
	setspeed SPEED_080
	wait 30
	setangle $00
	applyspeed $40
	setangle $08
	applyspeed $20
	setangle $00
	applyspeed $20
	setangle $18
	applyspeed $60
	setangle $00
	applyspeed $a0
	setangle $08
	applyspeed $20
	setangle $10
	applyspeed $20
	setangle $08
	applyspeed $20
	setangle $00
	applyspeed $20
script6598:
	wait 30
	createpuff
	enableallobjects
	asm15 setCameraFocusedObjectToLink
	setstate $03
	scriptend
script65a1:
	setspeed SPEED_080
	wait 30
	setangle $00
	applyspeed $40
	setangle $08
	applyspeed $20
	setangle $00
	applyspeed $60
	setangle $18
	applyspeed $60
	setangle $00
	applyspeed $60
	setangle $08
	applyspeed $40
	jump2byte script6598
script65be:
	setspeed SPEED_080
	wait 30
	setangle $18
	applyspeed $40
	setangle $00
	applyspeed $20
	setangle $08
	applyspeed $60
	setangle $00
	applyspeed $20
	setangle $18
	applyspeed $60
	setangle $00
	applyspeed $a0
	setangle $08
	applyspeed $60
	setangle $00
	applyspeed $20
	setangle $18
	applyspeed $20
	jump2byte script6598
script65e7:
	setspeed SPEED_080
	wait 30
	setangle $00
	applyspeed $80
	setangle $18
	applyspeed $20
	setangle $10
	applyspeed $40
	setangle $08
	applyspeed $40
	setangle $00
	applyspeed $20
	setangle $18
	applyspeed $60
	setangle $00
	applyspeed $a0
	setangle $08
	applyspeed $40
	jump2byte script6598
script660c:
	setcoords $58, $b8
	spawnitem TREASURE_SMALL_KEY $01
	scriptend
script6613:
	initcollisions
	jumpifroomflagset $80, script6623
	checkabutton
	showtext TX_0100
	jumpiftextoptioneq $00, script6630
	showtext TX_0103
script6623:
	checkabutton
	showtext TX_0101
	jumpiftextoptioneq $00, script6630
	showtext TX_0103
	jump2byte script6623
script6630:
	loadscript script_14_4be4
script6634:
	showtext TX_0115
	jumpiftextoptioneq $01, script6641
	asm15 fastFadeoutToWhite
	setstate2 $ff
	scriptend
script6641:
	loadscript script_14_4c06
script6645:
	giveitem $0600
	jump2byte script6657
script664a:
	giveitem $0e00
	jump2byte script6657
script664f:
	giveitem $3400
	jump2byte script6657
script6654:
	giveitem $3700
script6657:
	wait 30
	resetmusic
	enableinput
	setstate2 $ff
	initcollisions
script665e:
	checkabutton
	showloadedtext
	jump2byte script665e
script6662:
	rungenericnpc TX_3e03
script6665:
	initcollisions
	asm15 $5d54
	jumptable_memoryaddress $cfc1
	.dw script6674
	.dw script6686
	.dw script6690
	.dw script669b
script6674:
	jumpifroomflagset $20, script6678
script6678:
	checkabutton
	jumpifitemobtained $43, script6686
	setanimation $01
	showtext TX_2400
	setanimation $00
	jump2byte script6678
script6686:
	checkabutton
	setanimation $01
	showtext TX_2402
	setanimation $00
	jump2byte script6686
script6690:
	checkabutton
	orroomflag $80
	setanimation $01
	showtext TX_2403
	setanimation $00
	wait 30
script669b:
	checkabutton
	setanimation $01
	showtext $2404 ; TODO: why is TX_2404 not defined?
	setanimation $00
	jump2byte script669b
script66a5:
	showtext TX_2401
	enableinput
	scriptend
script66aa:
	checkmemoryeq $cc32, $01
	asm15 $5d89
	wait 8
	disableinput
	wait 30
	playsound SND_FLOODGATES
	asm15 objectSetVisible
	wait 60
	asm15 objectSetInvisible
	orroomflag $40
	settilehere $aa
	playsound SNDCTRL_STOPSFX
	playsound SND_SOLVEPUZZLE
	asm15 $5d92
	enableinput
	scriptend
script66ca:
	checkcfc0bit 0
	disableinput
	wait 60
	playsound SNDCTRL_STOPMUSIC
	shakescreen 120
	wait 60
	writememory $d008, $01
	orroomflag $80
	spawninteraction $6b14, $00, $00
	incstate
	scriptend
script66e0:
	checkcfc0bit 0
	asm15 $5d74
	playsound SNDCTRL_STOPMUSIC
	wait 60
	playsound SND_RUMBLE2
	shakescreen 255
	wait 60
	writememory $d008, $02
	orroomflag $80
	scriptend
script66f3:
	disableinput
	playsound SND_SOLVEPUZZLE
	settilehere $53
	createpuff
	orroomflag $40
	enableinput
	scriptend
script66fd:
	orroomflag $40
	wait 30
	playsound SND_SOLVEPUZZLE
	wait 20
	setcoords $08, $28
	createpuff
	settilehere $d0
	settileat $01, $6b
	settileat $03, $45
	scriptend
script6710:
	wait 30
	showtext TX_4d08
	xorcfc0bit 0
	enableinput
	scriptend
script6717:
	jumpifroomflagset $40, script671f
	loadscript script_14_4e3f
script671f:
	loadscript script_14_4e56
script6723:
	xorcfc0bit 0
	asm15 $5db1
	setstate2 $03
	moveup $30
	enableinput
	scriptend
script672d:
	asm15 $5e4e
	setstate2 $04
	setspeed SPEED_100
	jumprandom script6739, script673d
script6739:
	loadscript script_14_4e62
script673d:
	loadscript script_14_4e79
script6741:
	asm15 $5e4e
	setstate2 $04
	setspeed SPEED_100
	jumprandom script674d, script6751
script674d:
	loadscript script_14_4e97
script6751:
	loadscript script_14_4ec1
script6755:
	asm15 $5e4e
	setstate2 $04
	setspeed SPEED_100
	jumprandom script6761, script6765
script6761:
	loadscript script_14_4ee6
script6765:
	loadscript script_14_4f02
script6769:
	loadscript script_14_4f1b
script676d:
	loadscript script_14_4f26
script6771:
	loadscript script_14_4f44
script6775:
	wait 30
	setangleandanimation $10
	wait 30
	setangleandanimation $18
	wait 30
	setangleandanimation $08
	wait 30
	retscript
script6780:
	wait 30
	setangleandanimation $18
	wait 30
	setangleandanimation $00
	wait 30
	setangleandanimation $10
	wait 30
	retscript
script678b:
	wait 30
	setangleandanimation $00
	wait 30
	setangleandanimation $08
	wait 30
	setangleandanimation $18
	wait 30
	retscript
script6796:
	wait 30
	setangleandanimation $08
	wait 30
	setangleandanimation $10
	wait 30
	setangleandanimation $00
	wait 30
	retscript
script67a1:
	jumptable_memoryaddress $cfd0
	.dw script67a8
	.dw script67be
script67a8:
	setcoords $18, $48
	setangleandanimation $18
	callscript script67dd
	moveleft $30
	callscript script6a13
	movedown $60
	callscript script6a0b
	movedown $20
	xorcfc0bit 0
	scriptend
script67be:
	setcoords $48, $18
	setangleandanimation $00
	callscript script67dd
	moveup $30
	callscript script69fe
	moveright $30
	movedown $10
	moveright $10
	callscript script6a20
	movedown $50
	callscript script6a0b
	movedown $20
	xorcfc0bit 0
	scriptend
script67dd:
	jumpifglobalflagset $11, script67e9
script67e1:
	asm15 $5db1
	wait 60
	asm15 $5e4e
	retscript
script67e9:
	disableinput
	showtext TX_2805
	showtext TX_2806
	enableinput
	xorcfc0bit 0
	jump2byte script67e1
script67f4:
	jumpifglobalflagset $11, script67fa
	jump2byte script67e1
script67fa:
	checkcfc0bit 0
	jump2byte script67e1
script67fd:
	jumptable_memoryaddress $cfd0
	.dw script6804
	.dw script682a
script6804:
	setcoords $28, $78
	asm15 $5e4e
	setangleandanimation $10
	wait 60
	movedown $30
	callscript script6a0b
	wait 180
	moveleft $30
	moveup $30
	callscript script6a0b
	moveright $30
	movedown $30
	wait 120
	moveleft $10
	movedown $20
	callscript script6a0b
	movedown $20
	xorcfc0bit 0
	scriptend
script682a:
	setcoords $78, $28
	asm15 $5e4e
	setangleandanimation $18
	wait 60
	moveleft $10
	moveup $30
	setcounter1 $96
	moveright $20
	callscript script6a20
	moveup $30
	moveleft $20
	callscript script6a13
	wait 120
	moveright $30
	movedown $60
	callscript script6a0b
	movedown $20
	xorcfc0bit 0
	scriptend
script6851:
	jumptable_memoryaddress $cfd0
	.dw script6858
	.dw script687c
script6858:
	setcoords $38, $78
	asm15 $5e4e
	setangleandanimation $18
	wait 60
	moveleft $60
	callscript script6a13
	moveup $20
	callscript script69fe
	moveup $10
	moveright $40
	movedown $30
	callscript script6a0b
	moveleft $40
	movedown $10
	moveleft $30
	xorcfc0bit 0
	scriptend
script687c:
	setcoords $38, $48
	asm15 $5e4e
	setangleandanimation $18
	setcounter1 $7a
	setangleandanimation $10
	setcounter1 $3e
	setangleandanimation $08
	setcounter1 $3e
	setangleandanimation $00
	setcounter1 $3e
	moveleft $30
	movedown $10
	moveleft $30
	xorcfc0bit 0
	scriptend
script689a:
	jumptable_memoryaddress $cfd0
	.dw script68a1
	.dw script68be
script68a1:
	setcoords $38, $38
	asm15 $5e4e
	setangleandanimation $18
	wait 60
	moveleft $20
	callscript script6a13
	moveup $20
	moveright $30
	moveright $30
	moveup $10
	callscript script69fe
	moveup $20
	xorcfc0bit 0
	scriptend
script68be:
	setcoords $18, $18
	asm15 $5e4e
	setangleandanimation $10
	wait 60
	movedown $30
	callscript script6a0b
	moveright $50
	callscript script6a20
	moveup $10
	moveright $20
	callscript script6a20
	moveup $50
	xorcfc0bit 0
	scriptend
script68dc:
	jumptable_memoryaddress $cfd0
	.dw script68e3
	.dw script6905
script68e3:
	setcoords $08, $48
	asm15 $5e4e
	setangleandanimation $08
	wait 60
	moveright $40
	movedown $10
	callscript script6a0b
	movedown $20
	moveleft $60
	callscript script6a20
	moveup $30
	moveright $40
	callscript script6a13
	moveup $20
	xorcfc0bit 0
	scriptend
script6905:
	setcoords $08, $78
	asm15 $5e4e
	setangleandanimation $18
	wait 60
	movedown $60
	callscript script6a0b
	moveleft $30
	callscript script6a13
	moveup $30
	callscript script69fe
	moveright $40
	callscript script6a20
	moveup $50
	xorcfc0bit 0
	scriptend
script6926:
	jumptable_memoryaddress $cfd0
	.dw script692d
	.dw script694f
script692d:
	setcoords $18, $18
	asm15 $5e4e
	setangleandanimation $10
	wait 60
	movedown $60
	callscript script6a0b
	moveright $30
	callscript script6a20
	moveup $30
	moveleft $10
	moveup $30
	callscript script69fe
	moveleft $20
	movedown $80
	xorcfc0bit 0
	scriptend
script694f:
	setcoords $18, $18
	asm15 $5e4e
	setangleandanimation $10
	wait 60
	movedown $30
	moveright $30
	callscript script6a20
	movedown $30
	callscript script6a0b
	moveleft $30
	moveup $30
	moveright $30
	movedown $50
	xorcfc0bit 0
	scriptend
script696e:
	disableinput
	setcoords $48, $18
	setanimation $01
	playsound SND_SOLVEPUZZLE
	checkflagset $00, $cd00
	asm15 $5d9a
	wait 60
	showtext TX_2803
	xorcfc0bit 0
	movedown $50
	resetmusic
	spawninteraction $6b16, $48, $28
	asm15 $5dc4
	enableinput
	scriptend
script6990:
	jumptable_memoryaddress $cfd0
	.dw script6997
	.dw script69a3
script6997:
	setcoords $28, $18
	setangleandanimation $10
	callscript script67f4
	loadscript script_14_4f51
script69a3:
	setcoords $48, $28
	setangleandanimation $00
	callscript script67f4
	loadscript script_14_4f64
script69af:
	jumptable_memoryaddress $cfd0
	.dw script69b6
	.dw script69ba
script69b6:
	loadscript script_14_4f7f
script69ba:
	loadscript script_14_4fa9
script69be:
	jumptable_memoryaddress $cfd0
	.dw script69c5
	.dw script69c9
script69c5:
	loadscript script_14_4fcb
script69c9:
	loadscript script_14_4fe9
script69cd:
	jumptable_memoryaddress $cfd0
	.dw script69d4
	.dw script69d8
script69d4:
	loadscript script_14_5013
script69d8:
	loadscript script_14_503a
script69dc:
	jumptable_memoryaddress $cfd0
	.dw script69e3
	.dw script69e7
script69e3:
	loadscript script_14_504f
script69e7:
	loadscript script_14_506d
script69eb:
	jumptable_memoryaddress $cfd0
	.dw script69f2
	.dw script69f6
script69f2:
	loadscript script_14_5089
script69f6:
	loadscript script_14_50ab
script69fa:
	loadscript script_14_50ca
script69fe:
	setangleandanimation $10
	wait 30
	setangleandanimation $00
	wait 30
script6a04:
	setangleandanimation $08
	wait 30
	setangleandanimation $18
	wait 30
	retscript
script6a0b:
	setangleandanimation $00
	wait 30
	setangleandanimation $10
	wait 30
	jump2byte script6a04
script6a13:
	setangleandanimation $08
	wait 30
	setangleandanimation $18
	wait 30
script6a19:
	setangleandanimation $00
	wait 30
	setangleandanimation $10
	wait 30
	retscript
script6a20:
	setangleandanimation $18
	wait 30
	setangleandanimation $08
	wait 30
	jump2byte script6a19


script6a28:
	setcollisionradii $12, $30
	checkcollidedwithlink_onground
	disableinput
	asm15 scriptHlp.seasonsFunc_15_5e6f
	playsound SND_WHISTLE
	wait 8
	playsound SND_WHISTLE
	wait 30
	writememory $d008, $03
	wait 30
	writememory $d008, $01
	setmusic MUS_HIDE_AND_SEEK
	asm15 $5e75
	xorcfc0bit 0
	wait 20
	writememory $d008, $01
	checkcfc0bit 1
	playsound SND_SCENT_SEED
	asm15 scriptHlp.seasonsFunc_15_5e5d
	setspeed SPEED_100
	setangle $04
	incstate
	initcollisions
	wait 120
	setzspeed -$0100
	jumpifroomflagset $20, script6a6f
	jump2byte script6a66
script6a61:
	initcollisions
	jumpifroomflagset $20, script6a6f
script6a66:
	checkabutton
	showtext TX_2c00
	disableinput
	giveitem $1500
	enablemenu
script6a6f:
	enableallobjects
	checkabutton
	setdisabledobjectsto91
	jumpifglobalflagset $25, script6a7b
	showtext TX_2c01
	jump2byte script6a6f
script6a7b:
	showtext TX_2c02
	jump2byte script6a6f
script6a80:
	jumpifc6xxset $45, $02, script6ad9
	jumpifc6xxset $45, $01, script6ab8
	jumpifmemoryset $d13e, $04, script6a92
	jump2byte script6a80
script6a92:
	disablemenu
	writeobjectbyte $5a, $00
script6a96:
	jumpifmemoryset $d13e, $20, script6a9e
	jump2byte script6a96
script6a9e:
	checkmemoryeq $d12b, $00
	asm15 $5e91
	checkmemoryeq $d115, $00
	writememory $d106, $20
	checkmemoryeq $d106, $00
	asm15 $5ea6
	checkflagset $07, $d121
script6ab8:
	writememory $d103, $05
	writememory $d13f, $03
	enablemenu
	checkmemoryeq $d13d, $01
	disablemenu
	writememory $d13d, $00
	jumpifmemoryeq wIsLinkedGame, $00, script6ad5
	showtext TX_2214
	jump2byte script6ad9
script6ad5:
	disablemenu
	showtext TX_220a
script6ad9:
	disablemenu
	writememory $d13f, $03
	writememory $d103, $06
	ormemory $c645, $02
	checkflagset $02, $c645
	writememory $d13f, $03
	writememory $d103, $06
	writememory $d13d, $00
	checkmemoryeq $d13d, $01
	disablemenu
	jumpifmemoryeq wIsLinkedGame, $00, script6b0c
	showtext TX_2215
	writeobjectbyte $44, $02
	showtext TX_003a
	jump2byte script6b15
script6b0c:
	showtext TX_220d
	writeobjectbyte $44, $02
	showtext TX_006a
script6b15:
	showtext TX_2213
	ormemory $c645, $20
	checkmemoryeq $cc48, $d1
	showtext TX_2212
	enablemenu
	enableallobjects
	scriptend
script6b26:
	checkmemoryeq $d13d, $01
	disablemenu
	setdisabledobjectsto11
	jumpifitemobtained $48, script6b55
	enablemenu
	jumpifmemoryeq wIsLinkedGame, $00, script6b47
	jumpifmemoryset wRickyState, $10, script6b42
	showtext TX_200a
	jump2byte script6b4a
script6b42:
	showtext TX_200b
	jump2byte script6b4a
script6b47:
	showtext TX_2000
script6b4a:
	writememory $d13d, $00
	ormemory wRickyState, $10
	enableallobjects
	jump2byte script6b26
script6b55:
	jumpifmemoryeq wIsLinkedGame, $00, script6b6b
	jumpifmemoryset wRickyState, $10, script6b66
	showtext TX_200a
	jump2byte script6b6e
script6b66:
	showtext TX_200b
	jump2byte script6b6e
script6b6b:
	showtext TX_2000
script6b6e:
	wait 30
	showtext TX_2001
	wait 30
	writememory $d13d, $00
	jumpifmemoryeq $c610, $0b, script6b85
	showtext TX_2002
	writeobjectbyte $44, $02
	jump2byte script6b9c
script6b85:
	jumpifmemoryeq wIsLinkedGame, $00, script6b90
	showtext TX_200c
	jump2byte script6b93
script6b90:
	showtext TX_2006
script6b93:
	writeobjectbyte $44, $02
	showtext TX_0038
	showtext TX_2008
script6b9c:
	writememory $d103, $01
	checkmemoryeq $cc48, $d1
	showtext TX_2005
	enableallobjects
	scriptend
script6ba9:
	disablemenu
	writememory $d13f, $01
	jumpifmemoryset $d13e, $01, script6bb6
	jump2byte script6ba9
script6bb6:
	writememory $d108, $03
	setcounter1 $10
	writememory $d13f, $08
	writememory $d103, $04
script6bc4:
	jumpifmemoryset $d13e, $02, script6bcc
	jump2byte script6bc4
script6bcc:
	asm15 $5eb4
	enableallobjects
	checkmemoryeq $cc77, $00
	writememory $d008, $01
	setdisabledobjectsto11
	writememory $d103, $05
	setcounter1 $10
	showtext TX_2003
	setdisabledobjectsto11
	asm15 $5ec7
script6be6:
	jumpifmemoryset $d13e, $04, script6bee
	jump2byte script6be6
script6bee:
	writememory $d108, $00
	writememory $d13f, $18
	writememory $d103, $07
	setcounter1 $96
	writememory $d108, $02
	writememory $d13f, $03
	writememory $d103, $06
	enablemenu
	scriptend
script6c0a:
	checkmemoryeq $d13d, $01
	jumpifmemoryset $c644, $08, script6c1d
	showtext TX_2103
	writememory $d13d, $00
	jump2byte script6c0a
script6c1d:
	disablemenu
	jumpifmemoryeq wIsLinkedGame, $00, script6c2f
	showtext TX_2115
	writeobjectbyte $44, $02
	showtext TX_0039
	jump2byte script6c38
script6c2f:
	showtext TX_210b
	writeobjectbyte $44, $02
	showtext TX_0069
script6c38:
	showtext TX_211f
	writememory $d126, $06
	writememory $d127, $08
	ormemory $c644, $80
	checkmemoryeq $cc48, $d1
	showtext TX_211d
	enableallobjects
	enablemenu
	scriptend
script6c51:
	checkmemoryeq $d13d, $01
	jumpifmemoryset $c644, $08, script6c64
	showtext TX_2103
	writememory $d13d, $00
	jump2byte script6c51
script6c64:
	disablemenu
	showtext TX_2120
	jump2byte script6c38
script6c6a:
	writememory $d13f, $14
	writememory $d108, $00
	checkpalettefadedone
	disablemenu
	writememory $d103, $09
script6c78:
	jumpifmemoryset $d13e, $01, script6c80
	jump2byte script6c78
script6c80:
	writememory $d13f, $16
	setcounter1 $20
	writememory $d13f, $14
	setcounter1 $20
	writememory $d13f, $16
	setcounter1 $20
	writememory $d13f, $14
	setcounter1 $20
	writememory $d13f, $16
	setcounter1 $20
	ormemory $d13e, $02
	scriptend
script6ca3:
	checkmemoryeq $d13d, $01
	jumptable_objectbyte $78
	.dw script6cd8
	.dw script6cad
script6cad:
	showtext TX_2211
	writeobjectbyte $44, $02
	asm15 $5ede
	jumptable_objectbyte $7b
	.dw script6cc1
	.dw script6cbc
script6cbc:
	showtext TX_2219
	jump2byte script6cc4
script6cc1:
	showtext TX_2216
script6cc4:
	writememory $c645, $80
	enableallobjects
	checkmemoryeq $cc48, $d1
	jumptable_objectbyte $7b
	.dw script6cd3
	.dw script6cd6
script6cd3:
	showtext TX_2212
script6cd6:
	enablemenu
	scriptend
script6cd8:
	showtext TX_2210
	writememory $d13d, $00
	enableallobjects
	enablemenu
	jump2byte script6ca3
script6ce3:
	writememory $ccab, $01
	makeabuttonsensitive
	jumpifc6xxset $44, $04, script6d15
	disablemenu
	setdisabledobjectsto11
	writememory $ccab, $00
	callscript script6f43
script6cf6:
	jumptable_objectbyte $77
	.dw script6cf6
	.dw script6cfc
script6cfc:
	showtext TX_2100
	ormemory $c644, $01
	setangleandanimation $00
	checkabutton
	showtextnonexitable $2104
	jumpiftextoptioneq $00, script6d29
script6d0d:
	showtext TX_2107
	jump2byte script6d15
script6d12:
	showtext TX_211b
script6d15:
	writememory $ccab, $00
	setangleandanimation $00
	jumpifglobalflagset $2b, script6d2f
	checkabutton
	showtextnonexitable $2104
	jumpiftextoptioneq $00, script6d29
	jump2byte script6d0d
script6d29:
	jumptable_objectbyte $79
	.dw script6d12
	.dw script6d35
script6d2f:
	checkabutton
	showtextnonexitable $2106
	jump2byte script6d3d
script6d35:
	setglobalflag $2b
	writeobjectbyte $7a, $0b
	showtextnonexitable $2106
script6d3d:
	jumpiftextoptioneq $00, script6d43
	jump2byte script6d0d
script6d43:
	jumptable_objectbyte $78
	.dw script6d12
	.dw script6d49
script6d49:
	writeobjectbyte $7a, $07
	disablemenu
	showtext TX_2108
	setdisabledobjectsto11
	ormemory $c644, $08
	scriptend
script6d56:
	makeabuttonsensitive
script6d57:
	jumpifc6xxset $44, $04, script6d74
	jumpifc6xxset $44, $01, script6d63
	jump2byte script6d57
script6d63:
	callscript script6f43
script6d66:
	jumptable_objectbyte $77
	.dw script6d66
	.dw script6d6c
script6d6c:
	showtext TX_2101
	setdisabledobjectsto11
	ormemory $c644, $02
script6d74:
	setangleandanimation $18
	checkabutton
	showtext TX_210c
	jump2byte script6d74
script6d7c:
	makeabuttonsensitive
script6d7d:
	jumpifc6xxset $44, $04, script6d9b
	jumpifc6xxset $44, $02, script6d89
	jump2byte script6d7d
script6d89:
	callscript script6f43
script6d8c:
	jumptable_objectbyte $77
	.dw script6d8c
	.dw script6d92
script6d92:
	showtext TX_2102
	ormemory $c644, $04
	enablemenu
	enableallobjects
script6d9b:
	setangleandanimation $00
	checkabutton
	showtext TX_210d
	jump2byte script6d9b
script6da3:
	jumpifc6xxset $44, $20, script6daa
	jump2byte script6da3
script6daa:
	movedown $1c
	moveleft $1a
	movedown $18
	moveleft $1c
	movedown $20
	scriptend
script6db5:
	setangleandanimation $10
	callscript script6f43
script6dba:
	jumptable_objectbyte $77
	.dw script6dba
	.dw script6dc0
script6dc0:
	showtext TX_2109
	ormemory $c644, $10
script6dc7:
	jumpifc6xxset $44, $20, script6dce
	jump2byte script6dc7
script6dce:
	movedown $28
	moveleft $28
	movedown $18
	moveleft $19
	movedown $20
	enableallobjects
	enablemenu
	scriptend
script6ddb:
	jumpifc6xxset $44, $10, script6de2
	jump2byte script6ddb
script6de2:
	setangleandanimation $10
	callscript script6f43
script6de7:
	jumptable_objectbyte $77
	.dw script6de7
	.dw script6ded
script6ded:
	showtext TX_210a
	setdisabledobjectsto11
	ormemory $c644, $20
	movedown $1c
	moveleft $0f
	movedown $18
	moveleft $18
	movedown $20
	scriptend
script6e00:
	jumpifc6xxset $45, $02, script6e62
	jumpifc6xxset $45, $01, script6e5b
	setdisabledobjectsto11
	callscript script6f43
	jumptable_objectbyte $77
	.dw script6cf6
	.dw script6e14
script6e14:
	showtext TX_2200
	ormemory $d13e, $01
	setangleandanimation $00
script6e1d:
	jumpifmemoryset $d13e, $04, script6e25
	jump2byte script6e1d
script6e25:
	setcounter1 $20
	showtext TX_2203
	callscript script6f43
script6e2d:
	jumptable_objectbyte $77
	.dw script6e2d
	.dw script6e33
script6e33:
	showtext TX_2204
	setdisabledobjectsto11
	ormemory $d13e, $10
script6e3b:
	jumpifmemoryset $d13e, $40, script6e43
	jump2byte script6e3b
script6e43:
	playsound SND_DOORCLOSE
	setangle $08
	setspeed SPEED_280
	applyspeed $30
	wait 30
	setspeed SPEED_140
	moveleft $30
	showtext TX_2209
	setdisabledobjectsto11
	ormemory $c645, $01
	moveright $30
	enableallobjects
script6e5b:
	jumpifc6xxset $45, $02, script6e6f
	jump2byte script6e5b
script6e62:
	setdisabledobjectsto11
	moveleft $30
	callscript script6e9d
	setcounter1 $70
	showtext TX_220e
	jump2byte script6e7a
script6e6f:
	setdisabledobjectsto11
	moveleft $30
	callscript script6e9d
	setcounter1 $70
	showtext TX_220b
script6e7a:
	jumpifc6xxset $45, $08, script6e81
	jump2byte script6e7a
script6e81:
	enablemenu
	enableallobjects
	ormemory $d13e, $80
	moveright $30
script6e89:
	jumptable_objectbyte $7b
	.dw script6e8f
	.dw script6e89
script6e8f:
	setdisabledobjectsto11
	moveleft $30
	showtext TX_220c
	moveright $30
	enableallobjects
	ormemory $c645, $04
	scriptend
script6e9d:
	spawninteraction $7303, $88, $30
	spawninteraction $7304, $88, $50
	spawninteraction $7305, $18, $b0
	retscript
script6ead:
	jumpifc6xxset $45, $01, script6ef5
	jumpifmemoryset $d13e, $01, script6eba
	jump2byte script6ead
script6eba:
	callscript script6f43
script6ebd:
	jumptable_objectbyte $77
	.dw script6ebd
	.dw script6ec3
script6ec3:
	showtext TX_2201
	setdisabledobjectsto11
	ormemory $d13e, $02
	setangleandanimation $18
script6ecd:
	jumpifmemoryset $d13e, $10, script6ed5
	jump2byte script6ecd
script6ed5:
	showtext TX_2205
	setdisabledobjectsto11
	applyspeed $10
	writememory $d12b, $20
	setangle $08
	applyspeed $10
	ormemory $d13e, $20
script6ee7:
	jumpifmemoryset $d13e, $40, script6eef
	jump2byte script6ee7
script6eef:
	setspeed SPEED_280
	setangle $04
	applyspeed $20
script6ef5:
	scriptend
script6ef6:
	jumpifc6xxset $45, $01, script6f22
	jumpifmemoryset $d13e, $02, script6f03
	jump2byte script6ef6
script6f03:
	callscript script6f43
script6f06:
	jumptable_objectbyte $77
	.dw script6f06
	.dw script6f0c
script6f0c:
	showtext TX_2202
	setdisabledobjectsto11
	ormemory $d13e, $04
script6f14:
	jumpifmemoryset $d13e, $40, script6f1c
	jump2byte script6f14
script6f1c:
	setspeed SPEED_280
	setangle $18
	applyspeed $20
script6f22:
	scriptend
script6f23:
	setangle $00
	applyspeed $30
	ormemory $c645, $08
script6f2b:
	jumpifmemoryset $d13e, $80, script6f33
	jump2byte script6f2b
script6f33:
	spawnenemyhere $2000
	scriptend
script6f37:
	setangle $00
	applyspeed $2f
	jump2byte script6f2b
script6f3d:
	setangle $18
	applyspeed $2f
	jump2byte script6f2b
script6f43:
	setzspeed -$0300
	wait 8
	retscript
script6f48:
	setcoords $44, $50
	setcounter1 $c8
	setanimation $01
	setcounter1 $fa
	setcounter1 $60
	setanimation $02
	setcounter1 $de
	setanimation $03
	setcounter1 $7a
	scriptend
script6f5c:
	makeabuttonsensitive
	jumpifc6xxset $44, $04, script6f73
	disablemenu
	setdisabledobjectsto11
	callscript script6f43
script6f67:
	jumptable_objectbyte $77
	.dw script6f67
	.dw script6f6d
script6f6d:
	showtextlowindex $0e
	ormemory $c644, $01
script6f73:
	setangleandanimation $00
	checkabutton
	asm15 $5eec
	disablemenu
	showtextlowindex $11
	setdisabledobjectsto11
	jumptable_objectbyte $78
	.dw script6f90
	.dw script6f83
script6f83:
	wait 30
	showtextnonexitablelowindex $1c
	jumpiftextoptioneq $00, script6f95
script6f8a:
	showtextlowindex $14
	enablemenu
	enableallobjects
	jump2byte script6f73
script6f90:
	enablemenu
	enableallobjects
	wait 30
	jump2byte script6f73
script6f95:
	jumptable_objectbyte $78
	.dw script6f8a
	.dw script6f9b
script6f9b:
	writeobjectbyte $79, $01
	showtextlowindex $12
	setdisabledobjectsto11
	ormemory $c644, $08
	scriptend
script6fa6:
	makeabuttonsensitive
script6fa7:
	jumpifc6xxset $44, $04, script6fc2
	jumpifc6xxset $44, $01, script6fb3
	jump2byte script6fa7
script6fb3:
	callscript script6f43
script6fb6:
	jumptable_objectbyte $77
	.dw script6fb6
	.dw script6fbc
script6fbc:
	showtextlowindex $0f
	ormemory $c644, $02
script6fc2:
	setangleandanimation $00
	checkabutton
	asm15 $5eec
	showtextlowindex $16
	jump2byte script6fc2
script6fcc:
	makeabuttonsensitive
script6fcd:
	jumpifc6xxset $44, $04, script6fea
	jumpifc6xxset $44, $02, script6fd9
	jump2byte script6fcd
script6fd9:
	callscript script6f43
script6fdc:
	jumptable_objectbyte $77
	.dw script6fdc
	.dw script6fe2
script6fe2:
	showtextlowindex $10
	ormemory $c644, $04
	enablemenu
	enableallobjects
script6fea:
	setangleandanimation $08
	checkabutton
	asm15 $5eec
	showtextlowindex $17
	jump2byte script6fea
script6ff4:
	jumpifc6xxset $44, $10, script6ffb
	jump2byte script6ff4
script6ffb:
	setangle $04
	setanimationfromangle
	applyspeed $f0
	setangleandanimation $10
	callscript script6f43
script7006:
	jumpifc6xxset $44, $10, script700d
	jump2byte script7006
script700d:
	setangle $04
	setanimationfromangle
	applyspeed $f0
	setangleandanimation $10
	callscript script6f43
script7018:
	jumptable_objectbyte $77
	.dw script7018
	.dw script701e
script701e:
	showtextlowindex $13
	setdisabledobjectsto11
	ormemory $c644, $10
	setangle $04
	setanimationfromangle
	applyspeed $f0
	scriptend
script702c:
	makeabuttonsensitive
script702d:
	setangleandanimation $10
	checkabutton
	showtextlowindex $18
	jump2byte script702d
script7034:
	makeabuttonsensitive
script7035:
	setangleandanimation $10
	checkabutton
	showtextlowindex $19
	jump2byte script7035
script703c:
	makeabuttonsensitive
script703d:
	setangleandanimation $00
	checkabutton
	showtextlowindex $1a
	jump2byte script703d
script7044:
	rungenericnpc TX_1100
script7047:
	rungenericnpc TX_1101
script704a:
	rungenericnpc TX_1102
script704d:
	rungenericnpc TX_1103
script7050:
	rungenericnpc TX_1104
script7053:
	rungenericnpc TX_1105
script7056:
	showtextnonexitable $2b00
	callscript script70dc
	ormemory $c642, $01
	scriptend
script7061:
	showtextnonexitable $2b02
	callscript script70dc
	ormemory $c642, $04
	showtext TX_2b0d
	setdisabledobjectsto11
	scriptend
script7070:
	showtextnonexitable $2b04
	callscript script70dc
	ormemory $c642, $08
	scriptend
script707b:
	showtextnonexitable $2b01
	callscript script70dc
	ormemory $c642, $02
	scriptend
script7086:
	showtextnonexitable $2b03
	callscript script70dc
	ormemory $c642, $10
	scriptend
script7091:
	showtextnonexitable $2b03
	callscript script70dc
	ormemory $c642, $20
	scriptend
script709c:
	showtextnonexitable $2b03
	callscript script70dc
	ormemory $c642, $40
	scriptend
script70a7:
	showtextnonexitable $2b03
	callscript script70dc
	ormemory $c642, $80
	scriptend
script70b2:
	showtextnonexitable $2b09
	callscript script70dc
	scriptend
script70b9:
	showtextnonexitable $2b05
	callscript script70dc
	scriptend
script70c0:
	showtextnonexitable $2b0a
	callscript script70dc
	scriptend
script70c7:
	showtextnonexitable $2b06
	callscript script70dc
	scriptend
script70ce:
	showtextnonexitable $2b10
	callscript script70dc
	scriptend
script70d5:
	showtextnonexitable $2b08
	callscript script70dc
	scriptend
script70dc:
	jumpiftextoptioneq $00, script70e8
	writememory $cba0, $01
	writeobjectbyte $7d, $ff
	scriptend
script70e8:
	jumptable_objectbyte $7b
	.dw script70ee
	.dw script70f7
script70ee:
	playsound SND_ERROR
	showtext TX_2b12
	writeobjectbyte $7d, $ff
	scriptend
script70f7:
	jumptable_objectbyte $7c
	.dw script7102
script70fb:
	showtext TX_2b0c
	writeobjectbyte $7d, $ff
	scriptend
script7102:
	writememory $cba0, $01
	setdisabledobjectsto11
	writeobjectbyte $7d, $01
	retscript


; ==============================================================================
; INTERACID_MAKU_TREE
; ==============================================================================
script710b:
	jumptable_memoryaddress wIsLinkedGame
	.dw _unlinked
	.dw _linked
_unlinked:
	jumptable_memoryaddress $cc39
	.dw _stage0
	.dw script71a2
	.dw script71a2
	.dw script71a2
	.dw script71a2
	.dw script71a2 ; finished dungeon 5 after dungeon 4
	.dw script71a2
	.dw script71b1
	.dw script71c8
	.dw script71a2
	.dw script71a2 ; dungeons 1 to 5 except 4
	.dw script71a2 ; as above, but finally did 4
	.dw _stageMakuSeedGotten
	.dw script7223 ; highest essence gotten is 8, but wc6e5 is not $09
	.dw _stageFinishedGame
_linked:
	jumptable_memoryaddress $cc39
	.dw _stage0
	.dw script71a2
	.dw script71a2
	.dw script71b1
	.dw script71b1
	.dw script71b1
	.dw script71b1
	.dw script71b1
	.dw script71c8
	.dw script71a2
	.dw script71b1
	.dw script71b1
	.dw _stageMakuSeedGotten
	.dw script7223
	.dw _stageFinishedGame
_stage0:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
	asm15 scriptHlp.makuTree_setMakuMapText, $03
	jumpifroomflagset $40, _gnarledKeySpawned@loop
	callscript makuTreeScript_waitForBubblePopped
	disableinput
	jumpifglobalflagset GLOBALFLAG_S_18, _givenGnarledKey
	setglobalflag GLOBALFLAG_S_18
	asm15 scriptHlp.makuTree_showText, <TX_1700
	wait 30
_longText:
	asm15 scriptHlp.makuTree_showText, <TX_1701
	wait 1
	jumpiftextoptioneq $01, _acceptedQuest
	wait 30
	jump2byte _longText
_acceptedQuest:
	wait 30
_givenGnarledKey:
	asm15 scriptHlp.makuTree_showText, <TX_1702
	wait 1
	jumpifroomflagset $80, _gnarledKeySpawned
	orroomflag $80
	asm15 scriptHlp.makuTree_dropGnarledKey
_gnarledKeySpawned:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $02
	checkobjectbyteeq Interaction.animParameter, $ff
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
	enableinput
@loop:
	callscript makuTreeScript_waitForBubblePopped
	asm15 scriptHlp.makuTree_showTextAndSetMapText, <TX_1703
	callscript script729c
	jump2byte @loop
	
	
script71a2:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
@loop:
	callscript makuTreeScript_waitForBubblePopped
	asm15 scriptHlp.makuTree_showTextAndSetMapTextBasedOnStage
	callscript script729c
	jump2byte @loop

script71b1:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	setcollisionradii $24, $10
	makeabuttonsensitive
@loop:
	checkabutton
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	asm15 scriptHlp.makuTree_showTextAndSetMapTextBasedOnStage
	wait 1
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	jump2byte @loop

script71c8:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	checkflagset $00, $cd00
	disableinput
	wait 30
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	asm15 scriptHlp.makuTree_showTextBasedOnVar, <TX_1717 ; take this seed
	wait 1
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	asm15 scriptHlp.makuTree_dropMakuSeed
	setcounter1 $61
	setcounter1 $61
	playsound SND_GETSEED
	giveitem TREASURE_MAKU_SEED $00
	wait 40
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	asm15 scriptHlp.makuTree_showTextAndSetMapText, <TX_1718 ; you can defeat Onox
	wait 40
	asm15 fadeoutToBlackWithDelay, $01
	asm15 scriptHlp.makuTree_OnoxTauntingAfterMakuSeedGet
	setcounter1 $ff
	scriptend
	
	
_stageMakuSeedGotten:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	asm15 scriptHlp.seasonsFunc_15_619a
	setmusic MUS_MAKU_TREE
	asm15 scriptHlp.makuTree_setMakuMapText, <TX_1718
	setcollisionradii $24, $10
	makeabuttonsensitive
	asm15 scriptHlp.makuTree_disableEverythingIfUnlinked
@loop:
	checkabutton
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	asm15 scriptHlp.makuTree_showTextAndSetMapText, <TX_1718 ; /TX_1733
	wait 1
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	jump2byte @loop

script7223:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	asm15 scriptHlp.seasonsFunc_15_619a
	setmusic MUS_MAKU_TREE
	asm15 scriptHlp.makuTree_setMakuMapText, <TX_1738
	setcollisionradii $24, $10
	makeabuttonsensitive
@loop:
	checkabutton
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	showtext TX_1738 ; passage at my roots leads to Twinrova
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	jump2byte @loop

_stageFinishedGame:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
	asm15 scriptHlp.makuTree_setMakuMapText, <TX_1739
@loop:
	callscript makuTreeScript_waitForBubblePopped
	showtext TX_1739
	callscript script729c
	jump2byte @loop


script7255:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
	checkcfc0bit 7
	playsound SND_POOF
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $03
	scriptend


script7261:
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	checkmemoryeq $cfc0, $02
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	showtext TX_3d07
	wait 1
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $04
	wait 60
	writememory $cfc0, $03
	setcounter1 $ff
	scriptend


makuTreeScript_waitForBubblePopped:
	checkcfc0bit 7
	disablemenu
	writememory wcc95, $80
	playsound SND_POOF
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $03
	checkmemoryeq wcc95, $ff
	setdisabledobjectsto11
	checkobjectbyteeq $61, $ff
	setdisabledobjectsto91
	writememory wcc95, $00
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $01
	enablemenu
	retscript

script729c:
	enableallobjects
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $02
	checkobjectbyteeq Interaction.animParameter, $ff
	asm15 scriptHlp.makuTree_storeIntoVar37SpawnBubbleIf0, $00
	retscript


script72a9:
	initcollisions
script72aa:
	checkabutton
	showtext TX_1d00
	checkabutton
	showtext TX_1d01
	jump2byte script72aa
script72b4:
	rungenericnpc TX_1d02
script72b7:
	rungenericnpc TX_1d03
script72ba:
	rungenericnpc TX_1d04
script72bd:
	rungenericnpc TX_1d05
script72c0:
	initcollisions
	jumpifglobalflagset $16, script72e0
	jumpifitemobtained $2e, script72dd
	rungenericnpc TX_1800
script72cc:
	initcollisions
	jumpifglobalflagset $16, script72d3
	jump2byte script72dd
script72d3:
	checkabutton
	showtext TX_1802
	checkabutton
	showtext TX_1801
	jump2byte script72d3
script72dd:
	rungenericnpc TX_1801
script72e0:
	rungenericnpc TX_1802
script72e3:
	rungenericnpc TX_1803
script72e6:
	rungenericnpc TX_1804
script72e9:
	rungenericnpc TX_1805
script72ec:
	initcollisions
script72ed:
	enableinput
	checkabutton
	disableinput
	jumpifitemobtained $2e, script7311
	jumpifitemobtained $54, script72ff
	showtext TX_3400
	orroomflag $40
	jump2byte script72ed
script72ff:
	jumpifroomflagset $40, script7309
	showtext TX_3400
	orroomflag $40
	wait 30
script7309:
	showtext TX_3401
	wait 20
	giveitem $2e00
	wait 20
script7311:
	showtext TX_3404
	jump2byte script72ed
script7316:
	rungenericnpc TX_3402
script7319:
	rungenericnpc TX_3403
script731c:
	scriptend


; ==============================================================================
; INTERACID_OLD_MAN_WITH_JEWEL
; ==============================================================================

oldManWithJewelScript:
	initcollisions
	jumpifroomflagset $40, @alreadyGaveJewel
	jumptable_objectbyte Interaction.var38
	.dw @dontHaveEssences
	.dw @haveEssences

@dontHaveEssences:
	checkabutton
	showtextlowindex <TX_3601
	jump2byte @dontHaveEssences

@haveEssences:
	checkabutton
	showtextlowindex $02
	disableinput
	giveitem TREASURE_ROUND_JEWEL, $00
	orroomflag $40
	enableinput

@alreadyGaveJewel:
	checkabutton
	showtextlowindex <TX_3603
	jump2byte @alreadyGaveJewel


; ==============================================================================
; INTERACID_JEWEL_HELPER
; ==============================================================================

jewelHelperScript_insertedJewel:
	wait 60
	showtext TX_3600
	scriptend

jewelHelperScript_insertedAllJewels:
	wait 60
	orroomflag $80
	scriptend

script7345:
	stopifitemflagset
	jumptable_memoryaddress wIsLinkedGame
	.dw script734d
	.dw script7357
script734d:
	spawnitem TREASURE_PYRAMID_JEWEL $00
script7350:
	jumpifitemobtained $4d, script7356
	jump2byte script7350
script7356:
	scriptend
script7357:
	spawnitem TREASURE_RUPEES RUPEEVAL_100
	scriptend
script735b:
	jumpifroomflagset $40, script737a
	checkmemoryeq wNumTorchesLit, $01
	orroomflag $40
	wait 40
	playsound SND_SOLVEPUZZLE
	wait 60
	playsound SND_BIGSWORD
	settileat $76, $a7
	setcounter1 $02
	settileat $66, $a7
	wait 10
	playsound SND_BIGSWORD
	wait 15
	playsound SND_BIGSWORD
	scriptend
script737a:
	settileat $77, $a1
	scriptend
script737e:
	loadscript script_14_50d3
script7382:
	stopifitemflagset
	jumptable_memoryaddress wIsLinkedGame
	.dw script7392
	.dw script739e
script738a:
	stopifitemflagset
	jumptable_memoryaddress wIsLinkedGame
	.dw script739e
	.dw script7392
script7392:
	writememory $ccbd, $4e
	writememory $ccbe, $00
	settileat $57, $f1
	scriptend
script739e:
	writememory $ccbd, $28
	writememory $ccbe, $06
	settileat $57, $f1
	scriptend
script73aa:
	scriptend
script73ab:
	setcollisionradii $11, $0e
	makeabuttonsensitive
script73af:
	checkabutton
	showtext TX_3802
	jump2byte script73af
script73b5:
	setcollisionradii $0b, $0e
	makeabuttonsensitive
script73b9:
	checkabutton
	showtext TX_3803
	jump2byte script73b9
script73bf:
	setcollisionradii $0b, $0e
	makeabuttonsensitive
script73c3:
	checkabutton
	showtext TX_3805
	jump2byte script73c3
script73c9:
	loadscript script_14_5190
script73cd:
	checkcfc0bit 0
	setspeed SPEED_200
	setanimation $05
	setangle $10
	applyspeed $21
	wait 40
	scriptend
script73d8:
	setspeed SPEED_100
	checkmemoryeq $cfc0, $02
	setangle $00
	applyspeed $25
	checkmemoryeq $cfc0, $05
	setangle $10
	applyspeed $25
	checkmemoryeq $cfc0, $06
	setangle $00
	applyspeed $25
	scriptend
script73f3:
	rungenericnpc TX_3800
script73f6:
	setcoords $40, $7e
	initcollisions
	setspeed SPEED_080
	setangle $1f
	setanimationfromangle
script7400:
	checkcfc0bit 0
	writeobjectbyte $5a, $82
	applyspeed $10
	wait 20
	xorcfc0bit 1
	setangle $0f
	setanimationfromangle
	xorcfc0bit 0
	wait 10
	xorcfc0bit 2
	xorcfc0bit 1
	applyspeed $30
	wait 20
	xorcfc0bit 3
	xorcfc0bit 2
	wait 20
	setangle $1f
	setanimationfromangle
	applyspeed $20
	setcoords $40, $7e
	jump2byte script7400
script7421:
	checkcfc0bit 0
	wait 10
	setspeed SPEED_200
	callscript script7430
	wait 4
	setanimation $02
	setangle $10
	applyspeed $1a
	scriptend
script7430:
	jumpifobjectbyteeq $43, $01, script743c
	setanimation $01
	setangle $08
	applyspeed $09
	retscript
script743c:
	setanimation $03
	setangle $18
	applyspeed $09
	retscript
script7443:
	setspeed SPEED_100
	checkmemoryeq $cfc0, $01
	moveleft $29
	setanimation $09
	checkmemoryeq $cfc0, $03
	asm15 scriptHlp.seasonsFunc_15_6206
	wait 1
	scriptend
script7456:
	setspeed SPEED_100
	checkmemoryeq $cfc0, $01
	moveright $29
	setanimation $09
	checkmemoryeq $cfc0, $03
	asm15 scriptHlp.seasonsFunc_15_6206
	wait 1
	scriptend
script7469:
	checkmemoryeq $cfc0, $03
	asm15 scriptHlp.seasonsFunc_15_61fa
	wait 1
	scriptend
script7472:
	initcollisions
	jumpifroomflagset $40, script7483
	checkabutton
	disableinput
	showtextlowindex $03
	asm15 scriptHlp.seasonsFunc_15_6226
	wait 8
	checkrupeedisplayupdated
	orroomflag $40
	enableinput
script7483:
	checkabutton
	showtextlowindex $07
	jump2byte script7483
script7488:
	initcollisions
	jumpifroomflagset $40, script749e
	checkabutton
	disableinput
	showtextlowindex $00
	asm15 scriptHlp.seasonsFunc_15_620f
	jumpifobjectbyteeq $7f, $00, script74a3
	wait 8
	checkrupeedisplayupdated
	orroomflag $40
	enableinput
script749e:
	checkabutton
	showtextlowindex $01
	jump2byte script749e
script74a3:
	wait 30
	showtextlowindex $02
	enableinput
	jump2byte script749e
script74a9:
	initcollisions
	jumpifroomflagset $40, script74ef
	disableinput
	setspeed SPEED_100
	wait 120
	setangleandanimation $10
	applyspeed $20
	setangleandanimation $08
	setcounter1 $06
	applyspeed $20
	writememory $cfd0, $01
	checkmemoryeq $cfd0, $02
	wait 30
	jumpifmemoryeq wIsLinkedGame, $01, script74d0
	showtext TX_2500
	jump2byte script74d3
script74d0:
	showtext TX_2501
script74d3:
	setmusic SNDCTRL_FAST_FADEOUT
	setangleandanimation $18
	setcounter1 $06
	applyspeed $30
	setmusic MUS_OVERWORLD_PRES
	setangleandanimation $00
	setcounter1 $06
	applyspeed $20
	setanimation $02
	wait 30
	writememory $cfd0, $03
	orroomflag $40
	setglobalflag $0a
	enableinput
script74ef:
	jumpifglobalflagset $18, script74f6
	rungenericnpc TX_2503
script74f6:
	rungenericnpc TX_2505
script74f9:
	jumpifitemobtained $7, script7500
	rungenericnpc TX_2510
script7500:
	rungenericnpc TX_2506
script7503:
	rungenericnpc TX_2507
script7506:
	jumpifitemobtained $2e, script750d
	rungenericnpc TX_2508
script750d:
	rungenericnpc TX_2509
script7510:
	rungenericnpc TX_250a
script7513:
	asm15 scriptHlp.seasonsFunc_15_623b
	jumptable_memoryaddress $cfc0
	.dw script751d
	.dw script750d
script751d:
	rungenericnpc TX_250b
script7520:
	rungenericnpc TX_250c
script7523:
	rungenericnpc TX_250d
script7526:
	rungenericnpc TX_250e
script7529:
	initcollisions
script752a:
	checkabutton
	asm15 scriptHlp.seasonsFunc_15_63b8
	showtext TX_0600
	wait 10
	setanimationfromobjectbyte $7b
	jump2byte script752a
script7537:
	jumpifglobalflagset $26, script7546
	setspeed SPEED_100
	setangleandanimation $00
	wait 60
	applyspeed $29
	wait 10
	setangleandanimation $18
	wait 60
script7546:
	setcoords $78, $68
	rungenericnpc TX_0609
script754c:
	loadscript script_14_51c5
script7550:
	rungenericnpc TX_0502
script7553:
	rungenericnpc TX_250f
script7556:
	playsound SND_RUMBLE2
	callscript script756f
	setcounter1 $23
	callscript script756f
	setcounter1 $23
	playsound SND_RUMBLE2
	callscript script756f
	setcounter1 $23
	callscript script756f
	setcounter1 $ff
	scriptend
script756f:
	playsound SND_KILLENEMY
	asm15 scriptHlp.seasonsFunc_15_624c
	setcounter1 $05
	playsound SND_KILLENEMY
	asm15 scriptHlp.seasonsFunc_15_624f
	setcounter1 $05
	playsound SND_KILLENEMY
	asm15 scriptHlp.seasonsFunc_15_624c
	setcounter1 $05
	playsound SND_KILLENEMY
	asm15 scriptHlp.seasonsFunc_15_624c
	retscript
script758a:
	setcollisionradii $12, $06
	makeabuttonsensitive
	jumptable_objectbyte $7f
	.dw script7598
	.dw script759d
	.dw script75c1
	.dw script75f0
script7598:
	checkabutton
	showtextlowindex $00
	jump2byte script7598
script759d:
	checkabutton
	disableinput
	callscript script7642
	showtextlowindex $03
	jumpiftextoptioneq $00, script75b8
	wait 30
	showtextlowindex $06
	setanimation $01
	wait 30
	showtextlowindex $07
	callscript script7650
	giveitem $4a02
	jump2byte script7675
script75b8:
	wait 30
	showtextlowindex $04
	enableinput
script75bc:
	checkabutton
	showtextlowindex $05
	jump2byte script75bc
script75c1:
	checkabutton
	disableinput
	callscript script7642
	jumpifitemobtained $1, script75cc
	jump2byte script75eb
script75cc:
	showtextlowindex $0a
	jumpiftextoptioneq $00, script75e2
	wait 30
	showtextlowindex $0c
	setanimation $01
	wait 30
	showtextlowindex $0d
	callscript script7650
	asm15 scriptHlp.seasonsFunc_15_62a2
	jump2byte script7675
script75e2:
	wait 30
	showtextlowindex $0b
	enableinput
script75e6:
	checkabutton
	showtextlowindex $05
	jump2byte script75e6
script75eb:
	showtextlowindex $13
	enableinput
	jump2byte script75e6
script75f0:
	jumpifglobalflagset $5e, script763e
script75f4:
	checkabutton
	disableinput
	callscript script7642
	jumpifitemobtained $1, script7603
	enableinput
script75fe:
	showtextlowindex $18
	checkabutton
	jump2byte script75fe
script7603:
	showtextlowindex $0e
	jumpiftextoptioneq $00, script7611
	wait 30
	showtextlowindex $10
	enableinput
	checkabutton
	disableinput
	jump2byte script7603
script7611:
	wait 30
	showtextlowindex $0f
	askforsecret SMITH_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw script7623
	.dw script761e
script761e:
	showtextlowindex $11
	enableinput
	jump2byte script75f4
script7623:
	setglobalflag $54
	showtextlowindex $12
	callscript script7650
	asm15 scriptHlp.seasonsFunc_15_62a7
	setglobalflag $5e
	wait 30
script7630:
	generatesecret SMITH_RETURN_SECRET
script7632:
	showtextlowindex $16
	wait 30
	jumpiftextoptioneq $00, script763b
	jump2byte script7632
script763b:
	showtextlowindex $17
	enableinput
script763e:
	checkabutton
	disableinput
	jump2byte script7630
script7642:
	showtextlowindex $00
	wait 30
	showtextlowindex $01
	setanimation $01
	wait 30
	showtextlowindex $02
	setanimation $02
	wait 30
	retscript
script7650:
	asm15 fadeoutToWhite
	checkpalettefadedone
	setcoords $50, $70
	setanimation $01
	wait 60
	asm15 fadeinFromWhite
	checkpalettefadedone
	wait 30
	setspeed SPEED_200
	setanimation $00
	setangle $00
	applyspeed $0d
	wait 4
	setanimation $03
	setangle $18
	applyspeed $21
	wait 4
	setanimation $02
	wait 30
	showtextlowindex $08
	retscript
script7675:
	wait 4
	enableinput
script7677:
	checkabutton
	showtextlowindex $09
	jump2byte script7677
script767c:
	loadscript script_14_51f0
script7680:
	loadscript script_14_520a
script7684:
	scriptend
script7685:
	initcollisions
script7686:
	checkabutton
	disableinput
	wait 10
	writeobjectbyte $78, $01
	asm15 scriptHlp.seasonsFunc_15_62ca
	wait 8
	showtext TX_3d18
	enableinput
	writeobjectbyte $78, $00
	setanimation $06
	jump2byte script7686
script769b:
	loadscript script_14_521b
script769f:
	checkmemoryeq $cfc0, $01
	setanimation $01
	checkobjectbyteeq $61, $01
	writememory $cfc0, $02
	scriptend
script76ad:
	checkmemoryeq $cfc0, $02
	asm15 scriptHlp.seasonsFunc_15_62d9
	setanimation $03
	scriptend
script76b7:
	checkmemoryeq $cfc0, $03
	setangle $18
	setspeed SPEED_100
	applyspeed $20
	setcounter1 $06
	setanimation $04
	wait 30
	showtext TX_3d0a
	wait 30
	setangle $08
	setanimation $05
	setcounter1 $06
	applyspeed $20
	wait 10
	setanimation $07
	writememory $cfc0, $04
	setcounter1 $80
	scriptend
script76dc:
	checkmemoryeq $cfc0, $05
	setangle $18
	setspeed SPEED_100
	applyspeed $10
	setanimation $0a
	setangle $10
	setcounter1 $06
	applyspeed $10
	setanimation $0b
	setangle $18
	setcounter1 $06
	applyspeed $12
	setanimation $08
	setangle $00
	wait 30
	showtext TX_3d08
	setcounter1 $80
	writememory $cfc0, $06
	scriptend
script7705:
	setcoords $40, $70
	setcollisionradii $1c, $1c
	checkcollidedwithlink_ignorez
	setdisabledobjectsto91
	asm15 scriptHlp.seasonsFunc_15_6304
	jumptable_memoryaddress wIsLinkedGame
	.dw script7717
	.dw script7725
script7717:
	jumpifroomflagset $40, script7721
	showtextlowindex $00
	orroomflag $40
	enableallobjects
	scriptend
script7721:
	showtextlowindex $01
	enableallobjects
	scriptend
script7725:
	jumpifroomflagset $40, script772f
	showtextlowindex $02
	orroomflag $40
	enableallobjects
	scriptend
script772f:
	showtextlowindex $03
	enableallobjects
	scriptend
script7733:
	setcoords $68, $88
	setcollisionradii $08, $08
	checknotcollidedwithlink_ignorez
	createpuff
	wait 4
	settileat $68, $ac
	playsound SND_DOORCLOSE
	setcoords $40, $50
	setcollisionradii $28, $08
	checkcollidedwithlink_ignorez
	setdisabledobjectsto91
	asm15 scriptHlp.seasonsFunc_15_6304
	asm15 scriptHlp.seasonsFunc_15_62fc
	showtextlowindex $04
	playsound SND_BOOMERANG
	wait 30
	setmusic MUS_MINIBOSS
	xorcfc0bit 0
	enableallobjects
	checkcfc0bit 0
	setdisabledobjectsto91
	callscript script7776
	callscript script7776
	callscript script7783
	callscript script7783
	callscript script7783
	callscript script7783
	callscript script7783
	callscript script7783
	asm15 scriptHlp.seasonsFunc_15_62e2
	scriptend
script7776:
	playsound SND_BIG_EXPLOSION_2
	asm15 clearFadingPalettes
	wait 8
	playsound SND_BIG_EXPLOSION_2
	asm15 clearPaletteFadeVariablesAndRefreshPalettes
	wait 8
	retscript
script7783:
	playsound SND_BIG_EXPLOSION_2
	asm15 clearFadingPalettes
	wait 4
	playsound SND_BIG_EXPLOSION_2
	asm15 clearPaletteFadeVariablesAndRefreshPalettes
	wait 4
	retscript
script7790:
	stopifroomflag40set
	disableinput
	asm15 seasonsFunc_3e52
	showtextlowindex $05
	xorcfc0bit 0
	setcounter1 $4b
	orroomflag $40
	enableinput
	scriptend
script779e:
	setspeed SPEED_0a0
script77a0:
	applyspeed $0e
	setcounter1 $50
	jump2byte script77a0
script77a6:
	wait 30
	jump2byte script77a6
script77a9:
	setstate $03
	setdisabledobjectsto11
	wait 240
	spawninteraction $b102, $98, $78
	checkcfc0bit 0
	xorcfc0bit 0
	wait 240
	writememory $ccae, $02
	playsound SND_BIG_EXPLOSION
	wait 60
	setstate $02
	xorcfc0bit 2
	checkcfc0bit 0
	asm15 scriptHlp.seasonsFunc_15_630a
	scriptend
script77c4:
	setstate $02
	setspeed SPEED_100
	callscript script7801
	asm15 objectSetVisiblec1
	setzspeed -$01c0
	wait 30
	showtextlowindex $01
	callscript script7809
	showtextlowindex $03
	callscript script7809
	showtextlowindex $05
	movedown $30
	moveright $10
	wait 30
	xorcfc0bit 0
	setcoords $f8, $f8
	checkcfc0bit 2
	xorcfc0bit 2
	setangleandanimation $18
	setcoords $98, $78
	callscript script7801
	setzspeed -$01c0
	wait 30
	showtextlowindex $06
	callscript script7809
	xorcfc0bit 7
	wait 30
	showtextlowindex $08
	xorcfc0bit 0
	jump2byte script77a6
script7801:
	setangleandanimation $18
	wait 30
	applyspeed $10
	moveup $30
	retscript
script7809:
	xorcfc0bit 1
	checkcfc0bit 2
	xorcfc0bit 2
	setzspeed -$01c0
	wait 30
	retscript
script7811:
	setstate $02
	asm15 scriptHlp.seasonsFunc_15_630f
	checkcfc0bit 1
	setzspeed -$01c0
	setangleandanimation $10
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script7822:
	setcoords $f8, $f8
	checkcfc0bit 0
script7826:
	playsound SND_PIRATE_BELL
	wait 60
	jump2byte script7826
script782b:
	setstate $02
	setdisabledobjectsto11
	wait 180
	setmusic MUS_PIRATES
	spawninteraction $b10a, $98, $78
	checkcfc0bit 7
	wait 30
	showtextlowindex $11
	asm15 scriptHlp.seasonsFunc_15_630a
	scriptend
script783e:
	setstate $02
	wait 10
	asm15 objectSetInvisible
	setcoords $58, $70
	asm15 setCameraFocusedObject
	setspeed SPEED_040
	moveright $20
script784e:
	moveleft $40
	moveright $40
	playsound SND_WAVE
	jump2byte script784e
script7856:
	callscript script7891
	showtextlowindex $0a
	callscript script7880
	callscript script7880
	callscript script7880
	writememory $d008, $03
	callscript script7880
	callscript script7880
	writememory $d008, $00
	wait 30
	showtextlowindex $0b
	spawninteraction $b10b, $98, $78
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script7880:
	setangle $19
	applyspeed $10
	setangle $04
	applyspeed $10
	setangle $1c
	applyspeed $10
	setangle $00
	applyspeed $10
	retscript
script7891:
	setstate $04
	setspeed SPEED_080
	wait 60
	retscript
script7897:
	callscript script7891
	showtextlowindex $0c
	writememory $d008, $02
	callscript script78c2
	callscript script78c2
	callscript script78c2
	writememory $d008, $01
	callscript script78c2
	writememory $d008, $00
	wait 30
	showtextlowindex $0d
	spawninteraction $b10c, $98, $78
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script78c2:
	setangle $07
	applyspeed $0f
	setangle $1b
	applyspeed $10
	setangle $03
	applyspeed $10
	setangle $00
	applyspeed $10
	retscript
script78d3:
	callscript script7891
	showtextlowindex $0e
	writememory $d008, $02
	callscript script7880
	callscript script7880
	callscript script7880
	wait 30
	writememory $d008, $03
	showtextlowindex $0f
	spawninteraction $b201, $98, $78
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script78f7:
	setstate $04
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script78ff:
	jumpifroomflagset $40, script7904
	scriptend
script7904:
	rungenericnpclowindex $15
script7906:
	jumpifglobalflagset $17, script790b
	scriptend
script790b:
	rungenericnpclowindex $16
script790d:
	rungenericnpclowindex $17
script790f:
	rungenericnpclowindex $18
script7911:
	rungenericnpclowindex $19
script7913:
	rungenericnpclowindex $1a
script7915:
	rungenericnpclowindex $1b
script7917:
	setstate $02
	asm15 objectSetInvisible
	jumpifglobalflagset $1b, stubScript
	setcollisionradii $38, $30
	checkcollidedwithlink_onground
	createpuff
	writeobjectbyte $5c, $02
	initcollisions
	setstate $05
	asm15 interactionSetAlwaysUpdateBit
	checkabutton
	asm15 scriptHlp.seasonsFunc_15_6324
	showtextlowindex $01
	setdisabledobjectsto11
	wait 30
	createpuff
	setglobalflag $1b
	enableallobjects
script793a:
	xorcfc0bit 0
	scriptend
script793c:
	setstate $06
	asm15 objectSetInvisible
	setcollisionradii $06, $0a
script7944:
	jumpifglobalflagset $1b, stubScript
	checkcollidedwithlink_onground
	showtextlowindex $00
	jump2byte script793a
script794d:
	setstate $06
	asm15 objectSetInvisible
	initcollisions
	jump2byte script7944
script7955:
	callscript script796d
	showtextlowindex $02
	xorcfc0bit 2
	callscript script796d
	showtextlowindex $04
	xorcfc0bit 2
	callscript script796d
	showtextlowindex $07
	xorcfc0bit 2
	checkcfc0bit 7
	setzspeed -$01c0
	jump2byte script77a6
script796d:
	checkcfc0bit 1
	xorcfc0bit 1
	setzspeed -$01c0
	wait 30
	retscript
script7974:
	setspeed SPEED_080
	callscript script7880
	callscript script7880
	writememory $d008, $02
	showtextlowindex $10
	xorcfc0bit 7
	jump2byte script77a6
script7985:
	jumpifroomflagset $40, script7999
	asm15 objectSetInvisible
	wait 4
	wait 60
	showtextlowindex $12
	wait 60
	spawninteraction $b203, $68, $68
	orroomflag $40
	scriptend
script7999:
	incstate
	setcoords $68, $78
	rungenericnpclowindex $14
script79a0:
	setspeed SPEED_100
	setangle $08
	applyspeed $10
	asm15 scriptHlp.seasonsFunc_15_6317
	setdisabledobjectsto11
	wait 60
	showtextlowindex $13
	resetmusic
	enableinput
	incstate
	rungenericnpclowindex $14


linkedCutsceneScript_witches1:
	checkflagset $00, wScrollMode
	disablemenu
	setdisabledobjects $35
	wait 40
	setcoords $58, $38
	asm15 restartSound
	asm15 scriptHlp.seasonsFunc_15_632f
	checkpalettefadedone
	showtextlowindex <TX_5000
	wait 30
	asm15 scriptHlp.seasonsFunc_15_6347
	wait 40
	setmusic MUS_ONOX_CASTLE
	createpuff
	wait 4
	asm15 scriptHlp.seasonsFunc_15_635e
	wait 90
	xorcfc0bit 0
	wait 10
	showtextlowindex <TX_5001
	wait 30
	createpuff
	xorcfc0bit 1
	wait 20
	setmusic SNDCTRL_MEDIUM_FADEOUT
	wait 90
	asm15 scriptHlp.seasonsFunc_15_6334
	checkpalettefadedone
	resetmusic
	setglobalflag GLOBALFLAG_WITCHES_1_SEEN
	enableinput
	scriptend


linkedCutsceneScript_witches2:
	checkflagset $00, wScrollMode
	disablemenu
	setdisabledobjects $35
	setcoords $18, $50
	wait 60
	setmusic SNDCTRL_MEDIUM_FADEOUT
	wait 90
	asm15 scriptHlp.seasonsFunc_15_634c
	wait 40
	createpuff
	wait 4
	asm15 scriptHlp.seasonsFunc_15_6363
	wait 90
	showtextlowindex <TX_5002
	wait 30
	createpuff
	xorcfc0bit 7
	writememory $cfc6, $00
	asm15 scriptHlp.seasonsFunc_15_6378
	wait 1
	asm15 scriptHlp.seasonsFunc_15_6383
	setmusic MUS_DISASTER
	checkcfc0bit 0
	setdisabledobjectsto91
	showtextlowindex <TX_5003
	showtextlowindex <TX_5004
	showtextlowindex <TX_5005
	showtextlowindex <TX_5006
	xorcfc0bit 0
	wait 40
	playsound SND_BEAM2
	checkcfc0bit 0
	wait 60
	asm15 scriptHlp.seasonsFunc_15_63a6
	setglobalflag GLOBALFLAG_WITCHES_2_SEEN
	scriptend


linkedCutsceneScript_zeldaVillagers:
	writememory wcc90, $01
	setcollisionradii $02, $02
	checkcollidedwithlink_onground
	writememory wCutsceneTrigger, CUTSCENE_S_ZELDA_VILLAGERS
	scriptend


linkedCutsceneScript_zeldaKidnapped:
	writememory wCutsceneTrigger, CUTSCENE_S_ZELDA_KIDNAPPED
	scriptend


linkedCutsceneScript_flamesOfDestruction:
	writememory wCutsceneTrigger, CUTSCENE_S_FLAME_OF_DESTRUCTION
	scriptend


script7a41:
	initcollisions
script7a42:
	checkabutton
	jumpifglobalflagset $29, script7a4d
	setglobalflag $29
	showtextlowindex $39
	jump2byte script7a42
script7a4d:
	showtextlowindex $36
	jump2byte script7a42
script7a51:
	initcollisions
script7a52:
	checkabutton
	jumpifglobalflagset $29, script7a5d
	setglobalflag $29
	showtextlowindex $3a
	jump2byte script7a52
script7a5d:
	showtextlowindex $37
	jump2byte script7a52
script7a61:
	initcollisions
script7a62:
	checkabutton
	jumpifglobalflagset $29, script7a6d
	setglobalflag $29
	showtextlowindex $3b
	jump2byte script7a62
script7a6d:
	showtextlowindex $38
	jump2byte script7a62
script7a71:
	writeobjectbyte $7f, $01
	setspeed SPEED_080
	moveup $41
	xorcfc0bit 1
	checkcfc0bit 2
	applyspeed $09
	setcounter1 $ff
	scriptend
script7a7f:
	rungenericnpclowindex $2b
script7a81:
	setspeed SPEED_080
	wait 180
script7a84:
	setangle $18
	applyspeed $18
	setcounter1 $06
	setangle $08
	applyspeed $14
	wait 120
	jump2byte script7a84
script7a91:
	scriptend
script7a92:
	setcoords $18, $18
	setspeed SPEED_200
	movedown $19
	wait 4
	moveright $1d
	wait 4
	setanimation $00
	wait 4
	showtext TX_500e
	wait 30
	showtext TX_500f
	wait 30
	xorcfc0bit 0
	setspeed SPEED_100
	setangle $18
	applyspeed $11
	setanimation $01
	wait 8
	setanimation $02
	setcounter1 $ff
	scriptend
script7ab7:
	checkmemoryeq $cfc0, $08
	setspeed SPEED_100
	moveup $31
	checkmemoryeq $cfc0, $0b
	movedown $31
	scriptend
script7ac6:
	settextid $0601
script7ac9:
	initcollisions
script7aca:
	checkabutton
	asm15 scriptHlp.seasonsFunc_15_63b8
	showloadedtext
	wait 10
	setanimationfromobjectbyte $7b
	jump2byte script7aca
script7ad5:
	settextid $0604
	jump2byte script7ac9
script7ada:
	settextid $0603
	jump2byte script7ac9
script7adf:
	settextid $0606
	jump2byte script7ac9
script7ae4:
	settextid $0602
	jump2byte script7ac9
script7ae9:
	settextid $0605
	jump2byte script7ac9
script7aee:
	initcollisions
	jumpifglobalflagset GLOBALFLAG_FINISHEDGAME, script7af8
	settextid $3101
	jump2byte script7afb
script7af8:
	settextid $310a
script7afb:
	checkabutton
	showloadedtext
	jump2byte script7afb
script7aff:
	loadscript script_14_5246


; ==============================================================================
; INTERACID_BOOMERANG_SUBROSIAN
; ==============================================================================
boomerangSubrosianScript:
	rungenericnpc TX_3e18


; ==============================================================================
; INTERACID_TROY
; ==============================================================================
troyScript_beginningSecret:
	initcollisions
--
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c00
	jumpiftextoptioneq $00, @awaitSecret
	jump2byte +
+
	wait 30
	showtextlowindex <TX_4c01
	jump2byte --
@awaitSecret:
	wait 30
	askforsecret CLOCK_SHOP_SECRET
	wait 30
	jumptable_memoryaddress wTextInputResult
	.dw @correct
	.dw @incorrect
@incorrect:
	showtextlowindex <TX_4c02
	jump2byte --
@correct:
	setglobalflag GLOBALFLAG_BEGAN_CLOCK_SHOP_SECRET
	showtextlowindex <TX_4c03
	jumpiftextoptioneq $00, troyScript_acceptedQuest
	jump2byte troyScript_rejectedQuest


troyScript_beganSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c0e
	jumpiftextoptioneq $00, troyScript_acceptedQuest
	
troyScript_rejectedQuest:
	wait 30
	showtextlowindex <TX_4c04
	jump2byte -
	
troyScript_acceptedQuest:
	wait 30
	showtextlowindex <TX_4c05
	jumpiftextoptioneq $00, @understoodQuest
	jump2byte troyScript_acceptedQuest
	
@understoodQuest:
	settileat $9d, $ac
	wait 15
	
troyScript_playGame:
	wait 30
	showtextlowindex <TX_4c06
	createpuff
	wait 4
	asm15 scriptHlp.seasonsFunc_15_6455
	setcounter1 $2d
	playsound SND_WHISTLE
	setmusic MUS_MINIBOSS
	writeobjectbyte $71, $00
	asm15 scriptHlp.seasonsFunc_15_6443
	enableinput
	incstate
	scriptend
	
	
troyScript_gameBegun:
	disableinput
	resetmusic
	playsound SND_WHISTLE
	writeobjectbyte Interaction.var31, $00
	asm15 fadeoutToWhite
	checkpalettefadedone
	asm15 scriptHlp.seasonsFunc_15_6464
	wait 30
	asm15 fadeinFromWhite
	checkpalettefadedone
	jumptable_objectbyte Interaction.var3a
	.dw @wonGame
	.dw troyScript_tookTooLong
	
@wonGame:
	showtextlowindex <TX_4c0a
	createpuff
	wait 4
	asm15 scriptHlp.seasonsFunc_15_645d
	setcounter1 $2d
	showtextlowindex <TX_4c0b
	disableinput
	callscript troyScript_postGameEffects
	callscript troyScript_giveReward
	writememory $cbea, $ff
	wait 90
	enableallobjects
	setdisabledobjectsto91
	settileat $9d, TILEINDEX_INDOOR_UPSTAIRCASE
	setcounter1 $2d
	setglobalflag GLOBALFLAG_DONE_CLOCK_SHOP_SECRET

troyScript_generateReturnSecret:
	generatesecret CLOCK_SHOP_RETURN_SECRET
-
	showtextlowindex <TX_4c0c
	wait 30
	jumpiftextoptioneq $00, -
	showtextlowindex <TX_4c0d
	enableinput
	wait 30

troyScript_doneBiggoronSecret:
	checkabutton
	disableinput
	jump2byte troyScript_generateReturnSecret


troyScript_giveReward:
	jumptable_objectbyte Interaction.var03
	.dw @nobleSword
	.dw @masterSword
@nobleSword:
	giveitem TREASURE_SWORD $01
	giveitem TREASURE_SWORD $04
	retscript
@masterSword:
	giveitem TREASURE_SWORD $02
	giveitem TREASURE_SWORD $05
	retscript
	
	
troyScript_postGameEffects:
	asm15 scriptHlp.troyMinigame_createSparkle
	wait 30
	asm15 scriptHlp.createSwirlAtLink
	wait 10
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	wait 20
	playsound SND_FADEOUT
	asm15 fadeoutToWhite
	checkpalettefadedone
	wait 20
	asm15 fadeinFromWhiteWithDelay, $04
	checkpalettefadedone
	retscript
	
	
troyScript_tookTooLong:
	showtextlowindex <TX_4c08
	createpuff
	wait 4
	asm15 scriptHlp.seasonsFunc_15_645d
	setcounter1 $2d
	showtextlowindex <TX_4c09
	jumpiftextoptioneq $00, troyScript_playGame
	settileat $9d, TILEINDEX_INDOOR_UPSTAIRCASE
	wait 15
	writeobjectbyte Interaction.var31, $00
	jump2byte troyScript_rejectedQuest


troyScript_doneSecret:
	initcollisions
	jump2byte troyScript_doneBiggoronSecret


; ==============================================================================
; INTERACID_S_LINKED_GAME_GHINI
; ==============================================================================
linkedGhiniScript_beginningSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c0f
	jumpiftextoptioneq $00, @answeredYes
	jump2byte @answeredNo
@answeredNo:
	wait 30
	showtextlowindex <TX_4c10
	jump2byte -
@answeredYes:
	wait 30
	askforsecret GRAVEYARD_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw @success
	.dw @failed
@failed:
	showtextlowindex <TX_4c12
	jump2byte -
@success:
	setglobalflag GLOBALFLAG_BEGAN_GRAVEYARD_SECRET
	showtextlowindex <TX_4c11
	jumpiftextoptioneq $00, linkedGhiniScript_begunSecret@showExplanation
	jump2byte linkedGhiniScript_begunSecret@shownExit


linkedGhiniScript_begunSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c14
	jumpiftextoptioneq $00, @showExplanation
@shownExit:
	wait 30
	showtextlowindex <TX_4c13
	jump2byte -
@showExplanation:
	wait 30
	showtextlowindex <TX_4c15
	jumpiftextoptioneq $00, @understoodExplanation
	jump2byte @showExplanation
@understoodExplanation:
	asm15 fadeoutToWhite
	checkpalettefadedone
	wait 4
	asm15 scriptHlp.linkedGhini_forceLinksPositionAndState
	settileat $61, $a2
	wait 4
	asm15 fadeinFromWhite
	checkpalettefadedone
@startGame:
	wait 30
	showtextlowindex <TX_4c16
	createpuff
	wait 4
	asm15 scriptHlp.linkedGhini_clearAllAndSetInvisible
	setcounter1 $2d
	playsound SND_WHISTLE
	scriptend


linkedGhiniScript_startRound:
	disableinput
	playsound SND_WHISTLE
	wait 30
	createpuff
	wait 4
	asm15 scriptHlp.linkedGhini_setVisible
	setcounter1 $2d
	showtextlowindex <TX_4c17
	asm15 scriptHlp.seasonsFunc_15_64a0
	wait 30
	jumptable_objectbyte $7f
	.dw @successfulRound
	.dw @failedGame
@successfulRound:
	jumptable_objectbyte $7a
	.dw @succeededOnce
	.dw @succeededTwice
	.dw @succeededAll
@succeededOnce:
@succeededTwice:
	playsound SND_GETSEED
	showtextlowindex <TX_4c19
	jump2byte linkedGhiniScript_begunSecret@startGame
@succeededAll:
	playsound SND_GETSEED
	showtextlowindex <TX_4c1a
	wait 30
	giveitem TREASURE_HEART_CONTAINER $02
	wait 60
	spawninteraction INTERACID_PUFF $00, $68, $18
	wait 4
	settileat $61, TILEINDEX_INDOOR_UPSTAIRCASE
	setcounter1 $2d
	setglobalflag GLOBALFLAG_DONE_GRAVEYARD_SECRET
@generateSecret:
	generatesecret GRAVEYARD_RETURN_SECRET
-
	showtextlowindex <TX_4c1b
	wait 30
	jumpiftextoptioneq $00, @understoodSecret
	jump2byte -
@understoodSecret:
	showtextlowindex <TX_4c1c
	enableinput
@doneBiggoronSecret:
	checkabutton
	disableinput
	jump2byte @generateSecret
@failedGame:
	playsound SND_ERROR
	showtextlowindex <TX_4c18
	jumpiftextoptioneq $00, linkedGhiniScript_begunSecret@startGame
	spawninteraction INTERACID_PUFF $00, $68, $18
	wait 4
	settileat $61, TILEINDEX_INDOOR_UPSTAIRCASE
	wait 15
	jump2byte linkedGhiniScript_begunSecret@shownExit


linkedGhiniScript_doneSecret:
	initcollisions
	jump2byte linkedGhiniScript_startRound@doneBiggoronSecret


; ==============================================================================
; INTERACID_GOLDEN_CAVE_SUBROSIAN
; ==============================================================================
goldenCaveSubrosianScript_beginningSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c1e
	jumpiftextoptioneq $00, @givingSecret
	wait 20
	showtextlowindex <TX_4c1f
	jump2byte -
@failed:
	showtextlowindex <TX_4c20
	jump2byte -
@givingSecret:
	askforsecret SUBROSIAN_SECRET
	wait 20
	jumptable_memoryaddress $cca3
	.dw @success
	.dw @failed
@success:
	orroomflag $80
	showtextlowindex <TX_4c21
	jumpiftextoptioneq $00, @answeredYes
	wait 20
	showtextlowindex <TX_4c22
	jump2byte goldenCaveSubrosianScript_givenSecret
@answeredYes:
	wait 20
	showtextlowindex <TX_4c23
	jumpiftextoptioneq $01, @answeredYes
	wait 20
	showtextlowindex <TX_4c24
	wait 20
	asm15 scriptHlp.seasonsFunc_15_653c, $01
	asm15 scriptHlp.goldenCaveSubrosian_refreshRoom, $87
	scriptend
	
	
goldenCaveSubrosianScript_7d00:
	initcollisions
	setcoords $88, $88
	setangleandanimation $00
	writeobjectbyte $79, $00
	setdisabledobjectsto11
	asm15 scriptHlp.goldenCaveSubrosian_emptyLinksItemsAndSetPosition
	asm15 scriptHlp.seasonsFunc_15_6545
	jumpifobjectbyteeq $7c, $03, script7d19
	asm15 scriptHlp.putAwayLinksItems, TREASURE_BOOMERANG
script7d19:
	checkpalettefadedone
	asm15 scriptHlp.seasonsFunc_15_6518
	writememory $cc02, $01
	wait 20
	showloadedtext
	setspeed SPEED_200
	setangleandanimation $10
	applyspeed $09
	wait 8
	setangleandanimation $18
	applyspeed $09
	wait 8
	setangleandanimation $00
	enableallobjects
script7d32:
	checkabutton
	asm15 scriptHlp.seasonsFunc_15_64e9
	jumptable_objectbyte $79
	.dw script7d40
	.dw script7d6b
	.dw script7d72
	.dw script7d77
script7d40:
	setdisabledobjectsto11
	settextid TX_4c28
script7d44:
	showloadedtext
	jumpiftextoptioneq $01, script7d56
	wait 20
	showtextlowindex <TX_4c3f
	wait 20
	asm15 scriptHlp.goldenCaveSubrosian_refreshRoom, $87
	asm15 scriptHlp.seasonsFunc_15_653c, $03
	scriptend
script7d56:
	wait 20
	showtextlowindex <TX_4c22
	setspeed SPEED_100
	setangleandanimation $00
	applyspeed $10
	wait 8
	wait 8
	setangleandanimation $10
	asm15 scriptHlp.seasonsFunc_15_5cf7
	asm15 scriptHlp.seasonsFunc_15_652e
	rungenericnpclowindex <TX_4c22
script7d6b:
	showtextlowindex <TX_4c29
	writeobjectbyte $79, $00
	jump2byte script7d32
script7d72:
	settextid TX_4c3e
	jump2byte script7d44
script7d77:
	setdisabledobjectsto11
	showtextlowindex <TX_4c2a
	writeobjectbyte $4f, $00
	wait 20
	asm15 scriptHlp.seasonsFunc_15_653c, $02
	asm15 scriptHlp.goldenCaveSubrosian_refreshRoom, $57
	scriptend
	
	
goldenCaveSubrosianScript_7d87:
	initcollisions
	setcoords $48, $78
	setangleandanimation $10
	disableinput
	asm15 scriptHlp.goldenCaveSubrosian_faceLinkUp
	asm15 scriptHlp.seasonsFunc_15_5cf7
	checkpalettefadedone
	showtextlowindex <TX_4c2b
	wait 20
	giveitem $0d00
	wait 20
--
	generatesecret SUBROSIAN_RETURN_SECRET
-
	showtextlowindex <TX_4c2c
	wait 20
	jumpiftextoptioneq $01, -
	showtextlowindex <TX_4c2d
	asm15 scriptHlp.seasonsFunc_15_652e
	setglobalflag GLOBALFLAG_DONE_SUBROSIAN_SECRET
script7dac:
	initcollisions
	enableinput
	checkabutton
	disableinput
	jump2byte --
	
	
goldenCaveSubrosianScript_givenSecret:
	initcollisions
	enableinput
	checkabutton
	disableinput
	jump2byte goldenCaveSubrosianScript_beginningSecret@success
	
	
; ==============================================================================
; INTERACID_LINKED_MASTER_DIVER
; ==============================================================================
masterDiverScript_beginningSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c2e
	jumpiftextoptioneq $00, @answeredYes
	jump2byte @answeredNo
@answeredNo:
	wait 30
	showtextlowindex <TX_4c2f
	jump2byte -
@answeredYes:
	wait 30
	askforsecret DIVER_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw @success
	.dw @failed
@failed:
	showtextlowindex <TX_4c30
	jump2byte -
@success:
	setglobalflag GLOBALFLAG_BEGAN_DIVER_SECRET
	showtextlowindex <TX_4c31
	jumpiftextoptioneq $00, masterDiverScript_begunSecret@answeredYes
	jump2byte masterDiverScript_begunSecret@beginningSecret
	
	
masterDiverScript_begunSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c3c
	jumpiftextoptioneq $00, @answeredYes
@beginningSecret:
	wait 30
	showtextlowindex <TX_4c32
	jump2byte -
@answeredYes:
	wait 30
	showtextlowindex <TX_4c33
-
	wait 30
	showtextlowindex <TX_4c34
	jumpiftextoptioneq $00, @startingChallenge
	jump2byte -
@startingChallenge:
	spawninteraction INTERACID_PUFF $00, $58, $88
	wait 4
	settileat $58, TILEINDEX_INDOOR_DOWNSTAIRCASE
	setcounter1 $2d
-
	showtextlowindex <TX_4c35
	enableinput
	checkabutton
	disableinput
	jump2byte -
	
	
masterDiverScript_swimmingChallengeText:
	disableinput
	wait 40
	showtextlowindex <TX_4c36
	asm15 scriptHlp.seasonsFunc_15_654e
	setcounter1 $2d
	playsound SND_WHISTLE
	enableinput
-
	jumpifitemobtained TREASURE_60, @finishedChallenge
	jump2byte -
@finishedChallenge:
	disableinput
	orroomflag $40
	playsound SND_WHISTLE
	asm15 scriptHlp.masterDiver_checkIfDoneIn30Seconds
	asm15 scriptHlp.linkedFunc_15_6430
	wait 30
	jumpifglobalflagset GLOBALFLAG_SWIMMING_CHALLENGE_SUCCEEDED, @finishedInTime
	showtextlowindex <TX_4c37
	jumpiftextoptioneq $00, @retry
	asm15 scriptHlp.masterDiver_exitChallenge
	scriptend
@retry:
	asm15 scriptHlp.seasonsFunc_15_6558
	asm15 scriptHlp.masterDiver_retryChallenge
	scriptend
@finishedInTime:
	showtextlowindex <TX_4c38
	asm15 scriptHlp.masterDiver_exitChallenge
	scriptend
	

masterDiverScript_swimmingChallengeDone:
	disableinput
	initcollisions
	asm15 scriptHlp.masterDiver_forceLinkState
	jumpifglobalflagset GLOBALFLAG_SWIMMING_CHALLENGE_SUCCEEDED, @finishedInTime
	jump2byte @failed
@finishedInTime:
	wait 40
	showtextlowindex <TX_4c39
	asm15 scriptHlp.linkedScript_giveRing, SWIMMERS_RING
	setcounter1 $02
	setglobalflag GLOBALFLAG_DONE_DIVER_SECRET
-
	showtextlowindex <TX_4c3a
	enableinput
@showDoneText:
	checkabutton
	disableinput
	jump2byte -
@failed:
	showtextlowindex <TX_4c30
	enableinput
	checkabutton
	disableinput
	jump2byte @failed
	
	
masterDiverScript_secretDone:
	initcollisions
	jump2byte masterDiverScript_swimmingChallengeDone@showDoneText
	
	
masterDiverScript_spawnFakeStarOre:
	spawnitem TREASURE_60 $01
	scriptend
	
	
; ==============================================================================
; INTERACID_S_GREAT_FAIRY
; Temple fairy that awaits a secret
; ==============================================================================
templeGreatFairyScript_beginningSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4101
	jumpiftextoptioneq $00, @tellSecret
@failedSecret:
	wait 30
	showtextlowindex <TX_4102
	jump2byte -
@tellSecret:
	askforsecret TEMPLE_SECRET
	wait 30
	jumptable_memoryaddress $cca3
	.dw @success
	.dw @failedSecret
@success:
	showtextlowindex <TX_4103
	wait 30
	asm15 scriptHlp.linkedScript_giveRing, HEART_RING_L1
	wait 30
-
	showtextlowindex <TX_4104
	setglobalflag GLOBALFLAG_DONE_TEMPLE_SECRET
	enableinput
	

templeGreatFairyScript_doneSecret:
	initcollisions
	checkabutton
	jump2byte -


; ==============================================================================
; INTERACID_DEKU_SCRUB
; ==============================================================================
dekuScrubScript_notFinishedGame:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c48
	wait 20
	jumpiftextoptioneq $00, @refillSatchel
	showtextlowindex <TX_4c41
	jump2byte -
@refillSatchel:
	showtextlowindex <TX_4c49
	asm15 refillSeedSatchel
	wait 20
-
	showtextlowindex <TX_4c4a
	enableinput
	checkabutton
	disableinput
	jump2byte -


dekuScrubScript_beginningSecret:
	initcollisions
-
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c40
	jumpiftextoptioneq $00, @linkKnowsSong
@failedSecret:
	wait 20
	showtextlowindex <TX_4c41
	jump2byte -
@linkKnowsSong:
	askforsecret DEKU_SECRET
	jumptable_memoryaddress wTextInputResult
	.dw @success
	.dw @failedSecret
@success:
	orroomflag $80
	wait 20
	showtextlowindex <TX_4c42
	wait 20
_dekuScrubScript_finishSecret:
	asm15 scriptHlp.dekuScrub_upgradeSatchel
	jumpifobjectbyteeq Interaction.var38, $00, dekuScrubScript_gaveSecret
	showtextlowindex <TX_4c44
	wait 20
	giveitem TREASURE_SATCHEL_UPGRADE $00
	asm15 refillSeedSatchel
	wait 20
	showtextlowindex <TX_4c45
	wait 20
	setglobalflag GLOBALFLAG_DONE_DEKU_SECRET
	jump2byte _dekuScrubScript_giveReturnSecret


dekuScrubScript_doneSecret:
	initcollisions
--
	checkabutton
	disableinput
_dekuScrubScript_giveReturnSecret:
	generatesecret DEKU_RETURN_SECRET
	showtextlowindex <TX_4c46
	wait 20
	jumpiftextoptioneq $00, _dekuScrubScript_giveReturnSecret
	showtextlowindex <TX_4c47
	enableinput
	jump2byte --


dekuScrubScript_gaveSecret:
	initcollisions
	enableinput
	checkabutton
	disableinput
	showtextlowindex <TX_4c43
	wait 30
	jump2byte _dekuScrubScript_finishSecret


; ==============================================================================
; INTERACID_GOLDEN_BEAST_OLD_MAN
; ==============================================================================
goldenBeastOldManScript:
	initcollisions
-
	checkabutton
	asm15 checkGoldenBeastsKilled
	jumptable_memoryaddress $cfc1
	.dw @notSlayed4Beasts
	.dw @slayed4Beasts
@notSlayed4Beasts:
	showtextlowindex <TX_1f04
	jump2byte -
@slayed4Beasts:
	showtextlowindex <TX_1f05
	disableinput
	asm15 giveRedRing
	wait 20
	showtextlowindex <TX_1f06
	wait 20
	orroomflag $40
	enableinput
	createpuff
	scriptend


; ==============================================================================
; INTERACID_S_VIRE
; ==============================================================================
vireScript:
	wait 30
	showtext TX_2f10
	wait 30
	showtext TX_2f11
	wait 30
	scriptend


; ==============================================================================
; INTERACID_LINKED_HEROS_CAVE_OLD_MAN
; ==============================================================================
linkedHerosCaveOldManScript:
	initcollisions
	jumpifroomflagset $80, @puzzleDone
-
	checkabutton
	showtextlowindex <TX_3303
	jumpiftextoptioneq $00, @answeredYes
	showtextlowindex <TX_3305
	jump2byte -
@notEnoughRupees:
	showtextlowindex <TX_3306
	jump2byte -
@answeredYes:
	asm15 linkedHerosCaveOldMan_takeRupees
	jumptable_memoryaddress $cfd0
	.dw @notEnoughRupees
	.dw @hasEnoughRupees
@hasEnoughRupees:
	disableinput
	asm15 linkedHerosCaveOldMan_spawnChests
	wait 60
	showtextlowindex <TX_3304
	enableinput
-
	checkabutton
	jumpifroomflagset $80, @puzzleSucceeded
	showtextlowindex <TX_3304
	jump2byte -
@puzzleSucceeded:
	showtextlowindex <TX_3307
@puzzleDone:
	rungenericnpclowindex <TX_3307


; ==============================================================================
; INTERACID_GET_ROD_OF_SEASONS
; ==============================================================================
gettingRodOfSeasons:
	loadscript gettingRodOfSeasons_body

setCounter1To32:
	setcounter1 $32
	scriptend

