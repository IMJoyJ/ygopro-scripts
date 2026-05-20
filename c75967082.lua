--漏電
-- 效果：
-- 自己场上名字带有「电池人」的怪兽有3只以上表侧表示存在的场合才能发动。对方场上存在的卡全部破坏。
function c75967082.initial_effect(c)
	-- 自己场上名字带有「电池人」的怪兽有3只以上表侧表示存在的场合才能发动。对方场上存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c75967082.condition)
	e1:SetTarget(c75967082.target)
	e1:SetOperation(c75967082.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选表侧表示且卡名含有「电池人」的卡
function c75967082.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x28)
end
-- 发动条件：自己场上存在3只以上表侧表示的「电池人」怪兽
function c75967082.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区是否存在至少3张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c75967082.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 效果发动时的目标确认与操作信息设置
function c75967082.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：预计破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：将对方场上的卡全部破坏
function c75967082.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的对方场上的所有卡
	Duel.Destroy(g,REASON_EFFECT)
end
