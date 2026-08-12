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
-- 检查此卡是否因战斗破坏而送入墓地
function c20797524.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选「二轮车人」怪兽
function c20797524.filter(c,e,tp)
	return c:IsCode(83392426) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件，判断是否满足特殊召唤的条件
function c20797524.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或卡组中是否存在「二轮车人」怪兽
		and Duel.IsExistingMatchingCard(c20797524.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果发动时执行的操作，包括选择并特殊召唤「二轮车人」
function c20797524.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择一只「二轮车人」怪兽
	local g=Duel.SelectMatchingCard(tp,c20797524.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
