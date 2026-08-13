--ナチュル・ハイドランジー
-- 效果：
-- 自己场上的名字带有「自然」的怪兽的效果发动的回合，这张卡可以从手卡特殊召唤。
function c47795344.initial_effect(c)
	-- 自己场上的名字带有「自然」的怪兽的效果发动的回合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c47795344.spcon)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录玩家是否发动过满足chainfilter条件的“效果发动”行为，以便后续判断特殊召唤条件。
	Duel.AddCustomActivityCounter(47795344,ACTIVITY_CHAIN,c47795344.chainfilter)
end
-- 定义活动计数器的过滤函数：如果本次发动的是名字带有「自然」的怪兽效果，且是从场上（主要怪兽区）发动的，则返回false，使计数器增加1，表示该操作被记录。
function c47795344.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsSetCard(0x2a) and re:IsActiveType(TYPE_MONSTER)
		-- 进一步限定效果发动的位置必须在主要怪兽区，即该自然怪兽效果是自己场上的怪兽发动的。
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
end
-- 定义特殊召唤规则效果的条件：若c不存在则允许规则处理；否则需要本回合已有符合条件的自然怪兽效果发动，并且自己的主要怪兽区有空位，才能从手卡特殊召唤。
function c47795344.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自定义活动计数器的值不为0，即本回合确实发动过满足条件的自然怪兽效果。
	return Duel.GetCustomActivityCount(47795344,tp,ACTIVITY_CHAIN)~=0
		-- 检查玩家自己的主要怪兽区是否还有空位，确保特殊召唤能够进行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
