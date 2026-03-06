--ミステリーサークル
-- 效果：
-- 把自己场上任意数量的怪兽送去墓地发动。从自己卡组选择1只送去墓地的怪兽的合计等级的名字带有「外星」的怪兽特殊召唤。召唤失败的场合，自己受到2000分的伤害。
function c24082387.initial_effect(c)
	-- 效果原文：把自己场上任意数量的怪兽送去墓地发动。从自己卡组选择1只送去墓地的怪兽的合计等级的名字带有「外星」的怪兽特殊召唤。召唤失败的场合，自己受到2000分的伤害。
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
-- 效果作用：设置标记为100，表示已支付费用
function c24082387.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果作用：过滤满足条件的怪兽，包括属于外星卡组、可以特殊召唤、并且其等级总和等于目标等级的怪兽
function c24082387.filter1(c,e,tp,cg,minc)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and cg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),minc,99)
end
-- 效果作用：过滤可以作为墓地费用的怪兽，包括等级大于0、可以送去墓地、并且是怪兽类型的卡
function c24082387.cgfilter(c)
	return c:GetLevel()>0 and c:IsAbleToGraveAsCost() and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0
end
-- 效果作用：处理效果的发动阶段，包括选择要特殊召唤的怪兽、选择要送去墓地的怪兽并执行送去墓地操作、设置操作信息
function c24082387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：获取自己场上的所有可以送去墓地的怪兽
	local cg=Duel.GetMatchingGroup(c24082387.cgfilter,tp,LOCATION_MZONE,0,nil)
	-- 效果作用：获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=-ft+1
	if minc<=0 then minc=1 end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：检查自己卡组中是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(c24082387.filter1,tp,LOCATION_DECK,0,1,nil,e,tp,cg,minc)
	end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽用于特殊召唤
	local rg=Duel.SelectMatchingCard(tp,c24082387.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,cg,minc)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 效果作用：提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=cg:SelectWithSumEqual(tp,Card.GetLevel,e:GetLabel(),minc,99)
	-- 效果作用：将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(sg,REASON_COST)
	-- 效果作用：设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：过滤满足条件的怪兽，包括属于外星卡组、等级等于目标等级、并且可以特殊召唤
function c24082387.filter2(c,e,tp,lv)
	return c:IsSetCard(0xc) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：处理效果的发动，包括检查场上是否有空位、提示选择要特殊召唤的怪兽、执行特殊召唤或造成伤害
function c24082387.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否还有空位，如果没有则造成2000点伤害
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then Duel.Damage(tp,2000,REASON_EFFECT) return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽用于特殊召唤
	local g=Duel.SelectMatchingCard(tp,c24082387.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 效果作用：如果特殊召唤失败则造成2000点伤害
	else Duel.Damage(tp,2000,REASON_EFFECT) end
end
