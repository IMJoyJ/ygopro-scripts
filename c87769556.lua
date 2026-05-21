--魔術師の右手
-- 效果：
-- ①：1回合1次，自己场上有魔法师族怪兽存在的场合，对方发动的魔法卡的效果无效并破坏。
function c87769556.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上有魔法师族怪兽存在的场合，对方发动的魔法卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c87769556.negcon)
	e2:SetOperation(c87769556.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为表侧表示的魔法师族怪兽
function c87769556.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 判断是否满足效果无效的条件：自己场上有魔法师族怪兽存在，且对方发动了魔法卡的效果
function c87769556.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c87769556.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
-- 效果处理：使对方发动的魔法卡效果无效并将其破坏
function c87769556.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上显示该卡（魔术师的右手）的效果发动提示
	Duel.Hint(HINT_CARD,0,87769556)
	local rc=re:GetHandler()
	-- 若成功使效果无效，且该卡仍与该效果关联
	if Duel.NegateEffect(ev,true) and rc:IsRelateToEffect(re) then
		-- 因效果将该卡破坏
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
