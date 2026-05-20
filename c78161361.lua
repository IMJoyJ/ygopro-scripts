--ドライブレイブ
-- 效果：
-- ①：1回合1次，自己的电子界族怪兽的攻击宣言时，从手卡丢弃1只怪兽才能发动。那只攻击怪兽的攻击力直到回合结束时上升600。
function c78161361.initial_effect(c)
	-- ①：1回合1次，自己的电子界族怪兽的攻击宣言时，从手卡丢弃1只怪兽才能发动。那只攻击怪兽的攻击力直到回合结束时上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(78161361,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c78161361.atkcon)
	e1:SetCost(c78161361.atkcost)
	e1:SetTarget(c78161361.atktg)
	e1:SetOperation(c78161361.atkop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：是否为自己控制的电子界族怪兽进行攻击宣言
function c78161361.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(tp) and a:IsRace(RACE_CYBERSE)
end
-- 过滤条件：手卡中可以丢弃的怪兽卡
function c78161361.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 执行发动代价：从手卡丢弃1只怪兽
function c78161361.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查手卡中是否存在可丢弃的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78161361.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡中选择1只怪兽丢弃送去墓地
	Duel.DiscardHand(tp,c78161361.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 确定效果目标：使攻击怪兽与该效果建立关系
function c78161361.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 使当前攻击怪兽与该效果建立关系，以便在效果处理时确认其状态
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 执行效果处理：使攻击怪兽的攻击力上升
function c78161361.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToEffect(e) and a:IsFaceup() then
		-- 那只攻击怪兽的攻击力直到回合结束时上升600。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		a:RegisterEffect(e1)
	end
end
