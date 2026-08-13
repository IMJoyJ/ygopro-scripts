--リバーシブル・ビートル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合发动。这张卡以及和这张卡相同纵列的怪兽全部变成里侧守备表示。
-- ②：这张卡反转的场合发动。这张卡以及和这张卡相同纵列的表侧表示怪兽全部回到持有者卡组。
function c45702357.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合发动。这张卡以及和这张卡相同纵列的怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45702357,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,45702357)
	e1:SetTarget(c45702357.postg)
	e1:SetOperation(c45702357.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡反转的场合发动。这张卡以及和这张卡相同纵列的表侧表示怪兽全部回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45702357,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e3:SetCountLimit(1,45702358)
	e3:SetTarget(c45702357.tdtg)
	e3:SetOperation(c45702357.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数：候选怪兽须属于包含自身和同纵列怪兽的组内，且当前可变为里侧表示。
function c45702357.posfilter(c,g)
	return g:IsContains(c) and c:IsCanTurnSet()
end
-- 目标函数：发动时无额外条件限制（chk==0即返回true）；获取效果持有者及其同纵列怪兽（含自身），筛选出其中可变为里侧表示的怪兽组，并设置操作信息为改变表示形式。
function c45702357.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	-- 从双方怪兽区筛选出属于该纵列组且可变为里侧表示的怪兽。
	local g=Duel.GetMatchingGroup(c45702357.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置操作信息：本次效果将处理‘改变表示形式’，目标为筛选出的怪兽组，数量为组内卡片数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理函数：若效果持有者仍与该效果关联，则重新获取符合条件的怪兽组，并将其全部变为里侧守备表示。
function c45702357.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	cg:AddCard(c)
	if c:IsRelateToEffect(e) then
		-- 处理阶段重新从双方怪兽区筛选出属于该纵列组且可变为里侧表示的怪兽（以应对处理时场上情况变化）。
		local g=Duel.GetMatchingGroup(c45702357.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
		if g:GetCount()>0 then
			-- 将目标怪兽全部变为里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤函数：候选怪兽须为表侧表示、属于指定纵列组，且能返回持有者卡组。
function c45702357.tdfilter(c,g)
	return c:IsFaceup() and g:IsContains(c) and c:IsAbleToDeck()
end
-- 目标函数：发动时无额外条件限制（chk==0即返回true）；获取效果持有者及其同纵列怪兽（若自身未被战斗破坏确定则加入自身），筛选出表侧表示且能回卡组的怪兽，并设置操作信息为回卡组。
function c45702357.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) then cg:AddCard(c) end
	-- 从双方怪兽区筛选出属于该纵列组、表侧表示且能返回持有者卡组的怪兽。
	local g=Duel.GetMatchingGroup(c45702357.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
	-- 设置操作信息：本次效果将处理‘回卡组’，目标为筛选出的怪兽组，数量为组内卡片数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 处理函数：若效果持有者仍与该效果关联，则重新获取符合条件的怪兽组，并将其全部返回持有者卡组并洗切。
function c45702357.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if not c:IsStatus(STATUS_BATTLE_DESTROYED) then cg:AddCard(c) end
	if c:IsRelateToEffect(e) then
		-- 处理阶段重新从双方怪兽区筛选出属于该纵列组、表侧表示且能返回持有者卡组的怪兽（以应对处理时场上情况变化）。
		local g=Duel.GetMatchingGroup(c45702357.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
		if g:GetCount()>0 then
			-- 将目标怪兽以效果原因返回各自持有者卡组并洗牌（SEQ_DECKSHUFFLE 表示回卡组后洗切）。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
