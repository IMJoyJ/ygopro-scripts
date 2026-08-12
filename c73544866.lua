--ガーディアン・バオウ
-- 效果：
-- 当自己场上存在「破邪之大剑-黄昏」时才能召唤·反转召唤·特殊召唤。这张卡每战斗破坏对方1只怪兽并将其送去墓地，攻击力上升1000点。被这张卡战斗破坏的效果怪兽的效果无效化。
function c73544866.initial_effect(c)
	-- 当自己场上存在「破邪之大剑-黄昏」时才能召唤·反转召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c73544866.sumcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	-- 当自己场上存在「破邪之大剑-黄昏」时才能……特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(c73544866.sumlimit)
	c:RegisterEffect(e3)
	-- 被这张卡战斗破坏的效果怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(c73544866.negop)
	c:RegisterEffect(e4)
	-- 这张卡每战斗破坏对方1只怪兽并将其送去墓地，攻击力上升1000点。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(73544866,0))  --"攻击上升"
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c73544866.atkcon)
	e5:SetOperation(c73544866.atkop)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己场上表侧表示的「破邪之大剑-黄昏」
function c73544866.cfilter(c)
	return c:IsFaceup() and c:IsCode(68427465)
end
-- 召唤·反转召唤的限制条件：自己场上不存在「破邪之大剑-黄昏」时不能进行召唤·反转召唤
function c73544866.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「破邪之大剑-黄昏」
	return not Duel.IsExistingMatchingCard(c73544866.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤的限制条件：必须在自己场上存在「破邪之大剑-黄昏」时才能特殊召唤
function c73544866.sumlimit(e,se,sp,st,pos,tp)
	-- 检查自己场上是否存在表侧表示的「破邪之大剑-黄昏」
	return Duel.IsExistingMatchingCard(c73544866.cfilter,sp,LOCATION_ONFIELD,0,1,nil)
end
-- 在伤害计算后，将战斗破坏的效果怪兽的效果无效化
function c73544866.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsType(TYPE_EFFECT) and bc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 被这张卡战斗破坏的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 被这张卡战斗破坏的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
-- 攻击力上升效果的发动条件：战斗破坏对方怪兽并送去墓地
function c73544866.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 攻击力上升效果的执行：自身攻击力上升1000点
function c73544866.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 攻击力上升1000点。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
