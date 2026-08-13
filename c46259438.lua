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
-- 筛选满足条件的卡：自己魔法与陷阱区域中表侧表示、属于「契约书」系列且不在场地魔法格（仅限后场5格）的卡。
function c46259438.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xae) and c:GetSequence()<5
end
-- 效果发动前的目标检测：检查当前是否满足发动条件，并预获取可供破坏的「契约书」卡。
function c46259438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件判定阶段，首先确认自己可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 并且确认自己魔法与陷阱区域存在至少1张符合条件的表侧表示「契约书」卡。
		and Duel.IsExistingMatchingCard(c46259438.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 获取当前场上所有符合条件的「契约书」卡，组成一个卡片组。
	local g=Duel.GetMatchingGroup(c46259438.filter,tp,LOCATION_SZONE,0,nil)
	-- 设置操作信息：本次效果将破坏这些「契约书」卡，数量为卡片组的卡数，用于连锁判定和检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：本次效果将进行抽卡，预计抽卡数量为破坏的卡片数量，抽卡玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
	-- 设置操作信息：本次效果将回复基本分，预计回复数值为破坏卡片数量×1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetCount()*1000)
end
-- 效果处理阶段：实际破坏符合条件的「契约书」卡，按破坏数量抽卡，再回复对应基本分。
function c46259438.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取符合条件的「契约书」卡，以保证处理的是当前实际存在的卡。
	local g=Duel.GetMatchingGroup(c46259438.filter,tp,LOCATION_SZONE,0,nil)
	-- 将这些「契约书」卡全部破坏，并记录实际被破坏的数量。
	local ct1=Duel.Destroy(g,REASON_EFFECT)
	if ct1==0 then return end
	-- 自己从卡组抽出与实际被破坏数量相同的卡。
	local ct2=Duel.Draw(tp,ct1,REASON_EFFECT)
	-- 中断连锁处理，使抽卡效果和之后的回复效果被视为不同时处理，避免影响后续时点。
	Duel.BreakEffect()
	-- 自己回复与抽卡数量×1000相等的基本分。
	Duel.Recover(tp,ct2*1000,REASON_EFFECT)
end
