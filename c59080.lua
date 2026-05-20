--聖魔 裁きの雷
-- 效果：
-- 这个卡名在规则上也当作「大贤者」卡、「恩底弥翁」卡使用。
-- ①：可以把自己场上1张其他的表侧表示的「大贤者」卡送去墓地或2个魔力指示物取除，从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从自己的手卡·额外卡组（表侧）·墓地把1只魔法师族怪兽特殊召唤。
-- ●场上1张其他卡除外。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：可以把自己场上1张其他的表侧表示的「大贤者」卡送去墓地或2个魔力指示物取除，从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价的检查函数，用于判断在支付特定代价后是否仍有可执行的效果
function s.costcheck(c,ec,e,tp)
	-- 检查场上是否存在除当前卡和作为代价的卡以外的、可以被除外的卡
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
	-- 或者检查手卡、额外卡组、墓地是否存在可以特殊召唤的魔法师族怪兽
	or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 过滤满足送去墓地代价条件的、场上其他的表侧表示「大贤者」卡
function s.tgfilter(c,ec,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x150) and c:IsAbleToGraveAsCost() and s.costcheck(c,ec,e,tp)
end
-- 定义效果发动的代价（选择移除魔力指示物或将「大贤者」卡送去墓地）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能通过移除2个魔力指示物作为代价来发动效果
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x1,2,REASON_COST) and s.costcheck(nil,e:GetHandler(),e,tp)
	-- 检查是否能通过将场上1张其他的表侧表示「大贤者」卡送去墓地作为代价来发动效果
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp)
	if chk==0 then return b1 or b2 end
	local cost=0
	if b1 or b2 then
		-- 让玩家选择使用哪种发动代价
		cost=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"取除魔力指示物来发动"
			{b2,aux.Stringid(id,2),2})  --"把卡送墓来发动"
	end
	if cost==1 then
		-- 移除场上的2个魔力指示物
		Duel.RemoveCounter(tp,1,0,0x1,2,REASON_COST)
	elseif cost==2 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家选择1张场上其他的表侧表示「大贤者」卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e:GetHandler(),e,tp)
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤满足特殊召唤条件的魔法师族怪兽
function s.spfilter(c,e,tp,rc)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查非额外卡组的怪兽特殊召唤时，是否有可用的怪兽区域
		and (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,rc)>0
			-- 或者检查额外卡组的怪兽特殊召唤时，是否有可用的额外怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0)
end
-- 定义效果发动的目标，并让玩家选择要发动的效果分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在进行发动条件确认，且场上存在可作为代价送去墓地的「大贤者」卡
	local b0=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e:GetHandler(),e,tp) and e:IsCostChecked()
	-- 检查是否满足特殊召唤魔法师族怪兽效果的发动条件
	local b1=(Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,nil) or b0)
		-- 并且该特殊召唤效果在本回合尚未被选择过（或不进行代价检查）
		and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 检查是否满足除外场上1张其他卡效果的发动条件
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
		-- 并且该除外效果在本回合尚未被选择过（或不进行代价检查）
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择要发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},  --"特殊召唤"
			{b2,aux.Stringid(id,4),2})  --"除外"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册特殊召唤效果在本回合已选择过的标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 注册除外效果在本回合已选择过的标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_REMOVE)
		end
		-- 设置除外的操作信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
	end
end
-- 定义效果处理的函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择1只手卡、额外卡组（表侧）或墓地的魔法师族怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家选择场上1张其他的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 手动为选择的卡显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选择的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
