--豊穣のアルテミス
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己从卡组抽1张。
function c32296881.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c32296881.drop)
	c:RegisterEffect(e1)
end
-- 检测发动的卡是否为反击陷阱卡，是则执行抽卡效果
function c32296881.drop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	-- 向玩家显示此卡发动的动画提示
	Duel.Hint(HINT_CARD,0,32296881)
	-- 中断当前效果处理，避免时点错乱
	Duel.BreakEffect()
	-- 让发动者从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
