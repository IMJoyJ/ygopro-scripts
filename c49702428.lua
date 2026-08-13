--黒・魔・導・爆・裂・破
-- 效果：
-- ①：自己场上有「黑魔术少女」怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。
function c49702428.initial_effect(c)
	-- ①：自己场上有「黑魔术少女」怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c49702428.condition)
	e1:SetTarget(c49702428.target)
	e1:SetOperation(c49702428.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：判定怪兽是否为表侧表示且持有卡名含有「黑魔术少女」字段（0x30a2）。
function c49702428.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x30a2)
end
-- 发动条件函数：确认自己场上的主要怪兽区是否存在至少1只满足 cfilter 条件的「黑魔术少女」怪兽。
function c49702428.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_MZONE）是否存在至少1张满足 cfilter 条件的「黑魔术少女」怪兽。
	return Duel.IsExistingMatchingCard(c49702428.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选函数：用于筛选对方场上的表侧表示怪兽，作为本次破坏的对象。
function c49702428.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标处理：先验证对方场上有表侧表示怪兽；然后将对方场上所有表侧表示怪兽登记为将要破坏的卡。
function c49702428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认对方场上的主要怪兽区是否存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c49702428.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上当前全部表侧表示怪兽的集合，作为本次破坏的对象群。
	local g=Duel.GetMatchingGroup(c49702428.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置本次连锁的处理信息：效果类别为破坏（CATEGORY_DESTROY），目标为上述怪兽群，数量为群中卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：重新取得对方场上所有表侧表示怪兽，并将其全部破坏。
function c49702428.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次取得对方场上所有表侧表示怪兽的集合，确保使用最新状态。
	local g=Duel.GetMatchingGroup(c49702428.filter,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）将集合中的所有怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
