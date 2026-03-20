--トランスターン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽送去墓地才能发动。和墓地的那只怪兽种族·属性相同而等级高1星的1只怪兽从卡组特殊召唤。
function c5288597.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCountLimit(1,5288597)
	e1:SetCost(c5288597.cost)
	e1:SetTarget(c5288597.target)
	e1:SetOperation(c5288597.activate)
	c:RegisterEffect(e1)
end
-- 设置cost标签为100，表示已支付费用。
function c5288597.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤场上满足条件的怪兽（必须是表侧表示、可送入墓地、且其种族和属性在墓地中存在符合条件的怪兽）。
function c5288597.cfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	local rc=c:GetRaceInGrave()
	local att=c:GetAttributeInGrave()
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and lv>0 and c:IsFaceup() and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在与所选怪兽种族、属性相同且等级高1星的怪兽。
		and Duel.IsExistingMatchingCard(c5288597.spfilter,tp,LOCATION_DECK,0,1,nil,lv+1,rc,att,e,tp)
end
-- 过滤满足等级、种族、属性条件且可特殊召唤的怪兽。
function c5288597.spfilter(c,lv,rc,att,e,tp)
	return c:IsLevel(lv) and c:IsRace(rc) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①：把自己场上1只表侧表示怪兽送去墓地才能发动。和墓地的那只怪兽种族·属性相同而等级高1星的1只怪兽从卡组特殊召唤。
function c5288597.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家场上是否有足够的怪兽区域。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 检查玩家场上是否存在满足条件的怪兽用于支付费用。
			and Duel.IsExistingMatchingCard(c5288597.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的怪兽送入墓地。
	local g=Duel.SelectMatchingCard(tp,c5288597.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽送入墓地作为发动代价。
	Duel.SendtoGrave(tc,REASON_COST)
	-- 设置当前连锁的目标为被送入墓地的怪兽。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示将从卡组特殊召唤一只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作。
function c5288597.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足等级、种族、属性条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c5288597.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel()+1,tc:GetRace(),tc:GetAttribute(),e,tp)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
