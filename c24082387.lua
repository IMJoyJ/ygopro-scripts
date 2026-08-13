--ミステリーサークル
-- 效果：
-- 把自己场上任意数量的怪兽送去墓地发动。从自己卡组选择1只送去墓地的怪兽的合计等级的名字带有「外星」的怪兽特殊召唤。召唤失败的场合，自己受到2000分的伤害。
function c24082387.initial_effect(c)
	-- 把自己场上任意数量的怪兽送去墓地发动。从自己卡组选择1只送去墓地的怪兽的合计等级的名字带有「外星」的怪兽特殊召唤。召唤失败的场合，自己受到2000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetLabel(0)
	e1:SetCost(c24082387.cost)
	e1:SetTarget(c24082387.target)
	e1:SetOperation(c24082387.activate)
	c:RegisterEffect(e1)
end
-- 作为发动代价的检查函数：设置Label为100表示已确认过发动条件，返回true通过代价检查；实际送墓代价在目标选择时一并执行。
function c24082387.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤卡组中可作为特殊召唤对象的「外星」怪兽：必须是名字带有「外星」、能特殊召唤，并且场上代价候选怪兽中存在合计等级等于该怪兽等级的一组怪兽。
function c24082387.filter1(c,e,tp,cg,minc)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and cg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),minc,99)
end
-- 过滤场上可作为代价送去墓地的怪兽：要求等级大于0，可作为cost送去墓地，且原本类型为怪兽。
function c24082387.cgfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGraveAsCost() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 发动时的目标选择与代价处理：取得场上可送墓的怪兽集合和可用怪兽区空格数，计算至少需要送墓的数量；在发动时先选择1只卡组的「外星」怪兽并记录等级，再从场上选择合计等级等于该等级的任意数量怪兽送去墓地作为代价，同时设置特殊召唤的操作信息。
function c24082387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方场上所有可作为代价送去墓地的怪兽集合。
	local cg=Duel.GetMatchingGroup(c24082387.cgfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取我方主要怪兽区当前可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=-ft+1
	if minc<=0 then minc=1 end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在满足条件的「外星」怪兽——即可通过场上怪兽合计等级作代价来特殊召唤的对象。
		return Duel.IsExistingMatchingCard(c24082387.filter1,tp,LOCATION_DECK,0,1,nil,e,tp,cg,minc)
	end
	-- 提示玩家“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足filter1条件的「外星」怪兽作为特殊召唤对象。
	local rg=Duel.SelectMatchingCard(tp,c24082387.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,cg,minc)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 提示玩家“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=cg:SelectWithSumEqual(tp,Card.GetLevel,e:GetLabel(),minc,99)
	-- 将玩家选择的一组怪兽送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(sg,REASON_COST)
	-- 设置操作信息，标记本效果将在处理时进行1只怪兽的特殊召唤（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤效果处理时选择的「外星」怪兽：必须名字带有「外星」、等级等于发动时记录的等级且能特殊召唤。
function c24082387.filter2(c,e,tp,lv)
	return c:IsSetCard(0xc) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：若我方怪兽区无空格则直接受到2000伤害；否则从卡组选择1只相符的「外星」怪兽特殊召唤，若选择不到则受到2000伤害。
function c24082387.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方怪兽区没有可用空格，则特殊召唤不能进行，直接给予自己2000点效果伤害并结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then Duel.Damage(tp,2000,REASON_EFFECT) return end
	-- 提示玩家“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足filter2条件的「外星」怪兽作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c24082387.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的「外星」怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 当卡组中没有符合条件的「外星」怪兽时，特殊召唤失败，自己受到2000点效果伤害。
	else Duel.Damage(tp,2000,REASON_EFFECT) end
end
