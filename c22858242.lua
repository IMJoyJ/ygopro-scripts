--猿魔王ゼーマン
-- 效果：
-- 暗属性调整＋调整以外的兽族怪兽1只
-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。对方怪兽的攻击宣言时，可以把自己的手卡或者场上1只怪兽送去墓地，让1只对方怪兽的攻击无效。
function c22858242.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只暗属性调整＋1只调整以外的兽族怪兽作为素材。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_BEAST),1,1)
	c:EnableReviveLimit()
	-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c22858242.aclimit)
	e1:SetCondition(c22858242.actcon)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，可以把自己的手卡或者场上1只怪兽送去墓地，让1只对方怪兽的攻击无效。
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
-- 判定对方发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），若是则不能发动。
function c22858242.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果条件：当前发动攻击的怪兽是这张卡自身。
function c22858242.actcon(e)
	-- 判断攻击宣言的怪兽是否为此卡。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 触发条件：攻击宣言的怪兽为对方怪兽（控制者是对方）。
function c22858242.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(1-tp)
end
-- 代价用的过滤条件：是怪兽卡且可以作为代价送去墓地。
function c22858242.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从自己的手卡或场上选1只怪兽送去墓地。
function c22858242.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己的手卡或场上是否存在1只可送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c22858242.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	-- 弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡或场上选择1张满足条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c22858242.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽卡送去墓地，作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果对象：选择攻击宣言的对方怪兽为对象。
function c22858242.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击宣言的怪兽。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击宣言的怪兽设置为效果对象。
	Duel.SetTargetCard(tg)
end
-- 效果处理：无效对方的攻击。
function c22858242.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该攻击。
	Duel.NegateAttack()
end
