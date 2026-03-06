--ジャスティス・ブリンガー
-- 效果：
-- 对方场上存在的特殊召唤的怪兽的效果发动时才能发动。那次发动无效。这个效果1回合只能使用1次。
function c26842483.initial_effect(c)
	-- 效果原文内容：对方场上存在的特殊召唤的怪兽的效果发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26842483,0))  --"效果无效"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c26842483.condition)
	e1:SetTarget(c26842483.target)
	e1:SetOperation(c26842483.operation)
	c:RegisterEffect(e1)
end
-- 效果原文内容：那次发动无效。
function c26842483.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：这个效果1回合只能使用1次。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 检索当前连锁的发动位置信息
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and re:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 判断连锁发动玩家是否为对方、发动位置是否为主怪区、发动效果是否为怪兽卡类型、连锁是否可被无效、发动怪兽是否为特殊召唤
function c26842483.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 设置效果处理时的操作信息为使发动无效
function c26842483.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
