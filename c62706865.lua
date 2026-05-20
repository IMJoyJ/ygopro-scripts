--ドラコネット
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只2星以下的通常怪兽守备表示特殊召唤。
function c62706865.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只2星以下的通常怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62706865,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c62706865.sptg)
	e1:SetOperation(c62706865.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·卡组中2星以下的通常怪兽，且可以被特殊召唤
function c62706865.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标与条件检查
function c62706865.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c62706865.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，涉及手卡和卡组中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理的执行函数
function c62706865.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c62706865.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
