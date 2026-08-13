--トライクラー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己的手卡或者卡组把1只「二轮车人」在自己场上特殊召唤。
function c20797524.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己的手卡或者卡组把1只「二轮车人」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20797524,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c20797524.condition)
	e1:SetTarget(c20797524.target)
	e1:SetOperation(c20797524.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：当此卡被战斗破坏后处于墓地，且破坏原因为战斗时，才满足“被战斗破坏送去墓地时”的触发条件。
function c20797524.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选出卡名是「二轮车人」（83392426），并且能够被当前效果特殊召唤的卡（不检查召唤条件与苏生限制）。
function c20797524.filter(c,e,tp)
	return c:IsCode(83392426) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动前检查：我方主要怪兽区有空位，并且手卡或卡组中存在符合条件的「二轮车人」；同时向系统登记本次特殊召唤的操作信息。
function c20797524.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）先确认我方场上是否存在可用的主要怪兽区格子，若无空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续确认我方手卡或卡组中至少存在1只满足特殊召唤条件的「二轮车人」，满足条件则效果可以发动。
		and Duel.IsExistingMatchingCard(c20797524.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将在处理时进行特殊召唤，预定从手卡/卡组特殊召唤1只怪兽，操作者为发动方。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理时的实际操作：若场上仍有空格，则提示玩家选择1只「二轮车人」，从手卡或卡组选出后以表侧表示特殊召唤到自己场上。
function c20797524.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否有空格；若已无空格则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动者显示“请选择要特殊召唤的卡”的选卡提示，供后续选择框使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者从自己的手卡/卡组中选出1张满足条件的「二轮车人」作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c20797524.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「二轮车人」以表侧表示特殊召唤到我方场上，不检查其召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
