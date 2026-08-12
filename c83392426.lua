--ヴィークラー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己的手卡或者卡组把1只「单轮车人」在自己场上特殊召唤。
function c83392426.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从自己的手卡或者卡组把1只「单轮车人」在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83392426,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c83392426.condition)
	e1:SetTarget(c83392426.target)
	e1:SetOperation(c83392426.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否被战斗破坏并送去墓地
function c83392426.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡名是「单轮车人」且可以特殊召唤的卡
function c83392426.filter(c,e,tp)
	return c:IsCode(57308711) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与检测（检查怪兽区域空位以及手卡·卡组是否存在可特召的「单轮车人」）
function c83392426.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或卡组是否存在至少1张满足过滤条件的「单轮车人」
		and Duel.IsExistingMatchingCard(c83392426.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理的执行（从手卡或卡组选择1只「单轮车人」特殊召唤）
function c83392426.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组选择1只「单轮车人」
	local g=Duel.SelectMatchingCard(tp,c83392426.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
