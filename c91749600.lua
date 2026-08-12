--王の呪 ヴァラ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「王战之咒 伐拉」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在手卡·墓地存在的场合，从手卡把1张其他的「王战」卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ③：这张卡特殊召唤成功的场合才能发动。从自己的手卡·墓地选「王战之咒 伐拉」以外的1只「王战」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①场上只能表侧表示存在1只；②手卡·墓地起动效果特殊召唤自身；③特殊召唤成功时诱发效果特殊召唤手卡·墓地其他「王战」怪兽。
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- ②：这张卡在手卡·墓地存在的场合，从手卡把1张其他的「王战」卡送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ③：这张卡特殊召唤成功的场合才能发动。从自己的手卡·墓地选「王战之咒 伐拉」以外的1只「王战」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以作为代价送去墓地的「王战」卡。
function s.cfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0x134)
end
-- 效果②的发动代价：从手卡将1张其他的「王战」卡送去墓地。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：检查手卡中是否存在除自身以外的「王战」卡可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1张除自身以外的「王战」卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：特殊召唤自身，并添加“从场上离开的场合除外”的限制。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。③：这张卡特殊召唤成功的场合才能发动。从自己的手卡·墓地选「王战之咒 伐拉」以外的1只「王战」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：手卡·墓地中除「王战之咒 伐拉」以外可以特殊召唤的「王战」怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x134) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的发动准备：检查是否有空余怪兽区域以及手卡·墓地中是否存在可特殊召唤的「王战」怪兽，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地中是否存在满足特殊召唤条件的「王战」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置从手卡·墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果③的效果处理：从手卡·墓地选择1只除「王战之咒 伐拉」以外的「王战」怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·墓地选择1只满足条件的「王战」怪兽（受「王家长眠之谷」影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
