--漆黒のズムウォルト
-- 效果：
-- 暗属性调整＋调整以外的昆虫族怪兽1只
-- 这张卡不会被战斗破坏。这张卡的攻击宣言时，攻击对象怪兽的攻击力比这张卡的攻击力高的场合，攻击对象怪兽的攻击力直到战斗阶段结束时变成和这张卡相同数值。这张卡战斗破坏对方怪兽送去墓地时，从对方卡组上面把3张卡送去墓地。
function c31919988.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽必须为暗属性，调整以外的怪兽必须为昆虫族，数量为1只。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_INSECT),1,1)
	c:EnableReviveLimit()
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡的攻击宣言时，攻击对象怪兽的攻击力比这张卡的攻击力高的场合，攻击对象怪兽的攻击力直到战斗阶段结束时变成和这张卡相同数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31919988,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c31919988.atcon)
	e2:SetTarget(c31919988.attg)
	e2:SetOperation(c31919988.atop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽送去墓地时，从对方卡组上面把3张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31919988,1))  --"卡组破坏"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c31919988.ddcon)
	e3:SetTarget(c31919988.ddtg)
	e3:SetOperation(c31919988.ddop)
	c:RegisterEffect(e3)
end
-- 攻击变化效果的发动条件：这张卡进行攻击宣言时，其战斗对象存在、表侧表示，且攻击力高于这张卡的当前攻击力。
function c31919988.atcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:GetAttack()>e:GetHandler():GetAttack()
end
-- 攻击变化效果发动时，将战斗对象卡与当前效果建立联系，作为效果处理时的关联对象。
function c31919988.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():GetBattleTarget():CreateEffectRelation(e)
end
-- 效果处理时进行合法性判定：这张卡和战斗对象必须仍与效果关联、均非里侧表示，且战斗对象攻击力仍高于这张卡；否则不处理。
function c31919988.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or tc:GetAttack()<=c:GetAttack() then return end
	-- 攻击对象怪兽的攻击力直到战斗阶段结束时变成和这张卡相同数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
end
-- 卡组破坏效果的发动条件：这张卡战斗破坏的对方怪兽被送去墓地，且破坏原因为战斗。
function c31919988.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 卡组破坏效果发动时无指定对象，设置操作信息，表示将以效果从对方卡组上方把3张卡送去墓地。
function c31919988.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：效果类别为卡组破坏，预定从对方（1-tp）卡组上方将3张卡送去墓地，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,3)
end
-- 卡组破坏效果处理：以效果原因将对方卡组最上方3张卡送去墓地。
function c31919988.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将对方（1-tp）卡组最上方3张卡送去墓地。
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
