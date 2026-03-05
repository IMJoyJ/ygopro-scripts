--マジック・リアクター・AID
-- 效果：
-- 对方把魔法卡发动时才能发动。把那张魔法卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c15175429.initial_effect(c)
	-- 效果原文内容：对方把魔法卡发动时才能发动。把那张魔法卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15175429,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c15175429.condition)
	e1:SetTarget(c15175429.target)
	e1:SetOperation(c15175429.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否为对方发动的魔法卡效果
function c15175429.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 规则层面作用：设置效果处理时的破坏和伤害操作信息
function c15175429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 规则层面作用：设置将要被破坏的魔法卡作为操作目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 规则层面作用：设置给予对方基本分800伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 规则层面作用：执行破坏魔法卡并造成伤害的效果
function c15175429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：确认魔法卡仍在场上且成功破坏后造成伤害
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 规则层面作用：给与对方基本分800伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
