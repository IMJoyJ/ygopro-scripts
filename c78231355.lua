--ドラゴンメイドのお心づくし
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地把1只「半龙女仆」怪兽守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽是等级不同并是属性相同的1只「半龙女仆」怪兽从卡组送去墓地。
function c78231355.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地把1只「半龙女仆」怪兽守备表示特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽是等级不同并是属性相同的1只「半龙女仆」怪兽从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78231355+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c78231355.target)
	e1:SetOperation(c78231355.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：用于筛选手卡·墓地中可以表侧守备表示特殊召唤的「半龙女仆」怪兽
function c78231355.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的可行性检查：检查怪兽区域空位以及手卡·墓地是否存在可特殊召唤的「半龙女仆」怪兽
function c78231355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足特殊召唤条件的「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c78231355.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：用于筛选卡组中与已特殊召唤的怪兽属性相同、等级不同且能送去墓地的「半龙女仆」怪兽
function c78231355.tgfilter(c,mc)
	return c:IsSetCard(0x133) and c:IsType(TYPE_MONSTER) and c:IsAttribute(mc:GetAttribute()) and not c:IsLevel(mc:GetLevel()) and c:IsAbleToGrave()
end
-- 效果处理：特殊召唤手卡·墓地的「半龙女仆」怪兽，并可选择将卡组中属性相同且等级不同的「半龙女仆」怪兽送去墓地
function c78231355.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只满足条件的「半龙女仆」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78231355.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其以表侧守备表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 获取卡组中与特殊召唤的怪兽属性相同且等级不同的「半龙女仆」怪兽
		local tg=Duel.GetMatchingGroup(c78231355.tgfilter,tp,LOCATION_DECK,0,nil,g:GetFirst())
		-- 若卡组中存在满足条件的怪兽，询问玩家是否将其送去墓地
		if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(78231355,0)) then  --"是否从卡组把等级不同的怪兽送去墓地？"
			-- 中断当前效果处理，使后续的送去墓地处理不与特殊召唤同时进行（防止错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 将选择的怪兽因效果送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
