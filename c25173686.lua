--ストレートフラッシュ
-- 效果：
-- 对方场上的魔法与陷阱卡区域全部有卡存在的场合才能发动。对方的魔法与陷阱卡区域存在的卡全部破坏。
function c25173686.initial_effect(c)
	-- 对方场上的魔法与陷阱卡区域全部有卡存在的场合才能发动。对方的魔法与陷阱卡区域存在的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c25173686.condition)
	e1:SetTarget(c25173686.target)
	e1:SetOperation(c25173686.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查对方场上通常魔陷区（0-4号位）是否全部有卡，任一位置为空则条件不成立，不能发动。
function c25173686.condition(e,tp,eg,ep,ev,re,r,rp)
	for i=0,4 do
		-- 获取对方场上序号i的魔陷区卡片，如果该位置没有卡，说明并非全部区域都有卡，返回false使发动条件不成立。
		if Duel.GetFieldCard(1-tp,LOCATION_SZONE,i)==nil then return false end
	end
	return true
end
-- 筛选函数：只选择当前位于魔法与陷阱卡区域且格子编号小于5的卡，即排除场地区（5号位）和灵摆区域（6-7号位），确保只破坏通常的魔法与陷阱卡区域中的卡。
function c25173686.filter(c)
	return c:GetSequence()<5
end
-- 效果发动时的目标与操作信息设定：在发动确认阶段检查对方场上是否存在符合条件的魔法陷阱卡；若存在，则将对方所有符合条件的魔陷卡收集起来并登记为破坏对象。
function c25173686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：chk==0时，确认对方场上至少存在1张符合条件的魔法陷阱卡（格子编号<5），否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25173686.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 将对方场上所有符合条件的魔法陷阱卡（格子编号<5）组成一个集合，用于登记本次效果的操作信息。
	local sg=Duel.GetMatchingGroup(c25173686.filter,tp,0,LOCATION_SZONE,nil)
	-- 将当前连锁的效果信息登记为破坏：破坏对象为sg集合，数量为集合中的卡数，目标玩家和位置参数为0（不取对象、处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理阶段实际执行：重新获取对方场上所有符合条件的魔法陷阱卡，并将它们全部破坏。
function c25173686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新筛选获取对方场上所有符合条件的魔法陷阱卡（格子编号<5），确保实际破坏的是效果处理时仍存在于那些区域的卡。
	local sg=Duel.GetMatchingGroup(c25173686.filter,tp,0,LOCATION_SZONE,nil)
	-- 以效果原因破坏这些卡，该破坏不入连锁，不取对象，并正常触发被破坏卡片的时点。
	Duel.Destroy(sg,REASON_EFFECT)
end
