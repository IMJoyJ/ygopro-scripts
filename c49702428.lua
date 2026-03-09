--黒・魔・導・爆・裂・破
-- 效果：
-- ①：自己场上有「黑魔术少女」怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。
function c49702428.initial_effect(c)
	-- 效果原文内容：①：自己场上有「黑魔术少女」怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c49702428.condition)
	e1:SetTarget(c49702428.target)
	e1:SetOperation(c49702428.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查场上是否存在表侧表示的「黑魔术少女」怪兽
function c49702428.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x30a2)
end
-- 效果作用：判断是否满足发动条件，即己方场上存在「黑魔术少女」怪兽
function c49702428.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检测己方场上是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c49702428.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤出场上的表侧表示怪兽
function c49702428.filter(c)
	return c:IsFaceup()
end
-- 效果作用：设置连锁处理目标为对方场上的所有表侧表示怪兽，并设定破坏类别
function c49702428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即对方场上存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c49702428.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取对方场上所有表侧表示怪兽组成的组
	local g=Duel.GetMatchingGroup(c49702428.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置当前连锁的操作信息为破坏效果，并指定目标怪兽组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：执行破坏效果，将对方场上的所有表侧表示怪兽破坏
function c49702428.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取对方场上所有表侧表示怪兽组成的组
	local g=Duel.GetMatchingGroup(c49702428.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：以效果原因将目标怪兽组全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
