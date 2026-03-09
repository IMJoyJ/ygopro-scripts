--ナチュル・ハイドランジー
-- 效果：
-- 自己场上的名字带有「自然」的怪兽的效果发动的回合，这张卡可以从手卡特殊召唤。
function c47795344.initial_effect(c)
	-- 效果原文内容：自己场上的名字带有「自然」的怪兽的效果发动的回合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c47795344.spcon)
	c:RegisterEffect(e1)
	-- 设置一个代号为47795344、类型为连锁的计数器，并指定过滤函数为chainfilter。
	Duel.AddCustomActivityCounter(47795344,ACTIVITY_CHAIN,c47795344.chainfilter)
end
-- 过滤函数chainfilter用于判断是否满足特殊召唤条件，排除触发在怪兽区域的自然系怪兽效果。
function c47795344.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsSetCard(0x2a) and re:IsActiveType(TYPE_MONSTER)
		-- 判断连锁触发位置是否为主怪兽区，若为则不计入计数器。
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE)
end
-- 特殊召唤条件函数spcon，检查当前玩家是否有发动过自然系怪兽效果且场上存在空位。
function c47795344.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家是否在本回合发动过自然系怪兽效果（通过计数器判断）。
	return Duel.GetCustomActivityCount(47795344,tp,ACTIVITY_CHAIN)~=0
		-- 检查当前玩家场上是否有足够的主怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
