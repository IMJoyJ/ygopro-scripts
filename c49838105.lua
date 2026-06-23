--森羅の滝滑り
-- 效果：
-- 每次对方怪兽直接攻击宣言，可以把这张卡的效果发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，只要这张卡在场上存在，自己的抽卡阶段时作为进行通常抽卡的代替，自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡加入手卡。
function c49838105.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方怪兽直接攻击宣言，可以把这张卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49838105,0))  --"翻开卡组"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c49838105.condition)
	e2:SetTarget(c49838105.target)
	e2:SetOperation(c49838105.operation)
	c:RegisterEffect(e2)
	-- 自己的抽卡阶段时作为进行通常抽卡的代替，自己卡组最上面的卡翻开。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49838105,1))  --"抽卡代替"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c49838105.cfcon)
	e3:SetTarget(c49838105.cftg)
	e3:SetOperation(c49838105.cfop)
	c:RegisterEffect(e3)
end
-- 攻击方不是自己且没有攻击目标时才能发动
function c49838105.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方不是自己且没有攻击目标时才能发动
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 确认自己是否可以丢弃卡组最上方的1张卡
function c49838105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己是否可以丢弃卡组最上方的1张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 翻开卡组最上方的1张卡，若为植物族则送去墓地，否则回到卡组底端
function c49838105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否可以丢弃卡组最上方的1张卡
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 确认自己卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用洗切检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡移回卡组底端
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 在自己的抽卡阶段才能发动
function c49838105.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己的抽卡阶段才能发动
	return tp==Duel.GetTurnPlayer()
end
-- 确认自己是否可以进行通常抽卡并放弃通常抽卡
function c49838105.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己是否可以进行通常抽卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) end
	-- 使自己在当前回合的抽卡阶段放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp)
end
-- 翻开卡组最上方的1张卡，若为植物族则送去墓地，否则加入手牌并洗切手牌
function c49838105.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己卡组是否还有卡
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 确认自己卡组最上方的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 禁用洗切检测
	Duel.DisableShuffleCheck()
	if tc:IsRace(RACE_PLANT) then
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将翻开的卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
end
