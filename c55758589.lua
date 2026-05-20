--フォトン・ワイバーン
-- 效果：
-- ①：这张卡召唤·反转召唤成功的场合发动。对方场上盖放的卡全部破坏。
function c55758589.initial_effect(c)
	-- ①：这张卡召唤·反转召唤成功的场合发动。对方场上盖放的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55758589,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c55758589.destg)
	e1:SetOperation(c55758589.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为里侧表示（盖放的卡）
function c55758589.filter(c)
	return c:IsFacedown()
end
-- 效果发动的目标确认与操作信息设置
function c55758589.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有里侧表示（盖放）的卡片
	local g=Duel.GetMatchingGroup(c55758589.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏对方场上所有盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对方场上所有盖放的卡
function c55758589.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有里侧表示（盖放）的卡片
	local g=Duel.GetMatchingGroup(c55758589.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
