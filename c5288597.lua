--トランスターン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽送去墓地才能发动。和墓地的那只怪兽种族·属性相同而等级高1星的1只怪兽从卡组特殊召唤。
function c5288597.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示怪兽送去墓地才能发动。和墓地的那只怪兽种族·属性相同而等级高1星的1只怪兽从卡组特殊召唤。
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
-- 代价函数：进行代价检查时，先用标签100标记代价已通过；当处于发动合法性检查（chk==0）时直接返回true，表示该效果满足发动前提（实际送墓代价在目标选择时支付）。
function c5288597.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 筛选可作为发动代价的怪兽：必须是原本类型为怪兽、原等级大于0、表侧表示且可作为代价送去墓地，并且卡组中存在能以此怪兽为基准特殊召唤的候选。
function c5288597.cfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	local rc=c:GetRaceInGrave()
	local att=c:GetAttributeInGrave()
	return bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and lv>0 and c:IsFaceup() and c:IsAbleToGraveAsCost()
		-- 确认卡组中存在满足条件的特殊召唤候选：等级为原等级+1、与墓地该怪兽种族·属性相同，且可以被效果特殊召唤。
		and Duel.IsExistingMatchingCard(c5288597.spfilter,tp,LOCATION_DECK,0,1,nil,lv+1,rc,att,e,tp)
end
-- 特殊召唤候选的过滤条件：等级等于指定等级，种族、属性与墓地参照怪兽一致，并且可以被当前效果特殊召唤。
function c5288597.spfilter(c,lv,rc,att,e,tp)
	return c:IsLevel(lv) and c:IsRace(rc) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：在发动时检查阶段确认代价标记已设置、自己场上有可送墓的怪兽且场上区域允许；在发动确定后，选择1只怪兽作为代价送去墓地并将其设为效果对象，同时记录本次将进行卡组特殊召唤。
function c5288597.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否有怪兽区域可用（数量不小于0；具体空位在效果处理时再判定），作为发动条件之一。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
			-- 检查自己场上是否存在至少1只满足代价筛选条件（表侧表示、可送墓且卡组有对应可特殊召唤怪兽）的怪兽。
			and Duel.IsExistingMatchingCard(c5288597.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 向玩家显示选择提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1只满足代价条件的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c5288597.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽作为代价送去墓地。
	Duel.SendtoGrave(tc,REASON_COST)
	-- 把这张已送入墓地的怪兽设为当前效果的关联对象，用于后续处理时判断其是否仍然适用。
	Duel.SetTargetCard(tc)
	-- 设置本次连锁的操作信息：本次效果将从卡组特殊召唤1只怪兽，供其他卡片效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：处理时若自己场上有空位，则获取之前送去墓地的对象怪兽，按条件从卡组选择1只满足条件（等级+1、同种族·属性）的怪兽特殊召唤。
function c5288597.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则特殊召唤无法进行，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时作为代价送去墓地的那只怪兽（效果对象）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只等级为墓地怪兽等级+1、种族和属性均与墓地怪兽相同，且可以被特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c5288597.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel()+1,tc:GetRace(),tc:GetAttribute(),e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
