--デスガエル
-- 效果：
-- 这张卡的祭品召唤成功时，可以把最多有自己墓地存在的「恶魂邪苦止」数量的「死亡青蛙」从手卡或者卡组特殊召唤。
function c84451804.initial_effect(c)
	-- 这张卡的祭品召唤成功时，可以把最多有自己墓地存在的「恶魂邪苦止」数量的「死亡青蛙」从手卡或者卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84451804,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c84451804.condition)
	e1:SetTarget(c84451804.target)
	e1:SetOperation(c84451804.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否上级召唤（祭品召唤）成功
function c84451804.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤手牌或卡组中卡名为「死亡青蛙」且可以特殊召唤的卡
function c84451804.filter(c,e,tp)
	return c:IsCode(84451804) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查，确认有空怪兽位、墓地有「恶魂邪苦止」且手牌或卡组有「死亡青蛙」
function c84451804.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张「恶魂邪苦止」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,10456559)
		-- 检查自己的手牌或卡组是否存在至少1张可以特殊召唤的「死亡青蛙」
		and Duel.IsExistingMatchingCard(c84451804.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从手牌或卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：根据墓地的「恶魂邪苦止」数量，从手牌或卡组特殊召唤对应数量的「死亡青蛙」
function c84451804.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的最大数量（取自己场上空怪兽区域数量与自己墓地「恶魂邪苦止」数量的较小值）
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,10456559))
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组选择1到ct张「死亡青蛙」
	local g=Duel.SelectMatchingCard(tp,c84451804.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,ct,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
