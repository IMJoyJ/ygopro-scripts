--魔装戦士 テライガー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的通常怪兽守备表示特殊召唤。
function c56681873.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的通常怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56681873,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c56681873.sptg)
	e1:SetOperation(c56681873.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中等级4以下、可以守备表示特殊召唤的通常怪兽
function c56681873.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的可行性检查（是否有可用怪兽区域，以及手卡中是否存在符合条件的怪兽）
function c56681873.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c56681873.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只满足条件的通常怪兽守备表示特殊召唤
function c56681873.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无可用区域则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c56681873.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
