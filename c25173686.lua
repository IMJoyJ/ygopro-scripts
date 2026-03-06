--ストレートフラッシュ
-- 效果：
-- 对方场上的魔法与陷阱卡区域全部有卡存在的场合才能发动。对方的魔法与陷阱卡区域存在的卡全部破坏。
function c25173686.initial_effect(c)
	-- 效果原文内容：对方场上的魔法与陷阱卡区域全部有卡存在的场合才能发动。
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
-- 规则层面操作：检查对方魔法与陷阱区域的0~4号位置是否都有卡存在
function c25173686.condition(e,tp,eg,ep,ev,re,r,rp)
	for i=0,4 do
		-- 规则层面操作：若任意一个位置为空则返回false，表示不满足发动条件
		if Duel.GetFieldCard(1-tp,LOCATION_SZONE,i)==nil then return false end
	end
	return true
end
-- 规则层面操作：过滤函数，用于筛选位于魔法与陷阱区域且非场地魔法的卡
function c25173686.filter(c)
	return c:GetSequence()<5
end
-- 效果原文内容：对方的魔法与陷阱卡区域存在的卡全部破坏。
function c25173686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否满足发动条件，即对方魔法与陷阱区域存在至少一张卡
	if chk==0 then return Duel.IsExistingMatchingCard(c25173686.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 规则层面操作：获取满足条件的对方魔法与陷阱区域的卡组
	local sg=Duel.GetMatchingGroup(c25173686.filter,tp,0,LOCATION_SZONE,nil)
	-- 规则层面操作：设置连锁操作信息，指定将要破坏的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果原文内容：对方的魔法与陷阱卡区域存在的卡全部破坏。
function c25173686.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：再次获取满足条件的对方魔法与陷阱区域的卡组
	local sg=Duel.GetMatchingGroup(c25173686.filter,tp,0,LOCATION_SZONE,nil)
	-- 规则层面操作：以效果原因将这些卡全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
