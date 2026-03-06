--猿魔王ゼーマン
-- 效果：
-- 暗属性调整＋调整以外的兽族怪兽1只
-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。对方怪兽的攻击宣言时，可以把自己的手卡或者场上1只怪兽送去墓地，让1只对方怪兽的攻击无效。
function c22858242.initial_effect(c)
	-- 添加同调召唤手续，需要1只暗属性调整和1只调整以外的兽族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_BEAST),1,1)
	c:EnableReviveLimit()
	-- 对方直到伤害步骤结束时魔法·陷阱卡不能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c22858242.aclimit)
	e1:SetCondition(c22858242.actcon)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，可以把自己的手卡或者场上1只怪兽送去墓地，让1只对方怪兽的攻击无效
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22858242,0))  --"攻击无效"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c22858242.condition)
	e2:SetCost(c22858242.cost)
	e2:SetTarget(c22858242.target)
	e2:SetOperation(c22858242.activate)
	c:RegisterEffect(e2)
end
-- 判断效果是否适用于魔法·陷阱卡的发动
function c22858242.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否为当前卡攻击时触发的效果
function c22858242.actcon(e)
	-- 判断攻击怪兽是否为当前卡
	return Duel.GetAttacker()==e:GetHandler()
end
-- 判断攻击方是否为对方
function c22858242.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 过滤满足条件的怪兽（可送去墓地作为费用）
function c22858242.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 支付费用：选择1张手牌或场上1只怪兽送去墓地
function c22858242.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽用于支付费用
	if chk==0 then return Duel.IsExistingMatchingCard(c22858242.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c22858242.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置目标：选择攻击怪兽作为效果对象
function c22858242.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(tg)
end
-- 无效此次攻击
function c22858242.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击无效
	Duel.NegateAttack()
end
