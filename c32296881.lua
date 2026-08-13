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
-- 效果处理函数：在连锁处理结束时，检查本次连锁中发动的效果是否为反击陷阱卡的发动，若是则触发本卡的效果进行抽卡。
function c32296881.drop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	-- 向玩家展示丰穰之阿耳特弥斯的卡片动画，提示该效果正在发动。
	Duel.Hint(HINT_CARD,0,32296881)
	-- 中断当前效果处理流程，使后续的抽卡处理独立于当前连锁解决时点，避免错时点。
	Duel.BreakEffect()
	-- 让这张卡的控制者tp从卡组抽1张卡，抽卡原因视为效果。
	Duel.Draw(tp,1,REASON_EFFECT)
end
