--軍隊竜
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，从卡组选1张「军队龙」在自己的场上特殊召唤。之后卡组洗切。
function c55013285.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地的场合，从卡组选1张「军队龙」在自己的场上特殊召唤。之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55013285,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c55013285.condition)
	e1:SetTarget(c55013285.target)
	e1:SetOperation(c55013285.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否在墓地且是被战斗破坏
function c55013285.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中卡名为「军队龙」且可以特殊召唤的怪兽
function c55013285.filter(c,e,tp)
	return c:IsCode(55013285) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查，确认自身怪兽区域有空位且卡组中存在可特殊召唤的「军队龙」
function c55013285.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1张满足过滤条件的「军队龙」
		and Duel.IsExistingMatchingCard(c55013285.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1张「军队龙」特殊召唤到自己场上
function c55013285.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「军队龙」
	local g=Duel.SelectMatchingCard(tp,c55013285.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
