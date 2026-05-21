--水精鱗－アビスヒルデ
-- 效果：
-- 这张卡被送去墓地的场合，可以从手卡把「水精鳞-深渊希德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊希德」的效果1回合只能使用1次。
function c96682430.initial_effect(c)
	-- 这张卡被送去墓地的场合，可以从手卡把「水精鳞-深渊希德」以外的1只名字带有「水精鳞」的怪兽特殊召唤。「水精鳞-深渊希德」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96682430,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,96682430)
	e1:SetTarget(c96682430.target)
	e1:SetOperation(c96682430.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中除「水精鳞-深渊希德」以外的名字带有「水精鳞」且可以特殊召唤的怪兽
function c96682430.filter(c,e,tp)
	return c:IsSetCard(0x74) and not c:IsCode(96682430) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标与条件检查：检查自己场上是否有可用的怪兽区域，以及手牌中是否存在满足条件的怪兽
function c96682430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c96682430.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：在自己场上有可用怪兽区域时，从手牌选择1只满足条件的「水精鳞」怪兽特殊召唤
function c96682430.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96682430.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
