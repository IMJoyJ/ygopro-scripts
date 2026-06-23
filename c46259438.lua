--契約洗浄
-- 效果：
-- ①：自己的魔法与陷阱区域的「契约书」卡全部破坏。自己从卡组抽出破坏的数量。那之后，自己回复抽出数量×1000基本分。
function c46259438.initial_effect(c)
	-- ①：自己的魔法与陷阱区域的「契约书」卡全部破坏。自己从卡组抽出破坏的数量。那之后，自己回复抽出数量×1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46259438.target)
	e1:SetOperation(c46259438.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选表侧表示的「契约书」卡（卡包编号0xae），且位于魔法与陷阱区域的前5个位置（即非场地魔法区）的卡片。
function c46259438.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xae) and c:GetSequence()<5
end
-- 效果发动时的处理函数，检查玩家是否可以抽卡，并确认是否存在满足条件的「契约书」卡。
function c46259438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行抽卡操作。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查玩家在魔法与陷阱区域中是否存在至少一张满足过滤条件的「契约书」卡。
		and Duel.IsExistingMatchingCard(c46259438.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 获取所有满足条件的「契约书」卡组成的组。
	local g=Duel.GetMatchingGroup(c46259438.filter,tp,LOCATION_SZONE,0,nil)
	-- 设置连锁操作信息，将要破坏的卡片组作为目标，并设定破坏效果分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁操作信息，将要抽卡的数量设为满足条件的「契约书」卡数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
	-- 设置连锁操作信息，将要回复的基本分设为抽卡数量乘以1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*1000)
end
-- 效果发动时的实际处理函数，执行破坏、抽卡和回复基本分的操作。
function c46259438.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的「契约书」卡组成的组。
	local g=Duel.GetMatchingGroup(c46259438.filter,tp,LOCATION_SZONE,0,nil)
	-- 将满足条件的卡片全部破坏，并返回实际被破坏的数量。
	local ct1=Duel.Destroy(g,REASON_EFFECT)
	if ct1==0 then return end
	-- 让玩家从卡组抽出与破坏数量相同的卡数。
	local ct2=Duel.Draw(tp,ct1,REASON_EFFECT)
	-- 中断当前效果处理，使后续效果视为不同时处理。
	Duel.BreakEffect()
	-- 使玩家回复抽卡数量乘以1000的基本分。
	Duel.Recover(tp,ct2*1000,REASON_EFFECT)
end
