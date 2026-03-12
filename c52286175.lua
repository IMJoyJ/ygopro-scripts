--トラップ・リアクター・RR
-- 效果：
-- 对方把陷阱卡发动时才能发动。把那张陷阱卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c52286175.initial_effect(c)
	-- 效果原文内容：对方把陷阱卡发动时才能发动。把那张陷阱卡破坏，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52286175,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c52286175.condition)
	e1:SetTarget(c52286175.target)
	e1:SetOperation(c52286175.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方发动陷阱卡
function c52286175.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 效果作用：设置连锁处理时的破坏和伤害操作信息
function c52286175.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 效果作用：设置将目标陷阱卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 效果作用：设置给予对方800分伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果作用：执行破坏并造成伤害的效果处理
function c52286175.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：确认陷阱卡仍在场上且成功破坏后造成伤害
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 效果作用：对对方造成800分伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
